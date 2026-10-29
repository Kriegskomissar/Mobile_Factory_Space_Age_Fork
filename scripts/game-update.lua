require("utils/surface.lua")
require("utils/functions.lua")
require("scripts/update-system.lua")
require("utils/place-and-remove.lua")

-- Compatibility helper for the current runtime code. Factorio exposes this
-- through game.get_player(); the old fork used a global getPlayer helper.
function getPlayer(player)
    return game.get_player(player)
end

-- Update all runtime objects.
function updateEntities(event)
    UpSys.update(event)
end

-- Called after an entity dies.
function Event.ghostPlacedByDie(event)
    if event.ghost ~= nil and event.ghost.valid == true then
        Event.somethingWasPlaced({entity = event.ghost})
    end
end

-- Damage players that are outside protected Mobile Factory surfaces.
function updateFloorIsLava()
    for _, player in pairs(game.players) do
        if player.character ~= nil and player.character.valid then
            local surfaceName = player.surface.name
            if not string.match(surfaceName, _mfSurfaceName) and
               not string.match(surfaceName, _mfControlSurfaceName) and
               not string.match(surfaceName, "Factory") then
                player.character.damage(50, "neutral", "fire")
            end
        end
    end
end

-- Interior lighting currently has no separate runtime power object.
function updateIndoorLights()
    for _, MF in pairs(storage.MFTable or {}) do
        if MF.fS and MF.fS.valid then MF.fS.daytime = 0 end
    end
end
