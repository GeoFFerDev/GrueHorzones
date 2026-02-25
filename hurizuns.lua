-- Garden Horizons Powerful Mod Script
-- Designed for Delta Executor
-- Features: Auto-Harvest, Shop Teleports, QA Panel Bypass, WalkSpeed/JumpPower

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/7Lib/UI-Libraries/main/Orion/Source.lua"))()
local Window = Library:MakeWindow({Name = "Garden Horizons Exploiter", HidePremium = false, SaveConfig = true, ConfigFolder = "GardenHorizons"})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("RemoteEvents")
local UseGearRemote = Remotes:WaitForChild("UseGear") -- 

-- Main Tab
local MainTab = Window:MakeTab({
	Name = "Main",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

-- Auto Harvest Logic
-- Based on HarvestBellController [cite: 42873, 42876]
MainTab:AddToggle({
	Name = "Auto-Harvest All Plots",
	Default = false,
	Callback = function(Value)
		_G.AutoHarvest = Value
		while _G.AutoHarvest do
			for _, plot in ipairs(workspace:WaitForChild("Plots"):GetChildren()) do
				if plot:GetAttribute("Owner") == LocalPlayer.UserId or plot:FindFirstChild("Owner") and plot.Owner.Value == LocalPlayer.Name then
					for _, plant in ipairs(plot:GetChildren()) do
						if plant:IsA("Model") and plant:GetAttribute("FullyGrown") then
							local uuid = plant:GetAttribute("Uuid")
							if uuid then
								-- Fire the Gear Use remote as if using the HarvestBell 
								UseGearRemote:FireServer("HarvestBell", {["targetUuid"] = uuid})
							end
						end
					end
				end
			end
			task.wait(1)
		end
	end    
})

-- Teleport Tab
local TeleTab = Window:MakeTab({
	Name = "Teleports",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

TeleTab:AddButton({
	Name = "Teleport to Seed Shop",
	Callback = function()
		local target = workspace:FindFirstChild("SeedsTeleport", true) -- [cite: 45702]
		if target and LocalPlayer.Character then
			LocalPlayer.Character.HumanoidRootPart.CFrame = target.CFrame * CFrame.new(0, 3, 0)
		end
	end    
})

TeleTab:AddButton({
	Name = "Teleport to Sell Station",
	Callback = function()
		local target = workspace:FindFirstChild("SellTeleport", true) -- [cite: 45704]
		if target and LocalPlayer.Character then
			LocalPlayer.Character.HumanoidRootPart.CFrame = target.CFrame * CFrame.new(0, 3, 0)
		end
	end    
})

-- Developer/QA Tab
local DevTab = Window:MakeTab({
	Name = "Dev Tools",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

-- QA Panel Bypass [cite: 51122, 51108]
DevTab:AddButton({
	Name = "Force Open QA Panel",
	Callback = function()
		local QAGui = LocalPlayer.PlayerGui:FindFirstChild("QA")
		if QAGui then
			QAGui.Enabled = true
			QAGui.Background.Visible = true
			Library:MakeNotification({
				Name = "Bypass Success",
				Content = "QA Panel enabled. Use carefully!",
				Image = "rbxassetid://4483345998",
				Time = 5
			})
		else
			warn("QA Panel not found in PlayerGui")
		end
	end    
})

-- Character Settings
local CharTab = Window:MakeTab({
	Name = "Character",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

CharTab:AddSlider({
	Name = "WalkSpeed",
	Min = 16,
	Max = 200,
	Default = 16,
	Color = Color3.fromRGB(255,255,255),
	Increment = 1,
	ValueName = "Speed",
	Callback = function(Value)
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			LocalPlayer.Character.Humanoid.WalkSpeed = Value
		end
	end    
})

Library:Init()
