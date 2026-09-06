local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Brainrot = require(ServerScriptService.Server.Classes.Brainrot)

local Service = {}

task.spawn(function()
	while true do
		Brainrot.new({
			Model = ReplicatedStorage.Models.Brainrots["Tung Tung Tung Sahur"],
			Animations = {
				Walk = ReplicatedStorage.Animations.Brainrot.TungSahurWalkAnimation,
			},
			Price = 0,
			MoneyGenerateRate = 5,
		})

		task.wait(2)

		Brainrot.new({
			Model = ReplicatedStorage.Models.Brainrots["Noobini Pizzanini"],
			Price = 0,
			MoneyGenerateRate = 2,
		})

		task.wait(2)
	end
end)

return Service
