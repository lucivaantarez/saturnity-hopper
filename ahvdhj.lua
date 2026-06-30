--[[=====================================================================
    adm_autotrade.lua  —  Adopt Me auto-trade (Delta)
    For moving your own items between your own accounts.

    Everything is controlled from the CONFIG block below. Each feature has
    its own on/off, plus a master on/off. Edit, push to GitHub, done.

    SECTIONS
      1. CONFIG          — all toggles + settings (the only part you edit)
      2. SETUP           — loads game modules once
      3. FORCE SETTINGS  — forces Trading -> Everyone so bots can invite you
      4. AUTO-ACCEPT     — auto-answers the game's own trade-request dialog
      5. TRADE DRIVER    — accept -> confirm through to completion
      6. IDLE WATCHDOG   — kick or rehop if no trade for a while
      7. MAIN LOOP       — ties it together with a crash-proof watchdog
=======================================================================]]

--[[=====================================================================
    1. CONFIG  —  THE ONLY PART YOU NEED TO EDIT
=======================================================================]]
local CONFIG = {

    MASTER_ENABLED = true,        -- master on/off for the entire script

    FORCE_SETTINGS = {
        enabled = true,           -- force Trading/Give -> "Everyone"
        also_force_giving = true, -- also force give_item_requests (gifting)
    },

    AUTO_ACCEPT = {
        enabled = true,           -- auto-accept requests + drive trades
        poll = 0.4,               -- seconds between checks
        refire_every = 1.0,       -- re-send accept/confirm at most this often
    },

    IDLE_WATCHDOG = {
        enabled = false,          -- leave the server when idle
        idle_seconds = 120,       -- no trade for this long -> act
        mode = "rehop",           -- "rehop" (fresh server) or "kick" (leave)
    },

    WEBHOOK = {
        enabled = true,          -- Discord webhook on completed trade
        url = "https://discord.com/api/webhooks/1481617340247576729/oNNhsQuK_3MoXArfADV6fv5_xk4nIuxMWPCarj5c-_fw6nav2BtOM60xh5232tegePUm",                 -- your Discord webhook URL
        report = "received",      -- "received" / "given" / "both"
    },

    DEBUG = true,                 -- print status to the Delta console
}

--[[=====================================================================
    2. SETUP
=======================================================================]]
local function log(...) if CONFIG.DEBUG then print("[autotrade]", ...) end end

if not CONFIG.MASTER_ENABLED then
    log("MASTER_ENABLED = false — script is off")
    return
end

local Players         = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer     = Players.LocalPlayer

-- SINGLETON GUARD: if a previous run of this script is already looping in this
-- client, abort this one. Prevents double webhooks from a second execute.
if getgenv then
    if getgenv().__adm_autotrade_active then
        print("[autotrade] already running in this client — aborting duplicate")
        return
    end
    getgenv().__adm_autotrade_active = true
end

local Fsys = require(game.ReplicatedStorage:WaitForChild("Fsys"))
local load = Fsys.load

-- Load ONLY UIManager eagerly — it's all the accept hook needs, and getting
-- the hook in fast is what prevents the first-request race. Everything else
-- (settings DB, KindDB) is loaded lazily AFTER the hook is in.
local UIManager
pcall(function() UIManager = load("UIManager") end)

local SettingsHelper, SettingsDB, KindDB
local deps_ready = false
local function ensure_deps()
    if deps_ready then return end
    pcall(function()
        SettingsHelper = load("SettingsHelper")
        SettingsDB     = require(game.ReplicatedStorage.ClientDB.SettingsDB)
        KindDB         = load("KindDB")   -- kind -> display name
    end)
    deps_ready = (SettingsDB ~= nil)
end

-- idle state (declared early so the accept hook + driver can use it)
local last_activity = os.clock()
local function mark_activity() last_activity = os.clock() end

--[[=====================================================================
    3. FORCE SETTINGS  —  Trading -> Everyone (saves to server immediately)
=======================================================================]]
local function force_everyone(id)
    ensure_deps()
    pcall(function()
        local def = SettingsDB.by_id[id]
        if not def then return end
        local idx = table.find(def.element_options.choices, "Everyone")
        if not idx then return end
        SettingsHelper.set_setting_client({ setting_id = id, value = idx })
        log("setting", id, "-> Everyone")
    end)
end

local function force_trade_settings()
    if not CONFIG.FORCE_SETTINGS.enabled then return end
    force_everyone("trade_requests")
    if CONFIG.FORCE_SETTINGS.also_force_giving then
        force_everyone("give_item_requests")
    end
end

--[[=====================================================================
    4. AUTO-ACCEPT  —  auto-answer Adopt Me's own trade-request dialog
       We let the game's native accept path run (it does the real
       InvokeServer + the trade-start handshake that opens the window).
       We just (a) stop it auto-declining on join, (b) answer its dialog
       with "Accept", (c) skip the suspicious-captcha / scam popups so
       nothing can hang. Returns true once the dialog hook is in place.
=======================================================================]]
-- Neutralize every blocking popup in the trade flow on the TradeApp instance.
-- All are method calls (self:method()), so instance overrides shadow the class.
local function patch_trade_app(app)
    if not app or app.__autotrade_patched then return end
    -- suspicious-player captcha ("not your friend!")
    app._confirm_player_if_suspicious = function() return true end
    -- unbalanced-trade warnings ("seems unbalanced", "BANNABLE!", victim warning)
    app._evaluate_trade_fairness     = function() end
    app._show_scam_perpetrator_warning = function() end
    app._show_scam_victim_warning      = function() end
    app._show_experimental_warning     = function() end
    app.show_scam_warning              = function() end
    -- pet-paint-will-be-cleared confirm
    app._confirm_clear_colored_pets    = function() end
    app.__autotrade_patched = true
    log("trade warnings neutralized")
end

local function install_accept_hook()
    if not CONFIG.AUTO_ACCEPT.enabled then return false end
    if not UIManager then return false end

    local apps = UIManager.apps
    if not apps then return false end

    -- (a) don't let the game auto-decline before showing the dialog
    pcall(function() load("MinigameForcedState").can_receive_invites = function() return true end end)
    pcall(function() load("TradeExcluder").is_player_excluded = function() return false end end)

    -- (b) auto-answer the "trade_request" dialog with Accept
    local DialogApp = apps.DialogApp
    if not DialogApp then return false end
    if not DialogApp.__autotrade_hooked then
        local orig = DialogApp.dialog
        DialogApp.dialog = function(self, opts)
            if opts and opts.handle == "trade_request" then
                mark_activity()
                log("auto-accepting trade request dialog")
                return "Accept"
            end
            return orig(self, opts)
        end
        DialogApp.__autotrade_hooked = true
    end

    -- (c) neutralize suspicious-captcha, scam warnings, unbalanced warnings, etc.
    local TradeApp = apps.TradeApp
    if TradeApp then patch_trade_app(TradeApp) end

    return true
end

--[[=====================================================================
    8. WEBHOOK  —  Discord notify on completed trade (real display names)
       Translates each item's `kind` -> KindDB[kind].name in-game, groups
       by name + form, and posts quantities. Fires only when BOTH sides
       confirmed (a real completion, not a cancel).
=======================================================================]]
local function http_post(url, body)
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if not req then log("no HTTP function (request) available") return end
    pcall(function()
        req({ Url = url, Method = "POST",
              Headers = { ["Content-Type"] = "application/json" }, Body = body })
    end)
end

local function pet_label(item)
    if not KindDB then ensure_deps() end
    local def  = KindDB and KindDB[item.kind]
    local name = (def and def.name) or item.kind
    local p    = item.properties or {}
    local pre  = p.mega_neon and "Mega Neon " or (p.neon and "Neon " or "")
    local tag  = ""
    if p.rideable then tag = tag .. "R" end
    if p.flyable  then tag = tag .. "F" end
    if tag ~= "" then tag = " [" .. tag .. "]" end
    return pre .. name .. tag
end

local function summarize(items)
    local counts, order = {}, {}
    for _, item in ipairs(items or {}) do
        local lbl = pet_label(item)
        if not counts[lbl] then order[#order+1] = lbl end
        counts[lbl] = (counts[lbl] or 0) + 1
    end
    local lines = {}
    for _, lbl in ipairs(order) do lines[#lines+1] = ("%dx %s"):format(counts[lbl], lbl) end
    return lines, #(items or {})
end

local last_sig, last_sig_time = nil, 0
local function send_trade_webhook(received, given, partner_name)
    if not CONFIG.WEBHOOK.enabled or CONFIG.WEBHOOK.url == "" then return end

    -- dedup: a real second trade can't complete within a few seconds (lock
    -- timers), so an identical signature inside the window is a double-fire.
    local sig = tostring(partner_name) .. "|" .. tostring(#(received or {})) .. "|" .. tostring(#(given or {}))
    for _, it in ipairs(received or {}) do sig = sig .. it.kind end
    if sig == last_sig and (os.clock() - last_sig_time) < 6 then
        log("duplicate trade suppressed")
        return
    end
    last_sig, last_sig_time = sig, os.clock()

    local fields = {}
    local rep = CONFIG.WEBHOOK.report
    if rep ~= "given" then
        local lines, n = summarize(received)
        fields[#fields+1] = { name = ("Received (%d)"):format(n),
            value = (#lines>0 and table.concat(lines, "\n") or "nothing"), inline = false }
    end
    if rep == "given" or rep == "both" then
        local lines, n = summarize(given)
        fields[#fields+1] = { name = ("Given (%d)"):format(n),
            value = (#lines>0 and table.concat(lines, "\n") or "nothing"), inline = false }
    end
    local payload = {
        username = "Saturnity Hop",
        embeds = {{
            title = "Trade complete",
            description = partner_name and ("with **" .. partner_name .. "**") or nil,
            color = 5763719,
            fields = fields,
            footer = { text = LocalPlayer.Name },
        }},
    }
    local ok, body = pcall(function() return game:GetService("HttpService"):JSONEncode(payload) end)
    if ok then http_post(CONFIG.WEBHOOK.url, body) log("webhook sent") end
end


local app_cache = nil
local function get_trade_app()
    if app_cache then return app_cache end
    local ok, app = pcall(function() return UIManager.apps.TradeApp end)
    if ok and app then app_cache = app patch_trade_app(app) return app end
    return nil
end

local last_stage, last_fire = nil, 0
local in_trade = false
-- completion tracking for the webhook
local completing = false
local pending_received, pending_given, pending_partner = nil, nil, nil

local function step_trade()
    if not CONFIG.AUTO_ACCEPT.enabled then in_trade = false return end

    local app = get_trade_app()
    if not app then last_stage = nil in_trade = false return end

    local state = app:_get_local_trade_state()
    if not state then
        if last_stage == "confirmation" then
            if completing then
                send_trade_webhook(pending_received, pending_given, pending_partner)
            end
            log("trade complete")
        end
        completing = false
        pending_received, pending_given, pending_partner = nil, nil, nil
        last_stage = nil
        in_trade = false
        return
    end

    in_trade = true
    mark_activity()  -- pause idle watchdog while a trade is open

    local stage = state.current_stage
    if stage ~= last_stage then
        log("stage:", stage)
        last_stage = stage
        last_fire = 0
    end

    -- detect real completion: both sides confirmed (cache items before close)
    if stage == "confirmation" then
        local mine    = app:_get_my_offer()
        local partner = app:_get_partner_offer()
        if mine and partner and mine.confirmed and partner.confirmed then
            completing       = true
            pending_received = partner.items
            pending_given    = mine.items
            local me   = LocalPlayer
            local pp   = (state.sender == me) and state.recipient or state.sender
            pending_partner = (typeof(pp) == "Instance" and pp.Name) or nil
        end
    end

    if os.clock() - last_fire < CONFIG.AUTO_ACCEPT.refire_every then return end
    last_fire = os.clock()

    if stage == "negotiation" then
        pcall(function() app:_on_accept_pressed() end)
    elseif stage == "confirmation" then
        pcall(function() app:_on_confirm_pressed() end)
    end
end

--[[=====================================================================
    6. IDLE WATCHDOG
=======================================================================]]
local watchdog_fired = false
local function check_idle()
    if not CONFIG.IDLE_WATCHDOG.enabled then return false end
    if in_trade or watchdog_fired then return false end
    if os.clock() - last_activity < CONFIG.IDLE_WATCHDOG.idle_seconds then return false end

    watchdog_fired = true
    if CONFIG.IDLE_WATCHDOG.mode == "kick" then
        log("idle -> kick")
        pcall(function() LocalPlayer:Kick("autotrade: idle") end)
    else
        log("idle -> rehop")
        pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
    end
    return true
end

--[[=====================================================================
    7. MAIN LOOP
=======================================================================]]
log("starting | accept:", CONFIG.AUTO_ACCEPT.enabled,
    "| settings:", CONFIG.FORCE_SETTINGS.enabled,
    "| idle:", CONFIG.IDLE_WATCHDOG.enabled)

-- is the CURRENT DialogApp instance actually hooked? (catches instance swaps
-- where the UI replaces DialogApp after a cold load, leaving a stale hook)
local function hook_ready()
    if not UIManager or not UIManager.apps then return false end
    local d = UIManager.apps.DialogApp
    return d ~= nil and d.__autotrade_hooked == true
end

-- settings-only mode: nothing races, just force once and (maybe) exit
if not CONFIG.AUTO_ACCEPT.enabled then
    force_trade_settings()
    if not CONFIG.IDLE_WATCHDOG.enabled then
        log("only settings enabled — done")
        if getgenv then getgenv().__adm_autotrade_active = nil end
        return
    end
end

-- SPIN-WAIT: install the hook the instant the apps exist, before the first
-- request can land. Fast retry (per-frame), not the slow 0.4s poll.
if CONFIG.AUTO_ACCEPT.enabled then
    local t0 = os.clock()
    repeat
        install_accept_hook()
        if hook_ready() then break end
        task.wait()
    until os.clock() - t0 > 30
    log(hook_ready() and "accept hook ready (spin)" or "hook not ready after 30s — will keep retrying")
end

local settings_done = false
while true do
    -- re-verify the hook every poll; re-install if DialogApp was swapped
    if CONFIG.AUTO_ACCEPT.enabled and not hook_ready() then
        install_accept_hook()
    end

    -- force settings only after the hook is confirmed in
    if hook_ready() and not settings_done then
        force_trade_settings()
        settings_done = true
    end

    local ok, err = pcall(step_trade)
    if not ok then log("step error:", err) end

    if check_idle() then
        if getgenv then getgenv().__adm_autotrade_active = nil end
        break
    end

    task.wait(CONFIG.AUTO_ACCEPT.poll)
end
