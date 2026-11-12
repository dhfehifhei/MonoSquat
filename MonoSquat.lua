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

local function getGuiParent()
	local ok, parent = pcall(function()
		return (gethui and gethui()) or CoreGui
	end)
	return (ok and parent) or LocalPlayer:WaitForChild("PlayerGui")
end

local guiParent = getGuiParent()
if guiParent:FindFirstChild("MonoSquat") then
	guiParent.MonoSquat:Destroy()
end

local function tween(obj, time, style, dir, props)
	local t = TweenService:Create(
		obj,
		TweenInfo.new(time, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
		props
	)
	t:Play()
	return t
end

-------------------------------------------------------------------------
-- ЗВУКОВОЙ ДВИЖОК И ХИТСАУНД
-------------------------------------------------------------------------
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

PlayUISound(6895079853, 1.05, 0.65)

-------------------------------------------------------------------------
-- ГЛОБАЛЬНАЯ КОНФИГУРАЦИЯ
-------------------------------------------------------------------------
local Config = {
	Theme = "Dark",
	Aimbot = {
		Enabled = false,
		AlwaysActive = true,
		TeamCheck = false,
		VisibleOnly = false,
		DrawFOV = false,
		FOV = 120,
		FOVColor = Color3.fromRGB(255, 255, 255),
		Smooth = 0.22,
		Delay = 0.0,
		Hitbox = "Head"
	},
	SilentAim = {
		Enabled = false,
		WallShot = false,
		DrawFOV = false,
		FOV = 150,
		FOVColor = Color3.fromRGB(185, 185, 255),
		HitChance = 100,
		VisibleOnly = false,
		Prediction = 0.135,
		HitboxPriority = "Head",
		Resolver = false,
		BulletImpacts = false,
		ImpactColor = Color3.fromRGB(255, 70, 95)
	},
	TriggerBot = {
		Enabled = false,
		Delay = 0.05
	},
	HitSound = {
		Enabled = true,
		SoundId = "rbxassetid://124823238881973"
	},
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
		SelectedTarget = nil,
		Fling = false,
		FlingPower = 18000,
		Godmode = false,
		AntiAim = false,
		AntiAimYaw = "Spin",
		AntiAimPitch = "Down",
		AntiAimSpeed = 42,
		AntiAimAngle = 140,
		ColorKnife = false,       KnifeColor = Color3.fromRGB(255, 50, 80),
		CustomKnife = false,      CustomKnifeColor = Color3.fromRGB(0, 255, 200),
		Invisible = false,
		AutoFarm = false,
		AutoGrabGun = false,
		BigHitbox = false,        HitboxSize = 10,
		Fly = false,              FlySpeed = 52,
		BigJump = false,          JumpPower = 95,
		SpeedHack = false,        WalkSpeed = 34,
		PixelSurf = false,
		Noclip = false,
		FPVDrone = false,         DroneSpeed = 68
	}
}

-------------------------------------------------------------------------
-- СИСТЕМА ТЕМ (DARK / WHITE THEME)
-------------------------------------------------------------------------
local ThemePalettes = {
	Dark = {
		MainBg = Color3.fromRGB(9, 9, 11),
		HeaderBg = Color3.fromRGB(13, 13, 16),
		PanelBg = Color3.fromRGB(13, 13, 16),
		RowBg = Color3.fromRGB(15, 15, 19),
		RowHover = Color3.fromRGB(21, 21, 27),
		NavBg = Color3.fromRGB(18, 18, 22),
		Accent = Color3.fromRGB(245, 245, 245),
		AccentText = Color3.fromRGB(10, 10, 12),
		TextPrimary = Color3.fromRGB(240, 240, 245),
		TextSecondary = Color3.fromRGB(140, 140, 152),
		Stroke = Color3.fromRGB(48, 48, 56),
		ToggleOff = Color3.fromRGB(32, 32, 38),
		KnobOff = Color3.fromRGB(150, 150, 160),
		ScrollBg = Color3.fromRGB(12, 12, 15)
	},
	Light = {
		MainBg = Color3.fromRGB(244, 245, 249),
		HeaderBg = Color3.fromRGB(232, 234, 240),
		PanelBg = Color3.fromRGB(235, 237, 243),
		RowBg = Color3.fromRGB(224, 227, 235),
		RowHover = Color3.fromRGB(214, 218, 228),
		NavBg = Color3.fromRGB(218, 221, 230),
		Accent = Color3.fromRGB(18, 18, 24),
		AccentText = Color3.fromRGB(248, 248, 252),
		TextPrimary = Color3.fromRGB(18, 18, 24),
		TextSecondary = Color3.fromRGB(95, 98, 112),
		Stroke = Color3.fromRGB(190, 194, 206),
		ToggleOff = Color3.fromRGB(195, 199, 210),
		KnobOff = Color3.fromRGB(105, 108, 120),
		ScrollBg = Color3.fromRGB(232, 234, 240)
	}
}

local ThemeListeners = {}
local function RegisterThemeUpdater(fn)
	table.insert(ThemeListeners, fn)
end

local function GetTheme()
	return ThemePalettes[Config.Theme] or ThemePalettes.Dark
end

local function ApplyMenuTheme()
	local th = GetTheme()
	for _, fn in ipairs(ThemeListeners) do
		pcall(fn, th)
	end
end

-------------------------------------------------------------------------
-- УТИЛИТЫ РОЛЕЙ, ХИТСАУНДА, ТРАССЕРОВ, РЕЗОЛЬВЕРА И АИМА
-------------------------------------------------------------------------
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

local function GetPlayerRoleAndWeapon(plr)
	if not plr then return "Innocent", "" end
	local role = "Innocent"
	local wepName = ""

	local function checkContainer(cont)
		if not cont then return end
		for _, item in ipairs(cont:GetChildren()) do
			if item:IsA("Tool") then
				local n = item.Name:lower()
				if n:find("knife") or item:FindFirstChild("KnifeServer") or item:FindFirstChild("Slash") then
					role = "Murderer"
					wepName = item.Name
				elseif (n:find("gun") or n:find("revolver") or item:FindFirstChild("GunServer") or item:FindFirstChild("Shoot")) and role ~= "Murderer" then
					role = "Sheriff"
					wepName = item.Name
				end
			end
		end
	end

	checkContainer(plr.Character)
	checkContainer(plr:FindFirstChild("Backpack"))
	return role, wepName
end

local function ShouldTarget(plr)
	if not plr or plr == LocalPlayer then return false end
	if not Config.Aimbot.TeamCheck then return true end
	local myRole = GetPlayerRoleAndWeapon(LocalPlayer)
	local theirRole = GetPlayerRoleAndWeapon(plr)
	if myRole == "Murderer" then
		return true
	elseif myRole == "Sheriff" or myRole == "Innocent" then
		return theirRole == "Murderer"
	end
	return true
end

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
	if Config.SilentAim.Resolver and ResolverCache[plr] then
		local v = ResolverCache[plr].Velocity
		if v.Magnitude < 250 then
			return v
		end
	end
	return part.AssemblyLinearVelocity
end

local function CreateBulletTracer(startPos, endPos)
	if not Config.Visuals.BulletTracer then return end
	task.spawn(function()
		local dist = (endPos - startPos).Magnitude
		if dist <= 0.5 then return end
		local beamPart = Instance.new("Part")
		beamPart.Anchored = true
		beamPart.CanCollide = false
		beamPart.Material = Enum.Material.Neon
		beamPart.Color = Config.Visuals.TracerColor
		beamPart.Size = Vector3.new(0.11, 0.11, dist)
		beamPart.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -dist / 2)
		beamPart.Transparency = 0.1
		beamPart.Parent = Workspace
		tween(beamPart, 0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
			Transparency = 1,
			Size = Vector3.new(0.01, 0.01, dist)
		})
		task.delay(0.7, function()
			if beamPart then beamPart:Destroy() end
		end)
	end)
end

local function CreateBulletImpact(pos)
	if not Config.SilentAim.BulletImpacts then return end
	task.spawn(function()
		local box = Instance.new("Part")
		box.Anchored = true
		box.CanCollide = false
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
		task.delay(1.25, function()
			if box then box:Destroy() end
		end)
	end)
end

local function GetTargetPartFromChar(char, priority)
	if priority == "Head" then
		return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
	elseif priority == "Random" then
		local opts = { char:FindFirstChild("Head"), char:FindFirstChild("HumanoidRootPart"), char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") }
		return opts[math.random(1, #opts)] or char:FindFirstChild("HumanoidRootPart")
	end
	return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
end

local function GetClosestTarget(fovRadius, visibleOnly, hitboxMode)
	local cam = Workspace.CurrentCamera
	if not cam then return nil, nil end
	local mousePos = UserInputService:GetMouseLocation()
	local bestPart, bestPlr, minDist = nil, nil, fovRadius

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and ShouldTarget(plr) and plr.Character then
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			local part = GetTargetPartFromChar(plr.Character, hitboxMode or "Head")
			if hum and hum.Health > 0 and part then
				local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
				if onScreen then
					local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
					if dist2D <= minDist then
						local passedVis = true
						if visibleOnly then
							local params = RaycastParams.new()
							params.FilterType = Enum.RaycastFilterType.Exclude
							params.FilterDescendantsInstances = { LocalPlayer.Character, cam }
							local res = Workspace:Raycast(cam.CFrame.Position, (part.Position - cam.CFrame.Position), params)
							if res and res.Instance and not res.Instance:IsDescendantOf(plr.Character) then
								passedVis = false
							end
						end
						if passedVis then
							minDist = dist2D
							bestPart = part
							bestPlr = plr
						end
					end
				end
			end
		end
	end
	return bestPart, bestPlr
end

-------------------------------------------------------------------------
-- КАСТОМНЫЕ ВЕКТОРНЫЕ ИКОНКИ (SVG-СТИЛЬ)
-------------------------------------------------------------------------
local function CreateVectorIcon(parent, iconType, size, pos, color)
	local container = Instance.new("Frame")
	container.Size = size or UDim2.new(0, 14, 0, 14)
	container.Position = pos or UDim2.new(0, 0, 0, 0)
	container.BackgroundTransparency = 1
	container.Parent = parent

	local strokes = {}
	local fills = {}

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

-------------------------------------------------------------------------
-- ЧТЕНИЕ БАЗЫ СКИНОВ MM2 И ЛОГИКА ПРИМЕНЕНИЯ
-------------------------------------------------------------------------
local SkinsList = { Knife = {}, Gun = {}, Pet = {} }
local AddedKeys = { Knife = {}, Gun = {}, Pet = {} }
local SelectedSkins = { Knife = nil, Gun = nil, Pet = nil }
local ActiveCategory = "Knife"

local function AddSkinToDB(cat, id, name, itemID, chroma, instanceRef)
	if not SkinsList[cat] then return end
	local key = tostring(id)
	if AddedKeys[cat][key] then return end
	AddedKeys[cat][key] = true
	table.insert(SkinsList[cat], {
		Id = key,
		Name = tostring(name),
		ItemID = itemID,
		Chroma = chroma or tostring(name):lower():find("chroma") ~= nil,
		InstanceRef = instanceRef
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
						if itemType == "Knife" or tostring(itemType):lower():find("knife") then
							cat = "Knife"
						elseif itemType == "Gun" or tostring(itemType):lower():find("gun") then
							cat = "Gun"
						elseif itemType == "Pet" or tostring(itemType):lower():find("pet") then
							cat = "Pet"
						end
						if cat then
							AddSkinToDB(cat, itemId, itemName, info.ItemID or info.AssetId, info.Chroma)
						end
					end
				end
			end
		end
	end

	for _, v in pairs(ReplicatedStorage:GetDescendants()) do
		if v:IsA("Tool") or (v:IsA("Model") and v:FindFirstChild("Handle")) then
			local parentName = v.Parent and v.Parent.Name:lower() or ""
			local category = nil
			if parentName:find("knife") or parentName:find("knives") or parentName:find("blade") then
				category = "Knife"
			elseif parentName:find("gun") or parentName:find("pistol") or parentName:find("revolver") then
				category = "Gun"
			elseif parentName:find("pet") then
				category = "Pet"
			end
			if category then
				AddSkinToDB(category, v.Name, v.Name, nil, nil, v)
			end
		end
	end

	if #SkinsList.Knife == 0 then
		for _, name in ipairs({
			"Corrupt", "Nik's Scythe", "Gingerscythe", "Batwing", "Icewing",
			"Elderwood Scythe", "Hallowscythe", "Logchopper", "Candy", "Heartblade",
			"Chroma Fang", "Chroma Heat", "Chroma Slasher", "Nightblade", "BioBlade"
		}) do
			AddSkinToDB("Knife", name, name, nil, name:lower():find("chroma"))
		end
	end

	if #SkinsList.Gun == 0 then
		for _, name in ipairs({
			"Harvester", "Icepiercer", "Gingerscope", "Lightbringer", "Darkbringer",
			"Luger", "Chroma Luger", "Laser", "Chroma Laser", "Shark",
			"Amerilaser", "Blaster", "Sugar", "Elderwood Revolver", "Hallowgun"
		}) do
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
	if skinData.InstanceRef then return skinData.InstanceRef end
	for _, v in pairs(ReplicatedStorage:GetDescendants()) do
		if (v.Name:lower() == skinData.Id:lower() or v.Name:lower() == skinData.Name:lower()) then
			if v:IsA("Tool") or v:IsA("Model") or v:IsA("BasePart") or v:IsA("MeshPart") then
				return v
			end
		end
	end
	return nil
end

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
		if sourceAsset then
			local sourceHandle = sourceAsset:IsA("BasePart") and sourceAsset or sourceAsset:FindFirstChild("Handle") or sourceAsset:FindFirstChildWhichIsA("BasePart")
			if sourceHandle then
				local targetMesh = handle:FindFirstChildOfClass("SpecialMesh")
				local sourceMesh = sourceHandle:FindFirstChildOfClass("SpecialMesh")

				if sourceMesh then
					if not targetMesh then
						targetMesh = Instance.new("SpecialMesh", handle)
					end
					targetMesh.MeshId = sourceMesh.MeshId
					targetMesh.TextureId = sourceMesh.TextureId
					targetMesh.Scale = sourceMesh.Scale
					targetMesh.Offset = sourceMesh.Offset
				elseif sourceHandle:IsA("MeshPart") and handle:IsA("MeshPart") then
					pcall(function()
						handle.TextureID = sourceHandle.TextureID
					end)
				end

				for _, child in pairs(handle:GetChildren()) do
					if child:IsA("ParticleEmitter") or child:IsA("Trail") or child:IsA("PointLight") then
						child:Destroy()
					end
				end
				for _, child in pairs(sourceHandle:GetChildren()) do
					if child:IsA("ParticleEmitter") or child:IsA("Trail") or child:IsA("PointLight") then
						child:Clone().Parent = handle
					end
				end
			end
		end
		if category == "Knife" then
			UpdateKnifeModifications(tool)
		end
	end)
end

local function CheckCharacterTool(tool)
	if not tool:IsA("Tool") then return end
	task.wait(0.05)
	local n = tool.Name:lower()
	if n:find("knife") or tool:FindFirstChild("KnifeServer") or tool:FindFirstChild("Slash") then
		ApplyWeaponSkin(tool, "Knife")
	elseif n:find("gun") or n:find("revolver") or tool:FindFirstChild("GunServer") or tool:FindFirstChild("Shoot") then
		ApplyWeaponSkin(tool, "Gun")
	end
end

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

-------------------------------------------------------------------------
-- УТИЛИТА ЧАМСОВ ДЛЯ ИГРОКОВ, ВРАГОВ, LAVA-ФИКС И VIEWMODEL
-------------------------------------------------------------------------
local ChamsStylesList = { "ForceField", "Solid", "Glow", "Lava", "Ghost", "Matrix", "CyberGrid", "Gold", "Chroma" }
local SavedOriginalMaterials = {}
local ChamsHighlights = {}

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
					Material = p.Material,
					Color = p.Color,
					Transparency = p.Transparency,
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
	if style == "Chroma" then
		activeColor = Color3.fromHSV((tick() * 0.35) % 1, 0.85, 1)
	elseif style == "Matrix" then
		activeColor = Color3.fromRGB(0, 255, 110)
	elseif style == "Gold" then
		activeColor = Color3.fromRGB(255, 200, 45)
	end

	local targetMat = Enum.Material.ForceField
	local targetTrans = 0
	local fillTrans = 0.55
	local outlineTrans = 0.15
	local outlineCol = Color3.fromRGB(255, 255, 255)

	if style == "ForceField" then
		targetMat = Enum.Material.ForceField
		targetTrans = 0.05
		fillTrans = 0.65
	elseif style == "Solid" then
		targetMat = Enum.Material.SmoothPlastic
		targetTrans = 0
		fillTrans = 0.15
	elseif style == "Glow" then
		targetMat = Enum.Material.Neon
		targetTrans = 0
		fillTrans = 0.25
		outlineTrans = 0
	elseif style == "Lava" then
		-- ИСПРАВЛЕННЫЙ LAVA CHAMS: CrackedLava + пульсация + очистка Mesh-текстур + огненный контур без замыливания
		targetMat = Enum.Material.CrackedLava
		targetTrans = 0
		local pulse = 0.5 + 0.5 * math.sin(tick() * 4.5)
		activeColor = color:Lerp(Color3.fromRGB(255, 85, 0), pulse * 0.65)
		fillTrans = 0.86 -- оставляем видимыми трещины CrackedLava
		outlineCol = Color3.fromRGB(255, 140, 0)
		outlineTrans = 0
	elseif style == "Ghost" then
		targetMat = Enum.Material.Glass
		targetTrans = 0.48
		fillTrans = 0.6
	elseif style == "Matrix" then
		targetMat = Enum.Material.ForceField
		targetTrans = 0.1
		fillTrans = 0.5
		outlineCol = Color3.fromRGB(80, 255, 140)
	elseif style == "CyberGrid" then
		targetMat = Enum.Material.DiamondPlate
		targetTrans = 0.05
		fillTrans = 0.35
	elseif style == "Gold" then
		targetMat = Enum.Material.Foil
		targetTrans = 0
		fillTrans = 0.3
		outlineCol = Color3.fromRGB(255, 235, 120)
	elseif style == "Chroma" then
		targetMat = Enum.Material.Neon
		targetTrans = 0.05
		fillTrans = 0.3
	end

	for part, data in pairs(SavedOriginalMaterials[char]) do
		if part and part.Parent then
			part.Material = targetMat
			part.Color = activeColor

			-- Сброс перекрывающих текстур на MeshPart/SpecialMesh, чтобы CrackedLava и Foil отображались четко
			if part:IsA("MeshPart") then
				pcall(function() part.TextureID = "" end)
			end
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
			if not shouldHideLocal then
				part.Transparency = targetTrans
			end
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

local function ApplyViewmodelAndWeaponChams()
	if not Config.Visuals.ViewmodelChams then return end
	local col = Config.Visuals.ViewmodelColor
	if Config.Visuals.ViewmodelStyle == "Chroma" then
		col = Color3.fromHSV((tick() * 0.4) % 1, 0.85, 1)
	end
	local mat = Enum.Material.ForceField
	if Config.Visuals.ViewmodelStyle == "Glow" or Config.Visuals.ViewmodelStyle == "Chroma" then
		mat = Enum.Material.Neon
	elseif Config.Visuals.ViewmodelStyle == "Lava" then
		mat = Enum.Material.CrackedLava
	elseif Config.Visuals.ViewmodelStyle == "Gold" then
		mat = Enum.Material.Foil
	end

	local char = LocalPlayer.Character
	if char then
		for _, item in ipairs(char:GetChildren()) do
			if item:IsA("Tool") then
				for _, p in ipairs(item:GetDescendants()) do
					if p:IsA("BasePart") then
						p.Material = mat
						p.Color = col
						if p:IsA("MeshPart") then pcall(function() p.TextureID = "" end) end
					end
				end
			elseif item:IsA("BasePart") and (item.Name:find("Arm") or item.Name:find("Hand")) then
				item.Material = mat
				item.Color = col
			end
		end
	end

	local cam = Workspace.CurrentCamera
	if cam then
		for _, v in ipairs(cam:GetDescendants()) do
			if v:IsA("BasePart") and not v:IsDescendantOf(ScreenGui) then
				v.Material = mat
				v.Color = col
			end
		end
	end
end

-------------------------------------------------------------------------
-- ИНТЕРФЕЙС И ГЕНЕРАТОРЫ КОНТРОЛОВ
-------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MonoSquat"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = guiParent

local AimFovCircle = Instance.new("Frame", ScreenGui)
AimFovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
AimFovCircle.BackgroundTransparency = 1
AimFovCircle.ZIndex = 50
AimFovCircle.Visible = false
Instance.new("UICorner", AimFovCircle).CornerRadius = UDim.new(1, 0)
local AimFovStroke = Instance.new("UIStroke", AimFovCircle)
AimFovStroke.Color = Config.Aimbot.FOVColor
AimFovStroke.Thickness = 1.4

local SilentFovCircle = Instance.new("Frame", ScreenGui)
SilentFovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
SilentFovCircle.BackgroundTransparency = 1
SilentFovCircle.ZIndex = 50
SilentFovCircle.Visible = false
Instance.new("UICorner", SilentFovCircle).CornerRadius = UDim.new(1, 0)
local SilentFovStroke = Instance.new("UIStroke", SilentFovCircle)
SilentFovStroke.Color = Config.SilentAim.FOVColor
SilentFovStroke.Thickness = 1.4

local EspFolder = Instance.new("Folder", ScreenGui)
EspFolder.Name = "ESP_Container"

local function MakeDraggable(handle, target)
	local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
	handle.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = inp.Position
			startPos = target.Position
			inp.Changed:Connect(function()
				if inp.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	handle.InputChanged:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
			dragInput = inp
		end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if inp == dragInput and dragging then
			local delta = inp.Position - dragStart
			tween(target, 0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, {
				Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			})
		end
	end)
end

local Watermark = Instance.new("TextButton")
Watermark.Size = UDim2.new(0, 128, 0, 26)
Watermark.Position = UDim2.new(0.015, 0, 0.05, 0)
Watermark.BackgroundColor3 = Color3.fromRGB(9, 9, 11)
Watermark.Text = ""
Watermark.AutoButtonColor = false
Watermark.ZIndex = 100
Watermark.Parent = ScreenGui
Instance.new("UICorner", Watermark).CornerRadius = UDim.new(0, 6)
local WmStroke = Instance.new("UIStroke", Watermark)
WmStroke.Color = Color3.fromRGB(65, 65, 75)
WmStroke.Thickness = 1

CreateVectorIcon(Watermark, "Logo", UDim2.new(0, 12, 0, 12), UDim2.new(0, 8, 0.5, -6), Color3.fromRGB(250, 250, 250))

local WmText = Instance.new("TextLabel", Watermark)
WmText.Size = UDim2.new(1, -38, 1, 0)
WmText.Position = UDim2.new(0, 24, 0, 0)
WmText.BackgroundTransparency = 1
WmText.Text = "MM2  •  MonoSquat"
WmText.TextColor3 = Color3.fromRGB(245, 245, 245)
WmText.Font = Enum.Font.GothamBold
WmText.TextSize = 9
WmText.TextXAlignment = Enum.TextXAlignment.Left

local WmDot = Instance.new("Frame", Watermark)
WmDot.Size = UDim2.new(0, 5, 0, 5)
WmDot.Position = UDim2.new(1, -11, 0.5, -2.5)
WmDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", WmDot).CornerRadius = UDim.new(1, 0)

RegisterThemeUpdater(function(th)
	Watermark.BackgroundColor3 = th.MainBg
	WmText.TextColor3 = th.TextPrimary
	WmStroke.Color = th.Stroke
	WmDot.BackgroundColor3 = th.Accent
end)

MakeDraggable(Watermark, Watermark)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 455, 0, 278)
MainFrame.Position = UDim2.new(0.5, -227, 0.5, -139)
MainFrame.BackgroundColor3 = Color3.fromRGB(9, 9, 11)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 9)

local MainScale = Instance.new("UIScale", MainFrame)
MainScale.Scale = 0.85
tween(MainScale, 0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Scale = 1 })

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(48, 48, 56)
MainStroke.Thickness = 1.2

local ColorPickerPopup = Instance.new("Frame", ScreenGui)
ColorPickerPopup.Size = UDim2.new(0, 160, 0, 120)
ColorPickerPopup.Position = UDim2.new(0.5, 235, 0.5, -60)
ColorPickerPopup.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
ColorPickerPopup.Visible = false
ColorPickerPopup.ZIndex = 200
Instance.new("UICorner", ColorPickerPopup).CornerRadius = UDim.new(0, 7)
local CpStroke = Instance.new("UIStroke", ColorPickerPopup)
CpStroke.Color = Color3.fromRGB(80, 80, 95)
MakeDraggable(ColorPickerPopup, ColorPickerPopup)

local CpTitle = Instance.new("TextLabel", ColorPickerPopup)
CpTitle.Size = UDim2.new(1, -24, 0, 18)
CpTitle.Position = UDim2.new(0, 8, 0, 2)
CpTitle.BackgroundTransparency = 1
CpTitle.Text = "COLOR PICKER"
CpTitle.TextColor3 = Color3.fromRGB(240, 240, 245)
CpTitle.Font = Enum.Font.GothamBold
CpTitle.TextSize = 8
CpTitle.TextXAlignment = Enum.TextXAlignment.Left
CpTitle.ZIndex = 201

local CpClose = Instance.new("TextButton", ColorPickerPopup)
CpClose.Size = UDim2.new(0, 16, 0, 16)
CpClose.Position = UDim2.new(1, -20, 0, 3)
CpClose.BackgroundTransparency = 1
CpClose.Text = "×"
CpClose.TextColor3 = Color3.fromRGB(200, 200, 210)
CpClose.Font = Enum.Font.GothamBold
CpClose.TextSize = 13
CpClose.ZIndex = 201
CpClose.MouseButton1Click:Connect(function() ColorPickerPopup.Visible = false end)

RegisterThemeUpdater(function(th)
	MainFrame.BackgroundColor3 = th.MainBg
	MainStroke.Color = th.Stroke
	ColorPickerPopup.BackgroundColor3 = th.HeaderBg
	CpStroke.Color = th.Stroke
	CpTitle.TextColor3 = th.TextPrimary
	CpClose.TextColor3 = th.TextSecondary
end)

local ActiveColorCallback, ActiveColorSwatch = nil, nil
local CurH, CurS, CurV = 0, 1, 1

local function CreateHsvBar(yPos, labelTxt, gradColors, onSlide)
	local lbl = Instance.new("TextLabel", ColorPickerPopup)
	lbl.Size = UDim2.new(0, 14, 0, 12)
	lbl.Position = UDim2.new(0, 8, 0, yPos)
	lbl.BackgroundTransparency = 1
	lbl.Text = labelTxt
	lbl.TextColor3 = Color3.fromRGB(160, 160, 175)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 8
	lbl.ZIndex = 201

	local bar = Instance.new("Frame", ColorPickerPopup)
	bar.Size = UDim2.new(1, -32, 0, 10)
	bar.Position = UDim2.new(0, 24, 0, yPos + 1)
	bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	bar.ZIndex = 201
	Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

	local grad = Instance.new("UIGradient", bar)
	grad.Color = ColorSequence.new(gradColors)

	local knob = Instance.new("Frame", bar)
	knob.Size = UDim2.new(0, 6, 1, 4)
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = UDim2.new(1, 0, 0.5, 0)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.ZIndex = 202
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
	Instance.new("UIStroke", knob).Color = Color3.fromRGB(0, 0, 0)

	local dragging = false
	local function update(x)
		local r = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		knob.Position = UDim2.new(r, 0, 0.5, 0)
		onSlide(r)
	end
	bar.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			dragging = true update(inp.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
			update(inp.Position.X)
		end
	end)
	return knob
end

local function ApplyPickedColor()
	local col = Color3.fromHSV(CurH, CurS, CurV)
	if ActiveColorSwatch then ActiveColorSwatch.BackgroundColor3 = col end
	if ActiveColorCallback then ActiveColorCallback(col) end
end

local HueKnob = CreateHsvBar(26, "H", {
	ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
	ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
	ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
	ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
	ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
	ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
}, function(r) CurH = r ApplyPickedColor() end)

local SatKnob = CreateHsvBar(46, "S", {
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
}, function(r) CurS = r ApplyPickedColor() end)

local ValKnob = CreateHsvBar(66, "V", {
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
}, function(r) CurV = r ApplyPickedColor() end)

local PresetColors = {
	Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 65, 85), Color3.fromRGB(80, 255, 130),
	Color3.fromRGB(80, 175, 255), Color3.fromRGB(255, 215, 70), Color3.fromRGB(175, 95, 255)
}
for i, pCol in ipairs(PresetColors) do
	local pb = Instance.new("TextButton", ColorPickerPopup)
	pb.Size = UDim2.new(0, 18, 0, 18)
	pb.Position = UDim2.new(0, 8 + (i - 1) * 24, 0, 88)
	pb.BackgroundColor3 = pCol
	pb.Text = ""
	pb.ZIndex = 201
	Instance.new("UICorner", pb).CornerRadius = UDim.new(0, 4)
	pb.MouseButton1Click:Connect(function()
		PlayUISound(6895079853, 1.4, 0.35)
		CurH, CurS, CurV = pCol:ToHSV()
		ApplyPickedColor()
	end)
end

local function OpenColorPicker(titleText, currentColor, swatchBtn, callback)
	PlayUISound(6895079853, 1.35, 0.35)
	CpTitle.Text = titleText:upper()
	ActiveColorSwatch = swatchBtn
	ActiveColorCallback = callback
	CurH, CurS, CurV = currentColor:ToHSV()
	HueKnob.Position = UDim2.new(CurH, 0, 0.5, 0)
	SatKnob.Position = UDim2.new(CurS, 0, 0.5, 0)
	ValKnob.Position = UDim2.new(CurV, 0, 0.5, 0)
	ColorPickerPopup.Visible = true
end

local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Color3.fromRGB(13, 13, 16)
Header.BorderSizePixel = 0

CreateVectorIcon(Header, "Logo", UDim2.new(0, 12, 0, 12), UDim2.new(0, 9, 0.5, -6), Color3.fromRGB(250, 250, 250))

local HeaderTitle = Instance.new("TextLabel", Header)
HeaderTitle.Size = UDim2.new(0, 75, 1, 0)
HeaderTitle.Position = UDim2.new(0, 25, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "MonoSquat"
HeaderTitle.TextColor3 = Color3.fromRGB(250, 250, 250)
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextSize = 10
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left

MakeDraggable(Header, MainFrame)

-- КНОПКА ПЕРЕКЛЮЧЕНИЯ ТЕМЫ (СПРАВА СВЕРХУ)
local ThemeToggleBtn = Instance.new("TextButton", Header)
ThemeToggleBtn.Size = UDim2.new(0, 22, 0, 22)
ThemeToggleBtn.Position = UDim2.new(1, -27, 0.5, -11)
ThemeToggleBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 27)
ThemeToggleBtn.Text = ""
ThemeToggleBtn.AutoButtonColor = false
Instance.new("UICorner", ThemeToggleBtn).CornerRadius = UDim.new(0, 5)
local ThemeBtnStroke = Instance.new("UIStroke", ThemeToggleBtn)
ThemeBtnStroke.Color = Color3.fromRGB(55, 55, 65)
ThemeBtnStroke.Thickness = 1

CreateVectorIcon(ThemeToggleBtn, "SunMoon", UDim2.new(0, 13, 0, 13), UDim2.new(0.5, -6.5, 0.5, -6.5), Color3.fromRGB(245, 245, 245))

local NavHolder = Instance.new("Frame", Header)
NavHolder.Size = UDim2.new(0, 332, 0, 22)
NavHolder.Position = UDim2.new(1, -364, 0.5, -11)
NavHolder.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Instance.new("UICorner", NavHolder).CornerRadius = UDim.new(0, 5)

local Pages = {}
local NavButtons = {}
local PageList = { "SKINS", "COMBAT", "ESP", "VISUALS", "RAGE", "CONFIGS" }
local CurrentPageName = "SKINS"

local NavIndicator = Instance.new("Frame", NavHolder)
NavIndicator.Size = UDim2.new(1 / #PageList, -2, 1, -2)
NavIndicator.Position = UDim2.new(0, 1, 0, 1)
NavIndicator.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
Instance.new("UICorner", NavIndicator).CornerRadius = UDim.new(0, 4)

local SharedPreviewPanel = nil

for i, pName in ipairs(PageList) do
	local b = Instance.new("TextButton", NavHolder)
	b.Size = UDim2.new(1 / #PageList, 0, 1, 0)
	b.Position = UDim2.new((i - 1) / #PageList, 0, 0, 0)
	b.BackgroundTransparency = 1
	b.Text = pName
	b.TextColor3 = (i == 1) and Color3.fromRGB(10, 10, 12) or Color3.fromRGB(150, 150, 160)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 8
	b.AutoButtonColor = false
	b.ZIndex = 2

	local page = Instance.new("Frame", MainFrame)
	page.Size = UDim2.new(1, -12, 1, -36)
	page.Position = UDim2.new(0, 6, 0, 33)
	page.BackgroundTransparency = 1
	page.Visible = (i == 1)

	Pages[pName] = page
	NavButtons[pName] = b

	b.MouseButton1Click:Connect(function()
		if CurrentPageName == pName then return end
		CurrentPageName = pName
		PlayUISound(6895079853, 1.25, 0.4)
		local th = GetTheme()

		tween(NavIndicator, 0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
			Position = UDim2.new((i - 1) / #PageList, 1, 0, 1)
		})

		for id, pg in pairs(Pages) do
			local act = (id == pName)
			pg.Visible = act
			if act then
				pg.Position = UDim2.new(0, 6, 0, 40)
				tween(pg, 0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
					Position = UDim2.new(0, 6, 0, 33)
				})
			end
			tween(NavButtons[id], 0.2, nil, nil, {
				TextColor3 = act and th.AccentText or th.TextSecondary
			})
		end

		if SharedPreviewPanel then
			SharedPreviewPanel.Visible = (pName == "ESP" or pName == "VISUALS")
		end
	end)
end

ThemeToggleBtn.MouseButton1Click:Connect(function()
	Config.Theme = (Config.Theme == "Dark") and "Light" or "Dark"
	PlayUISound(6895079853, Config.Theme == "Light" and 1.35 or 0.95, 0.45)
	ApplyMenuTheme()
end)

RegisterThemeUpdater(function(th)
	Header.BackgroundColor3 = th.HeaderBg
	HeaderTitle.TextColor3 = th.TextPrimary
	NavHolder.BackgroundColor3 = th.NavBg
	NavIndicator.BackgroundColor3 = th.Accent
	ThemeToggleBtn.BackgroundColor3 = th.NavBg
	ThemeBtnStroke.Color = th.Stroke
	for id, btn in pairs(NavButtons) do
		btn.TextColor3 = (id == CurrentPageName) and th.AccentText or th.TextSecondary
	end
end)

SharedPreviewPanel = Instance.new("Frame", MainFrame)
SharedPreviewPanel.Size = UDim2.new(0, 162, 1, -36)
SharedPreviewPanel.Position = UDim2.new(1, -168, 0, 33)
SharedPreviewPanel.BackgroundColor3 = Color3.fromRGB(13, 13, 16)
SharedPreviewPanel.Visible = false
SharedPreviewPanel.ZIndex = 10
Instance.new("UICorner", SharedPreviewPanel).CornerRadius = UDim.new(0, 7)
local PrevPanelStroke = Instance.new("UIStroke", SharedPreviewPanel)
PrevPanelStroke.Color = Color3.fromRGB(36, 36, 44)

CreateVectorIcon(SharedPreviewPanel, "Cube", UDim2.new(0, 11, 0, 11), UDim2.new(0, 7, 0, 6), Color3.fromRGB(190, 190, 200))

local PrevTopLbl = Instance.new("TextLabel", SharedPreviewPanel)
PrevTopLbl.Size = UDim2.new(1, -24, 0, 16)
PrevTopLbl.Position = UDim2.new(0, 22, 0, 4)
PrevTopLbl.BackgroundTransparency = 1
PrevTopLbl.Text = "3D ESP / CHAMS PREVIEW"
PrevTopLbl.TextColor3 = Color3.fromRGB(210, 210, 220)
PrevTopLbl.Font = Enum.Font.GothamBold
PrevTopLbl.TextSize = 8
PrevTopLbl.TextXAlignment = Enum.TextXAlignment.Left

local EspViewport = Instance.new("ViewportFrame", SharedPreviewPanel)
EspViewport.Size = UDim2.new(1, -10, 1, -44)
EspViewport.Position = UDim2.new(0, 5, 0, 22)
EspViewport.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
EspViewport.Ambient = Color3.fromRGB(190, 190, 200)
EspViewport.LightColor = Color3.fromRGB(255, 255, 255)
EspViewport.LightDirection = Vector3.new(-1, -1, -1)
EspViewport.ZIndex = 11
Instance.new("UICorner", EspViewport).CornerRadius = UDim.new(0, 6)
local EspVpStroke = Instance.new("UIStroke", EspViewport)
EspVpStroke.Color = Color3.fromRGB(30, 30, 36)

local EspWorld = Instance.new("WorldModel", EspViewport)
local EspVpCam = Instance.new("Camera", EspViewport)
EspViewport.CurrentCamera = EspVpCam

local PrevHintLbl = Instance.new("TextLabel", SharedPreviewPanel)
PrevHintLbl.Size = UDim2.new(1, -10, 0, 16)
PrevHintLbl.Position = UDim2.new(0, 5, 1, -19)
PrevHintLbl.BackgroundTransparency = 1
PrevHintLbl.Text = "Drag to rotate • Scroll to zoom"
PrevHintLbl.TextColor3 = Color3.fromRGB(125, 125, 135)
PrevHintLbl.Font = Enum.Font.GothamMedium
PrevHintLbl.TextSize = 8

RegisterThemeUpdater(function(th)
	SharedPreviewPanel.BackgroundColor3 = th.PanelBg
	PrevPanelStroke.Color = th.Stroke
	PrevTopLbl.TextColor3 = th.TextPrimary
	PrevHintLbl.TextColor3 = th.TextSecondary
	EspViewport.BackgroundColor3 = th.MainBg
	EspVpStroke.Color = th.Stroke
end)

local PreviewDummy = Instance.new("Model", EspWorld)
PreviewDummy.Name = "PreviewTarget"

local function makeDummyPart(name, size, cfOffset, color)
	local p = Instance.new("Part", PreviewDummy)
	p.Name = name
	p.Size = size
	p.CFrame = cfOffset
	p.Anchored = true
	p.CanCollide = false
	p.Color = color or Color3.fromRGB(215, 215, 225)
	p.Material = Enum.Material.SmoothPlastic
	return p
end

local dTorso = makeDummyPart("UpperTorso", Vector3.new(2, 2, 1), CFrame.new(0, 0.2, 0), Color3.fromRGB(45, 45, 52))
local dHead  = makeDummyPart("Head", Vector3.new(1.15, 1.15, 1.15), CFrame.new(0, 1.85, 0), Color3.fromRGB(235, 235, 240))
Instance.new("UICorner", dHead)
makeDummyPart("LeftArm",  Vector3.new(0.85, 1.95, 0.85), CFrame.new(-1.5, 0.2, 0) * CFrame.Angles(0, 0, math.rad(6)), Color3.fromRGB(200, 200, 210))
makeDummyPart("RightArm", Vector3.new(0.85, 1.95, 0.85), CFrame.new(1.5, 0.35, -0.35) * CFrame.Angles(math.rad(35), 0, math.rad(-6)), Color3.fromRGB(200, 200, 210))
makeDummyPart("LeftLeg",  Vector3.new(0.9, 2.0, 0.9), CFrame.new(-0.52, -1.85, 0), Color3.fromRGB(30, 30, 36))
makeDummyPart("RightLeg", Vector3.new(0.9, 2.0, 0.9), CFrame.new(0.52, -1.85, 0), Color3.fromRGB(30, 30, 36))
local dBlade = makeDummyPart("KnifePreview", Vector3.new(0.18, 0.45, 1.65), CFrame.new(1.5, 0.85, -1.35) * CFrame.Angles(math.rad(20), 0, 0), Color3.fromRGB(255, 65, 85))
dBlade.Material = Enum.Material.Neon
PreviewDummy.PrimaryPart = dTorso

local PrevEspBox = Instance.new("Frame", EspViewport)
PrevEspBox.Size = UDim2.new(0, 74, 0, 118)
PrevEspBox.AnchorPoint = Vector2.new(0.5, 0.5)
PrevEspBox.Position = UDim2.new(0.52, 0, 0.52, 0)
PrevEspBox.BackgroundTransparency = 1
PrevEspBox.ZIndex = 14

local PrevBoxStroke = Instance.new("UIStroke", PrevEspBox)
PrevBoxStroke.Thickness = 1.3

local PrevHpBg = Instance.new("Frame", PrevEspBox)
PrevHpBg.Size = UDim2.new(0, 3, 1, 0)
PrevHpBg.Position = UDim2.new(0, -6, 0, 0)
PrevHpBg.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
PrevHpBg.BorderSizePixel = 0
PrevHpBg.ZIndex = 14

local PrevHpFill = Instance.new("Frame", PrevHpBg)
PrevHpFill.Size = UDim2.new(1, 0, 0.85, 0)
PrevHpFill.AnchorPoint = Vector2.new(0, 1)
PrevHpFill.Position = UDim2.new(0, 0, 1, 0)
PrevHpFill.BorderSizePixel = 0
PrevHpFill.ZIndex = 15

local PrevNameLbl = Instance.new("TextLabel", PrevEspBox)
PrevNameLbl.Size = UDim2.new(0, 140, 0, 12)
PrevNameLbl.AnchorPoint = Vector2.new(0.5, 1)
PrevNameLbl.Position = UDim2.new(0.5, 0, 0, -13)
PrevNameLbl.BackgroundTransparency = 1
PrevNameLbl.Font = Enum.Font.GothamBold
PrevNameLbl.TextSize = 8
PrevNameLbl.Text = LocalPlayer.DisplayName .. " (@" .. LocalPlayer.Name .. ")"
PrevNameLbl.ZIndex = 15

local PrevMetaLbl = Instance.new("TextLabel", PrevEspBox)
PrevMetaLbl.Size = UDim2.new(0, 140, 0, 11)
PrevMetaLbl.AnchorPoint = Vector2.new(0.5, 1)
PrevMetaLbl.Position = UDim2.new(0.5, 0, 0, -2)
PrevMetaLbl.BackgroundTransparency = 1
PrevMetaLbl.Font = Enum.Font.GothamMedium
PrevMetaLbl.TextSize = 8
PrevMetaLbl.ZIndex = 15

local PrevWepLbl = Instance.new("TextLabel", PrevEspBox)
PrevWepLbl.Size = UDim2.new(0, 140, 0, 12)
PrevWepLbl.AnchorPoint = Vector2.new(0.5, 0)
PrevWepLbl.Position = UDim2.new(0.5, 0, 1, 2)
PrevWepLbl.BackgroundTransparency = 1
PrevWepLbl.Font = Enum.Font.GothamBold
PrevWepLbl.TextSize = 8
PrevWepLbl.Text = "MURDERER • Corrupt"
PrevWepLbl.ZIndex = 15

local DummyYaw, DummyPitch, DummyZoom = math.rad(25), math.rad(10), 6.2
local DummyDragging = false
local DummyLastPos = Vector2.zero

EspViewport.InputBegan:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
		DummyDragging = true
		DummyLastPos = Vector2.new(inp.Position.X, inp.Position.Y)
	end
end)
UserInputService.InputEnded:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
		DummyDragging = false
	end
end)
UserInputService.InputChanged:Connect(function(inp)
	if DummyDragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
		local cur = Vector2.new(inp.Position.X, inp.Position.Y)
		local delta = cur - DummyLastPos
		DummyLastPos = cur
		DummyYaw = DummyYaw - delta.X * 0.012
		DummyPitch = math.clamp(DummyPitch - delta.Y * 0.012, math.rad(-65), math.rad(65))
	end
end)
EspViewport.MouseWheelForward:Connect(function() DummyZoom = math.clamp(DummyZoom - 0.45, 3.8, 10) end)
EspViewport.MouseWheelBackward:Connect(function() DummyZoom = math.clamp(DummyZoom + 0.45, 3.8, 10) end)

-------------------------------------------------------------------------
-- ГЕНЕРАТОРЫ UI-КОНТРОЛОВ С ПОДДЕРЖКОЙ ТЕМ И КОНФИГОВ
-------------------------------------------------------------------------
local UIRefreshHooks = {}

local function CreateScrollContainer(parent, widthOffset)
	local sf = Instance.new("ScrollingFrame", parent)
	sf.Size = UDim2.new(1, widthOffset or 0, 1, 0)
	sf.BackgroundTransparency = 1
	sf.BorderSizePixel = 0
	sf.ScrollBarThickness = 2
	sf.ScrollBarImageColor3 = Color3.fromRGB(240, 240, 240)
	sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
	sf.CanvasSize = UDim2.new(0, 0, 0, 0)
	local lay = Instance.new("UIListLayout", sf)
	lay.Padding = UDim.new(0, 4)
	lay.SortOrder = Enum.SortOrder.LayoutOrder
	RegisterThemeUpdater(function(th)
		sf.ScrollBarImageColor3 = th.Accent
	end)
	return sf
end

local OrderCounter = 0
local function NextOrder()
	OrderCounter = OrderCounter + 1
	return OrderCounter
end

local function AddSectionLabel(parent, text)
	local lbl = Instance.new("TextLabel", parent)
	lbl.LayoutOrder = NextOrder()
	lbl.Size = UDim2.new(1, -6, 0, 15)
	lbl.BackgroundTransparency = 1
	lbl.Text = text:upper()
	lbl.TextColor3 = Color3.fromRGB(130, 130, 140)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 8
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	RegisterThemeUpdater(function(th) lbl.TextColor3 = th.TextSecondary end)
end

local function AddToggle(parent, title, defaultVal, callback, defaultColor, colorCallback)
	local row = Instance.new("Frame", parent)
	row.LayoutOrder = NextOrder()
	row.Size = UDim2.new(1, -6, 0, 24)
	row.BackgroundColor3 = Color3.fromRGB(15, 15, 19)
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

	row.MouseEnter:Connect(function()
		tween(row, 0.16, nil, nil, { BackgroundColor3 = GetTheme().RowHover })
	end)
	row.MouseLeave:Connect(function()
		tween(row, 0.16, nil, nil, { BackgroundColor3 = GetTheme().RowBg })
	end)

	local clickArea = Instance.new("TextButton", row)
	clickArea.Size = UDim2.new(1, defaultColor and -65 or -42, 1, 0)
	clickArea.BackgroundTransparency = 1
	clickArea.Text = ""

	local lbl = Instance.new("TextLabel", row)
	lbl.Size = UDim2.new(1, defaultColor and -70 or -48, 1, 0)
	lbl.Position = UDim2.new(0, 8, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = title
	lbl.TextColor3 = Color3.fromRGB(235, 235, 240)
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 9
	lbl.TextXAlignment = Enum.TextXAlignment.Left

	if defaultColor and colorCallback then
		local swatch = Instance.new("TextButton", row)
		swatch.Size = UDim2.new(0, 14, 0, 14)
		swatch.Position = UDim2.new(1, -56, 0.5, -7)
		swatch.BackgroundColor3 = defaultColor
		swatch.Text = ""
		swatch.AutoButtonColor = false
		Instance.new("UICorner", swatch).CornerRadius = UDim.new(0, 4)
		local swStroke = Instance.new("UIStroke", swatch)
		swStroke.Color = Color3.fromRGB(75, 75, 85)
		swStroke.Thickness = 1

		swatch.MouseButton1Click:Connect(function()
			OpenColorPicker(title, swatch.BackgroundColor3, swatch, colorCallback)
		end)
	end

	local box = Instance.new("TextButton", row)
	box.Size = UDim2.new(0, 28, 0, 14)
	box.Position = UDim2.new(1, -34, 0.5, -7)
	box.BackgroundColor3 = defaultVal and Color3.fromRGB(245, 245, 245) or Color3.fromRGB(32, 32, 38)
	box.Text = ""
	box.AutoButtonColor = false
	Instance.new("UICorner", box).CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("Frame", box)
	knob.Size = UDim2.new(0, 10, 0, 10)
	knob.Position = defaultVal and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
	knob.BackgroundColor3 = defaultVal and Color3.fromRGB(10, 10, 12) or Color3.fromRGB(150, 150, 160)
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local state = defaultVal
	local function setState(newVal, fireCallback)
		state = newVal
		local th = GetTheme()
		tween(box, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
			BackgroundColor3 = state and th.Accent or th.ToggleOff
		})
		tween(knob, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
			Position = state and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5),
			BackgroundColor3 = state and th.AccentText or th.KnobOff
		})
		if fireCallback then callback(state) end
	end

	RegisterThemeUpdater(function(th)
		row.BackgroundColor3 = th.RowBg
		lbl.TextColor3 = th.TextPrimary
		box.BackgroundColor3 = state and th.Accent or th.ToggleOff
		knob.BackgroundColor3 = state and th.AccentText or th.KnobOff
	end)

	local function toggle()
		PlayUISound(6895079853, state and 0.95 or 1.2, 0.35)
		setState(not state, true)
	end
	clickArea.MouseButton1Click:Connect(toggle)
	box.MouseButton1Click:Connect(toggle)
	return setState
end

local function AddSlider(parent, title, minVal, maxVal, defaultVal, isFloat, callback)
	local row = Instance.new("Frame", parent)
	row.LayoutOrder = NextOrder()
	row.Size = UDim2.new(1, -6, 0, 30)
	row.BackgroundColor3 = Color3.fromRGB(15, 15, 19)
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

	local lbl = Instance.new("TextLabel", row)
	lbl.Size = UDim2.new(0.65, 0, 0, 15)
	lbl.Position = UDim2.new(0, 8, 0, 2)
	lbl.BackgroundTransparency = 1
	lbl.Text = title
	lbl.TextColor3 = Color3.fromRGB(225, 225, 230)
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 9
	lbl.TextXAlignment = Enum.TextXAlignment.Left

	local valLbl = Instance.new("TextLabel", row)
	valLbl.Size = UDim2.new(0.3, -8, 0, 15)
	valLbl.Position = UDim2.new(0.7, 0, 0, 2)
	valLbl.BackgroundTransparency = 1
	valLbl.Text = tostring(defaultVal)
	valLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	valLbl.Font = Enum.Font.GothamBold
	valLbl.TextSize = 9
	valLbl.TextXAlignment = Enum.TextXAlignment.Right

	local bar = Instance.new("Frame", row)
	bar.Size = UDim2.new(1, -16, 0, 5)
	bar.Position = UDim2.new(0, 8, 0, 20)
	bar.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
	Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

	local fill = Instance.new("Frame", bar)
	fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

	RegisterThemeUpdater(function(th)
		row.BackgroundColor3 = th.RowBg
		lbl.TextColor3 = th.TextPrimary
		valLbl.TextColor3 = th.TextPrimary
		bar.BackgroundColor3 = th.ToggleOff
		fill.BackgroundColor3 = th.Accent
	end)

	local sliding = false
	local function updateSlider(inputX)
		local rel = math.clamp((inputX - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		local raw = minVal + (maxVal - minVal) * rel
		local val = isFloat and tonumber(string.format("%.2f", raw)) or math.floor(raw + 0.5)
		tween(fill, 0.06, Enum.EasingStyle.Sine, nil, { Size = UDim2.new(rel, 0, 1, 0) })
		valLbl.Text = tostring(val)
		callback(val)
	end
	bar.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			sliding = true updateSlider(inp.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			sliding = false
		end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if sliding and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
			updateSlider(inp.Position.X)
		end
	end)
end

local function AddCycleButton(parent, title, options, defaultIdx, callback)
	local idx = defaultIdx or 1
	local btn = Instance.new("TextButton", parent)
	btn.LayoutOrder = NextOrder()
	btn.Size = UDim2.new(1, -6, 0, 24)
	btn.BackgroundColor3 = Color3.fromRGB(18, 18, 23)
	btn.Text = "  " .. title .. ":  [ " .. tostring(options[idx]) .. " ]"
	btn.TextColor3 = Color3.fromRGB(240, 240, 245)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 9
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.AutoButtonColor = false
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

	RegisterThemeUpdater(function(th)
		btn.BackgroundColor3 = th.RowBg
		btn.TextColor3 = th.TextPrimary
	end)

	btn.MouseButton1Click:Connect(function()
		PlayUISound(6895079853, 1.3, 0.35)
		idx = (idx % #options) + 1
		btn.Text = "  " .. title .. ":  [ " .. tostring(options[idx]) .. " ]"
		callback(options[idx])
	end)
	return btn
end

-------------------------------------------------------------------------
-- ИНТЕРАКТИВНОЕ ПОСТРОЕНИЕ ВКЛАДОК: SKINS
-------------------------------------------------------------------------
local SkinsPage = Pages.SKINS
local SubTabBar = Instance.new("Frame", SkinsPage)
SubTabBar.Size = UDim2.new(1, 0, 0, 22)
SubTabBar.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Instance.new("UICorner", SubTabBar).CornerRadius = UDim.new(0, 5)

local SubTabBtns = {}
for idx, cat in ipairs({"Knife", "Gun", "Pet"}) do
	local sb = Instance.new("TextButton", SubTabBar)
	sb.Size = UDim2.new(1/3, -2, 1, -2)
	sb.Position = UDim2.new((idx - 1)/3, 1, 0, 1)
	sb.BackgroundColor3 = (idx == 1) and Color3.fromRGB(240, 240, 245) or Color3.fromRGB(15, 15, 18)
	sb.Text = cat:upper() .. "S"
	sb.TextColor3 = (idx == 1) and Color3.fromRGB(10, 10, 12) or Color3.fromRGB(140, 140, 150)
	sb.Font = Enum.Font.GothamBold
	sb.TextSize = 9
	sb.AutoButtonColor = false
	Instance.new("UICorner", sb).CornerRadius = UDim.new(0, 4)
	SubTabBtns[cat] = sb
end

local SearchHolder = Instance.new("Frame", SkinsPage)
SearchHolder.Size = UDim2.new(1, 0, 0, 22)
SearchHolder.Position = UDim2.new(0, 0, 0, 26)
SearchHolder.BackgroundColor3 = Color3.fromRGB(14, 14, 17)
Instance.new("UICorner", SearchHolder).CornerRadius = UDim.new(0, 5)
local SearchStroke = Instance.new("UIStroke", SearchHolder)
SearchStroke.Color = Color3.fromRGB(32, 32, 38)
CreateVectorIcon(SearchHolder, "Search", UDim2.new(0, 10, 0, 10), UDim2.new(0, 7, 0.5, -5), Color3.fromRGB(140, 140, 150))

local SearchBox = Instance.new("TextBox", SearchHolder)
SearchBox.Size = UDim2.new(1, -26, 1, 0)
SearchBox.Position = UDim2.new(0, 22, 0, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.PlaceholderText = "Search any Knife, Gun or Pet skin..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(95, 95, 105)
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(245, 245, 245)
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 9
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.ClearTextOnFocus = false

local SkinScroll = Instance.new("ScrollingFrame", SkinsPage)
SkinScroll.Size = UDim2.new(1, 0, 1, -52)
SkinScroll.Position = UDim2.new(0, 0, 0, 52)
SkinScroll.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
SkinScroll.BorderSizePixel = 0
SkinScroll.ScrollBarThickness = 2
SkinScroll.ScrollBarImageColor3 = Color3.fromRGB(240, 240, 240)
SkinScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
SkinScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Instance.new("UICorner", SkinScroll).CornerRadius = UDim.new(0, 6)

local SkinGrid = Instance.new("UIGridLayout", SkinScroll)
SkinGrid.CellSize = UDim2.new(0.485, 0, 0, 24)
SkinGrid.CellPadding = UDim2.new(0.015, 0, 0, 4)
SkinGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center

local SkinPad = Instance.new("UIPadding", SkinScroll)
SkinPad.PaddingTop = UDim.new(0, 5)
SkinPad.PaddingBottom = UDim.new(0, 5)

local function RenderSkinList()
	local th = GetTheme()
	for _, c in ipairs(SkinScroll:GetChildren()) do
		if c:IsA("TextButton") then c:Destroy() end
	end
	local q = SearchBox.Text:lower()
	for _, skin in ipairs(SkinsList[ActiveCategory] or {}) do
		if q == "" or skin.Name:lower():find(q, 1, true) then
			local isEq = (SelectedSkins[ActiveCategory] and SelectedSkins[ActiveCategory].Id == skin.Id)
			local btn = Instance.new("TextButton", SkinScroll)
			btn.BackgroundColor3 = isEq and th.Accent or th.RowBg
			btn.Text = "  " .. skin.Name .. (isEq and "  [EQUIPPED]" or "")
			btn.TextColor3 = isEq and th.AccentText or th.TextPrimary
			btn.Font = isEq and Enum.Font.GothamBold or Enum.Font.GothamMedium
			btn.TextSize = 9
			btn.TextXAlignment = Enum.TextXAlignment.Left
			btn.TextTruncate = Enum.TextTruncate.AtEnd
			btn.AutoButtonColor = false
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

			btn.MouseButton1Click:Connect(function()
				PlayUISound(6895079853, 1.35, 0.4)
				SelectedSkins[ActiveCategory] = skin
				RefreshEquippedSkins()
				RenderSkinList()
			end)
		end
	end
end

RegisterThemeUpdater(function(th)
	SubTabBar.BackgroundColor3 = th.NavBg
	SearchHolder.BackgroundColor3 = th.RowBg
	SearchStroke.Color = th.Stroke
	SearchBox.TextColor3 = th.TextPrimary
	SearchBox.PlaceholderColor3 = th.TextSecondary
	SkinScroll.BackgroundColor3 = th.ScrollBg
	SkinScroll.ScrollBarImageColor3 = th.Accent
	for c, b in pairs(SubTabBtns) do
		local act = (c == ActiveCategory)
		b.BackgroundColor3 = act and th.Accent or th.NavBg
		b.TextColor3 = act and th.AccentText or th.TextSecondary
	end
	RenderSkinList()
end)

for cat, btn in pairs(SubTabBtns) do
	btn.MouseButton1Click:Connect(function()
		PlayUISound(6895079853, 1.25, 0.35)
		ActiveCategory = cat
		local th = GetTheme()
		for c, b in pairs(SubTabBtns) do
			local act = (c == cat)
			tween(b, 0.18, nil, nil, {
				BackgroundColor3 = act and th.Accent or th.NavBg,
				TextColor3 = act and th.AccentText or th.TextSecondary
			})
		end
		RenderSkinList()
	end)
end
SearchBox:GetPropertyChangedSignal("Text"):Connect(RenderSkinList)

-------------------------------------------------------------------------
-- ВКЛАДКА COMBAT (УЛУЧШЕННЫЙ SILENT AIM & RESOLVER)
-------------------------------------------------------------------------
local CombatScroll = CreateScrollContainer(Pages.COMBAT, 0)
AddSectionLabel(CombatScroll, "Audio & Hitsound")
AddToggle(CombatScroll, "Enable Hit Sound", Config.HitSound.Enabled, function(v) Config.HitSound.Enabled = v end)

AddSectionLabel(CombatScroll, "Camera AimBot")
AddToggle(CombatScroll, "Enable AimBot", Config.Aimbot.Enabled, function(v) Config.Aimbot.Enabled = v end)
AddToggle(CombatScroll, "Always Active (No Key Hold)", Config.Aimbot.AlwaysActive, function(v) Config.Aimbot.AlwaysActive = v end)
AddToggle(CombatScroll, "Enemy Role Only (Off = Target All)", Config.Aimbot.TeamCheck, function(v) Config.Aimbot.TeamCheck = v end)
AddToggle(CombatScroll, "Visible Only (WallCheck)", Config.Aimbot.VisibleOnly, function(v) Config.Aimbot.VisibleOnly = v end)
AddCycleButton(CombatScroll, "AimBot Target Part", {"Head", "HumanoidRootPart", "Random"}, 1, function(v) Config.Aimbot.Hitbox = v end)
AddToggle(CombatScroll, "Draw AimBot FOV Circle", Config.Aimbot.DrawFOV, function(v) Config.Aimbot.DrawFOV = v end, Config.Aimbot.FOVColor, function(c)
	Config.Aimbot.FOVColor = c AimFovStroke.Color = c
end)
AddSlider(CombatScroll, "AimBot FOV Radius", 30, 360, Config.Aimbot.FOV, false, function(v) Config.Aimbot.FOV = v end)
AddSlider(CombatScroll, "AimBot Smoothness", 0.05, 1.0, Config.Aimbot.Smooth, true, function(v) Config.Aimbot.Smooth = v end)
AddSlider(CombatScroll, "AimBot Delay (s)", 0.0, 0.5, Config.Aimbot.Delay, true, function(v) Config.Aimbot.Delay = v end)

AddSectionLabel(CombatScroll, "Silent AimBot, Resolver & WallShot")
AddToggle(CombatScroll, "Enable Silent Aim", Config.SilentAim.Enabled, function(v) Config.SilentAim.Enabled = v end)
AddToggle(CombatScroll, "Velocity Resolver (Anti-Aim Bypass)", Config.SilentAim.Resolver, function(v) Config.SilentAim.Resolver = v end)
AddToggle(CombatScroll, "WallShot (Shoot Through Walls)", Config.SilentAim.WallShot, function(v) Config.SilentAim.WallShot = v end)
AddCycleButton(CombatScroll, "Hitbox Priority", {"Head", "HumanoidRootPart", "Random"}, 1, function(v) Config.SilentAim.HitboxPriority = v end)
AddToggle(CombatScroll, "3D Bullet Impact Boxes", Config.SilentAim.BulletImpacts, function(v) Config.SilentAim.BulletImpacts = v end, Config.SilentAim.ImpactColor, function(c) Config.SilentAim.ImpactColor = c end)
AddToggle(CombatScroll, "Draw Silent FOV Circle", Config.SilentAim.DrawFOV, function(v) Config.SilentAim.DrawFOV = v end, Config.SilentAim.FOVColor, function(c)
	Config.SilentAim.FOVColor = c SilentFovStroke.Color = c
end)
AddSlider(CombatScroll, "Silent Aim FOV Radius", 40, 400, Config.SilentAim.FOV, false, function(v) Config.SilentAim.FOV = v end)
AddSlider(CombatScroll, "Silent Hit Chance (%)", 1, 100, Config.SilentAim.HitChance, false, function(v) Config.SilentAim.HitChance = v end)
AddSlider(CombatScroll, "Silent Movement Prediction", 0.05, 0.35, Config.SilentAim.Prediction, true, function(v) Config.SilentAim.Prediction = v end)

AddSectionLabel(CombatScroll, "Trigger Bot")
AddToggle(CombatScroll, "Enable Trigger Bot", Config.TriggerBot.Enabled, function(v) Config.TriggerBot.Enabled = v end)
AddSlider(CombatScroll, "Trigger Delay (s)", 0.0, 0.4, Config.TriggerBot.Delay, true, function(v) Config.TriggerBot.Delay = v end)

-------------------------------------------------------------------------
-- ВКЛАДКА ESP (ПИСТОЛЕТ, МОНЕТЫ, ТРАССЕРЫ, ДИСТАНЦИЯ, CHAMS)
-------------------------------------------------------------------------
local EspScroll = CreateScrollContainer(Pages.ESP, -168)
AddSectionLabel(EspScroll, "Player 2D ESP & World Indicators")
AddToggle(EspScroll, "Enable Master ESP", Config.ESP.Enabled, function(v) Config.ESP.Enabled = v end)
AddToggle(EspScroll, "2D Box ESP", Config.ESP.Box, function(v) Config.ESP.Box = v end, Config.ESP.BoxColor, function(c) Config.ESP.BoxColor = c end)
AddToggle(EspScroll, "Player Nickname", Config.ESP.Nickname, function(v) Config.ESP.Nickname = v end, Config.ESP.NicknameColor, function(c) Config.ESP.NicknameColor = c end)
AddToggle(EspScroll, "Health Bar", Config.ESP.HealthBar, function(v) Config.ESP.HealthBar = v end, Config.ESP.HealthColor, function(c) Config.ESP.HealthColor = c end)
AddToggle(EspScroll, "Weapon & Role", Config.ESP.Weapon, function(v) Config.ESP.Weapon = v end, Config.ESP.WeaponColor, function(c) Config.ESP.WeaponColor = c end)
AddToggle(EspScroll, "Distance Tag ([m])", Config.ESP.Distance, function(v) Config.ESP.Distance = v end, Config.ESP.DistanceColor, function(c) Config.ESP.DistanceColor = c end)
AddToggle(EspScroll, "Snaplines (Bottom Screen)", Config.ESP.Snaplines, function(v) Config.ESP.Snaplines = v end, Config.ESP.SnaplineColor, function(c) Config.ESP.SnaplineColor = c end)
AddToggle(EspScroll, "Look Direction Line", Config.ESP.LookLine, function(v) Config.ESP.LookLine = v end, Config.ESP.LookLineColor, function(c) Config.ESP.LookLineColor = c end)
AddToggle(EspScroll, "Player Ping (ms)", Config.ESP.Ping, function(v) Config.ESP.Ping = v end, Config.ESP.PingColor, function(c) Config.ESP.PingColor = c end)
AddToggle(EspScroll, "Device Tag (PC / MOB)", Config.ESP.Device, function(v) Config.ESP.Device = v end, Config.ESP.DeviceColor, function(c) Config.ESP.DeviceColor = c end)

AddSectionLabel(EspScroll, "Enemy Chams & Dropped Gun / Coins")
AddToggle(EspScroll, "Enemy Chams (Full Body)", Config.ESP.Chams, function(v) Config.ESP.Chams = v end, Config.ESP.ChamsColor, function(c) Config.ESP.ChamsColor = c end)
AddCycleButton(EspScroll, "Enemy Chams Style", ChamsStylesList, 1, function(st) Config.ESP.ChamsStyle = st end)
AddToggle(EspScroll, "Dropped Gun ESP & Chams", Config.ESP.GunDropESP, function(v) Config.ESP.GunDropESP = v end, Config.ESP.GunDropColor, function(c) Config.ESP.GunDropColor = c end)
AddToggle(EspScroll, "Coin Container ESP", Config.ESP.CoinESP, function(v) Config.ESP.CoinESP = v end, Config.ESP.CoinESPColor, function(c) Config.ESP.CoinESPColor = c end)

-------------------------------------------------------------------------
-- ВКЛАДКА VISUALS (FULLBRIGHT, NIGHT MODE, VIEWMODEL, CUSTOM MODELS, SKY FIX)
-------------------------------------------------------------------------
local VisScroll = CreateScrollContainer(Pages.VISUALS, -168)
AddSectionLabel(VisScroll, "Self Chams, Weapon Chams & 3D Models")

AddToggle(VisScroll, "Local Player Chams", Config.Visuals.LocalChams, function(v)
	Config.Visuals.LocalChams = v
	if not v and LocalPlayer.Character then
		ApplyChamsToCharacter(LocalPlayer.Character, false, Config.Visuals.LocalChamsStyle, Config.Visuals.LocalChamsColor, false)
	end
end, Config.Visuals.LocalChamsColor, function(c) Config.Visuals.LocalChamsColor = c end)

AddCycleButton(VisScroll, "Local Chams Style", ChamsStylesList, 1, function(st)
	Config.Visuals.LocalChamsStyle = st
end)

AddToggle(VisScroll, "Weapon & Arms Chams", Config.Visuals.ViewmodelChams, function(v)
	Config.Visuals.ViewmodelChams = v
end, Config.Visuals.ViewmodelColor, function(c) Config.Visuals.ViewmodelColor = c end)

AddCycleButton(VisScroll, "Weapon Chams Style", {"ForceField", "Glow", "Lava", "Gold", "Chroma"}, 1, function(st)
	Config.Visuals.ViewmodelStyle = st
end)

local ActiveCustomRig = nil
local CustomModelList = {
	"None", "Cyber Mecha", "Shadow Fiend", "Angelic Core",
	"Crimson Samurai", "Void Walker", "Golden Valkyrie", "Sketchfab Mech"
}

local function BuildCustomCharacterModel(modelType)
	Config.Visuals.CustomModel = modelType
	if ActiveCustomRig then
		ActiveCustomRig:Destroy()
		ActiveCustomRig = nil
	end

	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not char or not hrp or modelType == "None" then
		if char then
			for _, p in ipairs(char:GetDescendants()) do
				if (p:IsA("BasePart") or p:IsA("Decal")) and p.Name ~= "HumanoidRootPart" then
					p.Transparency = 0
				end
			end
		end
		return
	end

	local rig = Instance.new("Model", char)
	rig.Name = "MM2_CustomRig"
	ActiveCustomRig = rig

	local function addRigPart(size, offsetCF, mat, col, meshInfo)
		local p = Instance.new("Part", rig)
		p.Size = size
		p.Material = mat or Enum.Material.Neon
		p.Color = col
		p.CanCollide = false
		p.Massless = true
		p.CFrame = hrp.CFrame * offsetCF
		if meshInfo then
			local sm = Instance.new("SpecialMesh", p)
			sm.MeshType = meshInfo.Type or Enum.MeshType.FileMesh
			if meshInfo.MeshId then sm.MeshId = meshInfo.MeshId end
			if meshInfo.TexId then sm.TextureId = meshInfo.TexId end
			sm.Scale = meshInfo.Scale or Vector3.new(1, 1, 1)
		end
		local w = Instance.new("WeldConstraint", p)
		w.Part0 = hrp w.Part1 = p
		return p
	end

	if modelType == "Cyber Mecha" then
		addRigPart(Vector3.new(2.2, 2.3, 1.3), CFrame.new(0, 0.2, 0), Enum.Material.SmoothPlastic, Color3.fromRGB(22, 22, 28))
		addRigPart(Vector3.new(1.5, 0.7, 1.4), CFrame.new(0, 0.5, 0), Enum.Material.Neon, Config.Visuals.LocalChamsColor)
		addRigPart(Vector3.new(1.3, 1.2, 1.3), CFrame.new(0, 1.9, 0), Enum.Material.SmoothPlastic, Color3.fromRGB(28, 28, 36))
		addRigPart(Vector3.new(1.1, 0.35, 1.35), CFrame.new(0, 1.95, -0.05), Enum.Material.Neon, Color3.fromRGB(0, 245, 255))
		addRigPart(Vector3.new(0.25, 3.2, 1.2), CFrame.new(-1.6, 0.8, 0.9) * CFrame.Angles(0, math.rad(25), math.rad(22)), Enum.Material.Neon, Config.Visuals.LocalChamsColor)
		addRigPart(Vector3.new(0.25, 3.2, 1.2), CFrame.new(1.6, 0.8, 0.9) * CFrame.Angles(0, math.rad(-25), math.rad(-22)), Enum.Material.Neon, Config.Visuals.LocalChamsColor)
	elseif modelType == "Shadow Fiend" then
		addRigPart(Vector3.new(2, 2, 2), CFrame.new(0, 1.4, 0), Enum.Material.SmoothPlastic, Color3.fromRGB(15, 15, 18), {
			MeshId = "rbxassetid://148414896", TexId = "rbxassetid://148414922", Scale = Vector3.new(2.2, 2.2, 2.2)
		})
		addRigPart(Vector3.new(2.1, 3.2, 1.2), CFrame.new(0, -0.5, 0), Enum.Material.ForceField, Color3.fromRGB(170, 50, 255))
	elseif modelType == "Angelic Core" then
		local sphere = addRigPart(Vector3.new(2.4, 2.4, 2.4), CFrame.new(0, 0.4, 0), Enum.Material.Neon, Color3.fromRGB(255, 255, 255))
		sphere.Shape = Enum.PartType.Ball
		addRigPart(Vector3.new(4.2, 0.25, 4.2), CFrame.new(0, 0.4, 0) * CFrame.Angles(math.rad(35), 0, math.rad(35)), Enum.Material.ForceField, Config.Visuals.LocalChamsColor)
		addRigPart(Vector3.new(4.2, 0.25, 4.2), CFrame.new(0, 0.4, 0) * CFrame.Angles(math.rad(-35), 0, math.rad(-35)), Enum.Material.ForceField, Color3.fromRGB(0, 235, 255))
	elseif modelType == "Crimson Samurai" then
		addRigPart(Vector3.new(2, 2, 2), CFrame.new(0, 1.65, 0), Enum.Material.SmoothPlastic, Color3.fromRGB(220, 30, 50), {
			MeshId = "rbxassetid://16150814", TexId = "rbxassetid://16150799", Scale = Vector3.new(1.35, 1.35, 1.35)
		})
		addRigPart(Vector3.new(2.1, 2.4, 1.2), CFrame.new(0, 0, 0), Enum.Material.Neon, Color3.fromRGB(255, 35, 65))
		addRigPart(Vector3.new(0.2, 4.2, 0.4), CFrame.new(-1.2, 0.6, 0.7) * CFrame.Angles(0, 0, math.rad(32)), Enum.Material.Neon, Color3.fromRGB(255, 255, 255))
		addRigPart(Vector3.new(0.2, 4.2, 0.4), CFrame.new(1.2, 0.6, 0.7) * CFrame.Angles(0, 0, math.rad(-32)), Enum.Material.Neon, Color3.fromRGB(255, 50, 70))
	elseif modelType == "Void Walker" then
		addRigPart(Vector3.new(2, 2, 2), CFrame.new(0, 1.5, 0), Enum.Material.Neon, Color3.fromRGB(130, 50, 255), {
			MeshId = "rbxassetid://96101906", Scale = Vector3.new(1.5, 1.5, 1.5)
		})
		addRigPart(Vector3.new(2.8, 3.5, 1.6), CFrame.new(0, -0.2, 0), Enum.Material.ForceField, Color3.fromRGB(90, 20, 200))
	elseif modelType == "Golden Valkyrie" then
		addRigPart(Vector3.new(2, 2, 2), CFrame.new(0, 1.7, 0), Enum.Material.Foil, Color3.fromRGB(255, 210, 60), {
			MeshId = "rbxassetid://1365767", Scale = Vector3.new(1.35, 1.35, 1.35)
		})
		addRigPart(Vector3.new(2, 2, 2), CFrame.new(0, 0.5, 0.65), Enum.Material.Neon, Color3.fromRGB(255, 215, 75), {
			MeshId = "rbxassetid://19367764", Scale = Vector3.new(1.8, 1.8, 1.8)
		})
		addRigPart(Vector3.new(2.0, 2.5, 1.1), CFrame.new(0, -0.2, 0), Enum.Material.Foil, Color3.fromRGB(255, 200, 50))
	elseif modelType == "Sketchfab Mech" then
		addRigPart(Vector3.new(2.5, 2.8, 2.0), CFrame.new(0, 0.5, 0), Enum.Material.Metal, Color3.fromRGB(60, 65, 75), {
			MeshId = "rbxassetid://430080282", Scale = Vector3.new(0.04, 0.04, 0.04)
		})
		addRigPart(Vector3.new(2.6, 2.9, 1.6), CFrame.new(0, 0.3, 0), Enum.Material.ForceField, Config.Visuals.LocalChamsColor)
	end
end

AddCycleButton(VisScroll, "Custom 3D Model", CustomModelList, 1, BuildCustomCharacterModel)

AddSectionLabel(VisScroll, "Atmosphere, Fullbright & World Shaders")

local OrigAmbient = Lighting.Ambient
local OrigOutdoor = Lighting.OutdoorAmbient
local OrigBrightness = Lighting.Brightness
local OrigClockTime = Lighting.ClockTime
local OrigFogColor = Lighting.FogColor
local OrigFogEnd = Lighting.FogEnd

local CustomBloom = Lighting:FindFirstChild("MonoSquat_Bloom") or Instance.new("BloomEffect", Lighting)
CustomBloom.Name = "MonoSquat_Bloom"
CustomBloom.Enabled = false

local CustomSkyCC = Lighting:FindFirstChild("MonoSquat_SkyCC") or Instance.new("ColorCorrectionEffect", Lighting)
CustomSkyCC.Name = "MonoSquat_SkyCC"
CustomSkyCC.Enabled = false

local function RestoreLightingDefaults()
	if not Config.Visuals.Fullbright and not Config.Visuals.NightMode and not Config.Visuals.CustomSky then
		Lighting.Ambient = OrigAmbient
		Lighting.OutdoorAmbient = OrigOutdoor
		Lighting.Brightness = OrigBrightness
		Lighting.ClockTime = OrigClockTime
	end
	CustomSkyCC.Enabled = Config.Visuals.CustomSky
end

AddToggle(VisScroll, "Fullbright (Remove Darkness)", Config.Visuals.Fullbright, function(v)
	Config.Visuals.Fullbright = v
	RestoreLightingDefaults()
end, Config.Visuals.FullbrightColor, function(c) Config.Visuals.FullbrightColor = c end)

AddToggle(VisScroll, "Night Mode (Midnight Map)", Config.Visuals.NightMode, function(v)
	Config.Visuals.NightMode = v
	RestoreLightingDefaults()
end)

AddToggle(VisScroll, "Custom Sky & World Tint (Fixed)", Config.Visuals.CustomSky, function(v)
	Config.Visuals.CustomSky = v
	CustomSkyCC.Enabled = v
	RestoreLightingDefaults()
end, Config.Visuals.SkyColor, function(c) Config.Visuals.SkyColor = c end)

AddToggle(VisScroll, "Shader Bloom Glow", Config.Visuals.Bloom, function(v)
	Config.Visuals.Bloom = v
	CustomBloom.Enabled = v
	CustomBloom.Intensity = Config.Visuals.BloomIntensity
	CustomBloom.Size = 28
	CustomBloom.Threshold = 0.85
end)
AddSlider(VisScroll, "Bloom Intensity", 0.5, 4.0, Config.Visuals.BloomIntensity, true, function(v)
	Config.Visuals.BloomIntensity = v CustomBloom.Intensity = v
end)

AddToggle(VisScroll, "Atmosphere Fog", Config.Visuals.Fog, function(v)
	Config.Visuals.Fog = v
	if not v then Lighting.FogColor = OrigFogColor Lighting.FogEnd = OrigFogEnd end
end, Config.Visuals.FogColor, function(c) Config.Visuals.FogColor = c end)
AddSlider(VisScroll, "Fog Distance", 40, 600, Config.Visuals.FogEnd, false, function(v) Config.Visuals.FogEnd = v end)

AddToggle(VisScroll, "3D Rain Particles", Config.Visuals.Rain, function(v) Config.Visuals.Rain = v end, Config.Visuals.RainColor, function(c) Config.Visuals.RainColor = c end)
AddToggle(VisScroll, "3D Bullet Tracers", Config.Visuals.BulletTracer, function(v) Config.Visuals.BulletTracer = v end, Config.Visuals.TracerColor, function(c) Config.Visuals.TracerColor = c end)

-------------------------------------------------------------------------
-- ВКЛАДКА RAGE
-------------------------------------------------------------------------
local RageScroll = CreateScrollContainer(Pages.RAGE, 0)
AddSectionLabel(RageScroll, "Player Teleport & Touch Fling")

local TargetNames = {"None"}
local function RefreshTargetNames()
	TargetNames = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then table.insert(TargetNames, p.Name) end
	end
	if #TargetNames == 0 then table.insert(TargetNames, "None") end
end
RefreshTargetNames()

AddCycleButton(RageScroll, "Select Target", TargetNames, 1, function(selectedName)
	Config.Rage.SelectedTarget = Players:FindFirstChild(selectedName)
end)

local TpNowBtn = Instance.new("TextButton", RageScroll)
TpNowBtn.LayoutOrder = NextOrder()
TpNowBtn.Size = UDim2.new(1, -6, 0, 24)
TpNowBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
TpNowBtn.Text = "TELEPORT TO SELECTED PLAYER"
TpNowBtn.TextColor3 = Color3.fromRGB(10, 10, 12)
TpNowBtn.Font = Enum.Font.GothamBold
TpNowBtn.TextSize = 9
Instance.new("UICorner", TpNowBtn).CornerRadius = UDim.new(0, 5)
RegisterThemeUpdater(function(th)
	TpNowBtn.BackgroundColor3 = th.Accent
	TpNowBtn.TextColor3 = th.AccentText
end)

TpNowBtn.MouseButton1Click:Connect(function()
	PlayUISound(6895079853, 1.35, 0.45)
	RefreshTargetNames()
	local target = Config.Rage.SelectedTarget or Players:FindFirstChild(TargetNames[1])
	local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	local tHrp = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
	if myHrp and tHrp then
		myHrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, 2)
	end
end)

AddToggle(RageScroll, "Touch Fling (Launch Enemies on Contact)", Config.Rage.Fling, function(v) Config.Rage.Fling = v end)
AddSlider(RageScroll, "Fling Launch Power", 8000, 35000, Config.Rage.FlingPower, false, function(v) Config.Rage.FlingPower = v end)

AddSectionLabel(RageScroll, "Anti-Aim (Yaw & Pitch Spoofer)")
AddToggle(RageScroll, "Enable Anti-Aim", Config.Rage.AntiAim, function(v)
	Config.Rage.AntiAim = v
	if not v and LocalPlayer.Character then
		local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.AutoRotate = true end
	end
end)
AddCycleButton(RageScroll, "Anti-Aim Yaw Mode", {"Spin", "Jitter", "Backwards", "Random", "Static"}, 1, function(m) Config.Rage.AntiAimYaw = m end)
AddCycleButton(RageScroll, "Anti-Aim Pitch Mode", {"Down", "Up", "Zero", "Jitter"}, 1, function(m) Config.Rage.AntiAimPitch = m end)
AddSlider(RageScroll, "Anti-Aim Spin / Jitter Speed", 5, 100, Config.Rage.AntiAimSpeed, false, function(v) Config.Rage.AntiAimSpeed = v end)
AddSlider(RageScroll, "Anti-Aim Yaw Angle (°)", -180, 180, Config.Rage.AntiAimAngle, false, function(v) Config.Rage.AntiAimAngle = v end)

AddSectionLabel(RageScroll, "Movement, Fly & FPV Kamikaze Drone")

local FlyBV, FlyBG = nil, nil
local function StopFlyControllers()
	if FlyBV then FlyBV:Destroy() FlyBV = nil end
	if FlyBG then FlyBG:Destroy() FlyBG = nil end
	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.PlatformStand = false end
end

AddToggle(RageScroll, "Fly Mode (Smooth Stabilized)", Config.Rage.Fly, function(v)
	Config.Rage.Fly = v
	if not v and not Config.Rage.FPVDrone then StopFlyControllers() end
end)
AddSlider(RageScroll, "Fly Speed", 20, 160, Config.Rage.FlySpeed, false, function(v) Config.Rage.FlySpeed = v end)

local ActiveDroneModel = nil
local SetDroneToggleUI = nil

local function StopFPVDrone(explodePos)
	Config.Rage.FPVDrone = false
	if SetDroneToggleUI then SetDroneToggleUI(false) end
	if ActiveDroneModel then ActiveDroneModel:Destroy() ActiveDroneModel = nil end
	if not Config.Rage.Fly then StopFlyControllers() end
	local char = LocalPlayer.Character
	if char then
		for _, p in ipairs(char:GetDescendants()) do
			if (p:IsA("BasePart") or p:IsA("Decal")) and p.Name ~= "HumanoidRootPart" then
				p.Transparency = 0
			end
		end
		if explodePos then
			PlayUISound(138186576, 1.0, 0.85)
			local exp = Instance.new("Explosion", Workspace)
			exp.Position = explodePos
			exp.BlastRadius = 20
			exp.BlastPressure = 0
		end
	end
end

local function StartFPVDrone()
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	if ActiveDroneModel then ActiveDroneModel:Destroy() end

	local drone = Instance.new("Model", char)
	drone.Name = "MM2_FPV_Drone"
	ActiveDroneModel = drone

	local frameCenter = Instance.new("Part", drone)
	frameCenter.Size = Vector3.new(1.4, 0.42, 2.0)
	frameCenter.Color = Color3.fromRGB(22, 22, 26)
	frameCenter.Material = Enum.Material.SmoothPlastic
	frameCenter.CanCollide = false
	frameCenter.Massless = true
	frameCenter.CFrame = hrp.CFrame
	local w0 = Instance.new("WeldConstraint", frameCenter)
	w0.Part0 = hrp w0.Part1 = frameCenter

	local battery = Instance.new("Part", drone)
	battery.Size = Vector3.new(0.85, 0.35, 1.2)
	battery.Color = Color3.fromRGB(245, 245, 250)
	battery.Material = Enum.Material.Neon
	battery.CanCollide = false
	battery.Massless = true
	battery.CFrame = hrp.CFrame * CFrame.new(0, 0.35, 0)
	local wb = Instance.new("WeldConstraint", battery)
	wb.Part0 = frameCenter wb.Part1 = battery

	local camPod = Instance.new("Part", drone)
	camPod.Size = Vector3.new(0.5, 0.4, 0.45)
	camPod.Color = Color3.fromRGB(255, 45, 75)
	camPod.Material = Enum.Material.Neon
	camPod.CanCollide = false
	camPod.Massless = true
	camPod.CFrame = hrp.CFrame * CFrame.new(0, 0.08, -1.05)
	local wc = Instance.new("WeldConstraint", camPod)
	wc.Part0 = frameCenter wc.Part1 = camPod

	local offsets = {
		Vector3.new(-1.35, 0, -1.35), Vector3.new(1.35, 0, -1.35),
		Vector3.new(-1.35, 0,  1.35), Vector3.new(1.35, 0,  1.35)
	}
	for _, off in ipairs(offsets) do
		local arm = Instance.new("Part", drone)
		arm.Size = Vector3.new(1.75, 0.16, 0.24)
		arm.Color = Color3.fromRGB(45, 45, 55)
		arm.CanCollide = false
		arm.Massless = true
		arm.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + off) * CFrame.new(0, 0, -off.Magnitude * 0.5) * CFrame.Angles(0, math.rad(90), 0)
		local wa = Instance.new("WeldConstraint", arm)
		wa.Part0 = frameCenter wa.Part1 = arm

		local rotor = Instance.new("Part", drone)
		rotor.Shape = Enum.PartType.Cylinder
		rotor.Size = Vector3.new(0.08, 1.35, 1.35)
		rotor.Material = Enum.Material.Neon
		rotor.Color = Color3.fromRGB(0, 235, 255)
		rotor.Transparency = 0.25
		rotor.CanCollide = false
		rotor.Massless = true
		rotor.CFrame = (hrp.CFrame * CFrame.new(off + Vector3.new(0, 0.22, 0))) * CFrame.Angles(0, 0, math.rad(90))
		local wr = Instance.new("WeldConstraint", rotor)
		wr.Part0 = frameCenter wr.Part1 = rotor
	end
end

SetDroneToggleUI = AddToggle(RageScroll, "FPV Kamikaze Drone (Replace Body & Fly)", Config.Rage.FPVDrone, function(v)
	Config.Rage.FPVDrone = v
	if v then StartFPVDrone() else StopFPVDrone(nil) end
end)

AddToggle(RageScroll, "SpeedHack", Config.Rage.SpeedHack, function(v) Config.Rage.SpeedHack = v end)
AddSlider(RageScroll, "WalkSpeed", 16, 100, Config.Rage.WalkSpeed, false, function(v) Config.Rage.WalkSpeed = v end)
AddToggle(RageScroll, "Big Jump", Config.Rage.BigJump, function(v) Config.Rage.BigJump = v end)
AddSlider(RageScroll, "JumpPower", 50, 200, Config.Rage.JumpPower, false, function(v) Config.Rage.JumpPower = v end)
AddToggle(RageScroll, "Pixel Surf (Wall Climb)", Config.Rage.PixelSurf, function(v) Config.Rage.PixelSurf = v end)
AddToggle(RageScroll, "Noclip (Walk Through Walls)", Config.Rage.Noclip, function(v) Config.Rage.Noclip = v end)

AddSectionLabel(RageScroll, "Combat Mods & Automation")
AddToggle(RageScroll, "Godmode", Config.Rage.Godmode, function(v) Config.Rage.Godmode = v end)
AddToggle(RageScroll, "Invisible Character", Config.Rage.Invisible, function(v)
	Config.Rage.Invisible = v
	if not v and LocalPlayer.Character then
		for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
			if (p:IsA("BasePart") or p:IsA("Decal")) and p.Name ~= "HumanoidRootPart" then
				p.Transparency = 0
			end
		end
	end
end)
AddToggle(RageScroll, "Color Knife", Config.Rage.ColorKnife, function(v)
	Config.Rage.ColorKnife = v RefreshEquippedSkins()
end, Config.Rage.KnifeColor, function(c) Config.Rage.KnifeColor = c RefreshEquippedSkins() end)

AddToggle(RageScroll, "Custom Knife (Neon Part)", Config.Rage.CustomKnife, function(v)
	Config.Rage.CustomKnife = v RefreshEquippedSkins()
end, Config.Rage.CustomKnifeColor, function(c) Config.Rage.CustomKnifeColor = c RefreshEquippedSkins() end)

AddToggle(RageScroll, "Auto-Farm Coins", Config.Rage.AutoFarm, function(v) Config.Rage.AutoFarm = v end)
AddToggle(RageScroll, "Auto Grab Dropped Gun", Config.Rage.AutoGrabGun, function(v) Config.Rage.AutoGrabGun = v end)
AddToggle(RageScroll, "Big HitBox Expander", Config.Rage.BigHitbox, function(v) Config.Rage.BigHitbox = v end)
AddSlider(RageScroll, "HitBox Size", 4, 28, Config.Rage.HitboxSize, false, function(v) Config.Rage.HitboxSize = v end)

-------------------------------------------------------------------------
-- ВКЛАДКА CONFIGS (МЕНЕДЖЕР КОНФИГУРАЦИЙ И ПРЕСЕТОВ)
-------------------------------------------------------------------------
local ConfigsScroll = CreateScrollContainer(Pages.CONFIGS, 0)
AddSectionLabel(ConfigsScroll, "Create & Manage Custom Configurations")

local ConfigFolder = "MonoSquat_Configs"
pcall(function()
	if makefolder and isfolder and not isfolder(ConfigFolder) then
		makefolder(ConfigFolder)
	end
end)

local ConfigInputRow = Instance.new("Frame", ConfigsScroll)
ConfigInputRow.LayoutOrder = NextOrder()
ConfigInputRow.Size = UDim2.new(1, -6, 0, 26)
ConfigInputRow.BackgroundColor3 = Color3.fromRGB(15, 15, 19)
Instance.new("UICorner", ConfigInputRow).CornerRadius = UDim.new(0, 5)

local ConfigNameBox = Instance.new("TextBox", ConfigInputRow)
ConfigNameBox.Size = UDim2.new(1, -16, 1, 0)
ConfigNameBox.Position = UDim2.new(0, 8, 0, 0)
ConfigNameBox.BackgroundTransparency = 1
ConfigNameBox.PlaceholderText = "Enter config name (e.g. LegitMain)..."
ConfigNameBox.Text = "Default"
ConfigNameBox.Font = Enum.Font.GothamMedium
ConfigNameBox.TextSize = 9
ConfigNameBox.TextXAlignment = Enum.TextXAlignment.Left
ConfigNameBox.ClearTextOnFocus = false

local ConfigStatusLbl = Instance.new("TextLabel", ConfigsScroll)
ConfigStatusLbl.LayoutOrder = NextOrder()
ConfigStatusLbl.Size = UDim2.new(1, -6, 0, 16)
ConfigStatusLbl.BackgroundTransparency = 1
ConfigStatusLbl.Text = "Status: Ready"
ConfigStatusLbl.Font = Enum.Font.GothamBold
ConfigStatusLbl.TextSize = 8
ConfigStatusLbl.TextXAlignment = Enum.TextXAlignment.Left

RegisterThemeUpdater(function(th)
	ConfigInputRow.BackgroundColor3 = th.RowBg
	ConfigNameBox.TextColor3 = th.TextPrimary
	ConfigNameBox.PlaceholderColor3 = th.TextSecondary
	ConfigStatusLbl.TextColor3 = th.TextSecondary
end)

local function SerializeTable(tbl)
	local out = {}
	for k, v in pairs(tbl) do
		if typeof(v) == "Color3" then
			out[k] = { __color = { v.R, v.G, v.B } }
		elseif type(v) == "table" then
			out[k] = SerializeTable(v)
		elseif type(v) == "number" or type(v) == "string" or type(v) == "boolean" then
			out[k] = v
		end
	end
	return out
end

local function DeserializeTable(src, dst)
	for k, v in pairs(src) do
		if type(v) == "table" and v.__color then
			dst[k] = Color3.new(v.__color[1], v.__color[2], v.__color[3])
		elseif type(v) == "table" and type(dst[k]) == "table" then
			DeserializeTable(v, dst[k])
		elseif dst[k] ~= nil then
			dst[k] = v
		end
	end
end

local MemoryConfigs = {}

local function AddActionButton(parent, labelText, callback)
	local b = Instance.new("TextButton", parent)
	b.LayoutOrder = NextOrder()
	b.Size = UDim2.new(1, -6, 0, 24)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 9
	b.Text = labelText
	b.AutoButtonColor = false
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
	RegisterThemeUpdater(function(th)
		b.BackgroundColor3 = th.RowBg
		b.TextColor3 = th.TextPrimary
	end)
	b.MouseButton1Click:Connect(function()
		PlayUISound(6895079853, 1.3, 0.4)
		callback()
	end)
	return b
end

AddActionButton(ConfigsScroll, "SAVE CONFIG TO FILE / MEMORY", function()
	local name = (ConfigNameBox.Text ~= "" and ConfigNameBox.Text) or "Default"
	local encoded = HttpService:JSONEncode(SerializeTable(Config))
	MemoryConfigs[name] = encoded
	local savedDisk = false
	pcall(function()
		if writefile then
			writefile(ConfigFolder .. "/" .. name .. ".json", encoded)
			savedDisk = true
		end
	end)
	ConfigStatusLbl.Text = "Status: Saved '" .. name .. "'" .. (savedDisk and " (Disk)" or " (Memory)")
end)

AddActionButton(ConfigsScroll, "LOAD CONFIG FROM FILE / MEMORY", function()
	local name = (ConfigNameBox.Text ~= "" and ConfigNameBox.Text) or "Default"
	local raw = MemoryConfigs[name]
	pcall(function()
		if readfile and isfile and isfile(ConfigFolder .. "/" .. name .. ".json") then
			raw = readfile(ConfigFolder .. "/" .. name .. ".json")
		end
	end)
	if raw then
		local ok, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
		if ok and type(decoded) == "table" then
			DeserializeTable(decoded, Config)
			ApplyMenuTheme()
			RestoreLightingDefaults()
			ConfigStatusLbl.Text = "Status: Loaded '" .. name .. "' successfully!"
			return
		end
	end
	ConfigStatusLbl.Text = "Status: Config '" .. name .. "' not found"
end)

AddSectionLabel(ConfigsScroll, "Built-In Quick Presets")

AddActionButton(ConfigsScroll, "LOAD PRESET: LEGIT COMPETITIVE", function()
	Config.Aimbot.Enabled = true
	Config.Aimbot.Smooth = 0.18
	Config.Aimbot.FOV = 95
	Config.ESP.Enabled = true
	Config.ESP.Box = true
	Config.ESP.Weapon = true
	Config.ESP.GunDropESP = true
	ConfigStatusLbl.Text = "Status: Applied Preset [Legit Competitive]"
end)

AddActionButton(ConfigsScroll, "LOAD PRESET: RAGE / HVH MAX", function()
	Config.SilentAim.Enabled = true
	Config.SilentAim.WallShot = true
	Config.SilentAim.Resolver = true
	Config.SilentAim.BulletImpacts = true
	Config.Rage.AntiAim = true
	Config.Rage.SpeedHack = true
	Config.ESP.Enabled = true
	Config.ESP.Chams = true
	Config.ESP.ChamsStyle = "Lava"
	ConfigStatusLbl.Text = "Status: Applied Preset [Rage / HvH]"
end)

AddActionButton(ConfigsScroll, "LOAD PRESET: AESTHETIC SHADERS", function()
	Config.Visuals.Bloom = true
	Config.Visuals.CustomSky = true
	Config.Visuals.Fullbright = true
	Config.Visuals.LocalChams = true
	Config.Visuals.LocalChamsStyle = "Chroma"
	Config.Visuals.ViewmodelChams = true
	CustomBloom.Enabled = true
	CustomSkyCC.Enabled = true
	ConfigStatusLbl.Text = "Status: Applied Preset [Aesthetic Shaders]"
end)

-------------------------------------------------------------------------
-- ФИЗИКА, SILENT AIM, GUN DROP ESP, LAVA CHAMS И ЦИКЛЫ
-------------------------------------------------------------------------
local SavedVelocity = Vector3.zero
local IsFlingSpoofing = false

RunService.Heartbeat:Connect(function()
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	if Config.Rage.Fling then
		SavedVelocity = hrp.AssemblyLinearVelocity
		IsFlingSpoofing = true
		local pow = Config.Rage.FlingPower
		hrp.AssemblyLinearVelocity = SavedVelocity * 0.2 + Vector3.new(
			math.random(-pow, pow),
			pow,
			math.random(-pow, pow)
		)
		hrp.AssemblyAngularVelocity = Vector3.new(pow, pow, pow)
	elseif IsFlingSpoofing then
		IsFlingSpoofing = false
		hrp.AssemblyAngularVelocity = Vector3.zero
	end
end)

RunService.RenderStepped:Connect(function()
	if IsFlingSpoofing then
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.AssemblyLinearVelocity = SavedVelocity
		end
	end
end)

pcall(function()
	if not hookmetamethod or not getnamecallmethod then return end
	local oldNamecall
	oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
		local method = getnamecallmethod()
		local args = { ... }

		if (method == "InvokeServer" or method == "FireServer") then
			local selfName = tostring(self.Name):lower()
			if selfName:find("shoot") or selfName:find("gun") or selfName:find("createbeam") then
				local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if Config.SilentAim.Enabled and math.random(1, 100) <= Config.SilentAim.HitChance then
					local visCheck = Config.SilentAim.VisibleOnly and (not Config.SilentAim.WallShot)
					local targetPart, targetPlr = GetClosestTarget(Config.SilentAim.FOV, visCheck, Config.SilentAim.HitboxPriority)
					if targetPart then
						local vel = GetResolvedVelocity(targetPlr, targetPart)
						local pred = targetPart.Position + (vel * Config.SilentAim.Prediction)
						if myHrp then CreateBulletTracer(myHrp.Position, pred) end
						CreateBulletImpact(pred)
						for i, arg in ipairs(args) do
							if typeof(arg) == "Vector3" then
								args[i] = pred
							elseif typeof(arg) == "CFrame" then
								args[i] = CFrame.new(pred)
							end
						end
						return oldNamecall(self, unpack(args))
					end
				elseif myHrp and Config.Visuals.BulletTracer then
					for _, arg in ipairs(args) do
						if typeof(arg) == "Vector3" then
							CreateBulletTracer(myHrp.Position, arg)
							CreateBulletImpact(arg)
							break
						end
					end
				end
			end
		end
		return oldNamecall(self, ...)
	end)
end)

local RainDrops = {}
for i = 1, 35 do
	local drop = Instance.new("Part")
	drop.Size = Vector3.new(0.08, 2.6, 0.08)
	drop.Anchored = true
	drop.CanCollide = false
	drop.Material = Enum.Material.Neon
	drop.Transparency = 1
	drop.Parent = Workspace
	table.insert(RainDrops, { Part = drop, Offset = Vector3.new(math.random(-45, 45), math.random(5, 45), math.random(-45, 45)) })
end

task.spawn(function()
	while task.wait(0.22) do
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then
			if Config.Rage.AutoGrabGun then
				local gunDrop = Workspace:FindFirstChild("GunDrop", true)
				if gunDrop and gunDrop:IsA("BasePart") then
					local savedCF = hrp.CFrame
					hrp.CFrame = gunDrop.CFrame
					task.wait(0.14)
					hrp.CFrame = savedCF
				end
			end
			if Config.Rage.AutoFarm then
				local coinContainer = Workspace:FindFirstChild("CoinContainer", true)
				if coinContainer then
					local nearestCoin, minDist = nil, 250
					for _, c in ipairs(coinContainer:GetChildren()) do
						local coinPart = c:IsA("BasePart") and c or c:FindFirstChildWhichIsA("BasePart")
						if coinPart and coinPart.Transparency < 1 then
							local d = (coinPart.Position - hrp.Position).Magnitude
							if d < minDist then
								minDist = d nearestCoin = coinPart
							end
						end
					end
					if nearestCoin then
						hrp.CFrame = CFrame.new(nearestCoin.Position + Vector3.new(0, 1.5, 0))
						if firetouchinterest then
							pcall(function()
								firetouchinterest(hrp, nearestCoin, 0)
								firetouchinterest(hrp, nearestCoin, 1)
							end)
						end
					end
				end
			end
		end
	end
end)

-- GUN DROP ESP & COIN ESP ОБЪЕКТЫ
local GunEspHighlight = Instance.new("Highlight", CoreGui)
GunEspHighlight.Name = "MonoGunDropHighlight"
GunEspHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
GunEspHighlight.Enabled = false

local GunEspLabel = Instance.new("TextLabel", EspFolder)
GunEspLabel.Size = UDim2.new(0, 160, 0, 16)
GunEspLabel.AnchorPoint = Vector2.new(0.5, 0.5)
GunEspLabel.BackgroundTransparency = 1
GunEspLabel.Font = Enum.Font.GothamBold
GunEspLabel.TextSize = 10
GunEspLabel.TextStrokeTransparency = 0.2
GunEspLabel.Visible = false

local CoinEspLabel = Instance.new("TextLabel", EspFolder)
CoinEspLabel.Size = UDim2.new(0, 140, 0, 14)
CoinEspLabel.AnchorPoint = Vector2.new(0.5, 0.5)
CoinEspLabel.BackgroundTransparency = 1
CoinEspLabel.Font = Enum.Font.GothamBold
CoinEspLabel.TextSize = 9
CoinEspLabel.TextStrokeTransparency = 0.25
CoinEspLabel.Visible = false

local EspNodes = {}
local LastTriggerShot = 0
local AimDelayStart = 0

local function CreateEspNode(plr)
	local holder = Instance.new("Frame", EspFolder)
	holder.BackgroundTransparency = 1
	holder.Visible = false

	local boxStroke = Instance.new("UIStroke", holder)
	boxStroke.Thickness = 1.3

	local hpBg = Instance.new("Frame", holder)
	hpBg.Size = UDim2.new(0, 3, 1, 0)
	hpBg.Position = UDim2.new(0, -6, 0, 0)
	hpBg.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	hpBg.BorderSizePixel = 0

	local hpFill = Instance.new("Frame", hpBg)
	hpFill.Size = UDim2.new(1, 0, 1, 0)
	hpFill.AnchorPoint = Vector2.new(0, 1)
	hpFill.Position = UDim2.new(0, 0, 1, 0)
	hpFill.BorderSizePixel = 0

	local nameTag = Instance.new("TextLabel", holder)
	nameTag.Size = UDim2.new(0, 180, 0, 13)
	nameTag.AnchorPoint = Vector2.new(0.5, 1)
	nameTag.Position = UDim2.new(0.5, 0, 0, -14)
	nameTag.BackgroundTransparency = 1
	nameTag.Font = Enum.Font.GothamBold
	nameTag.TextSize = 9
	nameTag.TextStrokeTransparency = 0.25

	local metaTag = Instance.new("TextLabel", holder)
	metaTag.Size = UDim2.new(0, 180, 0, 12)
	metaTag.AnchorPoint = Vector2.new(0.5, 1)
	metaTag.Position = UDim2.new(0.5, 0, 0, -2)
	metaTag.BackgroundTransparency = 1
	metaTag.Font = Enum.Font.GothamMedium
	metaTag.TextSize = 8
	metaTag.TextStrokeTransparency = 0.25

	local wepTag = Instance.new("TextLabel", holder)
	wepTag.Size = UDim2.new(0, 180, 0, 13)
	wepTag.AnchorPoint = Vector2.new(0.5, 0)
	wepTag.Position = UDim2.new(0.5, 0, 1, 2)
	wepTag.BackgroundTransparency = 1
	wepTag.Font = Enum.Font.GothamBold
	wepTag.TextSize = 8
	wepTag.TextStrokeTransparency = 0.25

	local snapline = Instance.new("Frame", EspFolder)
	snapline.AnchorPoint = Vector2.new(0.5, 0.5)
	snapline.BorderSizePixel = 0
	snapline.Visible = false

	local lookLine = Instance.new("Frame", EspFolder)
	lookLine.AnchorPoint = Vector2.new(0.5, 0.5)
	lookLine.BorderSizePixel = 0
	lookLine.Visible = false

	EspNodes[plr] = {
		Holder = holder, BoxStroke = boxStroke, HpBg = hpBg, HpFill = hpFill,
		NameTag = nameTag, MetaTag = metaTag, WepTag = wepTag,
		Snapline = snapline, LookLine = lookLine
	}
end

local function Draw2DLine(lineFrame, p1, p2, col, thickness)
	local delta = p2 - p1
	local dist = delta.Magnitude
	if dist < 1 then
		lineFrame.Visible = false
		return
	end
	local center = (p1 + p2) * 0.5
	lineFrame.Visible = true
	lineFrame.BackgroundColor3 = col
	lineFrame.Size = UDim2.new(0, dist, 0, thickness or 1)
	lineFrame.Position = UDim2.new(0, center.X, 0, center.Y)
	lineFrame.Rotation = math.deg(math.atan2(delta.Y, delta.X))
end

Players.PlayerRemoving:Connect(function(plr)
	if EspNodes[plr] then
		EspNodes[plr].Holder:Destroy()
		EspNodes[plr].Snapline:Destroy()
		EspNodes[plr].LookLine:Destroy()
		EspNodes[plr] = nil
	end
	if plr.Character and ChamsHighlights[plr.Character] then
		ChamsHighlights[plr.Character]:Destroy()
		ChamsHighlights[plr.Character] = nil
	end
end)

RunService.Stepped:Connect(function()
	local char = LocalPlayer.Character
	if not char then return end

	if Config.Rage.Noclip or Config.Rage.Fling or Config.Rage.FPVDrone then
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide = false end
		end
	end

	if Config.Rage.FPVDrone or Config.Visuals.CustomModel ~= "None" or Config.Rage.Invisible then
		for _, p in ipairs(char:GetDescendants()) do
			if (p:IsA("BasePart") or p:IsA("Decal")) and p.Name ~= "HumanoidRootPart" then
				if not p:FindFirstAncestor("MM2_FPV_Drone") and not p:FindFirstAncestor("MM2_CustomRig") and not p:FindFirstAncestorOfClass("Tool") then
					p.Transparency = Config.Rage.Invisible and 0.7 or 1
				end
			end
		end
	end

	if Config.Rage.Godmode then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health > 0 and hum.Health < hum.MaxHealth then
			hum.Health = hum.MaxHealth
		end
	end
end)

RunService.RenderStepped:Connect(function(dt)
	local cam = Workspace.CurrentCamera
	if not cam then return end

	if MainFrame.Visible and SharedPreviewPanel.Visible then
		if not DummyDragging then
			DummyYaw = DummyYaw + dt * 0.55
		end
		local camCF = CFrame.fromEulerAnglesYXZ(DummyPitch, DummyYaw, 0) * CFrame.new(0, 0, DummyZoom)
		EspVpCam.CFrame = CFrame.lookAt(camCF.Position, Vector3.new(0, 0.1, 0))

		local showChamsOnDummy = (CurrentPageName == "ESP" and Config.ESP.Chams) or (CurrentPageName == "VISUALS" and Config.Visuals.LocalChams)
		local dummyStyle = (CurrentPageName == "ESP") and Config.ESP.ChamsStyle or Config.Visuals.LocalChamsStyle
		local dummyCol = (CurrentPageName == "ESP") and Config.ESP.ChamsColor or Config.Visuals.LocalChamsColor
		ApplyChamsToCharacter(PreviewDummy, showChamsOnDummy, dummyStyle, dummyCol, true)

		PrevEspBox.Visible = Config.ESP.Enabled
		PrevBoxStroke.Enabled = Config.ESP.Box
		PrevBoxStroke.Color = Config.ESP.BoxColor
		PrevHpBg.Visible = Config.ESP.HealthBar
		PrevHpFill.BackgroundColor3 = Config.ESP.HealthColor
		PrevNameLbl.Visible = Config.ESP.Nickname
		PrevNameLbl.TextColor3 = Config.ESP.NicknameColor

		local mParts = {}
		if Config.ESP.Device then table.insert(mParts, "[PC]") end
		if Config.ESP.Ping then table.insert(mParts, "24ms") end
		if Config.ESP.Distance then table.insert(mParts, "12m") end
		PrevMetaLbl.Visible = (#mParts > 0)
		PrevMetaLbl.Text = table.concat(mParts, " ")
		PrevMetaLbl.TextColor3 = Config.ESP.PingColor

		PrevWepLbl.Visible = Config.ESP.Weapon
		PrevWepLbl.TextColor3 = Config.ESP.WeaponColor
	end

	local mousePos = UserInputService:GetMouseLocation()

	AimFovCircle.Visible = Config.Aimbot.DrawFOV
	AimFovCircle.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y)
	AimFovCircle.Size = UDim2.new(0, Config.Aimbot.FOV * 2, 0, Config.Aimbot.FOV * 2)

	SilentFovCircle.Visible = Config.SilentAim.DrawFOV
	SilentFovCircle.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y)
	SilentFovCircle.Size = UDim2.new(0, Config.SilentAim.FOV * 2, 0, Config.SilentAim.FOV * 2)

	local aimActive = Config.Aimbot.AlwaysActive or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or UserInputService.TouchEnabled
	if Config.Aimbot.Enabled and aimActive then
		local target = GetClosestTarget(Config.Aimbot.FOV, Config.Aimbot.VisibleOnly, Config.Aimbot.Hitbox)
		if target then
			if AimDelayStart == 0 then AimDelayStart = tick() end
			if (tick() - AimDelayStart) >= Config.Aimbot.Delay then
				local goalCF = CFrame.lookAt(cam.CFrame.Position, target.Position)
				cam.CFrame = cam.CFrame:Lerp(goalCF, math.clamp(Config.Aimbot.Smooth, 0.02, 1))
			end
		else
			AimDelayStart = 0
		end
	else
		AimDelayStart = 0
	end

	if Config.TriggerBot.Enabled and (tick() - LastTriggerShot) >= Config.TriggerBot.Delay then
		local myChar = LocalPlayer.Character
		local tool = myChar and myChar:FindFirstChildOfClass("Tool")
		if tool then
			local unitRay = cam:ViewportPointToRay(mousePos.X, mousePos.Y)
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = { myChar, cam }
			local hit = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 250, params)
			if hit and hit.Instance then
				local hitPlr = Players:GetPlayerFromCharacter(hit.Instance:FindFirstAncestorOfClass("Model"))
				if hitPlr and ShouldTarget(hitPlr) then
					LastTriggerShot = tick()
					tool:Activate()
				end
			end
		end
	end

	-- ОБРАБОТКА МИРОВЫХ ШЕЙДЕРОВ (FULLBRIGHT, NIGHT MODE, CUSTOM SKY FIX)
	if Config.Visuals.Fullbright then
		Lighting.Ambient = Config.Visuals.FullbrightColor
		Lighting.OutdoorAmbient = Config.Visuals.FullbrightColor
		Lighting.Brightness = 2.6
		Lighting.ClockTime = 14
	elseif Config.Visuals.NightMode then
		Lighting.Ambient = Color3.fromRGB(16, 18, 28)
		Lighting.OutdoorAmbient = Color3.fromRGB(16, 18, 28)
		Lighting.Brightness = 0.45
		Lighting.ClockTime = 0
	end

	if Config.Visuals.CustomSky then
		CustomSkyCC.Enabled = true
		CustomSkyCC.TintColor = Config.Visuals.SkyColor
		if not Config.Visuals.Fullbright and not Config.Visuals.NightMode then
			Lighting.Ambient = Config.Visuals.SkyColor
			Lighting.OutdoorAmbient = Config.Visuals.SkyColor
		end
		local atm = Lighting:FindFirstChildOfClass("Atmosphere")
		if atm then
			atm.Color = Config.Visuals.SkyColor
			atm.Decay = Config.Visuals.SkyColor
		end
	else
		CustomSkyCC.Enabled = false
	end

	if Config.Visuals.Fog then
		Lighting.FogColor = Config.Visuals.FogColor
		Lighting.FogEnd = Config.Visuals.FogEnd
		Lighting.FogStart = 10
	end

	local myChar = LocalPlayer.Character
	local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
	local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")

	for _, dropInfo in ipairs(RainDrops) do
		if Config.Visuals.Rain and myHrp then
			dropInfo.Part.Transparency = 0.25
			dropInfo.Part.Color = Config.Visuals.RainColor
			local y = ((dropInfo.Offset.Y - (tick() * 38)) % 45)
			dropInfo.Part.Position = myHrp.Position + Vector3.new(dropInfo.Offset.X, y, dropInfo.Offset.Z)
		else
			dropInfo.Part.Transparency = 1
		end
	end

	if myChar and Config.Visuals.LocalChams then
		ApplyChamsToCharacter(myChar, true, Config.Visuals.LocalChamsStyle, Config.Visuals.LocalChamsColor, false)
	end
	ApplyViewmodelAndWeaponChams()

	-- GUN DROP ESP & CHAMS
	local gunDrop = Workspace:FindFirstChild("GunDrop", true)
	if Config.ESP.GunDropESP and gunDrop and gunDrop:IsA("BasePart") then
		GunEspHighlight.Adornee = gunDrop
		GunEspHighlight.FillColor = Config.ESP.GunDropColor
		GunEspHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		GunEspHighlight.FillTransparency = 0.25
		GunEspHighlight.Enabled = true

		local gPos, onScr = cam:WorldToViewportPoint(gunDrop.Position + Vector3.new(0, 1.4, 0))
		if onScr then
			local dist = myHrp and math.floor((gunDrop.Position - myHrp.Position).Magnitude) or 0
			GunEspLabel.Visible = true
			GunEspLabel.Position = UDim2.new(0, gPos.X, 0, gPos.Y)
			GunEspLabel.TextColor3 = Config.ESP.GunDropColor
			GunEspLabel.Text = "★ DROPPED GUN [" .. tostring(dist) .. "m] ★"
		else
			GunEspLabel.Visible = false
		end
	else
		GunEspHighlight.Enabled = false
		GunEspLabel.Visible = false
	end

	-- COIN ESP
	if Config.ESP.CoinESP and myHrp then
		local coinContainer = Workspace:FindFirstChild("CoinContainer", true)
		local nearestCoin, minD = nil, 300
		if coinContainer then
			for _, c in ipairs(coinContainer:GetChildren()) do
				local cp = c:IsA("BasePart") and c or c:FindFirstChildWhichIsA("BasePart")
				if cp and cp.Transparency < 1 then
					local d = (cp.Position - myHrp.Position).Magnitude
					if d < minD then minD = d nearestCoin = cp end
				end
			end
		end
		if nearestCoin then
			local cPos, onScr = cam:WorldToViewportPoint(nearestCoin.Position)
			if onScr then
				CoinEspLabel.Visible = true
				CoinEspLabel.Position = UDim2.new(0, cPos.X, 0, cPos.Y)
				CoinEspLabel.TextColor3 = Config.ESP.CoinESPColor
				CoinEspLabel.Text = "● COIN [" .. tostring(math.floor(minD)) .. "m]"
			else
				CoinEspLabel.Visible = false
			end
		else
			CoinEspLabel.Visible = false
		end
	else
		CoinEspLabel.Visible = false
	end

	if myHrp and myHum then
		if Config.Rage.SpeedHack then myHum.WalkSpeed = Config.Rage.WalkSpeed end
		if Config.Rage.BigJump then
			myHum.UseJumpPower = true
			myHum.JumpPower = Config.Rage.JumpPower
		end

		if Config.Rage.AntiAim and not Config.Rage.Fling and not Config.Rage.Fly and not Config.Rage.FPVDrone then
			myHum.AutoRotate = false
			local pos = myHrp.Position
			local camLook = cam.CFrame.LookVector
			local baseYaw = math.atan2(-camLook.X, -camLook.Z)
			local yawOffset = 0

			if Config.Rage.AntiAimYaw == "Spin" then
				yawOffset = math.rad((tick() * Config.Rage.AntiAimSpeed * 12) % 360)
			elseif Config.Rage.AntiAimYaw == "Jitter" then
				local side = (math.floor(tick() * Config.Rage.AntiAimSpeed) % 2 == 0) and 1 or -1
				yawOffset = math.rad(180 + side * Config.Rage.AntiAimAngle * 0.5)
			elseif Config.Rage.AntiAimYaw == "Backwards" then
				yawOffset = math.rad(180)
			elseif Config.Rage.AntiAimYaw == "Random" then
				yawOffset = math.rad(math.random(-180, 180))
			elseif Config.Rage.AntiAimYaw == "Static" then
				yawOffset = math.rad(Config.Rage.AntiAimAngle)
			end

			local pitchAngle = 0
			if Config.Rage.AntiAimPitch == "Down" then
				pitchAngle = math.rad(-55)
			elseif Config.Rage.AntiAimPitch == "Up" then
				pitchAngle = math.rad(55)
			elseif Config.Rage.AntiAimPitch == "Jitter" then
				pitchAngle = math.rad((math.floor(tick() * 22) % 2 == 0) and 55 or -55)
			end

			myHrp.CFrame = CFrame.new(pos) * CFrame.Angles(0, baseYaw + yawOffset, 0)

			local waist = myChar:FindFirstChild("Waist", true) or myChar:FindFirstChild("Neck", true)
			if waist and waist:IsA("Motor6D") then
				waist.C0 = CFrame.new(waist.C0.Position) * CFrame.Angles(pitchAngle, 0, 0)
			end
		end

		if Config.Rage.PixelSurf then
			local rayParams = RaycastParams.new()
			rayParams.FilterType = Enum.RaycastFilterType.Exclude
			rayParams.FilterDescendantsInstances = { myChar }
			local wallHit = Workspace:Raycast(myHrp.Position, myHrp.CFrame.LookVector * 2.6, rayParams)
			if wallHit then
				myHrp.AssemblyLinearVelocity = Vector3.new(myHrp.AssemblyLinearVelocity.X, 28, myHrp.AssemblyLinearVelocity.Z)
			end
		end

		if Config.Rage.Fly or Config.Rage.FPVDrone then
			if not FlyBV or FlyBV.Parent ~= myHrp then
				if FlyBV then FlyBV:Destroy() end
				FlyBV = Instance.new("BodyVelocity")
				FlyBV.MaxForce = Vector3.new(1e8, 1e8, 1e8)
				FlyBV.Velocity = Vector3.zero
				FlyBV.Parent = myHrp
			end
			if not FlyBG or FlyBG.Parent ~= myHrp then
				if FlyBG then FlyBG:Destroy() end
				FlyBG = Instance.new("BodyGyro")
				FlyBG.MaxTorque = Vector3.new(1e8, 1e8, 1e8)
				FlyBG.P = 12000
				FlyBG.Parent = myHrp
			end

			myHum.PlatformStand = true
			local speed = Config.Rage.FPVDrone and Config.Rage.DroneSpeed or Config.Rage.FlySpeed
			local moveVec = Vector3.zero

			if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec - cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec - cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVec = moveVec + Vector3.new(0, 1, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveVec = moveVec - Vector3.new(0, 1, 0) end

			if myHum.MoveDirection.Magnitude > 0 and moveVec.Magnitude == 0 then
				moveVec = (cam.CFrame.LookVector * -myHum.MoveDirection.Z) + (cam.CFrame.RightVector * myHum.MoveDirection.X)
				if moveVec.Magnitude == 0 then moveVec = cam.CFrame.LookVector end
			end

			FlyBV.Velocity = moveVec.Magnitude > 0 and (moveVec.Unit * speed) or Vector3.zero
			local tilt = (Config.Rage.FPVDrone and moveVec.Magnitude > 0) and CFrame.Angles(math.rad(-18), 0, 0) or CFrame.identity
			FlyBG.CFrame = cam.CFrame * tilt

			if Config.Rage.FPVDrone then
				for _, other in ipairs(Players:GetPlayers()) do
					if other ~= LocalPlayer and other.Character and other.Character:FindFirstChild("HumanoidRootPart") then
						local oHrp = other.Character.HumanoidRootPart
						if (oHrp.Position - myHrp.Position).Magnitude < 5.0 then
							myHrp.AssemblyLinearVelocity = (oHrp.Position - myHrp.Position).Unit * 22000
							myHrp.AssemblyAngularVelocity = Vector3.new(20000, 20000, 20000)
							StopFPVDrone(myHrp.Position)
							break
						end
					end
				end
			end
		end
	end

	-- ЦИКЛ PLAYER ESP
	local vpSize = cam.ViewportSize
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			if not EspNodes[plr] then CreateEspNode(plr) end
			local node = EspNodes[plr]
			local char = plr.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local head = char and char:FindFirstChild("Head")
			local hum = char and char:FindFirstChildOfClass("Humanoid")

			if hrp then
				if Config.Rage.BigHitbox then
					hrp.Size = Vector3.new(Config.Rage.HitboxSize, Config.Rage.HitboxSize, Config.Rage.HitboxSize)
					hrp.Transparency = 0.65
					hrp.CanCollide = false
				else
					hrp.Size = Vector3.new(2, 2, 1)
					hrp.Transparency = 1
				end
			end

			if char and hum and hum.Health > 0 then
				ApplyChamsToCharacter(char, Config.ESP.Chams, Config.ESP.ChamsStyle, Config.ESP.ChamsColor, false)
			end

			if Config.ESP.Enabled and hrp and hum and hum.Health > 0 then
				local topPos, on1 = cam:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.8, 0))
				local botPos, on2 = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.2, 0))
				if on1 or on2 then
					local h = math.abs(botPos.Y - topPos.Y)
					local w = h * 0.62
					local role, weaponName = GetPlayerRoleAndWeapon(plr)

					node.Holder.Visible = true
					node.Holder.Position = UDim2.new(0, topPos.X - w / 2, 0, topPos.Y)
					node.Holder.Size = UDim2.new(0, w, 0, h)

					node.BoxStroke.Enabled = Config.ESP.Box
					node.BoxStroke.Color = Config.ESP.BoxColor

					node.HpBg.Visible = Config.ESP.HealthBar
					local hpRatio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
					node.HpFill.Size = UDim2.new(1, 0, hpRatio, 0)
					node.HpFill.BackgroundColor3 = Config.ESP.HealthColor

					node.NameTag.Visible = Config.ESP.Nickname
					node.NameTag.Text = plr.DisplayName .. " (@" .. plr.Name .. ")"
					node.NameTag.TextColor3 = Config.ESP.NicknameColor

					local metaParts = {}
					if Config.ESP.Device then
						local dev = (hum.MoveDirection.Magnitude > 0 and hum.MoveDirection.Magnitude < 0.98) and "MOB" or "PC"
						table.insert(metaParts, "[" .. dev .. "]")
					end
					if Config.ESP.Ping then
						local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000) + ((plr.UserId % 17) + 6)
						table.insert(metaParts, tostring(ping) .. "ms")
					end
					if Config.ESP.Distance and myHrp then
						local d = math.floor((hrp.Position - myHrp.Position).Magnitude)
						table.insert(metaParts, tostring(d) .. "m")
					end
					node.MetaTag.Visible = (#metaParts > 0)
					node.MetaTag.Text = table.concat(metaParts, " ")
					node.MetaTag.TextColor3 = Config.ESP.PingColor

					node.WepTag.Visible = Config.ESP.Weapon
					node.WepTag.Text = (weaponName ~= "") and (role:upper() .. " • " .. weaponName) or role:upper()
					if role == "Murderer" then
						node.WepTag.TextColor3 = Color3.fromRGB(255, 65, 85)
					elseif role == "Sheriff" then
						node.WepTag.TextColor3 = Color3.fromRGB(80, 185, 255)
					else
						node.WepTag.TextColor3 = Config.ESP.WeaponColor
					end

					if Config.ESP.Snaplines then
						Draw2DLine(node.Snapline, Vector2.new(vpSize.X / 2, vpSize.Y), Vector2.new(botPos.X, botPos.Y), Config.ESP.SnaplineColor, 1.2)
					else
						node.Snapline.Visible = false
					end

					if Config.ESP.LookLine and head then
						local h1, vis1 = cam:WorldToViewportPoint(head.Position)
						local h2, vis2 = cam:WorldToViewportPoint(head.Position + head.CFrame.LookVector * 4.5)
						if vis1 and vis2 then
							Draw2DLine(node.LookLine, Vector2.new(h1.X, h1.Y), Vector2.new(h2.X, h2.Y), Config.ESP.LookLineColor, 1.4)
						else
							node.LookLine.Visible = false
						end
					else
						node.LookLine.Visible = false
					end
				else
					node.Holder.Visible = false
					node.Snapline.Visible = false
					node.LookLine.Visible = false
				end
			else
				node.Holder.Visible = false
				node.Snapline.Visible = false
				node.LookLine.Visible = false
			end
		end
	end
end)

-------------------------------------------------------------------------
-- ХУКИ СПАВНА И ХИТСАУНДА
-------------------------------------------------------------------------
local function OnCharacterAdded(char)
	char.ChildAdded:Connect(function(tool) CheckCharacterTool(tool) end)
	task.spawn(function()
		local bp = LocalPlayer:WaitForChild("Backpack", 5)
		if bp then
			bp.ChildAdded:Connect(function(tool) CheckCharacterTool(tool) end)
		end
	end)
	task.delay(0.5, function()
		RefreshEquippedSkins()
		if Config.Visuals.CustomModel ~= "None" then
			BuildCustomCharacterModel(Config.Visuals.CustomModel)
		end
		if Config.Rage.FPVDrone then
			StartFPVDrone()
		end
	end)
end

if LocalPlayer.Character then OnCharacterAdded(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)

local function HookEnemyHealth(plr)
	if plr == LocalPlayer then return end
	local function onCharacter(char)
		local hum = char:WaitForChild("Humanoid", 5)
		if hum then
			local lastHealth = hum.Health
			hum:GetPropertyChangedSignal("Health"):Connect(function()
				if hum.Health < lastHealth and hum.Health > 0 then
					PlayCustomHitSound()
				end
				lastHealth = hum.Health
			end)
		end
	end
	if plr.Character then onCharacter(plr.Character) end
	plr.CharacterAdded:Connect(onCharacter)
end

for _, p in ipairs(Players:GetPlayers()) do HookEnemyHealth(p) end
Players.PlayerAdded:Connect(HookEnemyHealth)

local IsMenuOpen = true
Watermark.MouseButton1Click:Connect(function()
	IsMenuOpen = not IsMenuOpen
	if not IsMenuOpen then ColorPickerPopup.Visible = false end
	local th = GetTheme()
	if IsMenuOpen then
		PlayUISound(6895079853, 1.18, 0.5)
		MainFrame.Visible = true
		MainScale.Scale = 0.86
		tween(MainScale, 0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Scale = 1 })
		tween(WmDot, 0.2, nil, nil, { BackgroundColor3 = th.Accent })
	else
		PlayUISound(6895079853, 0.82, 0.45)
		local t = tween(MainScale, 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In, { Scale = 0.86 })
		tween(WmDot, 0.2, nil, nil, { BackgroundColor3 = th.TextSecondary })
		t.Completed:Connect(function()
			if not IsMenuOpen then MainFrame.Visible = false end
		end)
	end
end)

ApplyMenuTheme()
RefreshEquippedSkins()
RenderSkinList()
