-------------- SURFACES UTILITIES -------------------

-- Create the Mobile Factory internal surface. The actual implementation now
-- lives in the per-factory interior object so multiple factories can coexist.
function createMFSurface(MF)
    if MFInterior ~= nil and MFInterior.create ~= nil then
        return MFInterior.create(MF)
    end
end

-- Kept as a compatibility no-op for old saves/scripts. The former Control
-- Center surface and its Internal Energy/Quatron cubes are gone from the new
-- Mobile Factory architecture.
function createControlRoom(MF)
    MF.ccS = nil
    return nil
end

function createEntity(surface, posX, posY, entityName, force, player)
    if surface == nil then game.print("createEntity: Surface nul") return end
    if force == nil then force = "player" end
    return surface.create_entity{name=entityName, position={posX,posY}, force=force, player=player}
end
