-- Garden Horizons: Ascended Edition
-- UI Framework: Fluent (Highly Aesthetic, Draggable, Mobile-Friendly)
-- Optimized for Delta Executor

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

-- 1. Force Landscape Mode for Mobile Users
pcall(function()
    StarterGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeRight
end)
pcall(function()
    LocalPlayer.PlayerGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeRight
end)

-- 2. Load Fluent UI Framework via Raw Link
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Garden Horizons: Ascended",
    SubTitle = "Elite Mod Menu",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 320), -- Scaled nicely for landscape mobile
    Acrylic = false, -- Disabled for better mobile performance/stability
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- PC fallback
})

-- 3. Setup Tabs
local Tabs = {
    Farming = Window:AddTab({ Title = "Farming", Icon = "leaf" }),
    Teleports = Window:AddTab({ Title = "Teleports", Icon = "map-pin" }),
    Character = Window:AddTab({ Title = "Character", Icon = "user" })
}

-- === GAME REMOTES ===
local Remotes = ReplicatedStorage:WaitForChild("RemoteEvents", 5)
local UseGear = Remotes and Remotes:FindFirstChild("UseGear")
local Purchase = Remotes and Remotes:FindFirstChild("PurchaseShopItem")

-- === FARMING TAB ===

local AutoHarvestToggle = Tabs.Farming:AddToggle("AutoHarvest", {
    Title = "Infinite Auto-Harvest",
    Description = "Automatically harvests all fully grown crops on your plot.",
    Default = false
})

AutoHarvestToggle:OnChanged(function()
    _G.AutoHarvest = AutoHarvestToggle.Value
end)

-- Auto-Harvest Background Loop
task.spawn(function()
    while true do
        if _G.AutoHarvest then
            pcall(function()
                local plotsFolder = workspace:FindFirstChild("Plots") or workspace:FindFirstChild("Plot")
                if plotsFolder and UseGear then
                    for _, plot in ipairs(plotsFolder:GetChildren()) do
                        -- Safely verify plot ownership
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
        task.wait(0.5) -- Fast check loop
    end
end)

Tabs.Farming:AddButton({
    Title = "Auto-Buy Carrots",
    Description = "Instantly buys a carrot seed from the shop.",
    Callback = function()
        if Purchase then
            pcall(function() Purchase:InvokeServer("SeedShop", "Carrot") end)
            Fluent:Notify({ Title = "Purchased", Content = "Bought 1 Carrot Seed.", Duration = 2 })
        else
            Fluent:Notify({ Title = "Error", Content = "Purchase remote not found.", Duration = 2 })
        end
    end
})

-- === TELEPORTS TAB ===

Tabs.Teleports:AddButton({
    Title = "Teleport to Sell Station",
    Description = "Instantly travel to the selling area.",
    Callback = function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local target = workspace:FindFirstChild("SellTeleport", true) or workspace:FindFirstChild("Sell", true)
        
        if target and hrp then 
            hrp.CFrame = target.CFrame * CFrame.new(0, 3, 0)
            Fluent:Notify({ Title = "Teleported", Content = "Arrived at Sell Station.", Duration = 2 })
        end
    end
})

Tabs.Teleports:AddButton({
    Title = "Teleport to My Plot",
    Description = "Instantly return to your farm.",
    Callback = function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local plotsFolder = workspace:FindFirstChild("Plots") or workspace:FindFirstChild("Plot")
        if plotsFolder then
            for _, plot in ipairs(plotsFolder:GetChildren()) do
                if plot:GetAttribute("Owner") == LocalPlayer.UserId or (plot:FindFirstChild("Owner") and plot.Owner.Value == LocalPlayer.Name) then
                    hrp.CFrame = plot:GetPivot() * CFrame.new(0, 5, 0)
                    Fluent:Notify({ Title = "Teleported", Content = "Arrived at your Plot.", Duration = 2 })
                    break
                end
            end
        end
    end
})

-- === CHARACTER TAB ===

local SpeedToggle = Tabs.Character:AddToggle("SpeedHack", {
    Title = "Enforced Speed Hack",
    Description = "Forces WalkSpeed to 75, bypassing game resets.",
    Default = false
})

SpeedToggle:OnChanged(function()
    _G.SpeedLoop = SpeedToggle.Value
end)

-- Heartbeat loop to override game's native speed controllers
RunService.Heartbeat:Connect(function()
    if _G.SpeedLoop then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum then
                hum.WalkSpeed = 75
            end
        end)
    end
end)

-- Finalize UI Loading
Window:SelectTab(1)
Fluent:Notify({
    Title = "Ascended Executed",
    Content = "Features loaded successfully.",
    Duration = 5
})
