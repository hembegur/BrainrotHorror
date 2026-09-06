local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local TraceRouteService = game:GetService("TraceRouteService")
local baseCurrStats = ServerScriptService.BaseStats
local Brainrot = {}
Brainrot.__index = Brainrot

export type Config = {
	Model: Model?,
	Price: number?,
	MoneyGenerateRate: number?,
	Rarity: string?,
	RarityColor: Color3?,
	Animations: { [string]: Animation }?,
}

export type Brainrot = typeof(setmetatable(
	{} :: {
		Model: Model,
		Captured: boolean,
		MoneyGenerated: number,
		Rarity: string?,
		RarityColor: Color3?,
		Animations: { [string]: Animation }?,
		_connections: { RBXScriptConnection },
		_destroyed: boolean,
		_capturePrompt: ProximityPrompt,
		_chosenSlot: Object,
	},
	Brainrot
))

function Brainrot.new(config: Config?): Brainrot
	local resolved: Config = config or {}
	local self = setmetatable({
		Model = resolved.Model:Clone(),
		Price = resolved.Price or 0,
		MoneyGenerateRate = resolved.MoneyGenerateRate or 0,
		Rarity = resolved.Rarity or "Common",
		RarityColor = resolved.RarityColor or Color3.new(0, 1, 0),
		MoneyGenerated = 0,
		Captured = false,
		Animations = {} :: { AnimationClip },
		_connections = {} :: { RBXScriptConnection },
		_destroyed = false,
		_capturePrompt = nil,
		_chosenSlot = nil,
	}, Brainrot)

	--Billboard gui setup
	local billboardFold = Instance.new("Folder")
	billboardFold.Parent = self.Model
	billboardFold.Name = "BillboardGuis"
	for _, gui in pairs(ReplicatedStorage.Models.Brainrots.BillboardGui:GetChildren()) do
		local clone = gui:Clone() :: BillboardGui
		clone.Parent = billboardFold
		clone.Adornee = self.Model.Head
	end
	billboardFold.NameGui.TextLabel.Text = self.Model.Name
	billboardFold.RarityGui.TextLabel.Text = self.Rarity
	billboardFold.MoneyRateGui.TextLabel.Text = self.MoneyGenerateRate .. "$/s"
	billboardFold.PriceGui.TextLabel.Text = self.Price .. "$"

	--Workspace walk and shit
	self.Model:PivotTo(workspace.Map.WalkPoints.Start.CFrame)
	self.Model.Parent = workspace.Map.NPCs.WalkingNPCs
	local hum = self.Model.Humanoid :: Humanoid
	local hrp = self.Model.HumanoidRootPart :: BasePart

	local walkAnim = hum.Animator:LoadAnimation(
		(resolved.Animations and resolved.Animations["Walk"]) or ReplicatedStorage.Animations.Brainrot.WalkAnimation
	) :: AnimationTrack
	walkAnim:Play()

	task.spawn(function()
		while not self._destroyed and not self.Captured do
			task.wait(0.2)
			hum:MoveTo(workspace.Map.WalkPoints.FinishPoint.Position)

			local dis = (hrp.Position - workspace.Map.WalkPoints.FinishPoint.Position).Magnitude
			if dis <= 8 then
				self:Destroy()
			end
		end
	end)

	--Capture Prompt
	local prompt = Instance.new("ProximityPrompt")
	self._capturePrompt = prompt
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 8
	prompt.Parent = self.Model.Torso
	prompt.ActionText = "Buy"

	table.insert(
		self._connections,
		prompt.TriggerEnded:Connect(function(player: Player)
			self:Buy(player)
		end)
	)

	--Die
	table.insert(
		self._connections,
		hum.Died:Connect(function()
			self:Destroy()
		end)
	)

	return self
end

function Brainrot.Buy(self: Brainrot, player: Player)
	if baseCurrStats.BrainrotCount.Value >= baseCurrStats.MaxBrainrots.Value then
		print("nga")
		return
	end
	if player.leaderstats.Money.Value < self.Price then
		return
	end

	player.leaderstats.Money.Value -= self.Price
	self.Captured = true
	self._capturePrompt:Destroy()
	local hum = self.Model.Humanoid :: Humanoid
	local hrp = self.Model.HumanoidRootPart :: BasePart

	task.spawn(function()
		while not self._destroyed do
			task.wait(0.1)
			hum:MoveTo(workspace.Map.PlayerBase.CollectZone.Position)

			local dis = (hrp.Position - workspace.Map.PlayerBase.CollectZone.Position).Magnitude
			if dis <= 8 then
				self:GetInBase()
				break
			end
		end
	end)
end

function Brainrot.GetInBase(self: Brainrot)
	local maxCount = baseCurrStats.MaxBrainrots.Value
	for i = 1, maxCount do
		local currSlot = workspace.Map.PlayerBase.Slots["Slot" .. i]
		local slotConfig = currSlot.Configuration
		if not slotConfig.Occupied.Value then
			slotConfig.Occupied.Value = true
			slotConfig.Thing.Value = self.Model
			self._chosenSlot = currSlot
			break
		end
	end
	local hrp = self.Model.HumanoidRootPart
	hrp.Anchored = true
	self.Model:PivotTo(self._chosenSlot.Spawn.CFrame)

	self:ProduceMoney()

	--sell Prompt
	local prompt = Instance.new("ProximityPrompt")
	self._capturePrompt = prompt
	prompt.HoldDuration = 1
	prompt.MaxActivationDistance = 8
	prompt.Parent = self.Model.Torso
	prompt.ActionText = "Sell"

	table.insert(
		self._connections,
		prompt.TriggerEnded:Connect(function(player: Player)
			self._chosenSlot.Configuration.Occupied.Value = false
			self._chosenSlot.Configuration.Thing.Value = nil
			self._moneyGui:Destroy()
			self:Destroy()
		end)
	)
end

function Brainrot.ProduceMoney(self: Brainrot)
	local moneyGui = workspace.Map.PlayerBase.Slots.MoneyGui:Clone() :: BillboardGui
	moneyGui.Parent = self._chosenSlot.Collect
	moneyGui.Adornee = self._chosenSlot.Collect
	self._moneyGui = moneyGui
	table.insert(
		self._connections,
		RunService.Heartbeat:Connect(function(dt: number)
			self.MoneyGenerated += dt * self.MoneyGenerateRate
			moneyGui.TextLabel.Text = math.round(self.MoneyGenerated) .. "$"
		end)
	)
	table.insert(
		self._connections,
		self._chosenSlot.Collect.Touched:Connect(function(touched: BasePart)
			if touched.Parent:FindFirstChild("HumanoidRootPart") and Players:GetPlayerFromCharacter(touched.Parent) then
				--print(char)
				for _, player in pairs(Players:GetPlayers()) do
					player.leaderstats.Money.Value += self.MoneyGenerated
					self.MoneyGenerated = 0
				end
			end
		end)
	)
end

function Brainrot.Destroy(self: Brainrot)
	if self._destroyed then
		return
	end
	self._destroyed = true
	for _, connection in self._connections do
		connection:Disconnect()
	end
	self.Model:Destroy()
	table.clear(self._connections)
end

return Brainrot
