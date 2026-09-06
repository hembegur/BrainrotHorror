local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
	},
	Brainrot
))

function Brainrot.new(config: Config?): Brainrot
	local resolved: Config = config or {}
	local self = setmetatable({
		Model = resolved.Model,
		Price = resolved.Price or 0,
		MoneyGenerateRate = resolved.MoneyGenerateRate or 0,
		Rarity = resolved.Rarity or "Common",
		RarityColor = resolved.RarityColor or Color3.new(0, 1, 0),
		MoneyGenerated = 0,
		Captured = false,
		Animations = {} :: { AnimationClip },
		_connections = {} :: { RBXScriptConnection },
		_destroyed = false,
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

	local walkAnim = hum.Animator:LoadAnimation(
		(resolved.Animations and resolved.Animations["Walk"]) or ReplicatedStorage.Animations.Brainrot.WalkAnimation
	) :: AnimationTrack
	walkAnim:Play()

	task.spawn(function()
		while not self._destroyed and not self.Captured do
			task.wait(0.2)
			hum:MoveTo(workspace.Map.WalkPoints.FinishPoint.Position)
		end
	end)
	table.insert(
		self._connections,
		hum.MoveToFinished:Connect(function(success)
			if success then
				self:Destroy()
			end
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
