-- Item --
local dpI = {}
dpI.type = "item"
dpI.name = "DimensionalPlate"
dpI.icon = "__Mobile_Factory_Space_Age__/mf_base/graphics/items/DimensionalPlate.png"
dpI.icon_size = 64
dpI.subgroup = "MFIntermediate"
dpI.order = "b"
dpI.stack_size = 1000
data:extend{dpI}

-- Recipe --
local dpR = {}
dpR.type = "recipe"
dpR.name = "DimensionalPlate"
dpR.energy_required = 1
dpR.categories = {"DimensionalSmelting"}
dpR.enabled = false
dpR.ingredients = {
	{type="item", name="DimensionalOre", amount=2}
}
dpR.results = {
  {type="item", name="DimensionalPlate", amount=1}
}
data:extend{dpR}