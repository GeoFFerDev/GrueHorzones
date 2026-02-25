-- Garden Horizons: Ascended Edition (Fixed & Draggable)
-- Built for Delta Mobile / Landscape

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

-- 1. Force Landscape Mode
pcall(function()
    StarterGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeRight
end)
pcall(function()
    LocalPlayer.PlayerGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeRight
end)

-- 2. Destroy Old UI to prevent duplicates
if LocalPlayer.PlayerGui:FindFirstChild("AscendedHub") then
    LocalPlayer.PlayerGui.AscendedHub:Destroy()
end

-- 3. UI Construction
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AscendedHub"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
MainFrame.Size = UDim2.new(0, 350, 0, 280) -- Fixed reasonable size for landscape
MainFrame.Active = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
TopBar.Size = UDim2.new(1, 0, 0, 35)

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 8)
TopCorner.Parent = TopBar

local TopBarExt = Instance.new("Frame")
TopBarExt.Parent = TopBar
TopBarExt.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
TopBarExt.Size = UDim2.new(1, 0, 0.5, 0)
TopBarExt.Position = UDim2.new(0, 0, 0.5, 0)
TopBarExt.BorderSizePixel = 0

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.Size = UDim2.new(0.8, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.Text = "GH: ASCENDED (Draggable)"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TopBar
CloseBtn.Size = UDim2.new(0, 30, 0, 25)
CloseBtn.Position = UDim2.new(1, -35, 0.5, -12.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- 4. Custom Dragging Logic (Supports Mobile Touch & PC Mouse)
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- 5. Content Area
local Content = Instance.new("ScrollingFrame")
Content.Parent = MainFrame
Content.BackgroundTransparency = 1
Content.Position = UDim2.new(0, 0, 0, 40)
Content.Size = UDim2.new(1, 0, 1, -45)
Content.CanvasSize = UDim2.new(0, 0, 1.5, 0)
Content.ScrollBarThickness = 4
Content.BorderSizePixel = 0

local ListLayout = Instance.new("UIListLayout")
ListLayout.Parent = Content
ListLayout.Padding = UDim.new(0, 6)
ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = Content
    btn.Size = UDim2.new(0.95, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    btn.Text = text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.TextSize = 14
    btn.AutoButtonColor = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- === ROBUST GAME LOGIC & FIXES ===

-- Find Remotes Safely
local function GetRemote(name)
    local remote = ReplicatedStorage:FindFirstChild(name, true)
    if not remote then warn("Could not find remote: " .. name) end
    return remote
end

local UseGear = GetRemote("UseGear")
local Purchase = GetRemote("PurchaseShopItem")

-- Feature: Auto Harvest
_G.AutoHarvest = false
local HarvestBtn = CreateButton("Toggle Auto-Harvest: OFF", function()
    _G.AutoHarvest = not _G.AutoHarvest
    -- Button will update text visually
end)

task.spawn(function()
    while true do
        if _G.AutoHarvest then
            HarvestBtn.Text = "Toggle Auto-Harvest: ON"
            HarvestBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
            
            pcall(function()
                local plotsFolder = workspace:FindFirstChild("Plots") or workspace:FindFirstChild("Plot")
                if plotsFolder then
                    for _, plot in ipairs(plotsFolder:GetChildren()) do
                        -- Checks multiple possible ownership attributes/values
                        local isOwner = plot:GetAttribute("Owner") == LocalPlayer.UserId or (plot:FindFirstChild("Owner") and plot.Owner.Value == LocalPlayer.Name)
                        
                        if isOwner then
                            for _, plant in ipairs(plot:GetChildren()) do
                                if plant:IsA("Model") and (plant:GetAttribute("FullyGrown") == true or plant:FindFirstChild("FullyGrown")) then
                                    local uuid = plant:GetAttribute("Uuid")
                                    if uuid and UseGear then
                                        UseGear:FireServer("HarvestBell", {["targetUuid"] = uuid})
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        else
            if HarvestBtn then 
                HarvestBtn.Text = "Toggle Auto-Harvest: OFF" 
                HarvestBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
            end
        end
        task.wait(0.5) -- Faster checks
    end
end)

-- Feature: Buy Carrots
CreateButton("Auto-Buy Carrots", function()
    if Purchase then
        pcall(function() Purchase:InvokeServer("SeedShop", "Carrot") end)
    end
end)

-- Feature: Fixed Teleports (Bypasses character load issues)
CreateButton("Teleport: Sell Station", function()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 3)
    local target = workspace:FindFirstChild("SellTeleport", true) or workspace:FindFirstChild("Sell", true)
    
    if target and hrp then 
        hrp.CFrame = target.CFrame * CFrame.new(0, 3, 0)
    end
end)

CreateButton("Teleport: My Plot", function()
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
end)

-- Feature: Enforced WalkSpeed (Fixes games that override speed)
_G.FastSpeed = false
local SpeedBtn = CreateButton("Toggle Speed Boost: OFF", function()
    _G.FastSpeed = not _G.FastSpeed
end)

RunService.Heartbeat:Connect(function()
    if _G.FastSpeed then
        SpeedBtn.Text = "Toggle Speed Boost: ON"
        SpeedBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = 75 -- Safe, noticeable speed
        end
    else
        if SpeedBtn then
            SpeedBtn.Text = "Toggle Speed Boost: OFF"
            SpeedBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
        end
    end
end)
