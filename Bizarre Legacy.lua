repeat wait() until game:IsLoaded()
 
pcall(function()
    
    local plr = game:GetService("Players").LocalPlayer
 
    game:GetService("ReplicatedStorage").Events:FindFirstChild("YieldFunction"):Destroy()
    wait(.8)
    game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("ClientMain"):Destroy()
    print("Bypass Ran! 2/2")
 
    spawn(function()
        plr.CharacterAdded:Connect(function()
            pcall(function()
                print("Bypassed! 2/2")
                game:GetService("ReplicatedStorage").Events:FindFirstChild("YieldFunction"):Destroy()
                wait(.5)
                game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("ClientMain"):Destroy()
            end)
        end)
    end)
 
    spawn(function()
        plr.CharacterAdded:Connect(function()
            pcall(function()
                game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("ClientMain"):Destroy()
                print("Bypassed! 1/2")
            end)
        end)
    end)
 
end)
--
local plr = game:GetService("Players").LocalPlayer
--
local Material = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))()
--
local UI = Material.Load({
     Title = "Bizarre Legacy",
     Style = 3,
     SizeX = 200,
     SizeY = 80,
     Theme = "Mocha"
})
--
game:GetService("CoreGui")["Bizarre Legacy"].MainFrame:TweenPosition(
    UDim2.new(0, 10, 0.450, 0),
    "Out",
    "Sine",
    .8
)
--
local Page = UI.New({
    Title = "Main"
})
--
local Tog1 = Page.Toggle({
    Text = "Item Farm",
    Callback = function(Bool)
        getgenv().ItemFarm = Bool
 
            while getgenv().ItemFarm do wait()
 
                pcall(function()
                    
                    plr.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                    plr.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
 
                    for i,v in pairs(workspace:GetDescendants()) do
                        if v:FindFirstChild("ClickDetector") and v.Parent.Name == "" then
                            plr.Character.HumanoidRootPart.CFrame = v.CFrame
                            fireclickdetector(v.ClickDetector)
                        end
                    end
 
                    wait(.75)
 
                end)
 
            end
 
        end,
Enabled = getgenv().AutoEnable
})
--
