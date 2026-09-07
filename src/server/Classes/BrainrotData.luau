-- ReplicatedStorage/BrainrotData.lua
-- Ready-to-paste ModuleScript
-- Notes:
--  - Rarities: "common", "rare", "epic", "legendary"
--  - "legendary" is the gold/top-tier variant for a brainrot (not a separate 'gold' rarity).
--  - Prices are scaled by number of players in the server (Players:GetPlayers()) so upgrade/rebirth timing stays balanced for 1-4 players.
--  - Edit the `raw` table to change Model references, BasePrice or BaseRate per-entry.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Type for autocomplete
export type BrainrotConfig = {
	Name: string?,
	Model: Model?,
	Price: number?,
	MoneyGenerateRate: number?,
	Rarity: string?,
	RarityColor: Color3?,
	Animations: { [string]: Animation }?,
}

-- BASE COMMON NUMBERS (tweak these to adjust pace)
local BASE_COMMON_RATE = 2 -- $/s for common
local BASE_COMMON_PRICE = 50 -- buy price for common

-- RARITY CONFIG (legendary is the gold variant / top tier)
local RarityConfig = {
	common = { rateMultiplier = 1, priceMultiplier = 1, color = Color3.fromRGB(200, 200, 200) },
	rare = { rateMultiplier = 4, priceMultiplier = 6, color = Color3.fromRGB(85, 170, 255) },
	epic = { rateMultiplier = 16, priceMultiplier = 40, color = Color3.fromRGB(170, 85, 255) },
	legendary = { rateMultiplier = 64, priceMultiplier = 250, color = Color3.fromRGB(255, 200, 0) }, -- gold
}

-- RAW brainrot list (models must exist under ReplicatedStorage.Models.Brainrots)
-- I populated this with the names from your screenshot. Adjust BasePrice / BaseRate per-entry if desired.
local raw: { [string]: any } = {
	Ballerina_Cappuccina = {
		Name = "Ballerina Cappuccina",
		Model = ReplicatedStorage.Models.Brainrots:FindFirstChild("Ballerina_Cappuccina"),
		BasePrice = BASE_COMMON_PRICE * 1.05,
		BaseRate = BASE_COMMON_RATE * 1.0,
		Animations = {
			Walk = ReplicatedStorage.Animations.Brainrot.BallerinaWalkAnimation,
		},
	},
	Bombardiro_Crocodilo = {
		Name = "Bombardiro Crocodilo",
		Model = ReplicatedStorage.Models.Brainrots:FindFirstChild("Bombardiro_Crocodilo"),
		BasePrice = BASE_COMMON_PRICE * 1.25,
		BaseRate = BASE_COMMON_RATE * 1.1,
		Animations = {
			Walk = ReplicatedStorage.Animations.Brainrot.BombardiroFlyAnimation,
		},
	},
	Brr_Brr_Patapim = {
		Name = "Brr Brr Patapim",
		Model = ReplicatedStorage.Models.Brainrots:FindFirstChild("Brr_Brr_Patapim"),
		BasePrice = BASE_COMMON_PRICE * 0.95,
		BaseRate = BASE_COMMON_RATE * 0.95,
		Animations = {
			Walk = ReplicatedStorage.Animations.Brainrot.TungSahurWalkAnimation,
		},
	},
	Cappuccino_Assassino = {
		Name = "Cappuccino Assassino",
		Model = ReplicatedStorage.Models.Brainrots:FindFirstChild("Cappuccino_Assassino"),
		BasePrice = BASE_COMMON_PRICE * 1.4,
		BaseRate = BASE_COMMON_RATE * 1.25,
		Animations = {
			Walk = ReplicatedStorage.Animations.Brainrot.CappuccinoWalkAnimation,
		},
	},
	Chimpanzini_Bananini = {
		Name = "Chimpanzini Bananini",
		Model = ReplicatedStorage.Models.Brainrots:FindFirstChild("Chimpanzini_Bananini"),
		BasePrice = BASE_COMMON_PRICE * 1.0,
		BaseRate = BASE_COMMON_RATE * 1.0,
		Animations = {
			Walk = ReplicatedStorage.Animations.Brainrot.BombardiroFlyAnimation,
		},
	},
	Frigo_Camelo = {
		Name = "Frigo Camelo",
		Model = ReplicatedStorage.Models.Brainrots:FindFirstChild("Frigo_Camelo"),
		BasePrice = BASE_COMMON_PRICE * 1.1,
		BaseRate = BASE_COMMON_RATE * 1.05,
		Animations = {
			Walk = ReplicatedStorage.Animations.Brainrot.BombardiroFlyAnimation,
		},
	},
	Lirili_Larila = {
		Name = "Lirili Larila",
		Model = ReplicatedStorage.Models.Brainrots:FindFirstChild("Lirili_Larila"),
		BasePrice = BASE_COMMON_PRICE * 0.9,
		BaseRate = BASE_COMMON_RATE * 0.9,
		Animations = {
			Walk = ReplicatedStorage.Animations.Brainrot.BombardiroFlyAnimation,
		},
	},
	Noobini_Pizzanini = {
		Name = "Noobini Pizzanini",
		Model = ReplicatedStorage.Models.Brainrots:FindFirstChild("Noobini_Pizzanini"),
		BasePrice = BASE_COMMON_PRICE * 0.85,
		BaseRate = BASE_COMMON_RATE * 0.85,
		Animations = {
			Walk = ReplicatedStorage.Animations.Brainrot.WalkAnimation,
		},
	},
	Odin_Din_Din_Dun = {
		Name = "Odin Din Din Dun",
		Model = ReplicatedStorage.Models.Brainrots:FindFirstChild("Odin_Din_Din_Dun"),
		BasePrice = BASE_COMMON_PRICE * 1.6,
		BaseRate = BASE_COMMON_RATE * 1.5,
		Animations = {
			Walk = ReplicatedStorage.Animations.Brainrot.OdinWalkAnimation,
		},
	},
	Tralalero_Tralala = {
		-- guessed name from screenshot; change string if different
		Name = "Tralalero Tralala",
		Model = ReplicatedStorage.Models.Brainrots:FindFirstChild("Tralalero_Tralala"),
		BasePrice = BASE_COMMON_PRICE * 1.0,
		BaseRate = BASE_COMMON_RATE * 1.0,
		Animations = {
			Walk = ReplicatedStorage.Animations.Brainrot.BombardiroFlyAnimation,
		},
	},
	Tung_Tung_Tung_Sahur = {
		Name = "Tung Tung Tung Sahur",
		Model = ReplicatedStorage.Models.Brainrots:FindFirstChild("Tung_Tung_Tung_Sahur"),
		BasePrice = BASE_COMMON_PRICE * 1.2,
		BaseRate = BASE_COMMON_RATE * 1.1,
		Animations = {
			Walk = ReplicatedStorage.Animations.Brainrot.TungSahurWalkAnimation,
		},
	},
}

-- Helper: resolve config for an entryName and a requested rarity ("common","rare","epic","legendary")
-- Legendary acts as the gold/top-tier variant.
local function GetConfig(entryName: string, rarity: string?)
	local e = raw[entryName]
	if not e then
		return nil
	end

	rarity = (rarity or "common"):lower()
	local r = RarityConfig[rarity] or RarityConfig.common

	local rate = (e.BaseRate or BASE_COMMON_RATE) * r.rateMultiplier
	local price = (e.BasePrice or BASE_COMMON_PRICE) * r.priceMultiplier
	local color = r.color

	-- Scale price by number of players present so rebirth / upgrade pacing stays consistent
	local players = math.max(1, #Players:GetPlayers())
	price = math.max(1, math.floor(price * players + 0.5))

	return {
		Name = e.Name,
		Model = e.Model,
		Price = price,
		MoneyGenerateRate = rate,
		Rarity = rarity,
		RarityColor = color,
		Animations = e.Animations,
	}
end

-- Base upgrade prices (levels 1..21) for single-player baseline. Multiply by #players same as GetConfig above.
local UpgradeBasePrices = {
	300,
	375,
	469,
	586,
	732,
	916,
	1144,
	1431,
	1788,
	2235,
	2794,
	3492,
	4366,
	5457,
	6821,
	8527,
	10658,
	13323,
	16653,
	20817,
	26021,
}

local function GetRebirthTarget()
	local total = 0
	for _, v in ipairs(UpgradeBasePrices) do
		total = total + v
	end
	return total * math.max(1, #Players:GetPlayers())
end

local function GetUpgradePrice(levelIndex: number)
	levelIndex = math.clamp(levelIndex, 1, UpgradeBasePrices[levelIndex])
	local base = UpgradeBasePrices[levelIndex]
	local players = math.max(1, #Players:GetPlayers())
	return math.floor(base * players + 0.5)
end

local Data = {}
Data.raw = raw
Data.RarityConfig = RarityConfig
Data.GetConfig = GetConfig
Data.GetUpgradePrice = GetUpgradePrice
Data.UpgradeBasePrices = UpgradeBasePrices
Data.GetRebirthTarget = GetRebirthTarget

return Data
