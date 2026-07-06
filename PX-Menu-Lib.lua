--[[
    PX-Menu Library v1.0
    Shared UI Components for all modules
    Colors: Gray + Dark Purple (#6432AA)
]]

local PX = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

PX.Players = Players
PX.UIS = UserInputService
PX.Run = RunService
PX.Tween = TweenService
PX.CoreGui = CoreGui
PX.Debris = Debris
PX.Lighting = Lighting
PX.Teleport = TeleportService
PX.VirtualUser = VirtualUser
PX.StarterGui = StarterGui
PX.Http = HttpService

PX.LocalPlayer = Players.LocalPlayer
PX.Mouse = PX.LocalPlayer:GetMouse()
PX.Camera = workspace.CurrentCamera

PX.Character = PX.LocalPlayer.Character or PX.LocalPlayer.CharacterAdded:Wait()
PX.HRP = PX.Character:WaitForChild("HumanoidRootPart")
PX.Humanoid = PX.Character:WaitForChild("Humanoid")

PX.LocalPlayer.CharacterAdded:Connect(function(char)
    PX.Character = char
    PX.HRP = char:WaitForChild("HumanoidRootPart")
    PX.Humanoid = char:WaitForChild("Humanoid")
end)

PX.Colors = {
    bg = Color3.fromRGB(24, 24, 32),
    header = Color3.fromRGB(30, 30, 40),
    card = Color3.fromRGB(36, 36, 50),
    cardHover = Color3.fromRGB(44, 44, 58),
    accent = Color3.fromRGB(100, 50, 170),
    accentDark = Color3.fromRGB(60, 30, 100),
    accentGlow = Color3.fromRGB(130, 70, 200),
    text = Color3.fromRGB(230, 230, 240),
    textDim = Color3.fromRGB(140, 140, 160),
    green = Color3.fromRGB(40, 200, 80),
    red = Color3.fromRGB(220, 40, 40),
    yellow = Color3.fromRGB(220, 180, 40),
    sep = Color3.fromRGB(40, 40, 55),
    pillBg = Color3.fromRGB(22, 22, 30),
    pillSel = Color3.fromRGB(100, 50, 170),
}

function PX.Corner(par, r)
    local c = Instance.new("UICorner", par)
    c.CornerRadius = UDim.new(0, r or 6)
    return c
end

function PX.Stroke(par, col, w)
    local s = Instance.new("UIStroke", par)
    s.Color = col or PX.Colors.accentDark
    s.Thickness = w or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

function PX.List(par, gap)
    local l = Instance.new("UIListLayout", par)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0, gap or 6)
    l.HorizontalAlignment = Enum.HorizontalAlignment.Left
    return l
end

function PX.Pad(par, t, b, l, r)
    local p = Instance.new("UIPadding", par)
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft = UDim.new(0, l or 0)
    p.PaddingRight = UDim.new(0, r or 0)
    return p
end

function PX.Label(parent, text, color)
    local f = Instance.new("TextLabel", parent)
    f.Size = UDim2.new(1, 0, 0, 20)
    f.BackgroundTransparency = 1
    f.Text = "  " .. text
    f.TextColor3 = color or PX.Colors.textDim
    f.Font = Enum.Font.GothamBold
    f.TextSize = 11
    f.TextXAlignment = Enum.TextXAlignment.Left
    f.AutomaticSize = Enum.AutomaticSize.Y
    return f
end

function PX.Separator(parent)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 1)
    f.BackgroundColor3 = PX.Colors.sep
    f.BorderSizePixel = 0
    return f
end

function PX.Card(parent, text, height)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, height or 42)
    f.BackgroundColor3 = PX.Colors.card
    f.BorderSizePixel = 0
    f.AutomaticSize = Enum.AutomaticSize.Y
    PX.Corner(f, 6)
    PX.Stroke(f, PX.Colors.accentDark, 1)
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1, -12, 0, 20)
    lbl.Position = UDim2.new(0, 10, 0, 8)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = PX.Colors.text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return f, lbl
end

function PX.Toggle(parent, text, callback)
    local f = PX.Card(parent, text, 36)
    local state = false
    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(0, 40, 0, 20)
    btn.Position = UDim2.new(1, -50, 0.5, -10)
    btn.BackgroundColor3 = PX.Colors.pillBg
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    PX.Corner(btn, 10)
    PX.Stroke(btn, PX.Colors.accentDark, 1)
    local indicator = Instance.new("Frame", btn)
    indicator.Size = UDim2.new(0, 16, 0, 16)
    indicator.Position = UDim2.new(0, 2, 0, 2)
    indicator.BackgroundColor3 = PX.Colors.textDim
    indicator.BorderSizePixel = 0
    PX.Corner(indicator, 8)
    btn.MouseButton1Click:Connect(function()
        state = not state
        indicator.BackgroundColor3 = state and PX.Colors.green or PX.Colors.textDim
        indicator.Position = state and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)
        btn.BackgroundColor3 = state and PX.Colors.accentDark or PX.Colors.pillBg
        if callback then callback(state) end
    end)
    return {
        set = function(v)
            state = v
            indicator.BackgroundColor3 = v and PX.Colors.green or PX.Colors.textDim
            indicator.Position = v and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)
            btn.BackgroundColor3 = v and PX.Colors.accentDark or PX.Colors.pillBg
        end,
        get = function() return state end
    }
end

function PX.Slider(parent, text, min, max, default, callback)
    local f = PX.Card(parent, text, 50)
    local val = default or min
    local valLabel = Instance.new("TextLabel", f)
    valLabel.Size = UDim2.new(0, 50, 0, 16)
    valLabel.Position = UDim2.new(1, -60, 0, 8)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(val)
    valLabel.TextColor3 = PX.Colors.accent
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 11
    local barBg = Instance.new("Frame", f)
    barBg.Size = UDim2.new(1, -24, 0, 6)
    barBg.Position = UDim2.new(0, 12, 1, -16)
    barBg.BackgroundColor3 = PX.Colors.pillBg
    barBg.BorderSizePixel = 0
    PX.Corner(barBg, 3)
    local barFill = Instance.new("Frame", barBg)
    barFill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
    barFill.BackgroundColor3 = PX.Colors.accent
    barFill.BorderSizePixel = 0
    PX.Corner(barFill, 3)
    local knob = Instance.new("Frame", barBg)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((val - min) / (max - min), -7, 0.5, -7)
    knob.BackgroundColor3 = PX.Colors.accentGlow
    knob.BorderSizePixel = 0
    knob.ZIndex = 2
    PX.Corner(knob, 7)
    local sliding = false
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
        end
    end)
    PX.UIS.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local absPos = barBg.AbsolutePosition.X
            local absSize = barBg.AbsoluteSize.X
            local rel = math.clamp((input.Position.X - absPos) / absSize, 0, 1)
            val = math.floor(min + rel * (max - min) + 0.5)
            barFill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, -7, 0.5, -7)
            valLabel.Text = tostring(val)
            if callback then callback(val) end
        end
    end)
    PX.UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
    return {
        set = function(v)
            v = math.clamp(v, min, max)
            val = v
            local rel = (v - min) / (max - min)
            barFill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, -7, 0.5, -7)
            valLabel.Text = tostring(v)
        end,
        get = function() return val end
    }
end

function PX.Button(parent, text, callback)
    local f = PX.Card(parent, text, 34)
    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(0, 50, 0, 22)
    btn.Position = UDim2.new(1, -60, 0.5, -11)
    btn.BackgroundColor3 = PX.Colors.accent
    btn.Text = ">>>"
    btn.TextColor3 = PX.Colors.text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    PX.Corner(btn, 4)
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = PX.Colors.accentGlow end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = PX.Colors.accent end)
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return f
end

function PX.Keybind(parent, text, default, callback)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 36)
    f.BackgroundColor3 = PX.Colors.card
    f.BorderSizePixel = 0
    PX.Corner(f, 6)
    PX.Stroke(f, PX.Colors.accentDark, 1)
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(0.55, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = PX.Colors.text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    local kbtn = Instance.new("TextButton", f)
    kbtn.Size = UDim2.new(0, 100, 0, 22)
    kbtn.Position = UDim2.new(1, -110, 0.5, -11)
    kbtn.BackgroundColor3 = PX.Colors.pillBg
    kbtn.Text = default or "None"
    kbtn.TextColor3 = PX.Colors.accent
    kbtn.Font = Enum.Font.GothamBold
    kbtn.TextSize = 10
    kbtn.BorderSizePixel = 0
    kbtn.AutoButtonColor = false
    PX.Corner(kbtn, 4)
    local waiting = false
    local currentBind = default
    kbtn.MouseButton1Click:Connect(function()
        if waiting then return end
        waiting = true
        kbtn.Text = "..."
        kbtn.BackgroundColor3 = PX.Colors.accent
    end)
    return {
        getBind = function() return currentBind end,
        setBind = function(v) currentBind = v; kbtn.Text = v or "None" end,
        isWaiting = function() return waiting end,
        accept = function(keyCode)
            if waiting then
                waiting = false
                currentBind = keyCode and keyCode.Name or nil
                kbtn.Text = currentBind or "None"
                kbtn.BackgroundColor3 = PX.Colors.pillBg
                if callback then callback(currentBind) end
            end
        end
    }
end

function PX.PlayerList(parent, onSelect, height)
    local results = {}
    local selected = nil
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, 0, 0, height or 160)
    container.BackgroundColor3 = PX.Colors.card
    container.BorderSizePixel = 0
    PX.Corner(container, 6)
    PX.Stroke(container, PX.Colors.accentDark, 1)
    local scroll = Instance.new("ScrollingFrame", container)
    scroll.Size = UDim2.new(1, -8, 1, -8)
    scroll.Position = UDim2.new(0, 4, 0, 4)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = PX.Colors.accent
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local layout = Instance.new("UIListLayout", scroll)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 2)

    local function refresh(filter)
        for _, c in ipairs(scroll:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        results = {}
        local idx = 0
        for _, p in ipairs(Players:GetPlayers()) do
            if not filter or filter == "" or string.find(string.lower(p.Name), string.lower(filter), 1, true) or string.find(string.lower(p.DisplayName), string.lower(filter), 1, true) then
                idx = idx + 1
                local btn = Instance.new("TextButton", scroll)
                btn.Size = UDim2.new(1, 0, 0, 28)
                btn.BackgroundColor3 = PX.Colors.pillBg
                btn.Text = "  " .. p.DisplayName .. " (@" .. p.Name .. ")"
                btn.TextColor3 = PX.Colors.textDim
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 11
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.BorderSizePixel = 0
                btn.AutoButtonColor = false
                btn.LayoutOrder = idx
                PX.Corner(btn, 4)
                btn.MouseEnter:Connect(function()
                    if selected ~= p then btn.BackgroundColor3 = PX.Colors.cardHover end
                end)
                btn.MouseLeave:Connect(function()
                    if selected ~= p then btn.BackgroundColor3 = PX.Colors.pillBg end
                end)
                btn.MouseButton1Click:Connect(function()
                    selected = p
                    for _, b in ipairs(scroll:GetChildren()) do
                        if b:IsA("TextButton") then b.BackgroundColor3 = PX.Colors.pillBg end
                    end
                    btn.BackgroundColor3 = PX.Colors.pillSel
                    if onSelect then onSelect(p) end
                end)
                table.insert(results, p)
            end
        end
    end

    refresh()

    return {
        refresh = refresh,
        selected = function() return selected end,
        getResults = function() return results end
    }
end

function PX.Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "PX-Menu",
            Text = text or "",
            Duration = duration or 3
        })
    end)
end

function PX.GetCharacter()
    return PX.Character, PX.HRP, PX.Humanoid
end

function PX.SafeExec(fn)
    local s, e = pcall(fn)
    if not s then warn("[PX-Menu] Error: " .. tostring(e)) end
    return s
end

return PX
