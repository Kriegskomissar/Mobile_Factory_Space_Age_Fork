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
t erminal.tank_driving = false
terminal.collision_box = {{-0.8, -1.1}, {0.8, 1.1}}
terminal.selection_box = {{-1.2, -1.4}, {1.2, 1.4}}
terminal.map_color = {0.25, 0.25, 0.25}
data:extend{terminal}

-- Invisible collision walls keep the interior a finite room. The visible
-- boundary is made from hazard-concrete tiles by the runtime builder.
local wallPicture = {filename = "__core__/graphics/empty.png", width = 1, height = 1, frame_count = 1}

data:extend{
    {
        type = "simple-entity",
        name = "mf-interior-wall-horizontal",
        icon = "__base__/graphics/icons/stone-wall.png",
        flags = {"placeable-off-grid", "not-deconstructable", "not-blueprintable", "not-upgradable", "not-repairable"},
        selectable_in_game = false,
        collision_mask = {layers = {player = true, car = true, is_object = true}},
        collision_box = {{-100, -0.5}, {100, 0.5}},
        selection_box = {{0, 0}, {0, 0}},
        picture = wallPicture
    },
    {
        type = "simple-entity",
        name = "mf-interior-wall-vertical",
        icon = "__base__/graphics/icons/stone-wall.png",
        flags = {"placeable-off-grid", "not-deconstructable", "not-blueprintable", "not-upgradable", "not-repairable"},
        selectable_in_game = false,
        collision_mask = {layers = {player = true, car = true, is_object = true}},
        collision_box = {{-0.5, -100}, {0.5, 100}},
        selection_box = {{0, 0}, {0, 0}},
        picture = wallPicture
    }
}

-- This is the only electrical connection point for the factory interior.
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

local inventoryWall = {
    type = "simple-entity",
    name = "mf-interior-inventory-wall",
    icon = "__base__/graphics/icons/steel-chest.png",
    flags = {"placeable-off-grid", "not-deconstructable", "not-blueprintable", "not-upgradable", "not-repairable"},
    selectable_in_game = false,
    collision_box = {{0,0},{0,0}},
    selection_box = {{0,0},{0,0}},
    render_layer = "object",
    picture = {filename = "__base__/graphics/entity/steel-chest/steel-chest.png", priority = "extra-high", width = 48, height = 34, shift = {0.2, 0}}
}
data:extend{inventoryWall}

-- Mega Factory energy core. The visible shell reuses the vanilla nuclear
-- reactor graphics; the actual power conversion is direct nuclear-fuel ->
-- electricity with no heat or steam loop.
local reactorShell = table.deepcopy(data.raw.reactor["nuclear-reactor"])
reactorShell.name = "mf-energy-core-reactor-shell"
reactorShell.type = "simple-entity-with-owner"
reactorShell.flags = nil
reactorShell.minable = nil
reactorShell.next_upgrade = nil
reactorShell.destructible = false
reactorShell.selectable_in_game = false
reactorShell.collision_mask = {layers = {}}
reactorShell.selection_box = {{-2.4, -2.4}, {2.4, 2.4}}
reactorShell.collision_box = {{0, 0}, {0, 0}}
reactorShell.energy_source = {type = "void"}
reactorShell.consumption = "0W"
reactorShell.heat_buffer = nil
reactorShell.working_light_picture = nil
reactorShell.neighbour_bonus = nil
reactorShell.neighbour_connectable = nil
reactorShell.connection_patches_connected = nil
reactorShell.connection_patches_disconnected = nil
reactorShell.circuit_connector = nil
reactorShell.circuit_wire_max_distance = nil
data:extend{reactorShell}

local emptyAnimation = {
    north = {filename = "__core__/graphics/empty.png", width = 1, height = 1, frame_count = 1},
    east = {filename = "__core__/graphics/empty.png", width = 1, height = 1, frame_count = 1},
    south = {filename = "__core__/graphics/empty.png", width = 1, height = 1, frame_count = 1},
    west = {filename = "__core__/graphics/empty.png", width = 1, height = 1, frame_count = 1}
}

local coreGenerator = {
    type = "burner-generator",
    name = "mf-energy-core-generator",
    icon = "__base__/graphics/icons/nuclear-reactor.png",
    icon_size = 64,
    flags = {"placeable-off-grid", "not-deconstructable", "not-blueprintable", "not-upgradable", "not-repairable"},
    selectable_in_game = true,
    selection_priority = 250,
    collision_box = {{-2.4, -2.4}, {2.4, 2.4}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    burner = {type = "burner", fuel_inventory_size = 1, fuel_categories = {"nuclear"}, effectivity = 1, auto_refuel = false, emissions_per_minute = {}},
    energy_source = {type = "electric", usage_priority = "primary-output", output_flow_limit = "100MW"},
    max_power_output = "100MW",
    animation = emptyAnimation,
    idle_animation = emptyAnimation
}
data:extend{coreGenerator}

local coreAccumulator = table.deepcopy(data.raw.accumulator.accumulator)
coreAccumulator.name = "mf-energy-core-accumulator"
coreAccumulator.icon = "__base__/graphics/icons/accumulator.png"
coreAccumulator.minable = nil
coreAccumulator.next_upgrade = nil
coreAccumulator.destructible = false
coreAccumulator.selectable_in_game = false
coreAccumulator.collision_box = {{-2.4, -2.4}, {2.4, 2.4}}
coreAccumulator.selection_box = {{-2.5, -2.5}, {2.5, 2.5}}
coreAccumulator.energy_source.buffer_capacity = "100MJ"
coreAccumulator.energy_source.input_flow_limit = "100MW"
coreAccumulator.energy_source.output_flow_limit = "100MW"
data:extend{coreAccumulator}
