local Players = game:GetService("Players")

local player = Players.LocalPlayer
player.leaderstats.Money.Changed:Connect(function(val)
	player.PlayerGui.Menu.MoneyText.Text = "$" .. val
end)

local uiservice = {}
return uiservice
