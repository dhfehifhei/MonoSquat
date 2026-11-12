--[[
	MonoSquat — Loader (загружается с GitHub)
	Инжект: loadstring(game:HttpGet(".../Loader.lua"))()

	Он сам скачивает Part1_Engine.lua и Part2_UI.lua с этого же репозитория
	и запускает их в правильном порядке.
]]

-- ==== НАСТРОЙКА: замени на свой репозиторий ====
local REPO = "dhfehifhei/MonoSquat"
local BRANCH = "main"
-- ===============================================

-- Собираем URL (raw.githubusercontent.com — самый стабильный вариант)
local BASE = "https://raw.githubusercontent.com/" .. REPO .. "/" .. BRANCH .. "/"
local PART1_URL = BASE .. "Part1_Engine.lua"
local PART2_URL = BASE .. "Part2_UI.lua"

-- Fallback-домены, если raw.githubusercontent.com недоступен
local MIRRORS = {
	function(u) return u end,
	function(u)
		return (u:gsub("raw%.githubusercontent%.com", "cdn.jsdelivr.net/gh"):gsub("/" .. BRANCH .. "/", "@" .. BRANCH .. "/"))
	end,
	function(u)
		return (u:gsub("raw%.githubusercontent%.com", "raw.githack.com"))
	end,
}

local function fetchScript(url)
	local lastErr = "unknown"
	for _, mirror in ipairs(MIRRORS) do
		local mirrored = mirror(url)
		local ok, body = pcall(function()
			return game:HttpGet(mirrored, true)
		end)
		if ok and type(body) == "string" and #body > 0 then
			return body
		end
		lastErr = tostring(body)
	end
	return nil, lastErr
end

local function runChunk(source, chunkName)
	local fn, err = loadstring(source, chunkName)
	if not fn then
		return nil, "compile error in " .. chunkName .. ": " .. tostring(err)
	end
	local ok, result = pcall(fn)
	if not ok then
		return nil, "runtime error in " .. chunkName .. ": " .. tostring(result)
	end
	return result
end

-- ==== PART 1 ====
local part1Src, err1 = fetchScript(PART1_URL)
if not part1Src then
	warn("[MonoSquat] Failed to fetch Part1: " .. tostring(err1))
	return
end

local Core, err2 = runChunk(part1Src, "MonoSquat_Part1")
if not Core then
	warn("[MonoSquat] " .. tostring(err2))
	return
end

-- ==== PART 2 ====
local part2Src, err3 = fetchScript(PART2_URL)
if not part2Src then
	warn("[MonoSquat] Failed to fetch Part2: " .. tostring(err3))
	return
end

local part2Fn, err4 = loadstring(part2Src, "MonoSquat_Part2")
if not part2Fn then
	warn("[MonoSquat] " .. tostring(err4))
	return
end

local ok, runErr = pcall(part2Fn, Core)
if not ok then
	warn("[MonoSquat] Part2 error: " .. tostring(runErr))
	return
end

print("[MonoSquat] Loaded successfully. Click the watermark to toggle the menu.")