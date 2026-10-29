require("scripts/objects/mobile-factory-interior.lua")

local FACTORY_NAMES = {
    SmallFactory = true,
    SuperFactory = true,
    MegaFactory = true
}

function Event.initPlayer(event)
    local player = getPlayer(event.player_index)
    if player == nil or player.controller_type == defines.controllers.cutscene then return end
    if getMFPlayer(player.name) == nil then
        storage.playersTable[player.name] = MFP:new(player)
        local MF = MF:new({player = player})
        storage.playersTable[player.name].MF = MF
        if mfCall(addMobileFactory, player) == true then player.print({"gui-description.initPlayer_AddMFFailed"}) end
        setPlayerVariable(player.name, "GotInventory", true)
        if mfCall(GUI.createMFMainGUI, player) == true then
            player.print({"gui-description.initPlayer_CreateMainGUIFailed"})
            if storage.playersTable[player.name].GUI then storage.playersTable[player.name].GUI.MFMainGUI = nil end
            local gui = player.gui.screen.MFMainGUI
            if gui ~= nil and gui.valid then gui.destroy() end
        end
    end
end

function Event.playerDriveStatChange(event)
    if MFInterior.onDrivingChanged(event) then return end
    local player = getPlayer(event.player_index)
    local entity = event.entity
    if entity == nil or not entity.valid or player == nil or not player.valid then return end
    if not FACTORY_NAMES[entity.name] then return end
    if player.vehicle ~= nil then return end
    local positions = {{entity.position.x + 5, entity.position.y},{entity.position.x - 5, entity.position.y},{entity.position.x, entity.position.y - 7},{entity.position.x, entity.position.y + 7}}
    for _, position in pairs(positions) do
        if entity.surface.can_place_entity{name = "character", position = position} then
            player.teleport(position, entity.surface)
            return
        end
    end
end

function Event.tick(event)
    updateEntities(event)
    GUI.updateAllGUIs()
    MFInterior.update()
    if event.tick % _eventTick49 == 0 then updateIndoorLights() end
    if event.tick % _eventTick150 == 0 and storage.floorIsLavaActivated == true then updateFloorIsLava() end
end

function Event.entityDamaged(event)
    if event.entity == nil or not event.entity.valid then return end
end

function Event.technologyFinished(event)
    -- Technology effects are now handled entirely by prototypes. The former
    -- Control Center / Deep Storage callback table has been removed.
end

function Event.selectedEntityChanged(event) end

function Event.settingsPasted(event)
    if event.source == nil or not event.source.valid or event.destination == nil or not event.destination.valid then return end
    local o1 = storage.entsTable[event.source.unit_number] or storage.objectsTable[event.source.unit_number]
    local o2 = storage.entsTable[event.destination.unit_number] or storage.objectsTable[event.destination.unit_number]
    if o1 == nil or o2 == nil or o1.ent == nil or o2.ent == nil or o1.ent.name ~= o2.ent.name then return end
    if o2.copySettings ~= nil then o2:copySettings(o1) end
    if o2.meta ~= nil and _G[o2.meta] and _G[o2.meta].copySettings ~= nil then _G[o2.meta].copySettings(o2, o1) end
end

function Event.forceCreated(event) end

function Event.playerChangedForce(event)
    local player = getPlayer(event.player_index)
    if not (player and player.valid) then return end
    local MFPlayer = getMFPlayer(player.name)
    if not (MFPlayer and MFPlayer:valid()) then return end
    local MF = getMF(player.name)
    if not (MF and MF:valid()) then return end
    if MF.ent and MF.ent.valid then MF.ent.force = player.force end
    if MF.fS and MF.fS.valid then
        for _, ent in pairs(MF.fS.find_entities_filtered{force = event.force}) do
            ent.force = player.force
        end
    end
end

function Event.playerSetupBlueprint(event)
    local player = game.players[event.player_index]
    if player == nil then return end
    local mapping = event.mapping.get()
    local bp = player.blueprint_to_setup
    if bp.valid_for_read == false then
        local cursor = player.cursor_stack
        if cursor and cursor.valid_for_read and cursor.name == "blueprint" then bp = cursor end
    end
    if bp == nil or bp.valid_for_read == false then return end
    for index, ent in pairs(mapping) do
        local tags = entityToBlueprintTags(ent)
        if tags ~= nil then
            for tag, value in pairs(tags) do bp.set_blueprint_entity_tag(index, tag, value) end
        end
    end
end

function Event.entityRotated(event) end

function Event.onShortcut(event)
    -- The old GUI shortcut system was removed with the legacy GUI stack.
end

function Event.clearGUI(event)
    local player = getPlayer(event.player_index)
    if player == nil then return end
    for _, gui in pairs(player.gui.screen.children) do
        if gui ~= nil and gui.valid and gui.get_mod() == "Mobile_Factories_Onboard_Production" then
            gui.destroy()
        end
    end
    local MFPlayer = getMFPlayer(event.player_index)
    if MFPlayer then MFPlayer.GUI = {} end
    player.opened = nil
    GUI.createMFMainGUI(player)
end
