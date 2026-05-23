-- ============================================
-- SATURNITY TELEPORT TEST  (Delta autoexec)
-- proves in-game -> in-game private server
-- teleport works via the executor.
-- by @lanavienrose
-- ============================================
--
-- HOW TO USE:
--   1. edit the 2 lines below (PLACE_ID + CODE_B)
--   2. put this file in:
--        /storage/emulated/0/Delta/Autoexecute/
--   3. open the clone, join ANY server of that
--      game (public is fine)
--   4. inject / execute Delta
--   5. watch the on-screen notifications
--   6. from termux read the result:
--        cat /storage/emulated/0/Delta/Workspace/saturnity_tp_result.txt
--
-- ============================================
-- EDIT THESE TWO LINES:
local PLACE_ID = 920587237        -- game place id
local CODE_B   = "https://www.roblox.com/games/920587237/Adopt-Me?privateServerLinkCode=61325242737220554678171376101779"  -- a private server linkCode to teleport to
-- ============================================

local TS      = game:GetService("TeleportService")
local Players = game:GetService("Players")
local SG      = game:GetService("StarterGui")

local function notify(msg)
    pcall(function()
        SG:SetCore("SendNotification", {
            Title = "SATURNITY",
            Text  = msg,
            Duration = 12,
        })
    end)
    pcall(function() writefile("saturnity_tp_result.txt", msg) end)
    print("[SATURNITY] " .. msg)
end

-- wait until fully loaded into a game
repeat task.wait(0.5) until game:IsLoaded()
repeat task.wait(0.5) until Players.LocalPlayer
task.wait(3)

-- read which step we are on (persists across teleport)
local step = 0
pcall(function()
    if isfile and isfile("saturnity_tp_step.txt") then
        step = tonumber(readfile("saturnity_tp_step.txt")) or 0
    end
end)

local here = tostring(game.PlaceId)

if step == 0 then
    -- first server: try to teleport to server B
    notify("STEP 1: in game (place " .. here ..
        "). teleporting to server B in 8s...")
    pcall(function() writefile("saturnity_tp_step.txt", "1") end)
    task.wait(8)

    local ok, err = pcall(function()
        TS:TeleportToPrivateServer(PLACE_ID, CODE_B,
            { Players.LocalPlayer })
    end)

    if not ok then
        notify("TELEPORT CALL FAILED: " .. tostring(err))
        pcall(function() writefile("saturnity_tp_step.txt", "0") end)
    else
        notify("teleport call sent, leaving...")
    end

elseif step == 1 then
    -- we arrived somewhere after the teleport call = it worked
    notify("SUCCESS: arrived via in-game teleport! place=" .. here ..
        " -- blitz mode is possible.")
    pcall(function() writefile("saturnity_tp_step.txt", "done") end)

else
    notify("test already done. delete saturnity_tp_step.txt to rerun.")
end

