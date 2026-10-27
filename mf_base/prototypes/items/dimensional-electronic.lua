-- DIMENSIONAL WIRE --

-- Item --
local dwI = {}
dwI.type = "item"
dwI.name = "DimensionalWire"
dwI.icon = "__Mobile_Factory_Space_Age__/mf_base/graphics/items/DimensionalWire.png"
dwI.icon_size = 64
dwI.subgroup = "MFElectronic"
dwI.order = "a"
dwI.stack_size = 500
data:extend{dwI}

-- Recipe --
local dwR = {}
dwR.type = "recipe"
dwR.name = "DimensionalWire"
dwR.energy_required = 1
dwR.enabled = false
dwR.ingredients =
{
	{type="item", name="DimensionalPlate", amount=1}
}
dwR.results = {
  {type="item", name="DimensionalWire", amount=1}
}
data:extend{dwR}


-- DIMENSIONAL CIRCUIT --

-- Item --
local dcI = {}
dcI.type = "item"
dcI.name = "DimensionalCircuit"
dcI.icon = "__Mobile_Factory_Space_Age__/mf_base/graphics/items/DimensionalCircuit.png"
dcI.icon_size = 64
dcI.subgroup = "MFElectronic"
dcI.order = "b"
dcI.stack_size = 200
data:extend{dcI}

-- Recipe --
local dcR = {}
dcR.type = "recipe"
dcR.name = "DimensionalCircuit"
dcR.energy_required = 2
dcR.enabled = false
dcR.ingredients =
{
	{type="item", name="DimensionalPlate", amount=1},
	{type="item", name="DimensionalWire", amount=3}
}
dcR.results = {
  {type="item", name="DimensionalCircuit", amount=1}
}
data:extend{dcR}

-- CRYSTALIZED CIRCUIT --

-- Item --
local ccI = {}
ccI.type = "item"
ccI.name = "CrystalizedCircuit"
ccI.icon = "__Mobile_Factory_Space_Age__/mf_base/graphics/items/CrystalizedCircuit.png"
ccI.icon_size = 64
ccI.subgroup = "MFElectronic"
ccI.order = "c"
ccI.stack_size = 200
data:extend{ccI}

-- Recipe --
local ccR = {}
ccR.type = "recipe"
ccR.name = "CrystalizedCircuit"
ccR.energy_required = 3
ccR.enabled = false
ccR.ingredients =
{
	{type="item", name="DimensionalCircuit", amount=4},
	{type="item", name="DimensionalCrystal", amount=1}
}
ccR.results = {
  {type="item", name="CrystalizedCircuit", amount=4}
}
data:extend{ccR}

-- Technology --
local deT = {}
deT.type = "technology"
deT.name = "DimensionalElectronic"
deT.icon = "__Mobile_Factory_Space_Age__/mf_base/graphics/technologies/DimensionalElectronic.png"
deT.icon_size = 128
deT.unit =
{
	count = 350,
	time = 2,
	ingredients = 
	{
		{"DimensionalSample", 1}
	}
}
deT.prerequisites = {"DimensionalOreSmelting"}
deT.effects = 
{
	{type="unlock-recipe", recipe="DimensionalWire"},
	{type="unlock-recipe", recipe="DimensionalCircuit"}
}
data:extend{deT}