local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packets = require(ReplicatedStorage.Shared.Modules.Packets)

packets.DealDamage.OnServerEvent:Connect(function(plr: Player, hum: Humanoid, damage: number)
	hum:TakeDamage(damage)
end)

local service = {}
return service
