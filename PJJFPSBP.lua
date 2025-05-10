if game.PlaceId ~= 2295122555 then return end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local KickHook
KickHook = hookmetamethod(game, "__namecall", function(self, ...)
    local namecallmethod = getnamecallmethod()

    if namecallmethod:lower() == "kick" then
        return
    end

    return KickHook(self, ...)
end)

local function SafeDestroy(Parent, Name, Duration)
    Duration = Duration or math.huge

    coroutine.wrap(function()
        local Object = Parent:WaitForChild(Name, Duration)
        if Object then Object:Destroy() end
    end)()
end

SafeDestroy(LocalPlayer.PlayerGui, "fpsKickWarning")
SafeDestroy(LocalPlayer.PlayerScripts, "fpsScript")
SafeDestroy(LocalPlayer.PlayerScripts, "FakeWeld")
