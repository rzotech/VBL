do
end

local players = (game:GetService("Players"))

do
end

local runService = (game:GetService("RunService"))

do
end

local replicatedStorage = (game:GetService("ReplicatedStorage"))
local v1 = game
local v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13
v1:GetService("CollectionService")

do
end

game:GetService("TweenService")

do
end

local v14 = (game:GetService("Workspace"))
local localPlayer = players.LocalPlayer

local v15 = {
  (Color3.fromRGB(0, 200, 255)), (Color3.fromRGB(255, 100, 255)), (Color3.fromRGB(255, 220, 0)),
  (Color3.fromRGB(255, 140, 0)), (Color3.fromRGB(100, 255, 150)), Color3.fromRGB(180, 100, 255),
}

local v16 = {}

local function f1(p1)
  local v17 = p1

  if v16[p1] then
    return v16[p1]
  else
    local v18
    v18 = {}

    for key, value in pairs(v16) do
      v18[value] = true
    end

    for index, value2 in ipairs(v15) do
      if not v18[value2] then
        v16[p1] = value2
        return value2
      end
    end

    local v19
    v19 = 0

    for key2 in pairs(v16) do
      v19 = v19 + 1
    end

    v16[p1] = v15[v19 % #v15 + 1]
    return v16[p1]
  end
end

do
end

players.PlayerRemoving:Connect(function(player)
  v16[player] = nil
  return
end)

local v20 = { Lines = {}, Enabled = false, Connection = nil }

local function f2(p2)
  local v21 = p2
  local v22

  if v20.Lines[p2] then
    if v20.Lines[p2].Parent then
      do
      end

      v20.Lines[p2]:Destroy()
    end

    v20.Lines[p2] = nil
  end

  return
end

local function f3(p3)
  local v23 = p3

  local espDirectionLine = Instance.new("LineHandleAdornment")
  espDirectionLine.Name = "ESPDirectionLine"
  espDirectionLine.Length = 75
  espDirectionLine.Thickness = 20

  local v24 = p3

  do
  end

  espDirectionLine.Color3 = p3 or Color3.fromRGB(0, 200, 255)
  espDirectionLine.AlwaysOnTop = true
  espDirectionLine.ZIndex = 5
  espDirectionLine.Adornee = workspace.Terrain
  espDirectionLine.Parent = workspace

  return espDirectionLine
end

local v25 = f2

local function f4()
  local v26
  v20.Enabled = false

  if v20.Connection then
    do
    end

    v20.Connection:Disconnect()
    v20.Connection = nil
  end

  for key3, value3 in pairs(v20.Lines) do
    f2(key3)
  end

  return
end

local function f5()
  local v27 = players

  local v28, v29, v30, v31, v32, v33, v34, humanoidRootPart, position, raycastParams, v35,
    raycast, y, v36, v37, v38, v39, vector

  for index2, value4 in ipairs(players:GetPlayers()) do
    local v40
    v40 = value4 == localPlayer

    local v41
    v41 = v40

    if not v40 then
      local team
      team = value4.Team

      local team2
      team2 = team

      if team then
        do
        end

        do
        end

        team2 = localPlayer.Team and value4.Team == localPlayer.Team
      end

      v41 = team2
    end

    if v41 then
      f2(value4)
    else
      local character
      character = value4.Character

      local v42
      v42 = character

      do
      end

      if character and character:FindFirstChild("HumanoidRootPart") then
        if not (character:GetAttribute("Jumping")) then
          f2(value4)
        else
          v32 = not v20.Lines[value4]
          v33 = v32

          do
          end

          if v32 or not v20.Lines[value4].Parent then
            v20.Lines[value4] = f3(f1(value4))
          end

          v34 = v20.Lines[value4]
          humanoidRootPart = character.HumanoidRootPart
          position = humanoidRootPart.Position

          raycastParams = RaycastParams.new()
          raycastParams.FilterType = Enum.RaycastFilterType.Exclude
          raycastParams.FilterDescendantsInstances = { character }

          do
          end

          raycast = workspace:Raycast(position, (Vector3.new(0, -999, 0)), raycastParams)

          y = raycast
          y = raycast and raycast.Position.Y

          v36 = y

          do
          end

          v37 = y or position.Y - 3
          vector = Vector3.new(position.X, v37 + 0.2, position.Z)

          do
          end

          v39 = { humanoidRootPart.CFrame:ToOrientation() }
          v34.CFrame = (CFrame.new(vector)) * (CFrame.Angles(0, v39[2], 0))
          ::L16551216::
        end
      else
        f2(value4)
        goto L16551216
      end
    end
  end

  for key4, value5 in pairs(v20.Lines) do
    do
    end

    do
    end

    if not key4 or not key4.Parent then
      f2(key4)
    end
  end

  return
end

local function f6()
  local v43

  if v20.Connection then
    return
  else
    v20.Enabled = true

    do
    end

    v20.Connection = runService.RenderStepped:Connect(function()
      f5()
      return
    end)

    return
  end
end

local v44 = f4

local v45 = { MethodHooks = {}, Initialized = false }

function v45:HookMethod(p4, p5, p6)
  local v46 = self
  local v47 = p6
  local v48 = p4
  local v49 = p5

  if not self.MethodHooks[p4] then
    self.MethodHooks[p4] = {}
  end

  self.MethodHooks[p4][p5] = p6
  return
end

function v45.UnhookMethod(p7, p8, p9)
  local v50 = p7
  local v51 = p8
  local v52 = p9

  if p7.MethodHooks[p8] then
    p7.MethodHooks[p8][p9] = nil
  end

  return
end

function v45:_Dispatch(p10, p11, ...)
  local v53 = self.MethodHooks[p10]

  if not v53 then
    return
  else
    for key5, value6 in pairs(v53) do
      if type(value6) == "function" then
        value6(p11, ...)
      end
    end

    return
  end
end

function v45:Initialize()
  local v54 = self
  local v55, v56, v57, v58, v59

  if self.Initialized then
    return
  else
    self.Initialized = true

    do
    end

    v56 = newcclosure or function(p12) return p12 end

    local v60
    v60 = v56

    v57 = hookmetamethod
    v58 = getnamecallmethod
    v59 = checkcaller

    task.spawn(function()
      local v61
      task.wait(3)
      local v62 = v57

      do
      end

      local v63, v64, v65, v66

      if v57 and v58 then
        local v67

        v67 = {
          pcall(function()
            local v68

            v68 = (v57(game, "__namecall", v56(function(p13, ...)
              local v69 = p13
              local v70 = (v58()) == "InvokeServer"
              local v71 = v70
              local v72, v73

              if v70 then
                local v74
                v74 = not v59

                local v75
                v75 = v74
                v75 = v74 or not (v59())

                local v76
                v76 = v75

                if v75 then
                  local v77
                  v77 = (typeof(p13)) == "Instance"

                  local v78
                  v78 = v77

                  if v77 then
                    do
                    end

                    do
                    end

                    v78 = p13.ClassName == "RemoteFunction" and v45.MethodHooks[p13.Name]
                  end

                  v76 = v78
                end

                v71 = v76
              end

              if v71 then
                local v79
                v79 = { ... }

                local v80
                v80 = v79[1]

                local v81
                v81 = v45

                v45:_Dispatch(p13.Name, v80, select(2, ...))
                return v68(p13, unpack(v79))
              else
                return v68(p13, ...)
              end
            end)))

            return
          end),
        }

        if v67[1] then
          return
        else
          ::L461112::

          v63 = {
            pcall(function()
              local v82 = replicatedStorage

              do
              end

              do
              end

              do
              end

              do
              end

              local services = ((((replicatedStorage:WaitForChild("Packages")):WaitForChild("_Index")):WaitForChild("sleitnick_knit@1.7.0")):WaitForChild("knit")):WaitForChild("Services")
              local v83, v84

              for index3, value7 in ipairs(services:GetChildren()) do
                local rf
                rf = value7:FindFirstChild("RF")

                if rf then
                  for index4, value8 in ipairs(rf:GetChildren()) do
                    do
                    end

                    do
                    end

                    if (value8:IsA("RemoteFunction")) and v45.MethodHooks[value8.Name] then
                      local name = value8.Name

                      local v85
                      v85 = hookfunction

                      local v86
                      v86 = v85

                      do
                      end

                      local v87

                      v87 = v85 and hookfunction(value8.InvokeServer, v56(function(p14, p15, ...)
                        local v88 = p14
                        local v89 = p15
                        local v90 = not v59
                        local v91 = v90

                        do
                        end

                        if v90 or not (v59()) then
                          local v92
                          v92 = v45
                          v45:_Dispatch(name, p15, ...)
                        end

                        return v87(p14, p15, ...)
                      end)) or nil
                    end
                  end
                end
              end

              return
            end),
          }

          v64 = v63[2]
          v65 = not v63[1]
          v66 = v65

          do
          end

          if v65 and false then
            print("[NetworkHook] fallback hook FAILED:", v64)
          end

          return
        end
      else
        goto L461112
      end
    end)

    return
  end
end

local v93 = v45
v45:Initialize()
local v94 = false
local v95 = false

do
end

localPlayer.AttributeChanged:Connect(function(p16)
  if p16 == "Context_IsServing" then
    local v96
    v96 = localPlayer

    if (localPlayer:GetAttribute("Context_IsServing")) ~= nil then
      v95 = true
    end
  end

  return
end)

local v97 = v45

v45:HookMethod("Interact", "TimeskipShoyoCharge", function(p17)
  local v98 = p17
  local v99, v100, v101

  if not v94 then
    return
  else
    if (type(p17)) ~= "table" then
      return
    else
      if p17.Move ~= "Spike" then
        return
      else
        if v95 then
          v95 = false
          return
        else
          do
          end

          local localPlayer2
          localPlayer2 = (game:GetService("Players")).LocalPlayer

          local specialCurrent
          specialCurrent = localPlayer2:GetAttribute("Special_Current")

          local v102
          v102 = specialCurrent

          do
          end

          do
          end

          if (specialCurrent or localPlayer2:GetAttribute("Gameplay_Special"))
            == "TimeskipShoyo" then
            do
            end

            p17.SpecialCharge = 0.95 + (math.random()) * 0.04
          else
          end

          return
        end
      end
    end
  end
end)

local v103 = false
local v104 = v45

v45:HookMethod("Interact", "SanjuTiltInteract", function(p18)
  local v105 = p18
  local v106, v107, v108, v109

  if not v103 then
    return
  else
    if (type(p18)) ~= "table" then
      return
    else
      if p18.Move ~= "Spike" then
        return
      else
        do
        end

        local localPlayer3
        localPlayer3 = (game:GetService("Players")).LocalPlayer

        local specialCurrent2
        specialCurrent2 = localPlayer3:GetAttribute("Special_Current")

        local v110
        v110 = specialCurrent2

        do
        end

        local v111
        v111 = (specialCurrent2 or localPlayer3:GetAttribute("Gameplay_Special")) == "Rintaro"

        local lookVector
        lookVector = v111

        if v111 then
          do
          end

          do
          end

          lookVector = p18.TiltDirection and p18.LookVector
        end

        if lookVector then
          local tiltDirection
          tiltDirection = p18.TiltDirection

          local v112
          v112 = (math.abs(tiltDirection.X)) > 0.01

          local v113
          v113 = v112

          do
          end

          if v112 or (math.abs(tiltDirection.Z)) > 0.01 then
            local lookVector2
            lookVector2 = p18.LookVector

            do
            end

            p18.LookVector = (Vector3.new(
              lookVector2.X + tiltDirection.X * 0.3, lookVector2.Y,
              lookVector2.Z + tiltDirection.Z * 0.3
            )).Unit

            p18.TiltDirection = Vector3.new(
              tiltDirection.X * 1.35, tiltDirection.Y, tiltDirection.Z * 1.35
            )
          end
        end

        return
      end
    end
  end
end)

-- ========================================================
-- RZO HUB EXTENDED TACTICAL MODULES (#2, #3, #6, #10, #18, #22)
-- ========================================================
local LiveBallPredictorEnabled = false
local CourtBoundaryCheckerEnabled = false
local AutoServePowerEnabled = false
local BallChamsEnabled = false
local AntiOutSpikeClampEnabled = false
local SpikeVelocityMultiplierEnabled = false
local SpikeVelocityMultiplierVal = 1.35

local COURT_HALF_WIDTH = 27.0
local COURT_HALF_LENGTH = 54.0

-- Feature #6: Auto Serve Perfect Power
v45:HookMethod("Interact", "AutoServePerfectPower", function(p)
  if not AutoServePowerEnabled then return end
  if type(p) ~= "table" then return end

  local isServing = (localPlayer:GetAttribute("Context_IsServing")) ~= nil
  if p.Move == "Serve" or isServing then
    p.Power = 1.0
    p.SpecialCharge = 1.0
    if p.Timing then p.Timing = "Perfect" end
    if p.TimingValue then p.TimingValue = 1.0 end
    if p.BarPower then p.BarPower = 1.0 end
  end
end)

-- Feature #18: Anti-Out Spike Safety Clamp
v45:HookMethod("Interact", "AntiOutSpikeClamp", function(p)
  if not AntiOutSpikeClampEnabled then return end
  if type(p) ~= "table" or p.Move ~= "Spike" then return end

  local character = localPlayer.Character
  local hrp = character and character:FindFirstChild("HumanoidRootPart")
  if not hrp then return end

  local look = p.LookVector or hrp.CFrame.LookVector
  local tilt = p.TiltDirection or Vector3.new(0, 1, 0)

  local estDist = 36.8
  local targetX = hrp.Position.X + (look.X * estDist) + (tilt.X * 12.0)
  local targetZ = hrp.Position.Z + (look.Z * estDist) + (tilt.Z * 12.0)

  local maxSafeX = COURT_HALF_WIDTH - 3.5
  local maxSafeZ = COURT_HALF_LENGTH - 4.0

  if math.abs(targetX) > maxSafeX then
    local signX = targetX > 0 and 1 or -1
    local clampedLookX = (signX * maxSafeX - hrp.Position.X) / estDist
    p.LookVector = Vector3.new(clampedLookX, look.Y, look.Z).Unit
    if p.TiltDirection then
      p.TiltDirection = Vector3.new(p.TiltDirection.X * 0.25, p.TiltDirection.Y, p.TiltDirection.Z)
    end
  end

  if math.abs(targetZ) > maxSafeZ then
    local signZ = targetZ > 0 and 1 or -1
    local clampedLookZ = (signZ * maxSafeZ - hrp.Position.Z) / estDist
    local currLook = p.LookVector or look
    p.LookVector = Vector3.new(currLook.X, currLook.Y, clampedLookZ).Unit
  end
end)

-- Feature #22: Spike Velocity Multiplier Injection
v45:HookMethod("Interact", "SpikeVelocityMultiplier", function(p)
  if not SpikeVelocityMultiplierEnabled then return end
  if type(p) ~= "table" or p.Move ~= "Spike" then return end

  local mult = SpikeVelocityMultiplierVal or 1.35
  p.PowerMultiplier = (p.PowerMultiplier or 1) * mult
  p.SpeedMultiplier = (p.SpeedMultiplier or 1) * mult
  if p.BallVelocity and typeof(p.BallVelocity) == "Vector3" then
    p.BallVelocity = p.BallVelocity * mult
  end
  if p.Velocity and typeof(p.Velocity) == "Vector3" then
    p.Velocity = p.Velocity * mult
  end
  if p.Power and type(p.Power) == "number" then
    p.Power = p.Power * mult
  end
end)

-- Feature #2 & #3: Live Ball Trajectory Predictor & Court Boundary Checker
local liveBallPredictorMarker = Instance.new("Part")
liveBallPredictorMarker.Name = "RzoHub_LiveBallPredictor"
liveBallPredictorMarker.Shape = Enum.PartType.Cylinder
liveBallPredictorMarker.Size = Vector3.new(0.25, 4.0, 4.0)
liveBallPredictorMarker.Material = Enum.Material.Neon
liveBallPredictorMarker.Color = Color3.fromRGB(0, 255, 180)
liveBallPredictorMarker.Anchored = true
liveBallPredictorMarker.CanCollide = false
liveBallPredictorMarker.CastShadow = false
liveBallPredictorMarker.Transparency = 1
liveBallPredictorMarker.Parent = v14

local landingBillboard = Instance.new("BillboardGui")
landingBillboard.Name = "LandingBillboard"
landingBillboard.Size = UDim2.new(0, 80, 0, 30)
landingBillboard.AlwaysOnTop = true
landingBillboard.StudsOffset = Vector3.new(0, 1.8, 0)
landingBillboard.Parent = liveBallPredictorMarker

local landingLabel = Instance.new("TextLabel")
landingLabel.Size = UDim2.new(1, 0, 1, 0)
landingLabel.BackgroundTransparency = 1
landingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
landingLabel.TextStrokeTransparency = 0.2
landingLabel.Font = Enum.Font.GothamBold
landingLabel.TextSize = 12
landingLabel.Text = ""
landingLabel.Parent = landingBillboard

-- Feature #10: Ball ESP & State Chams
local ballHighlight = Instance.new("Highlight")
ballHighlight.Name = "RzoHub_BallHighlight"
ballHighlight.FillTransparency = 0.4
ballHighlight.OutlineTransparency = 0
ballHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)

local ballBillboard = Instance.new("BillboardGui")
ballBillboard.Name = "RzoHub_BallBillboard"
ballBillboard.Size = UDim2.new(0, 110, 0, 35)
ballBillboard.AlwaysOnTop = true
ballBillboard.StudsOffset = Vector3.new(0, 2.5, 0)

local ballLabel = Instance.new("TextLabel")
ballLabel.Size = UDim2.new(1, 0, 1, 0)
ballLabel.BackgroundTransparency = 1
ballLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ballLabel.TextStrokeTransparency = 0.2
ballLabel.Font = Enum.Font.GothamBold
ballLabel.TextSize = 13
ballLabel.Text = "BALL"
ballLabel.Parent = ballBillboard

local function getLiveBall()
  local candidates = { "Ball", "Volleyball", "CurrentBall" }
  for _, name in ipairs(candidates) do
    local b = v14:FindFirstChild(name)
    if b and b:IsA("BasePart") then return b end
    if b and b:FindFirstChildWhichIsA("BasePart") then return b:FindFirstChildWhichIsA("BasePart") end
  end
  for _, obj in ipairs(v14:GetChildren()) do
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
  local hit = v14:Raycast(pos, Vector3.new(0, -999, 0), rayParams)
  local floorY = hit and hit.Position.Y or (pos.Y - 10)

  local g = v14.Gravity or 196.2
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

local liveBallRenderConnection = nil

local function updateLiveBallFrame()
  local activeBall = getLiveBall()

  -- Handle Ball Chams (#10)
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
      ballLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
      ballLabel.Text = string.format("SPIKE [%.0f spd | %.0fm]", spd, dist)
    elseif spd > 30 then
      ballHighlight.FillColor = Color3.fromRGB(50, 160, 255)
      ballLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
      ballLabel.Text = string.format("PASS [%.0f spd | %.0fm]", spd, dist)
    else
      ballHighlight.FillColor = Color3.fromRGB(255, 220, 50)
      ballLabel.TextColor3 = Color3.fromRGB(255, 230, 100)
      ballLabel.Text = string.format("BALL [%.0fm]", dist)
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

  -- Handle Live Trajectory Predictor & Boundary Checker (#2, #3)
  if LiveBallPredictorEnabled and activeBall then
    local landingPos, t = solveBallLanding(activeBall)
    if landingPos then
      liveBallPredictorMarker.CFrame = CFrame.new(landingPos) * CFrame.Angles(0, 0, math.pi / 2)
      liveBallPredictorMarker.Transparency = 0.25

      if CourtBoundaryCheckerEnabled then
        local inCourt = isInsideCourt(landingPos)
        if inCourt then
          liveBallPredictorMarker.Color = Color3.fromRGB(0, 255, 120)
          landingLabel.TextColor3 = Color3.fromRGB(100, 255, 120)
          landingLabel.Text = string.format("IN [%.1fs]", t)
        else
          liveBallPredictorMarker.Color = Color3.fromRGB(255, 45, 45)
          landingLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
          landingLabel.Text = string.format("OUT [%.1fs]", t)
        end
      else
        liveBallPredictorMarker.Color = Color3.fromRGB(0, 220, 255)
        landingLabel.TextColor3 = Color3.fromRGB(120, 230, 255)
        landingLabel.Text = string.format("%.1fs", t)
      end
    else
      liveBallPredictorMarker.Transparency = 1
      landingLabel.Text = ""
    end
  else
    liveBallPredictorMarker.Transparency = 1
    landingLabel.Text = ""
  end
end

local function updateLiveBallState()
  if LiveBallPredictorEnabled or BallChamsEnabled then
    if not liveBallRenderConnection then
      liveBallRenderConnection = runService.RenderStepped:Connect(updateLiveBallFrame)
    end
  else
    if liveBallRenderConnection then
      liveBallRenderConnection:Disconnect()
      liveBallRenderConnection = nil
    end
    liveBallPredictorMarker.Transparency = 1
    landingLabel.Text = ""
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

local v114 = {
  "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
  "https://cdn.jsdelivr.net/gh/Footagesus/WindUI@latest/dist/main.lua",
  "https://cdn.jsdelivr.net/gh/Footagesus/WindUI/dist/main.lua",
}

local v115 = writefile
local v116 = v115

if v115 then
  do
  end

  do
  end

  v116 = readfile and isfile
end

local v117

local function f7(p19)
  local v118 = p19

  if not v117 then
    return
  else
    pcall(function()
      writefile("RzoHub_WindUI.luau", p19)
      return
    end)

    return
  end
end

v117 = v116 and true or false
local v119 = syn

local function f8()
  local v120, v121

  if not v117 then
    return nil
  else
    local v122, v123

    v122, v123 = pcall(function()
      if (isfile("RzoHub_WindUI.luau")) then
        return readfile("RzoHub_WindUI.luau")
      else
        return
      end
    end)

    local v124
    v124 = v122

    if v122 then
      do
      end

      do
      end

      v124 = (type(v123)) == "string" and #v123 >= 1000
    end

    if v124 then
      return v123
    else
      return nil
    end
  end
end

local v125 = v119 and syn.request
local v126 = v125

if not v125 then
  do
  end

  local v127
  v127 = http and http.request

  local v128
  v128 = v127

  if not v127 then
    do
    end

    local v129
    v129 = fluxus and fluxus.request

    local httpRequest
    httpRequest = v129

    if not v129 then
      do
      end

      do
      end

      httpRequest = http_request or request
    end

    v128 = httpRequest
  end

  v126 = v128
end

local function f9(p20)
  local v130 = p20

  do
  end

  local v131 = (type(p20)) ~= "string" or #p20 < 1000
  local v132, v133, v134

  if v131 then
    return nil
  else
    local v135
    v135 = { pcall(loadstring, p20) }

    local v136
    v136 = v135[2]

    do
    end

    do
    end

    if not v135[1] or (type(v136)) ~= "function" then
      return nil
    else
      local v137, v138
      v138, v137 = pcall(v136)

      do
      end

      if v138 and (type(v137)) == "table" then
        return v137
      else
        return nil
      end
    end
  end
end

local v139 = v126

local function f10(p21)
  local v140 = p21
  local v141, v142, v143, v144, v145, v146

  if v139 then
    local v147, v148
    v147, v148 = pcall(v139, { Url = p21, Method = "GET" })

    local v149
    v149 = v147

    if v147 then
      local v150
      v150 = (type(v148)) == "table"

      local v151
      v151 = v150

      if v150 then
        local body
        body = v148.Body

        local v152
        v152 = body

        if body then
          do
          end

          do
          end

          v152 = v148.StatusCode == nil or v148.StatusCode == 200
        end

        v151 = v152
      end

      v149 = v151
    end

    if v149 then
      return v148.Body
    else
      ::L15192261::

      v144, v143 = pcall(function()
        do
        end

        return game:HttpGetAsync(p21)
      end)

      v145 = v144

      do
      end

      if v144 and (type(v143)) == "string" then
        return v143
      else
        local v153, v154

        v154, v153 = pcall(function()
          do
          end

          return game:HttpGet(p21)
        end)

        do
        end

        if v154 and (type(v153)) == "string" then
          return v153
        else
          return nil
        end
      end
    end
  else
    goto L15192261
  end
end

local v155 = f8()
local v156

if v155 then
  v156 = f9(v155)
end

if not v156 then
  for i = 1, 2 do
    for index5, value9 in ipairs(v114) do
      local v157
      v157 = f10(value9)

      local v158
      v158 = f9(v157)

      if v158 then
        f7(v157)
        v156 = v158
        break
      end
    end

    if v156 then
      break
    else
      task.wait(1.5)
    end
  end
end

local f11, f12, f13, f14, f15, f16, f17, rzoHubWindow, configManager, v159, v160, f18, f19,
  f20

if not v156 then
  pcall(function()
    do
    end

    local starterGui = game:GetService("StarterGui")

    starterGui:SetCore("SendNotification", {
      Title = "RzoHub Error",
      Text = "Failed to load UI (network?). Try executing again.",
      Duration = 10,
    })

    return
  end)

  return
else
  v156:AddTheme({
    Name = "Rzo Hub",
    Accent = (v156:Gradient({
      ["0"] = { Color = (Color3.fromHex("#000000")), Transparency = 0 },
      ["100"] = { Color = (Color3.fromHex("#1b1a1a")), Transparency = 0 },
    }, { Rotation = 90 })),
    Background = (Color3.fromHex("#0A0A0A")),
    Outline = (Color3.fromHex("#2A2A2A")),
    Text = (Color3.fromHex("#F5F5F5")),
    Placeholder = (Color3.fromHex("#606060")),
    Button = (Color3.fromHex("#1C1C1C")),
    Icon = (Color3.fromHex("#C0C0C0")),
  })

  v156:SetFont("rbxassetid://12187607287")

  rzoHubWindow = (v156:CreateWindow({
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
  }))

  local v161
  v161 = rzoHubWindow

  rzoHubWindow:EditOpenButton({
    Title = "VBL",
    Icon = "rbxassetid://79791092079055",
    CornerRadius = (UDim.new(0, 16)),
    StrokeThickness = 2,
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
    Color = (ColorSequence.new((Color3.fromHex("FFFFFF")), Color3.fromHex("000000"))),
  })

  local v162
  v162 = rzoHubWindow

  rzoHubWindow:Tag({ Title = "v1.0.0", Color = (Color3.fromHex("FFFFFF")) })

  local v163
  v163 = rzoHubWindow

  rzoHubWindow:Tag({ Title = "Volleyball Legends", Color = (Color3.fromHex("FFFFFF")) })

  task.spawn(function()
    task.wait(0.5)

    pcall(function()
      local v164 = rzoHubWindow
      rzoHubWindow:Close()
      return
    end)

    return
  end)

  configManager = rzoHubWindow.ConfigManager

  function f11(p22, p23, p24)
    local v165 = p23
    local v166 = p24

    do
    end

    local v167 = p22 == localPlayer and not p24
    local vector2

    if v167 then
      local currentCamera
      currentCamera = v14.CurrentCamera

      if currentCamera then
        local vector3

        vector3 = Vector3.new(
          currentCamera.CFrame.LookVector.X, 0, currentCamera.CFrame.LookVector.Z
        )

        if vector3.Magnitude > 0.01 then
          return vector3.Unit
        else
          ::L13967683::
          ::L5120700::
          vector2 = Vector3.new(p23.CFrame.LookVector.X, 0, p23.CFrame.LookVector.Z)

          if vector2.Magnitude < 0.01 then
            return nil
          else
            return vector2.Unit
          end
        end
      else
        goto L13967683
      end
    else
      goto L5120700
    end
  end

  v159 = {
    Markers = {},
    Connections = {},
    SelfEnabled = false,
    EnemyEnabled = false,
    BASE_DIST = 36.8,
    TILT_SCALE_FWD = 14.5,
    TILT_SCALE_BWD = 31.2,
    MIN_DIST = 10,
    BASE_LATERAL = 4.54,
  }

  function f12(p25, p26)
    local v168 = p26
    local raycastParams2 = RaycastParams.new()
    local v169, v170

    raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams2.FilterDescendantsInstances = { p26.Parent }

    local v171 = v14
    local raycast2 = v14:Raycast(p26.Position, (Vector3.new(0, -999, 0)), raycastParams2)

    do
    end

    do
    end

    return raycast2 and raycast2.Position.Y or p26.Position.Y - 3
  end

  function f13(p27)
    local v172 = p27
    local v173 = v160[p27]
    local v174, v175, v176

    if not v173 then
      local v177
      v177 = p27

      local gameplayTiltDirection
      gameplayTiltDirection = p27:GetAttribute("Gameplay_TiltDirection")

      local vector4
      vector4 = gameplayTiltDirection
      vector4 = gameplayTiltDirection or Vector3.new(0, 1, 0)

      local v178
      v178 = p27

      do
      end

      v173 = { tiltDir = vector4, tiltPower = (p27:GetAttribute("Multiplier_TiltPower")) or 1 }
      v160[p27] = v173

      local v179
      v179 = p27

      do
      end

      ;(p27:GetAttributeChangedSignal("Gameplay_TiltDirection")):Connect(function()
        local v180 = v173
        local v181 = p27
        local gameplayTiltDirection2 = p27:GetAttribute("Gameplay_TiltDirection")
        local v182 = gameplayTiltDirection2

        do
        end

        v180.tiltDir = gameplayTiltDirection2 or Vector3.new(0, 1, 0)
        return
      end)

      local v183
      v183 = p27

      do
      end

      ;(p27:GetAttributeChangedSignal("Multiplier_TiltPower")):Connect(function()
        local v184 = p27
        v173.tiltPower = (p27:GetAttribute("Multiplier_TiltPower")) or 1
        return
      end)
    end

    return v173
  end

  local v185
  v185 = f11

  v160 = {}

  function f14(p28)
    local v186 = p28

    local ballPredictorMarker = Instance.new("Part")
    ballPredictorMarker.Name = "BallPredictorMarker"
    ballPredictorMarker.Shape = Enum.PartType.Cylinder
    ballPredictorMarker.Size = Vector3.new(0.2, 3, 3)
    ballPredictorMarker.Material = Enum.Material.Neon
    ballPredictorMarker.Color = p28
    ballPredictorMarker.Anchored = true
    ballPredictorMarker.CanCollide = false
    ballPredictorMarker.CastShadow = false
    ballPredictorMarker.Transparency = 1
    ballPredictorMarker.Parent = v14

    return ballPredictorMarker
  end

  local v187
  v187 = f13

  local v188
  v188 = f12

  function f18(p29, p30, p31)
    local v189 = p29
    local v190 = p30
    local v191 = p31
    local v192 = f13(p30)
    local tiltDir = v192.tiltDir
    local tiltPower = v192.tiltPower
    local vector5 = Vector3.new(tiltDir.X, 0, tiltDir.Z)
    local v193 = f11(p30, p29, p31)
    local v194, v195, v196, v197, v198

    if not v193 then
      return nil
    else
      local dot
      dot = 0

      do
      end

      if p31 and vector5.Magnitude > 0.05 then
        dot = v193:Dot(vector5.Unit)
      end

      local unit
      unit = nil

      if p30 == localPlayer then
        local currentCamera2
        currentCamera2 = v14.CurrentCamera

        if currentCamera2 then
          local vector6

          vector6 = Vector3.new(
            currentCamera2.CFrame.RightVector.X, 0, currentCamera2.CFrame.RightVector.Z
          )

          if vector6.Magnitude > 0.01 then
            unit = vector6.Unit
          else
            unit = nil
          end
        end
      end

      if not unit then
        local vector7
        vector7 = Vector3.new(p29.CFrame.RightVector.X, 0, p29.CFrame.RightVector.Z)

        if vector7.Magnitude > 0.01 then
          unit = vector7.Unit
        else
          unit = Vector3.new(1, 0, 0)
        end
      end

      local dot2
      dot2 = 0

      do
      end

      do
      end

      if tiltPower > 1 and vector5.Magnitude > 0.05 then
        dot2 = unit:Dot(vector5.Unit)
      end

      do
      end

      do
      end

      local tiltSCALEFWD
      tiltSCALEFWD = dot >= 0 and v159.TILT_SCALE_FWD or v159.TILT_SCALE_BWD

      local v199
      v199 = math.max(v159.MIN_DIST, v159.BASE_DIST - dot * tiltSCALEFWD)

      local v200
      v200 = dot2 * v159.BASE_LATERAL * tiltPower

      local position2
      position2 = p29.Position

      local v201
      v201 = f12(p30, p29)

      return Vector3.new(
        position2.X + v193.X * v199 + unit.X * v200, v201 + 0.15,
        position2.Z + v193.Z * v199 + unit.Z * v200
      )
    end
  end

  local v202
  v202 = f14

  function f17(p32)
    local v203 = p32
    local v204, v205

    if v159.Markers[p32] then
      do
      end

      v159.Markers[p32]:Destroy()
      v159.Markers[p32] = nil
    end

    if v159.Connections[p32] then
      do
      end

      v159.Connections[p32]:Disconnect()
      v159.Connections[p32] = nil
    end

    return
  end

  function f15(p33)
    local v206 = p33
    local v207, v208

    if p33 == localPlayer then
      return false
    else
      do
      end

      do
      end

      if p33.Team and localPlayer.Team then
        return p33.Team ~= localPlayer.Team
      else
        return true
      end
    end
  end

  local v209
  v209 = f17

  function f19(p34, p35)
    local v210 = p34
    f17(p34)
    local v211 = (f14(p35))
    v159.Markers[p34] = v211
    local renderStepped = runService.RenderStepped

    v159.Connections[p34] = renderStepped:Connect(function()
      local character2 = p34.Character
      local v212 = character2
      local v213, v214

      do
      end

      local humanoidRootPart2 = character2 and character2:FindFirstChild("HumanoidRootPart")

      if not humanoidRootPart2 then
        v211.Transparency = 1
        return
      else
        local jumping
        jumping = character2:GetAttribute("Jumping")

        do
        end

        do
        end

        if p34 ~= localPlayer and not jumping then
          v211.Transparency = 1
          return
        else
          local v215
          v215 = f18(humanoidRootPart2, p34, jumping)

          if not v215 then
            v211.Transparency = 1
            return
          else
            v211.CFrame = (CFrame.new(v215)) * (CFrame.Angles(0, 0, math.pi / 2))
            v211.Transparency = 0.3
            return
          end
        end
      end
    end)

    return
  end

  local v216
  v216 = f15

  function f16(p36)
    local v217 = p36
    local characterAdded = p36.CharacterAdded
    local v218

    characterAdded:Connect(function()
      task.wait(0.5)

      if p36 == localPlayer then
        if v159.SelfEnabled then
          f19(localPlayer, Color3.fromRGB(0, 255, 100))
        end
      else
        local enemyEnabled
        enemyEnabled = v159.EnemyEnabled

        local v219
        v219 = enemyEnabled

        do
        end

        if enemyEnabled and f15(p36) then
          f19(p36, f1(p36))
        else
          f17(p36)
        end
      end

      return
    end)

    local v220 = p36

    do
    end

    ;(p36:GetPropertyChangedSignal("Team")):Connect(function()
      if v159.EnemyEnabled then
        if (f15(p36)) then
          if not v159.Connections[p36] then
            f19(p36, f1(p36))
          end
        else
          f17(p36)
        end
      end

      return
    end)

    return
  end

  function f20()
    if v159.SelfEnabled then
      f19(localPlayer, Color3.fromRGB(0, 255, 100))
    else
      f17(localPlayer)
    end

    local v221 = players

    for index6, value10 in ipairs(players:GetPlayers()) do
      if value10 ~= localPlayer then
        local enemyEnabled2
        enemyEnabled2 = v159.EnemyEnabled

        local v222
        v222 = enemyEnabled2

        do
        end

        if enemyEnabled2 and f15(value10) then
          f19(value10, f1(value10))
        else
          f17(value10)
        end
      end
    end

    return
  end

  local v223
  v223 = f16

  do
  end

  players.PlayerAdded:Connect(function(player2)
    local v224 = player2
    f16(player2)
    local enemyEnabled3 = v159.EnemyEnabled
    local v225 = enemyEnabled3

    do
    end

    if enemyEnabled3 and f15(player2) then
      task.wait(1)
      f19(player2, f1(player2))
    end

    return
  end)

  do
  end

  players.PlayerRemoving:Connect(function(player3)
    local v226 = player3
    f17(player3)
    v160[player3] = nil
    v16[player3] = nil
    return
  end)

  local v227
  v227 = players

  for index7, value11 in ipairs(players:GetPlayers()) do
    f16(value11)
  end

  local v228
  v228 = rzoHubWindow

  local mainTab
  mainTab = rzoHubWindow:Tab({ Title = "Main", Icon = "cpu", Locked = false })
  mainTab:Select()

  mainTab:Toggle({
    Title = "Ball Predictor (Self)",
    Icon = "target",
    Flag = "BallPredictorSelf",
    Callback = function(value12)
      v159.SelfEnabled = value12
      f20()
      return
    end,
  })

  mainTab:Toggle({
    Title = "Ball Predictor (Enemy)",
    Icon = "target",
    Flag = "BallPredictorEnemy",
    Callback = function(value13)
      v159.EnemyEnabled = value13
      f20()
      return
    end,
  })

  mainTab:Toggle({
    Title = "Enable ESP Character Direction",
    Icon = "eye",
    Flag = "ESPEnabled",
    Callback = function(value14)
      if value14 then
        f6()
      else
        f4()
      end

      return
    end,
  })

  mainTab:Toggle({
    Title = "Auto Max Charge Timeskip Hinata",
    Icon = "eye",
    Flag = "TimeskipChargeEnabled",
    Callback = function(value15)
      v94 = value15
      return
    end,
  })

  mainTab:Toggle({
    Title = "Extra Sanju Tilt",
    Icon = "eye",
    Flag = "SanjuTiltEnabled",
    Callback = function(value16)
      v103 = value16
      return
    end,
  })

  mainTab:Toggle({
    Title = "Live Ball Trajectory (Predictor)",
    Icon = "activity",
    Flag = "LiveBallPredictor",
    Callback = function(val)
      LiveBallPredictorEnabled = val
      updateLiveBallState()
      return
    end,
  })

  mainTab:Toggle({
    Title = "Court In/Out Boundary Checker",
    Icon = "map-pin",
    Flag = "CourtBoundaryChecker",
    Callback = function(val)
      CourtBoundaryCheckerEnabled = val
      return
    end,
  })

  mainTab:Toggle({
    Title = "Ball ESP & State Chams",
    Icon = "disc",
    Flag = "BallChamsEnabled",
    Callback = function(val)
      BallChamsEnabled = val
      updateLiveBallState()
      return
    end,
  })

  mainTab:Toggle({
    Title = "Auto Serve Perfect Power",
    Icon = "zap",
    Flag = "AutoServePower",
    Callback = function(val)
      AutoServePowerEnabled = val
      return
    end,
  })

  mainTab:Toggle({
    Title = "Anti-Out Spike Safety Clamp",
    Icon = "shield-check",
    Flag = "AntiOutSpikeClamp",
    Callback = function(val)
      AntiOutSpikeClampEnabled = val
      return
    end,
  })

  mainTab:Toggle({
    Title = "Spike Velocity Multiplier",
    Icon = "trending-up",
    Flag = "SpikeMultiplierEnabled",
    Callback = function(val)
      SpikeVelocityMultiplierEnabled = val
      return
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
      return
    end,
  })

  local v229
  v229 = configManager

  rzoHubWindow.CurrentConfig = configManager:CreateConfig("default")

  local currentConfig
  currentConfig = rzoHubWindow.CurrentConfig

  do
  end

  currentConfig:Load()

  local v230
  v230 = rzoHubWindow

  rzoHubWindow:OnClose(function()
    local v231 = configManager
    local v232
    rzoHubWindow.CurrentConfig = configManager:Config("default")

    do
    end

    rzoHubWindow.CurrentConfig:Save()
    return
  end)

  return
end
