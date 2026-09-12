local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local packets = require(ReplicatedStorage.Shared.Modules.Packets)

player.leaderstats.Money.Changed:Connect(function(val)
	player.PlayerGui.Menu.MoneyText.Text = "$" .. val
end)

export type itemConfig = {
	Name: string,
	Price: number,
}

local shop = player.PlayerGui:WaitForChild("Shop")
local function createNewItem(config: itemConfig)
	local clone = shop.itemTemplate:Clone() :: Frame
	clone.Parent = shop.ShopFrame.Items
	clone.TextLabel.Text = config.Name
	clone.Buy.Text = config.Price .. "$"
	clone.Visible = true

	local buyButton = clone.Buy :: TextButton
	local conn = buyButton.MouseButton1Click:Connect(function()
		packets.BuyRequest:Fire(config.Name)
	end)

	clone.Destroying:Connect(function()
		if conn then
			conn:Disconnect()
			conn = nil
		end
	end)
end

local itemData = require(ReplicatedStorage.Shared.Modules.ShopItems)
for _, item in itemData do
	createNewItem(item)
end

local prompt = workspace
	:WaitForChild("Map")
	:WaitForChild("Shop")
	:WaitForChild("BuyPart")
	:WaitForChild("ProximityPrompt") :: ProximityPrompt
prompt.TriggerEnded:Connect(function(promptPlr)
	if player == promptPlr then
		player.PlayerGui.Shop.Enabled = true
	end
end)

local uiservice = {}
return uiservice
