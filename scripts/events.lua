require("scripts/objects/mobile-factory-interior.lua")

-- When a player joins the game.
function Event.initPlayer(event)
    local player = getPlayer(event.player_index)
    if player == nil or player.controller_type == defines.controllers.cutscene then return end

    if getMFPlayer(player.name) == nil then
        storage.playersTable[player.name] = MFP:new(player)
        local MF = MF:new({player = player})
        storage.playersTable[player.name].MF = MF

        if mfCall(addMobileFactory, player) == true then
            player.print({"gui-description.initPlayer_AddMFFailed"})
        end

        setPlayerVariable(player.name, "GotInventory", true)

        if mfCall(GUI.createMFMainGUI, player) == true then
            player.print({"gui-description.initPlayer_CreateMainGUIFailed"})
            if storage.playersTable[player.name].GUI and storage.playersTable[player.name].GUI[_mfGUIName.MainGUI] ~= nil then
                storage.playersTable[player.name].GUI[_mfGUIName.MainGUI] = nil
            end
            if player.gui.screen[_mfGUIName.MainGUI] ~= nil and player.gui.screen[_mfGUIName.MainGUI].valid then
                player.gui.screen[_mfGUIName.MainGUI].destroy()
            end
        end
    end
end

function Event.playerDriveStatChange(event)
    if MFInterior ~= nil and MFInterior.onDrivingChanged ~= nil and MFInterior.onDrivingChanged(event) then return end

    local player = getPlayer(event.player_index)
    local entity = event.entity
    if entity == nil or not entity.valid or player == nil or not player.valid then return end
    if string.find(entity.name, "MobileFactory") == nil then return end
    if player.vehicle ~= nil then return end

    local positions = {
        {entity.position.x + 5, entity.position.y},
        {entity.position.x - 5, entity.position.y},
        {entity.position.x, entity.position.y - 7},
        {entity.position.x, entity.position.y + 7}
    }
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

    if MFInterior ~= nil and MFInterior.update ~= nil then
        MFInterior.update()
    end

    if event.tick % _eventTick49 == 0 then updateIndoorLights() end
    if event.tick % _eventTick150 == 0 and storage.floorIsLavaActivated == true then updateFloorIsLava() end
end

function Event.entityDamaged(event)
    if event.entity == nil or not event.entity.valid then return end
    if event.entity.force.name == "enemy" or event.entity.force.name == "neutral" then return end
end

function Event.technologyFinished(event)
    local researches = _MFResearches
    if researches == nil then return end
    local func = researches[event.research.name]
    if func == nil then return end
    for _, player in pairs(game.players) do
        if player.valid then
            local mfPlayer = getMFPlayer(player.name)
            if valid(mfPlayer) and valid(mfPlayer.MF) and event.research.force == player.force then
                _G[func](mfPlayer.MF)
            end
        end
    end
end

function Event.selectedEntityChanged(event)
end

function Event.settingsPasted(event)
    if event.source == nil or not event.source.valid then return end
    if event.destination == nil or not event.destination.valid then return end
    local o1 = storage.entsTable[event.source.unit_number] or storage.objectsTable[event.source.unit_number]
    local o2 = storage.entsTable[event.destination.unit_number] or storage.objectsTable[event.destination.unit_number]
    if o1 == nil or o2 == nil then return end
    if o1.ent == nil or o2.ent == nil or o1.ent.name ~= o2.ent.name then return end
    if o2.copySettings ~= nil then o2:copySettings(o1) end
    if o2.meta ~= nil and _G[o2.meta] and _G[o2.meta].copySettings ~= nil then _G[o2.meta].copySettings(o2, o1) end
end

function Event.forceCreated(event)
end

function Event.playerChangedForce(event)
    local player = getPlayer(event.player_index)
    if not (player and player.valid) then return end
    local MFPlayer = getMFPlayer(player.name)
    if not (MFPlayer and MFPlayer:valid()) then return end
    local MF = getMF(player.name)
    if not (MF and MF:valid()) then return end
    if MF.ent and MF.ent.valid then MF.ent.force = player.force end
    if MF.fS and MF.fS.valid then
        for _, ent in pairs(MF.fS.find_entities_filtered{force = event.force}) do ent.force = player.force end
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
        if tags ~= nil then for tag, value in pairs(tags) do bp.set_blueprint_entity_tag(index, tag, value) end end
    end
end

function Event.entityRotated(event)
end

function Event.onShortcut(event)
    local player = getPlayer(event.player_index)
    local MFPlayer = getMFPlayer(event.player_index)
    if player == nil or MFPlayer == nil then return end
    if event.input_name == "OpenTTGUI" and player.selected ~= nil and player.selected.valid and _mfShortcutGUI[player.selected.name] == true then
        if player.can_reach_entity(player.selected) then GUI.openTTGui(MFPlayer, player, player.selected) else player.create_local_flying_text{text = {"gui-description.CannnotReach"}, position = player.selected.position} end
        return
    end
    if event.input_name == "CloseGUI" then
        local names = {_mfGUIName.RecipeGUI, _mfGUIName.RecipeInfoGUI, _mfGUIName.SlotGUI}
        for _, name in pairs(names) do
            if name and MFPlayer.GUI and MFPlayer.GUI[name] ~= nil then
                if MFPlayer.GUI[name].gui ~= nil then MFPlayer.GUI[name].gui.destroy() end
                MFPlayer.GUI[name] = nil
            end
        end
    end
end

function Event.clearGUI(event)
    local player = getPlayer(event.player_index)
    if player == nil then return end
    for _, gui in pairs(player.gui.screen.children) do
        if gui ~= nil and gui.valid and gui.get_mod() == "Mobile_Factory_Space_Age" and gui.name ~= "MFBaseErrorWindows" then gui.destroy() end
    end
    local MFPlayer = getMFPlayer(event.player_index)
    if MFPlayer then MFPlayer.GUI = {} end
    player.opened = nil
    GUI.createMFMainGUI(player)
end
