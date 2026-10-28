---------------------------------- JUMP DRIVE EQUIPMENT ----------------------------------
--
-- Jump Drive is equipment installed in a Mobile Factory equipment grid.
-- It is the actual teleport mechanism and has no usable internal battery.
-- Its energy pulse is supplied exclusively by installed Jump Chargers.
--
-- Energy model:
--   E = 100 MJ * mass(t) * distance(km)
--
-- Drive Marks define the maximum pulse power and therefore the maximum time
-- for a jump. They do not make the jump cheaper:
--   Mk.I   = 120 MW, 10 s
--   Mk.II  = 240 MW, 5 s
--   Mk.III = 1.2 GW, 1 s
--
-- All marks occupy a 5x5 block in the equipment grid.

local function createJumpDrive(name, icon, power, maxTime, order)
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
            shape = {
                width = 5,
                height = 5,
                type = "full"
            },
            -- The Drive itself does not store meaningful energy and cannot
            -- receive or output power through the normal equipment grid.
            -- Jump Drive runtime logic consumes energy from Jump Charger(s).
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
            subgroup = "MobileFactory",
            order = order,
            stack_size = 1
        },
        {
            type = "recipe",
            name = name,
            enabled = false,
            energy_required = 20,
            ingredients = {
                {type = "item", name = "steel-plate", amount = 50},
                {type = "item", name = "processing-unit", amount = 50},
                {type = "item", name = "battery", amount = 20}
            },
            results = {{type = "item", name = name, amount = 1}}
        }
    }

    -- Runtime Jump Drive object reads these custom prototype fields.
    data.raw["battery-equipment"][name].mf_jump_power = power
    data.raw["battery-equipment"][name].mf_jump_max_time = maxTime
end

local icon = "__Mobile_Factory_Space_Age__/graphics/entity/JumpDriveE.png"

createJumpDrive("JumpDrive-Mk1", icon, 120e6, 10, "a")
createJumpDrive("JumpDrive-Mk2", icon, 240e6, 5, "b")
createJumpDrive("JumpDrive-Mk3", icon, 1.2e9, 1, "c")

---------------------------------- TECHNOLOGIES ----------------------------------

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
                ingredients = {
                    {"space-science-pack", 1}
                }
            },
            prerequisites = {prerequisite},
            effects = {{
                type = "unlock-recipe",
                recipe = recipe
            }},
            order = order
        }
    }
end

createJumpDriveTechnology("JumpDrive", "rocket-silo", "JumpDrive-Mk1", 100, "a")
createJumpDriveTechnology("JumpDrive-Mk2", "JumpDrive", "JumpDrive-Mk2", 250, "b")
createJumpDriveTechnology("JumpDrive-Mk3", "JumpDrive-Mk2", "JumpDrive-Mk3", 500, "c")
