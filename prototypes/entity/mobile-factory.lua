-- MOBILE FACTORY PROTOTYPE AND UPGRADE --
require("prototypes/entity/mobile-factory-base.lua")

local function setFactoryResistances(factory, percent)
    factory.resistances = {
        {type = "physical", percent = percent},
        {type = "impact", percent = percent},
        {type = "explosion", percent = percent},
        {type = "fire", percent = percent},
        {type = "acid", percent = percent},
        {type = "poison", percent = percent},
        {type = "laser", percent = percent},
        {type = "electric", percent = percent}
    }
    factory.energy_per_hit_point = data.raw.car.tank.energy_per_hit_point
end

-- Small Factory: 10% damage reduction.
setFactoryResistances(data.raw.car.SmallFactory, 10)

-- Super Factory --
createNewMF("SuperFactory", {0.55, 0.80, 1.0}, 2.0, "b", "__Mobile_Factory_Space_Age__/graphics/mobile-factory/QuickMF.png")
data.raw.car.SuperFactory.consumption = "1000kW"
data.raw.car.SuperFactory.effectivity = 2.3
data.raw.car.SuperFactory.rotation_speed = 0.30 / 60
data.raw.car.SuperFactory.turret_rotation_speed = 0.55 / 60
data.raw.car.SuperFactory.turret_return_timeout = 120
data.raw.car.SuperFactory.equipment_grid = "MFEquipmentGrid"
data.raw.car.SuperFactory.inventory_size = 300
data.raw.car.SuperFactory.guns = {
    "mfTank-machine-gun",
    "mfTank-cannon"
}
setFactoryResistances(data.raw.car.SuperFactory, 20)

-- Mega Factory --
createNewMF("MegaFactory", {1.0, 0.55, 0.20}, 3.0, "c", "__Mobile_Factory_Space_Age__/graphics/mobile-factory/HMF.png")
data.raw.car.MegaFactory.consumption = "15000kW"
data.raw.car.MegaFactory.effectivity = 0.8
data.raw.car.MegaFactory.rotation_speed = 0.60 / 60
data.raw.car.MegaFactory.equipment_grid = "MFEquipmentGrid"
data.raw.car.MegaFactory.inventory_size = 600
data.raw.car.MegaFactory.guns = {
    "mfTank-machine-gun",
    "mfTank-cannon",
    "mfTank-flamethrower"
}
setFactoryResistances(data.raw.car.MegaFactory, 30)
data.raw.car.MegaFactory.collision_mask = {
    layers = {},
}
data.raw.car.MegaFactory.animation.layers[3].shift = util.by_pixel(17.75, 80)
data.raw.car.MegaFactory.selection_priority = 120
