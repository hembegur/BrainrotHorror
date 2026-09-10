local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local closerangeWeapons = require(script.Classes.Weapons.CloseRangeWeapon)

Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local Money = Instance.new("IntValue")
	Money.Name = "Money"
	Money.Value = 100000000000
	Money.Parent = leaderstats

	local Rebirth = Instance.new("IntValue")
	Rebirth.Name = "Rebirth"
	Rebirth.Value = 0
	Rebirth.Parent = leaderstats

	player.CharacterAdded:Connect(function(char: Model)
		char.Humanoid.WalkSpeed = 40
		char.Parent = workspace.Map.PlayerCharacters
	end)
end)

local brainrotSpawn = require(script.Services.BrainrotSpawnService)
require(script.Services.BaseService)

brainrotSpawn.Start()

require(script.Services.CombatServerService)

local offset = 0
while true do
	local npc = require(script.Classes.NPC.NPC)
	local new = npc.new({ Health = 1 })
	new:SetCFrame(workspace.Test.CFrame * CFrame.new(0, 0, offset))
	new:StealBrainrot()
	offset += 10
	task.wait(100)
end
