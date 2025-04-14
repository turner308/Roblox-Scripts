local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local LogService = game:GetService("LogService")

--Anti AFK
for _, v in next, getconnections(LocalPlayer.Idled) do
    v:Disable()
end
--

--Disable Print LogService Detection
for _, v in next, getconnections(LogService.MessageOut) do
    v:Disable()
end
--

local KeyMap = {
    ["RightControl"] = {
        ["KeypadOne"] = function()
            --Hydroxide
            getgenv().getConstants = function() return {} end
            getgenv().getProtos = function() return {} end
            loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Upbolt/Hydroxide/revision/init.lua"))()
            loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Upbolt/Hydroxide/revision/ui/main.lua"))()
        end,
        ["KeypadTwo"] = function()
            --IY
            loadstring(game:HttpGet("https://raw.githubusercontent.com/edgeiy/infiniteyield/master/source"))()
        end,
        ["KeypadThree"] = function()
            --Frosthook
            loadstring(game:HttpGet("https://raw.githubusercontent.com/turner308/Roblox-Scripts/refs/heads/master/Frosthook.lua"))()
        end
    }
}

UserInputService.InputBegan:Connect(function(InputObject, GPE)
    if GPE then return end

    for keyHold, keyBinds in next, KeyMap do
        if keyHold == "" or keyHold:lower() == "none" or UserInputService:IsKeyDown(keyHold) then
            for keyBind, Func in next, keyBinds do
                if InputObject.KeyCode.Name == keyBind then
                    Func()
                end
            end
        end
    end
end)
