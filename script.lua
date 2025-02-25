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

-- Xeno ESP Script (Now With Movable Mini Radar)
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

-- Table to store ESP & radar data
local ESP_Objects = {}
local Radar_Dots = {}
local ESPEnabled = false -- Flag to track if ESP is enabled

-- Radar Settings
local RadarSize = 150 -- Size of the radar (square)
local RadarScale = 3 -- Scaling factor for distance visualization
local RadarPosition = Vector2.new(30, 30) -- Position (movable)
local DraggingRadar = false
local DragOffset = Vector2.new(0, 0)

-- Team colors for ESP and radar
local TeamColors = {
    ["Police"] = Color3.fromRGB(0, 0, 255), -- Blue
    ["Prisoner"] = Color3.fromRGB(255, 165, 0), -- Orange
    ["EMS"] = Color3.fromRGB(255, 0, 0), -- Red
    ["Neutral"] = Color3.fromRGB(128, 128, 128) -- Gray
}

-- Create Radar Base
local RadarFrame = Drawing.new("Square")
RadarFrame.Size = Vector2.new(RadarSize, RadarSize)
RadarFrame.Position = RadarPosition
RadarFrame.Color = Color3.fromRGB(255, 255, 255) -- White border
RadarFrame.Thickness = 2
RadarFrame.Filled = false
RadarFrame.Transparency = 1
RadarFrame.Visible = false -- Initially hidden until enabled

-- Create Radar Center Dot (Your Position)
local RadarCenter = Drawing.new("Circle")
RadarCenter.Position = RadarPosition + Vector2.new(RadarSize / 2, RadarSize / 2)
RadarCenter.Radius = 3
RadarCenter.Color = Color3.fromRGB(0, 255, 0) -- Green for local player
RadarCenter.Filled = true
RadarCenter.Transparency = 1
RadarCenter.Visible = false -- Initially hidden until enabled

-- Function to create ESP
local function CreateESP(Player)
    if Player == LocalPlayer then return end -- Skip local player

    local function UpdatePlayerESP()
        if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
        
        local HRP = Player.Character:FindFirstChild("HumanoidRootPart")
        local Humanoid = Player.Character:FindFirstChild("Humanoid")
        local oldTeam = ESP_Objects[Player] and ESP_Objects[Player].Team or nil
        local Team = Player.Team and Player.Team.Name or "Neutral"
        local LineColor = TeamColors[Team] or Color3.fromRGB(255, 255, 255) -- Default white
        local BoxColor = Color3.fromRGB(255, 0, 0) -- Red boxes for everyone

        -- Check if team changed
        if oldTeam and oldTeam ~= Team then
            Rayfield:Notify({
                Title = "Team Changed",
                Content = Player.DisplayName .. " changed from " .. oldTeam .. " to " .. Team,
                Duration = 6.5,
                Image = nil,
            })
        end

        -- Remove old ESP if exists
        if ESP_Objects[Player] then
            ESP_Objects[Player].Box:Remove()
            ESP_Objects[Player].Line:Remove()
            ESP_Objects[Player].Text:Remove()
            ESP_Objects[Player].RadarDot:Remove()
        end

        -- Create new ESP elements
        local Box = Drawing.new("Square")
        Box.Thickness = 3  -- FIXED: Increased thickness for better visibility
        Box.Color = BoxColor
        Box.Filled = false
        Box.Transparency = 1
        Box.Visible = false

        local Line = Drawing.new("Line")
        Line.Thickness = 2
        Line.Color = LineColor
        Line.Transparency = 1
        Line.Visible = false

        local Text = Drawing.new("Text")
        Text.Size = 15
        Text.Color = Color3.fromRGB(255, 255, 255) -- White text
        Text.Center = true
        Text.Outline = true
        Text.Transparency = 1
        Text.Visible = false

        local RadarDot = Drawing.new("Circle")
        RadarDot.Radius = 3
        RadarDot.Color = LineColor
        RadarDot.Filled = true
        RadarDot.Transparency = 1
        RadarDot.Visible = false

        ESP_Objects[Player] = { 
            Box = Box, 
            Line = Line, 
            Text = Text, 
            RadarDot = RadarDot, 
            HRP = HRP, 
            Humanoid = Humanoid,
            Team = Team 
        }
    end

    -- Initial ESP creation
    UpdatePlayerESP()
    
    -- Notify for new player
    Rayfield:Notify({
        Title = "Player Joined",
        Content = Player.DisplayName .. " added to ESP",
        Duration = 6.5,
        Image = nil,
    })

    -- Update ESP when the player switches teams
    Player:GetPropertyChangedSignal("Team"):Connect(UpdatePlayerESP)
end

-- Function to remove ESP when a player leaves
local function RemoveESP(Player)
    if ESP_Objects[Player] then
        ESP_Objects[Player].Box:Remove()
        ESP_Objects[Player].Line:Remove()
        ESP_Objects[Player].Text:Remove()
        ESP_Objects[Player].RadarDot:Remove()
        ESP_Objects[Player] = nil
    end
end

-- Function to properly calculate character size for better box fitting
local function GetCharacterSize(Character)
    if not Character then return Vector3.new(3, 5, 2) end -- Default size if character not available
    
    local minX, minY, minZ = math.huge, math.huge, math.huge
    local maxX, maxY, maxZ = -math.huge, -math.huge, -math.huge
    
    -- Loop through all parts to find bounds
    for _, part in pairs(Character:GetChildren()) do
        if part:IsA("BasePart") then
            minX = math.min(minX, part.Position.X - part.Size.X/2)
            minY = math.min(minY, part.Position.Y - part.Size.Y/2)
            minZ = math.min(minZ, part.Position.Z - part.Size.Z/2)
            
            maxX = math.max(maxX, part.Position.X + part.Size.X/2)
            maxY = math.max(maxY, part.Position.Y + part.Size.Y/2)
            maxZ = math.max(maxZ, part.Position.Z + part.Size.Z/2)
        end
    end
    
    -- If we couldn't find any parts, return default
    if minX == math.huge then return Vector3.new(3, 5, 2) end
    
    return Vector3.new(maxX - minX, maxY - minY, maxZ - minZ)
end

-- Update radar position based on mouse movement when dragging
local function UpdateRadarPosition(mousePos)
    if DraggingRadar then
        local newPosition = mousePos - DragOffset
        RadarPosition = newPosition
        RadarFrame.Position = RadarPosition
        RadarCenter.Position = RadarPosition + Vector2.new(RadarSize / 2, RadarSize / 2)
    end
end

-- Setup radar drag functionality
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = Vector2.new(input.Position.X, input.Position.Y)
        
        -- Check if mouse is over radar
        if mousePos.X >= RadarPosition.X and 
           mousePos.X <= RadarPosition.X + RadarSize and 
           mousePos.Y >= RadarPosition.Y and 
           mousePos.Y <= RadarPosition.Y + RadarSize then
            
            DraggingRadar = true
            DragOffset = mousePos - RadarPosition
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        DraggingRadar = false
    end
end)

UserInputService.InputChanged:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        UpdateRadarPosition(Vector2.new(input.Position.X, input.Position.Y))
    end
end)

-- Update ESP and Radar positions dynamically
local function UpdateESP()
    if not ESPEnabled then
        RadarFrame.Visible = false
        RadarCenter.Visible = false
        for _, Data in pairs(ESP_Objects) do
            Data.Box.Visible = false
            Data.Line.Visible = false
            Data.Text.Visible = false
            Data.RadarDot.Visible = false
        end
        return
    end
    
    RadarFrame.Visible = true
    RadarCenter.Visible = true
    
    for Player, Data in pairs(ESP_Objects) do
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Data.Humanoid then
            local HRP = Data.HRP
            local Humanoid = Data.Humanoid
            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(HRP.Position)
            local Distance = math.floor((HRP.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
            
            -- CRITICAL FIX: Always update and show the ESP boxes regardless of OnScreen check
            
            -- Get character size but with fixed minimum values
            local CharSize = GetCharacterSize(Player.Character)
            
            -- Hardcoded minimum size for boxes to ensure visibility
            local MinBoxHeight = 60  -- Increased minimum box height
            local MinBoxWidth = 35   -- Increased minimum box width
            
            -- FIXED: Drastically reduced distance impact on scaling to ensure boxes are visible at all distances
            local ScaleFactor = 1 / (Distance * 0.003 + 1)
            
            -- Calculate box dimensions
            local TopY = ScreenPos.Y - (CharSize.Y * 0.55) * ScaleFactor
            local BottomY = ScreenPos.Y + (CharSize.Y * 0.15) * ScaleFactor
            local BoxHeight = math.max(BottomY - TopY, MinBoxHeight)
            local BoxWidth = math.max(BoxHeight * 0.6, MinBoxWidth)
            
            -- Guaranteed box display: force boxes to be visible with proper dimensions
            Data.Box.Size = Vector2.new(BoxWidth, BoxHeight)
            Data.Box.Position = Vector2.new(ScreenPos.X - BoxWidth/2, TopY)
            
            -- MAJOR FIX: Always display the box regardless of whether player is on screen
            Data.Box.Visible = true
            
            -- FIXED: Ensure correct team colors
            local teamName = Player.Team and Player.Team.Name or "Neutral"
            local correctLineColor = TeamColors[teamName] or Color3.fromRGB(255, 255, 255)
            Data.Line.Color = correctLineColor
            Data.RadarDot.Color = correctLineColor

            -- ESP Line
            Data.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            Data.Line.To = Vector2.new(ScreenPos.X, ScreenPos.Y)
            Data.Line.Visible = true

            -- ESP Text
            Data.Text.Text = string.format("%d M | %s | %d HP", Distance, Player.DisplayName, math.floor(Humanoid.Health))
            Data.Text.Position = Vector2.new(ScreenPos.X, TopY - 15)
            Data.Text.Visible = true

            -- Radar Logic
            local LocalHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if LocalHRP then
                local RelativePosition = (HRP.Position - LocalHRP.Position) / RadarScale
                local RadarX = math.clamp(RadarSize / 2 + RelativePosition.X, 5, RadarSize - 5)
                local RadarY = math.clamp(RadarSize / 2 + RelativePosition.Z, 5, RadarSize - 5)
                Data.RadarDot.Position = RadarPosition + Vector2.new(RadarX, RadarY)
                Data.RadarDot.Visible = true
            else
                Data.RadarDot.Visible = false
            end
        else
            if ESP_Objects[Player] then
                ESP_Objects[Player].Box.Visible = false
                ESP_Objects[Player].Line.Visible = false
                ESP_Objects[Player].Text.Visible = false
                ESP_Objects[Player].RadarDot.Visible = false
            end
        end
    end
end

-- Toggle to enable/disable ESP
local Toggle = MainTab:CreateToggle({
   Name = "Toggle ESP",
   CurrentValue = false,
   Flag = "ToggleESP", 
   Callback = function(Value)
       ESPEnabled = Value
       Rayfield:Notify({
          Title = "ESP " .. (ESPEnabled and "Enabled" or "Disabled"),
          Content = "ESP and Radar are now " .. (ESPEnabled and "ON" or "OFF"),
          Duration = 3.5,
          Image = nil,
       })
   end,
})

-- Setup ESP for existing players
for _, Player in pairs(Players:GetPlayers()) do
    if Player ~= LocalPlayer then
        CreateESP(Player)
    end
end

-- Listen for new players joining
Players.PlayerAdded:Connect(CreateESP)

-- Listen for players leaving
Players.PlayerRemoving:Connect(RemoveESP)

-- Update loop
RunService.RenderStepped:Connect(UpdateESP)
