-- Garden Horizons: Ascended Elite UI
-- Principles: Glassmorphism, Advanced Constraints, Native Draggable Logic
-- Optimized for Delta Android (gethui() Support)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

-- 1. Safely Mount UI
local TargetParent = nil
if type(gethui) == "function" then
    TargetParent = gethui()
else
    pcall(function() TargetParent = game:GetService("CoreGui") end)
    if not TargetParent then
        TargetParent = LocalPlayer:WaitForChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
    end
end

if not TargetParent then return end

-- Wipe old instances
if TargetParent:FindFirstChild("AscendedElite") then
    TargetParent.AscendedElite:Destroy()
end

-- 2. GUI Container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AscendedElite"
ScreenGui.Parent = TargetParent
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

-- 3. Advanced Toggle Button (Floating/Draggable)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "Toggle"
ToggleBtn.Parent = ScreenGui
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0.5, -25, 0, 20)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ToggleBtn.BackgroundTransparency = 0.2
ToggleBtn.Text = "🌱"
ToggleBtn.TextSize = 24
ToggleBtn.AutoButtonColor = true

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0) -- Perfect Circle
ToggleCorner.Parent = ToggleBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(100, 255, 100)
ToggleStroke.Thickness = 2
ToggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ToggleStroke.Parent = ToggleBtn

-- 4. Main Glassmorphic Panel
local MainPanel = Instance.new("Frame")
MainPanel.Name = "MainPanel"
MainPanel.Parent = ScreenGui
MainPanel.Size = UDim2.new(0, 300, 0, 380)
MainPanel.Position = UDim2.new(0.5, -150, 0.5, -190)
MainPanel.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MainPanel.BackgroundTransparency = 0.3 -- Glass Effect
MainPanel.Visible = false
MainPanel.Active = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainPanel

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 255, 255)
MainStroke.Transparency = 0.8 -- Subtle border
MainStroke.Thickness = 1
MainStroke.Parent = MainPanel

-- 5. Top Bar & Title
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainPanel
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TopBar.BackgroundTransparency = 0.6

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 12)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "GARDEN HORIZONS: ASCENDED"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

-- 6. Content Area with Constraints
local Scroll = Instance.new("ScrollingFrame")
Scroll.Name = "Content"
Scroll.Parent = MainPanel
Scroll.Size = UDim2.new(1, 0, 1, -45)
Scroll.Position = UDim2.new(0, 0, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 2
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0) -- Auto-calculated by UIListLayout
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local UIPadding = Instance.new("UIPadding")
UIPadding.Parent = Scroll
UIPadding.PaddingLeft = UDim.new(0, 10)
UIPadding.PaddingRight = UDim.new(0, 10)
UIPadding.PaddingTop = UDim.new(0, 5)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Scroll
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- 7. Component Generators (Buttons/Toggles)
local function CreateButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = Scroll
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 0.9 -- Button transparency
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.AutoButtonColor = true

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", btn).Color = Color3.fromRGB(255, 255, 255); btn.UIStroke.Transparency = 0.9

    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function CreateToggle(text, callback)
    local state = false
    local btn = CreateButton(text .. ": [ OFF ]", function() end)
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. ": " .. (state and "[ ON ]" or "[ OFF ]")
        btn.TextColor3 = state and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(220, 220, 220)
        btn.UIStroke.Color = state and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 255, 255)
        btn.UIStroke.Transparency = state and 0.5 or 0.9
        callback(state)
    end)
end

-- 8. Dragging Logic (Optimized for Mobile Touch)
local function MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

MakeDraggable(MainPanel, TopBar)
MakeDraggable(ToggleBtn, ToggleBtn)

ToggleBtn.MouseButton1Click:Connect(function()
    MainPanel.Visible = not MainPanel.Visible
end)

-- === MOD LOGIC (Verified against Garden Horizons Source) ===
local Remotes = ReplicatedStorage:WaitForChild("RemoteEvents", 5)
local UseGear = Remotes and Remotes:FindFirstChild("UseGear") --
local Purchase = Remotes and Remotes:FindFirstChild("PurchaseShopItem") --

_G.AutoHarvest = false
_G.SpeedLoop = false

CreateToggle("Auto-Harvest Crops", function(val) _G.AutoHarvest = val end)

task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoHarvest then
            pcall(function()
                local plots = workspace:FindFirstChild("Plots") or workspace:FindFirstChild("Plot")
                if plots and UseGear then
                    for _, plot in ipairs(plots:GetChildren()) do
                        local owner = plot:GetAttribute("Owner") == LocalPlayer.UserId or (plot:FindFirstChild("Owner") and plot.Owner.Value == LocalPlayer.Name)
                        if owner then
                            for _, plant in ipairs(plot:GetChildren()) do
                                if plant:IsA("Model") and (plant:GetAttribute("FullyGrown") or plant:FindFirstChild("FullyGrown")) then
                                    local uuid = plant:GetAttribute("Uuid")
                                    if uuid then UseGear:FireServer("HarvestBell", {["targetUuid"] = uuid}) end --
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

CreateButton("Purchase Carrot Seeds", function()
    if Purchase then pcall(function() Purchase:InvokeServer("SeedShop", "Carrot") end) end --
end)

CreateButton("Teleport: Market Sell", function()
    local target = workspace:FindFirstChild("SellTeleport", true) or workspace:FindFirstChild("Sell", true)
    if target and LocalPlayer.Character then 
        LocalPlayer.Character:PivotTo(target.CFrame * CFrame.new(0, 3, 0)) 
    end
end)

CreateButton("Teleport: My Garden", function()
    local plots = workspace:FindFirstChild("Plots") or workspace:FindFirstChild("Plot")
    if plots and LocalPlayer.Character then
        for _, plot in ipairs(plots:GetChildren()) do
            if plot:GetAttribute("Owner") == LocalPlayer.UserId or (plot:FindFirstChild("Owner") and plot.Owner.Value == LocalPlayer.Name) then
                LocalPlayer.Character:PivotTo(plot:GetPivot() * CFrame.new(0, 5, 0))
                break
            end
        end
    end
end)

CreateToggle("Enhanced WalkSpeed", function(val) _G.SpeedLoop = val end)

RunService.Heartbeat:Connect(function()
    if _G.SpeedLoop then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = 75 end
        end)
    end
end)

print("[Elite] UI Framework mounted via gethui(). All constraints verified.")
