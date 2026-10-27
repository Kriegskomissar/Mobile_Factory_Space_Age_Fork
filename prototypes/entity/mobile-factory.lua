-- MOBILE FACTORY PROTOTYPE AND UPGRADE --
require("prototypes/entity/mobile-factory-base.lua")

-- Super Factory --
createNewMF("SuperFactory", {1,0.2,0.2}, 2.0, "b", "__Mobile_Factory_Space_Age__/graphics/mobile-factory/QuickMF.png")
data.raw.car.SuperFactory.consumption = "1000kW"
data.raw.car.SuperFactory.effectivity = 2.3
data.raw.car.SuperFactory.turret_rotation_speed = 0.55 / 60
data.raw.car.SuperFactory.turret_return_timeout = 120
data.raw.car.SuperFactory.equipment_grid = "MFEquipmentGridSuper"
data.raw.car.SuperFactory.inventory_size = 300

-- Mega Factory --
createNewMF("MegaFactory", {49,92,255}, 3.0, "c", "__Mobile_Factory_Space_Age__/graphics/mobile-factory/HMF.png")
data.raw.car.MegaFactory.consumption = "15000kW"
data.raw.car.MegaFactory.effectivity = 0.8
data.raw.car.MegaFactory.equipment_grid = "MFEquipmentGridMega"
data.raw.car.MegaFactory.inventory_size = 600
data.raw.car.MegaFactory.collision_mask = {
    layers = {},
}
data.raw.car.MegaFactory.animation.layers[3].shift = util.by_pixel(17.75, 80)
data.raw.car.MegaFactory.selection_priority = 120
