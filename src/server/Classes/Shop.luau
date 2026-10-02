local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packets = require(ReplicatedStorage.Shared.Modules.Packets)

local shop = {}

packets.BuyRequest.OnServerEvent:Connect(function(player, itemName) end)

return shop
