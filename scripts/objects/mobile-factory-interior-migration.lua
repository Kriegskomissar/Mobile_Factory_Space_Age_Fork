-- MOBILE FACTORY INTERIOR MIGRATION -----------------------------------------
-- Rebuild old grassy 1.0.x factory surfaces into the finite 1.1.0 rooms.

function MFInterior.rebuildForV11(MF)
    if MF == nil or MF.ent == nil or not MF.ent.valid then return end
    local oldSurface = MF.fS
    if oldSurface == nil or not oldSurface.valid then
        MFInterior.create(MF)
        return
    end

    local exteriorSurface = MF.ent.surface
    local exteriorPosition = MF.ent.position

    for _, player in pairs(game.connected_players) do
        if player.surface == oldSurface then
            local target = exteriorSurface.find_non_colliding_position(
                "character",
                {exteriorPosition.x, exteriorPosition.y + 6},
                8,
                0.5
            )
            if target then player.teleport(target, exteriorSurface) end
        end
    end

    MFInterior.destroy(MF)
    MFInterior.create(MF)
end
