---------------------- CRYSTALLISER ----------------------

-- Entity --
local cE = {}
cE.type = "assembling-machine"
cE.name = "Crystallizer"
cE.icon = "__Mobile_Factory_Space_Age__/mf_base/graphics/items/Crystallizer.png"
cE.icon_size = 32
cE.flags = {"placeable-neutral", "placeable-player", "player-creation"}
cE.minable = {mining_time = 0.2, result = "Crystallizer"}
cE.max_health = 350
cE.dying_explosion = "medium-explosion"
cE.corpse = "medium-remnants"
cE.alert_icon_shift = util.by_pixel(-3, -12)
cE.resistances =
    {
      {
        type = "fire",
        percent = 70
      }
    }
cE.fluid_boxes =
    {
      {
        production_type = "input",
        pipe_picture = table.deepcopy(require("__base__/prototypes/entity/assembler-pictures").assembler2pipepictures),
        pipe_covers = pipecoverspictures(),
        volume = 10,
        pipe_connections = {{ flow_direction="input", position = {0, -1}, direction=defines.direction.north }},
        secondary_draw_orders = { north = -1 }
      },
      {
        production_type = "output",
        pipe_picture = table.deepcopy(require("__base__/prototypes/entity/assembler-pictures").assembler2pipepictures),
        pipe_covers = pipecoverspictures(),
        volume = 10,
        pipe_connections = {{ flow_direction="output", position = {0, 1}, direction=defines.direction.south }},
        secondary_draw_orders = { north = -1 }
      },
    }
cE.fluid_boxes_off_when_no_fluid_recipe = true
cE.collision_box = {{-1.2, -1.2}, {1.2, 1.2}}
cE.selection_box = {{-1.5, -1.5}, {1.5, 1.5}}
cE.graphics_set = {
  animation =
    {
      layers =
      {
        {
            filename = "__Mobile_Factory_Space_Age__/mf_base/graphics/entities/Crystallizer.png",
            priority = "high",
            width = 214,
            height = 218,
            frame_count = 32,
            line_length = 8,
            shift = util.by_pixel(0, 4),
            scale = 0.5
        },
        util.sprite_load("__base__/graphics/entity/assembling-machine-2/assembling-machine-2-shadow",
        {
            priority = "high",
            repeat_count = 32,
            draw_as_shadow = true,
            scale = 0.5
        })
      }
    }
  }
cE.open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 }
cE.close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 }
cE.vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 }
cE.working_sound =
    {
      sound =
      {
        {
          filename = "__base__/sound/assembling-machine-t2-1.ogg",
          volume = 0.8
        },
        {
          filename = "__base__/sound/assembling-machine-t2-2.ogg",
          volume = 0.8
        }
      },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 1.5
    }
cE.crafting_categories = {"DimensionalCrystallizaton"}

cE.crafting_speed = 1
cE.energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = {pollution = 3}
    }
cE.energy_usage = "800kW"
cE.module_specification =
    {
      module_slots = 2
    }
cE.allowed_effects = {"consumption", "speed", "productivity", "pollution"}
data:extend{cE}

-- Item --
local cI = {}
cI.type = "item"
cI.name = "Crystallizer"
cI.icon = "__Mobile_Factory_Space_Age__/mf_base/graphics/items/Crystallizer.png"
cI.icon_size = 32
cI.place_result = "Crystallizer"
cI.subgroup = "MFStructure"
cI.order = "c"
cI.stack_size = 5
data:extend{cI}

-- Recipe --
local cR = {}
cR.type = "recipe"
cR.name = "Crystallizer"
cR.energy_required = 5
cR.enabled = false
cR.ingredients =
    {
      {type="item", name="MachineFrame2", amount=8},
      {type="item", name="DimensionalCircuit", amount=35}
    }
cR.results = {
  {type="item", name="Crystallizer", amount=1}
}
data:extend{cR}
