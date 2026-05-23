-- ============================================
-- SATURNITY HOP TEST  (Android / Termux)
-- width-aware: wraps to real terminal columns
-- so split-screen / high-dpi never breaks.
-- by @lanavienrose
-- ============================================

local C = "\27[93m"
local P = "\27[1;96m"
local G = "\27[1;92m"
local R = "\27[1;91m"
local D = "\27[97m"
local X = "\27[0m"

-- detect real terminal width
local function detect_w()
    local w
    local h = io.popen("stty size 2>/dev/null")
    if h then
        local s = h:read("*a") or ""; h:close()
        w = tonumber(s:match("%d+%s+(%d+)"))
    end
    if not w then
        local h2 = io.popen("tput cols 2>/dev/null")
        if h2 then w = tonumber(h2:read("*a")); h2:close() end
    end
    if not w then w = tonumber(os.getenv("COLUMNS") or "") end
    if not w or w < 12 then w = 24 end
    return w
end
local W = detect_w()

local function line() io.write(string.rep("-", W).."\n"); io.flush() end

-- word-wrap plain text to W, then color each line
local function cp(col, text)
    local lines, cur = {}, ""
    for word in text:gmatch("%S+") do
        if #cur + #word + (cur=="" and 0 or 1) > W then
            lines[#lines+1] = cur; cur = word
        else
            cur = (cur=="") and word or cur.." "..word
        end
    end
    if cur ~= "" then lines[#lines+1] = cur end
    if #lines == 0 then lines[1] = "" end
    for _,l in ipairs(lines) do io.write(col..l..X.."\n") end
    io.flush()
end

local function su(cmd)
    os.execute("su -c '"..cmd:gsub("'","'\\''").."' >/dev/null 2>&1")
end
local function ask(q)
    cp(C, q); io.write("\27[1;96m> \27[0m"); io.flush()
    return io.read("*l")
end
local function sleep(n) os.execute("sleep "..n) end
local function send_url(url, pkg)
    su("am start --user 0 -a android.intent.action.VIEW"
        .." -d \""..url.."\" -p "..pkg)
end
local function countdown(secs, label)
    for i=secs,1,-1 do
        local s = label.." "..i.."s"
        if #s > W then s = s:sub(1, W) end
        io.write("\r"..D..s..string.rep(" ", W-#s)..X)
        io.flush(); sleep(1)
    end
    io.write("\r"..string.rep(" ", W).."\r"); io.flush()
end

os.execute("clear")
line()
cp(P, "[ SATURNITY HOP TEST ]")
line()
cp(D, "no typing after start. watch the clone screen.")
cp(D, "term width = "..W)
line()

local pkg = ask("package (e.g. com.roblox.clienv)")
if not pkg or pkg=="" then cp(R,"cancelled.") return end
local linkA = ask("server A full link")
if not linkA or linkA=="" then cp(R,"cancelled.") return end
local linkB = ask("server B link (different)")
if not linkB or linkB=="" then cp(R,"cancelled.") return end
local lw = tonumber(ask("server A load wait sec (def 40)")) or 40

line()
cp(P, "STARTING IN 5s")
cp(D, "switch to the clone and watch it")
line()
countdown(5, "starting")

cp(D, "[1] opening roblox")
su("am start --user 0 -n "..pkg
    .."/com.roblox.client.startup.ActivitySplash")
sleep(6)
cp(D, "[2] sending server A link")
send_url(linkA, pkg)
countdown(lw, "loading A")
cp(G, ">>> in server A now <<<")
sleep(2)

cp(R, "*** WATCH: sending server B ***")
cp(D, "does the game RELOAD next 30s?")
send_url(linkB, pkg)
countdown(30, "watching")

line()
cp(P, "DONE - what did you see?")
line()
cp(D, "if game RELOADED (loading/play screen again):")
cp(G, "  teleport works, no force-stop")
cp(D, "if it STAYED, no reload:")
cp(R, "  no teleport, needs force-stop")
line()
cp(D, "tell saturnity which one.")
line()
 
