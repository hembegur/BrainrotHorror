local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Brainrot = require(ServerScriptService.Server.Classes.Brainrot)
local BrainrotData = require(ServerScriptService.Server.Classes.BrainrotData)

local Service = {}

task.spawn(function()
	while true do
		Brainrot.new(BrainrotData.GetConfig("Tralalero_Tralala", "Legendary"))

		task.wait(1)
	end
end)

return Service
