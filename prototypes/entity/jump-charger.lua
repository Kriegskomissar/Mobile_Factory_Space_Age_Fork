---------------------------------- JUMP CHARGER ----------------------------------

-- Entity --
local jcE = {}
jcE.type = "container"
jcE.name = "JumpCharger"
jcE.icon = "__Mobile_Factory_Space_Age__/graphics/entity/JumpChargerI.png"
jcE.icon_size = 128
jcE.flags = {"placeable-neutral", "player-creation"}
jcE.minable = {mining_time = 0.4, result = "JumpCharger"}
jcE.max_health = 300
jcE.corpse = "small-remnants"
jcE.render_not_in_network_icon = false
jcE.collision_box = {{-1.4, -1.4}, {1.4, 1.4}}
jcE.selection_box = {{-1.5, -1.5}, {1.5, 1.5}}
jcE.inventory_size = 0
jcE.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
jcE.close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" }
jcE.vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 }
jcE.picture =
    {
      layers =
      {
        {
          filename = "__Mobile_Factory_Space_Age__/graphics/entity/JumpChargerG.png",
          priority = "extra-high",
          width = 600,
          height = 600,
          shift = {0,-1.7},
          scale = 1/600*32*6.5,
          draw_as_glow = true
        },
        {
            filename = "__Mobile_Factory_Space_Age__/graphics/entity/JumpChargerE.png",
            priority = "extra-high",
            width = 600,
            height = 600,
            shift = {0,-1.7},
            scale = 1/600*32*6.5
        },
        {
            filename = "__Mobile_Factory_Space_Age__/graphics/entity/JumpChargerS.png",
            priority = "high",
            width = 600,
            height = 600,
            shift = {0,-1.7},
            draw_as_shadow = true,
            scale = 1/600*32*6.5
        }
      }
    }
    jcE.circuit_wire_connection_point =
{
	wire = {red={-0.05,-0.1}, green={0.05,-0.1}},
	shadow = {red={-0.05,0}, green={0.05,0}}
}
jcE.circuit_connector_sprites = nil
jcE.circuit_wire_max_distance = 20
data:extend{jcE}

-- Item --
local jcI = {}
jcI.type = "item"
jcI.name = "JumpCharger"
jcI.icon = "__Mobile_Factory_Space_Age__/graphics/entity/JumpChargerI.png"
jcI.icon_size = 128
jcI.place_result = "JumpCharger"
jcI.subgroup = "MobileFactory"
jcI.order = "z"
jcI.stack_size = 10
data:extend{jcI}

-- ============================================================================
-- РЕЦЕПТ И ТЕХНОЛОГИЯ JUMP CHARGER
-- ============================================================================

-- Старые рецепт и технология удалены.
--
-- Они были завязаны на старую экономику Mobile Factory:
-- CrystalizedCircuit
-- MachineFrame3
-- EnergyCore
-- DimensionalSample
-- DimensionalCrystal
--
-- Эти зависимости больше не должны проникать в новую версию мода.
--
-- TODO:
-- 1. Придумать новый рецепт Jump Charger.
-- 2. Определить, какие материалы нужны для его производства.
-- 3. Привязать рецепт к новой системе прогрессии.
-- 4. Определить, на каком этапе развития Mobile Factory он открывается.
-- 5. Вернуть технологию после проектирования новой системы исследований.
--
-- ВАЖНО:
-- Jump Charger не удалён как концепция.
-- Мы просто временно оставляем его без рецепта и технологии,
-- чтобы сначала разобраться с архитектурой Jump Drive.
