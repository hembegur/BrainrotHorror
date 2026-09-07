local ServerScriptService = game:GetService("ServerScriptService")
local TouchInputService = game:GetService("TouchInputService")
local baseCurrStats = ServerScriptService.BaseStats
local playerBase = workspace.Map.PlayerBase
local upgrades = playerBase.UpgradeProgression

local baseService = {}

baseCurrStats.MaxBrainrots.Value = 0
for _, p in pairs(workspace.Map.PlayerBase.Build:GetDescendants()) do
	if p:IsA("BasePart") then
		p.Position -= Vector3.new(0, -300, 0)
	end
end

function loadUpgrade(upgrade: Folder)
	for _, objVal in pairs(upgrade:GetChildren()) do
		local model = objVal.Value :: Model
		for _, p in pairs(model:GetDescendants()) do
			if p:IsA("BasePart") then
				p.Position += Vector3.new(0, -300, 0)
			end
		end
		if string.find(model.Name, "Stand", 1, true) then
			baseCurrStats.MaxBrainrots.Value += 1
		end
	end
end

loadUpgrade(upgrades.Upgrade0)

local prompt = Instance.new("ProximityPrompt")
prompt.HoldDuration = 0
prompt.MaxActivationDistance = 12
prompt.Parent = playerBase.UpgradeSpot
prompt.ActionText = "UpgradeBase"

local currUpgrade = 1
prompt.TriggerEnded:Connect(function(player: Player)
	if currUpgrade > 21 then
		return
	end
	loadUpgrade(upgrades["Upgrade" .. currUpgrade])
	currUpgrade += 1
end)

return baseService
