---------------------- ENERGY LASER 1 ----------------------
-- Entity --
local el1E = {}
el1E.type = "assembling-machine"
el1E.name = "EnergyLaser1"
el1E.icon = "__Mobile_Factory_Space_Age__/graphics/energy/EnergyLaser1I.png"
el1E.icon_size = 128
el1E.flags = {"placeable-neutral", "placeable-player", "player-creation"}
el1E.minable = {
    mining_time = 0.2,
    result = "EnergyLaser1"
}
el1E.max_health = 350
el1E.dying_explosion = "medium-explosion"
el1E.corpse = "medium-remnants"
el1E.alert_icon_shift = util.by_pixel(-3, -12)
el1E.resistances = {{
    type = "fire",
    percent = 70
}}
el1E.collision_box = {{-0.495, -0.49}, {0.495, 0.45}}
el1E.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
el1E.graphics_set = {
    animation = {
        west = {
            layers = {{
                filename = "__Mobile_Factory_Space_Age__/graphics/energy/EnergyLaser1G.png",
                priority = "high",
                width = 600,
                height = 600,
                frame_count = 1,
                scale = 1 / 18,
                draw_as_glow = true
            }, {
                filename = "__Mobile_Factory_Space_Age__/graphics/energy/EnergyLaser1E.png",
                priority = "high",
                width = 600,
                height = 600,
                frame_count = 1,
                scale = 1 / 18
            }, {
                filename = "__Mobile_Factory_Space_Age__/graphics/energy/EnergyLaserS.png",
                priority = "high",
                width = 600,
                height = 600,
                frame_count = 1,
                draw_as_shadow = true,
                scale = 1 / 18
            }}
        }
    }
}
el1E.graphics_set.animation.north = table.deepcopy(el1E.graphics_set.animation.west)
el1E.graphics_set.animation.north.layers[1].x = 600
el1E.graphics_set.animation.north.layers[2].x = 600
el1E.graphics_set.animation.east = table.deepcopy(el1E.graphics_set.animation.west)
el1E.graphics_set.animation.east.layers[1].x = 1200
el1E.graphics_set.animation.east.layers[2].x = 1200
el1E.graphics_set.animation.south = table.deepcopy(el1E.graphics_set.animation.west)
el1E.graphics_set.animation.south.layers[1].x = 1800
el1E.graphics_set.animation.south.layers[2].x = 1800
el1E.crafting_categories = {"Nothing"}
el1E.crafting_speed = 1
el1E.energy_source = {
    type = "electric",
    usage_priority = "secondary-input",
    buffer_capacity = "1J",
    output_flow_limit = "0W",
    input_flow_limit = "0W",
    drain = "0W",
    render_no_power_icon = false,
    render_no_network_icon = false
}
el1E.energy_usage = "1J"
el1E.fluid_boxes = {{
    volume = 1,
    pipe_connections = {{
        position = {0, 0.3},
        direction = defines.direction.north,
        flow_direction = "output"
    }},
    production_type = "output"
}}
data:extend{el1E}

-- Item --
local el1I = {}
el1I.type = "item"
el1I.name = "EnergyLaser1"
el1I.icon = "__Mobile_Factory_Space_Age__/graphics/energy/EnergyLaser1I.png"
el1I.icon_size = 128
el1I.place_result = "EnergyLaser1"
el1I.subgroup = "Energy"
el1I.order = "a1"
el1I.stack_size = 20
data:extend{el1I}

-- Recipe --
local el1R = {}
el1R.type = "recipe"
el1R.name = "EnergyLaser1"
el1R.energy_required = 5
el1R.enabled = false
el1R.ingredients = {{
    type = "item",
    name = "MachineFrame2",
    amount = 15
}, {
    type = "item",
    name = "DimensionalCircuit",
    amount = 3
}}
el1R.results = {{
    type = "item",
    name = "EnergyLaser1",
    amount = 1
}}
data:extend{el1R}

---------------------- ENERGY LASER 2 ----------------------

-- Entity --
local el2E = table.deepcopy(el1E)
el2E.name = "EnergyLaser2"
el2E.icon = "__Mobile_Factory_Space_Age__/graphics/energy/EnergyLaser2I.png"
el2E.minable = {
    mining_time = 0.2,
    result = "EnergyLaser2"
}
el2E.graphics_set = {
    animation = {
        west = {
            layers = {{
                filename = "__Mobile_Factory_Space_Age__/graphics/energy/EnergyLaser2G.png",
                priority = "high",
                width = 600,
                height = 600,
                frame_count = 1,
                scale = 1 / 18,
                draw_as_glow = true
            }, {
                filename = "__Mobile_Factory_Space_Age__/graphics/energy/EnergyLaser2E.png",
                priority = "high",
                width = 600,
                height = 600,
                frame_count = 1,
                scale = 1 / 18
            }, {
                filename = "__Mobile_Factory_Space_Age__/graphics/energy/EnergyLaserS.png",
                priority = "high",
                width = 600,
                height = 600,
                frame_count = 1,
                draw_as_shadow = true,
                scale = 1 / 18
            }}
        }
    }
}
el2E.graphics_set.animation.north = table.deepcopy(el2E.graphics_set.animation.west)
el2E.graphics_set.animation.north.layers[1].x = 600
el2E.graphics_set.animation.north.layers[2].x = 600
el2E.graphics_set.animation.east = table.deepcopy(el2E.graphics_set.animation.west)
el2E.graphics_set.animation.east.layers[1].x = 1200
el2E.graphics_set.animation.east.layers[2].x = 1200
el2E.graphics_set.animation.south = table.deepcopy(el2E.graphics_set.animation.west)
el2E.graphics_set.animation.south.layers[1].x = 1800
el2E.graphics_set.animation.south.layers[2].x = 1800
el2E.energy_source = {
    type = "electric",
    usage_priority = "secondary-input",
    buffer_capacity = "1J",
    output_flow_limit = "0W",
    input_flow_limit = "0W",
    drain = "0W",
    render_no_power_icon = false,
    render_no_network_icon = false
}
el2E.energy_usage = "1J"
data:extend{el2E}

-- Item --
local el2I = {}
el2I.type = "item"
el2I.name = "EnergyLaser2"
el2I.icon = "__Mobile_Factory_Space_Age__/graphics/energy/EnergyLaser2I.png"
el2I.icon_size = 128
el2I.place_result = "EnergyLaser2"
el2I.subgroup = "Energy"
el2I.order = "a2"
el2I.stack_size = 20
data:extend{el2I}

-- Recipe --
local el2R = {}
el2R.type = "recipe"
el2R.name = "EnergyLaser2"
el2R.energy_required = 5
el2R.enabled = false
el2R.ingredients = {{
    type = "item",
    name = "MachineFrame3",
    amount = 8
}, {
    type = "item",
    name = "CrystalizedCircuit",
    amount = 2
}}
el2R.results = {{
    type = "item",
    name = "EnergyLaser2",
    amount = 1
}}
data:extend{el2R}

---------------------- ENERGY LASER 3 ----------------------

-- Entity --
local el3E = table.deepcopy(el2E)
el3E.name = "EnergyLaser3"
el3E.icon = "__Mobile_Factory_Space_Age__/graphics/energy/EnergyLaser3I.png"
el3E.minable = {
    mining_time = 0.2,
    result = "EnergyLaser3"
}
el3E.graphics_set = {
    animation = {
        west = {
            layers = {{
                filename = "__Mobile_Factory_Space_Age__/graphics/energy/EnergyLaser3G.png",
                priority = "high",
                width = 600,
                height = 600,
                frame_count = 1,
                scale = 1 / 18,
                draw_as_glow = true
            }, {
                filename = "__Mobile_Factory_Space_Age__/graphics/energy/EnergyLaser3E.png",
                priority = "high",
                width = 600,
                height = 600,
                frame_count = 1,
                scale = 1 / 18
            }, {
                filename = "__Mobile_Factory_Space_Age__/graphics/energy/EnergyLaserS.png",
                priority = "high",
                width = 600,
                height = 600,
                frame_count = 1,
                draw_as_shadow = true,
                scale = 1 / 18
            }}
        }
    }
}
el3E.graphics_set.animation.north = table.deepcopy(el3E.graphics_set.animation.west)
el3E.graphics_set.animation.north.layers[1].x = 600
el3E.graphics_set.animation.north.layers[2].x = 600
el3E.graphics_set.animation.east = table.deepcopy(el3E.graphics_set.animation.west)
el3E.graphics_set.animation.east.layers[1].x = 1200
el3E.graphics_set.animation.east.layers[2].x = 1200
el3E.graphics_set.animation.south = table.deepcopy(el3E.graphics_set.animation.west)
el3E.graphics_set.animation.south.layers[1].x = 1800
el3E.graphics_set.animation.south.layers[2].x = 1800
el3E.energy_source = {
    type = "electric",
    usage_priority = "secondary-input",
    buffer_capacity = "1J",
    output_flow_limit = "0W",
    input_flow_limit = "0W",
    drain = "0W",
    render_no_power_icon = false,
    render_no_network_icon = false
}
el3E.energy_usage = "1J"
data:extend{el3E}

-- Item --
local el3I = {}
el3I.type = "item"
el3I.name = "EnergyLaser3"
el3I.icon = "__Mobile_Factory_Space_Age__/graphics/energy/EnergyLaser3I.png"
el3I.icon_size = 128
el3I.place_result = "EnergyLaser3"
el3I.subgroup = "Energy"
el3I.order = "a3"
el3I.stack_size = 20
data:extend{el3I}

-- Recipe --
local el3R = {}
el3R.type = "recipe"
el3R.name = "EnergyLaser3"
el3R.energy_required = 5
el3R.enabled = false
el3R.ingredients = {{
    type = "item",
    name = "MachineFrame3",
    amount = 8
}, {
    type = "item",
    name = "EnergyCore",
    amount = 1
}}
el3R.results = {{
    type = "item",
    name = "EnergyLaser3",
    amount = 1
}}
data:extend{el3R}

---------------------- QUATRON LASER 1 ----------------------

-- Entity --
local ql1E = {}
ql1E.type = "assembling-machine"
ql1E.name = "QuatronLaser1"
ql1E.icon = "__Mobile_Factory_Space_Age__/graphics/energy/QuatronLaser1I.png"
ql1E.icon_size = 128
ql1E.flags = {"placeable-neutral", "placeable-player", "player-creation"}
ql1E.minable = {
    mining_time = 0.2,
    result = "QuatronLaser1"
}
ql1E.max_health = 350
ql1E.dying_explosion = "medium-explosion"
ql1E.corpse = "medium-remnants"
ql1E.alert_icon_shift = util.by_pixel(-3, -12)
ql1E.resistances = {{
    type = "fire",
    percent = 70
}}
ql1E.collision_box = {{-0.495, -0.49}, {0.495, 0.45}}
ql1E.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
ql1E.graphics_set = {
    animation = {
        west = {
            layers = {{
                filename = "__Mobile_Factory_Space_Age__/graphics/energy/QuatronLaser1G.png",
                priority = "high",
                width = 600,
                height = 600,
                frame_count = 1,
                scale = 1 / 18,
                draw_as_glow = true
            }, {
                filename = "__Mobile_Factory_Space_Age__/graphics/energy/QuatronLaser1E.png",
                priority = "high",
                width = 600,
                height = 600,
                frame_count = 1,
                scale = 1 / 18
            }, {
                filename = "__Mobile_Factory_Space_Age__/graphics/energy/EnergyLaserS.png",
                priority = "high",
                width = 600,
                height = 600,
                frame_count = 1,
                draw_as_shadow = true,
                scale = 1 / 18
            }}
        }
    }
}
ql1E.graphics_set.animation.north = table.deepcopy(ql1E.graphics_set.animation.west)
ql1E.graphics_set.animation.north.layers[1].x = 600
ql1E.graphics_set.animation.north.layers[2].x = 600
ql1E.graphics_set.animation.east = table.deepcopy(ql1E.graphics_set.animation.west)
ql1E.graphics_set.animation.east.layers[1].x = 1200
ql1E.graphics_set.animation.east.layers[2].x = 1200
ql1E.graphics_set.animation.south = table.deepcopy(ql1E.graphics_set.animation.west)
ql1E.graphics_set.animation.south.layers[1].x = 1800
ql1E.graphics_set.animation.south.layers[2].x = 1800
ql1E.crafting_categories = {"Nothing"}
ql1E.crafting_speed = 1
ql1E.energy_source = {
    type = "electric",
    usage_priority = "secondary-input",
    buffer_capacity = "1J",
    output_flow_limit = "0W",
    input_flow_limit = "0W",
    drain = "0W",
    render_no_power_icon = false,
    render_no_network_icon = false
}
ql1E.energy_usage = "1J"
ql1E.fluid_boxes = {{
    volume = 1,
    pipe_connections = {{
        position = {0, 0.3},
        direction = defines.direction.north,
        flow_direction = "output"
    }},
    production_type = "output"
}}
data:extend{ql1E}

-- Item --
local ql1I = {}
ql1I.type = "item"
ql1I.name = "QuatronLaser1"
ql1I.icon = "__Mobile_Factory_Space_Age__/graphics/energy/QuatronLaser1I.png"
ql1I.icon_size = 128
ql1I.place_result = "QuatronLaser1"
ql1I.subgroup = "QuatronLogistic"
ql1I.order = "a1"
ql1I.stack_size = 20
data:extend{ql1I}

-- Recipe --
local ql1R = {}
ql1R.type = "recipe"
ql1R.name = "QuatronLaser1"
ql1R.energy_required = 5
ql1R.enabled = false
ql1R.ingredients = {{
    type = "item",
    name = "MachineFrame2",
    amount = 15
}, {
    type = "item",
    name = "DimensionalCircuit",
    amount = 3
}}
ql1R.results = {{
    type = "item",
    name = "QuatronLaser1",
    amount = 1
}}
data:extend{ql1R}

---------------------- QUATRON LASER 2 ----------------------

-- Entity --
local ql2E = table.deepcopy(ql1E)
ql2E.name = "QuatronLaser2"
ql2E.icon = "__Mobile_Factory_Space_Age__/graphics/energy/QuatronLaser2I.png"
ql2E.minable = {
    mining_time = 0.2,
    result = "QuatronLaser2"
}
ql2E.graphics_set = {
    animation = {
        west = {
            layers = {{
                filename = "__Mobile_Factory_Space_Age__/graphics/energy/QuatronLaser2G.png",
                priority = "high",
                width = 600,
                height = 600,
                frame_count = 1,
                scale = 1 / 18,
                draw_as_glow = true
            }, {
                filename = "__Mobile_Factory_Space_Age__/graphics/energy/QuatronLaser2E.png",
                priority = "high",
                width = 600,
                height = 600,
                frame_count = 1,
                scale = 1 / 18
            }, {
                filename = "__Mobile_Factory_Space_Age__/graphics/energy/EnergyLaserS.png",
                priority = "high",
                width = 600,
                height = 600,
                frame_count = 1,
                draw_as_shadow = true,
                scale = 1 / 18
            }}
        }
    }
}
ql2E.graphics_set.animation.north = table.deepcopy(ql2E.graphics_set.animation.west)
ql2E.graphics_set.animation.north.layers[1].x = 600
ql2E.graphics_set.animation.north.layers[2].x = 600
ql2E.graphics_set.animation.east = table.deepcopy(ql2E.graphics_set.animation.west)
ql2E.graphics_set.animation.east.layers[1].x = 1200
ql2E.graphics_set.animation.east.layers[2].x = 1200
ql2E.graphics_set.animation.south = table.deepcopy(ql2E.graphics_set.animation.west)
ql2E.graphics_set.animation.south.layers[1].x = 1800
ql2E.graphics_set.animation.south.layers[2].x = 1800
ql2E.energy_source = {
    type = "electric",
    usage_priority = "secondary-input",
    buffer_capacity = "1J",
    output_flow_limit = "0W",
    input_flow_limit = "0W",
    drain = "0W",
    render_no_power_icon = false,
    render_no_network_icon = false
}
ql2E.energy_usage = "1J"
data:extend{ql2E}

-- Item --
local ql2I = {}
ql2I.type = "item"
ql2I.name = "QuatronLaser2"
ql2I.icon = "__Mobile_Factory_Space_Age__/graphics/energy/QuatronLaser2I.png"
ql2I.icon_size = 128
ql2I.place_result = "QuatronLaser2"
ql2I.subgroup = "QuatronLogistic"
ql2I.order = "a2"
ql2I.stack_size = 20
data:extend{ql2I}

-- Recipe --
local ql2R = {}
ql2R.type = "recipe"
ql2R.name = "QuatronLaser2"
ql2R.energy_required = 5
ql2R.enabled = false
ql2R.ingredients = {{
    type = "item",
    name = "MachineFrame3",
    amount = 8
}, {
    type = "item",
    name = "CrystalizedCircuit",
    amount = 2
}}
ql2R.results = {{
    type = "item",
    name = "QuatronLaser2",
    amount = 1
}}
data:extend{ql2R}

---------------------- QUATRON LASER 3 ----------------------

-- Entity --
local ql3E = table.deepcopy(ql2E)
ql3E.name = "QuatronLaser3"
ql3E.icon = "__Mobile_Factory_Space_Age__/graphics/energy/QuatronLaser3I.png"
ql3E.minable = {
    mining_time = 0.2,
    result = "QuatronLaser3"
}
ql3E.graphics_set = {
    animation = {
        west = {
            layers = {{
                filename = "__Mobile_Factory_Space_Age__/graphics/energy/QuatronLaser3G.png",
                priority = "high",
                width = 600,
                height = 600,
                frame_count = 1,
                scale = 1 / 18,
                draw_as_glow = true
            }, {
                filename = "__Mobile_Factory_Space_Age__/graphics/energy/QuatronLaser3E.png",
                priority = "high",
                width = 600,
                height = 600,
                frame_count = 1,
                scale = 1 / 18
            }, {
                filename = "__Mobile_Factory_Space_Age__/graphics/energy/EnergyLaserS.png",
                priority = "high",
                width = 600,
                height = 600,
                frame_count = 1,
                draw_as_shadow = true,
                scale = 1 / 18
            }}
        }
    }
}
ql3E.graphics_set.animation.north = table.deepcopy(ql3E.graphics_set.animation.west)
ql3E.graphics_set.animation.north.layers[1].x = 600
ql3E.graphics_set.animation.north.layers[2].x = 600
ql3E.graphics_set.animation.east = table.deepcopy(ql3E.graphics_set.animation.west)
ql3E.graphics_set.animation.east.layers[1].x = 1200
ql3E.graphics_set.animation.east.layers[2].x = 1200
ql3E.graphics_set.animation.south = table.deepcopy(ql3E.graphics_set.animation.west)
ql3E.graphics_set.animation.south.layers[1].x = 1800
ql3E.graphics_set.animation.south.layers[2].x = 1800
ql3E.energy_source = {
    type = "electric",
    usage_priority = "secondary-input",
    buffer_capacity = "1J",
    output_flow_limit = "0W",
    input_flow_limit = "0W",
    drain = "0W",
    render_no_power_icon = false,
    render_no_network_icon = false
}
ql3E.energy_usage = "1J"
data:extend{ql3E}

-- Item --
local ql3I = {}
ql3I.type = "item"
ql3I.name = "QuatronLaser3"
ql3I.icon = "__Mobile_Factory_Space_Age__/graphics/energy/QuatronLaser3I.png"
ql3I.icon_size = 128
ql3I.place_result = "QuatronLaser3"
ql3I.subgroup = "QuatronLogistic"
ql3I.order = "a3"
ql3I.stack_size = 20
data:extend{ql3I}

-- Recipe --
local ql3R = {}
ql3R.type = "recipe"
ql3R.name = "QuatronLaser3"
ql3R.energy_required = 5
ql3R.enabled = false
ql3R.ingredients = {{
    type = "item",
    name = "MachineFrame3",
    amount = 8
}, {
    type = "item",
    name = "EnergyCore",
    amount = 1
}}
ql3R.results = {{
    type = "item",
    name = "QuatronLaser3",
    amount = 1
}}
data:extend{ql3R}
