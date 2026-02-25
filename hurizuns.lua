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

-- Developer Tools Tab
local DevTab = Window:CreateTab("Dev / QA", 4483345998)

DevTab:CreateButton({
   Name = "Force Open QA Panel",
   Callback = function()
      local QAGui = LocalPlayer.PlayerGui:FindFirstChild("QA")
      if QAGui then
         QAGui.Enabled = true
         if QAGui:FindFirstChild("Background") then
             QAGui.Background.Visible = true
         end
         Rayfield:Notify({
            Title = "Bypass Success",
            Content = "QA Panel enabled.",
            Duration = 5,
            Image = 4483345998,
         })
      else
         Rayfield:Notify({
            Title = "Failed",
            Content = "QA Panel GUI not found in PlayerGui.",
            Duration = 3,
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
