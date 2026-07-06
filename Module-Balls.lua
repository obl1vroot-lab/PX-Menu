--[[
    Module-Balls.lua
    PX-Menu Balls Module
    Features: Spawn Fling Ball, Mega x5, Homing, Bowling, Launch, Spam Loop
]]

return function(PX, page)
    local C = PX.Colors
    local State = PX.State
    
    PX.Label(page, "Fling Balls", C.accent)
    
    PX.Btn(page, "Fling Ball spawnen", function()
        PX.SafeExec(function()
            local hrp = PX.HRP
            local ball = Instance.new("Part")
            ball.Name = "PXMenu_FlingBall"
            ball.Shape = Enum.PartType.Ball
            ball.Size = Vector3.new(8, 8, 8)
            ball.Position = hrp.CFrame * CFrame.new(0, 0, -8).Position
            ball.BrickColor = BrickColor.new("Bright red")
            ball.Material = Enum.Material.Neon
            ball.Anchored = false
            ball.CanCollide = true
            ball.Parent = workspace
            local spin = Instance.new("BodyAngularVelocity")
            spin.AngularVelocity = Vector3.new(0, 50, 0)
            spin.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            spin.P = 100000
            spin.Parent = ball
            local light = Instance.new("PointLight")
            light.Color = Color3.fromRGB(255, 0, 0)
            light.Brightness = 5
            light.Range = 20
            light.Parent = ball
            local fire = Instance.new("Fire")
            fire.Color = Color3.fromRGB(255, 100, 0)
            fire.Size = 5
            fire.Parent = ball
            PX.Debris:AddItem(ball, 15)
            PX.Notify("PX-Menu", "Fling Ball gespawnt!")
        end)
    end)
    
    PX.Btn(page, "Mega Fling Ball x5", function()
        PX.SafeExec(function()
            local hrp = PX.HRP
            for i = 1, 5 do
                task.spawn(function()
                    local ball = Instance.new("Part")
                    ball.Shape = Enum.PartType.Ball
                    ball.Size = Vector3.new(12, 12, 12)
                    ball.Position = (hrp.CFrame * CFrame.new(math.random(-5, 5), 2, -10 - (i * 3))).Position
                    ball.BrickColor = BrickColor.new("Bright yellow")
                    ball.Material = Enum.Material.Neon
                    ball.Anchored = false
                    ball.CanCollide = true
                    ball.Parent = workspace
                    local spin = Instance.new("BodyAngularVelocity")
                    spin.AngularVelocity = Vector3.new(0, 100, 0)
                    spin.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                    spin.P = 500000
                    spin.Parent = ball
                    local thrust = Instance.new("BodyVelocity")
                    thrust.Velocity = hrp.CFrame.LookVector * 80
                    thrust.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    thrust.Parent = ball
                    local fire = Instance.new("Fire")
                    fire.Color = Color3.fromRGB(255, 200, 0)
                    fire.Size = 8
                    fire.Parent = ball
                    PX.Debris:AddItem(ball, 12)
                end)
            end
            PX.Notify("PX-Menu", "MEGA FLING BALL x5!")
        end)
    end)
    
    PX.Btn(page, "Homing Fling Ball", function()
        task.spawn(function()
            PX.SafeExec(function()
                local hrp = PX.HRP
                local ball = Instance.new("Part")
                ball.Shape = Enum.PartType.Ball
                ball.Size = Vector3.new(10, 10, 10)
                ball.Position = hrp.CFrame * CFrame.new(0, 0, -8).Position
                ball.BrickColor = BrickColor.new("Magenta")
                ball.Material = Enum.Material.Neon
                ball.Anchored = false
                ball.CanCollide = true
                ball.Parent = workspace
                local fire = Instance.new("Fire")
                fire.Color = Color3.fromRGB(200, 0, 255)
                fire.Size = 6
                fire.Parent = ball
                local elapsed = 0
                local homingConn
                homingConn = PX.Run.Heartbeat:Connect(function()
                    elapsed = elapsed + 1
                    if elapsed > 600 or not ball.Parent then homingConn:Disconnect() return end
                    local closest, closestDist = nil, math.huge
                    for _, player in pairs(PX.Players:GetPlayers()) do
                        if player ~= PX.LocalPlayer and player.Character then
                            local pHRP = player.Character:FindFirstChild("HumanoidRootPart")
                            if pHRP then
                                local dist = (pHRP.Position - ball.Position).Magnitude
                                if dist < closestDist then closest = pHRP closestDist = dist end
                            end
                        end
                    end
                    if closest then
                        ball.Velocity = (closest.Position - ball.Position).Unit * 70 + Vector3.new(0, 20, 0)
                        ball.RotVelocity = Vector3.new(50, 50, 50)
                    end
                end)
                PX.Debris:AddItem(ball, 10)
            end)
        end)
    end)
    
    PX.Sep(page)
    PX.Label(page, "Bowling", C.accent)
    
    PX.Btn(page, "Bowling Strike", function()
        PX.SafeExec(function()
            local hrp = PX.HRP
            for i = -3, 3 do
                local ball = Instance.new("Part")
                ball.Shape = Enum.PartType.Ball
                ball.Size = Vector3.new(6, 6, 6)
                ball.Position = (hrp.CFrame * CFrame.new(i * 4, 0, -50)).Position
                ball.BrickColor = BrickColor.new("Bright orange")
                ball.Material = Enum.Material.SmoothPlastic
                ball.Anchored = false
                ball.CanCollide = true
                ball.Parent = workspace
                local thrust = Instance.new("BodyVelocity")
                thrust.Velocity = hrp.CFrame.LookVector * 150
                thrust.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                thrust.Parent = ball
                local spin = Instance.new("BodyAngularVelocity")
                spin.AngularVelocity = Vector3.new(100, 0, 0)
                spin.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                spin.Parent = ball
                PX.Debris:AddItem(ball, 8)
            end
            PX.Notify("PX-Menu", "Bowling Strike!")
        end)
    end)
    
    PX.Btn(page, "Ball auf Naechsten", function()
        PX.SafeExec(function()
            local hrp = PX.HRP
            local closest, closestDist = nil, math.huge
            for _, player in pairs(PX.Players:GetPlayers()) do
                if player ~= PX.LocalPlayer and player.Character then
                    local pHRP = player.Character:FindFirstChild("HumanoidRootPart")
                    if pHRP then
                        local dist = (pHRP.Position - hrp.Position).Magnitude
                        if dist < closestDist then closest = pHRP closestDist = dist end
                    end
                end
            end
            if closest then
                local ball = Instance.new("Part")
                ball.Shape = Enum.PartType.Ball
                ball.Size = Vector3.new(10, 10, 10)
                ball.Position = hrp.Position + Vector3.new(0, 0, -5)
                ball.BrickColor = BrickColor.new("Really red")
                ball.Material = Enum.Material.Neon
                ball.Anchored = false
                ball.CanCollide = true
                ball.Parent = workspace
                local thrust = Instance.new("BodyVelocity")
                thrust.Velocity = (closest.Position - ball.Position).Unit * 200
                thrust.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                thrust.Parent = ball
                local spin = Instance.new("BodyAngularVelocity")
                spin.AngularVelocity = Vector3.new(0, 9999, 0)
                spin.MaxTorque = Vector3.new(0, math.huge, 0)
                spin.Parent = ball
                local fire = Instance.new("Fire")
                fire.Size = 6
                fire.Parent = ball
                PX.Debris:AddItem(ball, 8)
            end
        end)
    end)
    
    PX.Sep(page)
    PX.Label(page, "Spam Loop", C.accent)
    
    local spamBallActive = false
    local spamBallConn = nil
    
    PX.Toggle(page, "Spam Fling Ball Loop", function(on)
        spamBallActive = on
        if on then
            spamBallConn = task.spawn(function()
                while spamBallActive do
                    PX.SafeExec(function()
                        local hrp = PX.HRP
                        local ball = Instance.new("Part")
                        ball.Shape = Enum.PartType.Ball
                        ball.Size = Vector3.new(8, 8, 8)
                        ball.Position = (hrp.CFrame * CFrame.new(0, 0, -10)).Position
                        ball.BrickColor = BrickColor.new("Bright yellow")
                        ball.Material = Enum.Material.Neon
                        ball.Anchored = false
                        ball.CanCollide = true
                        ball.Parent = workspace
                        local spin = Instance.new("BodyAngularVelocity")
                        spin.AngularVelocity = Vector3.new(0, 9999, 0)
                        spin.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                        spin.P = 500000
                        spin.Parent = ball
                        local thrust = Instance.new("BodyVelocity")
                        thrust.Velocity = hrp.CFrame.LookVector * 60
                        thrust.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        thrust.Parent = ball
                        local fire = Instance.new("Fire")
                        fire.Size = 5
                        fire.Parent = ball
                        PX.Debris:AddItem(ball, 5)
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end)
end
