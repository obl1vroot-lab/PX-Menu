--[[
    Module-Chaos.lua
    PX-Menu Chaos Module
    Features: Black Hole, Tornado, Disco Floor, Chaos TP
]]

return function(PX, page)
    local C = PX.Colors
    local State = PX.State
    
    PX.Label(page, "Chaos Modus", C.accent)
    
    -- Black Hole
    PX.Btn(page, "Black Hole", function()
        task.spawn(function()
            PX.SafeExec(function()
                local hrp = PX.HRP
                local blackHole = Instance.new("Part")
                blackHole.Size = Vector3.new(1, 1, 1)
                blackHole.Position = hrp.Position + hrp.CFrame.LookVector * 20
                blackHole.Anchored = true
                blackHole.CanCollide = false
                blackHole.Transparency = 1
                blackHole.Parent = workspace
                local vortex = Instance.new("Part")
                vortex.Shape = Enum.PartType.Cylinder
                vortex.Size = Vector3.new(2, 30, 30)
                vortex.CFrame = blackHole.CFrame * CFrame.Angles(0, 0, math.rad(90))
                vortex.Anchored = true
                vortex.CanCollide = false
                vortex.Transparency = 0.5
                vortex.BrickColor = BrickColor.new("Really black")
                vortex.Material = Enum.Material.Neon
                vortex.Parent = workspace
                local fire = Instance.new("Fire")
                fire.Color = Color3.fromRGB(100, 0, 200)
                fire.Size = 20
                fire.Parent = vortex
                local elapsed = 0
                local conn
                conn = PX.Run.Heartbeat:Connect(function()
                    elapsed = elapsed + 1
                    if elapsed > 480 or not blackHole.Parent then
                        conn:Disconnect()
                        pcall(function() blackHole:Destroy() vortex:Destroy() end)
                        return
                    end
                    for _, player in pairs(PX.Players:GetPlayers()) do
                        if player.Character then
                            local pHRP = player.Character:FindFirstChild("HumanoidRootPart")
                            if pHRP then
                                local dir = (blackHole.Position - pHRP.Position)
                                local dist = dir.Magnitude
                                if dist < 60 and dist > 2 then
                                    pHRP.Velocity = dir.Unit * (200 / dist) * 10
                                end
                            end
                        end
                    end
                end)
            end)
        end)
    end)
    
    -- Tornado
    PX.Btn(page, "Tornado spawnen", function()
        PX.SafeExec(function()
            local hrp = PX.HRP
            task.spawn(function()
                for i = 1, 30 do
                    local part = Instance.new("Part")
                    part.Size = Vector3.new(math.random(2, 6), math.random(2, 6), math.random(2, 6))
                    part.Position = hrp.Position + Vector3.new(math.random(-20, 20), i * 2, math.random(-20, 20))
                    part.Anchored = false
                    part.CanCollide = true
                    part.BrickColor = BrickColor.new("White")
                    part.Parent = workspace
                    local bv = Instance.new("BodyVelocity")
                    bv.Velocity = Vector3.new(math.random(-30, 30), 50, math.random(-30, 30))
                    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bv.Parent = part
                    PX.Debris:AddItem(part, 5)
                    task.wait(0.05)
                end
            end)
        end)
    end)
    
    -- Disco Floor
    PX.Btn(page, "Disco Floor", function()
        task.spawn(function()
            PX.SafeExec(function()
                local hrp = PX.HRP
                local floorParts = {}
                for x = -15, 15, 5 do
                    for z = -15, 15, 5 do
                        local p = Instance.new("Part")
                        p.Size = Vector3.new(5, 0.5, 5)
                        p.Position = hrp.Position + Vector3.new(x, -3, z)
                        p.Anchored = true
                        p.Material = Enum.Material.Neon
                        p.Parent = workspace
                        table.insert(floorParts, p)
                    end
                end
                for i = 1, 100 do
                    for _, p in pairs(floorParts) do
                        if p.Parent then p.Color = Color3.fromHSV(math.random(), 1, 1) end
                    end
                    task.wait(0.2)
                end
                for _, p in pairs(floorParts) do
                    if p.Parent then p:Destroy() end
                end
            end)
        end)
    end)
    
    PX.Sep(page)
    PX.Label(page, "Chaos Aktionen", C.accent)
    
    -- Chaos TP All
    PX.Btn(page, "Chaos TP Alle", function()
        for _, player in pairs(PX.Players:GetPlayers()) do
            if player ~= PX.LocalPlayer then
                PX.SafeExec(function()
                    player.Character:FindFirstChild("HumanoidRootPart").CFrame = CFrame.new(
                        math.random(-200, 200), math.random(10, 100), math.random(-200, 200)
                    )
                end)
            end
        end
    end)
    
    -- Lag Server
    PX.Btn(page, "Server laggen (Parts)", function()
        for i = 1, 100 do
            local part = Instance.new("Part")
            part.Size = Vector3.new(10, 10, 10)
            part.Position = PX.HRP.Position + Vector3.new(math.random(-50, 50), math.random(0, 50), math.random(-50, 50))
            part.Anchored = true
            part.Parent = workspace
        end
    end)
    
    -- Destroy All Parts
    PX.Btn(page, "Alle Parts zerstoeren", function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(PX.Character) then
                PX.SafeExec(function() obj:Destroy() end)
            end
        end
    end)
    
    -- Remove Meshes
    PX.Btn(page, "Alle Meshes entfernen", function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("MeshPart") or obj:IsA("SpecialMesh") then
                PX.SafeExec(function() obj:Destroy() end)
            end
        end
    end)
end
