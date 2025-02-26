local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Afonso Scripts",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Example Hub",
   LoadingSubtitle = "by Afonso",
   Theme = "Dark Blue", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = true, -- Create a custom folder for your hub/game
      FileName = "ExampleHub"
   },

   Discord = {
      Enabled = true, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "https://discord.gg/mpTjs9EZ", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = true, -- Set this to true to use our key system
   KeySettings = {
      Title = "Afonso Scripts || keys",
      Subtitle = "Link in discord server",
      Note = "Join discord server from misc tab", -- Use this to tell the user how to get a key
      FileName = "ExampleHubKey", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"premiumkey1"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local MainTab = Window:CreateTab("🏠Home", nil) -- Title, Image
local MainSection = MainTab:CreateSection("Main")

Rayfield:Notify({
   Title = "Script executed!",
   Content = "Have fun!",
   Duration = 4,
   Image = nil,
})

local Button = MainTab:CreateButton({
   Name = "Role ESP",
   Callback = function()
-- Roblox Role-Based ESP Script
-- Shows players with customizable ESP features based on leaderboard roles
-- Different colored lines for Police, EMS, Prisoner, and Neutral roles

local ESPSettings = {
    Enabled = true,
    BoxesEnabled = true,
    BoxColor = Color3.fromRGB(255, 0, 0), -- Default red boxes
    LinesEnabled = true,
    TextEnabled = true,
    TextColor = Color3.fromRGB(255, 255, 255), -- White text
    TextSize = 14,
    MaxDistance = 1000, -- Maximum distance to render ESP
    FilterNonPlayerObjects = true, -- Prevents highlighting non-player objects
    FilterGUIElements = true, -- Prevents highlighting GUI elements
    
    -- Role-specific colors
    RoleColors = {
        ["Police"] = Color3.fromRGB(0, 0, 255),     -- Blue for Police
        ["EMS"] = Color3.fromRGB(255, 0, 0),        -- Red for EMS
        ["Prisoner"] = Color3.fromRGB(255, 165, 0), -- Orange for Prisoner
        ["Neutral"] = Color3.fromRGB(128, 128, 128) -- Gray for Neutral
    }
}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local ESPFolder
local SettingsGui

-- Create ESP container
local function CreateESPFolder()
    if CoreGui:FindFirstChild("ESPFolder") then
        CoreGui.ESPFolder:Destroy()
    end
    ESPFolder = Instance.new("Folder")
    ESPFolder.Name = "ESPFolder"
    ESPFolder.Parent = CoreGui
end

-- Utility function to create drawing objects
local function CreateDrawing(type, properties)
    local drawing = Drawing.new(type)
    for property, value in pairs(properties) do
        drawing[property] = value
    end
    return drawing
end

-- Function to get character parts
local function GetCharacterParts(character)
    if not character then return nil end
    
    local parts = {}
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            parts[#parts + 1] = part
        end
    end
    
    return parts
end

-- Validate if object is a valid player character
local function IsValidCharacter(object)
    if not object then return false end
    
    -- Verify it's a character model with required components
    if not object:IsA("Model") then return false end
    if not object:FindFirstChild("Humanoid") then return false end
    if not object:FindFirstChild("HumanoidRootPart") then return false end
    
    -- Check if it belongs to a player
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character == object then
            return true
        end
    end
    
    return false
end

-- Function to determine a player's role from the leaderboard
local function GetPlayerRole(player)
    -- Default role is Neutral
    local role = "Neutral"
    
    -- Look for role indicators in the player's leaderstats
    if player:FindFirstChild("leaderstats") then
        local leaderstats = player.leaderstats
        
        -- Check for various role indicators (might need adjustment for specific games)
        for _, child in pairs(leaderstats:GetChildren()) do
            local value = child.Value
            if typeof(value) == "string" then
                if value:find("Police") then
                    return "Police"
                elseif value:find("EMS") then
                    return "EMS"
                elseif value:find("Prisoner") then
                    return "Prisoner"
                end
            end
        end
    end
    
    -- Check for team-based roles
    if player.Team then
        local teamName = player.Team.Name
        if teamName:find("Police") then
            return "Police"
        elseif teamName:find("EMS") or teamName:find("Medic") or teamName:find("Doctor") then
            return "EMS"
        elseif teamName:find("Prisoner") or teamName:find("Criminal") or teamName:find("Inmate") then
            return "Prisoner"
        end
    end
    
    -- Check for specific team colors that might indicate roles
    if player.TeamColor then
        if player.TeamColor == BrickColor.new("Bright blue") then
            return "Police"
        elseif player.TeamColor == BrickColor.new("Really red") then
            return "EMS"
        elseif player.TeamColor == BrickColor.new("Bright orange") then
            return "Prisoner"
        end
    end
    
    return role
end

-- Calculate 3D bounding box corners
local function CalculateCorners(character)
    local parts = GetCharacterParts(character)
    if not parts or #parts == 0 then return nil end
    
    local minX, minY, minZ = math.huge, math.huge, math.huge
    local maxX, maxY, maxZ = -math.huge, -math.huge, -math.huge
    
    for _, part in pairs(parts) do
        local size = part.Size
        local cf = part.CFrame
        
        local corners = {
            cf * CFrame.new(size.X/2, size.Y/2, size.Z/2),
            cf * CFrame.new(-size.X/2, size.Y/2, size.Z/2),
            cf * CFrame.new(size.X/2, -size.Y/2, size.Z/2),
            cf * CFrame.new(-size.X/2, -size.Y/2, size.Z/2),
            cf * CFrame.new(size.X/2, size.Y/2, -size.Z/2),
            cf * CFrame.new(-size.X/2, size.Y/2, -size.Z/2),
            cf * CFrame.new(size.X/2, -size.Y/2, -size.Z/2),
            cf * CFrame.new(-size.X/2, -size.Y/2, -size.Z/2)
        }
        
        for _, corner in pairs(corners) do
            local position = corner.Position
            minX, minY, minZ = math.min(minX, position.X), math.min(minY, position.Y), math.min(minZ, position.Z)
            maxX, maxY, maxZ = math.max(maxX, position.X), math.max(maxY, position.Y), math.max(maxZ, position.Z)
        end
    end
    
    return {
        BottomCorner = Vector3.new(minX, minY, minZ),
        TopCorner = Vector3.new(maxX, maxY, maxZ)
    }
end

-- ESP class for each player
local ESP = {}
ESP.__index = ESP

function ESP.new(player)
    local self = setmetatable({}, ESP)
    
    self.Player = player
    self.Role = GetPlayerRole(player)
    
    -- Create ESP objects immediately
    self.BoxDrawing = CreateDrawing("Square", {
        Thickness = 2,
        Color = ESPSettings.BoxColor,
        Filled = false,
        Visible = false,
        ZIndex = 2
    })
    self.LineDrawing = CreateDrawing("Line", {
        Thickness = 1,
        Color = ESPSettings.RoleColors[self.Role],
        Visible = false,
        ZIndex = 1
    })
    self.TextDrawing = CreateDrawing("Text", {
        Text = "",
        Size = ESPSettings.TextSize,
        Center = true,
        Outline = true,
        Color = ESPSettings.TextColor,
        Visible = false,
        ZIndex = 3
    })
    
    -- Initialize character
    if player.Character then
        self.Character = player.Character
        -- Force an immediate update
        task.spawn(function()
            self:Update()
        end)
    end
    
    -- Handle character respawning with immediate update
    player.CharacterAdded:Connect(function(character)
        self.Character = character
        -- Force an immediate update when character loads
        task.spawn(function()
            self:Update()
        end)
    end)
    
    -- Update role when player data changes
    player.Changed:Connect(function()
        local newRole = GetPlayerRole(player)
        if self.Role ~= newRole then
            self.Role = newRole
            self.LineDrawing.Color = ESPSettings.RoleColors[self.Role]
        end
    end)
    
    -- Listen for team changes
    player:GetPropertyChangedSignal("Team"):Connect(function()
        local newRole = GetPlayerRole(player)
        if self.Role ~= newRole then
            self.Role = newRole
            self.LineDrawing.Color = ESPSettings.RoleColors[self.Role]
        end
    end)
    
    return self
end

function ESP:Update()
    if not ESPSettings.Enabled then
        self.BoxDrawing.Visible = false
        self.LineDrawing.Visible = false
        self.TextDrawing.Visible = false
        return
    end
    
    -- Extra validation to ensure we only highlight actual player characters
    if not self.Character or not self.Player or not self.Character:FindFirstChild("HumanoidRootPart") or not self.Character:FindFirstChild("Humanoid") then
        self.BoxDrawing.Visible = false
        self.LineDrawing.Visible = false
        self.TextDrawing.Visible = false
        return
    end
    
    -- Additional check to ensure the character is valid
    if ESPSettings.FilterNonPlayerObjects and not IsValidCharacter(self.Character) then
        self.BoxDrawing.Visible = false
        self.LineDrawing.Visible = false
        self.TextDrawing.Visible = false
        return
    end
    
    -- Get player data
    local humanoidRootPart = self.Character.HumanoidRootPart
    local humanoid = self.Character.Humanoid
    local position = humanoidRootPart.Position
    local distance = (Camera.CFrame.Position - position).Magnitude
    
    -- Check distance
    if distance > ESPSettings.MaxDistance then
        self.BoxDrawing.Visible = false
        self.LineDrawing.Visible = false
        self.TextDrawing.Visible = false
        return
    end
    
    -- Get bounding box
    local corners = CalculateCorners(self.Character)
    if not corners then
        self.BoxDrawing.Visible = false
        self.LineDrawing.Visible = false
        self.TextDrawing.Visible = false
        return
    end
    
    -- Additional size sanity check to avoid large boxes around non-character objects
    local boxWidth = math.abs(corners.TopCorner.X - corners.BottomCorner.X)
    local boxHeight = math.abs(corners.TopCorner.Y - corners.BottomCorner.Y)
    
    if boxWidth > 50 or boxHeight > 50 then
        self.BoxDrawing.Visible = false
        self.LineDrawing.Visible = false
        self.TextDrawing.Visible = false
        return
    end
    
    -- Box ESP
    if ESPSettings.BoxesEnabled then
        local bottomCorner = Camera:WorldToViewportPoint(corners.BottomCorner)
        local topCorner = Camera:WorldToViewportPoint(corners.TopCorner)
        
        if bottomCorner.Z > 0 and topCorner.Z > 0 then
            local width = math.abs(topCorner.X - bottomCorner.X)
            local height = math.abs(topCorner.Y - bottomCorner.Y)
            
            -- Additional size validation to prevent large boxes
            if width < 2000 and height < 2000 and width > 5 and height > 5 then
                self.BoxDrawing.Size = Vector2.new(width, height)
                self.BoxDrawing.Position = Vector2.new(
                    math.min(bottomCorner.X, topCorner.X),
                    math.min(bottomCorner.Y, topCorner.Y)
                )
                -- Use role-based colors for boxes too
                self.BoxDrawing.Color = ESPSettings.RoleColors[self.Role]
                self.BoxDrawing.Visible = true
            else
                self.BoxDrawing.Visible = false
            end
        else
            self.BoxDrawing.Visible = false
        end
    else
        self.BoxDrawing.Visible = false
    end
    
    -- Line ESP - now using role-based colors
    if ESPSettings.LinesEnabled then
        local headPosition = Camera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(0, 3, 0))
        
        if headPosition.Z > 0 then
            self.LineDrawing.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            self.LineDrawing.To = Vector2.new(headPosition.X, headPosition.Y)
            self.LineDrawing.Color = ESPSettings.RoleColors[self.Role]
            self.LineDrawing.Visible = true
        else
            self.LineDrawing.Visible = false
        end
    else
        self.LineDrawing.Visible = false
    end
    
    -- Text ESP (distance, name, health, and role)
    if ESPSettings.TextEnabled then
        local headPosition = Camera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(0, 3, 0))
        
        if headPosition.Z > 0 then
            local roundedDistance = math.floor(distance + 0.5)
            local healthPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100 + 0.5)
            
            self.TextDrawing.Text = string.format("%s|%dm|%s|%d%%", self.Role, roundedDistance, self.Player.Name, healthPercent)
            self.TextDrawing.Position = Vector2.new(headPosition.X, headPosition.Y - 30)
            self.TextDrawing.Color = ESPSettings.TextColor
            self.TextDrawing.Size = ESPSettings.TextSize
            self.TextDrawing.Visible = true
        else
            self.TextDrawing.Visible = false
        end
    else
        self.TextDrawing.Visible = false
    end
end

function ESP:Remove()
    self.BoxDrawing:Remove()
    self.LineDrawing:Remove()
    self.TextDrawing:Remove()
end

-- Main ESP manager
local ESPManager = {
    Players = {},
    Connections = {}
}

function ESPManager:Start()
    CreateESPFolder()
    
    -- Add existing players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            self.Players[player] = ESP.new(player)
        end
    end
    
    -- Handle new players joining
    table.insert(self.Connections, Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            -- Create new ESP instance
            self.Players[player] = ESP.new(player)
            
            -- Notify about new player
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "ESP",
                Text = player.Name .. " joined as " .. GetPlayerRole(player),
                Duration = 2
            })
        end
    end))
    
    -- Handle players leaving
    table.insert(self.Connections, Players.PlayerRemoving:Connect(function(player)
        if self.Players[player] then
            self.Players[player]:Remove()
            self.Players[player] = nil
        end
    end))
    
    -- Update ESP
    table.insert(self.Connections, RunService.RenderStepped:Connect(function()
        for _, esp in pairs(self.Players) do
            esp:Update()
        end
    end))
    
    -- Create settings GUI
    self:CreateSettingsGUI()
end

function ESPManager:Stop()
    -- Disconnect all connections
    for _, connection in pairs(self.Connections) do
        connection:Disconnect()
    end
    self.Connections = {}
    
    -- Remove all ESP objects
    for _, esp in pairs(self.Players) do
        esp:Remove()
    end
    self.Players = {}
    
    -- Remove ESP folder
    if ESPFolder then
        ESPFolder:Destroy()
    end
    
    -- Remove GUI
    if SettingsGui then
        SettingsGui:Destroy()
        SettingsGui = nil
    end
end

function ESPManager:ToggleGUI()
    if SettingsGui then
        -- If GUI exists, just show it instead of creating a new one
        SettingsGui.Enabled = true
        return
    end
    self:CreateSettingsGUI()
end

function ESPManager:UpdateAllButtons()
    -- This function updates all button appearances based on current settings
    if not SettingsGui then return end
    
    -- Find and update all toggle buttons
    for _, button in pairs(SettingsGui:GetDescendants()) do
        if button:IsA("TextButton") then
            local buttonText = button.Text
            -- Skip the X button and role color buttons
            if buttonText ~= "X" and not buttonText:find("Color") then
                local settingName = buttonText:split(":")[1]:gsub(" ", "")
                
                -- Map button text to setting names
                local settingMap = {
                    ["ESP"] = "Enabled",
                    ["Boxes"] = "BoxesEnabled",
                    ["Lines"] = "LinesEnabled",
                    ["TextInfo"] = "TextEnabled"
                }
                
                if settingMap[settingName] then
                    local isOn = ESPSettings[settingMap[settingName]]
                    button.Text = settingName .. ": " .. (isOn and "ON" or "OFF")
                    button.BackgroundColor3 = isOn and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
                    button.TextColor3 = Color3.fromRGB(255, 255, 255)
                end
            end
        end
    end
end

function ESPManager:CreateSettingsGUI()
    -- Check if GUI already exists, if so just show it
    if SettingsGui then
        SettingsGui.Enabled = true
        return
    end
    
    -- Create the ScreenGui with proper ZIndexBehavior
    SettingsGui = Instance.new("ScreenGui")
    SettingsGui.Name = "ESPSettings"
    SettingsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    SettingsGui.Parent = CoreGui
    SettingsGui.ResetOnSpawn = false
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 200, 0, 330)
    Frame.Position = UDim2.new(0, 10, 0, 10)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = SettingsGui
    
    -- Title with black background
    local TitleFrame = Instance.new("Frame")
    TitleFrame.Size = UDim2.new(1, 0, 0, 40)
    TitleFrame.Position = UDim2.new(0, 0, 0, 0)
    TitleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TitleFrame.BorderSizePixel = 0
    TitleFrame.Parent = Frame
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -25, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.SourceSansBold
    Title.Text = "Role ESP Settings"
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextYAlignment = Enum.TextYAlignment.Center
    Title.Parent = TitleFrame
    
    -- Add X button
    local XButton = Instance.new("TextButton")
    XButton.Size = UDim2.new(0, 25, 0, 25)
    XButton.Position = UDim2.new(1, -25, 0, 8)
    XButton.BackgroundTransparency = 1
    XButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    XButton.TextSize = 18
    XButton.Font = Enum.Font.SourceSansBold
    XButton.Text = "X"
    XButton.TextYAlignment = Enum.TextYAlignment.Center
    XButton.Parent = TitleFrame
    
    -- Add X button functionality - now just hides the GUI instead of destroying
    XButton.MouseButton1Click:Connect(function()
        SettingsGui.Enabled = false
    end)
    
    local function createButton(text, position, isOn, callback)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 30)
        button.Position = position
        button.Font = Enum.Font.SourceSansBold
        button.TextSize = 16
        button.Text = text
        button.Parent = Frame
        
        -- Update appearance based on state
        local function updateAppearance()
            if text:find("Police Color") then
                button.BackgroundColor3 = ESPSettings.RoleColors["Police"]
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
            elseif text:find("EMS Color") then
                button.BackgroundColor3 = ESPSettings.RoleColors["EMS"]
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
            elseif text:find("Prisoner Color") then
                button.BackgroundColor3 = ESPSettings.RoleColors["Prisoner"]
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
            elseif text:find("Neutral Color") then
                button.BackgroundColor3 = ESPSettings.RoleColors["Neutral"]
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                button.BackgroundColor3 = isOn and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
            end
        end
        
        updateAppearance()
        
        button.MouseButton1Click:Connect(function()
            if callback then
                if text:find("Color") then
                    -- For color buttons, cycle through some preset colors
                    callback()
                else
                    -- Toggle button state and update ESPSettings
                    isOn = not isOn
                    button.Text = text:split(":")[1] .. ": " .. (isOn and "ON" or "OFF")
                    callback(isOn)
                    
                    -- Apply notification when main ESP toggle changes
                    if text:find("ESP:") then
                        game:GetService("StarterGui"):SetCore("SendNotification", {
                            Title = "Role ESP",
                            Text = isOn and "Enabled" or "Disabled",
                            Duration = 2
                        })
                    end
                end
                
                updateAppearance()
                -- Update all buttons to ensure UI consistency
                ESPManager:UpdateAllButtons()
            end
        end)
        
        return button
    end
    
    -- Adjust button spacing for compact layout
    local buttonHeight = 30
    local buttonSpacing = 5
    local currentY = 45
    
    -- Create buttons with even spacing
    local espButton = createButton("ESP: " .. (ESPSettings.Enabled and "ON" or "OFF"), 
        UDim2.new(0, 0, 0, currentY), ESPSettings.Enabled, 
        function(value) 
            ESPSettings.Enabled = value 
        end)
    currentY = currentY + buttonHeight + buttonSpacing
    
    local boxesButton = createButton("Boxes: " .. (ESPSettings.BoxesEnabled and "ON" or "OFF"), 
        UDim2.new(0, 0, 0, currentY), ESPSettings.BoxesEnabled, 
        function(value) 
            ESPSettings.BoxesEnabled = value 
        end)
    currentY = currentY + buttonHeight + buttonSpacing
    
    local linesButton = createButton("Lines: " .. (ESPSettings.LinesEnabled and "ON" or "OFF"), 
        UDim2.new(0, 0, 0, currentY), ESPSettings.LinesEnabled, 
        function(value) 
            ESPSettings.LinesEnabled = value 
        end)
    currentY = currentY + buttonHeight + buttonSpacing
    
    local textButton = createButton("Text Info: " .. (ESPSettings.TextEnabled and "ON" or "OFF"), 
        UDim2.new(0, 0, 0, currentY), ESPSettings.TextEnabled, 
        function(value) 
            ESPSettings.TextEnabled = value 
        end)
    currentY = currentY + buttonHeight + buttonSpacing
    
    -- Add role color settings
    local policeColorButton = createButton("Police Color", UDim2.new(0, 0, 0, currentY), true, function()
        -- Cycle through blue shades
        local currentColor = ESPSettings.RoleColors["Police"]
        local blueShades = {
            Color3.fromRGB(0, 0, 255),      -- Bright blue
            Color3.fromRGB(0, 0, 200),      -- Medium blue
            Color3.fromRGB(0, 0, 150),      -- Darker blue
            Color3.fromRGB(30, 144, 255)    -- Dodger blue
        }
        
        for i, color in ipairs(blueShades) do
            if currentColor == color and i < #blueShades then
                ESPSettings.RoleColors["Police"] = blueShades[i + 1]
                break
            elseif i == #blueShades or currentColor ~= color then
                ESPSettings.RoleColors["Police"] = blueShades[1]
                break
            end
        end
    end)
    currentY = currentY + buttonHeight + buttonSpacing
    
    local emsColorButton = createButton("EMS Color", UDim2.new(0, 0, 0, currentY), true, function()
        -- Cycle through red shades
        local currentColor = ESPSettings.RoleColors["EMS"]
        local redShades = {
            Color3.fromRGB(255, 0, 0),      -- Bright red
            Color3.fromRGB(200, 0, 0),      -- Medium red
            Color3.fromRGB(150, 0, 0),      -- Darker red
            Color3.fromRGB(220, 20, 60)     -- Crimson
        }
        
        for i, color in ipairs(redShades) do
            if currentColor == color and i < #redShades then
                ESPSettings.RoleColors["EMS"] = redShades[i + 1]
                break
            elseif i == #redShades or currentColor ~= color then
                ESPSettings.RoleColors["EMS"] = redShades[1]
                break
            end
        end
    end)
    currentY = currentY + buttonHeight + buttonSpacing
    
    local prisonerColorButton = createButton("Prisoner Color", UDim2.new(0, 0, 0, currentY), true, function()
        -- Cycle through orange shades
        local currentColor = ESPSettings.RoleColors["Prisoner"]
        local orangeShades = {
            Color3.fromRGB(255, 165, 0),    -- Orange
            Color3.fromRGB(255, 140, 0),    -- Dark orange
            Color3.fromRGB(255, 69, 0),     -- Red-orange
            Color3.fromRGB(255, 215, 0)     -- Gold
        }
        
        for i, color in ipairs(orangeShades) do
            if currentColor == color and i < #orangeShades then
                ESPSettings.RoleColors["Prisoner"] = orangeShades[i + 1]
                break
            elseif i == #orangeShades or currentColor ~= color then
                ESPSettings.RoleColors["Prisoner"] = orangeShades[1]
                break
            end
        end
    end)
    currentY = currentY + buttonHeight + buttonSpacing
    
    local neutralColorButton = createButton("Neutral Color", UDim2.new(0, 0, 0, currentY), true, function()
        -- Cycle through gray shades
        local currentColor = ESPSettings.RoleColors["Neutral"]
        local grayShades = {
            Color3.fromRGB(128, 128, 128),  -- Gray
            Color3.fromRGB(169, 169, 169),  -- Dark gray
            Color3.fromRGB(192, 192, 192),  -- Silver
            Color3.fromRGB(105, 105, 105)   -- Dim gray
        }
        
        for i, color in ipairs(grayShades) do
            if currentColor == color and i < #grayShades then
                ESPSettings.RoleColors["Neutral"] = grayShades[i + 1]
                break
            elseif i == #grayShades or currentColor ~= color then
                ESPSettings.RoleColors["Neutral"] = grayShades[1]
                break
            end
        end
    end)
end

-- Keyboard shortcuts
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Toggle ESP with Right Control key
    if input.KeyCode == Enum.KeyCode.RightControl then
        ESPSettings.Enabled = not ESPSettings.Enabled
        -- Update GUI if it exists
        ESPManager:UpdateAllButtons()
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Role ESP",
            Text = ESPSettings.Enabled and "Enabled" or "Disabled",
            Duration = 2
        })
    end
    
    -- Toggle GUI with Right Alt key
    if input.KeyCode == Enum.KeyCode.RightAlt then
        ESPManager:ToggleGUI()
    end
end)

-- Start the ESP
ESPManager:Start()
   end,
})

-- Enhanced version with more features
local Toggle = MainTab:CreateToggle({
   Name = "Aim Bot",
   CurrentValue = false,
   Flag = "Toggle1", 
   Callback = function(Value)
       if Value then
           -- Configuration
           local ASSIST_RANGE = 800       -- Maximum range to detect targets
           local HEAD_OFFSET_FIRSTPERSON = Vector3.new(0, 0.1, 0)  -- Head offset for first person
           local HEAD_OFFSET_THIRDPERSON = Vector3.new(0, -0.2, 0)  -- Adjusted for third person
           local WALL_CHECK = true        -- Ignore targets behind walls
           local REACTION_SPEED = 0.01    -- How quickly to react to new targets (lower = faster)
           
           -- Different aim points
           local AIM_POINTS = {
               HEAD = "Head",
               TORSO = "HumanoidRootPart",
               LEGS = "LeftLeg"
           }
           
           local AIM_POINT = AIM_POINTS.HEAD  -- Default aim point
           
           local Players = game:GetService("Players")
           local RunService = game:GetService("RunService")
           local UserInputService = game:GetService("UserInputService")
           local Teams = game:GetService("Teams")
           
           local LocalPlayer = Players.LocalPlayer
           local Camera = workspace.CurrentCamera
           
           -- Function to check if a player is on the same team
           local function isTeammate(player)
               if not LocalPlayer.Team then return false end
               return player.Team == LocalPlayer.Team
           end
           
           -- Function to check if target is visible
           local function isTargetVisible(targetPart)
               if not targetPart then return false end
               
               local character = LocalPlayer.Character
               if not character or not character:FindFirstChild("Head") then return false end
               
               local ray = Ray.new(
                   character.Head.Position, 
                   targetPart.Position - character.Head.Position
               )
               
               local ignoreList = {character, Camera}
               -- Add any game-specific ignore parts
               local ignoreFolder = workspace:FindFirstChild("Ignore")
               if ignoreFolder then
                   table.insert(ignoreList, ignoreFolder)
               end
               
               local hit, hitPosition = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
               
               if hit and (hit:IsDescendantOf(targetPart.Parent) or hit == targetPart) then
                   return true
               end
               
               return false
           end
           
           -- Function to check if a character is valid target
           local function isValidTarget(character, player)
               if not character then return false end
               
               -- Check if character has necessary parts
               local humanoid = character:FindFirstChild("Humanoid")
               local head = character:FindFirstChild("Head")
               local rootPart = character:FindFirstChild("HumanoidRootPart")
               
               -- If it's a player, check team status
               if player then
                   if isTeammate(player) then return false end
               end
               
               -- Basic validity check
               if not (humanoid and head and rootPart) then return false end
               if humanoid.Health <= 0 then return false end
               
               -- Wall check if enabled
               if WALL_CHECK then
                   local targetPart = character:FindFirstChild(AIM_POINT)
                   if not targetPart then targetPart = head end
                   
                   return isTargetVisible(targetPart)
               end
               
               return true
           end
           
           -- Function to detect camera mode
           local function isFirstPersonMode()
               local character = LocalPlayer.Character
               if not character or not character:FindFirstChild("Head") then return true end
               
               local headPos = character.Head.Position
               local camPos = Camera.CFrame.Position
               
               return (headPos - camPos).Magnitude < 2
           end
           
           -- Function to get head offset based on view mode
           local function getTargetOffset()
               if isFirstPersonMode() then
                   return HEAD_OFFSET_FIRSTPERSON
               else
                   return HEAD_OFFSET_THIRDPERSON
               end
           end
           
           -- Function to check for equipped weapon
           local function hasWeaponEquipped()
               local character = LocalPlayer.Character
               if not character then return false end
               
               for _, item in pairs(character:GetChildren()) do
                   if item:IsA("Tool") then
                       -- You can add weapon-specific detection here
                       return true
                   end
               end
               
               return false
           end
           
           -- Enhanced priority target selection
           local function getBestTarget()
               local targets = {}
               local playerChar = LocalPlayer.Character
               if not playerChar then return nil end
               
               local playerHead = playerChar:FindFirstChild("Head")
               if not playerHead then return nil end
               
               -- Process all players
               for _, player in pairs(Players:GetPlayers()) do
                   if player ~= LocalPlayer then
                       local character = player.Character
                       if isValidTarget(character, player) then
                           local targetPart = character:FindFirstChild(AIM_POINT)
                           if not targetPart then targetPart = character:FindFirstChild("Head") end
                           
                           if targetPart then
                               local distance = (playerHead.Position - targetPart.Position).Magnitude
                               
                               if distance <= ASSIST_RANGE then
                                   -- Calculate angle priority
                                   local lookVector = Camera.CFrame.LookVector
                                   local toTarget = (targetPart.Position - Camera.CFrame.Position).Unit
                                   local angle = math.acos(math.clamp(lookVector:Dot(toTarget), -1, 1))
                                   
                                   -- Calculate priority: distance, angle, visibility
                                   local priority = (ASSIST_RANGE - distance)
                                   
                                   -- Huge priority boost for targets already near crosshair
                                   if angle < math.rad(5) then
                                       priority = priority * 10
                                   elseif angle < math.rad(20) then
                                       priority = priority * 3
                                   end
                                   
                                   -- Priority based on angle to target
                                   priority = priority + (math.pi - angle) * 200
                                   
                                   -- Add health consideration - prefer lower health targets
                                   local humanoid = character:FindFirstChild("Humanoid")
                                   if humanoid then
                                       priority = priority + (100 - humanoid.Health) * 2
                                   end
                                   
                                   table.insert(targets, {
                                       character = character,
                                       targetPart = targetPart,
                                       distance = distance,
                                       priority = priority,
                                       angle = angle,
                                       health = humanoid and humanoid.Health or 100
                                   })
                               end
                           end
                       end
                   end
               end
               
               -- Handle NPCs
               local possibleFolders = {"NPCs", "Monsters", "Enemies", "Mobs"}
               for _, folderName in pairs(possibleFolders) do
                   local folder = workspace:FindFirstChild(folderName)
                   if folder then
                       for _, npc in pairs(folder:GetChildren()) do
                           if isValidTarget(npc) then
                               local targetPart = npc:FindFirstChild(AIM_POINT)
                               if not targetPart then targetPart = npc:FindFirstChild("Head") end
                               
                               if targetPart then
                                   local distance = (playerHead.Position - targetPart.Position).Magnitude
                                   
                                   if distance <= ASSIST_RANGE then
                                       -- Same priority calculation logic as players
                                       local lookVector = Camera.CFrame.LookVector
                                       local toTarget = (targetPart.Position - Camera.CFrame.Position).Unit
                                       local angle = math.acos(math.clamp(lookVector:Dot(toTarget), -1, 1))
                                       
                                       local priority = (ASSIST_RANGE - distance)
                                       
                                       if angle < math.rad(5) then
                                           priority = priority * 10
                                       elseif angle < math.rad(20) then
                                           priority = priority * 3
                                       end
                                       
                                       priority = priority + (math.pi - angle) * 200
                                       
                                       local humanoid = npc:FindFirstChild("Humanoid")
                                       if humanoid then
                                           priority = priority + (100 - humanoid.Health) * 2
                                       end
                                       
                                       table.insert(targets, {
                                           character = npc,
                                           targetPart = targetPart,
                                           distance = distance,
                                           priority = priority,
                                           angle = angle,
                                           health = humanoid and humanoid.Health or 100
                                       })
                                   end
                               end
                           end
                       end
                   end
               end
               
               -- Sort by priority and return the best target
               table.sort(targets, function(a, b)
                   return a.priority > b.priority
               end)
               
               return targets[1]
           end
           
           -- Calculate the ideal aim position
           local function calculateAimPosition(targetInfo)
               if not targetInfo or not targetInfo.targetPart then return nil end
               
               local offset = getTargetOffset()
               
               -- Apply distance-based adjustments
               if targetInfo.distance > 100 then
                   -- For distant targets, aim slightly higher to account for bullet drop
                   offset = offset + Vector3.new(0, 0.1 + (targetInfo.distance / 1000), 0)
               end
               
               -- Apply different offset for steep angles
               local lookVectorY = Camera.CFrame.LookVector.Y
               if math.abs(lookVectorY) > 0.5 then
                   offset = offset + Vector3.new(0, -lookVectorY * 0.2, 0)
               end
               
               return targetInfo.targetPart.Position + offset
           end
           
           -- Main update function
           local function advancedUpdate()
               local targetInfo = getBestTarget()
               if not targetInfo then return end
               
               local aimPosition = calculateAimPosition(targetInfo)
               if not aimPosition then return end
               
               -- Determine proper smoothing/snap speed
               local isWeaponEquipped = hasWeaponEquipped()
               local smoothFactor
               
               if isWeaponEquipped then
                   -- Instant snap when weapon is equipped
                   smoothFactor = 1
               else
                   -- Smooth tracking otherwise
                   smoothFactor = 0.3
               end
               
               -- Adjust smoothness based on angle (more snap for targets already near crosshair)
               if targetInfo.angle < math.rad(5) then
                   smoothFactor = math.min(1, smoothFactor + 0.4)
               end
               
               -- Create aim CFrame and apply with smoothing
               local aimCFrame = CFrame.lookAt(Camera.CFrame.Position, aimPosition)
               Camera.CFrame = Camera.CFrame:Lerp(aimCFrame, smoothFactor)
           end
           
           -- Connect update function to RenderStepped for smooth performance
           _G.AdvancedAimConnection = RunService.RenderStepped:Connect(advancedUpdate)
           
       else
           -- Cleanup when toggled off
           if _G.AdvancedAimConnection then
               _G.AdvancedAimConnection:Disconnect()
               _G.AdvancedAimConnection = nil
           end
       end
   end
})

local TeleportTab = Window:CreateTab("🌀Teleport", nil) -- Title, Image
local TeleportSection = TeleportTab:CreateSection("Teleport")

local teleportLocations = {
    ["Construction Job"] = Vector3.new(-1729, 370, -1171),
    ["Warehouse"] = Vector3.new(-1563, 258, -1174),
    ["Ice Box"] = Vector3.new(-202, 283, -1169),
    ["Land Lord"] = Vector3.new(-209, 283, -1240),
    ["Pawn Shop"] = Vector3.new(-1052, 253, -808),
    ["Car Dealership"] = Vector3.new(-374, 253, -1247),
    ["McDonalds Job"] = Vector3.new(-385, 253, -1100)
}

local Dropdown = TeleportTab:CreateDropdown({
   Name = "Teleport Locations",
   Options = {
       "Construction Job",
       "Warehouse",
       "Ice Box",
       "Land Lord",
       "Pawn Shop",
       "Car Dealership", 
       "McDonalds Job"
   },
   CurrentOption = {}, -- Empty table means no initial selection
   MultipleOptions = false,
   Flag = "TeleportLocation",
   Callback = function(Option)
       -- Check if a location was selected
       if #Option == 0 then
           return -- No location selected, do nothing
       end
       
       -- Get the selected location from the dropdown
       local selectedLocation = Option[1]
       
       -- Get target position
       local targetPosition = teleportLocations[selectedLocation]
       if not targetPosition then return end
       
       -- Get player and services
       local Players = game:GetService("Players")
       local RunService = game:GetService("RunService")
       local TweenService = game:GetService("TweenService")
       local LocalPlayer = Players.LocalPlayer
       local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
       local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
       
       -- Create transition screen
       local screenGui = Instance.new("ScreenGui")
       screenGui.Name = "TeleportTransition"
       screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
       
       local frame = Instance.new("Frame")
       frame.Size = UDim2.new(1, 0, 1, 0)
       frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
       frame.BackgroundTransparency = 1
       frame.Parent = screenGui
       
       local textLabel = Instance.new("TextLabel")
       textLabel.Size = UDim2.new(1, 0, 0, 50)
       textLabel.Position = UDim2.new(0, 0, 0.5, -25)
       textLabel.BackgroundTransparency = 1
       textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
       textLabel.TextSize = 24
       textLabel.Font = Enum.Font.GothamBold
       textLabel.Text = "Teleporting to " .. selectedLocation .. "..."
       textLabel.TextTransparency = 1
       textLabel.Parent = frame
       
       screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
       
       -- Fade in animation
       local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
       local fadeIn = TweenService:Create(frame, tweenInfo, {BackgroundTransparency = 0})
       local textFadeIn = TweenService:Create(textLabel, tweenInfo, {TextTransparency = 0})
       
       fadeIn:Play()
       textFadeIn:Play()
       
       -- Setup no-clip
       local noclipConnection = RunService.Stepped:Connect(function()
           if Character and Character:FindFirstChild("Humanoid") then
               for _, part in pairs(Character:GetDescendants()) do
                   if part:IsA("BasePart") then
                       part.CanCollide = false
                   end
               end
           end
       end)
       
       -- Wait for transition
       task.wait(0.6)
       
       -- Make character invulnerable
       local humanoid = Character:FindFirstChild("Humanoid")
       local oldInvulnerable
       if humanoid then
           oldInvulnerable = humanoid.BreakJointsOnDeath
           humanoid.BreakJointsOnDeath = false
       end
       
       -- Calculate distance and duration (max speed of 30)
       local distance = (targetPosition - HumanoidRootPart.Position).Magnitude
       local duration = distance / 30
       
       -- Create and start tween
       local tween = TweenService:Create(
           HumanoidRootPart, 
           TweenInfo.new(duration, Enum.EasingStyle.Linear), 
           {CFrame = CFrame.new(targetPosition)}
       )
       
       tween.Completed:Connect(function()
           -- Restore character properties
           if humanoid and humanoid.Parent then
               humanoid.BreakJointsOnDeath = oldInvulnerable
           end
           
           -- Disable no-clip
           if noclipConnection then
               noclipConnection:Disconnect()
           end
           
           -- Fade out transition screen
           local fadeOut = TweenService:Create(frame, tweenInfo, {BackgroundTransparency = 1})
           local textFadeOut = TweenService:Create(textLabel, tweenInfo, {TextTransparency = 1})
           
           fadeOut:Play()
           textFadeOut:Play()
           
           fadeOut.Completed:Connect(function()
               screenGui:Destroy()
           end)
       end)
       
       tween:Play()
   end
})

local MiscTab = Window:CreateTab("📢Misc", nil) -- Title, Image
local MiscSection = MiscTab:CreateSection("Misc")

local Button = MiscTab:CreateButton({
    Name = "Rejoin",
    Callback = function()
        -- Create notification before rejoining
        Rayfield:Notify({
            Title = "Rejoining Server",
            Content = "Please wait 3 seconds while we reconnect you...",
            Duration = 3,
            Image = nil,
        })
        
        -- Wait for 1 second to allow notification to be seen
        task.wait(1)
        
        -- Get the TeleportService
        local TeleportService = game:GetService("TeleportService")
        local player = game:GetService("Players").LocalPlayer
        
        -- Rejoin the same server
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
    end,
})

-- Regular Server Hop Button
local ServerHopButton = MiscTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        Rayfield:Notify({
            Title = "Server Hop",
            Content = "Finding a random server...",
            Duration = 3,
            Image = nil,
        })
        
        local TeleportService = game:GetService("TeleportService")
        local HttpService = game:GetService("HttpService")
        local player = game:GetService("Players").LocalPlayer
        
        local function GetRandomServer()
            local servers = {}
            local endpoint = string.format(
                "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Desc&limit=100",
                game.PlaceId
            )
            
            local success, result = pcall(function()
                return HttpService:JSONDecode(game:HttpGet(endpoint))
            end)
            
            if success and result and result.data then
                for _, server in ipairs(result.data) do
                    if server.id ~= game.JobId and server.playing < server.maxPlayers then
                        table.insert(servers, server)
                    end
                end
            end
            
            return #servers > 0 and servers[math.random(1, #servers)] or nil
        end
        
        local randomServer = GetRandomServer()
        
        if randomServer then
            Rayfield:Notify({
                Title = "Server Found",
                Content = string.format("Joining server with %d players...", randomServer.playing),
                Duration = 3,
                Image = nil,
            })
            
            task.wait(1)
            
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer.id, player)
            end)
        else
            Rayfield:Notify({
                Title = "Server Hop Failed",
                Content = "No available servers found. Try again later.",
                Duration = 3,
                Image = nil,
            })
        end
    end,
})

-- Low Player Server Button
local LowPlayerServerButton = MiscTab:CreateButton({
    Name = "Join Low Player Server",
    Callback = function()
        Rayfield:Notify({
            Title = "Finding Server",
            Content = "Searching for a low population server...",
            Duration = 3,
            Image = nil,
        })
        
        local TeleportService = game:GetService("TeleportService")
        local HttpService = game:GetService("HttpService")
        local player = game:GetService("Players").LocalPlayer
        
        local function GetLowPopulationServer()
            local servers = {}
            local endpoint = string.format(
                "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100",
                game.PlaceId
            )
            
            local success, result = pcall(function()
                return HttpService:JSONDecode(game:HttpGet(endpoint))
            end)
            
            if success and result and result.data then
                for _, server in ipairs(result.data) do
                    -- Look for servers with less than 5 players
                    if server.playing < 5 and server.id ~= game.JobId then
                        table.insert(servers, server)
                    end
                end
                
                -- Sort by player count (ascending)
                table.sort(servers, function(a, b)
                    return a.playing < b.playing
                end)
            end
            
            return #servers > 0 and servers[1] or nil
        end
        
        local lowServer = GetLowPopulationServer()
        
        if lowServer then
            Rayfield:Notify({
                Title = "Low Player Server Found",
                Content = string.format("Joining server with only %d players...", lowServer.playing),
                Duration = 3,
                Image = nil,
            })
            
            task.wait(1)
            
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, lowServer.id, player)
            end)
        else
            Rayfield:Notify({
                Title = "Server Search Failed",
                Content = "No low population servers found. Try again later.",
                Duration = 3,
                Image = nil,
            })
        end
    end,
})

local JobIdInput = MiscTab:CreateInput({
    Name = "Server JobId",
    CurrentValue = "",
    PlaceholderText = "Format: PlaceId:JobId",
    RemoveTextAfterFocusLost = false,
    Flag = "JobIdTeleport",
    Callback = function(Input)
        if Input == "" then return end
        
        local TeleportService = game:GetService("TeleportService")
        local Players = game:GetService("Players")
        
        -- Split the input into PlaceId and JobId using : as separator
        local placeId, jobId = Input:match("(%d+):(.+)")
        
        -- If no : found, check for just numbers (PlaceId) or assume it's a JobId for current game
        if not placeId then
            if Input:match("^%d+$") then
                -- If input is all numbers, treat as PlaceId
                placeId = Input
                jobId = nil
            else
                -- If input contains non-numbers, treat as JobId for current game
                placeId = game.PlaceId
                jobId = Input
            end
        end
        
        -- Convert PlaceId to number
        placeId = tonumber(placeId)
        
        if not placeId then
            Rayfield:Notify({
                Title = "Invalid Input",
                Content = "Invalid PlaceId format",
                Duration = 3,
                Image = nil,
            })
            return
        end
        
        Rayfield:Notify({
            Title = "Teleporting",
            Content = jobId and "Joining specific server..." or "Joining game...",
            Duration = 3,
            Image = nil,
        })
        
        -- Set up teleport error handling
        local teleportOptions = Instance.new("TeleportOptions")
        teleportOptions.ServerInstanceId = jobId
        
        -- Set up retry logic for teleport failures
        local function attemptTeleport(retryCount)
            retryCount = retryCount or 0
            
            if retryCount >= 3 then
                Rayfield:Notify({
                    Title = "Error",
                    Content = "Failed to teleport after multiple attempts. Server might be unavailable.",
                    Duration = 5,
                    Image = nil,
                })
                return
            end
            
            local success, error = pcall(function()
                if jobId then
                    TeleportService:TeleportToPlaceInstance(placeId, jobId, Players.LocalPlayer, nil, teleportOptions)
                else
                    TeleportService:Teleport(placeId, Players.LocalPlayer, teleportOptions)
                end
            end)
            
            if not success then
                print("Teleport Error (Attempt " .. retryCount + 1 .. "):", error)
                
                -- Check for specific error messages
                if typeof(error) == "string" then
                    if error:find("experience is closed") or error:find("server is full") or error:find("reserved server") then
                        Rayfield:Notify({
                            Title = "Teleport Failed",
                            Content = "Server is either full, closed, or unavailable. " .. error,
                            Duration = 5,
                            Image = nil,
                        })
                    else
                        -- For other errors, retry after a short delay
                        Rayfield:Notify({
                            Title = "Retrying...",
                            Content = "Attempt " .. retryCount + 2 .. " in 2 seconds",
                            Duration = 2,
                            Image = nil,
                        })
                        task.delay(2, function()
                            attemptTeleport(retryCount + 1)
                        end)
                    end
                end
            end
        end
        
        -- Connect to teleport failure event
        local connection
        connection = TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
            if player == Players.LocalPlayer then
                connection:Disconnect()
                
                print("Teleport failed:", teleportResult.Name, errorMessage)
                
                if teleportResult == Enum.TeleportResult.GameEnded or 
                   teleportResult == Enum.TeleportResult.GameFull or
                   teleportResult == Enum.TeleportResult.Unauthorized then
                    Rayfield:Notify({
                        Title = "Teleport Failed",
                        Content = "Reason: " .. teleportResult.Name .. " - " .. (errorMessage or ""),
                        Duration = 5,
                        Image = nil,
                    })
                else
                    -- Try again for other teleport failures
                    Rayfield:Notify({
                        Title = "Retrying teleport",
                        Content = "First attempt failed: " .. teleportResult.Name,
                        Duration = 2,
                        Image = nil,
                    })
                    task.delay(2, function() 
                        attemptTeleport(1)
                    end)
                end
            end
        end)
        
        -- Start first teleport attempt
        task.delay(1, function()
            attemptTeleport(0)
        end)
    end,
})

local LinkInput = MiscTab:CreateInput({
    Name = "Game/Private Server Link",
    CurrentValue = "",
    PlaceholderText = "Paste game or private server link here",
    RemoveTextAfterFocusLost = false,
    Flag = "LinkTeleport",
    Callback = function(Link)
        if Link == "" then return end
        
        local TeleportService = game:GetService("TeleportService")
        local Players = game:GetService("Players")
        
        -- Extract PlaceId and optional PrivateServerId from the link
        local placeId = Link:match("roblox.com/games/(%d+)")
        local privateServerId = Link:match("privateServerLinkCode=([%w%-]+)")
        
        if not placeId then
            Rayfield:Notify({
                Title = "Invalid Link",
                Content = "Please provide a valid Roblox game link",
                Duration = 3,
                Image = nil,
            })
            return
        end
        
        placeId = tonumber(placeId)
        
        Rayfield:Notify({
            Title = "Teleporting",
            Content = "Joining game in 2 seconds...",
            Duration = 2,
            Image = nil,
        })
        
        -- Set up teleport error handling
        local teleportOptions = Instance.new("TeleportOptions")
        
        -- Set up retry logic for teleport failures
        local function attemptTeleport(retryCount)
            retryCount = retryCount or 0
            
            if retryCount >= 3 then
                Rayfield:Notify({
                    Title = "Error",
                    Content = "Failed to teleport after multiple attempts. Server might be unavailable.",
                    Duration = 5,
                    Image = nil,
                })
                return
            end
            
            local success, error = pcall(function()
                if privateServerId then
                    TeleportService:TeleportToPrivateServer(placeId, privateServerId, {Players.LocalPlayer})
                else
                    TeleportService:Teleport(placeId, Players.LocalPlayer, teleportOptions)
                end
            end)
            
            if not success then
                print("Teleport Error (Attempt " .. retryCount + 1 .. "):", error)
                
                -- Check for specific error messages
                if typeof(error) == "string" then
                    if error:find("experience is closed") or error:find("server is full") or error:find("reserved server") then
                        Rayfield:Notify({
                            Title = "Teleport Failed",
                            Content = "Server is either full, closed, or unavailable: " .. error,
                            Duration = 5,
                            Image = nil,
                        })
                    else
                        -- For other errors, retry after a short delay
                        Rayfield:Notify({
                            Title = "Retrying...",
                            Content = "Attempt " .. retryCount + 2 .. " in 2 seconds",
                            Duration = 2,
                            Image = nil,
                        })
                        task.delay(2, function()
                            attemptTeleport(retryCount + 1)
                        end)
                    end
                end
            end
        end
        
        -- Connect to teleport failure event
        local connection
        connection = TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
            if player == Players.LocalPlayer then
                connection:Disconnect()
                
                print("Teleport failed:", teleportResult.Name, errorMessage)
                
                if teleportResult == Enum.TeleportResult.GameEnded or 
                   teleportResult == Enum.TeleportResult.GameFull or
                   teleportResult == Enum.TeleportResult.Unauthorized then
                    Rayfield:Notify({
                        Title = "Teleport Failed",
                        Content = "Reason: " .. teleportResult.Name .. " - " .. (errorMessage or ""),
                        Duration = 5,
                        Image = nil,
                    })
                else
                    -- Try again for other teleport failures
                    Rayfield:Notify({
                        Title = "Retrying teleport",
                        Content = "First attempt failed: " .. teleportResult.Name,
                        Duration = 2,
                        Image = nil,
                    })
                    task.delay(2, function() 
                        attemptTeleport(1)
                    end)
                end
            end
        end)
        
        -- Start first teleport attempt
        task.delay(1, function()
            attemptTeleport(0)
        end)
    end,
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local autoAfkToggleEnabled = false  -- Estado do toggle para Anti-AFK

-- Função para enviar mensagem para prevenir desconexão
local function sendChatMessage()
    -- Envia mensagem para manter o sistema reconhecendo a atividade do jogador
    ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Auto-clicking to prevent AFK disconnection.", "All")
    print("Simulated activity: Preventing AFK disconnection.")
end

-- Função para evitar desconexão por AFK (ao detectar a inatividade do jogador)
local function startAntiAfk()
    -- A cada 10 minutos, envia a mensagem para resetar o timer AFK
    while autoAfkToggleEnabled do
        wait(600)  -- Espera 600 segundos (10 minutos)
        sendChatMessage()  -- Envia a mensagem para manter o jogador ativo
    end
end

-- Parar Anti-AFK (quando toggle é desabilitado)
local function stopAntiAfk()
    autoAfkToggleEnabled = false
    print("Anti-AFK disabled")
end

-- Criar o Toggle no UI para Anti-AFK
local AntiAfkToggle = MiscTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = false,
    Flag = "AntiAfkToggle",
    Callback = function(Value)
        if type(Value) == "boolean" then
            autoAfkToggleEnabled = Value
            print("Anti-AFK Enabled: ", autoAfkToggleEnabled)

            if autoAfkToggleEnabled then
                -- Inicia a verificação de Anti-AFK
                startAntiAfk()  
            else
                -- Para a verificação de Anti-AFK
                stopAntiAfk()   
            end
        else
            warn("Expected boolean for Anti-AFK toggle, received: ", type(Value))
        end
    end
})
