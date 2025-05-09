local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

coroutine.wrap(function()
    LocalPlayer.PlayerGui:WaitForChild("fpsKickWarning", math.huge):Destroy()
    LocalPlayer.PlayerScripts:WaitForChild("fpsScript", math.huge):Destroy()
    LocalPlayer.PlayerScripts:WaitForChild("FakeWeld", math.huge):Destroy()
end)()

local KickHook
KickHook = hookmetamethod(game, "__namecall", function(self, ...)
    local namecallmethod = getnamecallmethod()

    if namecallmethod:lower() == "kick" then
        return
    end

    return KickHook(self, ...)
end)

local Script = game:HttpGet("https://raw.githubusercontent.com/turner308/Roblox-Scripts/refs/heads/master/PJJFPSBP.lua")
queue_on_teleport(Script)
