-- ============================================
-- SATURNITY HOP TEST  (Android / Termux)
-- tests joining a private server by its full
-- privateServerLinkCode URL, and whether an
-- in-game URL teleports WITHOUT force-stop.
-- by @lanavienrose
-- ============================================

local C = "\27[93m"   -- bright yellow (states)
local P = "\27[1;96m" -- bold bright cyan (headers)
local G = "\27[1;92m" -- bold bright green (ok)
local R = "\27[1;91m" -- bold bright red (fail)
local D = "\27[97m"   -- bright white (info)
local X = "\27[0m"

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
    if sucmd("pidof "..pkg) ~= "" then return "UNKNOWN" end
    return "DEAD"
end

local function send_url(url, pkg)
    su("am start --user 0 -a android.intent.action.VIEW"
        .." -d \""..url.."\" -p "..pkg)
end

os.execute("clear")
line()
out("  "..P.."[ SATURNITY HOP TEST ]"..X)
line()
out(D.."  goal: join private server by its full")
out("  link url, then test if an in-game url")
out("  teleports WITHOUT force-stop."..X)
out("")
line()

local pkg = ask("roblox package (e.g. com.roblox.clienv)")
if not pkg or pkg=="" then out(R.."  cancelled."..X); return end

out("")
out(D.."  paste the FULL private server links")
out("  (the whole https://... url from winterhub)"..X)
out("")
local linkA = ask("server A full link")
if not linkA or linkA=="" then out(R.."  cancelled."..X); return end
local linkB = ask("server B full link (DIFFERENT server)")
if not linkB or linkB=="" then out(R.."  cancelled."..X); return end

out("")
line()
out("  "..P.."PHASE 1"..X.."  open + join server A")
line()

out(D.."  opening roblox..."..X)
su("am start --user 0 -n "..pkg
    .."/com.roblox.client.startup.ActivitySplash")
sleep(6)

out(D.."  sending server A link (with -p, no chooser)..."..X)
send_url(linkA, pkg)

out(D.."  waiting for arrival in server A..."..X)
local arrived, last = false, ""
for i=1,70 do
    local a = get_act(pkg)
    if a ~= last then
        out("    "..string.format("%02d",i).."s  "..C..a..X); last = a
    end
    if a == "INGAME" then
        arrived = true
        out("  "..G.."ARRIVED in server A at "..i.."s"..X); break
    end
    sleep(1)
end

if not arrived then
    out("")
    out(R.."  never reached INGAME for server A.")
    out("  the link url itself did not join."..X)
    out(D.."  if you saw an 'Open with' popup, -p")
    out("  is being ignored by the clone."..X)
    return
end

out(D.."  holding 8s to confirm stable..."..X)
sleep(8)
out("  state before teleport:  "..C..get_act(pkg)..X)

out("")
line()
out("  "..P.."PHASE 2"..X.."  send server B link (NO force-stop)")
line()
out(D.."  sending server B link while in server A..."..X)
send_url(linkB, pkg)

out(D.."  watching reaction for 45s..."..X)
local saw_loading, lst = false, "INGAME"
for i=1,45 do
    local a = get_act(pkg)
    if a ~= lst then
        out("    "..string.format("%02d",i).."s  "..C..a..X); lst = a
        if a == "LOADING" then saw_loading = true end
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
    out("  "..G.."TELEPORT WORKS, NO FORCE-STOP!"..X)
    out(D.."  it reloaded and is in-game again =")
    out("  teleported to B. fast blitz possible."..X)
elseif lst == "INGAME" and not saw_loading then
    out("  "..C.."UNCLEAR"..X)
    out(D.."  still in-game, no reload seen. might")
    out("  still be server A. check the screen."..X)
elseif lst == "MENU" then
    out("  "..R.."KICKED TO LOBBY"..X)
    out(D.."  in-game url dumped it to menu.")
    out("  blitz needs force-stop between hops."..X)
else
    out("  "..R.."NO CLEAN TELEPORT  ("..lst..")"..X)
    out(D.."  check the screen to see where it is."..X)
end
out("")
line()
out(D.."  IMPORTANT: look at the actual roblox")
out("  screen now. tell me: server B, server A,")
out("  or the lobby?"..X)
line()
