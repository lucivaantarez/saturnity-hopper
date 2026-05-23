-- ============================================
-- SATURNITY HOP TEST  (Android / Termux)
-- time-based + eye-confirmed. no activity
-- detection (roblox hides it on this build).
-- by @lanavienrose
-- ============================================

local C = "\27[93m"
local P = "\27[1;96m"
local G = "\27[1;92m"
local R = "\27[1;91m"
local D = "\27[97m"
local X = "\27[0m"

local function line() io.write(string.rep("-",40).."\n") end
local function out(s) io.write(s.."\n"); io.flush() end
local function su(cmd)
    os.execute("su -c '"..cmd:gsub("'","'\\''").."' >/dev/null 2>&1")
end
local function ask(q)
    io.write("\27[93m  "..q.."\27[0m\n\27[1;96m  > \27[0m"); io.flush()
    return io.read("*l")
end
local function pause(q)
    io.write("\27[1;92m  "..q.."\27[0m"); io.flush()
    io.read("*l")
end
local function sleep(n) os.execute("sleep "..n) end

local function send_url(url, pkg)
    su("am start --user 0 -a android.intent.action.VIEW"
        .." -d \""..url.."\" -p "..pkg)
end
local function countdown(secs, label)
    for i=secs,1,-1 do
        io.write("\r\27[97m  "..label.." "..i.."s   \27[0m")
        io.flush(); sleep(1)
    end
    io.write("\r"..string.rep(" ",38).."\r"); io.flush()
end

os.execute("clear")
line()
out("  "..P.."[ SATURNITY HOP TEST ]"..X)
line()
out(D.."  join server A, then send server B")
out("  while in-game (no force-stop) and")
out("  see if it teleports."..X)
line()

local pkg = ask("package (e.g. com.roblox.clienv)")
if not pkg or pkg=="" then out(R.."  cancelled."..X) return end
local linkA = ask("server A full link")
if not linkA or linkA=="" then out(R.."  cancelled."..X) return end
local linkB = ask("server B link (different)")
if not linkB or linkB=="" then out(R.."  cancelled."..X) return end

out("")
line()
out("  "..P.."PHASE 1  join server A"..X)
line()
out(D.."  opening roblox..."..X)
su("am start --user 0 -n "..pkg
    .."/com.roblox.client.startup.ActivitySplash")
countdown(8, "loading roblox")
out(D.."  sending server A link..."..X)
send_url(linkA, pkg)
out("")
pause("when you SEE server A loaded, press ENTER")

out("")
line()
out("  "..P.."PHASE 2  send B (no force-stop)"..X)
line()
out(D.."  sending server B link now..."..X)
send_url(linkB, pkg)
countdown(30, "watching")
out("")
out(D.."  look at the roblox screen now."..X)
out("")
local a = ask("where are you?  b / a / l / c")
out("")
line()
out("  "..P.."RESULT"..X)
line()
if a == "b" then
    out("  "..G.."TELEPORT WORKS, NO FORCE-STOP!"..X)
    out(D.."  in-game link teleports straight to")
    out("  the next server. fast blitz possible."..X)
elseif a == "a" then
    out("  "..R.."NO TELEPORT"..X)
    out(D.."  in-game link was ignored, stayed in")
    out("  server A. blitz needs force-stop."..X)
elseif a == "l" then
    out("  "..R.."KICKED TO LOBBY"..X)
    out(D.."  link dumped it to menu instead of")
    out("  teleporting. blitz needs force-stop."..X)
elseif a == "c" then
    out("  "..R.."CHOOSER APPEARED"..X)
    out(D.."  -p was ignored. need another way to")
    out("  target the clone."..X)
else
    out("  "..C.."unknown answer: "..tostring(a)..X)
    out(D.."  tell me what you saw on screen."..X)
end
line()
out(D.."  reminder:")
out("    b = in server B (different world)")
out("    a = still server A")
out("    l = lobby / menu / play screen")
out("    c = 'open with' popup"..X)
line()
