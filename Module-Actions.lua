--[[
    Module-Actions.lua
    PX-Menu Actions Module
    Features: TP, Spectate, Fling, Sit All, Hitbox Expand
]]

return function(PX, page)
    local C = PX.Colors
    local State = PX.State
    
    PX.Label(page, "Spieler Aktionen", C.accent)
    
    local targetPlayer = nil
    local plList = PX.PlayerList(page, function(p) targetPlayer = p end, 120)
    
    PX.Btn(page, "Liste aktualisieren", function()
        plList.refresh()
    end)
    
    PX.Sep(page)
    PX.Label(page, "Teleport", C.accent)
    
    PX.Btn(page, "Zu Spieler TP", function()
        if targetPlayer and targetPlayer.Character then
            local t = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if t and PX.HRP then
                PX.HRP.CFrame = t.CFrame * CFrame.new(0, 0, -5)
            end
        end
    end)
    
    PX.Btn(page, "Hinter Spieler", function()
        if targetPlayer and targetPlayer.Character then
            local t = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if t and PX.HRP then
                PX.HRP.CFrame = t.CFrame * CFrame.new(0, 0, 5)
            end
        end
    end)
    
    PX.Btn(page, "Auf Spieler stehen", function()
        if targetPlayer and targetPlayer.Character then
            local t = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if t and PX.HRP then
                PX.HRP.CFrame = t.CFrame * CFrame.new(0, 3, 0)
            end
        end
    end)
    
    PX.Sep(page)
    PX.Label(page, "Spectate", C.accent)
    
    PX.Btn(page, "Spectate Spieler", function()
        if targetPlayer and targetPlayer.Character then
            local head = targetPlayer.Character:FindFirstChild("Head")
            if head then PX.Camera.CameraSubject = head end
        end
    end)
    
    PX.Btn(page, "Spectate Stoppen", function()
        if PX.Humanoid then PX.Camera.CameraSubject = PX.Humanoid end
    end)
    
    PX.Sep(page)
    PX.Label(page, "Fling Engine", C.accent)
    
    local flingActive = false
    local flingThread = nil
    local flingSavedCFrame = nil
    
    local function skidFling(target)
        local Character = PX.Character
        local Humanoid = PX.Humanoid
        local RootPart = PX.HRP
        local TCharacter = target and target.Character
        if not Character or not Humanoid or not RootPart or not TCharacter then return end
        
        local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
        local TRootPart = THumanoid and THumanoid.RootPart
        local THead = TCharacter:FindFirstChild("Head")
        local Handle = (TCharacter:FindFirstChildOfClass("Accessory") or {Handle=nil}).Handle
        local BasePart = TRootPart or THead or Handle
        if not BasePart then return end
        
        if RootPart.Velocity.Magnitude < 50 then
            flingSavedCFrame = RootPart.CFrame
        end
        if THumanoid and THumanoid.Sit then return end
        
        local savedFPDH = workspace.FallenPartsDestroyHeight
        workspace.FallenPartsDestroyHeight = 0/0
        
        local BV = Instance.new("BodyVelocity")
        BV.Parent = RootPart
        BV.Velocity = Vector3.new(0,0,0)
        BV.MaxForce = Vector3.new(9e9,9e9,9e9)
        
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        
        local FPos = function(bp, pos, ang)
            RootPart.CFrame = CFrame.new(bp.Position) * pos * ang
            pcall(function() Character:SetPrimaryPartCFrame(CFrame.new(bp.Position) * pos * ang) end)
            RootPart.Velocity = Vector3.new(9e7, 9e7*10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end
        
        local deadline = tick() + 2
        local angle = 0
        repeat
            if not (RootPart and RootPart.Parent and THumanoid and THumanoid.Parent) then break end
            if BasePart.Velocity.Magnitude < 50 then
                angle = angle + 100
                FPos(BasePart, CFrame.new(0,1.5,0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(angle),0,0)) task.wait()
                FPos(BasePart, CFrame.new(0,-1.5,0)+ THumanoid.MoveDirection * BasePart.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(angle),0,0)) task.wait()
            else
                FPos(BasePart, CFrame.new(0,1.5, THumanoid.WalkSpeed),  CFrame.Angles(math.rad(90),0,0)) task.wait()
                FPos(BasePart, CFrame.new(0,-1.5,-THumanoid.WalkSpeed), CFrame.Angles(0,0,0)) task.wait()
            end
        until tick() > deadline or not flingActive
        
        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.FallenPartsDestroyHeight = savedFPDH
    end
    
    PX.Btn(page, "Fling starten", function()
        if targetPlayer then
            flingActive = true
            flingThread = task.spawn(function()
                while flingActive do
                    skidFling(targetPlayer)
                    if flingActive then task.wait(0.1) end
                end
            end)
        end
    end)
    
    PX.Btn(page, "Fling stoppen", function()
        flingActive = false
        if flingThread then task.cancel(flingThread) flingThread = nil end
        PX.SafeExec(function()
            if PX.HRP and flingSavedCFrame then
                PX.HRP.CFrame = flingSavedCFrame
            end
        end)
    end)
    
    PX.Sep(page)
    PX.Label(page, "Alle Aktionen", C.accent)
    
    PX.Btn(page, "Alle Sitzen", function()
        for _, player in pairs(PX.Players:GetPlayers()) do
            if player ~= PX.LocalPlayer then
                PX.SafeExec(function() player.Character:FindFirstChildOfClass("Humanoid").Sit = true end)
            end
        end
    end)
    
    PX.Btn(page, "Alle TP zu mir", function()
        PX.SafeExec(function()
            local myPos = PX.HRP.CFrame
            for _, player in pairs(PX.Players:GetPlayers()) do
                if player ~= PX.LocalPlayer then
                    PX.SafeExec(function() player.Character:FindFirstChild("HumanoidRootPart").CFrame = myPos end)
                end
            end
        end)
    end)
    
    PX.Btn(page, "Void Alle", function()
        for _, player in pairs(PX.Players:GetPlayers()) do
            if player ~= PX.LocalPlayer then
                PX.SafeExec(function() player.Character:FindFirstChild("HumanoidRootPart").CFrame = CFrame.new(0, -500, 0) end)
            end
        end
    end)
    
    PX.Sep(page)
    PX.Label(page, "Hitbox", C.accent)
    
    PX.Slider(page, "Hitbox Expand", 5, 50, 5, function(val)
        PX.SafeExec(function()
            local head = PX.Character:FindFirstChild("Head")
            if head and val > 5 then
                head.Size = Vector3.new(val, val, val)
                head.Transparency = 0.7
                head.BrickColor = BrickColor.new("Really red")
                head.CanCollide = false
            elseif head then
                head.Size = Vector3.new(2, 1, 1)
                head.Transparency = 0
            end
        end)
    end)
end
