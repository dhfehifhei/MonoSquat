local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

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
-- ГЛОБАЛЬНАЯ КОНФИГУРАЦИЯ (С ХИТСАУНДОМ)
-------------------------------------------------------------------------
local Config = {
	Aimbot = {
		Enabled = false,
		AlwaysActive = true,
		TeamCheck = false,
		VisibleOnly = false,
		DrawFOV = false,
		FOV = 120,
		FOVColor = Color3.fromRGB(255, 255, 255),
		Smooth = 0.22,
		Delay = 0.0
	},
	SilentAim = {
		Enabled = false,
		WallShot = false,
		DrawFOV = false,
		FOV = 150,
		FOVColor = Color3.fromRGB(185, 185, 255),
		HitChance = 100,
		VisibleOnly = false,
		Prediction = 0.135
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
		Box = true,          BoxColor = Color3.fromRGB(255, 255, 255),
		Nickname = true,     NicknameColor = Color3.fromRGB(255, 255, 255),
		HealthBar = true,    HealthColor = Color3.fromRGB(90, 255, 130),
		Weapon = true,       WeaponColor = Color3.fromRGB(255, 210, 90),
		Ping = true,         PingColor = Color3.fromRGB(160, 220, 255),
		Device = true,       DeviceColor = Color3.fromRGB(200, 160, 255),
		Chams = false,       ChamsColor = Color3.fromRGB(165, 95, 255),
		ChamsStyle = "ForceField"
	},
	Visuals = {
		Bloom = false,       BloomIntensity = 1.8,
		CustomSky = false,   SkyColor = Color3.fromRGB(25, 15, 55),
		Fog = false,         FogColor = Color3.fromRGB(35, 35, 50), FogEnd = 180,
		Rain = false,        RainColor = Color3.fromRGB(170, 205, 255),
		BulletTracer = false,TracerColor = Color3.fromRGB(255, 255, 255),
		LocalChams = false,  LocalChamsColor = Color3.fromRGB(140, 90, 255),
		LocalChamsStyle = "ForceField",
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
-- ФУНКЦИЯ ВОСПРОИЗВЕДЕНИЯ ХИТСАУНДА
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

-------------------------------------------------------------------------
-- КАСТОМНЫЕ ВЕКТОРНЫЕ ИКОНКИ (SVG-СТИЛЬ)
-------------------------------------------------------------------------
local function CreateVectorIcon(parent, iconType, size, pos, color)
	local container = Instance.new("Frame")
	container.Size = size or UDim2.new(0, 14, 0, 14)
	container.Position = pos or UDim2.new(0, 0, 0, 0)
	container.BackgroundTransparency = 1
	container.Parent = parent

	local function line(w, h, x, y, rot, corner)
		local f = Instance.new("Frame", container)
		f.Size = UDim2.new(w, 0, h, 0)
		f.Position = UDim2.new(x, 0, y, 0)
		f.AnchorPoint = Vector2.new(0.5, 0.5)
		f.Rotation = rot or 0
		f.BackgroundColor3 = color or Color3.fromRGB(255, 255, 255)
		f.BorderSizePixel = 0
		if corner then Instance.new("UICorner", f).CornerRadius = UDim.new(corner, 0) end
		return f
	end

	if iconType == "Logo" then
		local box = line(0.68, 0.68, 0.5, 0.5, 45, 0.15)
		box.BackgroundTransparency = 1
		local st = Instance.new("UIStroke", box)
		st.Color = color or Color3.fromRGB(255, 255, 255)
		st.Thickness = 1.4
		line(0.26, 0.26, 0.5, 0.5, 45, 0.1)
	elseif iconType == "Search" then
		local c = line(0.6, 0.6, 0.42, 0.42, 0, 1)
		c.BackgroundTransparency = 1
		local st = Instance.new("UIStroke", c)
		st.Color = color or Color3.fromRGB(160, 160, 160)
		st.Thickness = 1.3
		line(0.36, 0.12, 0.75, 0.75, 45, 1)
	elseif iconType == "Cube" then
		local c = line(0.74, 0.74, 0.5, 0.5, 0, 0.2)
		c.BackgroundTransparency = 1
		local st = Instance.new("UIStroke", c)
		st.Color = color or Color3.fromRGB(200, 200, 200)
		st.Thickness = 1.2
		line(0.3, 0.3, 0.5, 0.5, 45, 0.1)
	end
	return container
end

-------------------------------------------------------------------------
-- ЧТЕНИЕ БАЗЫ СКИНОВ MM2 И ЛОГИКА ПРИМЕНЕНИЯ (ПОДНЯТЫ НАВЕРХ)
-------------------------------------------------------------------------
local SkinsList = { Knife = {}, Gun = {}, Pet = {} }
local AddedKeys = { Knife = {}, Gun = {}, Pet = {} }
local SelectedSkins = { Knife = nil, Gun = nil, Pet = nil }
local AssetCache = {}
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
	local foundDB = false

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
							foundDB = true
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
				foundDB = true
			end
		end
	end

	if #SkinsList.Knife == 0 then
		local fallbackKnives = {
			"Corrupt", "Nik's Scythe", "Gingerscythe", "Batwing", "Icewing",
			"Elderwood Scythe", "Hallowscythe", "Logchopper", "Candy", "Heartblade",
			"Chroma Fang", "Chroma Heat", "Chroma Slasher", "Nightblade", "BioBlade"
		}
		for _, name in ipairs(fallbackKnives) do
			AddSkinToDB("Knife", name, name, nil, name:lower():find("chroma"))
		end
	end

	if #SkinsList.Gun == 0 then
		local fallbackGuns = {
			"Harvester", "Icepiercer", "Gingerscope", "Lightbringer", "Darkbringer",
			"Luger", "Chroma Luger", "Laser", "Chroma Laser", "Shark",
			"Amerilaser", "Blaster", "Sugar", "Elderwood Revolver", "Hallowgun"
		}
		for _, name in ipairs(fallbackGuns) do
			AddSkinToDB("Gun", name, name, nil, name:lower():find("chroma"))
		end
	end

	if #SkinsList.Pet == 0 then
		local fallbackPets = { "Fire Bat", "Fire Dog", "Phoenix", "Electro", "Sammy" }
		for _, name in ipairs(fallbackPets) do
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

local function LoadRealSkinPart(skinData)
	local key = skinData.Id .. "_" .. tostring(skinData.ItemID or "")
	if AssetCache[key] then return AssetCache[key]:Clone() end

	local sourceAsset = FindSkinAsset(skinData)
	if sourceAsset then
		local handle = sourceAsset:IsA("BasePart") and sourceAsset or sourceAsset:FindFirstChild("Handle") or sourceAsset:FindFirstChildWhichIsA("BasePart")
		if handle then
			local clean = handle:Clone()
			clean.Anchored = true
			clean.CanCollide = false
			clean.Transparency = 0
			AssetCache[key] = clean
			return clean:Clone()
		end
	end

	if skinData.ItemID then
		local ok, objects = pcall(function()
			return game:GetObjects("rbxassetid://" .. tostring(skinData.ItemID))
		end)
		if ok and objects and #objects > 0 then
			local rootObj = objects[1]
			local handle = rootObj:IsA("BasePart") and rootObj or rootObj:FindFirstChild("Handle", true) or rootObj:FindFirstChildWhichIsA("MeshPart", true) or rootObj:FindFirstChildWhichIsA("BasePart", true)
			if handle then
				local clean = handle:Clone()
				clean.Anchored = true
				clean.CanCollide = false
				clean.Transparency = 0
				AssetCache[key] = clean
				return clean:Clone()
			end
		end
	end
	return nil
end

local ActivePetModel = nil
local PetConn = nil

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
		for _, item in ipairs(char:GetChildren()) do
			CheckCharacterTool(item)
		end
	end
	local bp = LocalPlayer:FindFirstChild("Backpack")
	if bp then
		for _, item in ipairs(bp:GetChildren()) do
			CheckCharacterTool(item)
		end
	end
end

-------------------------------------------------------------------------
-- УТИЛИТА ЧАМСОВ ДЛЯ ИГРОКОВ И ВРАГОВ
-------------------------------------------------------------------------
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
					for _, tex in ipairs(part:GetChildren()) do
						if tex:IsA("SurfaceAppearance") or tex:IsA("SpecialMesh") or tex:IsA("Decal") then
							if tex:IsA("Decal") then tex.Transparency = 0 end
						end
					end
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
				SavedOriginalMaterials[char][p] = {
					Material = p.Material,
					Color = p.Color,
					Transparency = p.Transparency
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

	local targetMat = Enum.Material.ForceField
	local targetTrans = 0
	local useHighlight = false

	if style == "ForceField" then
		targetMat = Enum.Material.ForceField
		targetTrans = 0.05
	elseif style == "Solid" then
		targetMat = Enum.Material.SmoothPlastic
		targetTrans = 0
		useHighlight = true
	elseif style == "Glow" then
		targetMat = Enum.Material.Neon
		targetTrans = 0.05
		useHighlight = true
	elseif style == "Lava" then
		targetMat = Enum.Material.CrackedLava
		targetTrans = 0
	elseif style == "Ghost" then
		targetMat = Enum.Material.Glass
		targetTrans = 0.45
		useHighlight = true
	end

	for part, _ in pairs(SavedOriginalMaterials[char]) do
		if part and part.Parent then
			part.Material = targetMat
			part.Color = color
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
		hl.Enabled = useHighlight or (char ~= LocalPlayer.Character)
		hl.FillColor = color
		hl.OutlineColor = Color3.fromRGB(255, 255, 255)
		hl.FillTransparency = (style == "Solid") and 0.15 or 0.55
		hl.OutlineTransparency = (style == "Glow") and 0 or 0.25
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
Watermark.Size = UDim2.new(0, 122, 0, 26)
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

Watermark.MouseEnter:Connect(function()
	tween(WmStroke, 0.2, nil, nil, { Color = Color3.fromRGB(220, 220, 235) })
end)
Watermark.MouseLeave:Connect(function()
	tween(WmStroke, 0.2, nil, nil, { Color = Color3.fromRGB(65, 65, 75) })
end)

MakeDraggable(Watermark, Watermark)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 425, 0, 268)
MainFrame.Position = UDim2.new(0.5, -212, 0.5, -134)
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
ColorPickerPopup.Position = UDim2.new(0.5, 220, 0.5, -60)
ColorPickerPopup.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
ColorPickerPopup.Visible = false
ColorPickerPopup.ZIndex = 200
Instance.new("UICorner", ColorPickerPopup).CornerRadius = UDim.new(0, 7)
Instance.new("UIStroke", ColorPickerPopup).Color = Color3.fromRGB(80, 80, 95)
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
HeaderTitle.Size = UDim2.new(0, 85, 1, 0)
HeaderTitle.Position = UDim2.new(0, 25, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "MonoSquat"
HeaderTitle.TextColor3 = Color3.fromRGB(250, 250, 250)
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextSize = 10
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left

MakeDraggable(Header, MainFrame)

local NavHolder = Instance.new("Frame", Header)
NavHolder.Size = UDim2.new(0, 310, 0, 22)
NavHolder.Position = UDim2.new(1, -316, 0.5, -11)
NavHolder.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Instance.new("UICorner", NavHolder).CornerRadius = UDim.new(0, 5)

local NavIndicator = Instance.new("Frame", NavHolder)
NavIndicator.Size = UDim2.new(1 / 5, -2, 1, -2)
NavIndicator.Position = UDim2.new(0, 1, 0, 1)
NavIndicator.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
Instance.new("UICorner", NavIndicator).CornerRadius = UDim.new(0, 4)

local Pages = {}
local NavButtons = {}
local PageList = { "SKINS", "COMBAT", "ESP", "VISUALS", "RAGE" }
local CurrentPageName = "SKINS"

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
				TextColor3 = act and Color3.fromRGB(10, 10, 12) or Color3.fromRGB(150, 150, 160)
			})
		end

		if SharedPreviewPanel then
			SharedPreviewPanel.Visible = (pName == "ESP" or pName == "VISUALS")
		end
	end)
end

SharedPreviewPanel = Instance.new("Frame", MainFrame)
SharedPreviewPanel.Size = UDim2.new(0, 162, 1, -36)
SharedPreviewPanel.Position = UDim2.new(1, -168, 0, 33)
SharedPreviewPanel.BackgroundColor3 = Color3.fromRGB(13, 13, 16)
SharedPreviewPanel.Visible = false
SharedPreviewPanel.ZIndex = 10
Instance.new("UICorner", SharedPreviewPanel).CornerRadius = UDim.new(0, 7)
Instance.new("UIStroke", SharedPreviewPanel).Color = Color3.fromRGB(36, 36, 44)

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

local PreviewDummy = Instance.new("Model", EspWorld)
PreviewDummy.Name = "PreviewTarget"
local DummyParts = {}

local function makeDummyPart(name, size, cfOffset, color, shape)
	local p = Instance.new("Part", PreviewDummy)
	p.Name = name
	p.Size = size
	p.CFrame = cfOffset
	p.Anchored = true
	p.CanCollide = false
	p.Color = color or Color3.fromRGB(215, 215, 225)
	p.Material = Enum.Material.SmoothPlastic
	if shape then p.Shape = shape end
	table.insert(DummyParts, p)
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
		tween(EspVpStroke, 0.2, nil, nil, { Color = Color3.fromRGB(200, 200, 215) })
	end
end)
UserInputService.InputEnded:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
		DummyDragging = false
		tween(EspVpStroke, 0.2, nil, nil, { Color = Color3.fromRGB(30, 30, 36) })
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
EspViewport.MouseWheelForward:Connect(function()
	DummyZoom = math.clamp(DummyZoom - 0.45, 3.8, 10)
end)
EspViewport.MouseWheelBackward:Connect(function()
	DummyZoom = math.clamp(DummyZoom + 0.45, 3.8, 10)
end)

-------------------------------------------------------------------------
-- ГЕНЕРАТОРЫ UI-КОНТРОЛОВ (ПОЛНЫЙ ИСХОДНЫЙ НАБОР СТРОК)
-------------------------------------------------------------------------
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
end

local function AddToggle(parent, title, defaultVal, callback, defaultColor, colorCallback)
	local row = Instance.new("Frame", parent)
	row.LayoutOrder = NextOrder()
	row.Size = UDim2.new(1, -6, 0, 24)
	row.BackgroundColor3 = Color3.fromRGB(15, 15, 19)
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

	row.MouseEnter:Connect(function()
		tween(row, 0.16, nil, nil, { BackgroundColor3 = Color3.fromRGB(21, 21, 27) })
	end)
	row.MouseLeave:Connect(function()
		tween(row, 0.16, nil, nil, { BackgroundColor3 = Color3.fromRGB(15, 15, 19) })
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
	local function setState(newVal)
		state = newVal
		tween(box, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
			BackgroundColor3 = state and Color3.fromRGB(245, 245, 245) or Color3.fromRGB(32, 32, 38)
		})
		tween(knob, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
			Position = state and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5),
			BackgroundColor3 = state and Color3.fromRGB(10, 10, 12) or Color3.fromRGB(150, 150, 160)
		})
	end

	local function toggle()
		PlayUISound(6895079853, state and 0.95 or 1.2, 0.35)
		setState(not state)
		callback(state)
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

	btn.MouseButton1Click:Connect(function()
		PlayUISound(6895079853, 1.3, 0.35)
		idx = (idx % #options) + 1
		btn.Text = "  " .. title .. ":  [ " .. tostring(options[idx]) .. " ]"
		callback(options[idx])
	end)
	return btn
end

-------------------------------------------------------------------------
-- ИНТЕРАКТИВНОЕ ПОСТРОЕНИЕ ВКЛАДОК
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
Instance.new("UIStroke", SearchHolder).Color = Color3.fromRGB(32, 32, 38)
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
	for _, c in ipairs(SkinScroll:GetChildren()) do
		if c:IsA("TextButton") then c:Destroy() end
	end
	local q = SearchBox.Text:lower()
	for _, skin in ipairs(SkinsList[ActiveCategory] or {}) do
		if q == "" or skin.Name:lower():find(q, 1, true) then
			local isEq = (SelectedSkins[ActiveCategory] and SelectedSkins[ActiveCategory].Id == skin.Id)
			local btn = Instance.new("TextButton", SkinScroll)
			btn.BackgroundColor3 = isEq and Color3.fromRGB(245, 245, 250) or Color3.fromRGB(18, 18, 22)
			btn.Text = "  " .. skin.Name .. (isEq and "  [EQUIPPED]" or "")
			btn.TextColor3 = isEq and Color3.fromRGB(10, 10, 12) or Color3.fromRGB(230, 230, 235)
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

for cat, btn in pairs(SubTabBtns) do
	btn.MouseButton1Click:Connect(function()
		PlayUISound(6895079853, 1.25, 0.35)
		ActiveCategory = cat
		for c, b in pairs(SubTabBtns) do
			local act = (c == cat)
			tween(b, 0.18, nil, nil, {
				BackgroundColor3 = act and Color3.fromRGB(240, 240, 245) or Color3.fromRGB(15, 15, 18),
				TextColor3 = act and Color3.fromRGB(10, 10, 12) or Color3.fromRGB(140, 140, 150)
			})
		end
		RenderSkinList()
	end)
end
SearchBox:GetPropertyChangedSignal("Text"):Connect(RenderSkinList)

local CombatScroll = CreateScrollContainer(Pages.COMBAT, 0)
AddSectionLabel(CombatScroll, "Audio & Hitsound")
AddToggle(CombatScroll, "Enable Hit Sound", Config.HitSound.Enabled, function(v)
	Config.HitSound.Enabled = v
end)

AddSectionLabel(CombatScroll, "Camera AimBot")
AddToggle(CombatScroll, "Enable AimBot", Config.Aimbot.Enabled, function(v) Config.Aimbot.Enabled = v end)
AddToggle(CombatScroll, "Always Active (No Key Hold)", Config.Aimbot.AlwaysActive, function(v) Config.Aimbot.AlwaysActive = v end)
AddToggle(CombatScroll, "Enemy Role Only (Off = Target All)", Config.Aimbot.TeamCheck, function(v) Config.Aimbot.TeamCheck = v end)
AddToggle(CombatScroll, "Visible Only (WallCheck)", Config.Aimbot.VisibleOnly, function(v) Config.Aimbot.VisibleOnly = v end)
AddToggle(CombatScroll, "Draw AimBot FOV Circle", Config.Aimbot.DrawFOV, function(v) Config.Aimbot.DrawFOV = v end, Config.Aimbot.FOVColor, function(c)
	Config.Aimbot.FOVColor = c AimFovStroke.Color = c
end)
AddSlider(CombatScroll, "AimBot FOV Radius", 30, 360, Config.Aimbot.FOV, false, function(v) Config.Aimbot.FOV = v end)
AddSlider(CombatScroll, "AimBot Smoothness", 0.05, 1.0, Config.Aimbot.Smooth, true, function(v) Config.Aimbot.Smooth = v end)
AddSlider(CombatScroll, "AimBot Delay (s)", 0.0, 0.5, Config.Aimbot.Delay, true, function(v) Config.Aimbot.Delay = v end)

AddSectionLabel(CombatScroll, "Silent AimBot & WallShot")
AddToggle(CombatScroll, "Enable Silent Aim", Config.SilentAim.Enabled, function(v) Config.SilentAim.Enabled = v end)
AddToggle(CombatScroll, "WallShot (Shoot Through Walls)", Config.SilentAim.WallShot, function(v) Config.SilentAim.WallShot = v end)
AddToggle(CombatScroll, "Draw Silent FOV Circle", Config.SilentAim.DrawFOV, function(v) Config.SilentAim.DrawFOV = v end, Config.SilentAim.FOVColor, function(c)
	Config.SilentAim.FOVColor = c SilentFovStroke.Color = c
end)
AddSlider(CombatScroll, "Silent Aim FOV Radius", 40, 400, Config.SilentAim.FOV, false, function(v) Config.SilentAim.FOV = v end)
AddSlider(CombatScroll, "Silent Hit Chance (%)", 1, 100, Config.SilentAim.HitChance, false, function(v) Config.SilentAim.HitChance = v end)

AddSectionLabel(CombatScroll, "Trigger Bot")
AddToggle(CombatScroll, "Enable Trigger Bot", Config.TriggerBot.Enabled, function(v) Config.TriggerBot.Enabled = v end)
AddSlider(CombatScroll, "Trigger Delay (s)", 0.0, 0.4, Config.TriggerBot.Delay, true, function(v) Config.TriggerBot.Delay = v end)

local EspScroll = CreateScrollContainer(Pages.ESP, -168)
AddSectionLabel(EspScroll, "2D ESP & Enemy Material Chams")
AddToggle(EspScroll, "Enable Master ESP", Config.ESP.Enabled, function(v) Config.ESP.Enabled = v end)
AddToggle(EspScroll, "2D Box ESP", Config.ESP.Box, function(v) Config.ESP.Box = v end, Config.ESP.BoxColor, function(c) Config.ESP.BoxColor = c end)
AddToggle(EspScroll, "Player Nickname", Config.ESP.Nickname, function(v) Config.ESP.Nickname = v end, Config.ESP.NicknameColor, function(c) Config.ESP.NicknameColor = c end)
AddToggle(EspScroll, "Health Bar", Config.ESP.HealthBar, function(v) Config.ESP.HealthBar = v end, Config.ESP.HealthColor, function(c) Config.ESP.HealthColor = c end)
AddToggle(EspScroll, "Weapon & Role", Config.ESP.Weapon, function(v) Config.ESP.Weapon = v end, Config.ESP.WeaponColor, function(c) Config.ESP.WeaponColor = c end)
AddToggle(EspScroll, "Player Ping (ms)", Config.ESP.Ping, function(v) Config.ESP.Ping = v end, Config.ESP.PingColor, function(c) Config.ESP.PingColor = c end)
AddToggle(EspScroll, "Device Tag (PC / MOB)", Config.ESP.Device, function(v) Config.ESP.Device = v end, Config.ESP.DeviceColor, function(c) Config.ESP.DeviceColor = c end)
AddToggle(EspScroll, "Enemy Chams (Full Body)", Config.ESP.Chams, function(v) Config.ESP.Chams = v end, Config.ESP.ChamsColor, function(c) Config.ESP.ChamsColor = c end)
AddCycleButton(EspScroll, "Enemy Chams Style", {"ForceField", "Solid", "Glow", "Lava", "Ghost"}, 1, function(st)
	Config.ESP.ChamsStyle = st
end)

local VisScroll = CreateScrollContainer(Pages.VISUALS, -168)
AddSectionLabel(VisScroll, "Self Chams & Custom 3D Models")

AddToggle(VisScroll, "Local Player Chams", Config.Visuals.LocalChams, function(v)
	Config.Visuals.LocalChams = v
	if not v and LocalPlayer.Character then
		ApplyChamsToCharacter(LocalPlayer.Character, false, Config.Visuals.LocalChamsStyle, Config.Visuals.LocalChamsColor, false)
	end
end, Config.Visuals.LocalChamsColor, function(c) Config.Visuals.LocalChamsColor = c end)

AddCycleButton(VisScroll, "Local Chams Style", {"ForceField", "Solid", "Glow", "Lava", "Ghost"}, 1, function(st)
	Config.Visuals.LocalChamsStyle = st
end)

local ActiveCustomRig = nil
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
				if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
					p.Transparency = 0
				elseif p:IsA("Decal") then
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
		addRigPart(Vector3.new(0.85, 2.2, 0.85), CFrame.new(-1.6, 0, 0), Enum.Material.SmoothPlastic, Color3.fromRGB(32, 32, 40))
		addRigPart(Vector3.new(0.85, 2.2, 0.85), CFrame.new(1.6, 0, 0), Enum.Material.SmoothPlastic, Color3.fromRGB(32, 32, 40))
		addRigPart(Vector3.new(0.95, 2.2, 0.95), CFrame.new(-0.6, -2.0, 0), Enum.Material.SmoothPlastic, Color3.fromRGB(22, 22, 28))
		addRigPart(Vector3.new(0.95, 2.2, 0.95), CFrame.new(0.6, -2.0, 0), Enum.Material.SmoothPlastic, Color3.fromRGB(22, 22, 28))
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
	end
end

AddCycleButton(VisScroll, "Custom Model", {"None", "Cyber Mecha", "Shadow Fiend", "Angelic Core"}, 1, BuildCustomCharacterModel)

AddSectionLabel(VisScroll, "Atmosphere & World Shaders")
local CustomBloom = Lighting:FindFirstChild("MonoSquat") or Instance.new("BloomEffect", Lighting)
CustomBloom.Name = "MonoSquat"
CustomBloom.Enabled = false

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

local OrigAmbient, OrigOutdoor = Lighting.Ambient, Lighting.OutdoorAmbient
local OrigFogColor, OrigFogEnd = Lighting.FogColor, Lighting.FogEnd

AddToggle(VisScroll, "Custom Sky Color", Config.Visuals.CustomSky, function(v)
	Config.Visuals.CustomSky = v
	if not v then Lighting.Ambient = OrigAmbient Lighting.OutdoorAmbient = OrigOutdoor end
end, Config.Visuals.SkyColor, function(c) Config.Visuals.SkyColor = c end)

AddToggle(VisScroll, "Atmosphere Fog", Config.Visuals.Fog, function(v)
	Config.Visuals.Fog = v
	if not v then Lighting.FogColor = OrigFogColor Lighting.FogEnd = OrigFogEnd end
end, Config.Visuals.FogColor, function(c) Config.Visuals.FogColor = c end)
AddSlider(VisScroll, "Fog Distance", 40, 600, Config.Visuals.FogEnd, false, function(v) Config.Visuals.FogEnd = v end)

AddToggle(VisScroll, "3D Rain Particles", Config.Visuals.Rain, function(v) Config.Visuals.Rain = v end, Config.Visuals.RainColor, function(c) Config.Visuals.RainColor = c end)
AddToggle(VisScroll, "3D Bullet Tracers", Config.Visuals.BulletTracer, function(v) Config.Visuals.BulletTracer = v end, Config.Visuals.TracerColor, function(c) Config.Visuals.TracerColor = c end)

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

AddToggle(RageScroll, "Touch Fling (Launch Enemies on Contact)", Config.Rage.Fling, function(v)
	Config.Rage.Fling = v
end)
AddSlider(RageScroll, "Fling Launch Power", 8000, 35000, Config.Rage.FlingPower, false, function(v)
	Config.Rage.FlingPower = v
end)

AddSectionLabel(RageScroll, "Anti-Aim (Yaw & Pitch Spoofer)")
AddToggle(RageScroll, "Enable Anti-Aim", Config.Rage.AntiAim, function(v)
	Config.Rage.AntiAim = v
	if not v and LocalPlayer.Character then
		local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.AutoRotate = true end
	end
end)
AddCycleButton(RageScroll, "Anti-Aim Yaw Mode", {"Spin", "Jitter", "Backwards", "Random", "Static"}, 1, function(m)
	Config.Rage.AntiAimYaw = m
end)
AddCycleButton(RageScroll, "Anti-Aim Pitch Mode", {"Down", "Up", "Zero", "Jitter"}, 1, function(m)
	Config.Rage.AntiAimPitch = m
end)
AddSlider(RageScroll, "Anti-Aim Spin / Jitter Speed", 5, 100, Config.Rage.AntiAimSpeed, false, function(v)
	Config.Rage.AntiAimSpeed = v
end)
AddSlider(RageScroll, "Anti-Aim Yaw Angle (°)", -180, 180, Config.Rage.AntiAimAngle, false, function(v)
	Config.Rage.AntiAimAngle = v
end)

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
	if ActiveDroneModel then
		ActiveDroneModel:Destroy()
		ActiveDroneModel = nil
	end
	if not Config.Rage.Fly then StopFlyControllers() end

	local char = LocalPlayer.Character
	if char then
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
				p.Transparency = 0
			elseif p:IsA("Decal") then
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
-- ФИЗИКА И АВТОМАТИЗАЦИЯ (FLING, SILENT AIM, ДОЖДЬ, ЦИКЛЫ)
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
					local targetPart = GetClosestTarget(Config.SilentAim.FOV, visCheck)
					if targetPart then
						local pred = targetPart.Position + (targetPart.AssemblyLinearVelocity * Config.SilentAim.Prediction)
						if myHrp then CreateBulletTracer(myHrp.Position, pred) end
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

	EspNodes[plr] = {
		Holder = holder, BoxStroke = boxStroke, HpBg = hpBg, HpFill = hpFill,
		NameTag = nameTag, MetaTag = metaTag, WepTag = wepTag
	}
end

Players.PlayerRemoving:Connect(function(plr)
	if EspNodes[plr] then
		EspNodes[plr].Holder:Destroy()
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
		local target = GetClosestTarget(Config.Aimbot.FOV, Config.Aimbot.VisibleOnly)
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

	if Config.Visuals.CustomSky then
		Lighting.Ambient = Config.Visuals.SkyColor
		Lighting.OutdoorAmbient = Config.Visuals.SkyColor
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

	-- Безопасный цикл ESP (всегда работает, даже если роли/оружия не найдены)
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			if not EspNodes[plr] then CreateEspNode(plr) end
			local node = EspNodes[plr]
			local char = plr.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
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
					
					-- Автоматическое безопасное определение роли (если оружия нет, просто пишется PLAYER или INNOCENT)
					local role, weaponName = "Player", ""
					pcall(function()
						if GetPlayerRoleAndWeapon then
							role, weaponName = GetPlayerRoleAndWeapon(plr)
						end
					end)

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
					node.MetaTag.Visible = (#metaParts > 0)
					node.MetaTag.Text = table.concat(metaParts, " ")
					node.MetaTag.TextColor3 = Config.ESP.PingColor

					node.WepTag.Visible = Config.ESP.Weapon
					node.WepTag.Text = (weaponName ~= "") and (role:upper() .. " • " .. weaponName) or role:upper()
					node.WepTag.TextColor3 = Config.ESP.WeaponColor
				else
					node.Holder.Visible = false
				end
			else
				node.Holder.Visible = false
			end
		end
	end
end)

-------------------------------------------------------------------------
-- ХУКИ СПАВНА И АВТО-ПРИМЕНЕНИЕ СРАЗУ
-------------------------------------------------------------------------
local function OnCharacterAdded(char)
	char.ChildAdded:Connect(function(tool)
		CheckCharacterTool(tool)
	end)
	
	task.spawn(function()
		local bp = LocalPlayer:WaitForChild("Backpack", 5)
		if bp then
			bp.ChildAdded:Connect(function(tool)
				CheckCharacterTool(tool)
			end)
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

if LocalPlayer.Character then 
	OnCharacterAdded(LocalPlayer.Character) 
end
LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)

-------------------------------------------------------------------------
-- ОТСЛЕЖИВАНИЕ УРОНА ПО ВРАГАМ (ХИТСАУНД ЛОГИКА)
-------------------------------------------------------------------------
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

for _, p in ipairs(Players:GetPlayers()) do
	HookEnemyHealth(p)
end
Players.PlayerAdded:Connect(HookEnemyHealth)

local IsMenuOpen = true
Watermark.MouseButton1Click:Connect(function()
	IsMenuOpen = not IsMenuOpen
	if not IsMenuOpen then ColorPickerPopup.Visible = false end
	if IsMenuOpen then
		PlayUISound(6895079853, 1.18, 0.5)
		MainFrame.Visible = true
		MainScale.Scale = 0.86
		tween(MainScale, 0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Scale = 1 })
		tween(WmDot, 0.2, nil, nil, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) })
	else
		PlayUISound(6895079853, 0.82, 0.45)
		local t = tween(MainScale, 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In, { Scale = 0.86 })
		tween(WmDot, 0.2, nil, nil, { BackgroundColor3 = Color3.fromRGB(70, 70, 80) })
		t.Completed:Connect(function()
			if not IsMenuOpen then MainFrame.Visible = false end
		end)
	end
end)

-- Принудительный запуск скинченджера сразу при инжекте
RefreshEquippedSkins()
RenderSkinList()
