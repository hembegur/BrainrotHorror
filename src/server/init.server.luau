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

	player.CharacterAdded:Connect(function(char: Model)
		char.Humanoid.WalkSpeed = 40
	end)
end)

local brainrotSpawn = require(script.Services.BrainrotSpawnService)
require(script.Services.BaseService)

brainrotSpawn.Start()

require(script.Services.CombatServerService)
