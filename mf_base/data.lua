require("mf_base/prototypes/resources/dimensional-ore.lua")
require("mf_base/prototypes/resources/dimensional-fluid.lua")
require("mf_base/prototypes/items/dimensional-sample.lua")
require("mf_base/prototypes/items/dimensional-plate.lua")
require("mf_base/prototypes/items/dimensional-crystal.lua")
require("mf_base/prototypes/items/dimensional-electronic.lua")
require("mf_base/prototypes/items/machine-frame.lua")
require("mf_base/prototypes/items/energy-core.lua")
require("mf_base/prototypes/entities/dimensional-lab.lua")
require("mf_base/prototypes/entities/dimensional-furnace.lua")
require("mf_base/prototypes/entities/crystallizer.lua")

---- Add the MF Base Group --
data:extend{
	{
		type="item-group",
		name="MFBase",
		icon="__Mobile_Factory_Space_Age__/mf_base/graphics/items/DimensionalPlate.png",
		icon_size=64,
		order="w"
	}
}

---- Add Resources Category ----
data:extend{
	{
		type="item-subgroup",
		name="MFResources",
		group="MFBase",
		order="a"
	}
}

---- Add Intermediate Category ----
data:extend{
	{
		type="item-subgroup",
		name="MFIntermediate",
		group="MFBase",
		order="b"
	}
}

---- Add Electronic Category ----
data:extend{
	{
		type="item-subgroup",
		name="MFElectronic",
		group="MFBase",
		order="c"
	}
}

---- Add Frame Category ----
data:extend{
	{
		type="item-subgroup",
		name="MFFrame",
		group="MFBase",
		order="d"
	}
}

---- Add Structure Category ----
data:extend{
	{
		type="item-subgroup",
		name="MFStructure",
		group="MFBase",
		order="e"
	}
}

-- Add the Dimensional Smelting Recipe Category --
data:extend{
	{
		type="recipe-category",
		name="DimensionalSmelting",
		order="a"
	}
}

-- Add the Dimensional Crystallization Recipe Category --
data:extend{
	{
		type="recipe-category",
		name="DimensionalCrystallizaton",
		order="b"
	}
}