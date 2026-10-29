---------------------------------- JUMP DRIVE EQUIPMENT --------------------
-- Jump Drive is equipment installed in a Mobile Factory equipment grid.
-- It has no usable internal battery; its jump pulse is supplied by Jump Chargers.

local function createJumpDrive(name, icon, power, maxTime, order, ingredients)
    data:extend{
        {
            type = "battery-equipment",
            name = name,
            sprite = {
                filename = icon,
                width = 128,
                height = 128,
                priority = "medium"
            },
            shape = {width = 5, height = 5, type = "full"},
            energy_source = {
                type = "electric",
                buffer_capacity = "1J",
                input_flow_limit = "0W",
                output_flow_limit = "0W",
                usage_priority = "tertiary"
            },
            categories = {"mfEquipments"},
            order = order
        },
        {
            type = "item",
            name = name,
            icon = icon,
            icon_size = 128,
            place_as_equipment_result = name,
            subgroup = "MobileFactory",
            order = order,
            stack_size = 1,
            weight = 200 * kg
        },
        {
            type = "recipe",
            name = name,
            enabled = false,
            energy_required = 20,
            ingredients = ingredients,
            results = {{type = "item", name = name, amount = 1}}
        }
    }

    data.raw["battery-equipment"][name].mf_jump_power = power
    data.raw["battery-equipment"][name].mf_jump_max_time = maxTime
end

local icon = "__Mobile_Factories_Onboard_Production__/graphics/entity/JumpDriveE.png"

createJumpDrive("JumpDrive-Mk1", icon, 120e6, 10, "a", {
    {type = "item", name = "battery", amount = 20},
    {type = "item", name = "electric-engine-unit", amount = 20},
    {type = "item", name = "belt-immunity-equipment", amount = 10},
    {type = "item", name = "electronic-circuit", amount = 100}
})

createJumpDrive("JumpDrive-Mk2", icon, 240e6, 5, "b", {
    {type = "item", name = "battery", amount = 50},
    {type = "item", name = "electric-engine-unit", amount = 50},
    {type = "item", name = "belt-immunity-equipment", amount = 20},
    {type = "item", name = "processing-unit", amount = 300}
})

createJumpDrive("JumpDrive-Mk3", icon, 1.2e9, 1, "c", {
    {type = "item", name = "battery", amount = 100},
    {type = "item", name = "electric-engine-unit", amount = 100},
    {type = "item", name = "belt-immunity-equipment", amount = 50},
    {type = "item", name = "processing-unit", amount = 500},
    {type = "item", name = "holmium-plate", amount = 100}
})

---------------------------------- TECHNOLOGIES -------------------------------
local function createJumpDriveTechnology(name, prerequisite, recipe, count, order)
    data:extend{
        {
            type = "technology",
            name = name,
            icon = icon,
            icon_size = 128,
            unit = {
                count = count,
                time = 60,
                ingredients = {{"space-science-pack", 1}}
            },
            prerequisites = {prerequisite},
            effects = {{type = "unlock-recipe", recipe = recipe}},
            order = order
        }
    }
end

createJumpDriveTechnology("JumpDrive", "rocket-silo", "JumpDrive-Mk1", 100, "a")
createJumpDriveTechnology("JumpDrive-Mk2", "JumpDrive", "JumpDrive-Mk2", 250, "b")
createJumpDriveTechnology("JumpDrive-Mk3", "JumpDrive-Mk2", "JumpDrive-Mk3", 500, "c")
