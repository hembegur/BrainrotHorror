local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local baseCurrStats = ServerScriptService.BaseStats
local playerBase = workspace.Map.PlayerBase
local upgrades = playerBase.UpgradeProgression
local BrainrotData = require(ServerScriptService.Server.Classes.BrainrotData)
local Brainrot = require(ServerScriptService.Server.Classes.Brainrot)

local STARTER_PLAYER_MONEY = 50

local baseService = {}

local currUpgrade = 1
function resetBase()
	for _, p in pairs(Players:GetPlayers()) do
		p.leaderstats.Money.Value = STARTER_PLAYER_MONEY
	end
	for _, br in pairs(Brainrot.InBase) do
		if not br._destroyed then
			br:Destroy()
		end
	end
	table.clear(Brainrot.InBase)

	baseCurrStats.Upgrade.Value = 1
	currUpgrade = 1
	baseCurrStats.MaxBrainrots.Value = 0
	for _, p in pairs(workspace.Map.PlayerBase.Build:GetDescendants()) do
		if p:IsA("BasePart") then
			p.Position -= Vector3.new(0, 300, 0)
		end
	end
end

resetBase()

function loadUpgrade(upgrade: Folder)
	for _, objVal in pairs(upgrade:GetChildren()) do
		local model = objVal.Value :: Model
		for _, p in pairs(model:GetDescendants()) do
			if p:IsA("BasePart") then
				p.Position += Vector3.new(0, 300, 0)
			end
		end
		if string.find(model.Name, "Stand", 1, true) then
			baseCurrStats.MaxBrainrots.Value += 1
		end
	end
end

loadUpgrade(upgrades.Upgrade0)

--Waiting for claiming
local claimPrompt = Instance.new("ProximityPrompt")
claimPrompt.HoldDuration = 0.5
claimPrompt.MaxActivationDistance = 15
claimPrompt.Parent = playerBase.Arrow
claimPrompt.ActionText = "Claim Base"

playerBase.UpgradeSpot.Position -= Vector3.new(0, 100, 0)
claimPrompt.TriggerEnded:Connect(function()
	playerBase.Arrow:Destroy()
	playerBase.UpgradeSpot.Position += Vector3.new(0, 100, 0)
	baseCurrStats.Claimed.Value = true
	claimPrompt:Destroy()
end)

-- Upgrade prompt
local prompt = Instance.new("ProximityPrompt")
prompt.HoldDuration = 0
prompt.MaxActivationDistance = 12
prompt.Parent = playerBase.UpgradeSpot
prompt.ActionText = "Upgrade Base " .. 1 .. " (" .. BrainrotData.GetUpgradePrice(1) .. "$)"

prompt.TriggerEnded:Connect(function(player: Player)
	if currUpgrade > 21 then
		prompt.ActionText = "Upgrade Base " .. 1 .. " (" .. BrainrotData.GetUpgradePrice(1) .. "$)"
		resetBase()
		loadUpgrade(upgrades.Upgrade0)
		player.leaderstats.Rebirth.Value += 1
		return
	end
	if player.leaderstats.Money.Value < BrainrotData.GetUpgradePrice(currUpgrade) then
		return
	end
	player.leaderstats.Money.Value -= BrainrotData.GetUpgradePrice(currUpgrade)
	loadUpgrade(upgrades["Upgrade" .. currUpgrade])

	currUpgrade += 1
	baseCurrStats.Upgrade.Value = currUpgrade
	if currUpgrade == 22 then
		prompt.ActionText = "Rebirth"
		return
	end
	prompt.ActionText = "Upgrade Base " .. currUpgrade .. " (" .. BrainrotData.GetUpgradePrice(currUpgrade) .. "$)"
end)

return baseService
