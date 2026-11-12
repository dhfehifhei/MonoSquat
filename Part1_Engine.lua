--!strict
--[[
	MonoSquat — Part 1: Engine / Core
	Загружается первым. Экспортирует таблицу `Core` со всеми функциями и конфигом,
	которые использует Part 2 (UI + логика) и Loader.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local LocalMouse = LocalPlayer:GetMouse()

local Core = {}

--=========================================================================
-- GUI PARENT
--=========================================================================
local function getGuiParent()
	local ok, parent = pcall(function()
		return (gethui and gethui()) or CoreGui
	end)
	return (ok and parent) or LocalPlayer:WaitForChild("PlayerGui")
end
Core.getGuiParent = getGuiParent

local guiParent = getGuiParent()
if guiParent:FindFirstChild("MonoSquat") then
	guiParent.MonoSquat:Destroy()
end
Core.guiParent = guiParent

--=========================================================================
-- TWEEN HELPER
--=========================================================================
local function tween(obj, time, style, dir, props)
	local t = TweenService:Create(
		obj,
		TweenInfo.new(time, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
		props
	)
	t:Play()
	return t
end
Core.tween = tween

--=========================================================================
-- SOUND ENGINE
--=========================================================================
local function PlayUISound(id, pitch, volume)
	task.spawn(function()
		local s = Instance.new("Sound")
		s.SoundId = "rbxassetid://" .. tostring(id)
		s.PlaybackSpeed = pitch or 1
		s.Volume = volume or 0.5
		s.Parent = SoundService
		s:Play()
		s.Ended:Connect(function() s:Destroy() end)
		task.delay(3, function() if s and s.Parent then s:Destroy() end end)
	end)
end
Core.PlayUISound = PlayUISound
PlayUISound(6895079853, 1.05, 0.65)

--=========================================================================
-- CONFIG
--=========================================================================
local Config = {
	Theme = "Dark",
	Aimbot = {
		Enabled = false, AlwaysActive = true, TeamCheck = false, VisibleOnly = false,
		DrawFOV = false, FOV = 120, FOVColor = Color3.fromRGB(255, 255, 255),
		Smooth = 0.28, Delay = 0.0, Hitbox = "Head"
	},
	SilentAim = {
		Enabled = false, AutoFire = false, AutoFireDelay = 0.12, WallShot = false,
		DrawFOV = false, FOV = 150, FOVColor = Color3.fromRGB(185, 185, 255),
		HitChance = 100, VisibleOnly = false, Prediction = 0.135,
		HitboxPriority = "Head", Resolver = false, BulletImpacts = false,
		ImpactColor = Color3.fromRGB(255, 70, 95)
	},
	TriggerBot = { Enabled = false, Delay = 0.05, MaxDistance = 260 },
	HitSound = { Enabled = true, SoundId = "rbxassetid://124823238881973" },
	ESP = {
		Enabled = false,
		Box = true,           BoxColor = Color3.fromRGB(255, 255, 255),
		Nickname = true,      NicknameColor = Color3.fromRGB(255, 255, 255),
		HealthBar = true,     HealthColor = Color3.fromRGB(90, 255, 130),
		Weapon = true,        WeaponColor = Color3.fromRGB(255, 210, 90),
		Distance = true,      DistanceColor = Color3.fromRGB(190, 255, 190),
		Snaplines = false,    SnaplineColor = Color3.fromRGB(255, 255, 255),
		LookLine = false,     LookLineColor = Color3.fromRGB(0, 240, 255),
		Ping = true,          PingColor = Color3.fromRGB(160, 220, 255),
		Device = true,        DeviceColor = Color3.fromRGB(200, 160, 255),
		Chams = false,        ChamsColor = Color3.fromRGB(165, 95, 255),
		ChamsStyle = "ForceField",
		GunDropESP = true,    GunDropColor = Color3.fromRGB(80, 255, 150),
		CoinESP = false,      CoinESPColor = Color3.fromRGB(255, 215, 65)
	},
	Visuals = {
		CameraFOVEnabled = false, CameraFOV = 90,
		Fullbright = false,   FullbrightColor = Color3.fromRGB(245, 245, 255),
		NightMode = false,
		Bloom = false,        BloomIntensity = 1.8,
		CustomSky = false,    SkyColor = Color3.fromRGB(115, 65, 255),
		Fog = false,          FogColor = Color3.fromRGB(35, 35, 50), FogEnd = 180,
		Rain = false,         RainColor = Color3.fromRGB(170, 205, 255),
		BulletTracer = false, TracerColor = Color3.fromRGB(255, 255, 255),
		LocalChams = false,   LocalChamsColor = Color3.fromRGB(140, 90, 255),
		LocalChamsStyle = "ForceField",
		ViewmodelChams = false, ViewmodelColor = Color3.fromRGB(0, 235, 255),
		ViewmodelStyle = "ForceField",
		CustomModel = "None"
	},
	Rage = {
		SelectedTarget = nil, Fling = false, FlingPower = 18000, Godmode = false,
		AntiAim = false, AntiAimYaw = "Spin", AntiAimPitch = "Down",
		AntiAimSpeed = 42, AntiAimAngle = 140,
		ColorKnife = false,       KnifeColor = Color3.fromRGB(255, 50, 80),
		CustomKnife = false,      CustomKnifeColor = Color3.fromRGB(0, 255, 200),
		Invisible = false, AutoFarm = false, AutoGrabGun = false,
		BigHitbox = false,        HitboxSize = 10,
		Fly = false,              FlySpeed = 52,
		BigJump = false,          JumpPower = 95,
		SpeedHack = false,        WalkSpeed = 34,
		PixelSurf = false, Noclip = false,
		FPVDrone = false,         DroneSpeed = 68
	}
}
Core.Config = Config

--=========================================================================
-- THEME SYSTEM
--=========================================================================
local ThemePalettes = {
	Dark = {
		MainBg = Color3.fromRGB(9, 9, 11), HeaderBg = Color3.fromRGB(13, 13, 16),
		PanelBg = Color3.fromRGB(13, 13, 16), RowBg = Color3.fromRGB(15, 15, 19),
		RowHover = Color3.fromRGB(21, 21, 27), NavBg = Color3.fromRGB(18, 18, 22),
		Accent = Color3.fromRGB(245, 245, 245), AccentText = Color3.fromRGB(10, 10, 12),
		TextPrimary = Color3.fromRGB(240, 240, 245), TextSecondary = Color3.fromRGB(140, 140, 152),
		Stroke = Color3.fromRGB(48, 48, 56), ToggleOff = Color3.fromRGB(32, 32, 38),
		KnobOff = Color3.fromRGB(150, 150, 160), ScrollBg = Color3.fromRGB(12, 12, 15)
	},
	Light = {
		MainBg = Color3.fromRGB(244, 245, 249), HeaderBg = Color3.fromRGB(232, 234, 240),
		PanelBg = Color3.fromRGB(235, 237, 243), RowBg = Color3.fromRGB(224, 227, 235),
		RowHover = Color3.fromRGB(214, 218, 228), NavBg = Color3.fromRGB(218, 221, 230),
		Accent = Color3.fromRGB(18, 18, 24), AccentText = Color3.fromRGB(248, 248, 252),
		TextPrimary = Color3.fromRGB(18, 18, 24), TextSecondary = Color3.fromRGB(95, 98, 112),
		Stroke = Color3.fromRGB(190, 194, 206), ToggleOff = Color3.fromRGB(195, 199, 210),
		KnobOff = Color3.fromRGB(105, 108, 120), ScrollBg = Color3.fromRGB(232, 234, 240)
	}
}

local ThemeListeners = {}
local function RegisterThemeUpdater(fn)
	table.insert(ThemeListeners, fn)
end
Core.RegisterThemeUpdater = RegisterThemeUpdater

local function GetTheme()
	return ThemePalettes[Config.Theme] or ThemePalettes.Dark
end
Core.GetTheme = GetTheme

local function ApplyMenuTheme()
	local th = GetTheme()
	for _, fn in ipairs(ThemeListeners) do
		pcall(fn, th)
	end
end
Core.ApplyMenuTheme = ApplyMenuTheme

--=========================================================================
-- ROLE / HITSOUND / TRACER / RESOLVER / WEAPON UTILS
--=========================================================================
local function PlayCustomHitSound()
	if not Config.HitSound.Enabled then return end
	task.spawn(function()
		local s = Instance.new("Sound")
		s.SoundId = Config.HitSound.SoundId
		s.Volume = 1.0
		s.PlaybackSpeed = 1.0
		s.Parent = SoundService
		s:Play()
		s.Ended:Connect(function() s:Destroy() end)
		task.delay(3, function() if s and s.Parent then s:Destroy() end end)
	end)
end
Core.PlayCustomHitSound = PlayCustomHitSound

local function IsKnifeTool(item)
	if not item or not item:IsA("Tool") then return false end
	local n = item.Name:lower()
	return n:find("knife") or n:find("scythe") or n:find("blade") or n:find("sword")
		or item:FindFirstChild("KnifeServer") ~= nil or item:FindFirstChild("Slash") ~= nil
end
Core.IsKnifeTool = IsKnifeTool

local function IsGunTool(item)
	if not item or not item:IsA("Tool") then return false end
	local n = item.Name:lower()
	return n:find("gun") or n:find("revolver") or n:find("pistol") or n:find("laser") or n:find("blaster")
		or item:FindFirstChild("GunServer") ~= nil or item:FindFirstChild("Shoot") ~= nil
		or item:FindFirstChild("ShootGun", true) ~= nil
end
Core.IsGunTool = IsGunTool

local function GetPlayerRoleAndWeapon(plr)
	if not plr then return "Innocent", "" end
	local role = "Innocent"
	local wepName = ""
	local function checkContainer(cont)
		if not cont then return end
		for _, item in ipairs(cont:GetChildren()) do
			if item:IsA("Tool") then
				if IsKnifeTool(item) then
					role = "Murderer"; wepName = item.Name
				elseif IsGunTool(item) and role ~= "Murderer" then
					role = "Sheriff"; wepName = item.Name
				end
			end
		end
	end
	checkContainer(plr.Character)
	checkContainer(plr:FindFirstChild("Backpack"))
	return role, wepName
end
Core.GetPlayerRoleAndWeapon = GetPlayerRoleAndWeapon

local function ShouldTarget(plr)
	if not plr or plr == LocalPlayer then return false end
	if not Config.Aimbot.TeamCheck then return true end
	local myRole = GetPlayerRoleAndWeapon(LocalPlayer)
	local theirRole = GetPlayerRoleAndWeapon(plr)
	if myRole == "Murderer" then return true
	elseif myRole == "Sheriff" or myRole == "Innocent" then return theirRole == "Murderer" end
	return true
end
Core.ShouldTarget = ShouldTarget

local ResolverCache = {}
RunService.Heartbeat:Connect(function(dt)
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local prev = ResolverCache[plr]
				if prev and dt > 0 then
					local realVel = (hrp.Position - prev.LastPos) / dt
					ResolverCache[plr].Velocity = prev.Velocity:Lerp(realVel, 0.45)
					ResolverCache[plr].LastPos = hrp.Position
				else
					ResolverCache[plr] = { LastPos = hrp.Position, Velocity = Vector3.zero }
				end
			end
		end
	end
end)

local function GetResolvedVelocity(plr, part)
	if not part then return Vector3.zero end
	if Config.SilentAim.Resolver and plr and ResolverCache[plr] then
		local v = ResolverCache[plr].Velocity
		if v.Magnitude < 250 then return v end
	end
	return part.AssemblyLinearVelocity or Vector3.zero
end
Core.GetResolvedVelocity = GetResolvedVelocity

local function CreateBulletTracer(startPos, endPos)
	if not Config.Visuals.BulletTracer then return end
	task.spawn(function()
		local dist = (endPos - startPos).Magnitude
		if dist <= 0.5 then return end
		local beamPart = Instance.new("Part")
		beamPart.Anchored = true; beamPart.CanCollide = false
		beamPart.CanQuery = false; beamPart.CanTouch = false
		beamPart.Material = Enum.Material.Neon
		beamPart.Color = Config.Visuals.TracerColor
		beamPart.Size = Vector3.new(0.11, 0.11, dist)
		beamPart.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -dist / 2)
		beamPart.Transparency = 0.1
		beamPart.Parent = Workspace
		tween(beamPart, 0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
			Transparency = 1, Size = Vector3.new(0.01, 0.01, dist)
		})
		task.delay(0.7, function() if beamPart then beamPart:Destroy() end end)
	end)
end
Core.CreateBulletTracer = CreateBulletTracer

local function CreateBulletImpact(pos)
	if not Config.SilentAim.BulletImpacts then return end
	task.spawn(function()
		local box = Instance.new("Part")
		box.Anchored = true; box.CanCollide = false
		box.CanQuery = false; box.CanTouch = false
		box.Material = Enum.Material.Neon
		box.Color = Config.SilentAim.ImpactColor
		box.Size = Vector3.new(0.65, 0.65, 0.65)
		box.CFrame = CFrame.new(pos)
		box.Transparency = 0.15
		box.Parent = Workspace
		local hl = Instance.new("Highlight", box)
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.FillColor = Config.SilentAim.ImpactColor
		hl.OutlineColor = Color3.fromRGB(255, 255, 255)
		hl.FillTransparency = 0.3
		tween(box, 1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Transparency = 1, Size = Vector3.new(1.1, 1.1, 1.1) })
		task.delay(1.25, function() if box then box:Destroy() end end)
	end)
end
Core.CreateBulletImpact = CreateBulletImpact

local function GetScreenCenter()
	local cam = Workspace.CurrentCamera
	if cam then return Vector2.new(cam.ViewportSize.X * 0.5, cam.ViewportSize.Y * 0.5) end
	return Vector2.new(400, 300)
end
Core.GetScreenCenter = GetScreenCenter

local function GetTargetPartFromChar(char, priority)
	if not char then return nil end
	if priority == "Head" then
		return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
	elseif priority == "Random" then
		local opts = {}
		for _, n in ipairs({"Head", "HumanoidRootPart", "UpperTorso", "Torso"}) do
			local p = char:FindFirstChild(n)
			if p then table.insert(opts, p) end
		end
		if #opts > 0 then return opts[math.random(1, #opts)] end
	end
	return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
end
Core.GetTargetPartFromChar = GetTargetPartFromChar

local function CheckLineOfSight(targetPart, targetChar)
	local cam = Workspace.CurrentCamera
	if not cam or not targetPart then return false end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.IgnoreWater = true
	local ignoreList = { cam }
	if LocalPlayer.Character then table.insert(ignoreList, LocalPlayer.Character) end
	params.FilterDescendantsInstances = ignoreList
	local origin = cam.CFrame.Position
	local dir = (targetPart.Position - origin)
	local res = Workspace:Raycast(origin, dir, params)
	if not res then return true end
	if targetChar and res.Instance:IsDescendantOf(targetChar) then return true end
	return false
end
Core.CheckLineOfSight = CheckLineOfSight

local function GetClosestTarget(fovRadius, visibleOnly, hitboxMode)
	local cam = Workspace.CurrentCamera
	if not cam then return nil, nil end
	local centerPos = GetScreenCenter()
	local bestPart, bestPlr, minDist = nil, nil, fovRadius
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and ShouldTarget(plr) and plr.Character then
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			local part = GetTargetPartFromChar(plr.Character, hitboxMode or "Head")
			if hum and hum.Health > 0 and part then
				local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
				if onScreen and screenPos.Z > 0 then
					local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - centerPos).Magnitude
					if dist2D <= minDist then
						local passedVis = true
						if visibleOnly then passedVis = CheckLineOfSight(part, plr.Character) end
						if passedVis then
							minDist = dist2D; bestPart = part; bestPlr = plr
						end
					end
				end
			end
		end
	end
	return bestPart, bestPlr
end
Core.GetClosestTarget = GetClosestTarget

local CurrentSilentTargetPart = nil
local CurrentSilentTargetPlr = nil
local CurrentSilentAimPoint = nil
Core.GetSilentTargetState = function()
	return CurrentSilentTargetPart, CurrentSilentTargetPlr, CurrentSilentAimPoint
end
Core.SetSilentTargetState = function(part, plr, point)
	CurrentSilentTargetPart = part
	CurrentSilentTargetPlr = plr
	CurrentSilentAimPoint = point
end

local function GetSilentAimPointForTarget(targetPart, targetPlr)
	if not targetPart then return nil end
	local vel = GetResolvedVelocity(targetPlr, targetPart)
	return targetPart.Position + (vel * Config.SilentAim.Prediction)
end
Core.GetSilentAimPointForTarget = GetSilentAimPointForTarget

local IsFiringWeapon = false
local function FireEquippedWeapon(aimPoint)
	if IsFiringWeapon then return end
	local myChar = LocalPlayer.Character
	if not myChar then return end
	local tool = myChar:FindFirstChildOfClass("Tool")
	if not tool then return end
	IsFiringWeapon = true
	task.spawn(function()
		pcall(function()
			local myHrp = myChar:FindFirstChild("HumanoidRootPart")
			local targetPos = aimPoint or (LocalMouse and LocalMouse.Hit and LocalMouse.Hit.Position) or (myHrp and (myHrp.Position + myHrp.CFrame.LookVector * 100))
			tool:Activate()
			if IsKnifeTool(tool) then
				local slash = tool:FindFirstChild("Slash", true)
				if slash and slash:IsA("RemoteEvent") then slash:FireServer() end
				return
			end
			local firedRemote = false
			for _, desc in ipairs(tool:GetDescendants()) do
				if desc:IsA("RemoteFunction") then
					local n = desc.Name:lower()
					if n:find("shoot") or n:find("fire") or n:find("gun") or n:find("beam") then
						firedRemote = true
						task.spawn(function()
							pcall(function() desc:InvokeServer(1, targetPos, "AH2") end)
						end)
					end
				elseif desc:IsA("RemoteEvent") then
					local n = desc.Name:lower()
					if n:find("shoot") or n:find("fire") or n:find("gun") or n:find("beam") then
						firedRemote = true
						task.spawn(function()
							pcall(function() desc:FireServer(targetPos) end)
							pcall(function() desc:FireServer(1, targetPos, "AH2") end)
						end)
					end
				end
			end
			if not firedRemote and mouse1click and not UserInputService:GetFocusedTextBox() then
				pcall(mouse1click)
			end
			if myHrp and targetPos then
				CreateBulletTracer(myHrp.Position, targetPos)
				CreateBulletImpact(targetPos)
			end
		end)
		task.wait(0.04)
		IsFiringWeapon = false
	end)
end
Core.FireEquippedWeapon = FireEquippedWeapon

--=========================================================================
-- VECTOR ICONS
--=========================================================================
local function CreateVectorIcon(parent, iconType, size, pos, color)
	local container = Instance.new("Frame")
	container.Size = size or UDim2.new(0, 14, 0, 14)
	container.Position = pos or UDim2.new(0, 0, 0, 0)
	container.BackgroundTransparency = 1
	container.Parent = parent
	local strokes, fills = {}, {}
	local function line(w, h, x, y, rot, corner)
		local f = Instance.new("Frame", container)
		f.Size = UDim2.new(w, 0, h, 0)
		f.Position = UDim2.new(x, 0, y, 0)
		f.AnchorPoint = Vector2.new(0.5, 0.5)
		f.Rotation = rot or 0
		f.BackgroundColor3 = color or Color3.fromRGB(255, 255, 255)
		f.BorderSizePixel = 0
		if corner then Instance.new("UICorner", f).CornerRadius = UDim.new(corner, 0) end
		table.insert(fills, f)
		return f
	end
	if iconType == "Logo" then
		local box = line(0.68, 0.68, 0.5, 0.5, 45, 0.15)
		box.BackgroundTransparency = 1
		local st = Instance.new("UIStroke", box)
		st.Color = color or Color3.fromRGB(255, 255, 255)
		st.Thickness = 1.4
		table.insert(strokes, st)
		line(0.26, 0.26, 0.5, 0.5, 45, 0.1)
	elseif iconType == "Search" then
		local c = line(0.6, 0.6, 0.42, 0.42, 0, 1)
		c.BackgroundTransparency = 1
		local st = Instance.new("UIStroke", c)
		st.Color = color or Color3.fromRGB(160, 160, 160)
		st.Thickness = 1.3
		table.insert(strokes, st)
		line(0.36, 0.12, 0.75, 0.75, 45, 1)
	elseif iconType == "Cube" then
		local c = line(0.74, 0.74, 0.5, 0.5, 0, 0.2)
		c.BackgroundTransparency = 1
		local st = Instance.new("UIStroke", c)
		st.Color = color or Color3.fromRGB(200, 200, 200)
		st.Thickness = 1.2
		table.insert(strokes, st)
		line(0.3, 0.3, 0.5, 0.5, 45, 0.1)
	elseif iconType == "SunMoon" then
		local c = line(0.56, 0.56, 0.5, 0.5, 0, 1)
		c.BackgroundTransparency = 1
		local st = Instance.new("UIStroke", c)
		st.Color = color or Color3.fromRGB(240, 240, 240)
		st.Thickness = 1.3
		table.insert(strokes, st)
		line(0.14, 0.88, 0.5, 0.5, 0, 1).ZIndex = 0
		line(0.14, 0.88, 0.5, 0.5, 90, 1).ZIndex = 0
		line(0.14, 0.88, 0.5, 0.5, 45, 1).ZIndex = 0
		line(0.14, 0.88, 0.5, 0.5, -45, 1).ZIndex = 0
	end
	RegisterThemeUpdater(function(th)
		local col = th.TextPrimary
		for _, s in ipairs(strokes) do s.Color = col end
		for _, f in ipairs(fills) do
			if f.BackgroundTransparency < 1 then f.BackgroundColor3 = col end
		end
	end)
	return container
end
Core.CreateVectorIcon = CreateVectorIcon

--=========================================================================
-- SKIN DATABASE + MESHES
--=========================================================================
local SkinsList = { Knife = {}, Gun = {}, Pet = {} }
local AddedKeys = { Knife = {}, Gun = {}, Pet = {} }
local SelectedSkins = { Knife = nil, Gun = nil, Pet = nil }
Core.SkinsList = SkinsList
Core.SelectedSkins = SelectedSkins

local FallbackSkinMeshes = {
	["Corrupt"] = { MeshId = "rbxassetid://430339169", TextureId = "rbxassetid://430339192", Scale = Vector3.new(1, 1, 1) },
	["Nik's Scythe"] = { MeshId = "rbxassetid://218497296", TextureId = "rbxassetid://218497323", Scale = Vector3.new(1.1, 1.1, 1.1) },
	["Gingerscythe"] = { MeshId = "rbxassetid://6067948477", TextureId = "rbxassetid://6067948543", Scale = Vector3.new(1, 1, 1) },
	["Batwing"] = { MeshId = "rbxassetid://2510736522", TextureId = "rbxassetid://2510736593", Scale = Vector3.new(1, 1, 1) },
	["Icewing"] = { MeshId = "rbxassetid://1920042247", TextureId = "rbxassetid://1920042292", Scale = Vector3.new(1, 1, 1) },
	["Elderwood Scythe"] = { MeshId = "rbxassetid://4201461180", TextureId = "rbxassetid://4201461266", Scale = Vector3.new(1, 1, 1) },
	["Hallowscythe"] = { MeshId = "rbxassetid://5862598290", TextureId = "rbxassetid://5862598395", Scale = Vector3.new(1, 1, 1) },
	["Candy"] = { MeshId = "rbxassetid://192483948", TextureId = "rbxassetid://192483967", Scale = Vector3.new(1, 1, 1) },
	["Heartblade"] = { MeshId = "rbxassetid://6376166702", TextureId = "rbxassetid://6376166749", Scale = Vector3.new(1, 1, 1) },
	["Harvester"] = { MeshId = "rbxassetid://7806954614", TextureId = "rbxassetid://7806954705", Scale = Vector3.new(1, 1, 1) },
	["Icepiercer"] = { MeshId = "rbxassetid://11868190665", TextureId = "rbxassetid://11868190814", Scale = Vector3.new(1, 1, 1) },
	["Gingerscope"] = { MeshId = "rbxassetid://15646799015", TextureId = "rbxassetid://15646799190", Scale = Vector3.new(1, 1, 1) },
	["Lightbringer"] = { MeshId = "rbxassetid://4721859781", TextureId = "rbxassetid://4721859843", Scale = Vector3.new(1, 1, 1) },
	["Darkbringer"] = { MeshId = "rbxassetid://4721859781", TextureId = "rbxassetid://4721862520", Scale = Vector3.new(1, 1, 1) },
	["Luger"] = { MeshId = "rbxassetid://95356275", TextureId = "rbxassetid://95356250", Scale = Vector3.new(1.1, 1.1, 1.1) },
	["Chroma Luger"] = { MeshId = "rbxassetid://95356275", TextureId = "rbxassetid://95356250", Scale = Vector3.new(1.1, 1.1, 1.1) },
	["Laser"] = { MeshId = "rbxassetid://169214068", TextureId = "rbxassetid://169214084", Scale = Vector3.new(1, 1, 1) },
	["Chroma Laser"] = { MeshId = "rbxassetid://169214068", TextureId = "rbxassetid://169214084", Scale = Vector3.new(1, 1, 1) },
	["Shark"] = { MeshId = "rbxassetid://244080800", TextureId = "rbxassetid://244080778", Scale = Vector3.new(1, 1, 1) },
	["Amerilaser"] = { MeshId = "rbxassetid://290984072", TextureId = "rbxassetid://290984094", Scale = Vector3.new(1, 1, 1) },
	["Blaster"] = { MeshId = "rbxassetid://290983952", TextureId = "rbxassetid://290983966", Scale = Vector3.new(1, 1, 1) }
}

local function AddSkinToDB(cat, id, name, itemID, chroma, instanceRef, meshId, texId)
	if not SkinsList[cat] then return end
	local key = tostring(id)
	if AddedKeys[cat][key] then return end
	AddedKeys[cat][key] = true
	local fb = FallbackSkinMeshes[tostring(name)] or FallbackSkinMeshes[key]
	table.insert(SkinsList[cat], {
		Id = key, Name = tostring(name), Category = cat, ItemID = itemID,
		Chroma = chroma or tostring(name):lower():find("chroma") ~= nil,
		InstanceRef = instanceRef,
		MeshId = meshId or (fb and fb.MeshId) or nil,
		TextureId = texId or (fb and fb.TextureId) or nil,
		Scale = (fb and fb.Scale) or Vector3.new(1, 1, 1)
	})
end

local function ParseMM2Databases()
	for _, v in pairs(ReplicatedStorage:GetDescendants()) do
		if v:IsA("ModuleScript") and (v.Name == "ItemDatabase" or v.Name == "Weapons" or v.Name == "Items" or v.Name == "Sync") then
			local ok, data = pcall(require, v)
			if ok and type(data) == "table" then
				for itemId, info in pairs(data) do
					if type(info) == "table" then
						local itemType = info.ItemType or info.Type
						local itemName = info.ItemName or info.Name or tostring(itemId)
						local cat = nil
						if itemType == "Knife" or tostring(itemType):lower():find("knife") then cat = "Knife"
						elseif itemType == "Gun" or tostring(itemType):lower():find("gun") then cat = "Gun"
						elseif itemType == "Pet" or tostring(itemType):lower():find("pet") then cat = "Pet" end
						if cat then AddSkinToDB(cat, itemId, itemName, info.ItemID or info.AssetId, info.Chroma, nil, info.MeshId, info.TextureId or info.Image) end
					end
				end
			end
		end
	end
	for _, v in pairs(ReplicatedStorage:GetDescendants()) do
		if v:IsA("Tool") or (v:IsA("Model") and v:FindFirstChild("Handle")) then
			local parentName = v.Parent and v.Parent.Name:lower() or ""
			local category = nil
			if parentName:find("knife") or parentName:find("knives") or parentName:find("blade") then category = "Knife"
			elseif parentName:find("gun") or parentName:find("pistol") or parentName:find("revolver") then category = "Gun"
			elseif parentName:find("pet") then category = "Pet" end
			if category then AddSkinToDB(category, v.Name, v.Name, nil, nil, v) end
		end
	end
	if #SkinsList.Knife == 0 then
		for _, name in ipairs({"Corrupt", "Nik's Scythe", "Gingerscythe", "Batwing", "Icewing", "Elderwood Scythe", "Hallowscythe", "Logchopper", "Candy", "Heartblade", "Chroma Fang", "Chroma Heat", "Chroma Slasher", "Nightblade", "BioBlade"}) do
			AddSkinToDB("Knife", name, name, nil, name:lower():find("chroma"))
		end
	end
	if #SkinsList.Gun == 0 then
		for _, name in ipairs({"Harvester", "Icepiercer", "Gingerscope", "Lightbringer", "Darkbringer", "Luger", "Chroma Luger", "Laser", "Chroma Laser", "Shark", "Amerilaser", "Blaster", "Sugar", "Elderwood Revolver", "Hallowgun"}) do
			AddSkinToDB("Gun", name, name, nil, name:lower():find("chroma"))
		end
	end
	if #SkinsList.Pet == 0 then
		for _, name in ipairs({ "Fire Bat", "Fire Dog", "Phoenix", "Electro", "Sammy" }) do
			AddSkinToDB("Pet", name, name, nil, name:lower():find("chroma"))
		end
	end
	table.sort(SkinsList.Knife, function(a, b) return a.Name < b.Name end)
	table.sort(SkinsList.Gun, function(a, b) return a.Name < b.Name end)
	table.sort(SkinsList.Pet, function(a, b) return a.Name < b.Name end)
end
ParseMM2Databases()

local function FindSkinAsset(skinData)
	if not skinData then return nil end
	if skinData.InstanceRef and skinData.InstanceRef.Parent then return skinData.InstanceRef end
	for _, v in pairs(ReplicatedStorage:GetDescendants()) do
		if (v.Name:lower() == skinData.Id:lower() or v.Name:lower() == skinData.Name:lower()) then
			if v:IsA("Tool") or v:IsA("Model") or v:IsA("BasePart") or v:IsA("MeshPart") then
				skinData.InstanceRef = v
				return v
			end
		end
	end
	return nil
end
Core.FindSkinAsset = FindSkinAsset

local function UpdateKnifeModifications(tool)
	local handle = tool and tool:FindFirstChild("Handle")
	if not handle then return end
	if Config.Rage.CustomKnife then
		local sm = handle:FindFirstChildOfClass("SpecialMesh")
		if sm then sm:Destroy() end
		handle.Transparency = 0
		handle.Material = Enum.Material.Neon
		handle.Size = Vector3.new(0.35, 0.9, 3.6)
		handle.Color = Config.Rage.CustomKnifeColor
		return
	end
	if Config.Rage.ColorKnife then
		local sm = handle:FindFirstChildOfClass("SpecialMesh")
		if sm then
			sm.TextureId = ""
			sm.VertexColor = Vector3.new(Config.Rage.KnifeColor.R, Config.Rage.KnifeColor.G, Config.Rage.KnifeColor.B)
		end
		handle.Material = Enum.Material.Neon
		handle.Color = Config.Rage.KnifeColor
	end
end
Core.UpdateKnifeModifications = UpdateKnifeModifications

local function ApplyWeaponSkin(tool, category)
	local handle = tool:FindFirstChild("Handle")
	if not handle then return end
	if category == "Knife" and (Config.Rage.CustomKnife or Config.Rage.ColorKnife) then
		UpdateKnifeModifications(tool)
		return
	end
	local skin = SelectedSkins[category]
	if not skin then return end
	task.spawn(function()
		local sourceAsset = FindSkinAsset(skin)
		local appliedFromAsset = false
		if sourceAsset then
			local sourceHandle = sourceAsset:IsA("BasePart") and sourceAsset or sourceAsset:FindFirstChild("Handle") or sourceAsset:FindFirstChildWhichIsA("BasePart")
			if sourceHandle then
				local targetMesh = handle:FindFirstChildOfClass("SpecialMesh")
				local sourceMesh = sourceHandle:FindFirstChildOfClass("SpecialMesh")
				if sourceMesh then
					if not targetMesh then targetMesh = Instance.new("SpecialMesh", handle) end
					targetMesh.MeshId = sourceMesh.MeshId
					targetMesh.TextureId = sourceMesh.TextureId
					targetMesh.Scale = sourceMesh.Scale
					targetMesh.Offset = sourceMesh.Offset
					appliedFromAsset = true
				elseif sourceHandle:IsA("MeshPart") and handle:IsA("MeshPart") then
					pcall(function()
						handle.TextureID = sourceHandle.TextureID
						appliedFromAsset = true
					end)
				end
				for _, child in pairs(handle:GetChildren()) do
					if child:IsA("ParticleEmitter") or child:IsA("Trail") or child:IsA("PointLight") then child:Destroy() end
				end
				for _, child in pairs(sourceHandle:GetChildren()) do
					if child:IsA("ParticleEmitter") or child:IsA("Trail") or child:IsA("PointLight") then
						child:Clone().Parent = handle
					end
				end
			end
		end
		if not appliedFromAsset and skin.MeshId then
			local targetMesh = handle:FindFirstChildOfClass("SpecialMesh") or Instance.new("SpecialMesh", handle)
			targetMesh.MeshType = Enum.MeshType.FileMesh
			targetMesh.MeshId = tostring(skin.MeshId)
			if skin.TextureId then targetMesh.TextureId = tostring(skin.TextureId) end
			targetMesh.Scale = skin.Scale or Vector3.new(1, 1, 1)
		end
		if category == "Knife" then UpdateKnifeModifications(tool) end
	end)
end
Core.ApplyWeaponSkin = ApplyWeaponSkin

local function CheckCharacterTool(tool)
	if not tool:IsA("Tool") then return end
	task.wait(0.05)
	if IsKnifeTool(tool) then ApplyWeaponSkin(tool, "Knife")
	elseif IsGunTool(tool) then ApplyWeaponSkin(tool, "Gun") end
end
Core.CheckCharacterTool = CheckCharacterTool

local function RefreshEquippedSkins()
	local char = LocalPlayer.Character
	if char then
		for _, item in ipairs(char:GetChildren()) do CheckCharacterTool(item) end
	end
	local bp = LocalPlayer:FindFirstChild("Backpack")
	if bp then
		for _, item in ipairs(bp:GetChildren()) do CheckCharacterTool(item) end
	end
end
Core.RefreshEquippedSkins = RefreshEquippedSkins

--=========================================================================
-- CHAMS
--=========================================================================
local ChamsStylesList = { "ForceField", "Solid", "Glow", "Lava", "Ghost", "Matrix", "CyberGrid", "Gold", "Chroma" }
Core.ChamsStylesList = ChamsStylesList

local SavedOriginalMaterials = {}
local ChamsHighlights = {}
Core.ChamsHighlights = ChamsHighlights

local function ApplyChamsToCharacter(char, enabled, style, color, isPreviewDummy)
	if not char then return end
	local hl = ChamsHighlights[char]
	if not enabled then
		if hl then hl.Enabled = false end
		if SavedOriginalMaterials[char] then
			for part, data in pairs(SavedOriginalMaterials[char]) do
				if part and part.Parent then
					part.Material = data.Material
					part.Color = data.Color
					part.Transparency = data.Transparency
					if part:IsA("MeshPart") and data.MeshTextureID then
						pcall(function() part.TextureID = data.MeshTextureID end)
					end
					local sm = part:FindFirstChildOfClass("SpecialMesh")
					if sm and data.SpecialMeshTex then
						sm.TextureId = data.SpecialMeshTex
						sm.VertexColor = Vector3.new(1, 1, 1)
					end
					local lavaLight = part:FindFirstChild("MonoLavaLight")
					if lavaLight then lavaLight:Destroy() end
				end
			end
			SavedOriginalMaterials[char] = nil
		end
		local shirt = char:FindFirstChildOfClass("Shirt")
		local pants = char:FindFirstChildOfClass("Pants")
		if shirt and shirt:GetAttribute("SavedTemplate") then shirt.ShirtTemplate = shirt:GetAttribute("SavedTemplate") end
		if pants and pants:GetAttribute("SavedTemplate") then pants.PantsTemplate = pants:GetAttribute("SavedTemplate") end
		return
	end
	if not SavedOriginalMaterials[char] then
		SavedOriginalMaterials[char] = {}
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" and not p:FindFirstAncestor("MM2_CustomRig") and not p:FindFirstAncestor("MM2_FPV_Drone") then
				local sm = p:FindFirstChildOfClass("SpecialMesh")
				SavedOriginalMaterials[char][p] = {
					Material = p.Material, Color = p.Color, Transparency = p.Transparency,
					MeshTextureID = p:IsA("MeshPart") and p.TextureID or nil,
					SpecialMeshTex = sm and sm.TextureId or nil
				}
			end
		end
	end
	local shirt = char:FindFirstChildOfClass("Shirt")
	local pants = char:FindFirstChildOfClass("Pants")
	if shirt and shirt.ShirtTemplate ~= "" then
		shirt:SetAttribute("SavedTemplate", shirt.ShirtTemplate)
		shirt.ShirtTemplate = ""
	end
	if pants and pants.PantsTemplate ~= "" then
		pants:SetAttribute("SavedTemplate", pants.PantsTemplate)
		pants.PantsTemplate = ""
	end
	local activeColor = color
	if style == "Chroma" then activeColor = Color3.fromHSV((tick() * 0.35) % 1, 0.85, 1)
	elseif style == "Matrix" then activeColor = Color3.fromRGB(0, 255, 110)
	elseif style == "Gold" then activeColor = Color3.fromRGB(255, 200, 45) end
	local targetMat = Enum.Material.ForceField
	local targetTrans = 0
	local fillTrans = 0.55
	local outlineTrans = 0.15
	local outlineCol = Color3.fromRGB(255, 255, 255)
	if style == "ForceField" then targetMat = Enum.Material.ForceField; targetTrans = 0.05; fillTrans = 0.65
	elseif style == "Solid" then targetMat = Enum.Material.SmoothPlastic; targetTrans = 0; fillTrans = 0.15
	elseif style == "Glow" then targetMat = Enum.Material.Neon; targetTrans = 0; fillTrans = 0.25; outlineTrans = 0
	elseif style == "Lava" then
		targetMat = Enum.Material.CrackedLava; targetTrans = 0
		local pulse = 0.5 + 0.5 * math.sin(tick() * 4.5)
		activeColor = color:Lerp(Color3.fromRGB(255, 85, 0), pulse * 0.65)
		fillTrans = 0.86; outlineCol = Color3.fromRGB(255, 140, 0); outlineTrans = 0
	elseif style == "Ghost" then targetMat = Enum.Material.Glass; targetTrans = 0.48; fillTrans = 0.6
	elseif style == "Matrix" then targetMat = Enum.Material.ForceField; targetTrans = 0.1; fillTrans = 0.5; outlineCol = Color3.fromRGB(80, 255, 140)
	elseif style == "CyberGrid" then targetMat = Enum.Material.DiamondPlate; targetTrans = 0.05; fillTrans = 0.35
	elseif style == "Gold" then targetMat = Enum.Material.Foil; targetTrans = 0; fillTrans = 0.3; outlineCol = Color3.fromRGB(255, 235, 120)
	elseif style == "Chroma" then targetMat = Enum.Material.Neon; targetTrans = 0.05; fillTrans = 0.3 end
	for part, _ in pairs(SavedOriginalMaterials[char]) do
		if part and part.Parent then
			part.Material = targetMat
			part.Color = activeColor
			if part:IsA("MeshPart") then pcall(function() part.TextureID = "" end) end
			local sm = part:FindFirstChildOfClass("SpecialMesh")
			if sm then
				sm.TextureId = ""
				sm.VertexColor = Vector3.new(activeColor.R, activeColor.G, activeColor.B)
			end
			if style == "Lava" and part.Name == "UpperTorso" and not isPreviewDummy then
				local l = part:FindFirstChild("MonoLavaLight") or Instance.new("PointLight", part)
				l.Name = "MonoLavaLight"
				l.Color = activeColor
				l.Range = 9
				l.Brightness = 1.6
			else
				local l = part:FindFirstChild("MonoLavaLight")
				if l then l:Destroy() end
			end
			local shouldHideLocal = (char == LocalPlayer.Character) and (Config.Rage.FPVDrone or Config.Visuals.CustomModel ~= "None" or Config.Rage.Invisible)
			if not shouldHideLocal then part.Transparency = targetTrans end
		end
	end
	if not isPreviewDummy then
		if not hl then
			hl = Instance.new("Highlight")
			hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			hl.Parent = CoreGui
			ChamsHighlights[char] = hl
		end
		hl.Adornee = char
		hl.Enabled = true
		hl.FillColor = activeColor
		hl.OutlineColor = outlineCol
		hl.FillTransparency = fillTrans
		hl.OutlineTransparency = outlineTrans
	end
end
Core.ApplyChamsToCharacter = ApplyChamsToCharacter

--=========================================================================
-- RETURN
--=========================================================================
Core.PlayUISound = PlayUISound
Core.LocalPlayer = LocalPlayer
Core.LocalMouse = LocalMouse
Core.guiParent = guiParent

return Core