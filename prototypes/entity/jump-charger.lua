---------------------------------- JUMP CHARGER EQUIPMENT ----------------------------------
--
-- Jump Charger is a specialised capacitor for the Jump Drive.
-- It is deliberately separate from ordinary equipment-grid batteries:
-- normal batteries are general-purpose grid storage, while the Jump Charger
-- is the dedicated high-capacity buffer that the Jump Drive consumes directly.
--
-- One charger stores 5 GJ and accepts up to 100 MW from the equipment grid.
-- Multiple chargers may be installed; their capacities are added together.
--
-- Each charger occupies a 2x5 block in the equipment grid.

local chargerIcon = "__Mobile_Factories_Onboard_Production__/graphics/entity/JumpChargerE.png"

local charger = {
    type = "battery-equipment",
    name = "JumpCharger",
    sprite = {
        filename = chargerIcon,
        width = 128,
        height = 128,
        priority = "medium"
    },
    shape = {
        width = 2,
        height = 5,
        type = "full"
    },
    energy_source = {
        type = "electric",
        buffer_capacity = "5GJ",
        input_flow_limit = "100MW",
        output_flow_limit = "0W",
        usage_priority = "tertiary"
    },
    categories = {"mfEquipments"},
    order = "d"
}

data:extend{charger}

data:extend{
    {
        type = "item",
        name = "JumpCharger",
        icon = chargerIcon,
        icon_size = 128,
        subgroup = "MobileFactory",
        order = "d",
        stack_size = 1
    },
    {
        type = "recipe",
        name = "JumpCharger",
        enabled = false,
        energy_required = 15,
        ingredients = {
            {type = "item", name = "battery-equipment", amount = 10},
            {type = "item", name = "accumulator", amount = 5},
            {type = "item", name = "electronic-circuit", amount = 50},
            {type = "item", name = "steel-plate", amount = 50}
        },
        results = {{type = "item", name = "JumpCharger", amount = 1}}
    },
    {
        type = "technology",
        name = "JumpCharger",
        icon = chargerIcon,
        icon_size = 128,
        unit = {
            count = 100,
            time = 60,
            ingredients = {
                {"space-science-pack", 1}
            }
        },
        -- The technology graph gate is the vanilla Personal Battery equipment.
        -- The Jump Charger does not require Jump Drive research as a graph
        -- prerequisite; it is independently available once personal battery
        -- equipment has been researched.
        prerequisites = {"battery-equipment"},
        effects = {{
            type = "unlock-recipe",
            recipe = "JumpCharger"
        }}
    }
}
