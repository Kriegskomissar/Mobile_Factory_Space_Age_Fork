-- Register the runtime objects that are part of the fork core.
function createTableList()
    storage.objTable = {}
    addObject{tableName = "playersTable", tag = "MFP", objName = "MFPlayer", noPlaced = true, noUpsys = true}
    addObject{tableName = "MFTable", tag = "MF", objName = "MF", noPlaced = true}
    addObject{tableName = "jumpChargerTable", tag = "JC", objName = "JumpCharger", canInCC = true}
end

function addObject(object)
    storage.objTable = storage.objTable or {}
    storage.objTable[object.objName] = object
    if object.tableName ~= nil and storage[object.tableName] == nil then
        storage[object.tableName] = {}
    end
end

-- Transfer a chest inventory evenly between two containers.
function syncChest(chest1, chest2)
    if chest1 == nil or chest2 == nil or not chest1.valid or not chest2.valid then return end

    local inv1 = chest1.get_inventory(defines.inventory.chest)
    local inv2 = chest2.get_inventory(defines.inventory.chest)
    if inv1 == nil or inv2 == nil then return end

    local itemsDiff = {}
    for i = 1, #inv1 do
        local stack = inv1[i]
        if stack.valid_for_read and stack.item_number == nil then
            itemsDiff[stack.name] = (itemsDiff[stack.name] or 0) + stack.count / 2
        end
    end
    for i = 1, #inv2 do
        local stack = inv2[i]
        if stack.valid_for_read and stack.item_number == nil then
            itemsDiff[stack.name] = (itemsDiff[stack.name] or 0) - stack.count / 2
        end
    end

    local somethingMoved = 0
    for item, count in pairs(itemsDiff) do
        count = math.floor(count)
        if count < -1 then
            local inserted = inv1.insert{name = item, count = math.abs(count)}
            if inserted > 0 then
                somethingMoved = somethingMoved + inv2.remove{name = item, count = inserted}
            end
        elseif count > 1 then
            local inserted = inv2.insert{name = item, count = count}
            if inserted > 0 then
                somethingMoved = somethingMoved + inv1.remove{name = item, count = inserted}
            end
        end
    end

    if somethingMoved > 0 then
        local bar1 = inv1.get_bar()
        local bar2 = inv2.get_bar()
        inv1.set_bar()
        inv2.set_bar()
        inv1.sort_and_merge()
        inv2.sort_and_merge()
        inv1.set_bar(bar1)
        inv2.set_bar(bar2)
    end
end

-- Transfer fluid evenly between two tanks.
function syncTank(tank1, tank2)
    if tank1 == nil or tank2 == nil or not tank1.valid or not tank2.valid then return end
    if tank1.fluidbox[1] == nil and tank2.fluidbox[1] == nil then return end

    local f1 = tank1.fluidbox[1]
    local f2 = tank2.fluidbox[1]
    if f1 ~= nil and f2 ~= nil and f1.name ~= f2.name then return end

    local fluidName = f1 and f1.name or (f2 and f2.name)
    local amount = math.floor(((f1 and f1.amount or 0) + (f2 and f2.amount or 0)) / 2)
    local temperature = math.floor(((f1 and f1.temperature or 15) + (f2 and f2.temperature or 15)) / 2)
    if fluidName == nil or amount <= 0 then return end

    tank1.clear_fluid_inside()
    tank2.clear_fluid_inside()
    tank1.fluidbox[1] = {name = fluidName, amount = amount, temperature = temperature}
    tank2.fluidbox[1] = {name = fluidName, amount = amount, temperature = temperature}
end

function syncEnergy(accu1, accu2)
    if accu1 == nil or accu2 == nil or not accu1.valid or not accu2.valid then return end
    local totalEnergy = accu1.energy + accu2.energy
    accu1.energy = math.ceil(totalEnergy / 2)
    accu2.energy = math.floor(totalEnergy / 2)
end

-- Check whether one of the fork's runtime objects is valid.
function valid(obj)
    if obj == nil or type(obj) ~= "table" then return false end
    if type(obj.valid) == "boolean" then return obj.valid end
    if type(obj.valid) == "function" then return obj:valid() == true end

    if obj.meta ~= nil and _G[obj.meta] ~= nil and _G[obj.meta].valid ~= nil then
        return _G[obj.meta].valid(obj) == true
    end

    return false
end

function getMF(player)
    if player == nil then return nil end
    if type(player) == "number" then
        local p = game.players[player]
        return p and storage.MFTable[p.name] or nil
    elseif type(player) == "string" then
        return storage.MFTable[player]
    end
    error("bad argument to getMF()")
end

function getCurrentMF(player)
    if player == nil then return nil end
    if type(player) == "number" then
        local p = game.players[player]
        if not p then return nil end
        local mfPlayer = storage.playersTable[p.name]
        return mfPlayer and (mfPlayer.currentMF or mfPlayer.MF) or nil
    elseif type(player) == "string" then
        local mfPlayer = storage.playersTable[player]
        return mfPlayer and (mfPlayer.currentMF or mfPlayer.MF) or nil
    elseif type(player) == "table" then
        return player.currentMF or player.MF
    end
end

function getMFPlayer(player)
    if player == nil then return nil end
    if type(player) == "number" then
        local p = game.players[player]
        return p and storage.playersTable[p.name] or nil
    elseif type(player) == "string" then
        return storage.playersTable[player]
    end
    error("bad argument to getMFPlayer()")
end

function getMFFloor(surfaceName)
    if surfaceName == nil then return nil, nil end

    local prefixes = {_mfSurfaceName, _mfControlSurfaceName}
    for _, prefix in pairs(prefixes) do
        if prefix ~= nil then
            local floor, playerName = string.match(surfaceName, "^(" .. prefix .. ")(.*)$")
            if floor then return floor, playerName end
        end
    end

    return nil, nil
end

function findNearestMF(surface, position)
    if type(surface) ~= "userdata" and (type(surface) ~= "table" or surface.object_name ~= "LuaSurface") then
        error("invalid argument - surface")
    end
    if type(position) ~= "table" then error("invalid argument - position") end

    local pX = position.x or position[1]
    local pY = position.y or position[2]
    if pX == nil or pY == nil then error("findNearestMF() - invalid position table") end

    local nearestMFObj = nil
    local d2 = math.huge
    for _, MF in pairs(storage.MFTable or {}) do
        local MFEnt = MF.ent
        if MFEnt and MFEnt.valid and MFEnt.surface == surface then
            local MFPos = MFEnt.position
            local dist2 = (pX - MFPos.x)^2 + (pY - MFPos.y)^2
            if dist2 < d2 then
                d2 = dist2
                nearestMFObj = MF
            end
        end
    end
    return nearestMFObj
end

function valueToObj(inTable, key, value)
    if type(inTable) ~= "table" or key == nil or value == nil then return nil end
    for _, obj in pairs(inTable) do
        if obj[key] == value then return obj end
    end
    return nil
end

function getForce(player)
    if type(player) == "table" then
        player = player.playerIndex
    end
    if game.players[player] ~= nil then
        return game.players[player].force
    end
    return nil
end

function getMFBySurface(surface)
    for _, MF in pairs(storage.MFTable or {}) do
        if MF.fS == surface or MF.ccS == surface then
            return MF
        end
    end
    return nil
end

function getPlayerVariable(playerName, variable)
    storage.playersTable = storage.playersTable or {}
    local MFPlayer = getMFPlayer(playerName)
    if MFPlayer == nil then
        local player = getPlayer(playerName)
        if player ~= nil then
            storage.playersTable[playerName] = MFP:new(player)
            MFPlayer = storage.playersTable[playerName]
        end
    end
    if MFPlayer == nil then return nil end
    MFPlayer.varTable = MFPlayer.varTable or {}
    return MFPlayer.varTable[variable]
end

function setPlayerVariable(playerName, variable, value)
    storage.playersTable = storage.playersTable or {}
    local MFPlayer = getMFPlayer(playerName)
    if MFPlayer == nil then
        local player = getPlayer(playerName)
        if player ~= nil then
            storage.playersTable[playerName] = MFP:new(player)
            MFPlayer = storage.playersTable[playerName]
        end
    end
    if MFPlayer == nil then return end
    MFPlayer.varTable = MFPlayer.varTable or {}
    MFPlayer.varTable[variable] = value
end

function findMF(player)
    if player == nil then return nil end

    local found = nil
    local count = 0
    for _, surface in pairs(game.surfaces) do
        for _, entity in pairs(surface.find_entities_filtered{type = "car"}) do
            if entity.valid and string.match(entity.name, "MobileFactory") and entity.last_user ~= nil and entity.last_user.name == player.name then
                count = count + 1
                found = entity
            end
        end
    end

    player.print("Found " .. count .. " Mobile Factory")
    return found
end

-- Reattach a discovered factory entity to its runtime object.
function newMobileFactory(entity)
    if entity == nil or not entity.valid or entity.last_user == nil then return end

    local playerName = entity.last_user.name
    local MF = storage.MFTable[playerName]
    if MF == nil then return end

    MF:construct(entity)
end

function fixMB(event, MF)
    local player = getPlayer(event.player_index)
    if player == nil or MF == nil then return end

    if MF.ent == nil or not MF.ent.valid then
        local entity = findMF(player)
        if entity ~= nil and entity.valid then
            newMobileFactory(entity)
        else
            player.print({"", {"gui-description.MFScanNotFound"}})
        end
    end

    if MF.fS == nil or not MF.fS.valid then
        local surface = game.get_surface(_mfSurfaceName .. player.name)
        if surface ~= nil and surface.valid then
            MF.fS = surface
        else
            createMFSurface(MF)
        end
    end

    if MF.ccS == nil or not MF.ccS.valid then
        local surface = game.get_surface(_mfControlSurfaceName .. player.name)
        if surface ~= nil and surface.valid then
            MF.ccS = surface
        else
            createControlRoom(MF)
        end
    end
end

function addMobileFactory(player)
    if player == nil then return end
    if settings.startup["MF-first-MF"].value ~= "player creation" then return end

    local inv = player.get_main_inventory()
    if inv == nil then return end

    if inv.can_insert{name = "MobileFactory"} then
        inv.insert{name = "MobileFactory", count = 1}
        player.print({"", {"gui-description.MFInsertedInsideInventory"}})
    else
        player.print({"", {"gui-description.MFNotInsertedInsideInventory"}})
    end
end

function getEntID(array)
    local used = {}
    local highId = 0
    for _, obj in pairs(array or {}) do
        if obj.ID then
            used[obj.ID] = true
            highId = math.max(highId, obj.ID)
        end
    end
    for id = 1, highId + 1 do
        if not used[id] then return id end
    end
    return 1
end

function isOutside(player)
    if player == nil or player.surface == nil then return true end
    if _mfSurfaceName and string.match(player.surface.name, _mfSurfaceName) then return false end
    if _mfControlSurfaceName and string.match(player.surface.name, _mfControlSurfaceName) then return false end
    return true
end

function canUse(MFPlayer, obj)
    if MFPlayer == nil or obj == nil then return false end
    if obj.player == MFPlayer.name then return true end

    local variables = obj.MF and obj.MF.varTable or obj.varTable
    if variables and variables.allowedPlayers and variables.allowedPlayers[MFPlayer.index] == true then
        return true
    end
    return false
end

function entityToBlueprintTags(entity)
    if entity == nil or not entity.valid or entity.unit_number == nil then return nil end

    local obj = storage.entsTable[entity.unit_number] or storage.objectsTable[entity.unit_number]
    if obj and obj.settingsToBlueprintTags then
        return obj:settingsToBlueprintTags()
    end

    if _mfTagsTable and _mfTagsTable[entity.name] then
        local meta = _G[_mfTagsTable[entity.name]]
        if meta and meta.settingsToBlueprintTags then
            return meta.settingsToBlueprintTags(obj)
        end
    end

    return nil
end

function slotToPos(slotNumber, x, y)
    local positions = {
        [1] = {-2, -4}, [2] = {-1, -4}, [3] = {0, -4}, [4] = {1, -4},
        [5] = {-3, -3}, [6] = {-3, -2}, [7] = {-3, -1}, [8] = {-3, 0}, [9] = {-3, 1}, [10] = {-3, 2},
        [11] = {2, -3}, [12] = {2, -2}, [13] = {2, -1}, [14] = {2, 0}, [15] = {2, 1}, [16] = {2, 2},
        [17] = {-2, 3}, [18] = {-1, 3}, [19] = {0, 3}, [20] = {1, 3}
    }

    local offset = positions[slotNumber]
    if offset == nil then return nil end
    return {x + offset[1], y + offset[2]}
end

function slotToDirection(slotNumber, entity)
    local directions = {
        [1] = defines.direction.north, [2] = defines.direction.north, [3] = defines.direction.north, [4] = defines.direction.north,
        [5] = defines.direction.west, [6] = defines.direction.west, [7] = defines.direction.west, [8] = defines.direction.west, [9] = defines.direction.west, [10] = defines.direction.west,
        [11] = defines.direction.east, [12] = defines.direction.east, [13] = defines.direction.east, [14] = defines.direction.east, [15] = defines.direction.east, [16] = defines.direction.east,
        [17] = defines.direction.south, [18] = defines.direction.south, [19] = defines.direction.south, [20] = defines.direction.south
    }

    local direction = directions[slotNumber]
    if direction == nil then return nil end

    if type(entity) == "string" and string.match(entity, "Belt") then
        if direction == defines.direction.north then return defines.direction.south end
        if direction == defines.direction.south then return defines.direction.north end
        if direction == defines.direction.west then return defines.direction.east end
        if direction == defines.direction.east then return defines.direction.west end
    end

    return direction
end
