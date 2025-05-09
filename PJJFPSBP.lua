if game.PlaceId ~= 2295122555 then return end

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
