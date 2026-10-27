----------------- ENERGY CORE ---------------

-- Item --
local ecI = {}
ecI.type = "item"
ecI.name = "EnergyCore"
ecI.icon = "__Mobile_Factory_Space_Age__/mf_base/graphics/items/EnergyCore.png"
ecI.icon_size = 256
ecI.fuel_categories = {"chemical"}
ecI.fuel_value = "250MJ"
ecI.subgroup = "MFElectronic"
ecI.order = "d"
ecI.stack_size = 10
data:extend{ecI}

-- Recipe --
local ecR = {}
ecR.type = "recipe"
ecR.name = "EnergyCore"
ecR.energy_required = 120
ecR.enabled = false
ecR.categories = {"DimensionalCrystallizaton"}
ecR.ingredients =
{
	{type="item", name="CrystalizedCircuit", amount=10},
	{type="item", name="DimensionalCrystal", amount=1}
}
ecR.results = {{type="item", name="EnergyCore", amount=1}}
data:extend{ecR}

-- Technology --
local ecT = {}
ecT.name = "EnergyCore"
ecT.type = "technology"
ecT.icon = "__Mobile_Factory_Space_Age__/mf_base/graphics/items/EnergyCore.png"
ecT.icon_size = 256
ecT.unit = {
	count=10,
	time=30,
	ingredients={
		{"DimensionalSample", 100},
		{"DimensionalCrystal", 2}
	}
}
ecT.prerequisites = {"DimensionalCrystal"}
ecT.effects = {{type="unlock-recipe", recipe="EnergyCore"}}
data:extend{ecT}