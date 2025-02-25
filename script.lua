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
        Box.Thickness = 2
        Box.Color = BoxColor
        Box.Filled = false
        Box.Transparency = 1
        Box.Visible = false

        local Line = Drawing.new("Line")
        Line.Thickness = 1.5
        Line.Color = LineColor
        Line.Transparency = 1
        Line.Visible = false

        local Text = Drawing.new("Text")
        Text.Size = 14
        Text.Color = Color3.fromRGB(255, 255, 255) -- White text
        Text.Center = true
        Text.Outline = true
        Text.OutlineColor = Color3.fromRGB(0, 0, 0) -- Black outline for better visibility
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

-- Function to properly calculate character size for box dimensions
local function CalculateBoxDimensions(Character, ScreenPos, Distance)
    if not Character then return Vector2.new(40, 60) end -- Default size if character not available
    
    -- Get the head and root parts for more accurate calculations
    local Head = Character:FindFirstChild("Head")
    local Root = Character:FindFirstChild("HumanoidRootPart")
    
    if not Head or not Root then
        -- Use distance-based scaling with fixed ratio if parts aren't available
        local scaleFactor = 1 / (Distance * 0.05 + 1)
        local height = math.max(40, 70 * scaleFactor)
        local width = height * 0.5
        return Vector2.new(width, height)
    end
    
    -- Get screen positions of top (head) and bottom (root) of the character
    local headPos = Camera:WorldToViewportPoint(Head.Position + Vector3.new(0, 0.5, 0))
    local rootPos = Camera:WorldToViewportPoint(Root.Position - Vector3.new(0, 2.5, 0))
    
    -- Calculate height using vertical distance between head and root on screen
    local height = math.abs(headPos.Y - rootPos.Y)
    
    -- Ensure minimum size for visibility at distance
    height = math.max(40, height)
    
    -- Calculate width maintaining human body aspect ratio (approximately 1:2.5)
    local width = height * 0.4
    
    return Vector2.new(width, height)
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
            
            -- Calculate box dimensions based on character properties and distance
            local BoxDimensions = CalculateBoxDimensions(Player.Character, ScreenPos, Distance)
            
            -- Set box position correctly centered on the character
            Data.Box.Size = BoxDimensions
            Data.Box.Position = Vector2.new(
                ScreenPos.X - (BoxDimensions.X / 2),
                ScreenPos.Y - (BoxDimensions.Y / 2)
            )
            
            -- Update visibility based on whether the player is on screen
            Data.Box.Visible = OnScreen
            
            -- Update team colors
            local teamName = Player.Team and Player.Team.Name or "Neutral"
            local correctLineColor = TeamColors[teamName] or Color3.fromRGB(255, 255, 255)
            Data.Line.Color = correctLineColor
            Data.RadarDot.Color = correctLineColor

            -- ESP Line
            Data.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y - 50)
            Data.Line.To = Vector2.new(ScreenPos.X, ScreenPos.Y)
            Data.Line.Visible = OnScreen

            -- ESP Text (positioned above the box)
            Data.Text.Text = string.format("%d M | %s | %d HP", Distance, Player.DisplayName, math.floor(Humanoid.Health))
            Data.Text.Position = Vector2.new(ScreenPos.X, ScreenPos.Y - (BoxDimensions.Y / 2) - 15)
            Data.Text.Visible = OnScreen

            -- Radar Logic
            local LocalHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if LocalHRP then
                -- Get 2D position for radar (using top-down view, so X and Z components)
                local RelativePosition = (HRP.Position - LocalHRP.Position) / RadarScale
                
                -- Calculate yaw angle from LocalPlayer to convert positions correctly
                local lookAngle = math.atan2(LocalHRP.CFrame.LookVector.X, LocalHRP.CFrame.LookVector.Z)
                
                -- Rotate position for radar (so forward is always up on radar)
                local rotatedX = RelativePosition.X * math.cos(lookAngle) - RelativePosition.Z * math.sin(lookAngle)
                local rotatedZ = RelativePosition.X * math.sin(lookAngle) + RelativePosition.Z * math.cos(lookAngle)
                
                -- Calculate radar position and clamp to radar bounds
                local RadarX = math.clamp(RadarSize / 2 + rotatedX, 5, RadarSize - 5)
                local RadarY = math.clamp(RadarSize / 2 - rotatedZ, 5, RadarSize - 5)
                
                Data.RadarDot.Position = RadarPosition + Vector2.new(RadarX, RadarY)
                Data.RadarDot.Visible = true
            else
                Data.RadarDot.Visible = false
            end
        else
            -- Hide ESP if player character is not available
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

-- Fully Automatic Aimbot System
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Aimbot Configuration
local AimbotSettings = {
    Enabled = false,            -- Toggle state
    TargetPart = "Head",        -- Body part to target (default)
    TeamCheck = true,           -- Skip teammates
    VisibilityCheck = true,     -- Check if target is visible
    MaxDistance = 200,          -- Maximum targeting distance (in studs)
    PriorityDistance = 100,     -- Distance to prioritize visible targets
    WallTargetDistance = 50,    -- Distance to still target players behind walls
    AlwaysActive = true,        -- No need to press aim key
    InstantTrack = true,        -- Instant tracking (no smoothing)
    FOVRadius = 500,            -- Increased FOV circle size for better acquisition
    ShowFOV = true,             -- Show FOV circle
    IgnorePlayers = {},         -- List of players to ignore
    TargetPriority = "Closest"  -- Target priority method: "Closest", "LowestHealth", "HighestThreat"
}

-- Drawing objects
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7
FOVCircle.NumSides = 64
FOVCircle.Radius = AimbotSettings.FOVRadius
FOVCircle.Visible = false

-- Variables
local CurrentTarget = nil
local LastTargetTime = 0
local TargetAcquired = false
local TargetLockDuration = 1.5 -- Duration to lock onto a target (in seconds)

-- Function to check if a point is visible
local function IsVisible(Position, Target)
    if not AimbotSettings.VisibilityCheck then return true end
    
    local Origin = Camera.CFrame.Position
    local Direction = (Position - Origin).Unit * AimbotSettings.MaxDistance
    
    local RaycastParams = RaycastParams.new()
    RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    RaycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Target}
    
    local Result = workspace:Raycast(Origin, Direction, RaycastParams)
    return Result == nil
end

-- Function to find all valid targets
local function GetValidTargets()
    local ValidTargets = {}
    
    for _, Player in pairs(Players:GetPlayers()) do
        if Player == LocalPlayer then continue end
        if table.find(AimbotSettings.IgnorePlayers, Player.Name) then continue end
        
        -- Team check
        if AimbotSettings.TeamCheck and Player.Team == LocalPlayer.Team then continue end
        
        -- Character checks
        if not Player.Character or not Player.Character:FindFirstChild("Humanoid") then continue end
        if Player.Character.Humanoid.Health <= 0 then continue end
        
        -- Target part check
        local TargetPart = Player.Character:FindFirstChild(AimbotSettings.TargetPart)
        if not TargetPart then 
            -- Fallback to HumanoidRootPart if the target part doesn't exist
            TargetPart = Player.Character:FindFirstChild("HumanoidRootPart")
            if not TargetPart then continue end
        end
        
        -- Distance check
        local Distance = (TargetPart.Position - Camera.CFrame.Position).Magnitude
        if Distance > AimbotSettings.MaxDistance then continue end
        
        -- Visibility check
        local IsTargetVisible = IsVisible(TargetPart.Position, Player.Character)
        
        -- Prioritize visible targets within priority distance
        if IsTargetVisible or Distance <= AimbotSettings.WallTargetDistance then
            -- Calculate threat level (customizable)
            local ThreatLevel = 0
            
            -- Basic threat calculation based on distance and visibility
            if IsTargetVisible then
                ThreatLevel = ThreatLevel + 10
            end
            
            if Distance <= 25 then
                ThreatLevel = ThreatLevel + 20
            elseif Distance <= 50 then
                ThreatLevel = ThreatLevel + 10
            elseif Distance <= 100 then
                ThreatLevel = ThreatLevel + 5
            end
            
            -- Add to valid targets
            table.insert(ValidTargets, {
                Player = Player,
                Distance = Distance,
                Health = Player.Character.Humanoid.Health,
                TargetPart = TargetPart,
                Visible = IsTargetVisible,
                ThreatLevel = ThreatLevel
            })
        end
    end
    
    return ValidTargets
end

-- Function to get best target based on priority method
local function GetBestTarget()
    local ValidTargets = GetValidTargets()
    if #ValidTargets == 0 then return nil end
    
    -- Sort targets based on priority method
    if AimbotSettings.TargetPriority == "Closest" then
        table.sort(ValidTargets, function(a, b)
            -- Prioritize close and visible targets
            if a.Visible and not b.Visible then
                return true
            elseif not a.Visible and b.Visible then
                return false
            else
                return a.Distance < b.Distance
            end
        end)
    elseif AimbotSettings.TargetPriority == "LowestHealth" then
        table.sort(ValidTargets, function(a, b)
            return a.Health < b.Health
        end)
    elseif AimbotSettings.TargetPriority == "HighestThreat" then
        table.sort(ValidTargets, function(a, b)
            return a.ThreatLevel > b.ThreatLevel
        end)
    end
    
    -- Maintain target lock for a period to prevent rapid switching
    if CurrentTarget and time() - LastTargetTime < TargetLockDuration then
        -- Check if current target is still valid
        for _, Target in ipairs(ValidTargets) do
            if Target.Player == CurrentTarget then
                return CurrentTarget
            end
        end
    end
    
    -- Return the best target
    LastTargetTime = time()
    return ValidTargets[1].Player
end

-- Function to aim at a target
local function AimAt(Target)
    if not Target or not Target.Character then return end
    
    local TargetPart = Target.Character:FindFirstChild(AimbotSettings.TargetPart)
    if not TargetPart then
        -- Fallback to HumanoidRootPart if the target part doesn't exist
        TargetPart = Target.Character:FindFirstChild("HumanoidRootPart")
        if not TargetPart then return end
    end
    
    local TargetPosition = TargetPart.Position
    
    -- Add prediction for moving targets
    if Target.Character:FindFirstChild("HumanoidRootPart") then
        local Velocity = Target.Character.HumanoidRootPart.Velocity
        TargetPosition = TargetPosition + (Velocity * 0.05) -- Basic prediction factor
    end
    
    -- Calculate the direction
    local TargetCFrame = CFrame.lookAt(Camera.CFrame.Position, TargetPosition)
    
    -- Instant tracking mode
    if AimbotSettings.InstantTrack then
        Camera.CFrame = TargetCFrame
    else
        -- Fallback to smooth tracking if instant is disabled
        local LerpFactor = 0.5 -- Smoothness factor
        Camera.CFrame = Camera.CFrame:Lerp(TargetCFrame, LerpFactor)
    end
    
    TargetAcquired = true
end

-- Toggle the aimbot
local function ToggleAimbot(Value)
    AimbotSettings.Enabled = Value
    
    -- Update FOV circle
    FOVCircle.Visible = Value and AimbotSettings.ShowFOV
    
    -- Reset target when disabling
    if not Value then
        CurrentTarget = nil
        TargetAcquired = false
    end
    
    -- Notification
    Rayfield:Notify({
        Title = "Aimbot " .. (Value and "Enabled" or "Disabled"),
        Content = "Aimbot is now " .. (Value and "ON" or "OFF"),
        Duration = 3,
        Image = nil,
    })
end

-- Main aimbot logic - runs every frame
RunService.RenderStepped:Connect(function()
    -- Update FOV circle
    if AimbotSettings.ShowFOV and AimbotSettings.Enabled then
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = AimbotSettings.FOVRadius
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
    
    -- Handle aimbot logic
    if AimbotSettings.Enabled and AimbotSettings.AlwaysActive then
        -- Get best target
        local Target = GetBestTarget()
        
        -- Update current target
        if Target then
            CurrentTarget = Target
            AimAt(CurrentTarget)
        else
            TargetAcquired = false
        end
    end
end)

-- Create the aimbot toggle in the MainTab
local AimbotToggle = MainTab:CreateToggle({
    Name = "Toggle Aimbot",
    CurrentValue = false,
    Flag = "ToggleAimbot", 
    Callback = function(Value)
        ToggleAimbot(Value)
    end,
})

-- Add always active toggle
local AlwaysActiveToggle = MainTab:CreateToggle({
    Name = "Always Active (No Key Required)",
    CurrentValue = true,
    Flag = "AlwaysActive",
    Callback = function(Value)
        AimbotSettings.AlwaysActive = Value
    end,
})

-- Add instant tracking toggle
local InstantTrackToggle = MainTab:CreateToggle({
    Name = "Instant Tracking",
    CurrentValue = true,
    Flag = "InstantTracking",
    Callback = function(Value)
        AimbotSettings.InstantTrack = Value
    end,
})

-- Target priority dropdown
local PriorityDropdown = MainTab:CreateDropdown({
    Name = "Target Priority",
    Options = {"Closest", "LowestHealth", "HighestThreat"},
    CurrentOption = "Closest",
    Flag = "TargetPriority",
    Callback = function(Option)
        AimbotSettings.TargetPriority = Option
    end,
})

-- Target part dropdown
local TargetPartDropdown = MainTab:CreateDropdown({
    Name = "Target Part",
    Options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
    CurrentOption = "Head",
    Flag = "TargetPart",
    Callback = function(Option)
        AimbotSettings.TargetPart = Option
    end,
})

-- Add maximum distance slider
local MaxDistanceSlider = MainTab:CreateSlider({
    Name = "Maximum Distance",
    Range = {50, 500},
    Increment = 10,
    Suffix = "m",
    CurrentValue = 200,
    Flag = "MaxDistance",
    Callback = function(Value)
        AimbotSettings.MaxDistance = Value
    end,
})

-- FOV radius slider
local FOVRadiusSlider = MainTab:CreateSlider({
    Name = "FOV Radius",
    Range = {100, 1000},
    Increment = 50,
    Suffix = "px",
    CurrentValue = 500,
    Flag = "FOVRadius",
    Callback = function(Value)
        AimbotSettings.FOVRadius = Value
    end,
})

-- Team check toggle
local TeamCheckToggle = MainTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Flag = "TeamCheck",
    Callback = function(Value)
        AimbotSettings.TeamCheck = Value
    end,
})

-- Show FOV circle toggle
local ShowFOVToggle = MainTab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = true,
    Flag = "ShowFOV",
    Callback = function(Value)
        AimbotSettings.ShowFOV = Value
    end,
})

-- Visibility check toggle
local VisibilityCheckToggle = MainTab:CreateToggle({
    Name = "Visibility Check",
    CurrentValue = true,
    Flag = "VisibilityCheck",
    Callback = function(Value)
        AimbotSettings.VisibilityCheck = Value
    end,
})

local TeleportTab = Window:CreateTab("🌀Teleport", nil) -- Title, Image
local TeleportSection = TeleportTab:CreateSection("Teleport")

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
