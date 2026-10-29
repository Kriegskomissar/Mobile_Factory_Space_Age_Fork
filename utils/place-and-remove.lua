local FACTORY_NAMES = {
    SmallFactory = true,
    SuperFactory = true,
    MegaFactory = true
}

function Event.somethingWasPlaced(event)
    local entity = event.entity or event.destination
    if entity == nil or not entity.valid then return end
    if entity.type == "entity-ghost" then return end

    local playerIndex = event.player_index or (entity.last_user and entity.last_user.index)
    local MFPlayer = playerIndex and getMFPlayer(playerIndex) or nil

    if FACTORY_NAMES[entity.name] then
        if MFPlayer ~= nil then
            placedMobileFactory(event, entity, MFPlayer)
        else
            entity.destroy()
        end
        return
    end

    if entity.name == "MFDeploy" then
        local playerMF = playerIndex and getCurrentMF(playerIndex) or nil
        if MFPlayer ~= nil and playerMF ~= nil then
            placedDeploy(entity, MFPlayer, playerMF)
        else
            entity.destroy()
        end
        return
    end

    local objInfo = storage.objTable and storage.objTable[entity.name]
    if objInfo == nil or objInfo.noPlaced == true or objInfo.tag == nil then return end
    local objTable = _G[objInfo.tag]
    if objTable == nil or objTable.new == nil then return end

    local obj = objTable:new(entity)
    if objInfo.tableName ~= nil then
        storage[objInfo.tableName] = storage[objInfo.tableName] or {}
        storage[objInfo.tableName][entity.unit_number] = obj
    end
end

function Event.somethingWasCloned(event)
    if event.source == nil or not event.source.valid or event.destination == nil or not event.destination.valid then return end

    if FACTORY_NAMES[event.source.name] then
        for _, mf in pairs(storage.MFTable or {}) do
            if mf.ent ~= nil and mf.ent.valid and mf.ent == event.source then
                mf.ent.teleport(event.destination.position, event.destination.surface)
                event.destination.destroy()
                return
            end
        end
    end

    Event.somethingWasPlaced({entity = event.destination, player_index = event.player_index})
end

function Event.somethingWasRemoved(event)
    local removedEnt = event.entity
    if removedEnt == nil then return end

    local obj = storage.entsTable[removedEnt.unit_number] or storage.objectsTable[removedEnt.unit_number]
    if obj == nil then return end

    if FACTORY_NAMES[removedEnt.name] then
        obj:remove()
        return
    end

    if obj.contentToItemTags ~= nil and event.buffer ~= nil and event.buffer[1] ~= nil then
        obj:contentToItemTags(event.buffer[1])
    end
    if obj.remove ~= nil then obj:remove() end

    local objInfo = storage.objTable and storage.objTable[removedEnt.name]
    if objInfo ~= nil and objInfo.tableName ~= nil and storage[objInfo.tableName] ~= nil then
        storage[objInfo.tableName][removedEnt.unit_number] = nil
    end
end

function tilesWasPlaced(event)
end

function placedMobileFactory(event, entity, MFPlayer)
    if getMFFloor(entity.surface.name) ~= nil or string.match(entity.surface.name, "^mf-factory-floor%-") then
        entity.destroy()
        if event.consumed_items ~= nil and event.consumed_items[1] ~= nil and event.consumed_items[1].valid_for_read then
            MFPlayer.ent.get_main_inventory().insert(event.consumed_items[1])
        end
        return
    end

    -- There is deliberately no global one-factory restriction. Every placed
    -- entity gets a fresh runtime object and becomes the player's current one.
    local player = game.players[MFPlayer.index]
    local MF = newMobileFactory(entity, player)
    if MF == nil then
        entity.destroy()
        return
    end
    MFPlayer.currentMF = MF
end

function placedDeploy(ent, MFPlayer, mf)
    local ents = ent.surface.find_entities_filtered {
        type = "car",
        position = ent.position,
        radius = 7
    }

    local target = nil
    for _, candidate in pairs(ents) do
        if candidate.valid and FACTORY_NAMES[candidate.name] and candidate.last_user ~= nil then
            local candidateMF = storage.MFTable[candidate.unit_number]
            if candidateMF ~= nil and candidateMF == mf then
                target = candidate
                break
            end
        end
    end

    if target == nil then
        ent.destroy()
        return
    end

    if target.speed ~= 0 then
        MFPlayer.ent.create_local_flying_text {
            text = {"gui-description.DPGUIMFMoving"},
            position = ent.position
        }
        MFPlayer.ent.cursor_stack.set_stack({name = "MFDeploy", count = 1})
        ent.destroy()
        return
    end

    mf.ent.teleport({ent.position.x, ent.position.y + 0.5})
    mf.ent.orientation = 0
    if mf.deployed == true then mf:repack() end
    mf:deploy()
    ent.destroy()
end
