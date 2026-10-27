-- MOBILE FACTORY PROTOTYPE AND UPGRADE --
require("prototypes/entity/mobile-factory-base.lua")

-- Mobile Factory GT --
createNewMF("SuperFactory", {1,0.2,0.2}, 0.7, "b", "__Mobile_Factory_Space_Age__/graphics/mobile-factory/QuickMF.png")
data.raw.car.SuperFactory.max_health = 1000
data.raw.car.SuperFactory.consumption = "800kW"
data.raw.car.SuperFactory.weight = 8000
data.raw.car.SuperFactory.rotation_speed = 0.75 / 60
data.raw.car.SuperFactory.effectivity = 2.3
data.raw.car.SuperFactory.braking_power = "4200kW"
data.raw.car.SuperFactory.turret_rotation_speed = 0.55 / 60
data.raw.car.SuperFactory.turret_return_timeout = 120
data.raw.car.SuperFactory.equipment_grid = "MFEquipmentGridGT"
data.raw.car.SuperFactory.inventory_size = 3
data.raw.recipe.SuperFactory.ingredients =
{
	{type="item", name="car", amount=1},
    {type="item", name="CrystalizedCircuit", amount=35},
    {type="item", name="MachineFrame3", amount=15}
}
data.raw.technology.SuperFactory.unit =
{
	count=10,
		time=60,
		ingredients={
			{"DimensionalSample", 100},
			{"DimensionalCrystal", 1}
		}
}

-- Hovering Factory --
createNewMF("MegaFactory", {49,92,255}, 0.9, "c",  "__Mobile_Factory_Space_Age__/graphics/mobile-factory/HMF.png")
data.raw.car.MegaFactory.max_health = 2000
data.raw.car.MegaFactory.consumption = "550kW"
data.raw.car.MegaFactory.weight = 30000
data.raw.car.MegaFactory.braking_power = "400kW"
data.raw.car.MegaFactory.rotation_speed = 0.15 / 60
data.raw.car.MegaFactory.effectivity = 0.8
data.raw.car.MegaFactory.equipment_grid = "MFEquipmentGridH"
data.raw.car.MegaFactory.inventory_size = 8
data.raw.car.MegaFactory.collision_mask = {
	layers = {},
}
data.raw.car.MegaFactory.animation.layers[3].shift = util.by_pixel(17.75, 80)
data.raw.car.MegaFactory.selection_priority = 120
data.raw.recipe.MegaFactory.ingredients =
{
	{type="item", name="MobileFactory", amount=1},
    {type="item", name="CrystalizedCircuit", amount=20},
    {type="item", name="MachineFrame3", amount=25},
	{type="item", name="EnergyCore", amount=1}
}
data.raw.technology.HMobileFactory.unit =
{
	count=10,
		time=60,
		ingredients={
			{"DimensionalSample", 75},
			{"DimensionalCrystal", 2}
		}
}
