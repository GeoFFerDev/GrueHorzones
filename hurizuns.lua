-- Garden Horizons: Ascended (Final Local Build)
-- Uses gethui() mounting to bypass Delta Android silent crashes.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- 1. Safely Find UI Parent (The Diagnostic Fix)
local TargetParent = nil
if type(gethui) == "function" then
    TargetParent = gethui()
else
    pcall(function() TargetParent = game:GetService("CoreGui") end)
    if not TargetParent then
        TargetParent = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
    end
end

if not TargetParent then return end

-- 2. Wipe old instances
if TargetParent:FindFirstChild("AbsoluteHub") then
    TargetParent.AbsoluteHub:Destroy()
end

-- 3. Create the GUI Framework
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AbsoluteHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = TargetParent

-- Floating Mobile Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ScreenGui
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Position = UDim2.new(0.5, -22, 0, 15)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
ToggleBtn.Text = "🌱"
ToggleBtn.TextSize = 25
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = ToggleBtn
UIStroke.Color = Color3.fromRGB(100, 255, 100)
UIStroke.Thickness = 2

-- Make Toggle Draggable
local draggingToggle, dragInputToggle, dragStartToggle, startPosToggle
ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingToggle = true
        dragStartToggle = input.Position
        startPosToggle = ToggleBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then draggingToggle = false end
        end)
    end
end)
ToggleBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInputToggle = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInputToggle and draggingToggle then
        local delta = input.Position - dragStartToggle
        ToggleBtn.Position = UDim2.new(startPosToggle.X.Scale, startPosToggle.X.Offset + delta.X, startPosToggle.Y.Scale, startPosToggle.Y.Offset + delta.Y)
    end
end)

-- Main Mod Panel (Hidden initially)
local MainPanel = Instance.new("Frame")
MainPanel.Parent = ScreenGui
MainPanel.Size = UDim2.new(0, 260, 0, 320)
MainPanel.Position = UDim2.new(0.5, -130, 0.5, -160)
MainPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainPanel.Visible = false
MainPanel.Active = true
Instance.new("UICorner", MainPanel).CornerRadius = UDim.new(0, 8)

-- Make Panel Draggable
local TopBar = Instance.new("Frame", MainPanel)
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -10, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "GH: ASCENDED"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainPanel.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
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
        local delta = input.Position - dragStart
        MainPanel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Toggle Menu Logic
ToggleBtn.MouseButton1Click:Connect(function()
    if not draggingToggle then -- Only open if we aren't dragging it
        MainPanel.Visible = not MainPanel.Visible
    end
end)

local Scroll = Instance.new("ScrollingFrame", MainPanel)
Scroll.Size = UDim2.new(1, -10, 1, -45)
Scroll.Position = UDim2.new(0, 5, 0, 40)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 2
Scroll.CanvasSize = UDim2.new(0, 0, 1.5, 0)
Scroll.BorderSizePixel = 0

local ListLayout = Instance.new("UIListLayout", Scroll)
ListLayout.Padding = UDim.new(0, 6)

-- 4. UI Component Generators
local function CreateButton(text, callback)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(1, -5, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function CreateToggle(text, defaultState, callback)
    local state = defaultState
    local btn = CreateButton(text .. ": " .. (state and "ON" or "OFF"), function() end)
    if state then btn.TextColor3 = Color3.fromRGB(100, 255, 100) end
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. ": " .. (state and "ON" or "OFF")
        btn.TextColor3 = state and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(220, 220, 220)
        callback(state)
    end)
end

-- === MOD LOGIC ===
local Remotes = ReplicatedStorage:WaitForChild("RemoteEvents", 5)
local UseGear = Remotes and Remotes:FindFirstChild("UseGear")
local Purchase = Remotes and Remotes:FindFirstChild("PurchaseShopItem")

_G.AutoHarvest = false
_G.SpeedLoop = false

CreateToggle("Auto-Harvest", false, function(val) _G.AutoHarvest = val end)

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
                                    if uuid then UseGear:FireServer("HarvestBell", {["targetUuid"] = uuid}) end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

CreateButton("Auto-Buy Carrots", function()
    if Purchase then pcall(function() Purchase:InvokeServer("SeedShop", "Carrot") end) end
end)

CreateButton("Teleport: Sell Station", function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local target = workspace:FindFirstChild("SellTeleport", true) or workspace:FindFirstChild("Sell", true)
    if target and hrp then hrp.CFrame = target.CFrame * CFrame.new(0, 3, 0) end
end)

CreateButton("Teleport: My Plot", function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local plots = workspace:FindFirstChild("Plots") or workspace:FindFirstChild("Plot")
    if hrp and plots then
        for _, plot in ipairs(plots:GetChildren()) do
            local owner = plot:GetAttribute("Owner") == LocalPlayer.UserId or (plot:FindFirstChild("Owner") and plot.Owner.Value == LocalPlayer.Name)
            if owner then
                hrp.CFrame = plot:GetPivot() * CFrame.new(0, 5, 0)
                break
            end
        end
    end
end)

CreateToggle("Speed Hack (75)", false, function(val) _G.SpeedLoop = val end)

RunService.Heartbeat:Connect(function()
    if _G.SpeedLoop then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = 75 end
        end)
    end
end)

print("[Ascended] Successfully mounted GUI via gethui()")
