-- ============================================
-- SATURNITY HOP TEST
-- tests if in-game deep link teleports
-- to a new server WITHOUT force-stop
-- by @lanavienrose
-- ============================================

local P = "\27[1;96m" -- bold bright cyan (headers)
local C = "\27[93m"   -- bright yellow (state values)
local G = "\27[1;92m" -- bold bright green (success)
local R = "\27[1;91m" -- bold bright red (fail)
local D = "\27[97m"   -- bright white (info, was dim)
local X = "\27[0m"    -- reset

local function line() print(string.rep("-",49)) end
local function out(s) io.write(s.."\n"); io.flush() end

local function su(cmd)
    os.execute("su -c '"..cmd:gsub("'","'\\''").."' >/dev/null 2>&1")
end

local function sucmd(cmd)
    local h = io.popen("su -c '"..cmd:gsub("'","'\\''").."' 2>&1")
    if not h then return "" end
    local r = h:read("*a") or ""; h:close()
    r = r:gsub("\27%[[%d;]*[A-Za-z]","")
         :gsub("[\r\n\t]",""):gsub("%c","")
         :gsub("^%s+",""):gsub("%s+$","")
    return r
end

local function ask(q)
    io.write("\27[93m  "..q.."\27[0m\n\27[1;96m  > \27[0m"); io.flush()
    return io.read("*l")
end

local function sleep(n) os.execute("sleep "..n) end

-- detect current roblox state
local function get_act(pkg)
    local r = sucmd("dumpsys activity | grep "..pkg
        .." | grep -v '#' | head -5")
    if r:match("GameActivity") or r:match("RobloxGameActivity") then
        return "INGAME"
    elseif r:match("SplashActivity") or r:match("ActivitySplash") then
        return "LOADING"
    elseif r:match("[Mm]ain") or r:match("[Hh]ome")
        or r:match("LuaApp") or r:match("RobloxApp") then
        return "MENU"
    elseif r:match("[Ee]rror") then
        return "ERROR"
    end
    local pid = sucmd("pidof "..pkg)
    if pid~="" then return "UNKNOWN" end
    return "DEAD"
end

local function send_deeplink(code)
    su("am start --user 0 -a android.intent.action.VIEW"
        .." -d \"roblox://navigation/share_links?code="
        ..code.."&type=Server\"")
end

-- monitor state for N seconds, print changes
local function watch(pkg, secs, label)
    out(D.."  watching "..label.." for "..secs.."s..."..X)
    local last = ""
    for i=1,secs do
        local a = get_act(pkg)
        if a ~= last then
            out("    "..string.format("%02d",i).."s  "..C..a..X)
            last = a
        end
        sleep(1)
    end
    return last
end

-- ============================================
-- MAIN
-- ============================================
os.execute("clear")
line()
out("  "..P.."[ SATURNITY HOP TEST ]"..X)
line()
out(D.."  goal: see if a deep link sent WHILE")
out("  in-game teleports to a new server")
out("  without needing force-stop."..X)
out("")
line()

local pkg = ask("roblox package (e.g. com.roblox.clientb)")
if not pkg or pkg=="" then out(R.."  cancelled."..X); return end

local codeA = ask("server A code (first server)")
if not codeA or codeA=="" then out(R.."  cancelled."..X); return end

local codeB = ask("server B code (DIFFERENT server)")
if not codeB or codeB=="" then out(R.."  cancelled."..X); return end

out("")
line()
out("  "..P.."PHASE 1"..X.."  open + join server A")
line()

-- open roblox to lobby
out(D.."  opening roblox..."..X)
su("am start --user 0 -n "..pkg
    .."/com.roblox.client.startup.ActivitySplash")
sleep(6)

-- send deep link A
out(D.."  sending deep link A..."..X)
send_deeplink(codeA)

-- watch until in-game (up to 60s)
out(D.."  waiting for arrival in server A..."..X)
local arrived = false
local last = ""
for i=1,60 do
    local a = get_act(pkg)
    if a ~= last then
        out("    "..string.format("%02d",i).."s  "..C..a..X)
        last = a
    end
    if a == "INGAME" then
        arrived = true
        out("  "..G.."ARRIVED in server A at "..i.."s"..X)
        break
    end
    sleep(1)
end

if not arrived then
    out("")
    out(R.."  never reached INGAME for server A.")
    out("  test stopped. server A join itself failed."..X)
    return
end

-- stay a moment to be sure it's stable
out(D.."  holding 8s to confirm stable in-game..."..X)
sleep(8)
local before = get_act(pkg)
out("  state before teleport:  "..C..before..X)

out("")
line()
out("  "..P.."PHASE 2"..X.."  send deep link B (NO force-stop)")
line()
out(D.."  sending deep link B while in server A..."..X)
send_deeplink(codeB)

-- watch what happens for 45s
out(D.."  watching reaction..."..X)
local saw_loading = false
local saw_ingame_again = false
local saw_menu = false
local lst = before
for i=1,45 do
    local a = get_act(pkg)
    if a ~= lst then
        out("    "..string.format("%02d",i).."s  "..C..a..X)
        lst = a
        if a == "LOADING" then saw_loading = true end
        if a == "MENU" then saw_menu = true end
    end
    sleep(1)
end

out("")
line()
out("  "..P.."RESULT"..X)
line()
out("  final state:  "..C..lst..X)
out("")

if lst == "INGAME" and saw_loading then
    out("  "..G.."TELEPORT WORKS!"..X)
    out(D.."  it left server A, loaded, and is")
    out("  in-game again = teleported to B.")
    out("  blitz mode possible, NO force-stop."..X)
elseif lst == "INGAME" and not saw_loading then
    out("  "..C.."UNCLEAR"..X)
    out(D.."  still in-game but never saw a")
    out("  reload. might still be server A.")
    out("  check the screen: did it change server?"..X)
elseif saw_menu or lst == "MENU" then
    out("  "..R.."KICKED TO LOBBY"..X)
    out(D.."  deep link while in-game dumped it")
    out("  to menu instead of teleporting.")
    out("  blitz needs force-stop between hops."..X)
else
    out("  "..R.."NO CLEAN TELEPORT"..X)
    out(D.."  final state "..lst..". check screen.")
    out("  likely needs force-stop method."..X)
end
out("")
line()
out(D.."  IMPORTANT: also look at the actual")
out("  roblox screen now. tell me if it is")
out("  in server B, server A, or the lobby."..X)
line()
