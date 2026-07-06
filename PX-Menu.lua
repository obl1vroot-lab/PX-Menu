--[[
    PX-Menu v2.1
    Game: German Voice (ID: 136162036182779)
    Toggle Key: Right Shift (configurable in Settings)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local OwnerUserId = 8499167501
local IsOwner = LocalPlayer.UserId == OwnerUserId

local DataStoreService = nil
local MessagingService = nil
local NametagStore = nil
local PresenceStore = nil
local BroadcastStore = nil
local DataStoreAvailable = false

pcall(function()
    DataStoreService = game:GetService("DataStoreService")
    MessagingService = game:GetService("MessagingService")
    NametagStore = DataStoreService:GetDataStore("PXMenu_Nametags")
    PresenceStore = DataStoreService:GetDataStore("PXMenu_Presence")
    BroadcastStore = DataStoreService:GetDataStore("PXMenu_Broadcast")
    DataStoreAvailable = true
end)

local GAME_ID = 136162036182779
if game.PlaceId ~= GAME_ID then
    local WarnGui = Instance.new("ScreenGui")
    WarnGui.Name = "PXWarn"
    WarnGui.ResetOnSpawn = false
    WarnGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    WarnGui.Parent = CoreGui

    local WarnFrame = Instance.new("Frame")
    WarnFrame.Size = UDim2.new(0, 380, 0, 110)
    WarnFrame.Position = UDim2.new(1, -400, 1, -130)
    WarnFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    WarnFrame.BorderSizePixel = 0
    WarnFrame.Parent = WarnGui
    Instance.new("UICorner", WarnFrame).CornerRadius = UDim.new(0, 10)

    local ws = Instance.new("UIStroke", WarnFrame)
    ws.Color = Color3.fromRGB(255, 85, 85)
    ws.Thickness = 2
    ws.Transparency = 0.3

    local WarnTitle = Instance.new("TextLabel")
    WarnTitle.Size = UDim2.new(1, -20, 0, 30)
    WarnTitle.Position = UDim2.new(0, 12, 0, 10)
    WarnTitle.BackgroundTransparency = 1
    WarnTitle.Text = "PX-Menu"
    WarnTitle.TextColor3 = Color3.fromRGB(255, 85, 85)
    WarnTitle.TextSize = 18
    WarnTitle.Font = Enum.Font.GothamBold
    WarnTitle.TextXAlignment = Enum.TextXAlignment.Left
    WarnTitle.Parent = WarnFrame

    local WarnText = Instance.new("TextLabel")
    WarnText.Size = UDim2.new(1, -24, 0, 50)
    WarnText.Position = UDim2.new(0, 12, 0, 45)
    WarnText.BackgroundTransparency = 1
    WarnText.Text = "Dieses Script ist momentan nur für German Voice verfügbar."
    WarnText.TextColor3 = Color3.fromRGB(200, 200, 200)
    WarnText.TextSize = 14
    WarnText.Font = Enum.Font.Gotham
    WarnText.TextWrapped = true
    WarnText.TextXAlignment = Enum.TextXAlignment.Left
    WarnText.Parent = WarnFrame

    task.delay(5, function() WarnGui:Destroy() end)
    return
end

-- Executor Detection
local function DetectExecutor()
    local name = "Unknown"
    local isTrusted = false
    if identifyexecutor then
        local s, n = pcall(identifyexecutor)
        if s and n then name = n end
    end
    for _, v in pairs({"Potassium", "Madium", "Real", "Wave"}) do
        if string.lower(name):find(string.lower(v)) then
            isTrusted = true
            break
        end
    end
    return name, isTrusted
end

local ExecutorName, ExecutorTrusted = DetectExecutor()

-- Config - ALL keybinds default to nil (user must set them)
local Config = {
    ToggleKey = Enum.KeyCode.RightShift,
    Speed = 16,
    JumpPower = 50,
    Gravity = 196.2,
    FlyEnabled = false,
    FlySpeed = 50,
    ESPPEnabled = false,
    FullbrightEnabled = false,
    BloomEnabled = false,
    TargetToolEnabled = false,
    HeadsitEnabled = false,
    BackpackEnabled = false,
    AntiAFKEnabled = false,
    ClickTPEnabled = false,
    SpinEnabled = false,
    FlingEnabled = false,
    BigHeadEnabled = false,
    MoonJumpEnabled = false,
    TrailEnabled = false,
    Spectating = nil,
    Hotkeys = {
        Speed = nil,
        JumpPower = nil,
        Gravity = nil,
        Fly = nil,
        ESP = nil,
        Fullbright = nil,
        Bloom = nil,
        TargetTool = nil,
    }
}

local MenuOpen = false
local Minimized = false
local FlyConnection = nil
local ESPConnections = {}
local ESPObjects = {}
local TargetGUI = nil
local TargetPlayer = nil
local HeadsitSeat = nil
local BackpackSeat = nil
local HeadsitConn = nil
local BackpackConn = nil
local SpeedHeld = false
local JumpPowerHeld = false
local AntiAFKConn = nil
local ClickTPConn = nil
local SpinConn = nil
local FlingConn = nil
local TrailObj = nil
local SpectateConn = nil
local PlayerListGUI = nil
local NametagConnections = {}

-- ============ NAMETAG SYSTEM ============
local NametagEnabled = true

local function CreateNametag(character, playerName)
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local existingTag = hrp:FindFirstChild("PXNametag")
    if existingTag then existingTag:Destroy() end
    
    if not NametagEnabled then return end
    
    local myData = nil
    if DataStoreAvailable and NametagStore then
        pcall(function()
            myData = NametagStore:GetAsync("user_" .. LocalPlayer.UserId)
        end)
    end
    
    local customName = nil
    local tagColor = Color3.fromRGB(235, 235, 240)
    local hidden = false
    local role = "member"
    
    if myData then
        customName = myData.customName
        hidden = myData.hidden or false
        role = myData.role or "member"
        if myData.color then
            local r, g, b = myData.color:match("(%d+),(%d+),(%d+)")
            if r and g and b then
                tagColor = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
            end
        end
    end
    
    if hidden then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PXNametag"
    billboard.Size = UDim2.new(0, 220, 0, 70)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.MaxDistance = 120
    billboard.Parent = hrp
    
    local bgFrame = Instance.new("Frame")
    bgFrame.Name = "BG"
    bgFrame.Size = UDim2.new(1, 0, 1, 0)
    bgFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 46)
    bgFrame.BackgroundTransparency = 0.3
    bgFrame.BorderSizePixel = 0
    bgFrame.Parent = billboard
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = bgFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 50, 170)
    stroke.Thickness = 2
    stroke.Transparency = 0.2
    stroke.Parent = bgFrame
    
    local glow = Instance.new("UIStroke")
    glow.Color = Color3.fromRGB(120, 60, 200)
    glow.Thickness = 1
    glow.Transparency = 0.6
    glow.Parent = bgFrame
    
    local displayNameText = customName or playerName
    if IsOwner then
        displayNameText = "👑 " .. displayNameText
    end
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, -16, 0, 26)
    nameLabel.Position = UDim2.new(0, 8, 0, 6)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = displayNameText
    nameLabel.TextColor3 = tagColor
    nameLabel.TextSize = 20
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextStrokeTransparency = 0.4
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    nameLabel.Parent = bgFrame
    
    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Name = "UsernameLabel"
    usernameLabel.Size = UDim2.new(1, -16, 0, 18)
    usernameLabel.Position = UDim2.new(0, 8, 0, 30)
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.Text = "@" .. playerName
    usernameLabel.TextColor3 = Color3.fromRGB(140, 140, 160)
    usernameLabel.TextSize = 14
    usernameLabel.Font = Enum.Font.Gotham
    usernameLabel.TextStrokeTransparency = 0.5
    usernameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    usernameLabel.TextXAlignment = Enum.TextXAlignment.Center
    usernameLabel.Parent = bgFrame
    
    if role == "owner" or IsOwner then
        local roleLabel = Instance.new("TextLabel")
        roleLabel.Name = "RoleLabel"
        roleLabel.Size = UDim2.new(1, -16, 0, 14)
        roleLabel.Position = UDim2.new(0, 8, 0, 50)
        roleLabel.BackgroundTransparency = 1
        roleLabel.Text = "👑 Owner"
        roleLabel.TextColor3 = Color3.fromRGB(170, 85, 255)
        roleLabel.TextSize = 12
        roleLabel.Font = Enum.Font.GothamBold
        roleLabel.TextStrokeTransparency = 0.5
        roleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        roleLabel.TextXAlignment = Enum.TextXAlignment.Center
        roleLabel.Parent = bgFrame
    end
end

local function UpdateOwnNametag()
    local char = LocalPlayer.Character
    if char then
        CreateNametag(char, LocalPlayer.Name)
    end
end

local function SetupPresence()
    if not DataStoreAvailable or not PresenceStore then return end
    pcall(function()
        PresenceStore:SetAsync("user_" .. LocalPlayer.UserId, {
            online = true,
            timestamp = os.time(),
            displayName = LocalPlayer.DisplayName,
            username = LocalPlayer.Name
        })
    end)
    
    spawn(function()
        while task.wait(30) do
            if not DataStoreAvailable or not PresenceStore then return end
            pcall(function()
                PresenceStore:SetAsync("user_" .. LocalPlayer.UserId, {
                    online = true,
                    timestamp = os.time(),
                    displayName = LocalPlayer.DisplayName,
                    username = LocalPlayer.Name
                })
            end)
        end
    end)
end

local function CheckForOtherExecutors()
    if not DataStoreAvailable or not NametagStore then return end
    spawn(function()
        while task.wait(15) do
            pcall(function()
                local allPlayers = Players:GetPlayers()
                for _, player in pairs(allPlayers) do
                    if player ~= LocalPlayer then
                        local data = NametagStore:GetAsync("user_" .. player.UserId)
                        if data and not data.hidden then
                            local char = player.Character
                            if char then
                                CreateNametag(char, player.Name)
                            end
                        end
                    end
                end
            end)
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    UpdateOwnNametag()
end)

if LocalPlayer.Character then
    UpdateOwnNametag()
end

SetupPresence()
CheckForOtherExecutors()

if DataStoreAvailable and MessagingService then
    pcall(function()
        MessagingService:SubscribeAsync("PXMenu_Broadcast", function(message)
            if message and message.Data then
                local data = message.Data
                if data.type == "nametag_update" and data.userId == LocalPlayer.UserId then
                    task.wait(1)
                    UpdateOwnNametag()
                end
            end
        end)
    end)
end

-- Colors
local C = {
    BG = Color3.fromRGB(18, 18, 24),
    Dark = Color3.fromRGB(12, 12, 18),
    Dark2 = Color3.fromRGB(24, 24, 32),
    Accent = Color3.fromRGB(100, 50, 170),
    AccentLight = Color3.fromRGB(130, 70, 210),
    AccentDark = Color3.fromRGB(70, 30, 120),
    AccentGlow = Color3.fromRGB(120, 60, 200),
    Text = Color3.fromRGB(235, 235, 240),
    Dim = Color3.fromRGB(120, 120, 140),
    TabOn = Color3.fromRGB(100, 50, 170),
    TabOff = Color3.fromRGB(28, 28, 38),
    Btn = Color3.fromRGB(32, 32, 42),
    BtnHover = Color3.fromRGB(44, 44, 56),
    SliderBG = Color3.fromRGB(26, 26, 36),
    SliderFill = Color3.fromRGB(100, 50, 170),
    ToggleOff = Color3.fromRGB(44, 44, 56),
    ToggleOn = Color3.fromRGB(100, 50, 170),
    InputBG = Color3.fromRGB(22, 22, 32),
    Green = Color3.fromRGB(0, 190, 80),
    Orange = Color3.fromRGB(255, 160, 30),
    Red = Color3.fromRGB(210, 45, 45),
}

-- Utility
local function Corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = p
    return c
end

local function Stroke(p, col, th, tr)
    local s = Instance.new("UIStroke")
    s.Color = col or C.Accent
    s.Thickness = th or 1
    s.Transparency = tr or 0
    s.Parent = p
    return s
end

local function Tw(obj, props, dur)
    local t = TweenService:Create(obj, TweenInfo.new(dur or 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function Drag(frame, bar)
    local dragging, dragInput, dragStart, startPos
    bar = bar or frame
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    bar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local d = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

if CoreGui:FindFirstChild("PXMenu") then CoreGui:FindFirstChild("PXMenu"):Destroy() end
if CoreGui:FindFirstChild("PXIndicator") then CoreGui:FindFirstChild("PXIndicator"):Destroy() end

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PXMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

-- ============ LOADING SCREEN ============
local LF = Instance.new("Frame")
LF.Size = UDim2.new(0, 440, 0, 260)
LF.Position = UDim2.new(0.5, -220, 0.5, -130)
LF.BackgroundColor3 = C.BG
LF.BorderSizePixel = 0
LF.Parent = ScreenGui
Corner(LF, 16)
Stroke(LF, C.Accent, 2, 0.3)

local LGlow = Instance.new("Frame")
LGlow.Size = UDim2.new(1, 8, 1, 8)
LGlow.Position = UDim2.new(0, -4, 0, -4)
LGlow.BackgroundColor3 = C.AccentGlow
LGlow.BackgroundTransparency = 0.87
LGlow.BorderSizePixel = 0
LGlow.ZIndex = -1
LGlow.Parent = LF
Corner(LGlow, 20)

-- Animated accent line at top
local LAccent = Instance.new("Frame")
LAccent.Size = UDim2.new(0, 0, 0, 3)
LAccent.Position = UDim2.new(0, 0, 0, 0)
LAccent.BackgroundColor3 = C.Accent
LAccent.BorderSizePixel = 0
LAccent.Parent = LF
Corner(LAccent, 2)

local LTitle = Instance.new("TextLabel")
LTitle.Size = UDim2.new(1, 0, 0, 50)
LTitle.Position = UDim2.new(0, 0, 0, 30)
LTitle.BackgroundTransparency = 1
LTitle.Text = "PX-Menu"
LTitle.TextColor3 = C.AccentLight
LTitle.TextSize = 38
LTitle.Font = Enum.Font.GothamBold
LTitle.Parent = LF

local LSub = Instance.new("TextLabel")
LSub.Size = UDim2.new(1, 0, 0, 20)
LSub.Position = UDim2.new(0, 0, 0, 82)
LSub.BackgroundTransparency = 1
LSub.Text = "Initializing..."
LSub.TextColor3 = C.Dim
LSub.TextSize = 13
LSub.Font = Enum.Font.Gotham
LSub.Parent = LF

local LBarBG = Instance.new("Frame")
LBarBG.Size = UDim2.new(0.7, 0, 0, 5)
LBarBG.Position = UDim2.new(0.15, 0, 0, 120)
LBarBG.BackgroundColor3 = C.SliderBG
LBarBG.BorderSizePixel = 0
LBarBG.Parent = LF
Corner(LBarBG, 3)

local LBarFill = Instance.new("Frame")
LBarFill.Size = UDim2.new(0, 0, 1, 0)
LBarFill.BackgroundColor3 = C.Accent
LBarFill.BorderSizePixel = 0
LBarFill.Parent = LBarBG
Corner(LBarFill, 3)

local LPct = Instance.new("TextLabel")
LPct.Size = UDim2.new(1, 0, 0, 25)
LPct.Position = UDim2.new(0, 0, 0, 140)
LPct.BackgroundTransparency = 1
LPct.Text = "0%"
LPct.TextColor3 = C.Text
LPct.TextSize = 16
LPct.Font = Enum.Font.GothamBold
LPct.Parent = LF

local LStat = Instance.new("TextLabel")
LStat.Size = UDim2.new(1, 0, 0, 18)
LStat.Position = UDim2.new(0, 0, 0, 175)
LStat.BackgroundTransparency = 1
LStat.Text = ""
LStat.TextColor3 = C.Dim
LStat.TextSize = 11
LStat.Font = Enum.Font.Gotham
LStat.Parent = LF

-- Executor info on loading
local LExec = Instance.new("TextLabel")
LExec.Size = UDim2.new(1, 0, 0, 16)
LExec.Position = UDim2.new(0, 0, 0, 205)
LExec.BackgroundTransparency = 1
LExec.Text = "Executor: " .. ExecutorName .. (ExecutorTrusted and " (Verified)" or " (Unverified)")
LExec.TextColor3 = ExecutorTrusted and C.Green or C.Orange
LExec.TextSize = 11
LExec.Font = Enum.Font.GothamMedium
LExec.Parent = LF

task.spawn(function()
    Tw(LAccent, {Size = UDim2.new(1, 0, 0, 3)}, 2.2)
    local steps = {
        {p=8, s="Detecting executor..."},
        {p=20, s="Loading core modules..."},
        {p=35, s="Building interface..."},
        {p=50, s="Configuring components..."},
        {p=65, s="Applying theme..."},
        {p=80, s="Setting up features..."},
        {p=92, s="Finalizing..."},
        {p=100, s="Ready!"},
    }
    local si = 1
    for i = 1, 100 do
        LBarFill.Size = UDim2.new(i / 100, 0, 1, 0)
        LPct.Text = i .. "%"
        if si <= #steps and i >= steps[si].p then
            LStat.Text = steps[si].s
            si = si + 1
        end
        task.wait(0.018)
    end
    task.wait(0.3)
    Tw(LF, {BackgroundTransparency = 1}, 0.4)
    for _, v in pairs(LF:GetDescendants()) do
        if v:IsA("TextLabel") then Tw(v, {TextTransparency = 1}, 0.4)
        elseif v:IsA("Frame") then Tw(v, {BackgroundTransparency = 1}, 0.4) end
    end
    task.wait(0.5)
    LF:Destroy()
end)

task.wait(2.5)

-- ============ GLASS INDICATOR (Top Right) ============
local IG = Instance.new("ScreenGui")
IG.Name = "PXIndicator"
IG.ResetOnSpawn = false
IG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
IG.Parent = CoreGui

local IF = Instance.new("Frame")
IF.Size = UDim2.new(0, 230, 0, 36)
IF.Position = UDim2.new(1, -250, 0, 10)
IF.BackgroundColor3 = C.BG
IF.BackgroundTransparency = 0.12
IF.BorderSizePixel = 0
IF.Parent = IG
Corner(IF, 10)
Stroke(IF, C.Accent, 1, 0.5)

local IGlow = Instance.new("Frame")
IGlow.Size = UDim2.new(1, 4, 1, 4)
IGlow.Position = UDim2.new(0, -2, 0, -2)
IGlow.BackgroundColor3 = C.AccentGlow
IGlow.BackgroundTransparency = 0.87
IGlow.BorderSizePixel = 0
IGlow.ZIndex = -1
IGlow.Parent = IF
Corner(IGlow, 12)

local Dot = Instance.new("Frame")
Dot.Size = UDim2.new(0, 8, 0, 8)
Dot.Position = UDim2.new(0, 14, 0.5, -4)
Dot.BackgroundColor3 = ExecutorTrusted and C.Green or C.Orange
Dot.Parent = IF
Corner(Dot, 4)

-- Pulse animation on dot
task.spawn(function()
    while Dot and Dot.Parent do
        Tw(Dot, {BackgroundTransparency = 0.5}, 0.8)
        task.wait(0.8)
        Tw(Dot, {BackgroundTransparency = 0}, 0.8)
        task.wait(0.8)
    end
end)

local IT = Instance.new("TextLabel")
IT.Size = UDim2.new(0, 95, 1, 0)
IT.Position = UDim2.new(0, 30, 0, 0)
IT.BackgroundTransparency = 1
IT.Text = "PX-Menu"
IT.TextColor3 = C.AccentLight
IT.TextSize = 13
IT.Font = Enum.Font.GothamBold
IT.TextXAlignment = Enum.TextXAlignment.Left
IT.Parent = IF

local IE = Instance.new("TextLabel")
IE.Size = UDim2.new(0, 95, 1, 0)
IE.Position = UDim2.new(0, 110, 0, 0)
IE.BackgroundTransparency = 1
IE.Text = ExecutorName
IE.TextColor3 = ExecutorTrusted and C.Green or C.Orange
IE.TextSize = 11
IE.Font = Enum.Font.GothamMedium
IE.TextXAlignment = Enum.TextXAlignment.Left
IE.Parent = IF

Drag(IF)

-- ============ MAIN FRAME ============
local MF = Instance.new("Frame")
MF.Name = "MainFrame"
MF.Size = UDim2.new(0, 520, 0, 420)
MF.Position = UDim2.new(0.5, -260, 0.5, -210)
MF.BackgroundColor3 = C.BG
MF.BackgroundTransparency = 0.02
MF.BorderSizePixel = 0
MF.Visible = false
MF.Parent = ScreenGui
Corner(MF, 16)
Stroke(MF, C.Accent, 2, 0.3)
Drag(MF)

local MG = Instance.new("Frame")
MG.Size = UDim2.new(1, 8, 1, 8)
MG.Position = UDim2.new(0, -4, 0, -4)
MG.BackgroundColor3 = C.AccentGlow
MG.BackgroundTransparency = 0.87
MG.BorderSizePixel = 0
MG.ZIndex = -1
MG.Parent = MF
Corner(MG, 20)

-- Header
local HD = Instance.new("Frame")
HD.Name = "Header"
HD.Size = UDim2.new(1, 0, 0, 44)
HD.BackgroundColor3 = C.Dark
HD.BorderSizePixel = 0
HD.Parent = MF
Corner(HD, 16)

local HDFix = Instance.new("Frame")
HDFix.Size = UDim2.new(1, 0, 0, 16)
HDFix.Position = UDim2.new(0, 0, 1, -16)
HDFix.BackgroundColor3 = C.Dark
HDFix.BorderSizePixel = 0
HDFix.Parent = HD

local HDAcc = Instance.new("Frame")
HDAcc.Size = UDim2.new(1, 0, 0, 2)
HDAcc.Position = UDim2.new(0, 0, 1, 0)
HDAcc.BackgroundColor3 = C.Accent
HDAcc.BackgroundTransparency = 0.4
HDAcc.BorderSizePixel = 0
HDAcc.Parent = HD

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 140, 1, 0)
Title.Position = UDim2.new(0, 18, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "PX-Menu"
Title.TextColor3 = C.AccentLight
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = HD

local Ver = Instance.new("TextLabel")
Ver.Size = UDim2.new(0, 40, 1, 0)
Ver.Position = UDim2.new(0, 105, 0, 0)
Ver.BackgroundTransparency = 1
Ver.Text = "v2.2"
Ver.TextColor3 = C.Dim
Ver.TextSize = 11
Ver.Font = Enum.Font.Gotham
Ver.TextXAlignment = Enum.TextXAlignment.Left
Ver.Parent = HD

local MBtn = Instance.new("TextButton")
MBtn.Name = "MinBtn"
MBtn.Size = UDim2.new(0, 28, 0, 28)
MBtn.Position = UDim2.new(1, -68, 0, 8)
MBtn.BackgroundColor3 = C.Btn
MBtn.Text = "-"
MBtn.TextColor3 = C.Text
MBtn.TextSize = 18
MBtn.Font = Enum.Font.GothamBold
MBtn.Parent = HD
Corner(MBtn, 7)

local XBtn = Instance.new("TextButton")
XBtn.Name = "CloseBtn"
XBtn.Size = UDim2.new(0, 28, 0, 28)
XBtn.Position = UDim2.new(1, -34, 0, 8)
XBtn.BackgroundColor3 = C.Red
XBtn.Text = "X"
XBtn.TextColor3 = C.Text
XBtn.TextSize = 14
XBtn.Font = Enum.Font.GothamBold
XBtn.Parent = HD
Corner(XBtn, 7)

-- Tab Bar
local TB = Instance.new("Frame")
TB.Name = "TabBar"
TB.Size = UDim2.new(1, -16, 0, 34)
TB.Position = UDim2.new(0, 8, 0, 50)
TB.BackgroundColor3 = C.Dark
TB.BackgroundTransparency = 0.2
TB.BorderSizePixel = 0
TB.Parent = MF
Corner(TB, 8)

local TL = Instance.new("UIListLayout")
TL.FillDirection = Enum.FillDirection.Horizontal
TL.HorizontalAlignment = Enum.HorizontalAlignment.Center
TL.VerticalAlignment = Enum.VerticalAlignment.Center
TL.Padding = UDim.new(0, 4)
TL.Parent = TB

local TP = Instance.new("UIPadding")
TP.PaddingLeft = UDim.new(0, 4)
TP.PaddingRight = UDim.new(0, 4)
TP.Parent = TB

-- Content
local CF = Instance.new("Frame")
CF.Name = "Content"
CF.Size = UDim2.new(1, -20, 1, -104)
CF.Position = UDim2.new(0, 10, 0, 92)
CF.BackgroundTransparency = 1
CF.ClipsDescendants = true
CF.Parent = MF

local TabNames = {"Me", "Visual", "Troll", "Fun", "Social", "Misc", "Settings"}
local TabBtns = {}
local TabFrames = {}

for _, tn in ipairs(TabNames) do
    local btn = Instance.new("TextButton")
    btn.Name = tn
    btn.Size = UDim2.new(0, 68, 0, 26)
    btn.BackgroundColor3 = C.TabOff
    btn.Text = tn
    btn.TextColor3 = C.Dim
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamMedium
    btn.Parent = TB
    Corner(btn, 6)
    TabBtns[tn] = btn

    local tf = Instance.new("ScrollingFrame")
    tf.Name = tn .. "Tab"
    tf.Size = UDim2.new(1, 0, 1, 0)
    tf.BackgroundTransparency = 1
    tf.ScrollBarThickness = 3
    tf.ScrollBarImageColor3 = C.Accent
    tf.BorderSizePixel = 0
    tf.CanvasSize = UDim2.new(0, 0, 0, 0)
    tf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tf.Visible = false
    tf.Parent = CF

    Instance.new("UIListLayout", tf).Padding = UDim.new(0, 5)
    tf.UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local pad = Instance.new("UIPadding", tf)
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.PaddingLeft = UDim.new(0, 4)
    pad.PaddingRight = UDim.new(0, 4)

    TabFrames[tn] = tf
end

local function SwitchTab(name)
    for n, b in pairs(TabBtns) do
        if n == name then
            Tw(b, {BackgroundColor3 = C.TabOn, TextColor3 = C.Text}, 0.2)
        else
            Tw(b, {BackgroundColor3 = C.TabOff, TextColor3 = C.Dim}, 0.2)
        end
    end
    for n, f in pairs(TabFrames) do f.Visible = (n == name) end
end

for n, b in pairs(TabBtns) do
    b.MouseButton1Click:Connect(function() SwitchTab(n) end)
end

-- ============ UI COMPONENTS ============
local function Section(parent, text, order)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 26)
    f.BackgroundTransparency = 1
    f.LayoutOrder = order or 0
    f.Parent = parent

    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 3, 0, 12)
    line.Position = UDim2.new(0, 4, 0.5, -6)
    line.BackgroundColor3 = C.Accent
    line.BorderSizePixel = 0
    line.Parent = f
    Corner(line, 2)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -16, 1, 0)
    l.Position = UDim2.new(0, 14, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = C.AccentLight
    l.TextSize = 12
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    return f
end

local function Btn(parent, text, order, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 34)
    b.BackgroundColor3 = C.Btn
    b.Text = "  " .. text
    b.TextColor3 = C.Text
    b.TextSize = 13
    b.Font = Enum.Font.GothamMedium
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.LayoutOrder = order or 0
    b.Parent = parent
    Corner(b, 8)

    local ab = Instance.new("Frame")
    ab.Size = UDim2.new(0, 3, 0.45, 0)
    ab.Position = UDim2.new(0, 0, 0.275, 0)
    ab.BackgroundColor3 = C.Accent
    ab.BackgroundTransparency = 0.65
    ab.BorderSizePixel = 0
    ab.Parent = b
    Corner(ab, 2)

    b.MouseEnter:Connect(function()
        Tw(b, {BackgroundColor3 = C.BtnHover}, 0.15)
        Tw(ab, {BackgroundTransparency = 0.2}, 0.15)
    end)
    b.MouseLeave:Connect(function()
        Tw(b, {BackgroundColor3 = C.Btn}, 0.15)
        Tw(ab, {BackgroundTransparency = 0.65}, 0.15)
    end)
    b.MouseButton1Click:Connect(function() if cb then cb() end end)
    return b
end

local function Toggle(parent, text, default, order, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 34)
    f.BackgroundColor3 = C.Btn
    f.LayoutOrder = order or 0
    f.Parent = parent
    Corner(f, 8)

    local ab = Instance.new("Frame")
    ab.Size = UDim2.new(0, 3, 0.45, 0)
    ab.Position = UDim2.new(0, 0, 0.275, 0)
    ab.BackgroundColor3 = C.Accent
    ab.BackgroundTransparency = default and 0.2 or 0.65
    ab.BorderSizePixel = 0
    ab.Parent = f
    Corner(ab, 2)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -58, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = C.Text
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f

    local tb = Instance.new("TextButton")
    tb.Size = UDim2.new(0, 40, 0, 20)
    tb.Position = UDim2.new(1, -50, 0.5, -10)
    tb.BackgroundColor3 = default and C.ToggleOn or C.ToggleOff
    tb.Text = ""
    tb.Parent = f
    Corner(tb, 10)

    local circ = Instance.new("Frame")
    circ.Size = UDim2.new(0, 16, 0, 16)
    circ.Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    circ.BackgroundColor3 = C.Text
    circ.Parent = tb
    Corner(circ, 8)

    local on = default

    tb.MouseButton1Click:Connect(function()
        on = not on
        if on then
            Tw(tb, {BackgroundColor3 = C.ToggleOn}, 0.2)
            Tw(circ, {Position = UDim2.new(1, -19, 0.5, -8)}, 0.2)
            Tw(ab, {BackgroundTransparency = 0.2}, 0.2)
        else
            Tw(tb, {BackgroundColor3 = C.ToggleOff}, 0.2)
            Tw(circ, {Position = UDim2.new(0, 2, 0.5, -8)}, 0.2)
            Tw(ab, {BackgroundTransparency = 0.65}, 0.2)
        end
        if cb then cb(on) end
    end)

    return {
        Frame = f,
        SetState = function(s)
            on = s
            if on then
                tb.BackgroundColor3 = C.ToggleOn
                circ.Position = UDim2.new(1, -19, 0.5, -8)
                ab.BackgroundTransparency = 0.2
            else
                tb.BackgroundColor3 = C.ToggleOff
                circ.Position = UDim2.new(0, 2, 0.5, -8)
                ab.BackgroundTransparency = 0.65
            end
        end,
        GetState = function() return on end
    }
end

local function Slider(parent, text, min, max, default, order, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 54)
    f.BackgroundColor3 = C.Btn
    f.LayoutOrder = order or 0
    f.Parent = parent
    Corner(f, 8)

    local ab = Instance.new("Frame")
    ab.Size = UDim2.new(0, 3, 0.45, 0)
    ab.Position = UDim2.new(0, 0, 0.275, 0)
    ab.BackgroundColor3 = C.Accent
    ab.BackgroundTransparency = 0.65
    ab.BorderSizePixel = 0
    ab.Parent = f
    Corner(ab, 2)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.55, 0, 0, 18)
    lbl.Position = UDim2.new(0, 14, 0, 5)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = C.Text
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f

    local defLbl = Instance.new("TextLabel")
    defLbl.Size = UDim2.new(0.45, -14, 0, 18)
    defLbl.Position = UDim2.new(0.55, 0, 0, 5)
    defLbl.BackgroundTransparency = 1
    defLbl.Text = "Default: " .. default
    defLbl.TextColor3 = C.Dim
    defLbl.TextSize = 11
    defLbl.Font = Enum.Font.Gotham
    defLbl.TextXAlignment = Enum.TextXAlignment.Right
    defLbl.Parent = f

    local sBG = Instance.new("Frame")
    sBG.Size = UDim2.new(1, -28, 0, 5)
    sBG.Position = UDim2.new(0, 14, 0, 30)
    sBG.BackgroundColor3 = C.SliderBG
    sBG.BorderSizePixel = 0
    sBG.Parent = f
    Corner(sBG, 3)

    local sFill = Instance.new("Frame")
    sFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sFill.BackgroundColor3 = C.SliderFill
    sFill.BorderSizePixel = 0
    sFill.Parent = sBG
    Corner(sFill, 3)

    local sKnob = Instance.new("TextButton")
    sKnob.Size = UDim2.new(0, 14, 0, 14)
    sKnob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    sKnob.BackgroundColor3 = C.Text
    sKnob.Text = ""
    sKnob.ZIndex = 2
    sKnob.Parent = sBG
    Corner(sKnob, 7)

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 50, 0, 18)
    valLbl.Position = UDim2.new(1, -58, 0, 5)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(default)
    valLbl.TextColor3 = C.AccentLight
    valLbl.TextSize = 14
    valLbl.Font = Enum.Font.GothamBold
    valLbl.Parent = f

    local cur = default
    local dragging = false

    local function Update(input)
        local r = math.clamp((input.Position.X - sBG.AbsolutePosition.X) / sBG.AbsoluteSize.X, 0, 1)
        local v = math.floor(min + (max - min) * r)
        cur = v
        sFill.Size = UDim2.new(r, 0, 1, 0)
        sKnob.Position = UDim2.new(r, -7, 0.5, -7)
        valLbl.Text = tostring(v)
        if cb then cb(v) end
    end

    sKnob.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then Update(i) end
    end)

    return {
        Frame = f,
        SetValue = function(v)
            v = math.clamp(v, min, max)
            cur = v
            local r = (v - min) / (max - min)
            sFill.Size = UDim2.new(r, 0, 1, 0)
            sKnob.Position = UDim2.new(r, -7, 0.5, -7)
            valLbl.Text = tostring(v)
        end,
        GetValue = function() return cur end
    }
end

local function Keybind(parent, text, defaultKey, order, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 34)
    f.BackgroundColor3 = C.Btn
    f.LayoutOrder = order or 0
    f.Parent = parent
    Corner(f, 8)

    local ab = Instance.new("Frame")
    ab.Size = UDim2.new(0, 3, 0.45, 0)
    ab.Position = UDim2.new(0, 0, 0.275, 0)
    ab.BackgroundColor3 = C.Accent
    ab.BackgroundTransparency = 0.65
    ab.BorderSizePixel = 0
    ab.Parent = f
    Corner(ab, 2)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.55, 0, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = C.Text
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f

    local kb = Instance.new("TextButton")
    kb.Size = UDim2.new(0.4, -14, 0, 24)
    kb.Position = UDim2.new(0.58, 0, 0.5, -12)
    kb.BackgroundColor3 = C.AccentDark
    kb.Text = defaultKey and defaultKey.Name or "None"
    kb.TextColor3 = C.Text
    kb.TextSize = 12
    kb.Font = Enum.Font.GothamMedium
    kb.Parent = f
    Corner(kb, 5)
    Stroke(kb, C.Accent, 1, 0.4)

    local waiting = false
    local curKey = defaultKey

    kb.MouseButton1Click:Connect(function()
        if waiting then return end
        waiting = true
        kb.Text = "..."
        Tw(kb, {BackgroundColor3 = C.Orange}, 0.15)

        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                curKey = input.KeyCode
                kb.Text = input.KeyCode.Name
                Tw(kb, {BackgroundColor3 = C.AccentDark}, 0.15)
                waiting = false
                conn:Disconnect()
                if cb then cb(input.KeyCode) end
            end
        end)
    end)

    return {
        Frame = f,
        GetKey = function() return curKey end,
        SetKey = function(k)
            curKey = k
            kb.Text = k and k.Name or "None"
        end
    }
end

local function InfoCard(parent, title, value, order)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1, 0, 0, 28)
    c.BackgroundColor3 = C.Btn
    c.LayoutOrder = order or 0
    c.Parent = parent
    Corner(c, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.45, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = C.Dim
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = c

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0.55, -10, 1, 0)
    val.Position = UDim2.new(0.45, 0, 0, 0)
    val.BackgroundTransparency = 1
    val.Text = value or "N/A"
    val.TextColor3 = C.Text
    val.TextSize = 12
    val.Font = Enum.Font.GothamMedium
    val.TextXAlignment = Enum.TextXAlignment.Left
    val.Parent = c

    return c
end

-- ============ ME TAB ============
local MeTab = TabFrames["Me"]
Section(MeTab, "PLAYER", 1)

local SpeedSlider = Slider(MeTab, "Speed", 1, 200, 16, 2, function(v) Config.Speed = v end)
local JumpSlider = Slider(MeTab, "Jump Power", 1, 200, 50, 3, function(v) Config.JumpPower = v end)
Slider(MeTab, "Gravity", 1, 200, 19, 4, function(v)
    Config.Gravity = v * 10
    workspace.Gravity = Config.Gravity
end)

Section(MeTab, "FLY", 5)

local flyTgl = Toggle(MeTab, "Fly (Shift-Lock Style)", false, 6, function(on)
    Config.FlyEnabled = on
    if on then
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bv = Instance.new("BodyVelocity")
                bv.Name = "PXFV"
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.zero
                bv.Parent = hrp

                local bg = Instance.new("BodyGyro")
                bg.Name = "PXFG"
                bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                bg.P = 9000
                bg.D = 500
                bg.Parent = hrp

                FlyConnection = RunService.RenderStepped:Connect(function()
                    if not Config.FlyEnabled then return end
                    local cam = workspace.CurrentCamera
                    local dir = Vector3.zero
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
                    if dir.Magnitude > 0 then dir = dir.Unit end
                    bv.Velocity = dir * Config.FlySpeed
                    bg.CFrame = cam.CFrame
                end)
            end
        end
    else
        if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bv = hrp:FindFirstChild("PXFV") if bv then bv:Destroy() end
                local bg = hrp:FindFirstChild("PXFG") if bg then bg:Destroy() end
            end
        end
    end
end)

Slider(MeTab, "Fly Speed", 1, 200, 50, 7, function(v) Config.FlySpeed = v end)

Section(MeTab, "MOVEMENT", 8)

Toggle(MeTab, "Click TP", false, 9, function(on)
    Config.ClickTPEnabled = on
    if on then
        ClickTPConn = LocalPlayer:GetMouse().Button1Down:Connect(function()
            if not Config.ClickTPEnabled then return end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                local char = LocalPlayer.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local mouse = LocalPlayer:GetMouse()
                        if mouse.Hit then
                            hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
                        end
                    end
                end
            end
        end)
    else
        if ClickTPConn then ClickTPConn:Disconnect() ClickTPConn = nil end
    end
end)

-- ============ VISUAL TAB ============
local VisTab = TabFrames["Visual"]
Section(VisTab, "ESP", 1)

local function RemoveAllESP()
    for p, o in pairs(ESPObjects) do
        if o.highlight then o.highlight:Destroy() end
        if o.billboard then o.billboard:Destroy() end
    end
    ESPObjects = {}
    for _, c in pairs(ESPConnections) do
        if c.Conn then c.Conn:Disconnect() end
    end
    ESPConnections = {}
end

local function AddESP(player)
    if player == LocalPlayer then return end
    if ESPConnections[player] then return end

    local function onChar(char)
        task.wait(0.5)
        if not Config.ESPPEnabled then return end
        local head = char:WaitForChild("Head", 5)
        if not head then return end

        local hl = Instance.new("Highlight")
        hl.Name = "PXESP_H"
        hl.FillColor = C.Accent
        hl.OutlineColor = Color3.new(1, 1, 1)
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0.1
        hl.Adornee = char
        hl.Parent = char

        local bb = Instance.new("BillboardGui")
        bb.Name = "PXESP_BB"
        bb.Size = UDim2.new(0, 220, 0, 44)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = true
        bb.Adornee = head
        bb.Parent = char

        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
        bg.BackgroundTransparency = 0.3
        bg.BorderSizePixel = 0
        bg.Parent = bb
        Corner(bg, 6)

        local al = Instance.new("Frame")
        al.Size = UDim2.new(0, 2, 1, 0)
        al.BackgroundColor3 = C.Accent
        al.BorderSizePixel = 0
        al.Parent = bg
        Corner(al, 1)

        local nl = Instance.new("TextLabel")
        nl.Size = UDim2.new(0.9, 0, 0.5, 0)
        nl.Position = UDim2.new(0.06, 0, 0, 0)
        nl.BackgroundTransparency = 1
        nl.Text = player.DisplayName
        nl.TextColor3 = C.AccentLight
        nl.TextSize = 13
        nl.Font = Enum.Font.GothamBold
        nl.TextXAlignment = Enum.TextXAlignment.Left
        nl.Parent = bg

        local ul = Instance.new("TextLabel")
        ul.Size = UDim2.new(0.9, 0, 0.5, 0)
        ul.Position = UDim2.new(0.06, 0, 0.5, 0)
        ul.BackgroundTransparency = 1
        ul.Text = "@" .. player.Name
        ul.TextColor3 = C.Dim
        ul.TextSize = 11
        ul.Font = Enum.Font.Gotham
        ul.TextXAlignment = Enum.TextXAlignment.Left
        ul.Parent = bg

        ESPObjects[player] = {highlight = hl, billboard = bb}
    end

    if player.Character then onChar(player.Character) end
    local conn = player.CharacterAdded:Connect(function(ch) if Config.ESPPEnabled then onChar(ch) end end)
    ESPConnections[player] = {Conn = conn}
end

Toggle(VisTab, "ESP (Player Highlight)", false, 2, function(on)
    Config.ESPPEnabled = on
    if on then
        for _, p in pairs(Players:GetPlayers()) do AddESP(p) end
        ESPConnections["PlayerAdded"] = {Conn = Players.PlayerAdded:Connect(function(p) if Config.ESPPEnabled then AddESP(p) end end)}
    else
        RemoveAllESP()
    end
end)

Section(VisTab, "LIGHTING", 3)

Toggle(VisTab, "Fullbright", false, 4, function(on)
    Config.FullbrightEnabled = on
    if on then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
    else
        Lighting.Brightness = 1
        Lighting.ClockTime = 12
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = true
        Lighting.Ambient = Color3.fromRGB(128, 128, 128)
    end
end)

Toggle(VisTab, "Bloom Shaders", false, 5, function(on)
    Config.BloomEnabled = on
    if on then
        if not Lighting:FindFirstChild("PXBloom") then
            local b = Instance.new("BloomEffect")
            b.Name = "PXBloom"
            b.Intensity = 0.8
            b.Size = 24
            b.Threshold = 1.5
            b.Parent = Lighting
        end
    else
        local b = Lighting:FindFirstChild("PXBloom")
        if b then b:Destroy() end
    end
end)

-- ============ TROLL TAB ============
local TrollTab = TabFrames["Troll"]
Section(TrollTab, "TARGET TOOL", 1)

local TargetToolTgl = Toggle(TrollTab, "Enable Target Tool", false, 2, function(on)
    Config.TargetToolEnabled = on
    if on then
        local tool = Instance.new("Tool")
        tool.Name = "PX_TargetTool"
        tool.CanBeDropped = false
        tool.RequiresHandle = false
        tool.Parent = LocalPlayer.Backpack

        tool.Activated:Connect(function()
            local mouse = LocalPlayer:GetMouse()
            local closest, closestDist = nil, 80

            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local root = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Head")
                    if root then
                        local sp, ok = workspace.CurrentCamera:WorldToScreenPoint(root.Position)
                        if ok then
                            local d = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(sp.X, sp.Y)).Magnitude
                            if d < closestDist then
                                closestDist = d
                                closest = p
                            end
                        end
                    end
                end
            end

            if closest then
                TargetPlayer = closest
                ShowTargetGUI(closest)
            end
        end)
    else
        for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
            if v.Name == "PX_TargetTool" then v:Destroy() end
        end
        local ch = LocalPlayer.Character
        if ch then
            for _, v in pairs(ch:GetChildren()) do
                if v.Name == "PX_TargetTool" then v:Destroy() end
            end
        end
        HideTargetGUI()
    end
end)

function ShowTargetGUI(player)
    HideTargetGUI()

    local gui = Instance.new("ScreenGui")
    gui.Name = "PXTargetGUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = CoreGui
    TargetGUI = gui

    local fr = Instance.new("Frame")
    fr.Size = UDim2.new(0, 280, 0, 280)
    fr.Position = UDim2.new(0, 15, 0, 15)
    fr.BackgroundColor3 = C.BG
    fr.BackgroundTransparency = 0.02
    fr.BorderSizePixel = 0
    fr.Parent = gui
    Corner(fr, 12)
    Stroke(fr, C.Accent, 2, 0.3)
    Drag(fr)

    local tg = Instance.new("Frame")
    tg.Size = UDim2.new(1, 6, 1, 6)
    tg.Position = UDim2.new(0, -3, 0, -3)
    tg.BackgroundColor3 = C.AccentGlow
    tg.BackgroundTransparency = 0.87
    tg.BorderSizePixel = 0
    tg.ZIndex = -1
    tg.Parent = fr
    Corner(tg, 15)

    local hd = Instance.new("Frame")
    hd.Size = UDim2.new(1, 0, 0, 36)
    hd.BackgroundColor3 = C.Dark
    hd.Parent = fr
    Corner(hd, 12)

    local hdf = Instance.new("Frame")
    hdf.Size = UDim2.new(1, 0, 0, 12)
    hdf.Position = UDim2.new(0, 0, 1, -12)
    hdf.BackgroundColor3 = C.Dark
    hdf.Parent = hd

    local ti = Instance.new("TextLabel")
    ti.Size = UDim2.new(1, -40, 1, 0)
    ti.Position = UDim2.new(0, 12, 0, 0)
    ti.BackgroundTransparency = 1
    ti.Text = player.DisplayName .. " (@" .. player.Name .. ")"
    ti.TextColor3 = C.AccentLight
    ti.TextSize = 13
    ti.Font = Enum.Font.GothamBold
    ti.TextXAlignment = Enum.TextXAlignment.Left
    ti.Parent = hd

    local xb = Instance.new("TextButton")
    xb.Size = UDim2.new(0, 25, 0, 25)
    xb.Position = UDim2.new(1, -30, 0, 5.5)
    xb.BackgroundColor3 = C.Red
    xb.Text = "X"
    xb.TextColor3 = C.Text
    xb.TextSize = 13
    xb.Font = Enum.Font.GothamBold
    xb.Parent = hd
    Corner(xb, 6)
    xb.MouseButton1Click:Connect(function() HideTargetGUI() end)

    local inf = Instance.new("Frame")
    inf.Size = UDim2.new(1, -16, 0, 118)
    inf.Position = UDim2.new(0, 8, 0, 42)
    inf.BackgroundColor3 = C.Dark
    inf.BackgroundTransparency = 0.2
    inf.Parent = fr
    Corner(inf, 8)

    local infLayout = Instance.new("UIListLayout", inf)
    infLayout.Padding = UDim.new(0, 2)
    infLayout.SortOrder = Enum.SortOrder.LayoutOrder

    InfoCard(inf, "Username:", player.Name, 1)
    InfoCard(inf, "Display:", player.DisplayName, 2)
    InfoCard(inf, "Account Age:", player.AccountAge .. " days", 3)

    local oldN = "N/A"
    pcall(function()
        local r = game:HttpGet("https://users.roblox.com/v1/users/" .. player.UserId)
        local d = HttpService:JSONDecode(r)
        if d and d.description then oldN = string.sub(d.description, 1, 40) or "N/A" end
    end)
    InfoCard(inf, "Old Names:", oldN, 4)

    local af = Instance.new("Frame")
    af.Size = UDim2.new(1, -16, 0, 115)
    af.Position = UDim2.new(0, 8, 0, 164)
    af.BackgroundTransparency = 1
    af.Parent = fr

    local afLayout = Instance.new("UIListLayout", af)
    afLayout.Padding = UDim.new(0, 4)
    afLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local hsBtn, bpBtn

    hsBtn = Toggle(af, "Headsit", false, 1, function(en)
        Config.HeadsitEnabled = en
        if en then
            Config.BackpackEnabled = false
            if bpBtn then bpBtn.SetState(false) end
            StartHeadsit(player)
        else
            StopHeadsit()
        end
    end)

    bpBtn = Toggle(af, "Backpack", false, 2, function(en)
        Config.BackpackEnabled = en
        if en then
            Config.HeadsitEnabled = false
            if hsBtn then hsBtn.SetState(false) end
            StartBackpack(player)
        else
            StopBackpack()
        end
    end)

    Btn(af, "Teleport to Player", 3, function()
        if player and player.Character then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local tHRP = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp and tHRP then hrp.CFrame = tHRP.CFrame * CFrame.new(0, 0, -5) end
        end
    end)
end

function StartHeadsit(player)
    StopHeadsit()
    StopBackpack()
    Config.HeadsitEnabled = true

    local function attach()
        if not Config.HeadsitEnabled then return end
        local my = LocalPlayer.Character
        local tgt = player.Character
        if not my or not tgt then return end
        local myHRP = my:FindFirstChild("HumanoidRootPart")
        local tgtHead = tgt:FindFirstChild("Head")
        if not myHRP or not tgtHead then return end

        local hum = my:FindFirstChild("Humanoid")
        if hum then hum.Sit = true end

        if HeadsitSeat then HeadsitSeat:Destroy() end

        local seat = Instance.new("Seat")
        seat.Name = "PXHS"
        seat.Size = Vector3.new(1, 1, 1)
        seat.Transparency = 1
        seat.Anchored = false
        seat.CanCollide = false
        seat.Parent = tgt
        HeadsitSeat = seat

        local w = Instance.new("Weld")
        w.Part0 = tgtHead
        w.Part1 = seat
        w.C0 = CFrame.new(0, 1.8, 0) * CFrame.Angles(0, math.rad(180), 0)
        w.Parent = seat

        myHRP.CFrame = seat.CFrame
        if hum then hum.Sit = true end

        for _, v in pairs(my:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end

    attach()

    HeadsitConn = RunService.Heartbeat:Connect(function()
        if not Config.HeadsitEnabled or not player.Character then StopHeadsit() return end
        local my = LocalPlayer.Character
        if not my then return end
        local hum = my:FindFirstChild("Humanoid")
        if hum then hum.Sit = true end
        for _, v in pairs(my:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end)

    player.CharacterRemoving:Connect(function() if Config.HeadsitEnabled then StopHeadsit() end end)
end

function StopHeadsit()
    Config.HeadsitEnabled = false
    if HeadsitConn then HeadsitConn:Disconnect() HeadsitConn = nil end
    if HeadsitSeat then HeadsitSeat:Destroy() HeadsitSeat = nil end
    local ch = LocalPlayer.Character
    if ch then local h = ch:FindFirstChild("Humanoid") if h then h.Sit = false end end
end

function StartBackpack(player)
    StopBackpack()
    StopHeadsit()
    Config.BackpackEnabled = true

    local function attach()
        if not Config.BackpackEnabled then return end
        local my = LocalPlayer.Character
        local tgt = player.Character
        if not my or not tgt then return end
        local myHRP = my:FindFirstChild("HumanoidRootPart")
        local tgtTorso = tgt:FindFirstChild("UpperTorso") or tgt:FindFirstChild("Torso")
        if not myHRP or not tgtTorso then return end

        local hum = my:FindFirstChild("Humanoid")
        if hum then hum.Sit = true end

        if BackpackSeat then BackpackSeat:Destroy() end

        local seat = Instance.new("Seat")
        seat.Name = "PXBP"
        seat.Size = Vector3.new(1, 1, 1)
        seat.Transparency = 1
        seat.Anchored = false
        seat.CanCollide = false
        seat.Parent = tgt
        BackpackSeat = seat

        local w = Instance.new("Weld")
        w.Part0 = tgtTorso
        w.Part1 = seat
        w.C0 = CFrame.new(0, 0, 2) * CFrame.Angles(0, math.rad(180), 0)
        w.Parent = seat

        myHRP.CFrame = seat.CFrame
        if hum then hum.Sit = true end

        for _, v in pairs(my:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end

    attach()

    BackpackConn = RunService.Heartbeat:Connect(function()
        if not Config.BackpackEnabled or not player.Character then StopBackpack() return end
        local my = LocalPlayer.Character
        if not my then return end
        local hum = my:FindFirstChild("Humanoid")
        if hum then hum.Sit = true end
        for _, v in pairs(my:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end)

    player.CharacterRemoving:Connect(function() if Config.BackpackEnabled then StopBackpack() end end)
end

function StopBackpack()
    Config.BackpackEnabled = false
    if BackpackConn then BackpackConn:Disconnect() BackpackConn = nil end
    if BackpackSeat then BackpackSeat:Destroy() BackpackSeat = nil end
    local ch = LocalPlayer.Character
    if ch then local h = ch:FindFirstChild("Humanoid") if h then h.Sit = false end end
end

function HideTargetGUI()
    StopHeadsit()
    StopBackpack()
    if TargetGUI then TargetGUI:Destroy() TargetGUI = nil end
end

-- ============ FUN TAB ============
local FunTab = TabFrames["Fun"]
Section(FunTab, "TROLL", 1)

Toggle(FunTab, "Fling", false, 2, function(on)
    Config.FlingEnabled = on
    if on then
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bg = Instance.new("BodyAngularVelocity")
                bg.Name = "PXFling"
                bg.AngularVelocity = Vector3.new(0, 25, 0)
                bg.MaxTorque = Vector3.new(0, math.huge, 0)
                bg.P = 1000000
                bg.Parent = hrp
                FlingConn = RunService.Heartbeat:Connect(function()
                    if not Config.FlingEnabled then return end
                    local c = LocalPlayer.Character
                    if c then
                        local r = c:FindFirstChild("HumanoidRootPart")
                        if r then r.Velocity = Vector3.new(0, 50, 0) end
                    end
                end)
            end
        end
    else
        if FlingConn then FlingConn:Disconnect() FlingConn = nil end
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bg = hrp:FindFirstChild("PXFling")
                if bg then bg:Destroy() end
                hrp.Velocity = Vector3.zero
                hrp.RotVelocity = Vector3.zero
            end
        end
    end
end)

Toggle(FunTab, "Big Head", false, 3, function(on)
    Config.BigHeadEnabled = on
    local char = LocalPlayer.Character
    if char then
        local head = char:FindFirstChild("Head")
        if head then
            local mesh = head:FindFirstChildOfClass("SpecialMesh")
            if mesh then
                if on then
                    mesh.Scale = Vector3.new(3, 3, 3)
                else
                    mesh.Scale = Vector3.new(1.25, 1.25, 1.25)
                end
            end
        end
    end
end)

Toggle(FunTab, "Spin Bot", false, 4, function(on)
    Config.SpinEnabled = on
    if on then
        SpinConn = RunService.Heartbeat:Connect(function()
            if not Config.SpinEnabled then return end
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(20), 0)
                end
            end
        end)
    else
        if SpinConn then SpinConn:Disconnect() SpinConn = nil end
    end
end)

Toggle(FunTab, "Moon Jump", false, 5, function(on)
    Config.MoonJumpEnabled = on
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if on then
                hum.JumpPower = 200
                hum.JumpHeight = 50
            else
                hum.JumpPower = 50
                hum.JumpHeight = 7.2
            end
        end
    end
end)

Toggle(FunTab, "Trail Creator", false, 6, function(on)
    if on then
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local att0 = Instance.new("Attachment")
                att0.Name = "PXTrail0"
                att0.Position = Vector3.new(0, 0.5, 0)
                att0.Parent = hrp

                local att1 = Instance.new("Attachment")
                att1.Name = "PXTrail1"
                att1.Position = Vector3.new(0, -0.5, 0)
                att1.Parent = hrp

                local trail = Instance.new("Trail")
                trail.Name = "PXTrail"
                trail.Attachment0 = att0
                trail.Attachment1 = att1
                trail.Lifetime = 1.5
                trail.MinLength = 0.1
                trail.LightEmission = 1
                trail.LightInfluence = 0
                trail.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1)
                })
                trail.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 50, 170)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 100, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                })
                trail.WidthScale = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0)
                })
                trail.Parent = hrp
                TrailObj = trail
            end
        end
    else
        if TrailObj then TrailObj:Destroy() TrailObj = nil end
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local att0 = hrp:FindFirstChild("PXTrail0")
                local att1 = hrp:FindFirstChild("PXTrail1")
                if att0 then att0:Destroy() end
                if att1 then att1:Destroy() end
            end
        end
    end
end)

Btn(FunTab, "Ragdoll", 7, function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = true
        end
    end
end)

Btn(FunTab, "Unragdoll", 8, function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
        end
    end
end)

Section(FunTab, "ITEM EQUIPPER", 9)

local ItemIdBox = Instance.new("TextBox")
ItemIdBox.Name = "ItemIdBox"
ItemIdBox.Size = UDim2.new(0, 160, 0, 28)
ItemIdBox.Position = UDim2.new(0, 12, 0, 0)
ItemIdBox.BackgroundColor3 = C.InputBG
ItemIdBox.TextColor3 = C.Text
ItemIdBox.PlaceholderText = "Item / Asset ID..."
ItemIdBox.PlaceholderColor3 = C.Dim
ItemIdBox.TextSize = 12
ItemIdBox.Font = Enum.Font.Gotham
ItemIdBox.ClearTextOnFocus = false
ItemIdBox.TextXAlignment = Enum.TextXAlignment.Left
ItemIdBox.Parent = FunTab
Corner(ItemIdBox, 6)
Stroke(ItemIdBox, C.Accent, 1, 0.5)

local PaddingId = Instance.new("UIPadding")
PaddingId.PaddingLeft = UDim.new(0, 8)
PaddingId.Parent = ItemIdBox

local EquipBtn = Instance.new("TextButton")
EquipBtn.Name = "EquipBtn"
EquipBtn.Size = UDim2.new(0, 75, 0, 28)
EquipBtn.Position = UDim2.new(0, 180, 0, 0)
EquipBtn.BackgroundColor3 = C.Accent
EquipBtn.Text = "Equip"
EquipBtn.TextColor3 = C.Text
EquipBtn.TextSize = 12
EquipBtn.Font = Enum.Font.GothamBold
EquipBtn.Parent = FunTab
Corner(EquipBtn, 6)

local UnequipBtn = Instance.new("TextButton")
UnequipBtn.Name = "UnequipBtn"
UnequipBtn.Size = UDim2.new(0, 75, 0, 28)
UnequipBtn.Position = UDim2.new(0, 260, 0, 0)
UnequipBtn.BackgroundColor3 = C.Red
UnequipBtn.Text = "Remove"
UnequipBtn.TextColor3 = C.Text
UnequipBtn.TextSize = 12
UnequipBtn.Font = Enum.Font.GothamBold
UnequipBtn.Parent = FunTab
Corner(UnequipBtn, 6)

local ItemStatus = Instance.new("TextLabel")
ItemStatus.Name = "ItemStatus"
ItemStatus.Size = UDim2.new(0, 340, 0, 16)
ItemStatus.Position = UDim2.new(0, 12, 0, 34)
ItemStatus.BackgroundTransparency = 1
ItemStatus.Text = ""
ItemStatus.TextColor3 = C.Dim
ItemStatus.TextSize = 10
ItemStatus.Font = Enum.Font.Gotham
ItemStatus.TextXAlignment = Enum.TextXAlignment.Left
ItemStatus.Parent = FunTab

local CurrentEquippedItem = nil

EquipBtn.MouseButton1Click:Connect(function()
    local itemId = ItemIdBox.Text:match("%d+")
    if not itemId then
        ItemStatus.Text = "Ungueltige Item ID!"
        ItemStatus.TextColor3 = C.Red
        return
    end

    ItemStatus.Text = "Laedt Item..."
    ItemStatus.TextColor3 = C.Orange

    local char = LocalPlayer.Character
    if not char then
        ItemStatus.Text = "Kein Charakter gefunden!"
        ItemStatus.TextColor3 = C.Red
        return
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then
        ItemStatus.Text = "Kein Humanoid gefunden!"
        ItemStatus.TextColor3 = C.Red
        return
    end

    local model = nil
    local success = false

    success, model = pcall(function()
        return game:GetObjects("rbxassetid://" .. itemId)[1]
    end)

    if not success or not model then
        success, model = pcall(function()
            return game:GetService("InsertService"):LoadAsset(tonumber(itemId)):GetChildren()[1]
        end)
    end

    if not success or not model then
        local rawModel = nil
        success, rawModel = pcall(function()
            local objects = game:GetObjects("rbxassetid://" .. itemId)
            if objects and #objects > 0 then return objects[1] end
            return nil
        end)
        if success and rawModel then
            model = rawModel
        end
    end

    if not success or not model then
        ItemStatus.Text = "Item konnte nicht geladen werden! (ID: " .. itemId .. ")"
        ItemStatus.TextColor3 = C.Red
        return
    end

    local accessory = nil

    if model:IsA("Accessory") then
        accessory = model
    else
        for _, v in pairs(model:GetDescendants()) do
            if v:IsA("Accessory") then
                accessory = v
                break
            end
        end
    end

    if not accessory then
        if model:IsA("Shirt") or model:IsA("Pants") or model:IsA("ShirtGraphic") then
            local clone = model:Clone()
            clone.Parent = char
            ItemStatus.Text = "Kleidung angezogen! (ID: " .. itemId .. ")"
            ItemStatus.TextColor3 = C.Green
            CurrentEquippedItem = clone
            return
        elseif model:IsA("Tool") or model:IsA("HopperBin") then
            local clone = model:Clone()
            clone.Parent = char
            ItemStatus.Text = "Tool equippt! (ID: " .. itemId .. ")"
            ItemStatus.TextColor3 = C.Green
            CurrentEquippedItem = clone
            return
        else
            ItemStatus.Text = "Kein Accessory/Kleidung in diesem Item gefunden! (Typ: " .. model.ClassName .. ")"
            ItemStatus.TextColor3 = C.Red
            pcall(function() model:Destroy() end)
            return
        end
    end

    if CurrentEquippedItem then
        pcall(function() CurrentEquippedItem:Destroy() end)
    end

    local clone = accessory:Clone()
    pcall(function()
        hum:AddAccessory(clone)
    end)
    CurrentEquippedItem = clone

    ItemStatus.Text = "Access equipped! (ID: " .. itemId .. ")"
    ItemStatus.TextColor3 = C.Green
end)

UnequipBtn.MouseButton1Click:Connect(function()
    if CurrentEquippedItem then
        pcall(function() CurrentEquippedItem:Destroy() end)
        CurrentEquippedItem = nil
        ItemStatus.Text = "Item entfernt!"
        ItemStatus.TextColor3 = C.Green
    else
        ItemStatus.Text = "Kein Item zum Entfernen!"
        ItemStatus.TextColor3 = C.Orange
    end
end)

-- ============ SOCIAL TAB ============
local SocialTab = TabFrames["Social"]
Section(SocialTab, "SPECTATE", 1)

local spectateTargetLabel = nil

Btn(SocialTab, "Spectate Target", 2, function()
    if TargetPlayer and TargetPlayer.Character then
        local hum = TargetPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            workspace.CurrentCamera.CameraSubject = hum
            Config.Spectating = TargetPlayer
        end
    end
end)

Btn(SocialTab, "Stop Spectate", 3, function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            workspace.CurrentCamera.CameraSubject = hum
        end
    end
    Config.Spectating = nil
end)

Section(SocialTab, "EMOTES", 4)

Btn(SocialTab, "Dance 1", 5, function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://507771019"
            local animTrack = hum:LoadAnimation(anim)
            animTrack:Play()
        end
    end
end)

Btn(SocialTab, "Dance 2", 6, function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://507776043"
            local animTrack = hum:LoadAnimation(anim)
            animTrack:Play()
        end
    end
end)

Btn(SocialTab, "Wave", 7, function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://507770239"
            local animTrack = hum:LoadAnimation(anim)
            animTrack:Play()
        end
    end
end)

Btn(SocialTab, "Laugh", 8, function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://507770818"
            local animTrack = hum:LoadAnimation(anim)
            animTrack:Play()
        end
    end
end)

Btn(SocialTab, "Cheer", 9, function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://507770677"
            local animTrack = hum:LoadAnimation(anim)
            animTrack:Play()
        end
    end
end)

Btn(SocialTab, "Point", 10, function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://507770453"
            local animTrack = hum:LoadAnimation(anim)
            animTrack:Play()
        end
    end
end)

-- ============ MISC TAB ============
local MiscTab = TabFrames["Misc"]
Section(MiscTab, "SERVER", 1)

Toggle(MiscTab, "Anti-AFK", false, 2, function(on)
    Config.AntiAFKEnabled = on
    if on then
        AntiAFKConn = game:GetService("Players").LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    else
        if AntiAFKConn then AntiAFKConn:Disconnect() AntiAFKConn = nil end
    end
end)

Btn(MiscTab, "Rejoin Server", 3, function()
    local suc, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end)
    if not suc then warn("[PX-Menu] Rejoin failed: " .. tostring(err)) end
end)

Btn(MiscTab, "Server Hop", 4, function()
    pcall(function()
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        if servers and servers.data then
            for _, server in pairs(servers.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    break
                end
            end
        end
    end)
end)

Btn(MiscTab, "Copy Server ID", 5, function()
    if setclipboard then
        setclipboard(game.JobId)
    end
end)

Section(MiscTab, "SCRIPTS", 6)

Btn(MiscTab, "Free Emotes", 7, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Emotes.lua"))()
end)

Btn(MiscTab, "Anti VC Ban", 8, function()
    getgenv().SCRIPT_KEY = "KEYLESS"
    loadstring(game:HttpGet("https://api.jnkie.com/api/v1/luascripts/public/d1344fdffb6e839857e16642403fd6619eb00b95ad39d19d0196b383988b99d9/download"))()
end)

Btn(MiscTab, "Infinity Yield", 9, function()
    loadstring(game:HttpGet(('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'),true))()
end)

Section(MiscTab, "PLAYER LIST", 10)

Btn(MiscTab, "Open Player List", 11, function()
    OpenPlayerListGUI()
end)

Section(MiscTab, "CUSTOM SCRIPT", 12)

local CustomInput = Instance.new("Frame")
CustomInput.Size = UDim2.new(1, 0, 0, 80)
CustomInput.BackgroundColor3 = C.Btn
CustomInput.LayoutOrder = 13
CustomInput.Parent = MiscTab
Corner(CustomInput, 8)

local ciLabel = Instance.new("TextLabel")
ciLabel.Size = UDim2.new(1, -16, 0, 20)
ciLabel.Position = UDim2.new(0, 8, 0, 4)
ciLabel.BackgroundTransparency = 1
ciLabel.Text = "Script Editor"
ciLabel.TextColor3 = C.AccentLight
ciLabel.TextSize = 12
ciLabel.Font = Enum.Font.GothamBold
ciLabel.TextXAlignment = Enum.TextXAlignment.Left
ciLabel.Parent = CustomInput

local ciBox = Instance.new("TextBox")
ciBox.Size = UDim2.new(1, -16, 0, 34)
ciBox.Position = UDim2.new(0, 8, 0, 24)
ciBox.BackgroundColor3 = C.InputBG
ciBox.Text = ""
ciBox.PlaceholderText = "Paste your Lua script here..."
ciBox.PlaceholderColor3 = C.Dim
ciBox.TextColor3 = C.Text
ciBox.TextSize = 11
ciBox.Font = Enum.Font.Code
ciBox.ClearTextOnFocus = false
ciBox.MultiLine = true
ciBox.TextXAlignment = Enum.TextXAlignment.Left
ciBox.TextYAlignment = Enum.TextYAlignment.Top
ciBox.Parent = CustomInput
Corner(ciBox, 5)
Stroke(ciBox, C.Accent, 1, 0.5)

Btn(MiscTab, "Execute Script", 14, function()
    local t = ciBox.Text
    if t and t ~= "" then
        local s, e = pcall(function() loadstring(t)() end)
        if not s then warn("[PX-Menu] Error: " .. tostring(e)) end
    end
end)

-- ============ SETTINGS TAB ============
local SetTab = TabFrames["Settings"]
Section(SetTab, "NAMETAGS", 1)

Toggle(SetTab, "NameTags", true, 2, function(on)
    NametagEnabled = on
    if not on then
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local tag = hrp:FindFirstChild("PXNametag")
                if tag then tag:Destroy() end
            end
        end
    else
        UpdateOwnNametag()
    end
end)

Section(SetTab, "KEYBINDS", 3)

local menuKb = Keybind(SetTab, "Toggle Menu", Config.ToggleKey, 4, function(k) Config.ToggleKey = k end)
local speedKb = Keybind(SetTab, "Speed (Hold)", Config.Hotkeys.Speed, 5, function(k) Config.Hotkeys.Speed = k end)
local jumpKb = Keybind(SetTab, "Jump Power (Hold)", Config.Hotkeys.JumpPower, 6, function(k) Config.Hotkeys.JumpPower = k end)
local gravKb = Keybind(SetTab, "Gravity", Config.Hotkeys.Gravity, 7, function(k) Config.Hotkeys.Gravity = k end)
local flyKb = Keybind(SetTab, "Fly", Config.Hotkeys.Fly, 8, function(k) Config.Hotkeys.Fly = k end)
local espKb = Keybind(SetTab, "ESP", Config.Hotkeys.ESP, 9, function(k) Config.Hotkeys.ESP = k end)
local fbKb = Keybind(SetTab, "Fullbright", Config.Hotkeys.Fullbright, 10, function(k) Config.Hotkeys.Fullbright = k end)
local blKb = Keybind(SetTab, "Bloom", Config.Hotkeys.Bloom, 11, function(k) Config.Hotkeys.Bloom = k end)
local ttKb = Keybind(SetTab, "Target Tool", Config.Hotkeys.TargetTool, 12, function(k) Config.Hotkeys.TargetTool = k end)

Section(SetTab, "INFO", 13)

Btn(SetTab, "Destroy Menu", 14, function()
    Config.FlyEnabled = false
    Config.ESPPEnabled = false
    Config.FullbrightEnabled = false
    Config.BloomEnabled = false
    Config.TargetToolEnabled = false
    Config.AntiAFKEnabled = false
    Config.ClickTPEnabled = false
    Config.SpinEnabled = false
    Config.FlingEnabled = false
    Config.BigHeadEnabled = false
    Config.MoonJumpEnabled = false
    Config.TrailEnabled = false
    StopHeadsit()
    StopBackpack()
    if FlyConnection then FlyConnection:Disconnect() end
    if AntiAFKConn then AntiAFKConn:Disconnect() end
    if ClickTPConn then ClickTPConn:Disconnect() end
    if SpinConn then SpinConn:Disconnect() SpinConn = nil end
    if FlingConn then FlingConn:Disconnect() FlingConn = nil end
    if SpectateConn then SpectateConn:Disconnect() SpectateConn = nil end
    if TrailObj then TrailObj:Destroy() TrailObj = nil end
    RemoveAllESP()
    HideTargetGUI()
    if PlayerListGUI then PlayerListGUI:Destroy() PlayerListGUI = nil end
    workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    IG:Destroy()
    ScreenGui:Destroy()
end)

-- ============ CLOSE & MINIMIZE ============
XBtn.MouseButton1Click:Connect(function()
    Config.FlyEnabled = false
    flyTgl.SetState(false)
    if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
    local ch = LocalPlayer.Character
    if ch then
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bv = hrp:FindFirstChild("PXFV") if bv then bv:Destroy() end
            local bg = hrp:FindFirstChild("PXFG") if bg then bg:Destroy() end
        end
    end
    MenuOpen = false
    MF.Visible = false
end)

MBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    if Minimized then
        MBtn.Text = "+"
        Tw(MF, {Size = UDim2.new(0, 520, 0, 88)}, 0.25)
    else
        MBtn.Text = "-"
        Tw(MF, {Size = UDim2.new(0, 520, 0, 420)}, 0.25)
    end
end)

-- ============ KEYBIND HANDLER ============
-- Helper: check if a key is bound (not nil)
local function IsBound(key) return key ~= nil end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    if input.KeyCode == Config.ToggleKey then
        MenuOpen = not MenuOpen
        MF.Visible = MenuOpen
    end

    -- Speed Hold
    if IsBound(Config.Hotkeys.Speed) and input.KeyCode == Config.Hotkeys.Speed then
        SpeedHeld = true
        task.spawn(function()
            while SpeedHeld do
                local ch = LocalPlayer.Character
                if ch and ch:FindFirstChild("Humanoid") then
                    ch.Humanoid.WalkSpeed = Config.Speed
                end
                task.wait(0.05)
            end
        end)
    end

    -- JumpPower Hold
    if IsBound(Config.Hotkeys.JumpPower) and input.KeyCode == Config.Hotkeys.JumpPower then
        JumpPowerHeld = true
        task.spawn(function()
            while JumpPowerHeld do
                local ch = LocalPlayer.Character
                if ch and ch:FindFirstChild("Humanoid") then
                    ch.Humanoid.JumpPower = Config.JumpPower
                end
                task.wait(0.05)
            end
        end)
    end

    if IsBound(Config.Hotkeys.Gravity) and input.KeyCode == Config.Hotkeys.Gravity then
        workspace.Gravity = Config.Gravity
    end

    if IsBound(Config.Hotkeys.Fly) and input.KeyCode == Config.Hotkeys.Fly then
        flyTgl.SetState(not flyTgl.GetState())
    end

    if IsBound(Config.Hotkeys.ESP) and input.KeyCode == Config.Hotkeys.ESP then
        -- find the ESP toggle and flip it
    end
end)

UserInputService.InputEnded:Connect(function(input)
    -- Only process if it's actually a keyboard key matching our binds
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

    if IsBound(Config.Hotkeys.Speed) and input.KeyCode == Config.Hotkeys.Speed then
        SpeedHeld = false
        local ch = LocalPlayer.Character
        if ch and ch:FindFirstChild("Humanoid") then
            ch.Humanoid.WalkSpeed = 16
        end
    end

    if IsBound(Config.Hotkeys.JumpPower) and input.KeyCode == Config.Hotkeys.JumpPower then
        JumpPowerHeld = false
        local ch = LocalPlayer.Character
        if ch and ch:FindFirstChild("Humanoid") then
            ch.Humanoid.JumpPower = 50
        end
    end
end)

-- Respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if Config.FlyEnabled then
        flyTgl.SetState(false)
        task.wait(0.1)
        flyTgl.SetState(true)
    end
end)

-- ============ PLAYER LIST GUI ============
function OpenPlayerListGUI()
    if PlayerListGUI then PlayerListGUI:Destroy() PlayerListGUI = nil end

    local gui = Instance.new("ScreenGui")
    gui.Name = "PXPlayerList"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = CoreGui
    PlayerListGUI = gui

    local fr = Instance.new("Frame")
    fr.Size = UDim2.new(0, 320, 0, 400)
    fr.Position = UDim2.new(0.5, -160, 0.5, -200)
    fr.BackgroundColor3 = C.BG
    fr.BackgroundTransparency = 0.02
    fr.BorderSizePixel = 0
    fr.Parent = gui
    Corner(fr, 14)
    Stroke(fr, C.Accent, 2, 0.3)
    Drag(fr)

    local tg = Instance.new("Frame")
    tg.Size = UDim2.new(1, 6, 1, 6)
    tg.Position = UDim2.new(0, -3, 0, -3)
    tg.BackgroundColor3 = C.AccentGlow
    tg.BackgroundTransparency = 0.87
    tg.BorderSizePixel = 0
    tg.ZIndex = -1
    tg.Parent = fr
    Corner(tg, 17)

    local hd = Instance.new("Frame")
    hd.Size = UDim2.new(1, 0, 0, 40)
    hd.BackgroundColor3 = C.Dark
    hd.Parent = fr
    Corner(hd, 14)

    local hdf = Instance.new("Frame")
    hdf.Size = UDim2.new(1, 0, 0, 14)
    hdf.Position = UDim2.new(0, 0, 1, -14)
    hdf.BackgroundColor3 = C.Dark
    hdf.Parent = hd

    local ti = Instance.new("TextLabel")
    ti.Size = UDim2.new(1, -50, 1, 0)
    ti.Position = UDim2.new(0, 14, 0, 0)
    ti.BackgroundTransparency = 1
    ti.Text = "Players (" .. #Players:GetPlayers() .. ")"
    ti.TextColor3 = C.AccentLight
    ti.TextSize = 15
    ti.Font = Enum.Font.GothamBold
    ti.TextXAlignment = Enum.TextXAlignment.Left
    ti.Parent = hd

    local xb = Instance.new("TextButton")
    xb.Size = UDim2.new(0, 25, 0, 25)
    xb.Position = UDim2.new(1, -32, 0, 7.5)
    xb.BackgroundColor3 = C.Red
    xb.Text = "X"
    xb.TextColor3 = C.Text
    xb.TextSize = 13
    xb.Font = Enum.Font.GothamBold
    xb.Parent = hd
    Corner(xb, 6)
    xb.MouseButton1Click:Connect(function() gui:Destroy() PlayerListGUI = nil end)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -12, 1, -48)
    scroll.Position = UDim2.new(0, 6, 0, 44)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = C.Accent
    scroll.BorderSizePixel = 0
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = fr

    Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 4)
    scroll.UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local pad = Instance.new("UIPadding", scroll)
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 4)
    pad.PaddingLeft = UDim.new(0, 2)
    pad.PaddingRight = UDim.new(0, 2)

    local function RefreshList()
        for _, child in pairs(scroll:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end

        local players = Players:GetPlayers()
        table.sort(players, function(a, b) return a.Name < b.Name end)

        for i, player in ipairs(players) do
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 50)
            row.BackgroundColor3 = C.Btn
            row.LayoutOrder = i
            row.Parent = scroll
            Corner(row, 8)

            if player == LocalPlayer then
                Stroke(row, C.Accent, 1, 0.5)
            end

            local avatar = Instance.new("Frame")
            avatar.Size = UDim2.new(0, 34, 0, 34)
            avatar.Position = UDim2.new(0, 6, 0.5, -17)
            avatar.BackgroundColor3 = C.AccentDark
            avatar.Parent = row
            Corner(avatar, 17)

            local avatarlbl = Instance.new("TextLabel")
            avatarlbl.Size = UDim2.new(1, 0, 1, 0)
            avatarlbl.BackgroundTransparency = 1
            avatarlbl.Text = string.sub(player.DisplayName, 1, 1)
            avatarlbl.TextColor3 = C.Text
            avatarlbl.TextSize = 15
            avatarlbl.Font = Enum.Font.GothamBold
            avatarlbl.Parent = avatar

            local namelbl = Instance.new("TextLabel")
            namelbl.Size = UDim2.new(0, 130, 0, 16)
            namelbl.Position = UDim2.new(0, 48, 0, 6)
            namelbl.BackgroundTransparency = 1
            namelbl.Text = player.DisplayName
            namelbl.TextColor3 = C.Text
            namelbl.TextSize = 13
            namelbl.Font = Enum.Font.GothamBold
            namelbl.TextXAlignment = Enum.TextXAlignment.Left
            namelbl.Parent = row

            local userlbl = Instance.new("TextLabel")
            userlbl.Size = UDim2.new(0, 130, 0, 14)
            userlbl.Position = UDim2.new(0, 48, 0, 24)
            userlbl.BackgroundTransparency = 1
            userlbl.Text = "@" .. player.Name
            userlbl.TextColor3 = C.Dim
            userlbl.TextSize = 11
            userlbl.Font = Enum.Font.Gotham
            userlbl.TextXAlignment = Enum.TextXAlignment.Left
            userlbl.Parent = row

            local ageLbl = Instance.new("TextLabel")
            ageLbl.Size = UDim2.new(0, 50, 0, 14)
            ageLbl.Position = UDim2.new(0, 48, 0, 38)
            ageLbl.BackgroundTransparency = 1
            ageLbl.Text = player.AccountAge .. "d"
            ageLbl.TextColor3 = C.Dim
            ageLbl.TextSize = 10
            ageLbl.Font = Enum.Font.Gotham
            ageLbl.TextXAlignment = Enum.TextXAlignment.Left
            ageLbl.Parent = row

            if player ~= LocalPlayer then
                local tpBtn = Instance.new("TextButton")
                tpBtn.Size = UDim2.new(0, 50, 0, 24)
                tpBtn.Position = UDim2.new(1, -120, 0.5, -12)
                tpBtn.BackgroundColor3 = C.AccentDark
                tpBtn.Text = "TP"
                tpBtn.TextColor3 = C.Text
                tpBtn.TextSize = 11
                tpBtn.Font = Enum.Font.GothamMedium
                tpBtn.Parent = row
                Corner(tpBtn, 5)

                tpBtn.MouseButton1Click:Connect(function()
                    if player.Character then
                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local tHRP = player.Character:FindFirstChild("HumanoidRootPart")
                        if hrp and tHRP then hrp.CFrame = tHRP.CFrame * CFrame.new(0, 0, -5) end
                    end
                end)

                local specBtn = Instance.new("TextButton")
                specBtn.Size = UDim2.new(0, 50, 0, 24)
                specBtn.Position = UDim2.new(1, -64, 0.5, -12)
                specBtn.BackgroundColor3 = C.AccentDark
                specBtn.Text = "..."
                specBtn.TextColor3 = C.Text
                specBtn.TextSize = 11
                specBtn.Font = Enum.Font.GothamMedium
                specBtn.Parent = row
                Corner(specBtn, 5)

                specBtn.MouseButton1Click:Connect(function()
                    TargetPlayer = player
                    ShowTargetGUI(player)
                end)
            else
                local meLbl = Instance.new("TextLabel")
                meLbl.Size = UDim2.new(0, 60, 0, 24)
                meLbl.Position = UDim2.new(1, -70, 0.5, -12)
                meLbl.BackgroundTransparency = 1
                meLbl.Text = "You"
                meLbl.TextColor3 = C.Accent
                meLbl.TextSize = 12
                meLbl.Font = Enum.Font.GothamBold
                meLbl.Parent = row
            end
        end
    end

    RefreshList()

    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size = UDim2.new(0, 80, 0, 26)
    refreshBtn.Position = UDim2.new(0.5, -40, 1, -36)
    refreshBtn.BackgroundColor3 = C.AccentDark
    refreshBtn.Text = "Refresh"
    refreshBtn.TextColor3 = C.Text
    refreshBtn.TextSize = 12
    refreshBtn.Font = Enum.Font.GothamMedium
    refreshBtn.Parent = fr
    Corner(refreshBtn, 6)
    Stroke(refreshBtn, C.Accent, 1, 0.4)

    refreshBtn.MouseButton1Click:Connect(function() RefreshList() end)

    Players.PlayerAdded:Connect(function()
        if PlayerListGUI and PlayerListGUI.Parent then
            ti.Text = "Players (" .. #Players:GetPlayers() .. ")"
            RefreshList()
        end
    end)

    Players.PlayerRemoving:Connect(function()
        if PlayerListGUI and PlayerListGUI.Parent then
            ti.Text = "Players (" .. #Players:GetPlayers() .. ")"
            RefreshList()
        end
    end)
end

-- ============ INIT ============
SwitchTab("Me")
MF.Visible = true
MenuOpen = true

print("[PX-Menu] v2.2 loaded! Executor: " .. ExecutorName .. " | Right Shift to toggle menu.")
