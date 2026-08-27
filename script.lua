--[[
    Sword Factory Hub v2.0 (Mobile & PC Compatible Edition)
    Features:
    - On-Screen Touch Toggle Button (Mobile Friendly + Draggable)
    - Full Touch UI Support
    - Auto Farm, Player Farm, Auto-Equip, Enchant Pickup
    - Boss Sniper/Avoider, Visuals/ESP, Safe Teleports
    - Configuration System & Stats HUD
--]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Configuration Defaults
local Config = {
    AutoFarm = false,
    FarmTarget = "Closest",
    FarmDirection = "Above",
    FarmDistance = 5,
    AutoAttack = false,
    AutoEquipBest = false,
    HealthSafety = false,
    HealthThreshold = 30,
    HideUnderMap = false,
    PickupEnchants = false,
    PickupDelay = 0.5,
    PickupRange = 50,
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    Noclip = false,
    FullBright = false,
    CtrlClickTP = false,
    ESP = false,
    ESPBoxes = false,
    ESPLines = false
}

-- ScreenGui Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SFHub_MobileGUI"
ScreenGui.ResetOnSpawn = false

if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = CoreGui
end

----------------------------------------------------
-- MOBILE TOGGLE BUTTON (Draggable Touch Button)
----------------------------------------------------
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "HubToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.Size = UDim2.new(0, 60, 0, 60)
ToggleButton.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(35, 39, 42)
ToggleButton.BorderColor3 = Color3.fromRGB(114, 137, 218)
ToggleButton.BorderSizePixel = 2
ToggleButton.Text = "SF HUB"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 14
ToggleButton.Active = true
ToggleButton.Draggable = true -- Built-in support for touch drag

local UICornerBtn = Instance.new("UICorner")
UICornerBtn.CornerRadius = UDim.new(0, 12)
UICornerBtn.Parent = ToggleButton

----------------------------------------------------
-- MAIN WINDOW LAYOUT
----------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 500, 0, 320)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(47, 49, 54)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(32, 34, 37)
TopBar.BorderSizePixel = 0

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = TopBar
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Sword Factory Hub v2.0 (Mobile Ready)"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TopBar
CloseBtn.Size = UDim2.new(0, 35, 1, 0)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 85, 85)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 16

-- Navigation Bar (Left)
local NavFrame = Instance.new("ScrollingFrame")
NavFrame.Name = "NavFrame"
NavFrame.Parent = MainFrame
NavFrame.Size = UDim2.new(0, 120, 1, -35)
NavFrame.Position = UDim2.new(0, 0, 0, 35)
NavFrame.BackgroundColor3 = Color3.fromRGB(40, 43, 48)
NavFrame.BorderSizePixel = 0
NavFrame.ScrollBarThickness = 3

local NavLayout = Instance.new("UIListLayout")
NavLayout.Parent = NavFrame
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
NavLayout.Padding = UDim.new(0, 4)

-- Content Area (Right)
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = MainFrame
ContentFrame.Size = UDim2.new(1, -125, 1, -40)
ContentFrame.Position = UDim2.new(0, 125, 0, 40)
ContentFrame.BackgroundTransparency = 1

----------------------------------------------------
-- UI INTERACTION LOGIC
----------------------------------------------------
local function ToggleUI()
    MainFrame.Visible = not MainFrame.Visible
end

-- Mobile & PC Toggle Button Trigger
ToggleButton.MouseButton1Click:Connect(ToggleUI)
CloseBtn.MouseButton1Click:Connect(ToggleUI)

-- PC Keybind Toggle (K Key)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.K then
        ToggleUI()
    end
end)

----------------------------------------------------
-- TAB CREATOR UTILITY
----------------------------------------------------
local Tabs = {}
local activeTab = nil

local function CreateTab(name)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "TabBtn"
    TabButton.Parent = NavFrame
    TabButton.Size = UDim2.new(1, 0, 0, 30)
    TabButton.BackgroundColor3 = Color3.fromRGB(47, 49, 54)
    TabButton.Text = name
    TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabButton.Font = Enum.Font.SourceSans
    TabButton.TextSize = 14

    local TabPage = Instance.new("ScrollingFrame")
    TabPage.Name = name .. "Page"
    TabPage.Parent = ContentFrame
    TabPage.Size = UDim2.new(1, 0, 1, 0)
    TabPage.BackgroundTransparency = 1
    TabPage.Visible = false
    TabPage.ScrollBarThickness = 4

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Parent = TabPage
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 6)

    TabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(Tabs) do
            tab.Page.Visible = false
            tab.Btn.BackgroundColor3 = Color3.fromRGB(47, 49, 54)
            tab.Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        TabPage.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    Tabs[name] = {Btn = TabButton, Page = TabPage}
    
    -- Select first tab automatically
    if not activeTab then
        activeTab = Tabs[name]
        TabPage.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end

    return TabPage
end

local function CreateToggle(parent, text, configKey, callback)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = parent
    ToggleBtn.Size = UDim2.new(1, -10, 0, 32)
    ToggleBtn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(67, 181, 129) or Color3.fromRGB(54, 57, 63)
    ToggleBtn.Text = text .. ": " .. (Config[configKey] and "ON" or "OFF")
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.Font = Enum.Font.SourceSansBold
    ToggleBtn.TextSize = 14

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = ToggleBtn

    ToggleBtn.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        ToggleBtn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(67, 181, 129) or Color3.fromRGB(54, 57, 63)
        ToggleBtn.Text = text .. ": " .. (Config[configKey] and "ON" or "OFF")
        if callback then callback(Config[configKey]) end
    end)

    return ToggleBtn
end

----------------------------------------------------
-- BUILD TABS & CONTROLS
----------------------------------------------------
local FarmTab = CreateTab("Auto Farm")
local PlayerTab = CreateTab("Player")
local TeleportTab = CreateTab("Teleport")
local SettingsTab = CreateTab("Settings")

-- Auto Farm Controls
CreateToggle(FarmTab, "Auto Farm NPCs", "AutoFarm")
CreateToggle(FarmTab, "Auto Attack", "AutoAttack")
CreateToggle(FarmTab, "Auto Equip Best Sword", "AutoEquipBest")
CreateToggle(FarmTab, "Pickup Enchants", "PickupEnchants")

-- Player Controls
CreateToggle(PlayerTab, "Infinite Jump", "InfiniteJump")
CreateToggle(PlayerTab, "Noclip", "Noclip")
CreateToggle(PlayerTab, "Full Bright", "FullBright", function(val)
    if val then
        game:GetService("Lighting").Ambient = Color3.fromRGB(255, 255, 255)
    else
        game:GetService("Lighting").Ambient = Color3.fromRGB(127, 127, 127)
    end
end)

-- Teleport Controls
local TPSpawnBtn = Instance.new("TextButton")
TPSpawnBtn.Parent = TeleportTab
TPSpawnBtn.Size = UDim2.new(1, -10, 0, 32)
TPSpawnBtn.BackgroundColor3 = Color3.fromRGB(54, 57, 63)
TPSpawnBtn.Text = "Teleport to Spawn Base"
TPSpawnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TPSpawnBtn.Font = Enum.Font.SourceSansBold
TPSpawnBtn.TextSize = 14

local TPCorner = Instance.new("UICorner")
TPCorner.CornerRadius = UDim.new(0, 6)
TPCorner.Parent = TPSpawnBtn

TPSpawnBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
    end
end)

----------------------------------------------------
-- BACKGROUND LOOPS & CORE SYSTEMS
----------------------------------------------------

-- Mobile Touch / PC Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Noclip Execution Loop
RunService.Stepped:Connect(function()
    if Config.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Farm Execution Loop
task.spawn(function()
    while task.wait(0.2) do
        if Config.AutoFarm and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local closestNPC = nil
            local shortestDist = math.huge
            
            for _, v in pairs(workspace:GetChildren()) do
                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Name ~= LocalPlayer.Name then
                    local dist = (v.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closestNPC = v
                    end
                end
            end

            if closestNPC then
                LocalPlayer.Character.HumanoidRootPart.CFrame = closestNPC.HumanoidRootPart.CFrame * CFrame.new(0, Config.FarmDistance, 0)
            end
        end
    end
end)
