-- language: Luau, file: c:\vbl\vbl.lua, target: Roblox Client / Luau Executor
-- Title: Rzo Hub - Volleyball Legends (VBL)
-- Unified Tactical Suite & Cleaned Runtime Engine

local players = game:GetService("Players")
local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local userInputService = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")

local localPlayer = players.LocalPlayer or players:GetPropertyChangedSignal("LocalPlayer"):Wait()

-- ========================================================
-- CONFIGURATION & STATE
-- ========================================================
local Palette = {
    Color3.fromRGB(0, 200, 255),
    Color3.fromRGB(255, 100, 255),
    Color3.fromRGB(255, 220, 0),
    Color3.fromRGB(255, 140, 0),
    Color3.fromRGB(100, 255, 150),
    Color3.fromRGB(180, 100, 255),
}

local playerColors = {}

local function getPlayerColor(player)
    if playerColors[player] then
        return playerColors[player]
    end

    local usedColors = {}
    for _, color in pairs(playerColors) do
        usedColors[color] = true
    end

    for _, color in ipairs(Palette) do
        if not usedColors[color] then
            playerColors[player] = color
            return color
        end
    end

    local count = 0
    for _ in pairs(playerColors) do
        count = count + 1
    end

    playerColors[player] = Palette[(count % #Palette) + 1]
    return playerColors[player]
end

players.PlayerRemoving:Connect(function(player)
    playerColors[player] = nil
end)

-- Feature States
local TimeskipChargeEnabled = false
local SanjuTiltEnabled = false
local AutoServePowerEnabled = false
local AntiOutSpikeClampEnabled = false
local SpikeVelocityMultiplierEnabled = false
local SpikeVelocityMultiplierVal = 1.35
local LiveBallPredictorEnabled = false
local CourtBoundaryCheckerEnabled = false
local BallChamsEnabled = false

local isServingState = false

local COURT_HALF_WIDTH = 27.0
local COURT_HALF_LENGTH = 54.0

-- ========================================================
-- NETWORK DETOUR ENGINE (Remote Function & Metamethod Hook)
-- ========================================================
local NetworkHook = {
    MethodHooks = {},
    Initialized = false,
}

function NetworkHook:HookMethod(remoteName, hookId, callback)
    if not self.MethodHooks[remoteName] then
        self.MethodHooks[remoteName] = {}
    end
    self.MethodHooks[remoteName][hookId] = callback
end

function NetworkHook:UnhookMethod(remoteName, hookId)
    if self.MethodHooks[remoteName] then
        self.MethodHooks[remoteName][hookId] = nil
    end
end

function NetworkHook:_Dispatch(remoteName, payload, ...)
    local hooks = self.MethodHooks[remoteName]
    if not hooks then return end

    for _, callback in pairs(hooks) do
        if type(callback) == "function" then
            pcall(callback, payload, ...)
        end
    end
end

function NetworkHook:Initialize()
    if self.Initialized then return end
    self.Initialized = true

    local closure = newcclosure or function(fn) return fn end
    local hookMeta = hookmetamethod
    local getNamecall = getnamecallmethod
    local checkCaller = checkcaller or function() return false end

    task.spawn(function()
        task.wait(1.5)

        local metamethodHooked = false
        if hookMeta and getNamecall then
            local success = pcall(function()
                local originalNamecall
                originalNamecall = hookMeta(game, "__namecall", closure(function(selfInstance, ...)
                    if getNamecall() == "InvokeServer" and not checkCaller() then
                        if typeof(selfInstance) == "Instance" and selfInstance.ClassName == "RemoteFunction" then
                            if NetworkHook.MethodHooks[selfInstance.Name] then
                                local args = { ... }
                                NetworkHook:_Dispatch(selfInstance.Name, args[1], select(2, ...))
                                return originalNamecall(selfInstance, unpack(args))
                            end
                        end
                    end
                    return originalNamecall(selfInstance, ...)
                end))
            end)
            metamethodHooked = success
        end

        -- Safe Fallback Hook for Knit Services (Handles starter map/lobby gracefully)
        if not metamethodHooked and hookfunction then
            pcall(function()
                local packages = replicatedStorage:WaitForChild("Packages", 3)
                if not packages then return end

                local index = packages:WaitForChild("_Index", 3)
                if not index then return end

                local knitPkg = index:FindFirstChild("sleitnick_knit@1.7.0") or index:FindFirstChildWhichIsA("Folder")
                if not knitPkg then return end

                local knit = knitPkg:WaitForChild("knit", 3)
                if not knit then return end

                local services = knit:WaitForChild("Services", 3)
                if not services then return end

                for _, service in ipairs(services:GetChildren()) do
                    local rfFolder = service:FindFirstChild("RF")
                    if rfFolder then
                        for _, rf in ipairs(rfFolder:GetChildren()) do
                            if rf:IsA("RemoteFunction") and NetworkHook.MethodHooks[rf.Name] then
                                local rfName = rf.Name
                                local originalInvoke
                                originalInvoke = hookfunction(rf.InvokeServer, closure(function(inst, payload, ...)
                                    if not checkCaller() then
                                        NetworkHook:_Dispatch(rfName, payload, ...)
                                    end
                                    return originalInvoke(inst, payload, ...)
                                end))
                            end
                        end
                    end
                end
            end)
        end
    end)
end

NetworkHook:Initialize()

-- Track Serving Context
localPlayer.AttributeChanged:Connect(function(attr)
    if attr == "Context_IsServing" then
        if localPlayer:GetAttribute("Context_IsServing") ~= nil then
            isServingState = true
        end
    end
end)

-- ========================================================
-- GAMEPLAY REMOTE HOOKS (Interact)
-- ========================================================

-- 1. Auto Max Charge Timeskip Hinata
NetworkHook:HookMethod("Interact", "TimeskipShoyoCharge", function(payload)
    if not TimeskipChargeEnabled or type(payload) ~= "table" or payload.Move ~= "Spike" then
        return
    end

    if isServingState then
        isServingState = false
        return
    end

    local special = localPlayer:GetAttribute("Special_Current") or localPlayer:GetAttribute("Gameplay_Special")
    if special == "TimeskipShoyo" then
        payload.SpecialCharge = 0.95 + (math.random() * 0.04)
    end
end)

-- 2. Extra Sanju Tilt
NetworkHook:HookMethod("Interact", "SanjuTiltInteract", function(payload)
    if not SanjuTiltEnabled or type(payload) ~= "table" or payload.Move ~= "Spike" then
        return
    end

    local special = localPlayer:GetAttribute("Special_Current") or localPlayer:GetAttribute("Gameplay_Special")
    if special == "Rintaro" and payload.TiltDirection and payload.LookVector then
        local tilt = payload.TiltDirection
        if math.abs(tilt.X) > 0.01 or math.abs(tilt.Z) > 0.01 then
            local look = payload.LookVector
            payload.LookVector = Vector3.new(
                look.X + (tilt.X * 0.3),
                look.Y,
                look.Z + (tilt.Z * 0.3)
            ).Unit

            payload.TiltDirection = Vector3.new(
                tilt.X * 1.35,
                tilt.Y,
                tilt.Z * 1.35
            )
        end
    end
end)

-- 3. Auto Serve Perfect Power (#6)
NetworkHook:HookMethod("Interact", "AutoServePerfectPower", function(payload)
    if not AutoServePowerEnabled or type(payload) ~= "table" then
        return
    end

    local isServing = (localPlayer:GetAttribute("Context_IsServing") ~= nil)
    if payload.Move == "Serve" or isServing then
        payload.Power = 1.0
        payload.SpecialCharge = 1.0
        if payload.Timing then payload.Timing = "Perfect" end
        if payload.TimingValue then payload.TimingValue = 1.0 end
        if payload.BarPower then payload.BarPower = 1.0 end
    end
end)

-- 4. Anti-Out Spike Safety Clamp (#18)
NetworkHook:HookMethod("Interact", "AntiOutSpikeClamp", function(payload)
    if not AntiOutSpikeClampEnabled or type(payload) ~= "table" or payload.Move ~= "Spike" then
        return
    end

    local char = localPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local look = payload.LookVector or hrp.CFrame.LookVector
    local tilt = payload.TiltDirection or Vector3.new(0, 1, 0)

    local estDist = 36.8
    local targetX = hrp.Position.X + (look.X * estDist) + (tilt.X * 12.0)
    local targetZ = hrp.Position.Z + (look.Z * estDist) + (tilt.Z * 12.0)

    local maxSafeX = COURT_HALF_WIDTH - 3.5
    local maxSafeZ = COURT_HALF_LENGTH - 4.0

    if math.abs(targetX) > maxSafeX then
        local signX = targetX > 0 and 1 or -1
        local clampedLookX = (signX * maxSafeX - hrp.Position.X) / estDist
        payload.LookVector = Vector3.new(clampedLookX, look.Y, look.Z).Unit
        if payload.TiltDirection then
            payload.TiltDirection = Vector3.new(payload.TiltDirection.X * 0.25, payload.TiltDirection.Y, payload.TiltDirection.Z)
        end
    end

    if math.abs(targetZ) > maxSafeZ then
        local signZ = targetZ > 0 and 1 or -1
        local clampedLookZ = (signZ * maxSafeZ - hrp.Position.Z) / estDist
        local currLook = payload.LookVector or look
        payload.LookVector = Vector3.new(currLook.X, currLook.Y, clampedLookZ).Unit
    end
end)

-- 5. Spike Velocity Multiplier Injection (#22)
NetworkHook:HookMethod("Interact", "SpikeVelocityMultiplier", function(payload)
    if not SpikeVelocityMultiplierEnabled or type(payload) ~= "table" or payload.Move ~= "Spike" then
        return
    end

    local mult = SpikeVelocityMultiplierVal or 1.35
    payload.PowerMultiplier = (payload.PowerMultiplier or 1) * mult
    payload.SpeedMultiplier = (payload.SpeedMultiplier or 1) * mult
    if payload.BallVelocity and typeof(payload.BallVelocity) == "Vector3" then
        payload.BallVelocity = payload.BallVelocity * mult
    end
    if payload.Velocity and typeof(payload.Velocity) == "Vector3" then
        payload.Velocity = payload.Velocity * mult
    end
    if payload.Power and type(payload.Power) == "number" then
        payload.Power = payload.Power * mult
    end
end)

-- ========================================================
-- ESP CHARACTER DIRECTION
-- ========================================================
local DirectionESP = {
    Lines = {},
    Enabled = false,
    Connection = nil,
}

local function removeDirectionLine(player)
    if DirectionESP.Lines[player] then
        if DirectionESP.Lines[player].Parent then
            DirectionESP.Lines[player]:Destroy()
        end
        DirectionESP.Lines[player] = nil
    end
end

local function createDirectionLine(player)
    local line = Instance.new("LineHandleAdornment")
    line.Name = "ESPDirectionLine"
    line.Length = 75
    line.Thickness = 20
    line.Color3 = getPlayerColor(player)
    line.AlwaysOnTop = true
    line.ZIndex = 5
    line.Adornee = workspace.Terrain
    line.Parent = workspace
    return line
end

local function stopDirectionESP()
    DirectionESP.Enabled = false
    if DirectionESP.Connection then
        DirectionESP.Connection:Disconnect()
        DirectionESP.Connection = nil
    end
    for player in pairs(DirectionESP.Lines) do
        removeDirectionLine(player)
    end
end

local function updateDirectionESP()
    for _, player in ipairs(players:GetPlayers()) do
        local isSelf = (player == localPlayer)
        local isFriendly = false

        if not isSelf and player.Team and localPlayer.Team then
            isFriendly = (player.Team == localPlayer.Team)
        end

        if isSelf or isFriendly then
            removeDirectionLine(player)
        else
            local character = player.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")

            if hrp and character:GetAttribute("Jumping") then
                if not DirectionESP.Lines[player] or not DirectionESP.Lines[player].Parent then
                    DirectionESP.Lines[player] = createDirectionLine(player)
                end

                local line = DirectionESP.Lines[player]
                local pos = hrp.Position

                local rayParams = RaycastParams.new()
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                rayParams.FilterDescendantsInstances = { character }

                local ray = workspace:Raycast(pos, Vector3.new(0, -999, 0), rayParams)
                local floorY = ray and ray.Position.Y or (pos.Y - 3)
                local basePos = Vector3.new(pos.X, floorY + 0.2, pos.Z)

                local _, yaw, _ = hrp.CFrame:ToOrientation()
                line.CFrame = CFrame.new(basePos) * CFrame.Angles(0, yaw, 0)
            else
                removeDirectionLine(player)
            end
        end
    end

    for player in pairs(DirectionESP.Lines) do
        if not player or not player.Parent then
            removeDirectionLine(player)
        end
    end
end

local function startDirectionESP()
    if DirectionESP.Connection then return end
    DirectionESP.Enabled = true
    DirectionESP.Connection = runService.RenderStepped:Connect(updateDirectionESP)
end

-- ========================================================
-- CHARACTER SPIKE TARGET PREDICTOR (Self & Enemy)
-- ========================================================
local PlayerPredictor = {
    Markers = {},
    Connections = {},
    TiltCache = {},
    SelfEnabled = false,
    EnemyEnabled = false,
    BASE_DIST = 36.8,
    TILT_SCALE_FWD = 14.5,
    TILT_SCALE_BWD = 31.2,
    MIN_DIST = 10.0,
    BASE_LATERAL = 4.54,
}

local function getFloorY(character, hrp)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = { character }
    local hit = workspace:Raycast(hrp.Position, Vector3.new(0, -999, 0), rayParams)
    return hit and hit.Position.Y or (hrp.Position.Y - 3)
end

local function getPlayerTilt(player)
    local cached = PlayerPredictor.TiltCache[player]
    if not cached then
        cached = {
            tiltDir = player:GetAttribute("Gameplay_TiltDirection") or Vector3.new(0, 1, 0),
            tiltPower = player:GetAttribute("Multiplier_TiltPower") or 1,
        }
        PlayerPredictor.TiltCache[player] = cached

        player:GetAttributeChangedSignal("Gameplay_TiltDirection"):Connect(function()
            cached.tiltDir = player:GetAttribute("Gameplay_TiltDirection") or Vector3.new(0, 1, 0)
        end)

        player:GetAttributeChangedSignal("Multiplier_TiltPower"):Connect(function()
            cached.tiltPower = player:GetAttribute("Multiplier_TiltPower") or 1
        end)
    end
    return cached
end

local function getForwardVector(player, hrp, isJumping)
    if player == localPlayer and not isJumping then
        local cam = workspace.CurrentCamera
        if cam then
            local flatCam = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
            if flatCam.Magnitude > 0.01 then
                return flatCam.Unit
            end
        end
    end

    local flatHrp = Vector3.new(hrp.CFrame.LookVector.X, 0, hrp.CFrame.LookVector.Z)
    if flatHrp.Magnitude > 0.01 then
        return flatHrp.Unit
    end
    return nil
end

local function calculateLandingPosition(hrp, player, isJumping)
    local tiltInfo = getPlayerTilt(player)
    local flatTilt = Vector3.new(tiltInfo.tiltDir.X, 0, tiltInfo.tiltDir.Z)
    local forward = getForwardVector(player, hrp, isJumping)
    if not forward then return nil end

    local dotFwd = 0
    if isJumping and flatTilt.Magnitude > 0.05 then
        dotFwd = forward:Dot(flatTilt.Unit)
    end

    local lateralUnit = nil
    if player == localPlayer then
        local cam = workspace.CurrentCamera
        if cam then
            local flatRight = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z)
            if flatRight.Magnitude > 0.01 then
                lateralUnit = flatRight.Unit
            end
        end
    end

    if not lateralUnit then
        local hrpRight = Vector3.new(hrp.CFrame.RightVector.X, 0, hrp.CFrame.RightVector.Z)
        lateralUnit = (hrpRight.Magnitude > 0.01) and hrpRight.Unit or Vector3.new(1, 0, 0)
    end

    local dotLat = 0
    if tiltInfo.tiltPower > 1 and flatTilt.Magnitude > 0.05 then
        dotLat = lateralUnit:Dot(flatTilt.Unit)
    end

    local scaleFwd = (dotFwd >= 0) and PlayerPredictor.TILT_SCALE_FWD or PlayerPredictor.TILT_SCALE_BWD
    local dist = math.max(PlayerPredictor.MIN_DIST, PlayerPredictor.BASE_DIST - (dotFwd * scaleFwd))
    local latDist = dotLat * PlayerPredictor.BASE_LATERAL * tiltInfo.tiltPower

    local pos = hrp.Position
    local floorY = getFloorY(player.Character, hrp)

    return Vector3.new(
        pos.X + (forward.X * dist) + (lateralUnit.X * latDist),
        floorY + 0.15,
        pos.Z + (forward.Z * dist) + (lateralUnit.Z * latDist)
    )
end

local function removePredictorMarker(player)
    if PlayerPredictor.Markers[player] then
        PlayerPredictor.Markers[player]:Destroy()
        PlayerPredictor.Markers[player] = nil
    end
    if PlayerPredictor.Connections[player] then
        PlayerPredictor.Connections[player]:Disconnect()
        PlayerPredictor.Connections[player] = nil
    end
end

local function isEnemy(player)
    if player == localPlayer then return false end
    if player.Team and localPlayer.Team then
        return player.Team ~= localPlayer.Team
    end
    return true
end

local function createPredictorMarker(color)
    local marker = Instance.new("Part")
    marker.Name = "BallPredictorMarker"
    marker.Shape = Enum.PartType.Cylinder
    marker.Size = Vector3.new(0.2, 3, 3)
    marker.Material = Enum.Material.Neon
    marker.Color = color
    marker.Anchored = true
    marker.CanCollide = false
    marker.CastShadow = false
    marker.Transparency = 1
    marker.Parent = workspace
    return marker
end

local function attachPredictor(player, color)
    removePredictorMarker(player)
    local marker = createPredictorMarker(color)
    PlayerPredictor.Markers[player] = marker

    PlayerPredictor.Connections[player] = runService.RenderStepped:Connect(function()
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            marker.Transparency = 1
            return
        end

        local isJumping = character:GetAttribute("Jumping")
        if player ~= localPlayer and not isJumping then
            marker.Transparency = 1
            return
        end

        local landingPos = calculateLandingPosition(hrp, player, isJumping)
        if not landingPos then
            marker.Transparency = 1
            return
        end

        marker.CFrame = CFrame.new(landingPos) * CFrame.Angles(0, 0, math.pi / 2)
        marker.Transparency = 0.3
    end)
end

local function updatePlayerPredictors()
    if PlayerPredictor.SelfEnabled then
        attachPredictor(localPlayer, Color3.fromRGB(0, 255, 100))
    else
        removePredictorMarker(localPlayer)
    end

    for _, player in ipairs(players:GetPlayers()) do
        if player ~= localPlayer then
            if PlayerPredictor.EnemyEnabled and isEnemy(player) then
                attachPredictor(player, getPlayerColor(player))
            else
                removePredictorMarker(player)
            end
        end
    end
end

local function bindPlayerLifecycle(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if player == localPlayer then
            if PlayerPredictor.SelfEnabled then
                attachPredictor(localPlayer, Color3.fromRGB(0, 255, 100))
            end
        else
            if PlayerPredictor.EnemyEnabled and isEnemy(player) then
                attachPredictor(player, getPlayerColor(player))
            else
                removePredictorMarker(player)
            end
        end
    end)

    player:GetPropertyChangedSignal("Team"):Connect(function()
        if PlayerPredictor.EnemyEnabled then
            if isEnemy(player) then
                if not PlayerPredictor.Connections[player] then
                    attachPredictor(player, getPlayerColor(player))
                end
            else
                removePredictorMarker(player)
            end
        end
    end)
end

players.PlayerAdded:Connect(function(player)
    bindPlayerLifecycle(player)
    if PlayerPredictor.EnemyEnabled and isEnemy(player) then
        task.wait(1)
        attachPredictor(player, getPlayerColor(player))
    end
end)

players.PlayerRemoving:Connect(function(player)
    removePredictorMarker(player)
    PlayerPredictor.TiltCache[player] = nil
end)

for _, player in ipairs(players:GetPlayers()) do
    bindPlayerLifecycle(player)
end

-- ========================================================
-- LIVE BALL TRAJECTORY & COURT BOUNDARY CHECKER (#2, #3, #10)
-- ========================================================
local liveBallMarker = Instance.new("Part")
liveBallMarker.Name = "RzoHub_LiveBallPredictor"
liveBallMarker.Shape = Enum.PartType.Cylinder
liveBallMarker.Size = Vector3.new(0.25, 4.0, 4.0)
liveBallMarker.Material = Enum.Material.Neon
liveBallMarker.Color = Color3.fromRGB(0, 255, 180)
liveBallMarker.Anchored = true
liveBallMarker.CanCollide = false
liveBallMarker.CastShadow = false
liveBallMarker.Transparency = 1
liveBallMarker.Parent = workspace

local liveBallBillboard = Instance.new("BillboardGui")
liveBallBillboard.Name = "LandingBillboard"
liveBallBillboard.Size = UDim2.new(0, 90, 0, 30)
liveBallBillboard.AlwaysOnTop = true
liveBallBillboard.StudsOffset = Vector3.new(0, 1.8, 0)
liveBallBillboard.Parent = liveBallMarker

local liveBallLabel = Instance.new("TextLabel")
liveBallLabel.Size = UDim2.new(1, 0, 1, 0)
liveBallLabel.BackgroundTransparency = 1
liveBallLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
liveBallLabel.TextStrokeTransparency = 0.2
liveBallLabel.Font = Enum.Font.GothamBold
liveBallLabel.TextSize = 12
liveBallLabel.Text = ""
liveBallLabel.Parent = liveBallBillboard

-- Ball Highlight / Chams (#10)
local ballHighlight = Instance.new("Highlight")
ballHighlight.Name = "RzoHub_BallHighlight"
ballHighlight.FillTransparency = 0.4
ballHighlight.OutlineTransparency = 0
ballHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)

local ballBillboard = Instance.new("BillboardGui")
ballBillboard.Name = "RzoHub_BallBillboard"
ballBillboard.Size = UDim2.new(0, 120, 0, 35)
ballBillboard.AlwaysOnTop = true
ballBillboard.StudsOffset = Vector3.new(0, 2.5, 0)

local ballStatusLabel = Instance.new("TextLabel")
ballStatusLabel.Size = UDim2.new(1, 0, 1, 0)
ballStatusLabel.BackgroundTransparency = 1
ballStatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ballStatusLabel.TextStrokeTransparency = 0.2
ballStatusLabel.Font = Enum.Font.GothamBold
ballStatusLabel.TextSize = 13
ballStatusLabel.Text = "BALL"
ballStatusLabel.Parent = ballBillboard

local function getLiveBall()
    local names = { "Ball", "Volleyball", "CurrentBall" }
    for _, name in ipairs(names) do
        local obj = workspace:FindFirstChild(name)
        if obj and obj:IsA("BasePart") then return obj end
        if obj and obj:FindFirstChildWhichIsA("BasePart") then return obj:FindFirstChildWhichIsA("BasePart") end
    end
    for _, obj in ipairs(workspace:GetChildren()) do
        if (obj.Name:find("Ball") or obj.Name:find("ball")) and obj:IsA("BasePart") then
            return obj
        end
    end
    return nil
end

local function solveBallLanding(ball)
    if not ball then return nil end
    local pos = ball.Position
    local vel = ball.AssemblyLinearVelocity or ball.Velocity
    if not vel or vel.Magnitude < 0.5 then return nil end

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = { ball }
    local hit = workspace:Raycast(pos, Vector3.new(0, -999, 0), rayParams)
    local floorY = hit and hit.Position.Y or (pos.Y - 10)

    local g = workspace.Gravity or 196.2
    local deltaY = pos.Y - floorY
    if deltaY <= 0.1 then return nil end

    local vy = vel.Y
    local disc = (vy * vy) + (2 * g * deltaY)
    if disc < 0 then return nil end

    local t = (vy + math.sqrt(disc)) / g
    if t <= 0.05 then return nil end

    local landX = pos.X + (vel.X * t)
    local landZ = pos.Z + (vel.Z * t)
    return Vector3.new(landX, floorY + 0.15, landZ), t
end

local function isInsideCourt(pos)
    return math.abs(pos.X) <= COURT_HALF_WIDTH and math.abs(pos.Z) <= COURT_HALF_LENGTH
end

local liveBallConnection = nil

local function updateLiveBallFrame()
    local activeBall = getLiveBall()

    -- Chams Processing (#10)
    if BallChamsEnabled and activeBall then
        if ballHighlight.Parent ~= activeBall then
            ballHighlight.Adornee = activeBall
            ballHighlight.Parent = activeBall
        end
        if ballBillboard.Parent ~= activeBall then
            ballBillboard.Adornee = activeBall
            ballBillboard.Parent = activeBall
        end

        local vel = activeBall.AssemblyLinearVelocity or activeBall.Velocity or Vector3.zero
        local spd = vel.Magnitude
        local char = localPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local dist = hrp and (hrp.Position - activeBall.Position).Magnitude or 0

        if spd > 70 then
            ballHighlight.FillColor = Color3.fromRGB(255, 50, 50)
            ballStatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            ballStatusLabel.Text = string.format("SPIKE [%.0f spd | %.0fm]", spd, dist)
        elseif spd > 30 then
            ballHighlight.FillColor = Color3.fromRGB(50, 160, 255)
            ballStatusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
            ballStatusLabel.Text = string.format("PASS [%.0f spd | %.0fm]", spd, dist)
        else
            ballHighlight.FillColor = Color3.fromRGB(255, 220, 50)
            ballStatusLabel.TextColor3 = Color3.fromRGB(255, 230, 100)
            ballStatusLabel.Text = string.format("BALL [%.0fm]", dist)
        end
    else
        if ballHighlight.Parent then
            ballHighlight.Adornee = nil
            ballHighlight.Parent = nil
        end
        if ballBillboard.Parent then
            ballBillboard.Adornee = nil
            ballBillboard.Parent = nil
        end
    end

    -- Physics Predictor Processing (#2, #3)
    if LiveBallPredictorEnabled and activeBall then
        local landingPos, t = solveBallLanding(activeBall)
        if landingPos then
            liveBallMarker.CFrame = CFrame.new(landingPos) * CFrame.Angles(0, 0, math.pi / 2)
            liveBallMarker.Transparency = 0.25

            if CourtBoundaryCheckerEnabled then
                if isInsideCourt(landingPos) then
                    liveBallMarker.Color = Color3.fromRGB(0, 255, 120)
                    liveBallLabel.TextColor3 = Color3.fromRGB(100, 255, 120)
                    liveBallLabel.Text = string.format("IN [%.1fs]", t)
                else
                    liveBallMarker.Color = Color3.fromRGB(255, 45, 45)
                    liveBallLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
                    liveBallLabel.Text = string.format("OUT [%.1fs]", t)
                end
            else
                liveBallMarker.Color = Color3.fromRGB(0, 220, 255)
                liveBallLabel.TextColor3 = Color3.fromRGB(120, 230, 255)
                liveBallLabel.Text = string.format("%.1fs", t)
            end
        else
            liveBallMarker.Transparency = 1
            liveBallLabel.Text = ""
        end
    else
        liveBallMarker.Transparency = 1
        liveBallLabel.Text = ""
    end
end

local function updateLiveBallState()
    if LiveBallPredictorEnabled or BallChamsEnabled then
        if not liveBallConnection then
            liveBallConnection = runService.RenderStepped:Connect(updateLiveBallFrame)
        end
    else
        if liveBallConnection then
            liveBallConnection:Disconnect()
            liveBallConnection = nil
        end
        liveBallMarker.Transparency = 1
        liveBallLabel.Text = ""
        if ballHighlight.Parent then
            ballHighlight.Adornee = nil
            ballHighlight.Parent = nil
        end
        if ballBillboard.Parent then
            ballBillboard.Adornee = nil
            ballBillboard.Parent = nil
        end
    end
end

-- ========================================================
-- WINDUI FRAMEWORK LOADER
-- ========================================================
local WindUI_Sources = {
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
    "https://cdn.jsdelivr.net/gh/Footagesus/WindUI@latest/dist/main.lua",
    "https://cdn.jsdelivr.net/gh/Footagesus/WindUI/dist/main.lua",
}

local hasFileIO = (writefile and readfile and isfile) and true or false

local function saveCache(code)
    if hasFileIO then
        pcall(writefile, "RzoHub_WindUI.luau", code)
    end
end

local function loadCache()
    if not hasFileIO then return nil end
    local success, content = pcall(function()
        if isfile("RzoHub_WindUI.luau") then
            return readfile("RzoHub_WindUI.luau")
        end
        return nil
    end)
    if success and type(content) == "string" and #content >= 1000 then
        return content
    end
    return nil
end

local requestFn = (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request) or http_request or request

local function fetchSource(url)
    if requestFn then
        local success, res = pcall(requestFn, { Url = url, Method = "GET" })
        if success and type(res) == "table" and res.Body and (res.StatusCode == nil or res.StatusCode == 200) then
            return res.Body
        end
    end

    local s1, b1 = pcall(function() return game:HttpGetAsync(url) end)
    if s1 and type(b1) == "string" then return b1 end

    local s2, b2 = pcall(function() return game:HttpGet(url) end)
    if s2 and type(b2) == "string" then return b2 end

    return nil
end

local function compileModule(src)
    if type(src) ~= "string" or #src < 1000 then return nil end
    local s1, loader = pcall(loadstring, src)
    if s1 and type(loader) == "function" then
        local s2, module = pcall(loader)
        if s2 and type(module) == "table" then
            return module
        end
    end
    return nil
end

local WindUI = nil
local cachedCode = loadCache()
if cachedCode then
    WindUI = compileModule(cachedCode)
end

if not WindUI then
    for attempt = 1, 2 do
        for _, url in ipairs(WindUI_Sources) do
            local code = fetchSource(url)
            local mod = compileModule(code)
            if mod then
                saveCache(code)
                WindUI = mod
                break
            end
        end
        if WindUI then break else task.wait(1.5) end
    end
end

if not WindUI then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Rzo Hub Error",
            Text = "Failed to load WindUI. Please check internet connection.",
            Duration = 10,
        })
    end)
    return
end

-- ========================================================
-- USER INTERFACE CONSTRUCTION
-- ========================================================
WindUI:AddTheme({
    Name = "Rzo Hub",
    Accent = WindUI:Gradient({
        ["0"] = { Color = Color3.fromHex("#000000"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#1b1a1a"), Transparency = 0 },
    }, { Rotation = 90 }),
    Background = Color3.fromHex("#0A0A0A"),
    Outline = Color3.fromHex("#2A2A2A"),
    Text = Color3.fromHex("#F5F5F5"),
    Placeholder = Color3.fromHex("#606060"),
    Button = Color3.fromHex("#1C1C1C"),
    Icon = Color3.fromHex("#C0C0C0"),
})

WindUI:SetFont("rbxassetid://12187607287")

local rzoHubWindow = WindUI:CreateWindow({
    Title = "Rzo Hub",
    Icon = "rbxassetid://79791092079055",
    Author = "by @rzohub",
    Folder = "Rzo-Hub/VBL",
    Transparent = false,
    Theme = "Rzo Hub",
    Resizable = true,
    HideSearchBar = false,
    ScrollBarEnabled = true,
    User = { Enabled = true, Anonymous = false },
})

rzoHubWindow:EditOpenButton({
    Title = "VBL",
    Icon = "rbxassetid://79791092079055",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
    Color = ColorSequence.new(Color3.fromHex("FFFFFF"), Color3.fromHex("000000")),
})

rzoHubWindow:Tag({ Title = "v1.2.0", Color = Color3.fromHex("FFFFFF") })
rzoHubWindow:Tag({ Title = "Volleyball Legends", Color = Color3.fromHex("FFFFFF") })

-- Keyboard toggle shortcut (RightControl / Insert) to guarantee access
userInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.Insert then
        pcall(function()
            if rzoHubWindow.Toggle then
                rzoHubWindow:Toggle()
            elseif rzoHubWindow.IsOpen ~= nil then
                if rzoHubWindow.IsOpen then
                    rzoHubWindow:Close()
                else
                    rzoHubWindow:Open()
                end
            end
        end)
    end
end)

-- Main Tab
local mainTab = rzoHubWindow:Tab({ Title = "Main", Icon = "cpu", Locked = false })
mainTab:Select()

mainTab:Section({ Title = "Ball & Visual Trajectory" })

mainTab:Toggle({
    Title = "Live Ball Trajectory (Predictor)",
    Icon = "activity",
    Flag = "LiveBallPredictor",
    Callback = function(val)
        LiveBallPredictorEnabled = val
        updateLiveBallState()
    end,
})

mainTab:Toggle({
    Title = "Court In/Out Boundary Checker",
    Icon = "map-pin",
    Flag = "CourtBoundaryChecker",
    Callback = function(val)
        CourtBoundaryCheckerEnabled = val
    end,
})

mainTab:Toggle({
    Title = "Ball ESP & State Chams",
    Icon = "disc",
    Flag = "BallChamsEnabled",
    Callback = function(val)
        BallChamsEnabled = val
        updateLiveBallState()
    end,
})

mainTab:Toggle({
    Title = "Spike Target Predictor (Self)",
    Icon = "target",
    Flag = "BallPredictorSelf",
    Callback = function(val)
        PlayerPredictor.SelfEnabled = val
        updatePlayerPredictors()
    end,
})

mainTab:Toggle({
    Title = "Spike Target Predictor (Enemy)",
    Icon = "target",
    Flag = "BallPredictorEnemy",
    Callback = function(val)
        PlayerPredictor.EnemyEnabled = val
        updatePlayerPredictors()
    end,
})

mainTab:Toggle({
    Title = "Enable ESP Character Direction",
    Icon = "eye",
    Flag = "ESPEnabled",
    Callback = function(val)
        if val then
            startDirectionESP()
        else
            stopDirectionESP()
        end
    end,
})

mainTab:Section({ Title = "Spike & Serve Modifiers" })

mainTab:Toggle({
    Title = "Auto Serve Perfect Power",
    Icon = "zap",
    Flag = "AutoServePower",
    Callback = function(val)
        AutoServePowerEnabled = val
    end,
})

mainTab:Toggle({
    Title = "Anti-Out Spike Safety Clamp",
    Icon = "shield-check",
    Flag = "AntiOutSpikeClamp",
    Callback = function(val)
        AntiOutSpikeClampEnabled = val
    end,
})

mainTab:Toggle({
    Title = "Spike Velocity Multiplier",
    Icon = "trending-up",
    Flag = "SpikeMultiplierEnabled",
    Callback = function(val)
        SpikeVelocityMultiplierEnabled = val
    end,
})

mainTab:Slider({
    Title = "Spike Multiplier Factor",
    Icon = "sliders",
    Flag = "SpikeMultiplierFactor",
    Min = 1.0,
    Max = 2.5,
    Step = 0.05,
    Value = 1.35,
    Callback = function(val)
        SpikeVelocityMultiplierVal = val
    end,
})

mainTab:Toggle({
    Title = "Auto Max Charge Timeskip Hinata",
    Icon = "flame",
    Flag = "TimeskipChargeEnabled",
    Callback = function(val)
        TimeskipChargeEnabled = val
    end,
})

mainTab:Toggle({
    Title = "Extra Sanju Tilt",
    Icon = "crosshair",
    Flag = "SanjuTiltEnabled",
    Callback = function(val)
        SanjuTiltEnabled = val
    end,
})

-- Configuration Management
local configManager = rzoHubWindow.ConfigManager
if configManager then
    pcall(function()
        rzoHubWindow.CurrentConfig = configManager:CreateConfig("default")
        if rzoHubWindow.CurrentConfig and rzoHubWindow.CurrentConfig.Load then
            rzoHubWindow.CurrentConfig:Load()
        end
    end)

    rzoHubWindow:OnClose(function()
        pcall(function()
            rzoHubWindow.CurrentConfig = configManager:Config("default")
            if rzoHubWindow.CurrentConfig and rzoHubWindow.CurrentConfig.Save then
                rzoHubWindow.CurrentConfig:Save()
            end
        end)
    end)
end
