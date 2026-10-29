-- MOBILE FACTORY INTERIOR PROTOTYPES ----------------------------------------

-- A real car is used as the interior terminal so Factorio's native Enter key
-- and driving events can be reused. Runtime code immediately transfers the
-- driver to the Mobile Factory, so the car never becomes a second vehicle.
local terminal = table.deepcopy(data.raw.car.car)
terminal.name = "mf-interior-terminal-car"
terminal.icon = "__base__/graphics/icons/car.png"
terminal.flags = {"placeable-off-grid", "not-deconstructable", "not-blueprintable", "not-upgradable", "not-repairable"}
terminal.minable = nil
terminal.max_health = 1000000
terminal.destructible = false
terminal.selectable_in_game = true
terminal.allow_copy_paste = false
terminal.inventory_size = 0
terminal.trash_inventory_size = 0
terminal.guns = nil
terminal.energy_source = {type = "void"}
terminal.consumption = "1W"
terminal.effectivity = 1
terminal.max_speed = 0.01
terminal.braking_power = "1000MW"
terminal.rotation_speed = 0.01 / 60
terminal.acceleration_per_sec = 0
terminal.tank_driving = false
terminal.collision_box = {{-0.8, -1.1}, {0.8, 1.1}}
terminal.selection_box = {{-1.2, -1.4}, {1.2, 1.4}}
terminal.map_color = {0.25, 0.25, 0.25}
data:extend{terminal}

-- This is the visible Factorissimo-style connection point. Its supply area
-- covers the entire interior even for the 60x60 Mega floor, while its circuit
-- connectors can be linked to the interior pole across surfaces by script.
local power = table.deepcopy(data.raw["electric-pole"].substation)
power.name = "mf-interior-power-interface"
power.icon = "__base__/graphics/icons/substation.png"
power.minable = nil
power.flags = {"placeable-off-grid", "not-deconstructable", "not-blueprintable", "not-upgradable", "not-repairable"}
power.selectable_in_game = true
power.allow_copy_paste = false
power.supply_area_distance = 32
power.maximum_wire_distance = 64
power.auto_connect_up_to_n_wires = 0
power.selection_priority = 200
data:extend{power}

-- Hidden energy buffers form the actual cross-surface electrical bridge. The
-- visible poles remain normal circuit/power connection points for the player.
local energy = {
    type = "electric-energy-interface",
    name = "mf-interior-energy-interface",
    icon = "__base__/graphics/icons/accumulator.png",
    icon_size = 64,
    flags = {"placeable-off-grid", "not-deconstructable", "not-blueprintable", "not-upgradable", "not-repairable", "not-on-map"},
    selectable_in_game = false,
    collision_box = {{-0.5, -0.5}, {0.5, 0.5}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    energy_source = {
        type = "electric",
        buffer_capacity = "10GJ",
        usage_priority = "tertiary",
        input_flow_limit = "100MW",
        output_flow_limit = "100MW"
    },
    energy_production = "0W",
    energy_usage = "0W",
    picture = {filename = "__core__/graphics/empty.png", width = 1, height = 1}
}
data:extend{energy}
