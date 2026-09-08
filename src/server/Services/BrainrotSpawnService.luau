-- ServerScriptService.Server.Services.SpawnService
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local BrainrotClass = require(ServerScriptService.Server.Classes.Brainrot)
local BrainrotData = require(ServerScriptService.Server.Classes.BrainrotData)

local Random = Random.new()

local SpawnService = {}
SpawnService.__index = SpawnService

-- CONFIG (tweak these)
local CONFIG = {
	SpawnIntervalBase = 2.5,
	MaxActivePerPlayer = 6, -- active walking brainrots allowed per player
	MaxAbsoluteActive = 60, -- hard upper cap
	SpawnPointsFolder = Workspace:FindFirstChild("Map")
		and Workspace.Map:FindFirstChild("WalkPoints")
		and Workspace.Map.WalkPoints:FindFirstChild("SpawnPoints"), -- optional folder of spawn parts
	WalkingNPCsFolder = Workspace:FindFirstChild("Map")
		and Workspace.Map:FindFirstChild("NPCs")
		and Workspace.Map.NPCs:FindFirstChild("WalkingNPCs"),
	-- Rarity weights (sum => 100)
	RarityWeights = {
		common = 70,
		rare = 20,
		epic = 9,
		legendary = 1, -- legendary acts as the gold variant in your system
	},
}

-- Utility: pick weighted rarity
local function pickWeightedRarity()
	local weights = CONFIG.RarityWeights
	local total = 0
	for _, w in pairs(weights) do
		total = total + w
	end
	local r = Random:NextInteger(1, total)
	local running = 0
	for name, w in pairs(weights) do
		running = running + w
		if r <= running then
			return name
		end
	end
	return "common"
end

-- Utility: get list of raw brainrot keys
local function getAllBrainrotNames()
	local t = {}
	if BrainrotData and BrainrotData.raw then
		for k, _ in pairs(BrainrotData.raw) do
			table.insert(t, k)
		end
	end
	return t
end

-- Utility: count active walking NPCs (safe)
local function countActiveBrainrots()
	local folder = CONFIG.WalkingNPCsFolder
	if not folder then
		-- best-effort: try to find by name
		local okFolder = Workspace:FindFirstChild("Map")
			and Workspace.Map:FindFirstChild("NPCs")
			and Workspace.Map.NPCs:FindFirstChild("WalkingNPCs")
		folder = okFolder
	end
	if not folder then
		return 0
	end
	local count = 0
	for _, child in ipairs(folder:GetChildren()) do
		count = count + 1
	end
	return count
end

-- Utility: choose a spawn CFrame
local function chooseSpawnCFrame()
	local spFolder = CONFIG.SpawnPointsFolder
	if spFolder and spFolder:GetChildren() and #spFolder:GetChildren() > 0 then
		local kids = spFolder:GetChildren()
		local pick = kids[Random:NextInteger(1, #kids)]
		if pick and pick:IsA("BasePart") then
			return pick.CFrame
		elseif pick and pick:IsA("Model") and pick.PrimaryPart then
			return pick:GetPrimaryPartCFrame()
		end
	end

	-- Fallback: try Map WalkPoints Start
	if
		Workspace:FindFirstChild("Map")
		and Workspace.Map:FindFirstChild("WalkPoints")
		and Workspace.Map.WalkPoints:FindFirstChild("Start")
	then
		return Workspace.Map.WalkPoints.Start.CFrame
	end

	-- final fallback: workspace origin
	return CFrame.new(0, 5, 0)
end

-- Spawns a single Brainrot with given name and rarity (or nil to randomize)
function SpawnService.SpawnOnce(name: string?, rarity: string?)
	-- pick name
	local entryName = name
	if not entryName then
		local names = getAllBrainrotNames()
		if #names == 0 then
			warn("[SpawnService] No brainrot names available in BrainrotData.raw")
			return false
		end
		entryName = names[Random:NextInteger(1, #names)]
	end

	-- pick rarity if not given
	local chosenRarity = rarity and tostring(rarity):lower() or pickWeightedRarity()

	-- Resolve config
	local cfg = nil
	local ok, result = pcall(function()
		return BrainrotData.GetConfig(entryName, chosenRarity)
	end)
	if ok then
		cfg = result
	end
	if not cfg then
		warn("[SpawnService] Failed to GetConfig for", entryName, chosenRarity)
		return false
	end

	-- choose spawn CFrame
	local spawnCFrame = chooseSpawnCFrame()

	-- try to spawn safely
	local success, instanceOrErr = pcall(function()
		-- ensure Model exists (GetConfig returns model reference, Brainrot.new clones inside)
		if cfg.Model == nil then
			-- still allow BrainrotClass to handle nil model if it's designed so, but log
			warn("[SpawnService] Config.Model is nil for", entryName)
		end

		-- Give the Brainrot class a position by setting CFrame after creation (slightly future-proof)
		local b = BrainrotClass.new(cfg)
		-- If the class did not set pivot location, try to move its model if available
		if b and b.Model and b.Model.PrimaryPart then
			pcall(function()
				b.Model:PivotTo(spawnCFrame)
			end)
		end
		return b
	end)

	if not success then
		warn("[SpawnService] Error while creating Brainrot:", instanceOrErr)
		return false
	end

	return true
end

-- Spawns random name + rarity (helper)
function SpawnService.SpawnRandom()
	return SpawnService.SpawnOnce(nil, nil)
end

-- Main loop
local _spawnLoopThread = nil
local function spawnLoop()
	local intervalBase = CONFIG.SpawnIntervalBase
	while SpawnService._running do
		-- compute player-scaled interval and caps
		local players = math.max(1, #Players:GetPlayers())
		-- spawn frequency increases slightly with players (less wait)
		local spawnInterval = math.max(0.5, intervalBase / math.clamp(players, 1, 4))

		SpawnService.SpawnRandom()

		-- wait
		task.wait(spawnInterval)
	end
end

-- Start/Stop API
function SpawnService.Start()
	if SpawnService._running then
		return
	end
	SpawnService._running = true
	_spawnLoopThread = task.spawn(spawnLoop)
	print("[SpawnService] started")
end

function SpawnService.Stop()
	if not SpawnService._running then
		return
	end
	SpawnService._running = false
	if _spawnLoopThread then
		-- allow thread to finish naturally
		_spawnLoopThread = nil
	end
	print("[SpawnService] stopped")
end

-- Manual cleanup (call if you ever teardown server)
function SpawnService.Cleanup()
	SpawnService.Stop()
	-- (Nothing else to disconnect, but if you added event connections keep them here)
end

return SpawnService
