local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Brainrot = require(ServerScriptService.Server.Classes.Brainrot)

local Service = {}

task.spawn(function()
	Brainrot.new({
		Model = ReplicatedStorage.Models.Brainrots["Tung Tung Tung Sahur"],
		Animations = {
			Walk = ReplicatedStorage.Animations.Brainrot.TungSahurWalkAnimation,
		},
	})

	task.wait(3)
	Brainrot.new({
		Model = ReplicatedStorage.Models.Brainrots["Noobini Pizzanini"],
	})
end)

return Service
