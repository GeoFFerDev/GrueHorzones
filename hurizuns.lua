-- Garden Horizons: Ascended Fluent
-- Aesthetic: Fluent Design, Sidebar Tabs, Glassmorphism
-- Optimized for Delta Android (Local UI)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

-- 1. Safely Mount & Force Landscape
pcall(function() StarterGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeRight end)
pcall(function() LocalPlayer.PlayerGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeRight end)

local TargetParent = (type(gethui) == "function" and gethui()) or 
                     (pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui")) or 
                     LocalPlayer:WaitForChild("PlayerGui")

if not TargetParent then return end
if TargetParent:FindFirstChild("AscendedFluent") then TargetParent.AscendedFluent:Destroy() end

local ScreenGui = Instance.new("ScreenGui", TargetParent)
ScreenGui.Name = "AscendedFluent"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

-- Fluent Colors
local Theme = {
    Background = Color3.fromRGB(24, 24, 28),
    Sidebar = Color3.fromRGB(18, 18, 22),
    Accent = Color3.fromRGB(0, 170, 120), -- Fluent Green
    Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(150, 150, 150),
    Button = Color3.fromRGB(35, 35, 40),
    Stroke = Color3.fromRGB(60, 60, 65)
}

-- 2. Draggable Toggle Icon (Minimize State)
local ToggleIcon = Instance.new("TextButton", ScreenGui)
ToggleIcon.Size = UDim2.new(0, 45, 0, 45)
ToggleIcon.Position = UDim2.new(0.5, -22, 0.05, 0)
ToggleIcon.BackgroundColor3 = Theme.Background
ToggleIcon.BackgroundTransparency = 0.1
ToggleIcon.Text = "🌱"
ToggleIcon.TextSize = 22
ToggleIcon.Visible = false
Instance.new("UICorner", ToggleIcon).CornerRadius = UDim.new(1, 0)
local IconStroke = Instance.new("UIStroke", ToggleIcon)
IconStroke.Color = Theme.Accent
IconStroke.Thickness = 2

-- 3. Main Fluent Window
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 400, 0, 260)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -130)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BackgroundTransparency = 0.1
MainFrame.Active = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Theme.Stroke
MainStroke.Transparency = 0.5

-- Top Bar (Dragging Area)
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Text = "Ascended UI"
Title.Font = Enum.Font.GothamMedium
Title.TextColor3 = Theme.Text
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

-- Window Controls
local function AddControl(text, pos, color, callback)
    local btn = Instance.new("TextButton", TopBar)
    btn.Size = UDim2.new(0, 30, 0, 20)
    btn.Position = pos
    btn.BackgroundColor3 = Theme.Background
    btn.Text = text
    btn.TextColor3 = color
    btn.Font = Enum.Font.GothamMedium
    btn.BackgroundTransparency = 1
    btn.MouseButton1Click:Connect(callback)
end

AddControl("✕", UDim2.new(1, -35, 0.5, -10), Color3.fromRGB(255, 80, 80), function() ScreenGui:Destroy() end)
AddControl("—", UDim2.new(1, -70, 0.5, -10), Theme.Text, function() 
    MainFrame.Visible = false
    ToggleIcon.Visible = true 
end)

ToggleIcon.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    ToggleIcon.Visible = false
end)

-- 4. Native Dragging Logic
local function EnableDrag(obj, handle)
    local drag, input, start, startPos
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; start = i.Position; startPos = obj.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then drag = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - start
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
EnableDrag(MainFrame, TopBar)
EnableDrag(ToggleIcon, ToggleIcon)

-- 5. Fluent Sidebar Navigation
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 110, 1, -30)
Sidebar.Position = UDim2.new(0, 0, 0, 30)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BackgroundTransparency = 0.5
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.Padding = UDim.new(0, 5)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 10)

-- Content Area (Where tabs show)
local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Size = UDim2.new(1, -120, 1, -30)
ContentArea.Position = UDim2.new(0, 115, 0, 30)
ContentArea.BackgroundTransparency = 1

local Tabs = {}
local TabButtons = {}

local function CreateTab(name, icon)
    -- Tab Content Frame
    local TabFrame = Instance.new("ScrollingFrame", ContentArea)
    TabFrame.Size = UDim2.new(1, 0, 1, -10)
    TabFrame.BackgroundTransparency = 1
    TabFrame.ScrollBarThickness = 2
    TabFrame.Visible = false
    TabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabFrame.CanvasSize = UDim2.new(0,0,0,0)
    TabFrame.BorderSizePixel = 0
    
    local Layout = Instance.new("UIListLayout", TabFrame)
    Layout.Padding = UDim.new(0, 8)
    Instance.new("UIPadding", TabFrame).PaddingTop = UDim.new(0, 5)

    -- Sidebar Button
    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size = UDim2.new(0.9, 0, 0, 30)
    TabBtn.BackgroundColor3 = Theme.Accent
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = "  " .. icon .. " " .. name
    TabBtn.TextColor3 = Theme.SubText
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.TextSize = 12
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 5)
    
    local Indicator = Instance.new("Frame", TabBtn)
    Indicator.Size = UDim2.new(0, 3, 0.6, 0)
    Indicator.Position = UDim2.new(0, 2, 0.2, 0)
    Indicator.BackgroundColor3 = Theme.Accent
    Indicator.Visible = false
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.Frame.Visible = false end
        for _, b in pairs(TabButtons) do 
            b.Btn.BackgroundTransparency = 1
            b.Btn.TextColor3 = Theme.SubText
            b.Indicator.Visible = false
        end
        TabFrame.Visible = true
        TabBtn.BackgroundTransparency = 0.85
        TabBtn.TextColor3 = Theme.Text
        Indicator.Visible = true
    end)

    table.insert(Tabs, {Frame = TabFrame})
    table.insert(TabButtons, {Btn = TabBtn, Indicator = Indicator})
    
    return TabFrame
end

-- 6. Fluent UI Components (Toggles & Buttons)
local function CreateFluentToggle(parent, title, desc, callback)
    local state = false
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.98, 0, 0, 45)
    btn.BackgroundColor3 = Theme.Button
    btn.Text = ""
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", btn).Color = Theme.Stroke

    local Txt = Instance.new("TextLabel", btn)
    Txt.Size = UDim2.new(0.7, 0, 0.5, 0)
    Txt.Position = UDim2.new(0, 10, 0, 5)
    Txt.Text = title
    Txt.Font = Enum.Font.GothamMedium
    Txt.TextColor3 = Theme.Text
    Txt.TextSize = 13
    Txt.TextXAlignment = Enum.TextXAlignment.Left
    Txt.BackgroundTransparency = 1

    local SubTxt = Instance.new("TextLabel", btn)
    SubTxt.Size = UDim2.new(0.7, 0, 0.5, 0)
    SubTxt.Position = UDim2.new(0, 10, 0.5, 0)
    SubTxt.Text = desc
    SubTxt.Font = Enum.Font.Gotham
    SubTxt.TextColor3 = Theme.SubText
    SubTxt.TextSize = 10
    SubTxt.TextXAlignment = Enum.TextXAlignment.Left
    SubTxt.BackgroundTransparency = 1

    local StatusPill = Instance.new("Frame", btn)
    StatusPill.Size = UDim2.new(0, 40, 0, 20)
    StatusPill.Position = UDim2.new(1, -50, 0.5, -10)
    StatusPill.BackgroundColor3 = Theme.Background
    Instance.new("UICorner", StatusPill).CornerRadius = UDim.new(1, 0)
    local PillStroke = Instance.new("UIStroke", StatusPill)
    PillStroke.Color = Theme.Stroke

    local StatusText = Instance.new("TextLabel", StatusPill)
    StatusText.Size = UDim2.new(1, 0, 1, 0)
    StatusText.Text = "OFF"
    StatusText.Font = Enum.Font.GothamBold
    StatusText.TextColor3 = Theme.SubText
    StatusText.TextSize = 10
    StatusText.BackgroundTransparency = 1

    btn.MouseButton1Click:Connect(function()
        state = not state
        StatusText.Text = state and "ON" or "OFF"
        StatusText.TextColor3 = state and Theme.Background or Theme.SubText
        StatusPill.BackgroundColor3 = state and Theme.Accent or Theme.Background
        PillStroke.Color = state and Theme.Accent or Theme.Stroke
        btn.BackgroundColor3 = state and Color3.fromRGB(40, 45, 45) or Theme.Button
        callback(state)
    end)
end

local function CreateFluentButton(parent, title, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.98, 0, 0, 35)
    btn.BackgroundColor3 = Theme.Button
    btn.Text = "  " .. title
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", btn).Color = Theme.Stroke
    btn.MouseButton1Click:Connect(callback)
end

-- 7. Game Logic & Tabs Implementation
local Remotes = ReplicatedStorage:WaitForChild("RemoteEvents", 5)
local UseGear = Remotes and Remotes:FindFirstChild("UseGear")
local Purchase = Remotes and Remotes:FindFirstChild("PurchaseShopItem")

local TabFarming = CreateTab("Farming", "🌱")
local TabShop = CreateTab("Shop", "🛒")
local TabTravel = CreateTab("Travel", "📍")
local TabPlayer = CreateTab("Player", "🏃")

-- Farming
_G.AH = false
CreateFluentToggle(TabFarming, "Auto-Harvest", "Automatically picks fully grown crops.", function(v) _G.AH = v end)

task.spawn(function()
    while task.wait(0.5) do
        if _G.AH then
            pcall(function()
                local plots = workspace:FindFirstChild("Plots") or workspace:FindFirstChild("Plot")
                if plots and UseGear then
                    for _, p in ipairs(plots:GetChildren()) do
                        if p:GetAttribute("Owner") == LocalPlayer.UserId or (p:FindFirstChild("Owner") and p.Owner.Value == LocalPlayer.Name) then
                            for _, plant in ipairs(p:GetChildren()) do
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

-- Shop
CreateFluentButton(TabShop, "Buy Carrot Seeds", function()
    if Purchase then pcall(function() Purchase:InvokeServer("SeedShop", "Carrot") end) end
end)

-- Travel
CreateFluentButton(TabTravel, "Teleport to Market", function()
    local t = workspace:FindFirstChild("SellTeleport", true) or workspace:FindFirstChild("Sell", true)
    if t and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
        LocalPlayer.Character.HumanoidRootPart.CFrame = t.CFrame * CFrame.new(0, 3, 0)
    end
end)

CreateFluentButton(TabTravel, "Teleport to Garden", function()
    local plots = workspace:FindFirstChild("Plots") or workspace:FindFirstChild("Plot")
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if plots and hrp then
        for _, p in ipairs(plots:GetChildren()) do
            if p:GetAttribute("Owner") == LocalPlayer.UserId or (p:FindFirstChild("Owner") and p.Owner.Value == LocalPlayer.Name) then
                hrp.CFrame = p:GetPivot() * CFrame.new(0, 5, 0)
                break
            end
        end
    end
end)

-- Player
_G.Spd = false
CreateFluentToggle(TabPlayer, "Infinite Speed", "Forces WalkSpeed to 80.", function(v) _G.Spd = v end)

RunService.Heartbeat:Connect(function()
    if _G.Spd then
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 80
            end
        end)
    end
end)

-- Init Default Tab
TabButtons[1].Btn.MouseButton1Click:Fire()
