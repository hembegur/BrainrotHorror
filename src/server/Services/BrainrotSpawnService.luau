local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Brainrot = require(ServerScriptService.Server.Classes.Brainrot)

local Service = {}

task.spawn(function()
	while true do
		Brainrot.new({
			Model = ReplicatedStorage.Models.Brainrots.Odin_Din_Din_Dun,
			Animations = {
				Walk = ReplicatedStorage.Animations.Brainrot.OdinWalkAnimation,
			},
			Price = 0,
			MoneyGenerateRate = 5,
		})

		task.wait(1)

		Brainrot.new({
			Model = ReplicatedStorage.Models.Brainrots["Noobini_Pizzanini"],
			Price = 0,
			MoneyGenerateRate = 2,
		})

		task.wait(1)

		Brainrot.new({
			Model = ReplicatedStorage.Models.Brainrots.Frigo_Camelo,
			Price = 0,
			MoneyGenerateRate = 2,
			Animations = {
				Walk = ReplicatedStorage.Animations.Brainrot.BombardiroFlyAnimation,
			},
		})

		task.wait(1)
	end
end)

return Service
