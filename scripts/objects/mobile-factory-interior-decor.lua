require("scripts/objects/mobile-factory-interior.lua")

local oldCreate = MFInterior.create
function MFInterior.create(MF)
    local surface = oldCreate(MF)
    if surface == nil or MF == nil or MF.ent == nil or not MF.ent.valid then return surface end

    if surface.count_entities_filtered{name = "mf-interior-inventory-wall", limit = 1} == 0 then
        local sizes = {SmallFactory=15, SuperFactory=23, MegaFactory=30}
        local half = sizes[MF.ent.name] or 15
        for x=-half,half do
            surface.create_entity{name="mf-interior-inventory-wall",position={x,-half},force=MF.ent.force}
            surface.create_entity{name="mf-interior-inventory-wall",position={x,half},force=MF.ent.force}
        end
        for y=-half+1,half-1 do
            surface.create_entity{name="mf-interior-inventory-wall",position={-half,y},force=MF.ent.force}
            surface.create_entity{name="mf-interior-inventory-wall",position={half,y},force=MF.ent.force}
        end
    end
    return surface
end
