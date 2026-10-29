---------------------- Control Center Technology ---------------------

local CC = {}
CC.name = "ControlCenter"
CC.type = "technology"
CC.icon = "__Mobile_Factories_Onboard_Production__/graphics/icons/ControlCenterT.png"
CC.icon_size = 256
CC.unit = {
    count = 300,
    time = 30,
    ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"military-science-pack", 1}
    }
}
CC.prerequisites = {"MobileFactory"}
CC.effects = {
    {type = "nothing", effect_description = {"description.ControlCenter"}}
}
data:extend{CC}

local ca1T = {}
ca1T.name = "ConstructibleArea1"
ca1T.type = "technology"
ca1T.icons = {
    {icon = "__base__/graphics/terrain/tutorial-grid/tutorial-grid-o.png", tint = {32, 165, 3}}
}
ca1T.icon_size = 32
ca1T.unit = {
    count = 300,
    time = 30,
    ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1}
    }
}
ca1T.prerequisites = {"ControlCenter"}
ca1T.effects = {{type = "nothing", effect_description = {"description.ConstructibleArea1"}}}
data:extend{ca1T}

local ca2T = {}
ca2T.name = "ConstructibleArea2"
ca2T.type = "technology"
ca2T.icons = {
    {icon = "__base__/graphics/terrain/tutorial-grid/tutorial-grid-o.png", tint = {32, 165, 3}}
}
ca2T.icon_size = 32
ca2T.unit = {
    count = 600,
    time = 30,
    ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"military-science-pack", 1}
    }
}
ca2T.prerequisites = {"ConstructibleArea1"}
ca2T.effects = {{type = "nothing", effect_description = {"description.ConstructibleArea2"}}}
data:extend{ca2T}
