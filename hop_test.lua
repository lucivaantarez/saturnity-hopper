-- ============================================
-- SATURNITY HOP TEST  (Android / Termux)
-- forces narrow width so split-screen wraps
-- right. tests send-once vs send-twice.
-- by @lanavienrose
-- ============================================

-- FORCE a narrow terminal so nothing overflows
os.execute("stty cols 40 rows 30 2>/dev/null")
local W = 40

local C = "\27[93m"
local P = "\27[1;96m"
local G = "\27[1;92m"
local R = "\27[1;91m"
local D = "\27[97m"
local X = "\27[0m"

local function line() io.write(string.rep("-", W).."\n"); io.flush() end
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
cp(P, "[ SATURNITY HOP TEST 2 ]")
line()
cp(D, "no typing after start. watch the clone.")
line()

local pkg = ask("package")
if not pkg or pkg=="" then cp(R,"cancelled.") return end
local linkB = ask("server B link (where to hop to)")
if not linkB or linkB=="" then cp(R,"cancelled.") return end
local linkA = ask("server A link (start here)")
if not linkA or linkA=="" then cp(R,"cancelled.") return end
local lw = tonumber(ask("load wait sec (def 40)")) or 40

line()
cp(P, "START IN 5s - watch clone")
line()
countdown(5, "starting")

-- join server A fresh
cp(D, "[1] open roblox")
su("am start --user 0 -n "..pkg
    .."/com.roblox.client.startup.ActivitySplash")
sleep(6)
cp(D, "[2] send link A")
send_url(linkA, pkg)
countdown(lw, "loading A")
cp(G, ">>> should be in A <<<")
sleep(2)

-- first send of B (we expect lobby bounce)
cp(R, "[3] send B (1st)")
send_url(linkB, pkg)
countdown(10, "after 1st send")
cp(D, "(likely at lobby now)")

-- second send of B from lobby
cp(R, "[4] send B (2nd)")
send_url(linkB, pkg)
countdown(35, "after 2nd send")

line()
cp(P, "DONE - what happened?")
line()
cp(D, "did the 2nd send JOIN a server?")
cp(G, "  joined = blitz needs 2 sends, no kill")
cp(D, "still stuck at lobby?")
cp(R, "  = blitz needs force-stop each hop")
line()
cp(D, "tell saturnity:")
cp(D, "1 = joined after 1st send")
cp(D, "2 = joined after 2nd send")
cp(D, "L = stuck at lobby")
line()
