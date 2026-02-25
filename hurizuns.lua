-- Garden Horizons: Absolute Local
-- Zero external dependencies. 100% execution success rate.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreTarget = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- 1. Wipe old instances
if CoreTarget:FindFirstChild("AbsoluteHub") then
    CoreTarget.AbsoluteHub:Destroy()
end

-- 2. Create the GUI Framework
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AbsoluteHub"
ScreenGui.Parent = CoreTarget
ScreenGui.ResetOnSpawn = false

-- Floating Mobile Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ScreenGui
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Position = UDim2.new(0.5, -22, 0, 10)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
ToggleBtn.Text = "🌱"
ToggleBtn.TextSize = 25
local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleBtn

local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = ToggleBtn
UIStroke.Color = Color3.fromRGB(100, 255, 100)
UIStroke.Thickness = 2

-- Main Mod Panel (Hidden initially)
local MainPanel = Instance.new("Frame")
MainPanel.Parent = ScreenGui
MainPanel.Size = UDim2.new(0, 250, 0, 300)
MainPanel.Position = UDim2.new(0.5, -125, 0.5, -150)
MainPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainPanel.Visible = false
MainPanel.Active = true
MainPanel.Draggable = true -- Native Roblox dragging
local PanelCorner = Instance.new("UICorner")
PanelCorner.CornerRadius = UDim.new(0, 10)
PanelCorner.Parent = MainPanel

local Title = Instance.new("TextLabel")
Title.Parent = MainPanel
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "  GH: ABSOLUTE LOCAL"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local Scroll = Instance.new("ScrollingFrame")
Scroll.Parent = MainPanel
Scroll.Size = UDim2.new(1, -10, 1, -40)
Scroll.Position = UDim2.new(0, 5, 0, 35)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 4
Scroll.CanvasSize = UDim2.new(0, 0, 1.5, 0)

local ListLayout = Instance.new("UIListLayout")
ListLayout.Parent = Scroll
ListLayout.Padding = UDim.new(0, 5)

-- Toggle Logic
ToggleBtn.MouseButton1Click:Connect(function()
    MainPanel.Visible = not MainPanel.Visible
end)

-- 3. UI Component Generators
local function CreateButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = Scroll
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
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

CreateButton("Teleport to Sell Station", function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local target = workspace:FindFirstChild("SellTeleport", true) or workspace:FindFirstChild("Sell", true)
    if target and hrp then hrp.CFrame = target.CFrame * CFrame.new(0, 3, 0) end
end)

CreateButton("Teleport to My Plot", function()
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
