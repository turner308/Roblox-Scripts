--locals
local sleep = task.wait
local spawn = task.spawn
local Camera = workspace.CurrentCamera
local VirtualInputManager = game:GetService('VirtualInputManager')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local lastPlayerTeleportCFrame
local ItemData = require(ReplicatedStorage.Modules.ItemData)
local ESPCache = {}
--Functions
local function retrieveFromGC(data)
    local in_table = data.in_table
    local name = data.name
    local all_in_script = data.all_in_script
    local script = data.script
    if script and name then
        for _, v in next, getgc() do
            if type(v) == 'function' and getfenv(v).script.Name == script and getinfo(v).name == name then
                return v
            end
        end
    end
    if name then
        for _, v in next, getgc() do
            if type(v) == 'function' and getinfo(v).name == name then
                return v
            end
        end
    end
    if all_in_script then
        local collected = {}
        for _, v in next, getgc() do
            if type(v) == 'function' and getfenv(v).script and getfenv(v).script.Name == all_in_script then
                collected[getinfo(v).name] = v
            end
        end
        return collected
    end
    if in_table then
        for _, v in next, getgc(true) do
            if type(v) == 'table' and rawget(v, name) then
                return v
            end
        end
    end
end
local function playerAlive(player)
    player = player or LocalPlayer
    local Player = Players:FindFirstChild(tostring(player))
    if Player then
        local Character = Player.Character
        if Character then
            local Humanoid = Character:FindFirstChild('Humanoid')
            local HumanoidRootPart = Character:FindFirstChild('HumanoidRootPart')
            return HumanoidRootPart and Humanoid and Humanoid.Health > 0
        end
    end
end
local function getSorted(tbl, sortFunction)
    if sortFunction then
        table.sort(tbl, sortFunction)
    else
        table.sort(tbl)
    end
    return tbl
end
local function getPlayerNames(includeLocalPlayer, sorted)
    local players = {}
    for _, player in next, Players:GetPlayers() do
        if player.Name ~= LocalPlayer.Name or includeLocalPlayer then
            players[#players + 1] = player.Name
        end
    end
    if sorted then
        table.sort(players)
    end
    return players
end
local function getFoods()
    local foods = {}
    local haveFoods = {}
    for i, v in next, ItemData do
        if v.itemType == 'food' then
            foods[i] = v
        end
    end
    for _, v in next, getrenv()._G.Data.inventory do
        for i, v in next, v do
            if foods[v] and not v:find('Raw') then
                haveFoods[#haveFoods + 1] = v
            end
        end
    end
    return haveFoods
end
local function getIsAInstances(instance, IsA, recurse)
    local result = {}
    for _, v in next, recurse and instance:GetDescendants() or instance:GetChildren() do
        if v:IsA(IsA) then
            result[#result + 1] = v
        end
    end
    return result
end
function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end
local function Draw(object, properties)
    local newObject = Drawing.new(object)
    for i, v in next, properties do
        newObject[i] = v
    end
    return newObject
end
local function AddESP(player)
    ESPCache[player.Name] = {
        Box = Draw('Square', {
            Thickness = 1,
            Filled = false
        }),
        Name = Draw('Text', {
            Font = 1,
            Transparency = 1,
            Size = 10,
            Center = true
        }),
        SetAllVisible = function(self, visible)
            self.Box.Visible = visible
            self.Name.Visible = visible
        end,
        Destroy = function(self)
            self.Box:Remove()
            self.Name:Remove()
        end
    }
end
for _, player in next, Players:GetPlayers() do
    if player ~= LocalPlayer then
        AddESP(player)
    end
end
Players.PlayerAdded:Connect(AddESP)
Players.PlayerRemoving:Connect(function(player)
    if ESPCache[player.Name] then
        ESPCache[player.Name]:Destroy()
        ESPCache[player.Name] = nil
    end
end)
--swing tool
local SwingTool = retrieveFromGC({
    script = 'Local_Handler',
    name = 'SwingTool'
})
--grab items
local items = {}
for i, _ in next, ItemData do
    items[#items + 1] = i
end
items = getSorted(items)
--anti afk
for _, v in next, getconnections(LocalPlayer.Idled) do
    v:Disable()
end
-- GUI
local Library, ThemeManager, SaveManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/BimbusCoder/Roblox-Scripts/master/User%20Interfaces/LinoriaRewrite'))()
local Window = Library:CreateWindow({Title = 'aturner scripts | ' .. game:GetService('MarketplaceService'):GetProductInfo(game.PlaceId).Name, Center = true, AutoShow = true})
local Main = Window:AddTab('Main')
local General = Main:AddLeftGroupbox('Players')
local playerDropdown = General:AddDropdown('Player Selection', {Text = 'Player Selection', Values = getPlayerNames(false, true), Default = 1, Multi = false, Tooltip = 'Select target player.'})
Players.PlayerAdded:Connect(function()
    playerDropdown.Values = getPlayerNames(false, true)
    playerDropdown:SetValues()
end)
Players.PlayerRemoving:Connect(function()
    playerDropdown.Values = getPlayerNames(false, true)
    playerDropdown:SetValues()
end)
General:AddToggle('Farm Player', {Text = 'Attack Player', Default = false, Tooltip = 'Loop teleports selected player.'}):OnChanged(function()
    if not Toggles['Farm Player'].Value and playerAlive() and lastPlayerTeleportCFrame then
        LocalPlayer.Character.HumanoidRootPart.CFrame = lastPlayerTeleportCFrame
    end
end)
General:AddSlider('Distance', {Text = 'Distance', Default = 10, Min = 5, Max = 15, Rounding = 0.1, Compact = false})
General:AddButton('Teleport To Player', function()
    if playerAlive() and playerAlive(Options['Player Selection'].Value) then
        LocalPlayer.Character.HumanoidRootPart.CFrame = Players[Options['Player Selection'].Value].Character.HumanoidRootPart.CFrame
    end
end)
General:AddToggle('Spectate Player', {Text = 'Spectate Player', Default = false, Tooltip = 'Spectates selected player.'}):OnChanged(function()
    if not Toggles['Spectate Player'].Value and playerAlive() then
        Camera.CameraSubject = LocalPlayer.Character
    end
end)
local Player = Main:AddRightGroupbox('Local Player')
Player:AddToggle('Pickup Aura', {Text = 'Pickup Aura', Default = false, Tooltip = 'Automatically picks up items around you.'})
Player:AddDivider()
Player:AddToggle('Auto Eat', {Text = 'Auto Eat', Default = false, Tooltip = 'Automatically eats food you.'})
Player:AddToggle('Ignore Bloodfruit', {Text = 'Ignore Bloodfruit', Default = false, Tooltip = 'Ignored Bloodfruits if auto eating.'})
Player:AddSlider('Eat When Below', {Text = 'Eat When Hunger Below', Default = 50, Min = 10, Max = 90, Rounding = 0.1, Compact = false})
Player:AddDivider()
Player:AddToggle('Auto Spawn', {Text = 'Auto Spawn', Default = false, Tooltip = 'Automatically respawns you.'})
Player:AddToggle('Auto Swing', {Text = 'Auto Swing', Default = false, Tooltip = 'Automatically swings current tool.'})
Player:AddToggle('Auto Equip', {Text = 'Auto Equip', Default = false, Tooltip = 'Automatically equips an item from hotbar.'})
Player:AddDropdown('Slot Selection', {Text = 'Slot Selection', Values = {'One', 'Two', 'Three', 'Four', 'Five', 'Six'}, Default = 1, Multi = false, Tooltip = 'Selects the slot to equip from.'})
Player:AddDivider()
Player:AddLabel('Aura Requires Tool')
Player:AddToggle('Player Damage', {Text = 'Player Damage Aura', Default = false, Tooltip = 'Activates player damage aura.'})
Player:AddToggle('Animal Damage', {Text = 'Animal Damage Aura', Default = false, Tooltip = 'Activates animal damage aura.'})
Player:AddToggle('Resource Damage', {Text = 'Resource Damage Aura', Default = false, Tooltip = 'Activates resource damage aura.'})
local Farming = Main:AddRightGroupbox('Farming')
Farming:AddDropdown('Resource Selection', {Text = 'Resource Selection', Values = (function()
    local drops = {}
    for i, v in next, ItemData do
        if v.drops then
            drops[#drops + 1] = i
        end
    end
    table.sort(drops)
    return drops
end)(), Default = 1, Multi = false, Tooltip = 'Selects the resource to farm.'})
Farming:AddToggle('Collect Resource', {Text = 'Farm Resource', Default = false, Tooltip = 'Automatically collects selected resources.'})
Farming:AddSlider('Collect Resource Distance', {Text = 'Distance', Default = 2, Min = -15, Max = 15, Rounding = 0.1, Compact = false})
local Crafting = Main:AddLeftGroupbox('Crafting')
Crafting:AddInput('Selected Craft Item Text', {Text = 'Item Name', Numeric = false, Finished = false, Tooltip = 'Select item to craft.'}):OnChanged(function()
    for _, v in next, items do
        if v:lower() == Options['Selected Craft Item Text'].Value:lower() then
            Options['Selected Craft Item Text'].Value = v
            print(Options['Selected Craft Item Text'].Value, ' is the item you selected.')
        end
    end
end)
Crafting:AddButton('Craft Item', function() ReplicatedStorage.Events.CraftItem:FireServer(Options['Selected Craft Item Text'].Value) end)
Crafting:AddDivider()
Crafting:AddDropdown('Selected Craft Item', {Text = 'Select Item to Craft', Values = items, Default = 1, Multi = false, Tooltip = 'Select item to craft.'})
Crafting:AddButton('Craft Item', function() ReplicatedStorage.Events.CraftItem:FireServer(Options['Selected Craft Item'].Value) end)
local ESP = Main:AddLeftGroupbox('ESP')
ESP:AddToggle('Box ESP', {Text = 'Box', Default = false, Tooltip = 'Activates box ESP.'})
ESP:AddToggle('Name ESP', {Text = 'Name', Default = false, Tooltip = 'Activates name ESP.'})
ESP:AddToggle('Health ESP', {Text = 'Health', Default = false, Tooltip = 'Activates health ESP.'})
ESP:AddToggle('Armor ESP', {Text = 'Armor', Default = false, Tooltip = 'Activates armor ESP.'})
ESP:AddLabel('ESP Color'):AddColorPicker('ESP Color', {Default = Color3.new(1, 1, 1), Title = 'ESP Color Picker'})
-- UI Settings
local SettingsTab = Window:AddTab('Settings')
Library:OnUnload(function()
    Library.Unloaded = true
end)
local MenuGroup = SettingsTab:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {Default = 'End', NoUI = true, Text = 'Menu keybind'})
Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:SetIgnoreIndexes({'MenuKeybind'})
ThemeManager:SetFolder('aturner scripts')
SaveManager:SetFolder('aturner scripts/' .. game.PlaceId)
SaveManager:BuildConfigSection(SettingsTab)
ThemeManager:ApplyToTab(SettingsTab)
-- Loops
game:GetService('RunService').RenderStepped:Connect(function()
    for player, esp in next, ESPCache do
        local Player = Players:FindFirstChild(player)
        if Player and playerAlive() then
            local Character = Player.Character
            if Character then
                local Humanoid = Character:FindFirstChild('Humanoid')
                local HumanoidRootPart = Character:FindFirstChild('HumanoidRootPart')
                local Head = Character:FindFirstChild('Head')
                if Head and HumanoidRootPart and Humanoid and Humanoid.Health > 0 then
                    local Box = esp.Box
                    local Name = esp.Name
                    if Toggles['Box ESP'].Value then
                        local Position, Visible = Camera:WorldToViewportPoint(HumanoidRootPart.Position)
                        if Visible then
                            Box.Position = Vector2.new(Position.X - 10, Position.Y - 10)
                            Box.Size = Vector2.new(HumanoidRootPart.Size.X + 20, HumanoidRootPart.Size.Y + 30)
                            Box.Color = Options['ESP Color'].Value
                            Box.Filled = false
                            Box.Visible = true
                        else
                            Box.Visible = false
                        end
                    else
                        Box.Visible = false
                    end
                    if Toggles['Name ESP'].Value then
                        local Position, Visible = Camera:WorldToViewportPoint(Head.Position)
                        if Visible then
                            local health = Toggles['Health ESP'].Value and string.format(' [Health: %s]', round(Humanoid.Health, 2)) or ''
                            local hasArmor = Character:FindFirstChild('legs', true) or Character:FindFirstChild('torso', true) or Character:FindFirstChild('head', true)
                            local armor = Toggles['Armor ESP'].Value and hasArmor and string.format(' [Armor: %s]', hasArmor.Parent.Name:split(' ')[1]) or ''
                            Name.Text = '[' .. player .. ']' .. health .. armor
                            Name.Position = Vector2.new(Position.X, Position.Y - 30)
                            Name.Color = Options['ESP Color'].Value
                            Name.Size = 17
                            Name.Visible = true
                        else
                            Name.Visible = false
                        end
                    else
                        Name.Visible = false
                    end
                else
                    esp:SetAllVisible(false)
                end
            else
                esp:SetAllVisible(false)
            end
        else
            esp:SetAllVisible(false)
        end
    end
end)
spawn(function()
    while true do
        if Toggles['Player Damage'].Value and playerAlive() then
            for _, v in next, Players:GetPlayers() do
                if v ~= LocalPlayer then
                    local Character = v.Character
                    if Character then
                        local HumanoidRootPart = Character:FindFirstChild('HumanoidRootPart')
                        if HumanoidRootPart then
                            local Distance = LocalPlayer:DistanceFromCharacter(HumanoidRootPart.Position)
                            if Distance <= 10 then
                                ReplicatedStorage.Events.SwingTool:FireServer(ReplicatedStorage.RelativeTime.Value, getIsAInstances(Character, 'BasePart'))
                            end
                        end
                    end
                end
            end
        end
        if Toggles['Resource Damage'].Value and playerAlive() then
            for _, v in next, workspace.Resources:GetChildren() do
                local part = v:FindFirstChildWhichIsA('BasePart')
                if part then
                    local Distance = LocalPlayer:DistanceFromCharacter(part.Position)
                    if Distance <= 20 then
                        ReplicatedStorage.Events.SwingTool:FireServer(ReplicatedStorage.RelativeTime.Value, getIsAInstances(v, 'BasePart'))
                    end
                end
            end
        end
        if Toggles['Animal Damage'].Value and playerAlive() then
            for _, v in next, workspace.Critters:GetChildren() do
                local part = v:FindFirstChildWhichIsA('BasePart')
                if part then
                    local Distance = LocalPlayer:DistanceFromCharacter(part.Position)
                    if Distance <= 10 then
                        ReplicatedStorage.Events.SwingTool:FireServer(ReplicatedStorage.RelativeTime.Value, getIsAInstances(v, 'BasePart'))
                    end
                end
            end
            for _, v in next, workspace:GetChildren() do
                local torso = v:FindFirstChild('Torso')
                if torso then
                    local Distance = LocalPlayer:DistanceFromCharacter(torso.Position)
                    if Distance <= 10 then
                        ReplicatedStorage.Events.SwingTool:FireServer(ReplicatedStorage.RelativeTime.Value, getIsAInstances(v, 'BasePart'))
                    end
                end
            end
        end
        sleep(0.5)
    end
end)
spawn(function()
    while true do
        if Toggles['Auto Eat'].Value and playerAlive() and getrenv()._G.Data.stats.food < Options['Eat When Below'].Value then
            local foods = getFoods()
            if #foods > 0 then
                if Toggles['Ignore Bloodfruit'].Value then
                    table.remove(foods, table.find(foods, 'Bloodfruit'))
                end
                ReplicatedStorage.Events.UseBagItem:FireServer(foods[1])
            end
        end
        sleep(0.5)
    end
end)
spawn(function()
    while true do
        if Toggles['Spectate Player'].Value and playerAlive(Options['Player Selection'].Value) then
            Camera.CameraSubject = Players[Options['Player Selection'].Value].Character
        elseif playerAlive() then
            Camera.CameraSubject = LocalPlayer.Character
        end
        sleep()
    end
end)
spawn(function()
    while true do
        if Toggles['Collect Resource'].Value and playerAlive() then
            local resource
            for _, v in next, workspace.Resources:GetChildren() do
                if v.Name == Options['Resource Selection'].Value then
                    resource = v
                    break
                end
            end
            if resource then
                local part = resource:FindFirstChildWhichIsA('BasePart')
                if part then
                    repeat
                        LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame * CFrame.new(0, 0, Options['Collect Resource Distance'].Value)
                        ReplicatedStorage.Events.SwingTool:FireServer(ReplicatedStorage.RelativeTime.Value, resource:GetChildren())
                        VirtualInputManager:SendKeyEvent(true, Options['Slot Selection'].Value, false, nil)
                        sleep()
                    until not Toggles['Collect Resource'].Value or not playerAlive() or not resource:IsDescendantOf(workspace) or Options['Resource Selection'].Value ~= resource.Name
                    sleep(0.5)
                    if playerAlive() then
                        for _, v in next, workspace.Items:GetChildren() do
                            local BasePart = v:FindFirstChildWhichIsA('BasePart')
                            if BasePart then
                                spawn(function()
                                    if LocalPlayer:DistanceFromCharacter(BasePart.Position) <= 30 then
                                        ReplicatedStorage.Events.PickupItem:InvokeServer(v)
                                    end
                                end)
                            end
                        end
                    end
                    sleep(0.5)
                end
            end
        end
        if Toggles['Farm Player'].Value and playerAlive() and playerAlive(Options['Player Selection'].Value) then
            repeat
                if playerAlive() then
                    local Character = Players[Options['Player Selection'].Value].Character
                    local teleportCFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, -Options['Distance'].Value, 0) * CFrame.Angles(math.rad(90), 0, 0)
                    lastPlayerTeleportCFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                    LocalPlayer.Character.HumanoidRootPart.CFrame = teleportCFrame
                    ReplicatedStorage.Events.SwingTool:FireServer(ReplicatedStorage.RelativeTime.Value, getIsAInstances(Character, 'BasePart'))
                end
                sleep()
            until not Toggles['Farm Player'].Value or not playerAlive() or not playerAlive(Options['Player Selection'].Value)
            if playerAlive() then
                LocalPlayer.Character.HumanoidRootPart.CFrame = lastPlayerTeleportCFrame
                sleep(1)
                if Toggles['Pickup Aura'].Value then
                    for _, v in next, workspace.Items:GetChildren() do
                        local BasePart = v:FindFirstChildWhichIsA('BasePart')
                        if BasePart then
                            if LocalPlayer:DistanceFromCharacter(BasePart.Position) <= 30 then
                                ReplicatedStorage.Events.PickupItem:InvokeServer(v)
                            end
                        end
                    end
                end
                sleep(1)
            end
        end
        sleep()
    end
end)
spawn(function()
    while true do
        if Toggles['Pickup Aura'].Value then
            for _, v in next, workspace.Items:GetChildren() do
                local BasePart = v:FindFirstChildWhichIsA('BasePart')
                if BasePart then
                    spawn(function()
                        if LocalPlayer:DistanceFromCharacter(BasePart.Position) <= 30 then
                            ReplicatedStorage.Events.PickupItem:InvokeServer(v)
                        end
                    end)
                end
            end
        end
        sleep()
    end
end)
spawn(function()
    while true do
        if Toggles['Auto Spawn'].Value and PlayerGui.SpawnGui.Enabled then
            firesignal(PlayerGui.SpawnGui.PlayButton.Activated)
            sleep(2)
        end
        if Toggles['Auto Equip'].Value and playerAlive() and not LocalPlayer.Character:FindFirstChild('ToolWeld', true) then
            VirtualInputManager:SendKeyEvent(true, Options['Slot Selection'].Value, false, nil)
            sleep(3)
        end
        if Toggles['Auto Swing'].Value and playerAlive() and LocalPlayer.Character:FindFirstChild('ToolWeld', true) then
            SwingTool()
        end
        sleep()
    end
end)
