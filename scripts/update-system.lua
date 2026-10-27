require("utils/functions.lua")

function UpSys.addObj(obj)
    if valid(obj) == false then return end
    UpSys.addObject(obj)
end

function UpSys.removeObj(obj)
    if obj.entID then
        storage.entsTable[obj.entID] = nil
    end
end

function UpSys.scanObjs()
    storage.entsTable = {}

    for k, _ in pairs(storage.upsysTickTable or {}) do
        if k < game.tick then
            storage.upsysTickTable[k] = nil
        end
    end

    for _, obj in pairs(storage.objTable or {}) do
        if obj.noUpsys ~= true and obj.tableName ~= nil then
            UpSys.addTable(storage[obj.tableName])
        end
    end

    for _, MF in pairs(storage.MFTable or {}) do
        UpSys.addObject(MF.jumpDriveObj)
    end

    storage.upSysLastScan = game.tick
end

function UpSys.addObject(obj)
    storage.upsysTickTable = storage.upsysTickTable or {}
    storage.entsTable = storage.entsTable or {}

    if table_size(storage.upsysTickTable) > 300 then
        game.print("Mobile Factory - Upsys Error: table size too high, unable to update entities")
        storage.upsysTickTable = {}
        return false
    end

    if obj == nil or getmetatable(obj) == nil then
        return false
    end

    if obj:valid() ~= true then
        if obj.remove ~= nil then obj:remove() end
        return false
    end

    if obj.ent ~= nil and obj.ent.valid == true and obj.ent.unit_number ~= nil then
        storage.entsTable[obj.ent.unit_number] = obj
    end

    if obj.updateTick ~= nil and obj.updateTick > 0 then
        local nextUpdate = game.tick + obj.updateTick

        if obj.lastUpdate == nil or obj.lastUpdate == 0 or game.tick - obj.lastUpdate > obj.updateTick * 2 then
            local bestTick = 1
            for i = 1, 60 do
                if table_size(storage.upsysTickTable[game.tick + i] or {}) < table_size(storage.upsysTickTable[game.tick + bestTick] or {}) then
                    bestTick = i
                    if storage.upsysTickTable[game.tick + i] == nil then break end
                end
            end
            nextUpdate = game.tick + bestTick
        end

        storage.upsysTickTable[nextUpdate] = storage.upsysTickTable[nextUpdate] or {}
        table.insert(storage.upsysTickTable[nextUpdate], obj)
        obj.lastUpdate = game.tick
    end

    return true
end

function UpSys.addTable(array)
    if array == nil then return end

    for k, obj in pairs(array) do
        if UpSys.addObject(obj) == false then
            array[k] = nil
        end
    end
end

function UpSys.update(event)
    storage.upsysTickTable = storage.upsysTickTable or {}
    storage.upSysLastScan = storage.upSysLastScan or 0

    if game.tick - storage.upSysLastScan > (_mfScanTicks or 60) * 10 then
        UpSys.scanObjs()
    end

    local current = storage.upsysTickTable[game.tick]
    if current == nil then return end

    local updated = 0
    local maxUpdates = storage.entsUpPerTick or 10

    for _, obj in pairs(current) do
        if valid(obj) and obj.update ~= nil then
            if updated < maxUpdates then
                if mfCall(obj.update, obj, event) == true then
                    if obj.ent and obj.ent.valid then
                        game.print({"gui-description.UpSysupdateEntity_Failed", obj.ent.name})
                    end
                end
                updated = updated + 1

                local nextTick = game.tick + (obj.updateTick or 1)
                storage.upsysTickTable[nextTick] = storage.upsysTickTable[nextTick] or {}
                table.insert(storage.upsysTickTable[nextTick], obj)
            else
                storage.upsysTickTable[game.tick + 1] = storage.upsysTickTable[game.tick + 1] or {}
                table.insert(storage.upsysTickTable[game.tick + 1], obj)
            end
        end
    end

    storage.upsysTickTable[game.tick] = nil
end
