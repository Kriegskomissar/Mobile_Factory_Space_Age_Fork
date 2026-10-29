-- Multi-factory runtime overrides. The old player-keyed MF table can contain
-- only the current factory, while entsTable is keyed by each factory entity's
-- unit_number. Interior lookup/update therefore uses entsTable.
require("scripts/objects/mobile-factory-interior.lua")

local function allFactories()
    local seen, result = {}, {}
    for _, MF in pairs(storage.entsTable or {}) do
        if MF and not seen[MF] then
            seen[MF] = true
            table.insert(result, MF)
        end
    end
    return result
end

function MFInterior.getBySurface(surface)
    if surface == nil then return nil end
    for _, MF in pairs(allFactories()) do
        if MF.fS == surface then return MF end
    end
    return nil
end

local function updateAllFactories()
    for _, MF in pairs(allFactories()) do
        if MF.ent and MF.ent.valid then
            if not MF.fS or not MF.fS.valid then MFInterior.create(MF) end
            local tier = tierFor and tierFor(MF) or nil
            if tier == nil then
                local name = MF.ent.name
                local sizes = {SmallFactory={half=15,power=100e6},SuperFactory={half=23,power=250e6},MegaFactory={half=30,power=1000e6}}
                tier = sizes[name] or sizes.SmallFactory
            end
            local outside = {MF.ent.position.x, MF.ent.position.y + 6}
            if MF.exteriorPower and MF.exteriorPower.valid then MF.exteriorPower.teleport(outside, MF.ent.surface) end
            if MF.exteriorEnergy and MF.exteriorEnergy.valid then MF.exteriorEnergy.teleport(outside, MF.ent.surface) end
            if MF.exteriorEnergy and MF.exteriorEnergy.valid and MF.interiorEnergy and MF.interiorEnergy.valid then
                local available = math.max(MF.exteriorEnergy.energy or 0, 0)
                local room = math.max(10e9 - math.max(MF.interiorEnergy.energy or 0, 0), 0)
                local transfer = math.min(available, room, tier.power / 60)
                if transfer > 0 then
                    MF.exteriorEnergy.energy = available - transfer
                    MF.interiorEnergy.energy = math.min(10e9, (MF.interiorEnergy.energy or 0) + transfer)
                end
            end
            if MF.interiorTerminal and MF.interiorTerminal.valid and MF.interiorTerminal.get_driver() == nil then
                MF.interiorTerminal.teleport({0, tier.half - 5})
                MF.interiorTerminal.speed = 0
            end
        end
    end
end

MFInterior.update = updateAllFactories
