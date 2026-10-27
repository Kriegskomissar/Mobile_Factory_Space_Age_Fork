-- Dimensional Laboratory --

-- Prototype --
local dlP = table.deepcopy(data.raw.lab.lab)
dlP.name = "DimensionalLab"
dlP.inputs = {
        "DimensionalSample",
        "DimensionalCrystal"
    }
dlP.minable = {mining_time = 0.2, result = "DimensionalLab"}
dlP.order = "c"
dlP.on_animation =
    {
      layers =
      {
        {
            filename = "__Mobile_Factory_Space_Age__/mf_base/graphics/entities/DimensionalLab.png",
            width = 194,
            height = 174,
            frame_count = 33,
            line_length = 11,
            animation_speed = 1 / 3,
            shift = util.by_pixel(0, 1.5),
            scale = 0.5
        },
        {
            filename = "__base__/graphics/entity/lab/lab-integration.png",
            width = 242,
            height = 162,
            frame_count = 1,
            line_length = 1,
            repeat_count = 33,
            animation_speed = 1 / 3,
            shift = util.by_pixel(0, 15.5),
            scale = 0.5
        },
        {
            filename = "__base__/graphics/entity/lab/lab-shadow.png",
            width = 242,
            height = 136,
            frame_count = 1,
            line_length = 1,
            repeat_count = 33,
            animation_speed = 1 / 3,
            shift = util.by_pixel(13, 11),
            scale = 0.5,
            draw_as_shadow = true
        }
      }
    }
dlP.off_animation =
    {
      layers =
      {
        {
            filename = "__Mobile_Factory_Space_Age__/mf_base/graphics/entities/DimensionalLab.png",
            width = 194,
            height = 174,
            frame_count = 1,
            shift = util.by_pixel(0, 1.5),
            scale = 0.5
        },
        {
            filename = "__base__/graphics/entity/lab/lab-integration.png",
            width = 242,
            height = 162,
            frame_count = 1,
            shift = util.by_pixel(0, 15.5),
            scale = 0.5
        },
        {
            filename = "__base__/graphics/entity/lab/lab-shadow.png",
            width = 242,
            height = 136,
            frame_count = 1,
            shift = util.by_pixel(13, 11),
            draw_as_shadow = true,
            scale = 0.5
        }
      }
    }
data:extend{dlP}

-- Item --
local dlI = {}
dlI.type = "item"
dlI.name = "DimensionalLab"
dlI.icon = "__Mobile_Factory_Space_Age__/mf_base/graphics/items/DimensionalLab.png"
dlI.icon_size = 32
dlI.subgroup = "MFStructure"
dlI.order = "a"
dlI.place_result = "DimensionalLab"
dlI.stack_size = 10
data:extend{dlI}

-- Recipe --
local dlR = {}
dlR.type = "recipe"
dlR.name = "DimensionalLab"
dlR.energy_required = 5
dlR.ingredients =
    {
      {type="item", name="MachineFrame", amount=5},
    }
dlR.results = {
  {type="item", name="DimensionalLab", amount=1}
}
data:extend{dlR}