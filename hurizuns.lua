-- Garden Horizons Mobile "Ascended" Script v3
-- Revamped UI with Logical Grouping & Clean Layout

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

-- Force Landscape for Mobile
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            StarterGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeRight
        end)
    end
end)

-- Destroy old UI if it exists
if LocalPlayer.PlayerGui:FindFirstChild("AscendedHub") then
    LocalPlayer.PlayerGui.AscendedHub:Destroy()
end

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AscendedHub"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

-- Main Container (Responsive landscape sizing)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
MainFrame.Size = UDim2.new(0.35, 0, 0.8, 0) -- 35% width, 80% height

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Top Bar (Title & Close Button)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TopBar.Size = UDim2.new(1, 0, 0.12, 0)

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = TopBar

-- Hide bottom corners of top bar to blend with main frame
local TopBarExtension = Instance.new("Frame")
TopBarExtension.Parent = TopBar
TopBarExtension.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TopBarExtension.Size = UDim2.new(1, 0, 0.5, 0)
TopBarExtension.Position = UDim2.new(0, 0, 0.5, 0)
TopBarExtension.BorderSizePixel = 0

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.Size = UDim2.new(0.8, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.Text = "GH: ASCENDED"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.TextScaled = true
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TopBar
CloseBtn.Size = UDim2.new(0.15, 0, 0.8, 0)
CloseBtn.Position = UDim2.new(0.82, 0, 0.1, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextScaled = true
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Scrolling Content Frame
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "Content"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 0, 0.15, 0)
ContentFrame.Size = UDim2.new(1, 0, 0.85, 0)
ContentFrame.CanvasSize = UDim2.new(0, 0, 2, 0) -- Scrollable height
ContentFrame.ScrollBarThickness = 4
ContentFrame.BorderSizePixel = 0

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ContentFrame
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local UIPadding = Instance.new("UIPadding")
UIPadding.Parent = ContentFrame
UIPadding.PaddingLeft = UDim.new(0, 10)
UIPadding.PaddingRight = UDim.new(0, 10)
UIPadding.PaddingTop = UDim.new(0, 5)

-- UI Element Generators
local LayoutOrderCount = 0
local function GetOrder() LayoutOrderCount = LayoutOrderCount + 1 return LayoutOrderCount end

local function CreateSection(name)
    local SectionLabel = Instance.new("TextLabel")
    SectionLabel.Parent = ContentFrame
    SectionLabel.Size = UDim2.new(1, 0, 0, 25)
    SectionLabel.Text = "  " .. name
    SectionLabel.Font = Enum.Font.GothamBold
    SectionLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    SectionLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    SectionLabel.TextSize = 14
    SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    SectionLabel.LayoutOrder = GetOrder()
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = SectionLabel
end

local function CreateButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = ContentFrame
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    btn.Text = text
    btn.Font = Enum.Font.Gotham
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.LayoutOrder = GetOrder()
    btn.MouseButton1Click:Connect(callback)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
end

-- === LOGIC & REMOTES ===
local Remotes = ReplicatedStorage:WaitForChild("RemoteEvents")
local UseGear = Remotes:WaitForChild("UseGear")
local Purchase = Remotes:WaitForChild("PurchaseShopItem")
_G.AutoHarvest = false

-- === UI POPULATION ===

CreateSection("🌱 Farming Automation")

CreateButton("Toggle Auto-Harvest", function()
    _G.AutoHarvest = not _G.AutoHarvest
    print("AutoHarvest status: ", _G.AutoHarvest)
end)

CreateButton("Auto-Buy Carrots", function()
    Purchase:InvokeServer("SeedShop", "Carrot")
    print("Bought Carrots")
end)

CreateSection("📍 Teleports")

CreateButton("Teleport: Sell Station", function()
    local target = workspace:FindFirstChild("SellTeleport", true)
    if target and LocalPlayer.Character then 
        LocalPlayer.Character.HumanoidRootPart.CFrame = target.CFrame * CFrame.new(0,3,0)
    end
end)

CreateButton("Teleport: My Plot", function()
    for _, plot in ipairs(workspace.Plots:GetChildren()) do
        if plot:GetAttribute("Owner") == LocalPlayer.UserId and LocalPlayer.Character then
            LocalPlayer.Character.HumanoidRootPart.CFrame = plot:GetPivot() * CFrame.new(0, 3, 0)
        end
    end
end)

CreateSection("🏃 Character")

CreateButton("Set Speed to 100", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 100
    end
end)

-- Background Auto-Harvest Loop
task.spawn(function()
    while true do
        if _G.AutoHarvest then
            for _, plot in ipairs(workspace.Plots:GetChildren()) do
                if plot:GetAttribute("Owner") == LocalPlayer.UserId then
                    for _, plant in ipairs(plot:GetChildren()) do
                        if plant:IsA("Model") and plant:GetAttribute("FullyGrown") then
                            local uuid = plant:GetAttribute("Uuid")
                            if uuid then
                                UseGear:FireServer("HarvestBell", {["targetUuid"] = uuid})
                            end
                        end
                    end
                end
            end
        end
        task.wait(1)
    end
end)
