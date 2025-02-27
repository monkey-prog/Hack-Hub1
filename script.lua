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

-- Notification on script execution
Rayfield:Notify({
   Title = "Script executed!",
   Content = "Have fun!",
   Duration = 4,
   Image = nil,
})

-- Leaderstat modification section
local LeaderstatTab = Window:CreateTab("📊Leaderstats", nil)
local LeaderstatSection = LeaderstatTab:CreateSection("Modify Leaderstats")

-- Variables to store input values
local leaderstatName = ""
local leaderstatValue = 0

-- Input field for leaderstat name
local LeaderstatNameInput = LeaderstatTab:CreateInput({
   Name = "Leaderstat Name",
   PlaceholderText = "Enter leaderstat name (e.g. Cash, Points)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      leaderstatName = Text
   end,
})

-- Input field for leaderstat value
local LeaderstatValueInput = LeaderstatTab:CreateInput({
   Name = "Leaderstat Value",
   PlaceholderText = "Enter amount",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      -- Convert input to number
      leaderstatValue = tonumber(Text) or 0
   end,
})

-- Function to update the leaderstat
local function updateLeaderstat(player, statName, statValue)
    -- Get the leaderstats folder
    local leaderstats = player:FindFirstChild("leaderstats")
    
    if leaderstats then
        -- Check if the specified stat exists
        local stat = leaderstats:FindFirstChild(statName)
        
        if stat then
            -- Update the existing stat
            stat.Value = statValue
            return true
        else
            -- Create a new stat if it doesn't exist
            local newStat
            -- Determine the value type and create appropriate instance
            if type(statValue) == "number" then
                newStat = Instance.new("IntValue")
            elseif type(statValue) == "string" then
                newStat = Instance.new("StringValue")
            else
                return false
            end
            
            newStat.Name = statName
            newStat.Value = statValue
            newStat.Parent = leaderstats
            return true
        end
    else
        -- Create leaderstats folder if it doesn't exist
        local newLeaderstats = Instance.new("Folder")
        newLeaderstats.Name = "leaderstats"
        newLeaderstats.Parent = player
        
        -- Create the new stat
        local newStat
        if type(statValue) == "number" then
            newStat = Instance.new("IntValue")
        elseif type(statValue) == "string" then
            newStat = Instance.new("StringValue")
        else
            return false
        end
        
        newStat.Name = statName
        newStat.Value = statValue
        newStat.Parent = newLeaderstats
        return true
    end
end

-- Button to apply the changes
local UpdateButton = LeaderstatTab:CreateButton({
   Name = "Update Leaderstat",
   Callback = function()
      local player = game.Players.LocalPlayer
      
      if leaderstatName == "" then
         Rayfield:Notify({
            Title = "Error",
            Content = "Please enter a leaderstat name",
            Duration = 3,
         })
         return
      end
      
      local success = updateLeaderstat(player, leaderstatName, leaderstatValue)
      
      if success then
         Rayfield:Notify({
            Title = "Success!",
            Content = leaderstatName .. " set to " .. tostring(leaderstatValue),
            Duration = 3,
         })
      else
         Rayfield:Notify({
            Title = "Error",
            Content = "Failed to update leaderstat",
            Duration = 3,
         })
      end
   end,
})

-- Remote event handler for server-side updates (optional)
-- You may need to set up a RemoteEvent on the server to properly update leaderstats if they're managed server-side
local function setupRemoteEvents()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    -- Create a folder for our remote events if it doesn't exist
    local remoteFolder = ReplicatedStorage:FindFirstChild("AfonsoScriptsRemotes")
    if not remoteFolder then
        remoteFolder = Instance.new("Folder")
        remoteFolder.Name = "AfonsoScriptsRemotes"
        remoteFolder.Parent = ReplicatedStorage
    end
    
    -- Create the remote event if it doesn't exist
    local updateStatRemote = remoteFolder:FindFirstChild("UpdateLeaderstat")
    if not updateStatRemote then
        updateStatRemote = Instance.new("RemoteEvent")
        updateStatRemote.Name = "UpdateLeaderstat"
        updateStatRemote.Parent = remoteFolder
    end
    
    return updateStatRemote
end

-- Set up remote events when the script runs
local updateStatRemote = setupRemoteEvents()

-- Add server-side update button
local ServerUpdateButton = LeaderstatTab:CreateButton({
   Name = "Update Leaderstat (Server)",
   Callback = function()
      if leaderstatName == "" then
         Rayfield:Notify({
            Title = "Error",
            Content = "Please enter a leaderstat name",
            Duration = 3,
         })
         return
      end
      
      -- Fire the remote event to update the stat on the server
      updateStatRemote:FireServer(leaderstatName, leaderstatValue)
      
      Rayfield:Notify({
         Title = "Request Sent",
         Content = "Server update requested for " .. leaderstatName,
         Duration = 3,
      })
   end,
})

-- Add a section for presets
local PresetSection = LeaderstatTab:CreateSection("Presets")

-- Add some preset buttons for common leaderstats
local CashPreset = LeaderstatTab:CreateButton({
   Name = "Set Cash to 10000",
   Callback = function()
      local player = game.Players.LocalPlayer
      updateLeaderstat(player, "Cash", 10000)
      Rayfield:Notify({
         Title = "Success!",
         Content = "Cash set to 10000",
         Duration = 3,
      })
   end,
})

local PointsPreset = LeaderstatTab:CreateButton({
   Name = "Set Points to 500",
   Callback = function()
      local player = game.Players.LocalPlayer
      updateLeaderstat(player, "Points", 500)
      Rayfield:Notify({
         Title = "Success!",
         Content = "Points set to 500",
         Duration = 3,
      })
   end,
})

-- Information section
local InfoSection = LeaderstatTab:CreateSection("Information")

LeaderstatTab:CreateParagraph({
   Title = "How to Use",
   Content = "1. Enter the name of the leaderstat you want to modify\n2. Enter the value you want to set\n3. Click 'Update Leaderstat' button\n\nNote: Some games may have server-sided leaderstats that cannot be modified directly. Use the Server button to attempt server-side updates."
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
