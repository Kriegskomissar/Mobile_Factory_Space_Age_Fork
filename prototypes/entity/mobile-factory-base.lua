-- THE BASE MOBILE FACTORY PROTOTYPE ------------------------------------------
-- The Small Factory is deliberately based on the vanilla tank. Higher tiers
-- are clones of this vehicle so Factorio keeps its native vehicle physics,
-- collision handling and driving model.

local mf = table.deepcopy(data.raw.car.tank)
mf.name = "SmallFactory"
mf.order = "a"
mf.minable = {
    mining_time = 1.5,
    result = "SmallFactory"
}
mf.inventory_size = 160
mf.max_health = 2500
mf.collision_mask = {
    layers = {
        player = true,
        car = true,
        train = true,
        is_object = true,
        layer_52 = true
    },
    consider_tile_transitions = true,
    not_colliding_with_itself = true
}
mf.emissions_per_second = {pollution = 0.005}
mf.consumption = "700kW"
mf.effectivity = 1
mf.weight = 25000
mf.braking_power = "600kW"
mf.rotation_speed = 0.30 / 60
mf.guns = {"mfTank-machine-gun"}
mf.collision_box = {{-1.5, -2.5}, {1.0, 2.5}}
mf.selection_box = {{-2, -3.5}, {1.6, 2.5}}
mf.animation = {
    layers = {{
        priority = "low",
        width = 269,
        height = 212,
        frame_count = 2,
        direction_count = 64,
        shift = util.by_pixel(-4.75, -10),
        animation_speed = 8,
        max_advance = 1,
        scale = 1,
        stripes = {{
            filename = "__base__/graphics/entity/tank/tank-base-1.png",
            width_in_frames = 2,
            height_in_frames = 16
        }, {
            filename = "__base__/graphics/entity/tank/tank-base-2.png",
            width_in_frames = 2,
            height_in_frames = 16
        }, {
            filename = "__base__/graphics/entity/tank/tank-base-3.png",
            width_in_frames = 2,
            height_in_frames = 16
        }, {
            filename = "__base__/graphics/entity/tank/tank-base-4.png",
            width_in_frames = 2,
            height_in_frames = 16
        }}
    }, {
        priority = "low",
        width = 207,
        height = 166,
        frame_count = 2,
        direction_count = 64,
        shift = util.by_pixel(-4.75, -21),
        max_advance = 1,
        line_length = 2,
        stripes = util.multiplystripes(2, {{
            filename = "__base__/graphics/entity/tank/tank-base-mask-1.png",
            width_in_frames = 1,
            height_in_frames = 22
        }, {
            filename = "__base__/graphics/entity/tank/tank-base-mask-2.png",
            width_in_frames = 1,
            height_in_frames = 22
        }, {
            filename = "__base__/graphics/entity/tank/tank-base-mask-3.png",
            width_in_frames = 1,
            height_in_frames = 20
        }}),
        scale = 1
    }, {
        priority = "low",
        width = 301,
        height = 194,
        frame_count = 2,
        draw_as_shadow = true,
        direction_count = 64,
        shift = util.by_pixel(17.75, 7),
        max_advance = 1,
        stripes = util.multiplystripes(2, {{
            filename = "__base__/graphics/entity/tank/tank-base-shadow-1.png",
            width_in_frames = 1,
            height_in_frames = 16
        }, {
            filename = "__base__/graphics/entity/tank/tank-base-shadow-2.png",
            width_in_frames = 1,
            height_in_frames = 16
        }, {
            filename = "__base__/graphics/entity/tank/tank-base-shadow-3.png",
            width_in_frames = 1,
            height_in_frames = 16
        }, {
            filename = "__base__/graphics/entity/tank/tank-base-shadow-4.png",
            width_in_frames = 1,
            height_in_frames = 16
        }}),
        scale = 1
    }}
}
mf.turret_animation = {
    layers = {{
        filename = "__base__/graphics/entity/tank/tank-turret.png",
        priority = "low",
        line_length = 8,
        width = 179,
        height = 132,
        frame_count = 1,
        direction_count = 64,
        shift = util.by_pixel(-4.75, -50),
        animation_speed = 8,
        scale = 1
    }, {
        filename = "__base__/graphics/entity/tank/tank-turret-mask.png",
        priority = "low",
        line_length = 8,
        width = 72,
        height = 66,
        frame_count = 1,
        direction_count = 64,
        shift = util.by_pixel(-5, -50),
        scale = 1
    }, {
        filename = "__base__/graphics/entity/tank/tank-turret-shadow.png",
        priority = "low",
        line_length = 8,
        width = 193,
        height = 134,
        frame_count = 1,
        draw_as_shadow = true,
        direction_count = 64,
        shift = util.by_pixel(51.25, 6.5),
        animation_speed = 8,
        scale = 1
    }}
}
data:extend{mf}

-- Small Factory item ---------------------------------------------------------
local mfI = {
    type = "item-with-entity-data",
    name = "SmallFactory",
    icon = "__Mobile_Factories_Onboard_Production__/graphics/mobile-factory/tank.png",
    icon_size = 256,
    place_result = "SmallFactory",
    subgroup = "MobileFactory",
    order = "a",
    stack_size = 1,
    weight = 1 * tons
}
data:extend{mfI}

local mfR = {
    type = "recipe",
    name = "SmallFactory",
    enabled = false,
    energy_required = 30,
    ingredients = {
        {type = "item", name = "tank", amount = 5},
        {type = "item", name = "iron-gear-wheel", amount = 1500},
        {type = "item", name = "electronic-circuit", amount = 100},
        {type = "item", name = "engine-unit", amount = 200},
        {type = "item", name = "steel-plate", amount = 200},
        {type = "item", name = "medium-electric-pole", amount = 10},
        {type = "item", name = "car", amount = 1},
        {type = "item", name = "stone-brick", amount = 500},
        {type = "item", name = "iron-chest", amount = 20}
    },
    results = {{type = "item", name = "SmallFactory", amount = 1}}
}
data:extend{mfR}

local mfT = {
    name = "SmallFactory",
    type = "technology",
    icon = "__Mobile_Factories_Onboard_Production__/graphics/mobile-factory/tank.png",
    icon_size = 256,
    unit = {
        count = 250,
        time = 30,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"military-science-pack", 1}
        }
    },
    prerequisites = {"tank"},
    effects = {{type = "unlock-recipe", recipe = "SmallFactory"}}
}
data:extend{mfT}

-- Clone the vanilla tank rather than implementing custom vehicle physics.
function createNewMF(name, color, size, order, icon)
    local nMFE = table.deepcopy(data.raw.car.SmallFactory)
    nMFE.name = name
    nMFE.order = order
    nMFE.minable = {mining_time = 1.5, result = name}

    nMFE.animation.layers[2].tint = color
    nMFE.turret_animation.layers[2].tint = color
    for _, layer in pairs(nMFE.animation.layers) do layer.scale = size end
    for _, layer in pairs(nMFE.turret_animation.layers) do layer.scale = size end

    nMFE.turret_animation.layers[1].shift = util.by_pixel(-4.75, -50 * size)
    nMFE.turret_animation.layers[2].shift = util.by_pixel(-5, -50 * size)
    nMFE.turret_animation.layers[3].shift = util.by_pixel(51.25, 6.5 * size)

    nMFE.collision_box = {{-1.5 * size, -2.5 * size}, {1.0 * size, 2.5 * size}}
    nMFE.selection_box = {{-2 * size, -3.5 * size}, {1.6 * size, 2.5 * size}}
    nMFE.max_health = mf.max_health * size
    nMFE.weight = mf.weight * size

    data:extend{nMFE}

    local nMFI = table.deepcopy(data.raw["item-with-entity-data"].SmallFactory)
    nMFI.name = name
    nMFI.order = order
    nMFI.icon = icon
    nMFI.place_result = name
    data:extend{nMFI}

    local nMFR = table.deepcopy(data.raw.recipe.SmallFactory)
    nMFR.name = name
    nMFR.results = {{type = "item", name = name, amount = 1}}
    nMFR.enabled = false
    data:extend{nMFR}

    local nMFT = {
        name = name,
        type = "technology",
        icon = icon,
        icon_size = 256,
        unit = {
            count = 1000,
            time = 60,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"military-science-pack", 1}
            }
        },
        prerequisites = {"SmallFactory"},
        effects = {{type = "unlock-recipe", recipe = name}}
    }
    data:extend{nMFT}
end
