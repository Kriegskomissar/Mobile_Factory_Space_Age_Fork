-------------- SURFACES UTILITIES -------------------

require("scripts/objects/mobile-factory-interior.lua")
require("scripts/objects/mobile-factory-interior-multi.lua")

function createMFSurface(MF)
    if MFInterior ~= nil and MFInterior.create ~= nil then return MFInterior.create(MF) end
end

function createControlRoom(MF)
    MF.ccS = nil
    return nil
end

function createEntity(surface, posX, posY, entityName, force, player)
    if surface == nil then game.print("createEntity: Surface nul") return end
    if force == nil then force = "player" end
    return surface.create_entity{name=entityName, position={posX,posY}, force=force, player=player}
end
