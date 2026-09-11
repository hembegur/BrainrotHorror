local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packets = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("Packets"))

Players.LocalPlayer.CharacterAdded:Connect(function(char: Model)
	local test = require(script.Classes.CloseRangeWeapon).new()
	test:GiveTo(Players.LocalPlayer)
end)

local warninghb = require(script.Classes.WarningHitbox)
packets.SpawnHitbox.OnClientEvent:Connect(function(config)
	local new = warninghb.new(config)
	new:Start()
end)

local uiService = require(script.Services.UiService)
local combatService = require(script.Services.CombatClientService)

require(script.Controllers.MovementController):Start()
