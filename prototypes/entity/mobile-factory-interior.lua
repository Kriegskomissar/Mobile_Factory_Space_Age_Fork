-- MOBILE FACTORY INTERIOR PROTOTYPES ----------------------------------------

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

local energy = {
    type = "electric-energy-interface",
    name = "mf-interior-energy-interface",
    icon = "__base__/graphics/icons/accumulator.png",
    icon_size = 64,
    flags = {"placeable-off-grid", "not-deconstructable", "not-blueprintable", "not-upgradable", "not-repairable", "not-on-map"},
    selectable_in_game = false,
    collision_box = {{-0.5, -0.5}, {0.5, 0.5}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    energy_source = {type="electric", buffer_capacity="10GJ", usage_priority="tertiary", input_flow_limit="100MW", output_flow_limit="100MW"},
    energy_production = "0W",
    energy_usage = "0W",
    picture = {filename="__core__/graphics/empty.png", width=1, height=1}
}
data:extend{energy}

-- Decorative inventory wall: the perimeter is literally rendered as a
-- continuous line of steel chests, representing the Mobile Factory inventory.
local inventoryWall = {
    type = "simple-entity",
    name = "mf-interior-inventory-wall",
    icon = "__base__/graphics/icons/steel-chest.png",
    flags = {"placeable-off-grid", "not-deconstructable", "not-blueprintable", "not-upgradable", "not-repairable"},
    selectable_in_game = false,
    collision_box = {{0,0},{0,0}},
    selection_box = {{0,0},{0,0}},
    render_layer = "object",
    picture = {
        filename = "__base__/graphics/entity/steel-chest/steel-chest.png",
        priority = "extra-high",
        width = 48,
        height = 34,
        shift = {0.2, 0}
    }
}
data:extend{inventoryWall}
