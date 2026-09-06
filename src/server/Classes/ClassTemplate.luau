local Brainrot = {}

export type Config = {
	Model: Model?,
	Price: number?,
	MoneyGenerateRate: number?,
}

export type Brainrot = typeof(setmetatable(
	{} :: {
		Model: Model,
		Captured: boolean,
		_moneyGenerated: number,
		_connections: { RBXScriptConnection },
		_destroyed: boolean,
	},
	Brainrot
))

function Brainrot.new(config: Config?): Brainrot
	local resolved: Config = config or {}
	local self = setmetatable({
		Model = resolved.Model,
		Price = resolved.Price,
		MoneyGenerateRate = resolved.MoneyGenerateRate,
		_connections = {} :: { RBXScriptConnection },
		_destroyed = false,
	}, Brainrot)

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
	table.clear(self._connections)
end

return Brainrot
