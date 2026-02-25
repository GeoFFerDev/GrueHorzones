-- Garden Horizons: Ascended Edition
-- UI Framework: Orion (Native PC & Mobile Support)
-- Optimized for Delta Android

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

-- Force Landscape for Mobile
pcall(function()
    StarterGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeRight
end)
pcall(function()
    LocalPlayer.PlayerGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeRight
end)

-- Load Orion Library via Raw GitHub Link
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexsoftware/Orion/main/source')))()

-- Create the Window
-- Orion automatically handles Mobile minimizing. When you press the '_' (minimize) button, 
-- it turns into a draggable Orion logo on your screen to reopen it.
local Window = OrionLib:MakeWindow({
    Name = "Garden Horizons: Ascended",
    HidePremium = true,
    SaveConfig = false,
    ConfigFolder = "AscendedGH",
    IntroEnabled = true,
    IntroText = "Loading Ascended..."
})

-- === GAME REMOTES ===
local Remotes = ReplicatedStorage:WaitForChild("RemoteEvents", 5)
local UseGear = Remotes and Remotes:FindFirstChild("UseGear")
local Purchase = Remotes and Remotes:FindFirstChild("PurchaseShopItem")

-- === TABS ===
local FarmTab = Window:MakeTab({
    Name = "Farming",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local TeleTab = Window:MakeTab({
    Name = "Teleports",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local CharTab = Window:MakeTab({
    Name = "Character",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- === FARMING LOGIC ===
_G.AutoHarvest = false

FarmTab:AddToggle({
    Name = "Infinite Auto-Harvest",
    Default = false,
    Callback = function(Value)
        _G.AutoHarvest = Value
    end    
})

-- Background Harvesting Loop
task.spawn(function()
    while true do
        if _G.AutoHarvest then
            pcall(function()
                local plotsFolder = workspace:FindFirstChild("Plots") or workspace:FindFirstChild("Plot")
                if plotsFolder and UseGear then
                    for _, plot in ipairs(plotsFolder:GetChildren()) do
                        local isOwner = plot:GetAttribute("Owner") == LocalPlayer.UserId or (plot:FindFirstChild("Owner") and plot.Owner.Value == LocalPlayer.Name)
                        if isOwner then
                            for _, plant in ipairs(plot:GetChildren()) do
                                if plant:IsA("Model") and (plant:GetAttribute("FullyGrown") == true or plant:FindFirstChild("FullyGrown")) then
                                    local uuid = plant:GetAttribute("Uuid")
                                    if uuid then
                                        UseGear:FireServer("HarvestBell", {["targetUuid"] = uuid})
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

FarmTab:AddButton({
    Name = "Auto-Buy Carrots",
    Callback = function()
        if Purchase then
            pcall(function() Purchase:InvokeServer("SeedShop", "Carrot") end)
            OrionLib:MakeNotification({
                Name = "Purchased",
                Content = "Bought 1 Carrot Seed.",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end    
})

-- === TELEPORTS LOGIC ===
TeleTab:AddButton({
    Name = "Teleport to Sell Station",
    Callback = function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local target = workspace:FindFirstChild("SellTeleport", true) or workspace:FindFirstChild("Sell", true)
        if target and hrp then 
            hrp.CFrame = target.CFrame * CFrame.new(0, 3, 0)
        end
    end    
})

TeleTab:AddButton({
    Name = "Teleport to My Plot",
    Callback = function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local plotsFolder = workspace:FindFirstChild("Plots") or workspace:FindFirstChild("Plot")
        if plotsFolder then
            for _, plot in ipairs(plotsFolder:GetChildren()) do
                if plot:GetAttribute("Owner") == LocalPlayer.UserId or (plot:FindFirstChild("Owner") and plot.Owner.Value == LocalPlayer.Name) then
                    hrp.CFrame = plot:GetPivot() * CFrame.new(0, 5, 0)
                    break
                end
            end
        end
    end    
})

-- === CHARACTER LOGIC ===
_G.SpeedLoop = false

CharTab:AddToggle({
    Name = "Enforced Speed Hack (75)",
    Default = false,
    Callback = function(Value)
        _G.SpeedLoop = Value
    end    
})

RunService.Heartbeat:Connect(function()
    if _G.SpeedLoop then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = 75 end
        end)
    end
end)

-- Initialize UI
OrionLib:Init()
