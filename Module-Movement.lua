--[[
    Module-Movement.lua
    PX-Menu Movement Module
    Features: Fly, Noclip, Speed, JumpPower, Gravity, FOV, Infinite Jump, Spin
]]

return function(PX, page)
    local C = PX.Colors
    local State = PX.State
    
    PX.Label(page, "Bewegung", C.accent)
    
    -- WalkSpeed
    PX.Slider(page, "WalkSpeed", 0, 500, 16, function(v)
        PX.SafeExec(function() PX.Humanoid.WalkSpeed = v end)
    end)
    
    -- JumpPower
    PX.Slider(page, "JumpPower", 0, 500, 50, function(v)
        PX.SafeExec(function()
            PX.Humanoid.UseJumpPower = true
            PX.Humanoid.JumpPower = v
        end)
    end)
    
    -- Gravity
    PX.Slider(page, "Schwerkraft", 0, 500, 196, function(v)
        workspace.Gravity = v
    end)
    
    -- FOV
    PX.Slider(page, "FOV", 30, 120, 70, function(v)
        workspace.CurrentCamera.FieldOfView = v
    end)
    
    PX.Sep(page)
    PX.Label(page, "Flug", C.accent)
    
    -- Fly Speed
    PX.Slider(page, "Flug Speed", 10, 800, 100, function(v)
        State.FlySpeed = v
    end)
    
    -- Fly Toggle
    local flyToggle = PX.Toggle(page, "Fliegen (WASD + Kamera)", function(on)
        State.FlyEnabled = on
        if on then
            PX.SafeExec(function()
                local bg = Instance.new("BodyGyro", PX.HRP)
                bg.P = 9000
                bg.D = 500
                bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                local bv = Instance.new("BodyVelocity", PX.HRP)
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.new(0, 0, 0)
                State.FlyBody = bv
                State.FlyGyro = bg
                State.Connections.Fly = PX.Run.RenderStepped:Connect(function()
                    if not PX.HRP or not PX.HRP.Parent then
                        pcall(function() bg:Destroy() bv:Destroy() end)
                        State.Connections.Fly:Disconnect()
                        return
                    end
                    local camCF = PX.Camera.CFrame
                    bg.CFrame = camCF
                    local moveDir = Vector3.new(0, 0, 0)
                    if PX.UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Vector3.new(0, 0, -1) end
                    if PX.UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir + Vector3.new(0, 0, 1) end
                    if PX.UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir + Vector3.new(-1, 0, 0) end
                    if PX.UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Vector3.new(1, 0, 0) end
                    if PX.UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                    if PX.UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir + Vector3.new(0, -1, 0) end
                    if moveDir.Magnitude > 0 then
                        local worldDir = (camCF * CFrame.new(moveDir)).Position - camCF.Position
                        if worldDir.Magnitude > 0 then
                            bv.Velocity = worldDir.Unit * State.FlySpeed
                        else
                            bv.Velocity = Vector3.new(0, 0, 0)
                        end
                    else
                        bv.Velocity = Vector3.new(0, 0, 0)
                    end
                end)
            end)
        else
            if State.Connections.Fly then State.Connections.Fly:Disconnect() State.Connections.Fly = nil end
            PX.SafeExec(function()
                if PX.HRP then
                    for _, c in ipairs(PX.HRP:GetChildren()) do
                        if c:IsA("BodyGyro") or c:IsA("BodyVelocity") then c:Destroy() end
                    end
                end
            end)
            State.FlyBody = nil
            State.FlyGyro = nil
        end
    end)
    
    PX.Sep(page)
    PX.Label(page, "Extras", C.accent)
    
    -- Noclip
    PX.Toggle(page, "Noclip", function(on)
        State.NoclipEnabled = on
        if on then
            State.Connections.Noclip = PX.Run.Stepped:Connect(function()
                PX.SafeExec(function()
                    for _, part in ipairs(PX.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end)
            end)
        else
            if State.Connections.Noclip then State.Connections.Noclip:Disconnect() State.Connections.Noclip = nil end
        end
    end)
    
    -- Infinite Jump
    PX.Toggle(page, "Infinite Jump", function(on)
        State.InfiniteJumpEnabled = on
    end)
    
    PX.UIS.JumpRequest:Connect(function()
        if State.InfiniteJumpEnabled then
            PX.SafeExec(function()
                PX.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end)
        end
    end)
    
    -- Spin
    PX.Slider(page, "Spin Speed", 1, 100, 10, function(v)
        State.SpinSpeed = v
    end)
    
    PX.Toggle(page, "Spin Bot", function(on)
        State.SpinEnabled = on
    end)
    
    PX.Run.Heartbeat:Connect(function()
        if State.SpinEnabled then
            PX.SafeExec(function()
                PX.HRP.CFrame = PX.HRP.CFrame * CFrame.Angles(0, math.rad(State.SpinSpeed), 0)
            end)
        end
    end)
    
    PX.Sep(page)
    PX.Label(page, "Auto Reset", C.accent)
    
    -- Auto Reset on Respawn
    PX.Toggle(page, "Auto Reset bei Respawn", function(on)
        if on then
            State.Connections.ResetOnSpawn = PX.LocalPlayer.CharacterAdded:Connect(function(char)
                task.wait(0.5)
                PX.SafeExec(function()
                    local hum = char:WaitForChild("Humanoid")
                    hum.WalkSpeed = 16
                    hum.UseJumpPower = true
                    hum.JumpPower = 50
                end)
            end)
        else
            if State.Connections.ResetOnSpawn then
                State.Connections.ResetOnSpawn:Disconnect()
                State.Connections.ResetOnSpawn = nil
            end
        end
    end)
end
