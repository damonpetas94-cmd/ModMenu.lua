-- Waveyy.lua
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/damonpetas94-cmd/ModMenu.lua/main/ModMenu.lua"))()
-- Universal: Xeno, Delta, Synapse X, KRNL, Fluxus, Evon, Codex, Arceus X

-- ════════════════════════════════════════════════════════════
--  KEY CONFIG
-- ════════════════════════════════════════════════════════════
local PREMIUM_KEYS = {
    "Waveyy-LIFETIME-001",
    "Waveyy-LIFETIME-002",
    "Waveyy-LIFETIME-003",
}
local REGULAR_KEYS = {
    "WAVE-FRIEND-001",
    "WAVE-FRIEND-002",
    "WAVE-FRIEND-003",
    "WAVE-FRIEND-004",
    "WAVE-FRIEND-005",
}

-- ════════════════════════════════════════════════════════════
--  UNIVERSAL HTTP
-- ════════════════════════════════════════════════════════════
local function httpGet(url)
    if syn and syn.request then return syn.request({Url=url,Method="GET"}).Body
    elseif http and http.request then return http.request({Url=url,Method="GET"}).Body
    elseif request then return request({Url=url,Method="GET"}).Body
    else
        local ok,res = pcall(function() return game:HttpGet(url) end)
        if ok then return res end
        ok,res = pcall(function() return game:HttpGetAsync(url) end)
        if ok then return res end
    end
end

-- ════════════════════════════════════════════════════════════
--  FILE SYSTEM
-- ════════════════════════════════════════════════════════════
local KEY_FILE = "WaveyyyKey.txt"
local function safeWrite(p,d) pcall(function() if writefile then writefile(p,d) end end) end
local function safeRead(p)  local ok,d=pcall(function() if readfile then return readfile(p) end end) return ok and d or nil end
local function safeDelete(p) pcall(function() if delfile then delfile(p) end end) end

-- ════════════════════════════════════════════════════════════
--  KEY VALIDATION
-- ════════════════════════════════════════════════════════════
local function isPremiumKey(k) for _,v in ipairs(PREMIUM_KEYS) do if k==v then return true end end return false end
local function isRegularKey(k) for _,v in ipairs(REGULAR_KEYS) do if k==v then return true end end return false end

local function validateKey(key)
    key = key:gsub("%s","")
    if isPremiumKey(key) then safeWrite(KEY_FILE,key.."|premium") return "premium" end
    if isRegularKey(key) then
        local stored = safeRead(KEY_FILE)
        if stored then
            local sk,st = stored:match("^(.+)|(%d+)$")
            if sk==key then
                if os.time()-tonumber(st) > 86400 then safeDelete(KEY_FILE) return "expired"
                else return "valid" end
            end
        end
        safeWrite(KEY_FILE,key.."|"..os.time())
        return "valid"
    end
    return "invalid"
end

local function checkSavedKey()
    local stored = safeRead(KEY_FILE) if not stored then return nil end
    if stored:match("|premium$") then
        local k = stored:match("^(.+)|premium$")
        if isPremiumKey(k) then return "premium" end
    end
    local k,t = stored:match("^(.+)|(%d+)$")
    if k and t and isRegularKey(k) then
        if os.time()-tonumber(t) <= 86400 then return "valid"
        else safeDelete(KEY_FILE) return "expired" end
    end
    return nil
end

-- ════════════════════════════════════════════════════════════
--  SERVICES
-- ════════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")

local lp     = Players.LocalPlayer
local camera = workspace.CurrentCamera

local function getChar() return lp.Character end
local function getRoot() local c=getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()  local c=getChar() return c and c:FindFirstChildOfClass("Humanoid") end

-- ════════════════════════════════════════════════════════════
--  INTRO SCREEN  (matches the dark wavy Waveyy aesthetic)
-- ════════════════════════════════════════════════════════════
if lp.PlayerGui:FindFirstChild("_WaveyyyIntro") then lp.PlayerGui._WaveyyyIntro:Destroy() end

local introGui = Instance.new("ScreenGui")
introGui.Name           = "_WaveyyyIntro"
introGui.ResetOnSpawn   = false
introGui.IgnoreGuiInset = true
introGui.DisplayOrder   = 999
introGui.Parent         = lp.PlayerGui

-- Full black background
local backdrop = Instance.new("Frame")
backdrop.Size             = UDim2.new(1,0,1,0)
backdrop.BackgroundColor3 = Color3.fromRGB(0,0,0)
backdrop.BorderSizePixel  = 0
backdrop.Parent           = introGui

-- Wave lines container
local waveContainer = Instance.new("Frame")
waveContainer.Size             = UDim2.new(1,0,1,0)
waveContainer.BackgroundTransparency = 1
waveContainer.ClipsDescendants = true
waveContainer.Parent           = backdrop

-- Generate wavy vertical lines (like the GIF)
local NUM_LINES = 28
local lines = {}
for i = 1, NUM_LINES do
    local line = Instance.new("Frame")
    local xPos = (i-1)/NUM_LINES
    line.Size             = UDim2.new(0, 3, 1.4, 0)
    line.Position         = UDim2.new(xPos, 0, -0.2, 0)
    line.BackgroundColor3 = Color3.fromRGB(
        math.random(5,18),
        math.random(5,18),
        math.random(20,50)
    )
    line.BorderSizePixel  = 0
    line.Rotation         = math.random(-8, 8)
    line.Parent           = waveContainer
    lines[i] = {frame=line, baseX=xPos, baseRot=line.Rotation, offset=math.random(0,62)/10}
end

-- Waveyy title text
local titleLabel = Instance.new("TextLabel")
titleLabel.Size                  = UDim2.new(1,0,0,80)
titleLabel.Position              = UDim2.new(0,0,0.5,-40)
titleLabel.BackgroundTransparency= 1
titleLabel.Text                  = "Waveyy"
titleLabel.Font                  = Enum.Font.GothamBlack
titleLabel.TextSize              = 52
titleLabel.TextColor3            = Color3.fromRGB(30,60,220)
titleLabel.TextStrokeColor3      = Color3.fromRGB(0,10,80)
titleLabel.TextStrokeTransparency= 0.3
titleLabel.TextTransparency      = 1  -- starts invisible
titleLabel.Parent                = backdrop

-- Subtitle
local subLabel = Instance.new("TextLabel")
subLabel.Size                  = UDim2.new(1,0,0,30)
subLabel.Position              = UDim2.new(0,0,0.5,44)
subLabel.BackgroundTransparency= 1
subLabel.Text                  = "loading..."
subLabel.Font                  = Enum.Font.Gotham
subLabel.TextSize              = 14
subLabel.TextColor3            = Color3.fromRGB(60,100,200)
subLabel.TextTransparency      = 1
subLabel.Parent                = backdrop

-- Animate wave lines
local t = 0
local waveConn
waveConn = RunService.Heartbeat:Connect(function(dt)
    t = t + dt
    for i, data in ipairs(lines) do
        local wave = math.sin(t * 1.8 + data.offset) * 0.012
        data.frame.Position = UDim2.new(data.baseX + wave, 0, -0.2, 0)
        data.frame.Rotation = data.baseRot + math.sin(t * 1.2 + data.offset) * 3
    end
end)

-- Fade in title
task.wait(0.3)
TweenService:Create(titleLabel, TweenInfo.new(1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency=0}):Play()
TweenService:Create(subLabel,  TweenInfo.new(1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency=0}):Play()

-- Shimmer/pulse on title
task.delay(1.2, function()
    while introGui.Parent do
        TweenService:Create(titleLabel, TweenInfo.new(0.6,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut), {TextColor3=Color3.fromRGB(80,120,255)}):Play()
        task.wait(0.6)
        TweenService:Create(titleLabel, TweenInfo.new(0.6,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut), {TextColor3=Color3.fromRGB(20,50,200)}):Play()
        task.wait(0.6)
    end
end)

task.wait(2.8)

-- Swap loading text
subLabel.Text = "initializing key system..."
task.wait(0.8)

-- Fade out intro
TweenService:Create(backdrop, TweenInfo.new(0.7,Enum.EasingStyle.Quad,Enum.EasingDirection.In), {BackgroundTransparency=1}):Play()
TweenService:Create(titleLabel, TweenInfo.new(0.7,Enum.EasingStyle.Quad,Enum.EasingDirection.In), {TextTransparency=1}):Play()
TweenService:Create(subLabel,   TweenInfo.new(0.7,Enum.EasingStyle.Quad,Enum.EasingDirection.In), {TextTransparency=1}):Play()
for _,data in ipairs(lines) do
    TweenService:Create(data.frame, TweenInfo.new(0.7), {BackgroundTransparency=1}):Play()
end
task.wait(0.8)
waveConn:Disconnect()
introGui:Destroy()

-- ════════════════════════════════════════════════════════════
--  STATE
-- ════════════════════════════════════════════════════════════
local state           = {fly=false,noclip=false,esp=false,aimbot=false}
local FLY_SPEED       = 80
local AIMBOT_SMOOTH   = 0.15
local excludedPlayers = {}
local aimbotKey       = Enum.KeyCode.RightAlt
local toggleGuiKey    = Enum.KeyCode.RightShift
local remappingAimbot = false
local remappingGui    = false
local invisActive     = false

-- ════════════════════════════════════════════════════════════
--  FLY
-- ════════════════════════════════════════════════════════════
local function enableFly()
    local root=getRoot() if not root then return end
    local hum=getHum() if hum then hum.PlatformStand=true end
    if root:FindFirstChild("_FlyBV") then return end
    local bv=Instance.new("BodyVelocity")
    bv.Name="_FlyBV" bv.Velocity=Vector3.new(0,0,0) bv.MaxForce=Vector3.new(1e6,1e6,1e6) bv.Parent=root
    local bg=Instance.new("BodyGyro")
    bg.Name="_FlyBG" bg.MaxTorque=Vector3.new(1e6,1e6,1e6) bg.D=100 bg.Parent=root
end
local function disableFly()
    local root=getRoot()
    if root then for _,v in ipairs(root:GetChildren()) do if v.Name=="_FlyBV" or v.Name=="_FlyBG" then v:Destroy() end end end
    local hum=getHum() if hum then hum.PlatformStand=false end
end
local function setInvis(on)
    local char=getChar() if not char then return end
    for _,p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") or p:IsA("Decal") then
            if on then p:SetAttribute("_origTrans",p.Transparency) p.Transparency=1
            else p.Transparency=p:GetAttribute("_origTrans") or 0 end
        end
    end
    invisActive=on
end
RunService.Heartbeat:Connect(function()
    if not state.fly then return end
    local root=getRoot() if not root then return end
    local bv=root:FindFirstChild("_FlyBV") if not bv then return end
    local cf=camera.CFrame local x,y,z=0,0,0
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then x=x+cf.LookVector.X  y=y+cf.LookVector.Y  z=z+cf.LookVector.Z  end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then x=x-cf.LookVector.X  y=y-cf.LookVector.Y  z=z-cf.LookVector.Z  end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then x=x-cf.RightVector.X y=y-cf.RightVector.Y z=z-cf.RightVector.Z end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then x=x+cf.RightVector.X y=y+cf.RightVector.Y z=z+cf.RightVector.Z end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space)       then y=y+1 end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then y=y-1 end
    local dir=Vector3.new(x,y,z)
    bv.Velocity = dir.Magnitude>0 and dir.Unit*FLY_SPEED or Vector3.new(0,0,0)
    if FLY_SPEED>=500 and not invisActive then setInvis(true)
    elseif FLY_SPEED<500 and invisActive  then setInvis(false) end
end)

-- ════════════════════════════════════════════════════════════
--  NOCLIP
-- ════════════════════════════════════════════════════════════
RunService.Stepped:Connect(function()
    if not state.noclip then return end
    local char=getChar() if not char then return end
    for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
end)

-- ════════════════════════════════════════════════════════════
--  ESP
-- ════════════════════════════════════════════════════════════
local espHL={}
local function applyHL(player)
    if player==lp then return end
    local char=player.Character if not char then return end
    if espHL[player] then espHL[player]:Destroy() end
    local hl=Instance.new("Highlight")
    hl.Adornee=char hl.FillColor=Color3.fromRGB(255,50,50)
    hl.OutlineColor=Color3.fromRGB(255,255,255)
    hl.FillTransparency=0.45 hl.OutlineTransparency=0
    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop hl.Parent=char espHL[player]=hl
end
local function enableESP()
    for _,p in ipairs(Players:GetPlayers()) do applyHL(p) end
    Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() task.wait(0.1) if state.esp then applyHL(p) end end) end)
end
local function disableESP() for p,hl in pairs(espHL) do hl:Destroy() espHL[p]=nil end end

-- ════════════════════════════════════════════════════════════
--  AIMBOT
-- ════════════════════════════════════════════════════════════
local function nearestPlayer()
    local root=getRoot() if not root then return nil end
    local best,bestDist=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and not excludedPlayers[p.Name] and p.Character then
            local r=p.Character:FindFirstChild("HumanoidRootPart")
            if r then local d=(r.Position-root.Position).Magnitude if d<bestDist then bestDist=d best=p end end
        end
    end
    return best
end
RunService.RenderStepped:Connect(function()
    if not state.aimbot then return end
    local target=nearestPlayer() if not target then return end
    local head=target.Character and target.Character:FindFirstChild("Head") if not head then return end
    camera.CFrame=camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position,head.Position),AIMBOT_SMOOTH)
end)

-- ════════════════════════════════════════════════════════════
--  UNLOCK ALL
-- ════════════════════════════════════════════════════════════
local function unlockAll()
    local rs=game:GetService("ReplicatedStorage")
    local unlockWords={"unlock","give","grant","award","equip","purchase","buy","open","claim","redeem","all","skin","charm","finisher","emote","cosmetic","item"}
    local cosmeticWords={"skin","charm","finisher","emote","cosmetic","unlocked","owned","equipped","coin","cash","money","gem","credit","point","level","xp","rank"}
    pcall(function()
        for _,v in ipairs(rs:GetDescendants()) do
            local n=v.Name:lower()
            if v:IsA("RemoteEvent") then
                for _,w in ipairs(unlockWords) do if n:find(w) then
                    pcall(function() v:FireServer() end) pcall(function() v:FireServer(true) end)
                    pcall(function() v:FireServer("all") end) pcall(function() v:FireServer(lp) end)
                    break
                end end
            elseif v:IsA("RemoteFunction") then
                for _,w in ipairs(unlockWords) do if n:find(w) then
                    pcall(function() v:InvokeServer() end) pcall(function() v:InvokeServer(true) end)
                    break
                end end
            end
        end
    end)
    pcall(function()
        for _,v in ipairs(rs:GetDescendants()) do if v:IsA("Tool") then pcall(function() v:Clone().Parent=lp.Backpack end) end end
    end)
    local function maxValues(parent)
        pcall(function()
            for _,v in ipairs(parent:GetDescendants()) do
                local n=v.Name:lower()
                if v:IsA("BoolValue") then
                    for _,w in ipairs(cosmeticWords) do if n:find(w) then pcall(function() v.Value=true end) break end end
                elseif v:IsA("IntValue") or v:IsA("NumberValue") then
                    for _,w in ipairs(cosmeticWords) do if n:find(w) then pcall(function() v.Value=999999999 end) break end end
                elseif v:IsA("StringValue") then
                    for _,w in ipairs(cosmeticWords) do if n:find(w) then pcall(function() v.Value="all" end) break end end
                end
            end
        end)
    end
    maxValues(lp)
    local commonNames={"UnlockSkin","GiveSkin","UnlockAll","UnlockCosmetic","GiveCosmetic","UnlockEmote","GiveEmote","UnlockCharm","GiveCharm","UnlockFinisher","GiveFinisher"}
    for _,name in ipairs(commonNames) do
        pcall(function()
            local re=rs:FindFirstChild(name,true)
            if re and re:IsA("RemoteEvent") then re:FireServer() re:FireServer(true) re:FireServer("all")
            elseif re and re:IsA("RemoteFunction") then re:InvokeServer() re:InvokeServer(true) end
        end)
    end
end

-- ════════════════════════════════════════════════════════════
--  KEY SYSTEM UI
-- ════════════════════════════════════════════════════════════
local savedStatus = checkSavedKey()
local keyType = savedStatus

if not keyType or keyType == "expired" then
    if lp.PlayerGui:FindFirstChild("_KeySystem") then lp.PlayerGui._KeySystem:Destroy() end

    local keyGui = Instance.new("ScreenGui")
    keyGui.Name="_KeySystem" keyGui.ResetOnSpawn=false keyGui.IgnoreGuiInset=true keyGui.Parent=lp.PlayerGui

    local bg2=Instance.new("Frame")
    bg2.Size=UDim2.new(1,0,1,0) bg2.BackgroundColor3=Color3.fromRGB(3,3,8)
    bg2.BackgroundTransparency=0.1 bg2.BorderSizePixel=0 bg2.Parent=keyGui

    local card=Instance.new("Frame")
    card.Size=UDim2.new(0,400,0,300) card.Position=UDim2.new(0.5,-200,0.5,-150)
    card.BackgroundColor3=Color3.fromRGB(8,8,16) card.BorderSizePixel=0 card.Parent=bg2
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,14)
    local cs=Instance.new("UIStroke",card) cs.Color=Color3.fromRGB(30,60,220) cs.Thickness=1.8

    -- Waveyy branding on key screen
    local kbrand=Instance.new("TextLabel")
    kbrand.Size=UDim2.new(1,0,0,44) kbrand.Position=UDim2.new(0,0,0,10)
    kbrand.BackgroundTransparency=1 kbrand.Text="Waveyy"
    kbrand.Font=Enum.Font.GothamBlack kbrand.TextSize=26
    kbrand.TextColor3=Color3.fromRGB(30,60,220)
    kbrand.TextStrokeColor3=Color3.fromRGB(0,10,80) kbrand.TextStrokeTransparency=0.4
    kbrand.Parent=card

    local ksub=Instance.new("TextLabel")
    ksub.Size=UDim2.new(1,0,0,20) ksub.Position=UDim2.new(0,0,0,52)
    ksub.BackgroundTransparency=1 ksub.Text="Enter your key to continue"
    ksub.Font=Enum.Font.Gotham ksub.TextSize=12
    ksub.TextColor3=Color3.fromRGB(60,80,160) ksub.Parent=card

    if keyType=="expired" then
        local expLbl=Instance.new("TextLabel")
        expLbl.Size=UDim2.new(1,-40,0,22) expLbl.Position=UDim2.new(0,20,0,74)
        expLbl.BackgroundTransparency=1 expLbl.Text="⚠  Your key expired! Get a new one from Damon."
        expLbl.Font=Enum.Font.Gotham expLbl.TextSize=11
        expLbl.TextColor3=Color3.fromRGB(255,140,0) expLbl.Parent=card
    end

    local kentry=Instance.new("TextBox")
    kentry.Size=UDim2.new(1,-40,0,48) kentry.Position=UDim2.new(0,20,0,104)
    kentry.BackgroundColor3=Color3.fromRGB(14,14,28) kentry.BorderSizePixel=0
    kentry.Font=Enum.Font.Code kentry.TextSize=14
    kentry.TextColor3=Color3.fromRGB(255,255,255)
    kentry.PlaceholderText="Enter key..." kentry.PlaceholderColor3=Color3.fromRGB(50,50,80)
    kentry.Text="" kentry.ClearTextOnFocus=false kentry.Parent=card
    Instance.new("UICorner",kentry).CornerRadius=UDim.new(0,8)
    local kes=Instance.new("UIStroke",kentry) kes.Color=Color3.fromRGB(30,60,220) kes.Thickness=1

    local kstatus=Instance.new("TextLabel")
    kstatus.Size=UDim2.new(1,-40,0,26) kstatus.Position=UDim2.new(0,20,0,158)
    kstatus.BackgroundTransparency=1 kstatus.Text=""
    kstatus.Font=Enum.Font.Gotham kstatus.TextSize=12
    kstatus.TextColor3=Color3.fromRGB(255,80,80) kstatus.Parent=card

    local kbtn=Instance.new("TextButton")
    kbtn.Size=UDim2.new(1,-40,0,48) kbtn.Position=UDim2.new(0,20,0,190)
    kbtn.BackgroundColor3=Color3.fromRGB(20,50,200) kbtn.BorderSizePixel=0
    kbtn.Font=Enum.Font.GothamBold kbtn.TextSize=15
    kbtn.TextColor3=Color3.fromRGB(255,255,255) kbtn.Text="UNLOCK" kbtn.Parent=card
    Instance.new("UICorner",kbtn).CornerRadius=UDim.new(0,8)

    local pinfo=Instance.new("TextLabel")
    pinfo.Size=UDim2.new(1,-40,0,24) pinfo.Position=UDim2.new(0,20,0,248)
    pinfo.BackgroundTransparency=1 pinfo.Text="⭐ Premium = lifetime  |  Regular keys expire in 24h"
    pinfo.Font=Enum.Font.Gotham pinfo.TextSize=11
    pinfo.TextColor3=Color3.fromRGB(40,50,100) pinfo.Parent=card

    local keyPassed=Instance.new("BindableEvent")

    kbtn.MouseButton1Click:Connect(function()
        local result=validateKey(kentry.Text)
        if result=="premium" or result=="valid" then
            keyType=result keyGui:Destroy() keyPassed:Fire()
        elseif result=="expired" then
            kstatus.Text="⚠  Key expired! Get a new one from Damon." kentry.Text=""
        else
            kstatus.Text="✗  Invalid key!" kentry.Text=""
        end
    end)
    kentry.FocusLost:Connect(function(enter) if enter then kbtn.MouseButton1Click:Fire() end end)
    keyPassed.Event:Wait()
    keyPassed:Destroy()
end

-- ════════════════════════════════════════════════════════════
--  LOAD RAYFIELD
-- ════════════════════════════════════════════════════════════
local Rayfield
pcall(function() Rayfield=loadstring(httpGet('https://sirius.menu/rayfield'))() end)
if not Rayfield then
    pcall(function() Rayfield=loadstring(httpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))() end)
end
if not Rayfield then warn("[Waveyy] Rayfield failed to load.") return end

local isPremium = keyType=="premium"

local Window=Rayfield:CreateWindow({
    Name           = isPremium and "Waveyy  ⭐ Lifetime" or "Waveyy",
    LoadingTitle   = "Waveyy",
    LoadingSubtitle= isPremium and "Lifetime Access" or "24h Key",
    ConfigurationSaving={Enabled=false},
    Discord={Enabled=false},
    KeySystem=false,
})

-- ── Mods Tab ──────────────────────────────
local ModTab=Window:CreateTab("⚙  Mods",4483362458)
ModTab:CreateToggle({Name="Fly",CurrentValue=false,Flag="FlyToggle",Callback=function(v) state.fly=v if v then enableFly() else disableFly() end end})
ModTab:CreateSlider({Name="Fly Speed  [500 = invisible prank]",Range={1,500},Increment=1,CurrentValue=80,Flag="FlySpeed",Callback=function(v) FLY_SPEED=v end})
ModTab:CreateDivider()
ModTab:CreateToggle({Name="NoClip",CurrentValue=false,Flag="NoclipToggle",Callback=function(v) state.noclip=v end})
ModTab:CreateDivider()
ModTab:CreateToggle({Name="ESP",CurrentValue=false,Flag="ESPToggle",Callback=function(v) state.esp=v if v then enableESP() else disableESP() end end})
ModTab:CreateDivider()
ModTab:CreateToggle({Name="Aimbot (auto lock-on)",CurrentValue=false,Flag="AimbotToggle",Callback=function(v) state.aimbot=v end})
ModTab:CreateSlider({Name="Aimbot Smoothness  [1=slow 20=instant]",Range={1,20},Increment=1,CurrentValue=3,Flag="AimbotSmooth",Callback=function(v) AIMBOT_SMOOTH=v/20 end})

-- ── Unlock Tab ────────────────────────────
local UnlockTab=Window:CreateTab("🔓  Unlock",4483362458)
UnlockTab:CreateButton({Name="🎨  Unlock All Skins",   Callback=function() unlockAll() Rayfield:Notify({Title="Skins",    Content="Attempted to unlock all skins!",    Duration=4}) end})
UnlockTab:CreateButton({Name="✨  Unlock All Charms",  Callback=function() unlockAll() Rayfield:Notify({Title="Charms",   Content="Attempted to unlock all charms!",   Duration=4}) end})
UnlockTab:CreateButton({Name="💀  Unlock All Finishers",Callback=function() unlockAll() Rayfield:Notify({Title="Finishers",Content="Attempted to unlock all finishers!",Duration=4}) end})
UnlockTab:CreateButton({Name="💃  Unlock All Emotes",  Callback=function() unlockAll() Rayfield:Notify({Title="Emotes",   Content="Attempted to unlock all emotes!",   Duration=4}) end})
UnlockTab:CreateDivider()
UnlockTab:CreateButton({Name="🔓  Unlock EVERYTHING",  Callback=function() unlockAll() Rayfield:Notify({Title="Unlock All",Content="Attempted to unlock everything!",   Duration=5}) end})

-- ── Exclude Tab ───────────────────────────
local ExclTab=Window:CreateTab("🚫  Exclude",4483362458)
ExclTab:CreateParagraph({Title="Aimbot Exclusions",Content="Toggle a player OFF to stop aimbot targeting them."})
local exclToggles={}
local function refreshExclusions()
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and not exclToggles[p.Name] then
            exclToggles[p.Name]=true
            ExclTab:CreateToggle({Name=p.Name,CurrentValue=true,Flag="Excl_"..p.Name,Callback=function(v)
                if v then excludedPlayers[p.Name]=nil else excludedPlayers[p.Name]=true end
            end})
        end
    end
end
refreshExclusions()
Players.PlayerAdded:Connect(function() task.wait(1) refreshExclusions() end)
ExclTab:CreateButton({Name="🔄  Refresh Player List",Callback=function() refreshExclusions() Rayfield:Notify({Title="Refreshed",Content="Player list updated!",Duration=3}) end})

-- ── Keybinds Tab ──────────────────────────
local KbTab=Window:CreateTab("🎮  Keybinds",4483362458)
KbTab:CreateParagraph({Title="How to Remap",Content="Click a button, then press any key on your keyboard."})
KbTab:CreateButton({Name="Remap: Aimbot Toggle  ["..aimbotKey.Name.."]",Callback=function() remappingAimbot=true Rayfield:Notify({Title="Press a key...",Content="Waiting for aimbot key",Duration=5}) end})
KbTab:CreateButton({Name="Remap: Show/Hide GUI  ["..toggleGuiKey.Name.."]",Callback=function() remappingGui=true Rayfield:Notify({Title="Press a key...",Content="Waiting for GUI key",Duration=5}) end})

-- ── Info Tab ──────────────────────────────
local InfoTab=Window:CreateTab("ℹ  Info",4483362458)
InfoTab:CreateParagraph({Title="Waveyy",Content="Made by Damon\nPrivate use only - do not share"})
InfoTab:CreateParagraph({Title="Key Status",Content=isPremium and "⭐ Lifetime (Premium) access!" or "🕐 Key expires 24h after first use. Ask Damon for a new one."})
InfoTab:CreateParagraph({Title="Controls",Content="Fly: WASD | Space=up | Ctrl=down\nSpeed 500 = invisible troll mode\nAimbot: auto locks nearest non-excluded player\nExclude tab: remove teammates from aimbot"})
InfoTab:CreateParagraph({Title="Compatibility",Content="Xeno, Delta, Synapse X, KRNL, Fluxus, Evon, Codex, Arceus X + more"})

-- ════════════════════════════════════════════════════════════
--  INPUT HANDLER
-- ════════════════════════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.UserInputType~=Enum.UserInputType.Keyboard then return end
    if remappingAimbot then
        remappingAimbot=false aimbotKey=input.KeyCode
        Rayfield:Notify({Title="Aimbot Key Set!",Content="Key: "..input.KeyCode.Name,Duration=3}) return
    end
    if remappingGui then
        remappingGui=false toggleGuiKey=input.KeyCode
        Rayfield:Notify({Title="GUI Key Set!",Content="Key: "..input.KeyCode.Name,Duration=3}) return
    end
    if input.KeyCode==toggleGuiKey then
        for _,v in ipairs(lp.PlayerGui:GetChildren()) do
            if v.Name:find("Rayfield") or v.Name:find("Waveyy") or v.Name:find("ModMenu") then
                pcall(function() v.Enabled=not v.Enabled end)
            end
        end
    end
end)

print("[Waveyy] Loaded! Key: "..tostring(keyType))
