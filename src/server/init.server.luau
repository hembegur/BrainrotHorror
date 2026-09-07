local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local Money = Instance.new("IntValue")
	Money.Name = "Money"
	Money.Value = 10
	Money.Parent = leaderstats

	player.CharacterAdded:Connect(function(char: Model)
		for _, p in pairs(char:GetDescendants()) do
			if p:IsA("BasePart") then
				p.CollisionGroup = "Players"
			end
		end
	end)
end)

require(script.Services.BrainrotSpawnService)
require(script.Services.BaseService)
