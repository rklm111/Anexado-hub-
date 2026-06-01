-- [[ ANEXADO HUB - ARSENAL EDITION ]] --
-- [[ Compatible with Mobile & PC - Optimized for Arsenal Mechanics ]] --

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Window = Rayfield:CreateWindow({
   Name = "Anexado Hub",
   LoadingTitle = "Loading System...",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "AnexadoConfig",
      FileName = "ArsenalHub"
   },
   Discord = {
      Enabled = false,
      Invite = "",
      RememberJoins = true
   },
   KeySystem = false
})

-- [[ TABS ]] --
local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

-- [[ HUB VARIABLES ]] --
local AimbotEnabled = false
local Smoothness = 1
local TriggerbotEnabled = false
local EspEnabled = false

-- Fly Variables
local FlyEnabled = false
local FlySpeed = 50
local FlyConnection = nil

-- [[ HELPER FUNCTION: GET CLOSEST PLAYER FOR AIMBOT ]] --
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if distance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end
    return closestPlayer
end

-- [[ HELPER FUNCTION: CHECK MOUSE/SCREEN CENTER OVER ENEMY ]] --
local function checkTriggerbotTarget()
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    local raycastResult = workspace:Raycast(Camera.CFrame.Position, Camera.CFrame.LookVector * 500, raycastParams)

    if raycastResult and raycastResult.Instance then
        local hitInstance = raycastResult.Instance
        local model = hitInstance:FindFirstAncestorOfClass("Model")
        if model then
            local player = Players:GetPlayerFromCharacter(model)
            if player and player ~= LocalPlayer and model:FindFirstChildOfClass("Humanoid") and model:FindFirstChildOfClass("Humanoid").Health > 0 then
                if player.Team ~= LocalPlayer.Team or player.Team == nil then
                    return true
                end
            end
        end
    end
    return false
end

-- [[ COMBAT TAB ]] --
CombatTab:CreateSection("Aimbot Settings")

CombatTab:CreateToggle({
   Name = "Enable Aimbot",
   CurrentValue = false,
   Flag = "AimbotToggle",
   Callback = function(Value)
      AimbotEnabled = Value
   end,
})

CombatTab:CreateSlider({
   Name = "Aimbot Smoothness",
   Range = {1, 10},
   Increment = 0.5,
   Suffix = "x",
   CurrentValue = 1,
   Flag = "SmoothnessSlider",
   Callback = function(Value)
      Smoothness = Value
   end,
})

CombatTab:CreateSection("Triggerbot Settings")

CombatTab:CreateToggle({
   Name = "Enable Triggerbot (Auto Shoot)",
   CurrentValue = false,
   Flag = "TriggerbotToggle",
   Callback = function(Value)
      TriggerbotEnabled = Value
   end,
})

-- [[ VISUALS TAB ]] --
VisualsTab:CreateSection("ESP Settings")

VisualsTab:CreateToggle({
   Name = "Enable ESP (Wallhack)",
   CurrentValue = false,
   Flag = "EspToggle",
   Callback = function(Value)
      EspEnabled = Value
      
      if not EspEnabled then
          for _, player in ipairs(Players:GetPlayers()) do
              if player.Character and player.Character:FindFirstChild("HubHighlight") then
                  player.Character.HubHighlight:Destroy()
              end
          end
      end
   end,
})

VisualsTab:CreateSection("Camera Settings")

VisualsTab:CreateSlider({
   Name = "Field of View (FOV)",
   Range = {70, 120},
   Increment = 1,
   Suffix = "°",
   CurrentValue = 70,
   Flag = "FovSlider",
   Callback = function(Value)
      Camera.FieldOfView = Value
   end,
})

-- [[ MISC TAB (FLY FEATURE) ]] --
MiscTab:CreateSection("Movement Utilities")

MiscTab:CreateToggle({
   Name = "Enable Fly (CFrame Mode)",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
      FlyEnabled = Value
      
      if FlyEnabled then
          FlyConnection = RunService.Heartbeat:Connect(function(deltaTime)
              if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                  local hrp = LocalPlayer.Character.HumanoidRootPart
                  local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                  
                  hrp.Velocity = Vector3.new(0, 0, 0)
                  local moveDirection = humanoid.MoveDirection
                  
                  if moveDirection.Magnitude > 0 then
                      hrp.CFrame = hrp.CFrame + (moveDirection * FlySpeed * deltaTime)
                  end
              end
          end)
      else
          if FlyConnection then
              FlyConnection:Disconnect()
              FlyConnection = nil
          end
      end
   end,
})

MiscTab:CreateSlider({
   Name = "Fly Speed",
   Range = {20, 150},
   Increment = 5,
   Suffix = " studs/s",
   CurrentValue = 50,
   Flag = "FlySpeedSlider",
   Callback = function(Value)
      FlySpeed = Value
   end,
})

-- [[ MAIN CORE LOOP ]] --
RunService.RenderStepped:Connect(function()
    -- 1. AIMBOT
    if AimbotEnabled then
        local targetPlayer = getClosestPlayer()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPlayer.Character.Head.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / Smoothness)
        end
    end

    -- 2. TRIGGERBOT
    if TriggerbotEnabled then
        if checkTriggerbotTarget() then
            VirtualInputManager:SendMouseButtonEvent(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2, 0, true, game, 1)
            task.wait(0.01)
            VirtualInputManager:SendMouseButtonEvent(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2, 0, false, game, 1)
        end
    end

    -- 3. ESP NATIVO
    if EspEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local character = player.Character
                local highlight = character:FindFirstChild("HubHighlight")
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                
                if humanoid and humanoid.Health > 0 then
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "HubHighlight"
                        highlight.Parent = character
                        highlight.Adornee = character
                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                        highlight.FillTransparency = 0.5
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.OutlineTransparency = 0
                    end
                else
                    if highlight then highlight:Destroy() end
                end
            end
        end
    end
end)

-- [[ INIT ]] --
Rayfield:Notify({
   Title = "Anexado Hub",
   Content = "Arsenal Module loaded successfully!",
   Duration = 5,
})
