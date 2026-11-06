--[[
	Constipated Hub | Murder Mystery 2  v3
	Place: 142823291
	Hardened Silent Aim · Crosshairs · Full ESP · Coin Farm · Roles
]]

repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer

local ok, OrionLib = pcall(function()
	return loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
end)
if not ok or not OrionLib then
	warn("[Constipated] Orion failed")
	return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local GENV = (typeof(getgenv) == "function" and getgenv()) or _G
GENV.__ConstipatedMM2 = (GENV.__ConstipatedMM2 or 0) + 1
local GEN = GENV.__ConstipatedMM2
local function alive()
	return GENV.__ConstipatedMM2 == GEN
end

local F = {
	SilentAim = false,
	Aimbot = false,
	AimPart = "Head",
	AimSmooth = 0.18,
	FOV = 180,
	ShowFOV = true,
	Prediction = true,
	PredMult = 0.12,
	AutoShoot = false,
	AutoKnife = false,
	Triggerbot = false,
	KillAura = false,
	KillAuraRange = 14,
	AimTarget = "Murderer",
	WallCheck = false,

	RoleESP = true,
	ShowMurderer = true,
	ShowSheriff = true,
	ShowInnocent = true,
	EspNames = true,
	EspDistance = true,
	EspChams = true,
	EspHealth = true,
	EspBoxes = true,
	EspTracers = true,
	EspSkeletons = false,
	MasterESP = true,
	GunESP = true,
	CoinESP = true,
	FullBright = false,
	AutoAnnounce = false,

	Crosshair = true,
	CrosshairStyle = "Cross", -- Cross | Dot | Circle | CrossDot | T
	CrosshairColor = "White",
	CrosshairSize = 12,
	CrosshairGap = 4,
	CrosshairThick = 2,

	AutoCoins = false,
	CoinRange = 30,
	CoinTP = true,
	AutoGrabGun = false,

	WalkSpeed = false,
	WalkSpeedVal = 24,
	JumpPower = false,
	JumpPowerVal = 50,
	InfJump = false,
	Noclip = false,
	Fly = false,
	FlySpeed = 55,
	Bhop = false,
	SpinBot = false,
	HipHeight = false,
	HipHeightVal = 2,
	CamFOV = false,
	CamFOVVal = 90,

	AntiFling = true,
	AntiAFK = true,
	GodMode = false,
	HitboxExpand = false,
	HitboxSize = 6,
}

local COL = {
	Murderer = Color3.fromRGB(255, 45, 45),
	Sheriff = Color3.fromRGB(55, 140, 255),
	Innocent = Color3.fromRGB(70, 220, 100),
	Hero = Color3.fromRGB(255, 200, 50),
	Coin = Color3.fromRGB(255, 215, 40),
	Gun = Color3.fromRGB(255, 170, 40),
	White = Color3.fromRGB(255, 255, 255),
	Red = Color3.fromRGB(255, 60, 60),
	Green = Color3.fromRGB(60, 255, 100),
	Cyan = Color3.fromRGB(60, 220, 255),
	Purple = Color3.fromRGB(180, 80, 255),
}

local function rpath(...)
	local n = ReplicatedStorage
	for _, name in ipairs({ ... }) do
		n = n and n:FindFirstChild(name)
	end
	return n
end

local Remotes = {
	GunBeam = rpath("WeaponEvents", "GunBeam"),
	GunFired = rpath("ClientServices", "WeaponService", "GunFired"),
	GetCoin = rpath("Remotes", "Gameplay", "GetCoin"),
	EliminatePlayer = rpath("Remotes", "Gameplay", "EliminatePlayer"),
	KillEvent = rpath("Remotes", "Gameplay", "KillEvent"),
	CoinCollected = rpath("Remotes", "Gameplay", "CoinCollected"),
}

local function fire(remote, ...)
	if not remote then return end
	local args = { ... }
	pcall(function()
		if remote:IsA("RemoteFunction") then
			remote:InvokeServer(table.unpack(args))
		else
			remote:FireServer(table.unpack(args))
		end
	end)
end

local function char()
	return LP.Character
end
local function hum()
	local c = char()
	return c and c:FindFirstChildOfClass("Humanoid")
end
local function hrp()
	local c = char()
	return c and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart)
end

local function isAlivePlr(plr)
	local c = plr.Character
	if not c then return false end
	local h = c:FindFirstChildOfClass("Humanoid")
	local r = c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart
	return h and r and h.Health > 0
end

local function hasTool(plr, keywords)
	local c = plr.Character
	local pack = plr:FindFirstChild("Backpack")
	local function scan(parent)
		if not parent then return false end
		for _, t in ipairs(parent:GetChildren()) do
			if t:IsA("Tool") then
				local n = string.lower(t.Name)
				for _, k in ipairs(keywords) do
					if n:find(k) then return true, t end
				end
			end
		end
		return false
	end
	local a, b = scan(c)
	if a then return a, b end
	return scan(pack)
end

local function getRole(plr)
	if hasTool(plr, { "knife", "sword", "blade", "murder" }) then return "Murderer" end
	if hasTool(plr, { "gun", "revolver", "pistol", "sheriff" }) then return "Sheriff" end
	return "Innocent"
end

local function getByRole(role)
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP and isAlivePlr(p) and getRole(p) == role then
			return p
		end
	end
	return nil
end

local function aimPartOf(plr)
	local c = plr.Character
	if not c then return nil end
	if F.AimPart == "Head" then
		return c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart")
	elseif F.AimPart == "Torso" then
		return c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso") or c:FindFirstChild("HumanoidRootPart")
	end
	return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Head")
end

local function predictedPos(part, plr)
	if not F.Prediction or not part then return part.Position end
	local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
	local vel = root and root.AssemblyLinearVelocity or Vector3.zero
	return part.Position + vel * F.PredMult
end

local function worldToScreen(pos)
	local v, on = Camera:WorldToViewportPoint(pos)
	return Vector2.new(v.X, v.Y), on and v.Z > 0, v.Z
end

local function wallCheck(from, to)
	if not F.WallCheck then return true end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { char(), to.Parent }
	local dir = to.Position - from
	local result = Workspace:Raycast(from, dir, params)
	return result == nil or result.Instance:IsDescendantOf(to.Parent)
end

local function getCombatTarget()
	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	local best, bestD, bestPlr
	local origin = Camera.CFrame.Position

	local function consider(plr)
		if not isAlivePlr(plr) then return end
		local part = aimPartOf(plr)
		if not part then return end
		if not wallCheck(origin, part) then return end
		local pos = predictedPos(part, plr)
		local sp, on = worldToScreen(pos)
		if not on then return end
		local d = (sp - center).Magnitude
		if d > F.FOV then return end
		if not bestD or d < bestD then
			bestD = d
			best = part
			bestPlr = plr
		end
	end

	if F.AimTarget == "Murderer" then
		local m = getByRole("Murderer")
		if m then consider(m) end
	elseif F.AimTarget == "Sheriff" then
		local s = getByRole("Sheriff")
		if s then consider(s) end
	else
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LP then consider(p) end
		end
	end
	return best, bestPlr
end

-- ===================== SILENT AIM (hardened) =====================
local currentTargetPart, currentTargetPlr

local function applySilentArgs(args)
	if not currentTargetPart or not currentTargetPlr then return args end
	local pos = predictedPos(currentTargetPart, currentTargetPlr)
	for i, a in ipairs(args) do
		if typeof(a) == "Vector3" then
			args[i] = pos
		elseif typeof(a) == "CFrame" then
			args[i] = CFrame.new(a.Position, pos)
		elseif typeof(a) == "Instance" and a:IsA("BasePart") then
			-- leave hit part or redirect conceptually via position args
		end
	end
	-- common MM2 pattern: also force last arg / insert
	if #args == 0 then
		args[1] = pos
	elseif #args == 1 and typeof(args[1]) ~= "Vector3" then
		table.insert(args, pos)
	end
	return args
end

local function hookSilent()
	if typeof(hookmetamethod) == "function" then
		local old
		old = hookmetamethod(game, "__namecall", function(self, ...)
			local method = getnamecallmethod()
			if F.SilentAim and alive() and (method == "FireServer" or method == "InvokeServer") then
				if self == Remotes.GunBeam or self == Remotes.GunFired
					or (typeof(self) == "Instance" and self.Name and (self.Name == "GunBeam" or self.Name == "GunFired")) then
					local args = applySilentArgs({ ... })
					return old(self, table.unpack(args))
				end
			end
			return old(self, ...)
		end)
	elseif typeof(hookfunction) == "function" then
		local function wrap(remote)
			if not remote or remote:GetAttribute("CSW3") then return end
			remote:SetAttribute("CSW3", true)
			local old = remote.FireServer
			hookfunction(old, function(self, ...)
				if self ~= remote or not F.SilentAim then return old(self, ...) end
				local args = applySilentArgs({ ... })
				return old(self, table.unpack(args))
			end)
		end
		wrap(Remotes.GunBeam)
		wrap(Remotes.GunFired)
	end
end
pcall(hookSilent)

local function fireKnife(eventName, targetPlr)
	local c = char()
	local pack = LP:FindFirstChild("Backpack")
	local function scan(parent)
		if not parent then return end
		for _, t in ipairs(parent:GetChildren()) do
			if t:IsA("Tool") and string.lower(t.Name):find("knife") then
				local ev = t:FindFirstChild("Events")
				local remote = ev and ev:FindFirstChild(eventName)
				if remote then
					fire(remote, targetPlr)
					fire(remote, targetPlr and targetPlr.Character)
					fire(remote)
				end
			end
		end
	end
	scan(c)
	scan(pack)
end

-- ===================== COINS (hardened) =====================
local function isCoin(obj)
	local n = string.lower(obj.Name)
	return n == "coin" or n:find("coin") or n:find("candy")
end

local function collectCoins()
	local me = hrp()
	if not me then return end
	local coins = {}
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and isCoin(obj) then
			local d = (obj.Position - me.Position).Magnitude
			if d <= F.CoinRange then
				table.insert(coins, { part = obj, dist = d })
			end
		end
	end
	table.sort(coins, function(a, b) return a.dist < b.dist end)
	for _, entry in ipairs(coins) do
		local obj = entry.part
		if F.CoinTP then
			pcall(function()
				obj.CFrame = me.CFrame
				obj.CanCollide = false
			end)
		end
		fire(Remotes.GetCoin, obj)
		fire(Remotes.GetCoin, obj.Name)
		fire(Remotes.GetCoin)
		fire(Remotes.CoinCollected, obj)
		fire(Remotes.CoinCollected)
		local cd = obj:FindFirstChildOfClass("ClickDetector")
		if cd and fireclickdetector then pcall(fireclickdetector, cd) end
		local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt")
		if prompt and fireproximityprompt then pcall(fireproximityprompt, prompt) end
	end
end

local function findGunDrop()
	for _, obj in ipairs(Workspace:GetDescendants()) do
		local n = string.lower(obj.Name)
		if (n:find("gun") or n:find("revolver")) and not obj:IsDescendantOf(LP) then
			local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
			if part then return obj, part end
		end
	end
end

local function grabGun()
	local gun, part = findGunDrop()
	if not part then return end
	local me = hrp()
	if me then me.CFrame = part.CFrame + Vector3.new(0, 3, 0) end
	task.wait(0.08)
	local prompt = gun:FindFirstChildWhichIsA("ProximityPrompt", true)
	if prompt and fireproximityprompt then pcall(fireproximityprompt, prompt) end
end

-- ===================== UI LAYERS (ESP + Crosshair + FOV) =====================
local guiParent = CoreGui
pcall(function()
	local g = Instance.new("ScreenGui")
	g.Name = "CSW_MM2_V3"
	g.ResetOnSpawn = false
	g.IgnoreGuiInset = true
	g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	g.Parent = CoreGui
	guiParent = g
end)
if guiParent == CoreGui then
	local g = Instance.new("ScreenGui")
	g.Name = "CSW_MM2_V3"
	g.ResetOnSpawn = false
	g.IgnoreGuiInset = true
	g.Parent = LP:WaitForChild("PlayerGui")
	guiParent = g
end

-- Crosshair
local crossFolder = Instance.new("Folder")
crossFolder.Name = "Crosshair"
crossFolder.Parent = guiParent
local crossParts = {}

local function clearCross()
	for _, f in ipairs(crossParts) do
		pcall(function() f:Destroy() end)
	end
	table.clear(crossParts)
end

local function makeSeg(size, pos)
	local f = Instance.new("Frame")
	f.BorderSizePixel = 0
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.Size = size
	f.Position = pos
	f.Parent = crossFolder
	table.insert(crossParts, f)
	return f
end

local function rebuildCrosshair()
	clearCross()
	if not F.Crosshair then return end
	local col = COL[F.CrosshairColor] or COL.White
	local s = F.CrosshairSize
	local g = F.CrosshairGap
	local t = F.CrosshairThick
	local style = F.CrosshairStyle
	local cx, cy = 0.5, 0.5

	local function paint(f)
		f.BackgroundColor3 = col
	end

	if style == "Dot" or style == "CrossDot" then
		local d = makeSeg(UDim2.new(0, t + 2, 0, t + 2), UDim2.new(cx, 0, cy, 0))
		paint(d)
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(1, 0)
		c.Parent = d
	end
	if style == "Circle" then
		local d = makeSeg(UDim2.new(0, s * 2, 0, s * 2), UDim2.new(cx, 0, cy, 0))
		d.BackgroundTransparency = 1
		local st = Instance.new("UIStroke")
		st.Color = col
		st.Thickness = t
		st.Parent = d
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(1, 0)
		c.Parent = d
	end
	if style == "Cross" or style == "CrossDot" or style == "T" then
		-- horizontal
		paint(makeSeg(UDim2.new(0, s, 0, t), UDim2.new(cx, -(g + s / 2), cy, 0)))
		paint(makeSeg(UDim2.new(0, s, 0, t), UDim2.new(cx, (g + s / 2), cy, 0)))
		-- vertical top
		paint(makeSeg(UDim2.new(0, t, 0, s), UDim2.new(cx, 0, cy, -(g + s / 2))))
		if style ~= "T" then
			paint(makeSeg(UDim2.new(0, t, 0, s), UDim2.new(cx, 0, cy, (g + s / 2))))
		end
	end
end

-- FOV circle
local fovCircle = Instance.new("Frame")
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.BackgroundTransparency = 1
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.Parent = guiParent
local fovStroke = Instance.new("UIStroke")
fovStroke.Color = Color3.fromRGB(255, 255, 255)
fovStroke.Thickness = 1.2
fovStroke.Transparency = 0.35
fovStroke.Parent = fovCircle
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)

-- ESP folder in workspace for highlights / 3d
local espFolder = Instance.new("Folder")
espFolder.Name = "CSW_ESP_World"
espFolder.Parent = Workspace

local overlay = Instance.new("Folder")
overlay.Name = "ESP_Overlay"
overlay.Parent = guiParent

local plrEsp = {}

local function clearPlr(plr)
	local t = plrEsp[plr]
	if not t then return end
	for _, x in pairs(t) do
		if typeof(x) == "Instance" then pcall(function() x:Destroy() end) end
	end
	plrEsp[plr] = nil
end

local function ensurePlr(plr)
	if plrEsp[plr] and plrEsp[plr].bb and plrEsp[plr].bb.Parent then
		return plrEsp[plr]
	end
	clearPlr(plr)
	local bb = Instance.new("BillboardGui")
	bb.AlwaysOnTop = true
	bb.Size = UDim2.new(0, 150, 0, 52)
	bb.StudsOffset = Vector3.new(0, 3.5, 0)
	bb.Parent = espFolder
	local nameL = Instance.new("TextLabel")
	nameL.BackgroundTransparency = 1
	nameL.Size = UDim2.new(1, 0, 0, 16)
	nameL.Font = Enum.Font.GothamBold
	nameL.TextSize = 13
	nameL.TextStrokeTransparency = 0.25
	nameL.Parent = bb
	local roleL = Instance.new("TextLabel")
	roleL.BackgroundTransparency = 1
	roleL.Size = UDim2.new(1, 0, 0, 14)
	roleL.Position = UDim2.new(0, 0, 0, 16)
	roleL.Font = Enum.Font.Gotham
	roleL.TextSize = 11
	roleL.TextStrokeTransparency = 0.35
	roleL.Parent = bb
	local hpL = Instance.new("TextLabel")
	hpL.BackgroundTransparency = 1
	hpL.Size = UDim2.new(1, 0, 0, 12)
	hpL.Position = UDim2.new(0, 0, 0, 30)
	hpL.Font = Enum.Font.Gotham
	hpL.TextSize = 11
	hpL.TextStrokeTransparency = 0.5
	hpL.TextColor3 = Color3.fromRGB(200, 200, 200)
	hpL.Parent = bb
	local hl = Instance.new("Highlight")
	hl.FillTransparency = 0.55
	hl.OutlineTransparency = 0.12
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Enabled = false
	hl.Parent = espFolder
	-- 2D box
	local box = Instance.new("Frame")
	box.BackgroundTransparency = 1
	box.Visible = false
	box.Parent = overlay
	local boxStroke = Instance.new("UIStroke")
	boxStroke.Thickness = 1.5
	boxStroke.Parent = box
	-- tracer line
	local tracer = Instance.new("Frame")
	tracer.AnchorPoint = Vector2.new(0.5, 0)
	tracer.BorderSizePixel = 0
	tracer.Visible = false
	tracer.Parent = overlay
	plrEsp[plr] = {
		bb = bb, name = nameL, role = roleL, hp = hpL, hl = hl,
		box = box, boxStroke = boxStroke, tracer = tracer,
		bones = {},
	}
	return plrEsp[plr]
end

Players.PlayerRemoving:Connect(clearPlr)

local function updateSkeleton(t, c, col)
	-- simple bone lines via Billboard thin frames is heavy; use Highlight only for skeleton toggle
	-- skeleton: attach small parts links via Beam between R15 joints
	if not F.EspSkeletons then
		for _, b in pairs(t.bones) do pcall(function() b:Destroy() end) end
		table.clear(t.bones)
		return
	end
	local links = {
		{ "Head", "UpperTorso" }, { "UpperTorso", "LowerTorso" },
		{ "UpperTorso", "LeftUpperArm" }, { "LeftUpperArm", "LeftLowerArm" }, { "LeftLowerArm", "LeftHand" },
		{ "UpperTorso", "RightUpperArm" }, { "RightUpperArm", "RightLowerArm" }, { "RightLowerArm", "RightHand" },
		{ "LowerTorso", "LeftUpperLeg" }, { "LeftUpperLeg", "LeftLowerLeg" }, { "LeftLowerLeg", "LeftFoot" },
		{ "LowerTorso", "RightUpperLeg" }, { "RightUpperLeg", "RightLowerLeg" }, { "RightLowerLeg", "RightFoot" },
		-- R6 fallbacks
		{ "Head", "Torso" }, { "Torso", "Left Arm" }, { "Torso", "Right Arm" }, { "Torso", "Left Leg" }, { "Torso", "Right Leg" },
	}
	for _, link in ipairs(links) do
		local a, b = c:FindFirstChild(link[1]), c:FindFirstChild(link[2])
		if a and b and a:IsA("BasePart") and b:IsA("BasePart") then
			local key = link[1] .. "_" .. link[2]
			if not t.bones[key] then
				local att0 = Instance.new("Attachment")
				att0.Parent = a
				local att1 = Instance.new("Attachment")
				att1.Parent = b
				local beam = Instance.new("Beam")
				beam.Attachment0 = att0
				beam.Attachment1 = att1
				beam.Width0 = 0.08
				beam.Width1 = 0.08
				beam.FaceCamera = true
				beam.Parent = espFolder
				t.bones[key] = { beam = beam, a0 = att0, a1 = att1 }
			end
			local bone = t.bones[key]
			bone.beam.Color = ColorSequence.new(col)
			bone.beam.Enabled = true
		end
	end
end

-- ===================== ROLES ANNOUNCE =====================
local function nameOf(plr)
	if not plr then return "none" end
	return plr.DisplayName or plr.Name
end

local function announceRoles()
	local murderer = getByRole("Murderer")
	local sheriff = getByRole("Sheriff")
	local hero = nil
	local gunHolders = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP and isAlivePlr(p) and getRole(p) == "Sheriff" then
			table.insert(gunHolders, p)
		end
	end
	if #gunHolders >= 1 then
		sheriff = gunHolders[1]
		hero = gunHolders[2] -- second gun = hero-style
	end
	local msg = string.format("ROLES | Murderer: %s | Sheriff: %s | Hero: %s", nameOf(murderer), nameOf(sheriff), nameOf(hero))
	pcall(function()
		local tcs = game:GetService("TextChatService")
		local channels = tcs:FindFirstChild("TextChannels")
		local ch = channels and (channels:FindFirstChild("RBXGeneral") or channels:FindFirstChildWhichIsA("TextChannel"))
		if ch then ch:SendAsync(msg) end
	end)
	pcall(function()
		if typeof(LP.Chat) == "function" then LP:Chat(msg) end
	end)
	OrionLib:MakeNotification({ Name = "Roles", Content = msg, Time = 4 })
end

-- ===================== MOVEMENT =====================
local flyBV, flyBG
local function stopFly()
	if flyBV then flyBV:Destroy() flyBV = nil end
	if flyBG then flyBG:Destroy() flyBG = nil end
end
local function startFly()
	stopFly()
	local root = hrp()
	if not root then return end
	flyBV = Instance.new("BodyVelocity")
	flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	flyBV.Velocity = Vector3.zero
	flyBV.Parent = root
	flyBG = Instance.new("BodyGyro")
	flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
	flyBG.P = 1e4
	flyBG.Parent = root
end

local noclipConn
local function setNoclip(on)
	if noclipConn then noclipConn:Disconnect() noclipConn = nil end
	if not on then return end
	noclipConn = RunService.Stepped:Connect(function()
		if not F.Noclip or not alive() then return end
		local c = char()
		if not c then return end
		for _, p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide = false end
		end
	end)
end

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.Space and F.InfJump then
		local h = hum()
		if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)

local function applyFB(on)
	if on then
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.FogEnd = 1e6
		Lighting.GlobalShadows = false
		Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
	end
end

rebuildCrosshair()

-- ===================== LOOPS =====================
local tickN = 0
RunService.RenderStepped:Connect(function()
	if not alive() then return end

	fovCircle.Visible = F.ShowFOV and (F.Aimbot or F.SilentAim or F.Triggerbot)
	local size = F.FOV * 2
	fovCircle.Size = UDim2.new(0, size, 0, size)

	currentTargetPart, currentTargetPlr = getCombatTarget()

	if F.Aimbot and currentTargetPart and currentTargetPlr then
		local pos = predictedPos(currentTargetPart, currentTargetPlr)
		local cam = Camera.CFrame
		Camera.CFrame = cam:Lerp(CFrame.new(cam.Position, pos), F.AimSmooth)
	end

	if (F.Triggerbot or F.AutoShoot) and currentTargetPart and currentTargetPlr then
		pcall(function()
			if mouse1click then mouse1click() end
		end)
		local pos = predictedPos(currentTargetPart, currentTargetPlr)
		fire(Remotes.GunBeam, pos)
		fire(Remotes.GunBeam, currentTargetPlr)
		fire(Remotes.GunFired, pos)
		fire(Remotes.EliminatePlayer, currentTargetPlr)
		fire(Remotes.EliminatePlayer, currentTargetPlr.UserId)
	end

	-- 2D boxes + tracers
	local bottom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
	for plr, t in pairs(plrEsp) do
		if not isAlivePlr(plr) then
			t.box.Visible = false
			t.tracer.Visible = false
			continue
		end
		local c = plr.Character
		local root = c:FindFirstChild("HumanoidRootPart")
		local head = c:FindFirstChild("Head")
		if not root then
			t.box.Visible = false
			t.tracer.Visible = false
			continue
		end
		local topPos = (head and head.Position or root.Position) + Vector3.new(0, 1.2, 0)
		local botPos = root.Position - Vector3.new(0, 3, 0)
		local spTop, onTop = worldToScreen(topPos)
		local spBot, onBot = worldToScreen(botPos)
		local role = getRole(plr)
		local col = COL[role] or COL.Innocent

		if F.MasterESP and F.EspBoxes and onTop and onBot then
			local h = math.abs(spBot.Y - spTop.Y)
			local w = h * 0.55
			t.box.Visible = true
			t.box.Position = UDim2.new(0, spTop.X - w / 2, 0, spTop.Y)
			t.box.Size = UDim2.new(0, w, 0, h)
			t.boxStroke.Color = col
		else
			t.box.Visible = false
		end

		if F.MasterESP and F.EspTracers and onBot then
			local mid = Vector2.new((spTop.X + spBot.X) / 2, spBot.Y)
			local dist = (mid - bottom).Magnitude
			local angle = math.atan2(mid.Y - bottom.Y, mid.X - bottom.X)
			t.tracer.Visible = true
			t.tracer.BackgroundColor3 = col
			t.tracer.Size = UDim2.new(0, dist, 0, 1.4)
			t.tracer.Position = UDim2.new(0, bottom.X, 0, bottom.Y)
			t.tracer.Rotation = math.deg(angle)
			t.tracer.AnchorPoint = Vector2.new(0, 0.5)
		else
			t.tracer.Visible = false
		end
	end
end)

RunService.Heartbeat:Connect(function()
	if not alive() then return end
	tickN += 1

	if tickN % 4 == 0 then
		if F.AutoCoins then pcall(collectCoins) end
		if F.AutoGrabGun then pcall(grabGun) end
	end

	if F.KillAura or F.AutoKnife then
		local me = hrp()
		if me then
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr == LP or not isAlivePlr(plr) then continue end
				local rh = plr.Character:FindFirstChild("HumanoidRootPart")
				if rh and (rh.Position - me.Position).Magnitude <= F.KillAuraRange then
					fireKnife("KnifeStabbed", plr)
					fireKnife("HandleTouched", plr)
					fireKnife("KnifeThrown", plr)
					fire(Remotes.EliminatePlayer, plr)
					fire(Remotes.KillEvent, plr)
				end
			end
		end
	end

	-- hitbox expand
	if F.HitboxExpand and tickN % 10 == 0 then
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr == LP or not isAlivePlr(plr) then continue end
			local r = plr.Character:FindFirstChild("HumanoidRootPart")
			if r then
				r.Size = Vector3.new(F.HitboxSize, F.HitboxSize, F.HitboxSize)
				r.Transparency = 0.7
				r.CanCollide = false
			end
		end
	end

	local h = hum()
	local root = hrp()
	if h then
		if F.WalkSpeed then h.WalkSpeed = F.WalkSpeedVal end
		if F.JumpPower then h.JumpPower = F.JumpPowerVal end
		if F.HipHeight then h.HipHeight = F.HipHeightVal end
		if F.GodMode then h.Health = h.MaxHealth end
		if F.Bhop and h.FloorMaterial ~= Enum.Material.Air then
			h:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
	if F.CamFOV then Camera.FieldOfView = F.CamFOVVal end
	if F.SpinBot and root then
		root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(28), 0)
	end
	if F.AntiFling and root then
		if root.AssemblyLinearVelocity.Magnitude > 150 then
			root.AssemblyLinearVelocity = Vector3.zero
		end
		if root.AssemblyAngularVelocity.Magnitude > 50 then
			root.AssemblyAngularVelocity = Vector3.zero
		end
	end

	if F.Fly then
		if root then
			if not flyBV then startFly() end
			local cam = Camera.CFrame
			local move = Vector3.zero
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.yAxis end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.yAxis end
			if move.Magnitude > 0 then move = move.Unit * F.FlySpeed end
			flyBV.Velocity = move
			flyBG.CFrame = cam
		end
	else
		stopFly()
	end

	applyFB(F.FullBright)

	-- Role ESP 3D
	if F.RoleESP and F.MasterESP then
		local me = hrp()
		local seen = {}
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr == LP then continue end
			if not isAlivePlr(plr) then clearPlr(plr) continue end
			local role = getRole(plr)
			if role == "Murderer" and not F.ShowMurderer then clearPlr(plr) continue end
			if role == "Sheriff" and not F.ShowSheriff then clearPlr(plr) continue end
			if role == "Innocent" and not F.ShowInnocent then clearPlr(plr) continue end
			local c = plr.Character
			local rh = c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart
			local hd = c:FindFirstChild("Head")
			local hu = c:FindFirstChildOfClass("Humanoid")
			if not rh then clearPlr(plr) continue end
			seen[plr] = true
			local col = COL[role] or COL.Innocent
			local t = ensurePlr(plr)
			t.bb.Adornee = hd or rh
			t.name.Visible = F.EspNames
			t.name.Text = plr.DisplayName or plr.Name
			t.name.TextColor3 = col
			local extra = role
			if F.EspDistance and me then
				extra = extra .. " · " .. math.floor((rh.Position - me.Position).Magnitude) .. "m"
			end
			t.role.Text = extra
			t.role.TextColor3 = col
			if F.EspHealth and hu then
				t.hp.Text = math.floor(hu.Health) .. "/" .. math.floor(hu.MaxHealth)
				t.hp.Visible = true
			else
				t.hp.Visible = false
			end
			if F.EspChams then
				t.hl.Adornee = c
				t.hl.FillColor = col
				t.hl.OutlineColor = Color3.new(1, 1, 1)
				t.hl.Enabled = true
			else
				t.hl.Enabled = false
			end
			pcall(updateSkeleton, t, c, col)
		end
		for p in pairs(plrEsp) do
			if not seen[p] then clearPlr(p) end
		end
	else
		for p in pairs(plrEsp) do clearPlr(p) end
	end
end)

task.spawn(function()
	local lastM, lastT = nil, 0
	while alive() do
		if F.AutoAnnounce then
			local m = getByRole("Murderer")
			if m and (m ~= lastM or os.clock() - lastT > 20) then
				lastM, lastT = m, os.clock()
				pcall(announceRoles)
			end
		end
		task.wait(2)
	end
end)

task.spawn(function()
	while alive() do
		if F.AntiAFK then
			pcall(function()
				local vu = game:GetService("VirtualUser")
				vu:CaptureController()
				vu:ClickButton2(Vector2.new())
			end)
		end
		task.wait(50)
	end
end)

-- ===================== UI =====================
local Window = OrionLib:MakeWindow({
	Name = "Constipated Hub | MM2 v3",
	HidePremium = true,
	SaveConfig = false,
	IntroEnabled = false,
})

local TabCombat = Window:MakeTab({ Name = "Combat", Icon = "rbxassetid://4483345998", PremiumOnly = false })
local TabESP = Window:MakeTab({ Name = "ESP", Icon = "rbxassetid://4483345998", PremiumOnly = false })
local TabCross = Window:MakeTab({ Name = "Crosshair", Icon = "rbxassetid://4483345998", PremiumOnly = false })
local TabMove = Window:MakeTab({ Name = "Movement", Icon = "rbxassetid://4483345998", PremiumOnly = false })
local TabFarm = Window:MakeTab({ Name = "Farm", Icon = "rbxassetid://4483345998", PremiumOnly = false })
local TabServer = Window:MakeTab({ Name = "Server", Icon = "rbxassetid://4483345998", PremiumOnly = false })
local TabMisc = Window:MakeTab({ Name = "Misc", Icon = "rbxassetid://4483345998", PremiumOnly = false })

TabCombat:AddToggle({ Name = "Silent Aim", Default = false, Callback = function(v) F.SilentAim = v end })
TabCombat:AddToggle({ Name = "Aimbot", Default = false, Callback = function(v) F.Aimbot = v end })
TabCombat:AddToggle({ Name = "Prediction", Default = true, Callback = function(v) F.Prediction = v end })
TabCombat:AddSlider({ Name = "Prediction Mult", Min = 0.02, Max = 0.35, Default = 0.12, Increment = 0.01, Callback = function(v) F.PredMult = v end })
TabCombat:AddToggle({ Name = "Wall Check", Default = false, Callback = function(v) F.WallCheck = v end })
TabCombat:AddDropdown({ Name = "Aim Part", Default = "Head", Options = { "Head", "Torso", "Body" }, Callback = function(v) F.AimPart = v end })
TabCombat:AddDropdown({ Name = "Aim Target", Default = "Murderer", Options = { "Murderer", "Sheriff", "Nearest" }, Callback = function(v) F.AimTarget = v end })
TabCombat:AddSlider({ Name = "FOV", Min = 40, Max = 450, Default = 180, Increment = 10, Callback = function(v) F.FOV = v end })
TabCombat:AddToggle({ Name = "Show FOV", Default = true, Callback = function(v) F.ShowFOV = v end })
TabCombat:AddSlider({ Name = "Smooth", Min = 0.05, Max = 1, Default = 0.18, Increment = 0.05, Callback = function(v) F.AimSmooth = v end })
TabCombat:AddToggle({ Name = "Auto Shoot", Default = false, Callback = function(v) F.AutoShoot = v end })
TabCombat:AddToggle({ Name = "Triggerbot", Default = false, Callback = function(v) F.Triggerbot = v end })
TabCombat:AddToggle({ Name = "Kill Aura / Auto Knife", Default = false, Callback = function(v) F.KillAura = v F.AutoKnife = v end })
TabCombat:AddSlider({ Name = "Aura Range", Min = 5, Max = 30, Default = 14, Increment = 1, Callback = function(v) F.KillAuraRange = v end })
TabCombat:AddToggle({ Name = "Hitbox Expand", Default = false, Callback = function(v) F.HitboxExpand = v end })
TabCombat:AddSlider({ Name = "Hitbox Size", Min = 2, Max = 15, Default = 6, Increment = 1, Callback = function(v) F.HitboxSize = v end })
TabCombat:AddButton({ Name = "TP Murderer", Callback = function()
	local m, me = getByRole("Murderer"), hrp()
	if m and me then
		local r = m.Character and m.Character:FindFirstChild("HumanoidRootPart")
		if r then me.CFrame = r.CFrame + Vector3.new(0, 3, 0) end
	end
end })
TabCombat:AddButton({ Name = "TP Sheriff", Callback = function()
	local s, me = getByRole("Sheriff"), hrp()
	if s and me then
		local r = s.Character and s.Character:FindFirstChild("HumanoidRootPart")
		if r then me.CFrame = r.CFrame + Vector3.new(0, 3, 0) end
	end
end })

TabESP:AddToggle({ Name = "Master ESP", Default = true, Callback = function(v) F.MasterESP = v end })
TabESP:AddToggle({ Name = "Role ESP", Default = true, Callback = function(v) F.RoleESP = v if not v then for p in pairs(plrEsp) do clearPlr(p) end end end })
TabESP:AddToggle({ Name = "Murderer", Default = true, Callback = function(v) F.ShowMurderer = v end })
TabESP:AddToggle({ Name = "Sheriff", Default = true, Callback = function(v) F.ShowSheriff = v end })
TabESP:AddToggle({ Name = "Innocent", Default = true, Callback = function(v) F.ShowInnocent = v end })
TabESP:AddToggle({ Name = "Names", Default = true, Callback = function(v) F.EspNames = v end })
TabESP:AddToggle({ Name = "Distance", Default = true, Callback = function(v) F.EspDistance = v end })
TabESP:AddToggle({ Name = "Health", Default = true, Callback = function(v) F.EspHealth = v end })
TabESP:AddToggle({ Name = "Chams", Default = true, Callback = function(v) F.EspChams = v end })
TabESP:AddToggle({ Name = "2D Boxes", Default = true, Callback = function(v) F.EspBoxes = v end })
TabESP:AddToggle({ Name = "Tracers", Default = true, Callback = function(v) F.EspTracers = v end })
TabESP:AddToggle({ Name = "Skeletons", Default = false, Callback = function(v) F.EspSkeletons = v end })
TabESP:AddToggle({ Name = "Gun Drop ESP", Default = true, Callback = function(v) F.GunESP = v end })
TabESP:AddToggle({ Name = "Coin ESP", Default = true, Callback = function(v) F.CoinESP = v end })
TabESP:AddToggle({ Name = "FullBright", Default = false, Callback = function(v) F.FullBright = v applyFB(v) end })
TabESP:AddButton({ Name = "Announce Roles", Callback = function() announceRoles() end })
TabESP:AddToggle({ Name = "Auto Announce", Default = false, Callback = function(v) F.AutoAnnounce = v end })

TabCross:AddToggle({ Name = "Enable Crosshair", Default = true, Callback = function(v) F.Crosshair = v rebuildCrosshair() end })
TabCross:AddDropdown({
	Name = "Style",
	Default = "Cross",
	Options = { "Cross", "Dot", "Circle", "CrossDot", "T" },
	Callback = function(v) F.CrosshairStyle = v rebuildCrosshair() end,
})
TabCross:AddDropdown({
	Name = "Color",
	Default = "White",
	Options = { "White", "Red", "Green", "Cyan", "Purple" },
	Callback = function(v) F.CrosshairColor = v rebuildCrosshair() end,
})
TabCross:AddSlider({ Name = "Size", Min = 4, Max = 30, Default = 12, Increment = 1, Callback = function(v) F.CrosshairSize = v rebuildCrosshair() end })
TabCross:AddSlider({ Name = "Gap", Min = 0, Max = 16, Default = 4, Increment = 1, Callback = function(v) F.CrosshairGap = v rebuildCrosshair() end })
TabCross:AddSlider({ Name = "Thickness", Min = 1, Max = 5, Default = 2, Increment = 1, Callback = function(v) F.CrosshairThick = v rebuildCrosshair() end })

TabMove:AddToggle({ Name = "WalkSpeed", Default = false, Callback = function(v) F.WalkSpeed = v end })
TabMove:AddSlider({ Name = "Speed", Min = 16, Max = 40, Default = 24, Increment = 1, Callback = function(v) F.WalkSpeedVal = v end })
TabMove:AddToggle({ Name = "JumpPower", Default = false, Callback = function(v) F.JumpPower = v end })
TabMove:AddSlider({ Name = "Jump", Min = 50, Max = 120, Default = 50, Increment = 5, Callback = function(v) F.JumpPowerVal = v end })
TabMove:AddToggle({ Name = "Inf Jump", Default = false, Callback = function(v) F.InfJump = v end })
TabMove:AddToggle({ Name = "Noclip", Default = false, Callback = function(v) F.Noclip = v setNoclip(v) end })
TabMove:AddToggle({ Name = "Fly", Default = false, Callback = function(v) F.Fly = v if not v then stopFly() end end })
TabMove:AddSlider({ Name = "Fly Speed", Min = 20, Max = 150, Default = 55, Increment = 5, Callback = function(v) F.FlySpeed = v end })
TabMove:AddToggle({ Name = "Bhop", Default = false, Callback = function(v) F.Bhop = v end })
TabMove:AddToggle({ Name = "SpinBot", Default = false, Callback = function(v) F.SpinBot = v end })
TabMove:AddToggle({ Name = "Hip Height", Default = false, Callback = function(v) F.HipHeight = v end })
TabMove:AddSlider({ Name = "Hip Value", Min = 0, Max = 10, Default = 2, Increment = 0.5, Callback = function(v) F.HipHeightVal = v end })
TabMove:AddToggle({ Name = "Cam FOV", Default = false, Callback = function(v) F.CamFOV = v end })
TabMove:AddSlider({ Name = "Cam FOV Val", Min = 50, Max = 120, Default = 90, Increment = 5, Callback = function(v) F.CamFOVVal = v end })

TabFarm:AddToggle({ Name = "Auto Coins", Default = false, Callback = function(v) F.AutoCoins = v end })
TabFarm:AddToggle({ Name = "Coin TP to You", Default = true, Callback = function(v) F.CoinTP = v end })
TabFarm:AddSlider({ Name = "Coin Range", Min = 5, Max = 80, Default = 30, Increment = 1, Callback = function(v) F.CoinRange = v end })
TabFarm:AddToggle({ Name = "Auto Grab Gun", Default = false, Callback = function(v) F.AutoGrabGun = v end })
TabFarm:AddButton({ Name = "Grab Gun Now", Callback = function() grabGun() end })

TabServer:AddButton({ Name = "Rejoin", Callback = function()
	TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
end })
TabServer:AddButton({ Name = "Server Hop", Callback = function()
	pcall(function()
		local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
		local data = HttpService:JSONDecode(game:HttpGet(url))
		for _, s in ipairs(data.data or {}) do
			if s.playing < s.maxPlayers and s.id ~= game.JobId then
				TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LP)
				return
			end
		end
	end)
end })

TabMisc:AddToggle({ Name = "God Mode", Default = false, Callback = function(v) F.GodMode = v end })
TabMisc:AddToggle({ Name = "Anti Fling", Default = true, Callback = function(v) F.AntiFling = v end })
TabMisc:AddToggle({ Name = "Anti AFK", Default = true, Callback = function(v) F.AntiAFK = v end })
TabMisc:AddButton({ Name = "Unload", Callback = function()
	GENV.__ConstipatedMM2 = GEN + 1
	stopFly()
	setNoclip(false)
	for p in pairs(plrEsp) do clearPlr(p) end
	pcall(function() espFolder:Destroy() end)
	pcall(function() guiParent:Destroy() end)
	OrionLib:Destroy()
end })

OrionLib:MakeNotification({ Name = "Constipated MM2 v3", Content = "Crosshair · ESP suite · Hard aim ready", Time = 4 })
OrionLib:Init()
