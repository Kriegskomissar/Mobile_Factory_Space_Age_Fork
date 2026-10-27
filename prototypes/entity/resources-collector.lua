------------------------------- RESOURCES COLLECTOR ---------------------------

-- Entity --
local rcE = {}
rcE.type = "container"
rcE.name = "ResourcesCollector"
rcE.icon = "__Mobile_Factory_Space_Age__/graphics/entity/ResourcesCollectorI.png"
rcE.icon_size = 256
rcE.flags = {"placeable-neutral", "player-creation", "not-rotatable"}
rcE.minable = {mining_time = 1, result = "ResourcesCollector"}
rcE.max_health = 500
rcE.inventory_size = 50
rcE.inventory_properties = {
	stack_size_multiplier = 20,
}
rcE.inventory_type = "with_custom_stack_size"
rcE.picture = {
	layers = {
		{
			filename = "__Mobile_Factory_Space_Age__/graphics/entity/ResourcesCollectorE.png",
			width = 600,
			height = 600,
			frames = 1,
			scale = 1/600*33*6
		},
		{
			filename = "__Mobile_Factory_Space_Age__/graphics/entity/ResourcesCollectorS.png",
			width = 600,
			height = 600,
			frames = 1,
			scale = 1/600*33*6,
			draw_as_shadow = true,
			shift = {1.5,0}
		}
	}
}
rcE.collision_box = {{ -2.85, -0.99}, {2.85, 1.99}}
rcE.selection_box = {{ -2.85, -1.85}, {2.85, 2.99}}
rcE.radius_visualisation_specification =
{
	sprite = {
		filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-radius-visualization.png",
		width = 10,
		height = 10
	},
	distance = 50
}
data:extend{rcE}

-- Tank Entity --
local rctE = {}
rctE.name = "ResourcesCollectorTank"
rctE.type = "assembling-machine"
rctE.icon = "__Mobile_Factory_Space_Age__/graphics/entity/ResourcesCollectorI.png"
rctE.icon_size = 256
rctE.flags = {"placeable-neutral", "player-creation", "not-rotatable"}
rctE.minable = {mining_time = 1}
rctE.collision_box = {{ -2.85, -0.99}, {2.85, 1.99}}
rctE.selection_box = nil
rctE.energy_usage = "1J"
rctE.crafting_speed = 1
rctE.crafting_categories = {"crafting"}
rctE.energy_source = {type="void"}
rctE.graphics_set = {
    animation = {filename="__Mobile_Factory_Space_Age__/graphics/Alpha.png", size=1}
}
rctE.idle_animation = {filename="__Mobile_Factory_Space_Age__/graphics/Alpha.png", size=1}
rctE.squeak_behaviour = false
rctE.fluid_boxes = {
	{
		production_type = "output",
		volume = 100,
		pipe_connections = {{ flow_direction="output", position = {-2.85, 0}, direction=defines.direction.west }},
		pipe_picture = table.deepcopy(require("__base__/prototypes/entity/assembler-pictures").assembler2pipepictures),
        pipe_covers = pipecoverspictures()
	},
	{
		production_type = "output",
		volume = 100,
		pipe_connections = {{ flow_direction="output", position = {2.85, 0}, direction=defines.direction.east }},
		pipe_picture = table.deepcopy(require("__base__/prototypes/entity/assembler-pictures").assembler2pipepictures),
        pipe_covers = pipecoverspictures()
	},
	{
		production_type = "output",
		volume = 100,
		pipe_connections = {{ flow_direction="output", position = {-2.85, 1.90}, direction=defines.direction.west }},
		pipe_picture = table.deepcopy(require("__base__/prototypes/entity/assembler-pictures").assembler2pipepictures),
        pipe_covers = pipecoverspictures()
	},
	{
		production_type = "output",
		volume = 100,
		pipe_connections = {{ flow_direction="output", position = {2.85, 1.90}, direction=defines.direction.east }},
		pipe_picture = table.deepcopy(require("__base__/prototypes/entity/assembler-pictures").assembler2pipepictures),
        pipe_covers = pipecoverspictures()
	}

}
data:extend{rctE}


-- Item --
local rcI = {}
rcI.type = "item-with-tags"
rcI.name = "ResourcesCollector"
rcI.icon = "__Mobile_Factory_Space_Age__/graphics/entity/ResourcesCollectorI.png"
rcI.icon_size = 256
rcI.place_result = "ResourcesCollector"
rcI.subgroup = "DimensionalStuff"
rcI.order = "g"
rcI.stack_size = 1
rcI.enable = true
data:extend{rcI}

-- Recipe --
local rcR = {}
rcR.type = "recipe"
rcR.name = "ResourcesCollector"
rcR.energy_required = 10
rcR.enabled = false
rcR.ingredients =
    {
	  {type="item", name="CrystalizedCircuit", amount=12},
      {type="item", name="MachineFrame3", amount=10}
    }
rcR.results = 
  {
    {type="item", name="ResourcesCollector", amount=1}
  }
data:extend{rcR}

-- Technology --
local rcT = {}
rcT.name = "ResourcesCollector"
rcT.type = "technology"
rcT.icon = "__Mobile_Factory_Space_Age__/graphics/entity/ResourcesCollectorI.png"
rcT.icon_size = 256
rcT.unit = {
	count=15,
	time=60,
	ingredients={
		{"DimensionalSample", 100},
		{"DimensionalCrystal", 1}
	}
}
rcT.prerequisites = {"Quatron"}
rcT.effects = {{type="unlock-recipe", recipe="ResourcesCollector"}}
data:extend{rcT}

-- Animation --
local rcAn = {}
rcAn.name = "ResourcesCollectorAn"
rcAn.type = "animation"
rcAn.frame_count = 60
rcAn.filename = "__Mobile_Factory_Space_Age__/graphics/entity/ResourcesCollectorAn.png"
rcAn.size = 600
rcAn.line_length = 10
rcAn.animation_speed = 1
rcAn.scale = 1/600*33*6
rcAn.draw_as_glow = true
data:extend{rcAn}