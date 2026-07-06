--[[
    Module-ESP.lua
    PX-Menu ESP Module
    Features: Highlight ESP, Billboard ESP
]]

return function(PX, page)
    local C = PX.Colors
    local State = PX.State
    
    PX.Label(page, "ESP - Spieler Markierung", C.accent)
    
    -- Highlight ESP
    PX.Toggle(page, "Highlight ESP", function(on)
        State.ESPEnabled = on
        if on then
            State.Connections.ESP = PX.Run.RenderStepped:Connect(function()
                for _, p in ipairs(PX.Players:GetPlayers()) do
                    if p ~= PX.LocalPlayer and p.Character then
                        if not p.Character:FindFirstChild("PXMenu_ESP_HL") then
                            local hl = Instance.new("Highlight")
                            hl.Name = "PXMenu_ESP_HL"
                            hl.FillColor = C.accentGlow
                            hl.FillTransparency = 0.5
                            hl.OutlineColor = C.text
                            hl.OutlineTransparency = 0
                            hl.Adornee = p.Character
                            hl.Parent = p.Character
                        end
                    end
                end
            end)
            State.Connections.ESPJoin = PX.Players.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function(char)
                    if State.ESPEnabled then
                        task.wait(1)
                        if not char:FindFirstChild("PXMenu_ESP_HL") then
                            local hl = Instance.new("Highlight")
                            hl.Name = "PXMenu_ESP_HL"
                            hl.FillColor = C.accentGlow
                            hl.FillTransparency = 0.5
                            hl.OutlineColor = C.text
                            hl.OutlineTransparency = 0
                            hl.Adornee = char
                            hl.Parent = char
                        end
                    end
                end)
            end)
        else
            if State.Connections.ESP then State.Connections.ESP:Disconnect() State.Connections.ESP = nil end
            if State.Connections.ESPJoin then State.Connections.ESPJoin:Disconnect() State.Connections.ESPJoin = nil end
            for _, p in ipairs(PX.Players:GetPlayers()) do
                if p.Character then
                    local hl = p.Character:FindFirstChild("PXMenu_ESP_HL")
                    if hl then hl:Destroy() end
                end
            end
        end
    end)
    
    PX.Sep(page)
    PX.Label(page, "ESP Billboard", C.accent)
    
    -- Billboard ESP
    PX.Toggle(page, "Billboard ESP", function(on)
        State.BillboardESP = on
        if on then
            State.Connections.BillboardESP = PX.Run.RenderStepped:Connect(function()
                for _, p in ipairs(PX.Players:GetPlayers()) do
                    if p ~= PX.LocalPlayer and p.Character then
                        local head = p.Character:FindFirstChild("Head")
                        if head and not head:FindFirstChild("PXMenu_ESP_BB") then
                            local b = Instance.new("BillboardGui", head)
                            b.Name = "PXMenu_ESP_BB"
                            b.Size = UDim2.new(0, 120, 0, 30)
                            b.StudsOffset = Vector3.new(0, 2.5, 0)
                            b.AlwaysOnTop = true
                            local t = Instance.new("TextLabel", b)
                            t.Size = UDim2.new(1, 0, 1, 0)
                            t.BackgroundTransparency = 1
                            t.Text = p.DisplayName .. " (@" .. p.Name .. ")"
                            t.TextColor3 = C.accentGlow
                            t.Font = Enum.Font.GothamBold
                            t.TextSize = 12
                            t.TextStrokeTransparency = 0.4
                        end
                    end
                end
            end)
        else
            if State.Connections.BillboardESP then State.Connections.BillboardESP:Disconnect() State.Connections.BillboardESP = nil end
            for _, p in ipairs(PX.Players:GetPlayers()) do
                if p.Character then
                    local head = p.Character:FindFirstChild("Head")
                    if head then
                        local bb = head:FindFirstChild("PXMenu_ESP_BB")
                        if bb then bb:Destroy() end
                    end
                end
            end
        end
    end)
    
    PX.Sep(page)
    PX.Label(page, "Distance ESP", C.accent)
    
    -- Distance ESP
    PX.Toggle(page, "Distance ESP", function(on)
        State.DistanceESP = on
        if on then
            State.Connections.DistanceESP = PX.Run.RenderStepped:Connect(function()
                for _, p in ipairs(PX.Players:GetPlayers()) do
                    if p ~= PX.LocalPlayer and p.Character then
                        local head = p.Character:FindFirstChild("Head")
                        local myHRP = PX.Character and PX.Character:FindFirstChild("HumanoidRootPart")
                        if head and myHRP and not head:FindFirstChild("PXMenu_ESP_DIST") then
                            local b = Instance.new("BillboardGui", head)
                            b.Name = "PXMenu_ESP_DIST"
                            b.Size = UDim2.new(0, 60, 0, 20)
                            b.StudsOffset = Vector3.new(0, 4, 0)
                            b.AlwaysOnTop = true
                            local t = Instance.new("TextLabel", b)
                            t.Name = "DistLabel"
                            t.Size = UDim2.new(1, 0, 1, 0)
                            t.BackgroundTransparency = 1
                            t.Text = ""
                            t.TextColor3 = C.green
                            t.Font = Enum.Font.Gotham
                            t.TextSize = 11
                            t.TextStrokeTransparency = 0.5
                        end
                        local b = head and head:FindFirstChild("PXMenu_ESP_DIST")
                        if b and myHRP then
                            local dist = math.floor((head.Position - myHRP.Position).Magnitude)
                            local lbl = b:FindFirstChild("DistLabel")
                            if lbl then lbl.Text = dist .. "m" end
                        end
                    end
                end
            end)
        else
            if State.Connections.DistanceESP then State.Connections.DistanceESP:Disconnect() State.Connections.DistanceESP = nil end
            for _, p in ipairs(PX.Players:GetPlayers()) do
                if p.Character then
                    local head = p.Character:FindFirstChild("Head")
                    if head then
                        local bb = head:FindFirstChild("PXMenu_ESP_DIST")
                        if bb then bb:Destroy() end
                    end
                end
            end
        end
    end)
end
