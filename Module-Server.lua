--[[
    Module-Server.lua
    PX-Menu Server Module
    Features: Anti AFK, Rejoin, Server Hop, Copy Job ID, Streamer Mode
]]

return function(PX, page)
    local C = PX.Colors
    local State = PX.State
    
    PX.Label(page, "Server Aktionen", C.accent)
    
    -- Anti AFK
    local antiAfkActive = false
    local antiAfkConn = nil
    
    PX.Toggle(page, "Anti AFK", function(on)
        antiAfkActive = on
        if on then
            antiAfkConn = PX.Run.Heartbeat:Connect(function()
                PX.SafeExec(function()
                    PX.VirtualUser:ClickButton1(Vector2.new(0, 0))
                end)
            end)
            PX.Notify("PX-Menu", "Anti-AFK aktiviert!")
        else
            if antiAfkConn then antiAfkConn:Disconnect() antiAfkConn = nil end
        end
    end)
    
    PX.Sep(page)
    PX.Label(page, "Server", C.accent)
    
    -- Rejoin
    PX.Btn(page, "Server beitreten", function()
        PX.Teleport:Teleport(game.PlaceId, PX.LocalPlayer)
    end)
    
    -- Server Hop
    PX.Btn(page, "Server Hop", function()
        PX.SafeExec(function()
            local servers = PX.Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
            if servers and servers.data then
                for _, server in pairs(servers.data) do
                    if server.id ~= game.JobId then
                        PX.Teleport:TeleportToPlaceInstance(game.PlaceId, server.id, PX.LocalPlayer)
                        break
                    end
                end
            end
        end)
    end)
    
    -- Copy Job ID
    PX.Btn(page, "Job ID kopieren", function()
        PX.SafeExec(function() if setclipboard then setclipboard(game.JobId) end end)
        PX.Notify("PX-Menu", "Job ID kopiert!")
    end)
    
    PX.Sep(page)
    PX.Label(page, "Modi", C.accent)
    
    -- Streamer Mode
    PX.Toggle(page, "Streamer Mode", function(on)
        if on then
            game.Name = "*** *** ***"
        else
            game.Name = "Roblox"
        end
    end)
    
    -- Remove Playerlist
    PX.Btn(page, "Eigene Spielerliste", function()
        if not PX.Pages then return end
        
        local playerListGui = Instance.new("ScreenGui")
        playerListGui.Name = "PXMenu_PlayerList"
        playerListGui.ResetOnSpawn = false
        playerListGui.Parent = PX.CoreGui
        
        local fr = Instance.new("Frame", playerListGui)
        fr.Size = UDim2.new(0, 350, 0, 450)
        fr.Position = UDim2.new(0.5, -175, 0.5, -225)
        fr.BackgroundColor3 = C.bg
        fr.BorderSizePixel = 0
        PX.Corner(fr, 8)
        PX.Stroke(fr, C.accentDark, 1)
        
        local ti = Instance.new("TextLabel", fr)
        ti.Size = UDim2.new(1, 0, 0, 36)
        ti.BackgroundColor3 = C.header
        ti.Text = "Players (" .. #PX.Players:GetPlayers() .. ")"
        ti.TextColor3 = C.accent
        ti.Font = Enum.Font.GothamBold
        ti.TextSize = 14
        ti.BorderSizePixel = 0
        PX.Corner(ti, 8)
        
        local scroll = Instance.new("ScrollingFrame", fr)
        scroll.Size = UDim2.new(1, -12, 1, -80)
        scroll.Position = UDim2.new(0, 6, 0, 42)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 3
        scroll.ScrollBarImageColor3 = C.accent
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 4)
        scroll.UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        
        local function RefreshList()
            for _, c in ipairs(scroll:GetChildren()) do
                if c:IsA("Frame") then c:Destroy() end
            end
            for i, player in ipairs(PX.Players:GetPlayers()) do
                local row = Instance.new("Frame", scroll)
                row.Size = UDim2.new(1, 0, 0, 56)
                row.BackgroundColor3 = C.card
                row.BorderSizePixel = 0
                row.LayoutOrder = i
                PX.Corner(row, 5)
                PX.Stroke(row, C.accentDark, 1)
                
                local avatar = Instance.new("ImageLabel", row)
                avatar.Size = UDim2.new(0, 40, 0, 40)
                avatar.Position = UDim2.new(0, 8, 0.5, -20)
                avatar.BackgroundColor3 = C.pillBg
                avatar.BorderSizePixel = 0
                PX.Corner(avatar, 6)
                pcall(function()
                    avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=100&height=100&format=png"
                end)
                
                local userlbl = Instance.new("TextLabel", row)
                userlbl.Size = UDim2.new(0, 130, 0, 14)
                userlbl.Position = UDim2.new(0, 48, 0, 14)
                userlbl.BackgroundTransparency = 1
                userlbl.Text = player.DisplayName
                userlbl.TextColor3 = C.text
                userlbl.TextSize = 12
                userlbl.Font = Enum.Font.GothamBold
                userlbl.TextXAlignment = Enum.TextXAlignment.Left
                
                local userlbl2 = Instance.new("TextLabel", row)
                userlbl2.Size = UDim2.new(0, 130, 0, 14)
                userlbl2.Position = UDim2.new(0, 48, 0, 28)
                userlbl2.BackgroundTransparency = 1
                userlbl2.Text = "@" .. player.Name
                userlbl2.TextColor3 = C.textDim
                userlbl2.TextSize = 11
                userlbl2.Font = Enum.Font.Gotham
                userlbl2.TextXAlignment = Enum.TextXAlignment.Left
                
                local ageLbl = Instance.new("TextLabel", row)
                ageLbl.Size = UDim2.new(0, 50, 0, 14)
                ageLbl.Position = UDim2.new(0, 48, 0, 42)
                ageLbl.BackgroundTransparency = 1
                ageLbl.Text = player.AccountAge .. "d"
                ageLbl.TextColor3 = C.textDim
                ageLbl.TextSize = 10
                ageLbl.Font = Enum.Font.Gotham
                ageLbl.TextXAlignment = Enum.TextXAlignment.Left
                
                if player ~= PX.LocalPlayer then
                    local tpBtn = Instance.new("TextButton", row)
                    tpBtn.Size = UDim2.new(0, 50, 0, 24)
                    tpBtn.Position = UDim2.new(1, -120, 0.5, -12)
                    tpBtn.BackgroundColor3 = C.accentDark
                    tpBtn.Text = "TP"
                    tpBtn.TextColor3 = C.text
                    tpBtn.TextSize = 11
                    tpBtn.Font = Enum.Font.GothamMedium
                    tpBtn.Parent = row
                    PX.Corner(tpBtn, 5)
                    tpBtn.MouseButton1Click:Connect(function()
                        if player.Character then
                            local hrp = PX.Character and PX.Character:FindFirstChild("HumanoidRootPart")
                            local tHRP = player.Character:FindFirstChild("HumanoidRootPart")
                            if hrp and tHRP then hrp.CFrame = tHRP.CFrame * CFrame.new(0, 0, -5) end
                        end
                    end)
                    
                    local specBtn = Instance.new("TextButton", row)
                    specBtn.Size = UDim2.new(0, 50, 0, 24)
                    specBtn.Position = UDim2.new(1, -64, 0.5, -12)
                    specBtn.BackgroundColor3 = C.accentDark
                    specBtn.Text = "..."
                    specBtn.TextColor3 = C.text
                    specBtn.TextSize = 11
                    specBtn.Font = Enum.Font.GothamMedium
                    specBtn.Parent = row
                    PX.Corner(specBtn, 5)
                    specBtn.MouseButton1Click:Connect(function()
                        if player.Character then
                            local head = player.Character:FindFirstChild("Head")
                            if head then PX.Camera.CameraSubject = head end
                        end
                    end)
                else
                    local meLbl = Instance.new("TextLabel", row)
                    meLbl.Size = UDim2.new(0, 60, 0, 24)
                    meLbl.Position = UDim2.new(1, -70, 0.5, -12)
                    meLbl.BackgroundTransparency = 1
                    meLbl.Text = "You"
                    meLbl.TextColor3 = C.accent
                    meLbl.TextSize = 12
                    meLbl.Font = Enum.Font.GothamBold
                    meLbl.Parent = row
                end
            end
        end
        
        RefreshList()
        
        local refreshBtn = Instance.new("TextButton", fr)
        refreshBtn.Size = UDim2.new(0, 80, 0, 26)
        refreshBtn.Position = UDim2.new(0.5, -40, 1, -36)
        refreshBtn.BackgroundColor3 = C.accentDark
        refreshBtn.Text = "Refresh"
        refreshBtn.TextColor3 = C.text
        refreshBtn.TextSize = 12
        refreshBtn.Font = Enum.Font.GothamMedium
        refreshBtn.Parent = fr
        PX.Corner(refreshBtn, 6)
        PX.Stroke(refreshBtn, C.accent, 1, 0.4)
        
        refreshBtn.MouseButton1Click:Connect(function() RefreshList() end)
        
        PX.Players.PlayerAdded:Connect(function()
            if playerListGui and playerListGui.Parent then
                ti.Text = "Players (" .. #PX.Players:GetPlayers() .. ")"
                RefreshList()
            end
        end)
        
        PX.Players.PlayerRemoving:Connect(function()
            if playerListGui and playerListGui.Parent then
                ti.Text = "Players (" .. #PX.Players:GetPlayers() .. ")"
                RefreshList()
            end
        end)
    end)
end
