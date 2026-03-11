-- ModMenu.lua
-- Host on GitHub, then load with:
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/YOURNAME/YOURREPO/main/ModMenu.lua"))()
-- Compatible with Xeno executor

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local lp     = Players.LocalPlayer
local camera = workspace.CurrentCamera

local function getChar() return lp.Character end
local function getRoot() local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()  local c = getChar() return c and c:FindFirstChildOfClass("Humanoid") end

local state = { fly=false, noclip=false, esp=false, aimbot=false }

-- ══════════════════════════════════════════
--  FLY
-- ══════════════════════════════════════════
local FLY_SPEED = 80

local function enableFly()
    local root = getRoot() if not root then return end
    local hum = getHum() if hum then hum.PlatformStand = true end
    local bv = Instance.new("BodyVelocity")
    bv.Name = "_FlyBV" bv.Velocity = Vector3.zero
    bv.MaxForce = Vector3.new(1e6,1e6,1e6) bv.Parent = root
    local bg = Instance.new("BodyGyro")
    bg.Name = "_FlyBG" bg.MaxTorque = Vector3.new(1e6,1e6,1e6)
    bg.D = 100 bg.Parent = root
end

local function disableFly()
    local root = getRoot()
    if root then
        for _,v in ipairs(root:GetChildren()) do
            if v.Name=="_FlyBV" or v.Name=="_FlyBG" then v:Destroy() end
        end
    end
    local hum = getHum() if hum then hum.PlatformStand = false end
end

RunService.Heartbeat:Connect(function()
    if not state.fly then return end
    local root = getRoot() if not root then return end
    local bv = root:FindFirstChild("_FlyBV") if not bv then return end
    local cf = camera.CFrame
    local dir = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cf.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cf.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cf.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cf.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space)       then dir += Vector3.yAxis end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.yAxis end
    bv.Velocity = dir.Magnitude > 0 and dir.Unit * FLY_SPEED or Vector3.zero
end)

-- ══════════════════════════════════════════
--  NOCLIP
-- ══════════════════════════════════════════
RunService.Stepped:Connect(function()
    if not state.noclip then return end
    local char = getChar() if not char then return end
    for _,p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end)

-- ══════════════════════════════════════════
--  ESP
-- ══════════════════════════════════════════
local espHL = {}

local function applyHL(player)
    if player == lp then return end
    local char = player.Character if not char then return end
    if espHL[player] then espHL[player]:Destroy() end
    local hl = Instance.new("Highlight")
    hl.Adornee = char
    hl.FillColor = Color3.fromRGB(255,50,50)
    hl.OutlineColor = Color3.fromRGB(255,255,255)
    hl.FillTransparency = 0.45
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = char
    espHL[player] = hl
end

local function enableESP()
    for _,p in ipairs(Players:GetPlayers()) do applyHL(p) end
    Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function()
            task.wait(0.1)
            if state.esp then applyHL(p) end
        end)
    end)
end

local function disableESP()
    for p,hl in pairs(espHL) do hl:Destroy() espHL[p]=nil end
end

-- ══════════════════════════════════════════
--  AIMBOT
-- ══════════════════════════════════════════
local function nearestPlayer()
    local root = getRoot() if not root then return nil end
    local best, bestDist = nil, math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            if r then
                local d = (r.Position - root.Position).Magnitude
                if d < bestDist then bestDist=d best=p end
            end
        end
    end
    return best
end

RunService.RenderStepped:Connect(function()
    if not state.aimbot then return end
    local target = nearestPlayer() if not target then return end
    local head = target.Character and target.Character:FindFirstChild("Head")
    if not head then return end
    camera.CFrame = CFrame.new(camera.CFrame.Position, head.Position)
end)

-- ══════════════════════════════════════════
--  GUI
-- ══════════════════════════════════════════
if lp.PlayerGui:FindFirstChild("_ModMenu") then
    lp.PlayerGui._ModMenu:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "_ModMenu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = lp.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,215,0,320)
frame.Position = UDim2.new(0,16,0.5,-160)
frame.BackgroundColor3 = Color3.fromRGB(10,10,10)
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner",frame).CornerRadius = UDim.new(0,10)
local stroke = Instance.new("UIStroke",frame)
stroke.Color = Color3.fromRGB(0,210,115)
stroke.Thickness = 1.5

local bar = Instance.new("Frame")
bar.Size = UDim2.new(1,0,0,38)
bar.BackgroundColor3 = Color3.fromRGB(18,18,18)
bar.BorderSizePixel = 0
bar.Parent = frame
Instance.new("UICorner",bar).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,1,0)
title.BackgroundTransparency = 1
title.Text = "⚡  MOD MENU"
title.Font = Enum.Font.Code
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(0,210,115)
title.Parent = bar

-- Drag
local dragging, dStart, fStart
bar.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=true dStart=i.Position fStart=frame.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d = i.Position - dStart
        frame.Position = UDim2.new(fStart.X.Scale, fStart.X.Offset+d.X, fStart.Y.Scale, fStart.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
end)

local BUTTONS = {
    { label="✈  Fly",      key="fly",    on=enableFly,    off=disableFly  },
    { label="👻  NoClip",  key="noclip", on=function()end, off=function()end },
    { label="👁  ESP",     key="esp",    on=enableESP,    off=disableESP  },
    { label="🎯  Aimbot",  key="aimbot", on=function()end, off=function()end },
}

local COL_ON  = Color3.fromRGB(0,210,115)
local COL_OFF = Color3.fromRGB(160,160,160)
local BG_ON   = Color3.fromRGB(0,38,20)
local BG_OFF  = Color3.fromRGB(24,24,24)

for i,info in ipairs(BUTTONS) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-20,0,50)
    btn.Position = UDim2.new(0,10,0,44+(i-1)*60)
    btn.BackgroundColor3 = BG_OFF
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Code
    btn.TextSize = 13
    btn.TextColor3 = COL_OFF
    btn.Text = "  "..info.label.."    [ OFF ]"
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = frame
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,7)

    btn.MouseButton1Click:Connect(function()
        state[info.key] = not state[info.key]
        if state[info.key] then
            info.on()
            btn.BackgroundColor3 = BG_ON
            btn.TextColor3 = COL_ON
            btn.Text = "  "..info.label.."    [ ON ]"
        else
            info.off()
            btn.BackgroundColor3 = BG_OFF
            btn.TextColor3 = COL_OFF
            btn.Text = "  "..info.label.."    [ OFF ]"
        end
    end)
end

-- RightShift to hide/show
UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        frame.Visible = not frame.Visible
    end
end)

print("[ModMenu] Loaded! Press RightShift to toggle UI")
