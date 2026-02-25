-- Garden Horizons Mod Script (Rayfield UI Version)
-- Optimized for Delta Executor

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Garden Horizons Hub",
   LoadingTitle = "Injecting Modules...",
   LoadingSubtitle = "Delta Executor Version",
   ConfigurationSaving = {
      Enabled = false,
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true 
   },
   KeySystem = false
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("RemoteEvents", 5)

-- Main Farming Tab
local FarmingTab = Window:CreateTab("Farming", 4483345998)

FarmingTab:CreateToggle({
   Name = "Auto-Harvest All Plots",
   CurrentValue = false,
   Flag = "AutoHarvestTog", 
   Callback = function(Value)
      _G.AutoHarvest = Value
      
      -- Spawns a new thread so it doesn't yield the UI
      task.spawn(function()
          local UseGearRemote = Remotes and Remotes:FindFirstChild("UseGear")
          if not UseGearRemote then
              Rayfield:Notify({Title = "Error", Content = "UseGear remote not found.", Duration = 3})
              return
          end

          while _G.AutoHarvest do
              for _, plot in ipairs(workspace:WaitForChild("Plots"):GetChildren()) do
                  if plot:GetAttribute("Owner") == LocalPlayer.UserId or (plot:FindFirstChild("Owner") and plot.Owner.Value == LocalPlayer.Name) then
                      for _, plant in ipairs(plot:GetChildren()) do
                          if plant:IsA("Model") and plant:GetAttribute("FullyGrown") then
                              local uuid = plant:GetAttribute("Uuid")
                              if uuid then
                                  UseGearRemote:FireServer("HarvestBell", {["targetUuid"] = uuid})
                              end
                          end
                      end
                  end
              end
              task.wait(1)
          end
      end)
   end,
})

-- Teleport Tab
local TeleportTab = Window:CreateTab("Teleports", 4483345998)

TeleportTab:CreateButton({
   Name = "Teleport to Seed Shop",
   Callback = function()
      local target = workspace:FindFirstChild("SeedsTeleport", true)
      if target and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
         LocalPlayer.Character.HumanoidRootPart.CFrame = target.CFrame * CFrame.new(0, 3, 0)
      else
         Rayfield:Notify({Title = "Error", Content = "Location not found or character not loaded.", Duration = 3})
      end
   end,
})

TeleportTab:CreateButton({
   Name = "Teleport to Sell Station",
   Callback = function()
      local target = workspace:FindFirstChild("SellTeleport", true)
      if target and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
         LocalPlayer.Character.HumanoidRootPart.CFrame = target.CFrame * CFrame.new(0, 3, 0)
      end
   end,
})

-- Developer Tools Tab (Upgraded Bypass)
local DevTab = Window:CreateTab("Dev / QA", 4483345998)

DevTab:CreateButton({
   Name = "Force Open QA Panel",
   Callback = function()
      -- 1. Try a deep search in PlayerGui
      local QAGui = LocalPlayer.PlayerGui:FindFirstChild("QA", true) 
      
      -- 2. If not found, check StarterGui and force clone it
      if not QAGui then
          local StarterQA = game:GetService("StarterGui"):FindFirstChild("QA", true)
          if StarterQA then
              QAGui = StarterQA:Clone()
              QAGui.Parent = LocalPlayer.PlayerGui
              Rayfield:Notify({Title = "Cloned", Content = "QA Panel was missing, cloned from StarterGui.", Duration = 3})
          end
      end

      -- 3. Enable the UI if we successfully found/cloned it
      if QAGui and QAGui:IsA("ScreenGui") then
         QAGui.Enabled = true
         -- Deep search for background elements that might be hidden
         local bg = QAGui:FindFirstChild("Background", true) or QAGui:FindFirstChild("BG", true)
         if bg then bg.Visible = true end
         
         Rayfield:Notify({
            Title = "Bypass Success",
            Content = "QA Panel forced open.",
            Duration = 5,
            Image = 4483345998,
         })
      else
         Rayfield:Notify({
            Title = "Critical Failure",
            Content = "QA Panel doesn't exist in the client data at all.",
            Duration = 4,
         })
      end
   end,
})

-- Character Settings Tab
local CharTab = Window:CreateTab("Character", 4483345998)

CharTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 200},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "WalkSpeedSlider", 
   Callback = function(Value)
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
         LocalPlayer.Character.Humanoid.WalkSpeed = Value
      end
   end,
})

Rayfield:LoadConfiguration()
