local REPO = "dhfehifhei/MonoSquat"
local BRANCH = "main"
local BASE = "https://raw.githubusercontent.com/" .. REPO .. "/" .. BRANCH .. "/"

local function fetchScript(url)
	local ok, body = pcall(function() return game:HttpGet(url, true) end)
	if ok and type(body) == "string" and #body > 0 then return body end
	return nil
end

local function runChunk(source, chunkName)
	local fn, err = loadstring(source, chunkName)
	if not fn then return nil, "compile error: " .. tostring(err) end
	local ok, result = pcall(fn)
	if not ok then return nil, "runtime error: " .. tostring(result) end
	return result
end

local part1Src = fetchScript(BASE .. "Part1_Engine.lua")
if not part1Src then warn("[MonoSquat] Failed to fetch Part1"); return end

local Core, err2 = runChunk(part1Src, "MonoSquat_Part1")
if not Core then warn("[MonoSquat] " .. tostring(err2)); return end

local part2Src = fetchScript(BASE .. "Part2_UI.lua")
if not part2Src then warn("[MonoSquat] Failed to fetch Part2"); return end

local part2Fn, err4 = loadstring(part2Src, "MonoSquat_Part2")
if not part2Fn then warn("[MonoSquat] " .. tostring(err4)); return end

local ok, runErr = pcall(part2Fn, Core)
if not ok then warn("[MonoSquat] Part2 error: " .. tostring(runErr)); return end

print("[MonoSquat] Loaded successfully. Click the watermark to toggle the menu.")