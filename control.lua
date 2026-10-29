GUI = GUI or {}
UpSys = UpSys or {}
Event = Event or {}

require("utils/settings.lua")
require("utils/surface.lua")
require("scripts/GUI/gui.lua")
require("scripts/game-update.lua")
require("scripts/events.lua")
require("scripts/objects/mobile-factory.lua")
require("scripts/objects/mobile-factory-interior-migration.lua")
require("scripts/objects/jump-drive.lua")
require("scripts/objects/jump-markers.lua")
require("scripts/objects/jump-marker-events.lua")
require("scripts/objects/MFPlayer.lua")

function mfCall(fn, ...)
    if fn == nil then return true end
    local ok, err = pcall(fn, ...)
    if not ok then log("Mobile Factory runtime error: " .. tostring(err)) end
    return not ok
end

local FACTORY_NAMES = {SmallFactory = true, SuperFactory = true, MegaFactory = true}

local function migrateFactoryTable()
    storage.MFTable = storage.MFTable or {}
    storage.entsTable = storage.entsTable or {}
    storage.playersTable = storage.playersTable or {}

    local legacy = {}
    for key, MF in pairs(storage.MFTable) do
        if type(key) == "string" then table.insert(legacy, {key = key, MF = MF}) end
    end
    for _, entry in pairs(legacy) do
        local MF = entry.MF
        if MF and MF.ent and MF.ent.valid and MF.ent.unit_number then
            local unit = MF.ent.unit_number
            MF.player = MF.player ~= "" and MF.player or entry.key
            MF.playerIndex = MF.playerIndex or (game.players[MF.player] and game.players[MF.player].index)
            storage.MFTable[unit] = MF
            storage.entsTable[unit] = MF
            storage.MFTable[entry.key] = nil
        else
            storage.MFTable[entry.key] = nil
        end
    end
end

function onInit()
    local hadSaveData = next(storage) ~= nil

    storage.allowMigration = hadSaveData
    storage.entsTable = storage.entsTable or {}
    storage.upsysTickTable = storage.upsysTickTable or {}
    storage.entsUpPerTick = storage.entsUpPerTick or 10
    storage.upSysLastScan = storage.upSysLastScan or 0
    storage.useVanillaChooseElem = storage.useVanillaChooseElem or false
    storage.floorIsLavaActivated = storage.floorIsLavaActivated or false
    storage.objectsTable = storage.objectsTable or {}
    storage.jumpMarkerMode = storage.jumpMarkerMode or {}

    createTableList()
    migrateFactoryTable()

    storage.playersTable = storage.playersTable or {}
    for _, player in pairs(game.players) do
        Event.initPlayer({player_index = player.index})
    end

    for _, MF in pairs(storage.MFTable or {}) do
        if type(MF) == "table" and MF.ent and MF.ent.valid then
            MF:refresh()
            if hadSaveData and MF.fS and MF.fS.valid then
                MFInterior.rebuildForV11(MF)
            elseif MF.fS == nil or not MF.fS.valid then
                MFInterior.create(MF)
            end
            if MF.playerIndex and game.players[MF.playerIndex] then
                local playerName = game.players[MF.playerIndex].name
                storage.playersTable[playerName] = storage.playersTable[playerName] or MFP:new(game.players[MF.playerIndex])
                storage.playersTable[playerName].currentMF = MF
            end
        end
    end

    rendering.clear("Mobile_Factories_Onboard_Production")

    for k, obj in pairs(storage.objectsTable) do
        if obj.meta ~= nil and _G[obj.meta] ~= nil and _G[obj.meta].valid ~= nil then
            if _G[obj.meta].valid(obj) == false then storage.objectsTable[k] = nil end
        else
            storage.objectsTable[k] = nil
        end
    end
end

function onLoad(event)
    for _, obj in pairs(storage.objTable or {}) do
        if obj.tableName ~= nil and obj.tag ~= nil and _G[obj.tag] ~= nil then
            for _, entry in pairs(storage[obj.tableName] or {}) do
                _G[obj.tag]:rebuild(entry)
            end
        end
    end
end

_mfEntityFilter = {
    {filter = "type", type = "unit", invert = true},
    {filter = "type", type = "tree", mode = "and", invert = true},
    {filter = "type", type = "simple-entity", mode = "and", invert = true},
    {filter = "type", type = "unit-spawner", mode = "and", invert = true},
    {filter = "type", type = "turret", mode = "and", invert = true},
    {filter = "type", type = "fish", mode = "and", invert = true}
}

_mfEntityFilterWithCBJ = {
    {filter = "type", type = "unit", invert = true},
    {filter = "type", type = "tree", mode = "and", invert = true},
    {filter = "type", type = "simple-entity", mode = "and", invert = true},
    {filter = "type", type = "unit-spawner", mode = "and", invert = true},
    {filter = "type", type = "turret", mode = "and", invert = true},
    {filter = "type", type = "fish", mode = "and", invert = true}
}

function initAPlayer(event)
    if mfCall(Event.initPlayer, event) == true then
        local player = event.player_index and game.players[event.player_index]
        if player and player.name then game.print({"gui-description.initAPlayer_PlayerInitFailed", player.name}) end
    end
end

function onPlayerDriveStatChange(event) mfCall(Event.playerDriveStatChange, event) end
function onTick(event) mfCall(Event.tick, event) end
function onEntityDamaged(event) mfCall(Event.entityDamaged, event) end

function whenSomethingWasPlaced(event)
    if mfCall(Event.somethingWasPlaced, event) == true then
        game.print({"gui-description.whenSomethingWasPlaced_Failed"})
        local entity = event.entity or event.destination
        if entity ~= nil and entity.valid == true then entity.destroy() end
    end
end

function whenSomethingWasCloned(event) mfCall(Event.somethingWasCloned, event) end
function whenSomethingWasRemoved(event) mfCall(Event.somethingWasRemoved, event) end

function onGhostPlacedByDie(event)
    if mfCall(Event.ghostPlacedByDie, event) == true then
        game.print({"gui-description.onGhostPlacedByDie_Failed"})
        if event.ghost ~= nil and event.ghost.valid == true then event.ghost.destroy() end
    end
end

function onGuiOpened(event) mfCall(GUI.guiOpened, event) end
function onGuiClosed(event) mfCall(GUI.guiClosed, event) end
function onButtonClicked(event) mfCall(GUI.buttonClicked, event) end
function onGuiElemChanged(event) mfCall(GUI.onGuiElemChanged, event) end
function onTechnologyFinished(event) mfCall(Event.technologyFinished, event) end
function onSelectedEntityChanged(event) mfCall(Event.selectedEntityChanged, event) end
function onSettingsPasted(event) mfCall(Event.settingsPasted, event) end
function onForceCreated(event) mfCall(Event.forceCreated, event) end
function onPlayerChangedForce(event) mfCall(Event.playerChangedForce, event) end
function onPlayerSetupBlueprint(event) mfCall(Event.playerSetupBlueprint, event) end
function onStringTranslated(event) mfCall(GUI.onStringTranslated, event) end
function onEntityRotated(event) mfCall(Event.entityRotated, event) end
function onShortcutPressed(event) mfCall(Event.onShortcut, event) end
function clearAllGUI(event) mfCall(Event.clearGUI, event) end

script.on_init(onInit)
script.on_configuration_changed(onInit)
script.on_load(onLoad)
script.on_event(defines.events.on_cutscene_cancelled, initAPlayer)
script.on_event(defines.events.on_player_created, initAPlayer)
script.on_event(defines.events.on_player_joined_game, initAPlayer)
script.on_event(defines.events.on_player_driving_changed_state, onPlayerDriveStatChange)
script.on_event(defines.events.on_tick, onTick)
script.on_event(defines.events.on_entity_damaged, onEntityDamaged, _mfEntityFilterWithCBJ)
script.on_event(defines.events.on_built_entity, whenSomethingWasPlaced)
script.on_event(defines.events.on_player_built_tile, whenSomethingWasPlaced)
script.on_event(defines.events.script_raised_built, whenSomethingWasPlaced)
script.on_event(defines.events.script_raised_revive, whenSomethingWasPlaced)
script.on_event(defines.events.on_robot_built_entity, whenSomethingWasPlaced)
script.on_event(defines.events.on_robot_built_tile, whenSomethingWasPlaced)
script.on_event(defines.events.on_entity_cloned, whenSomethingWasCloned)
script.on_event(defines.events.on_player_mined_entity, whenSomethingWasRemoved)
script.on_event(defines.events.on_player_mined_tile, whenSomethingWasRemoved)
script.on_event(defines.events.on_robot_mined_entity, whenSomethingWasRemoved)
script.on_event(defines.events.on_robot_mined_tile, whenSomethingWasRemoved)
script.on_event(defines.events.script_raised_destroy, whenSomethingWasRemoved)
script.on_event(defines.events.on_entity_died, whenSomethingWasRemoved, _mfEntityFilter)
script.on_event(defines.events.on_post_entity_died, onGhostPlacedByDie, _mfEntityFilter)
script.on_event(defines.events.on_gui_opened, onGuiOpened)
script.on_event(defines.events.on_gui_closed, onGuiClosed)
script.on_event(defines.events.on_gui_click, onButtonClicked)
script.on_event(defines.events.on_gui_elem_changed, onGuiElemChanged)
script.on_event(defines.events.on_gui_checked_state_changed, onGuiElemChanged)
script.on_event(defines.events.on_gui_selection_state_changed, onGuiElemChanged)
script.on_event(defines.events.on_gui_text_changed, onGuiElemChanged)
script.on_event(defines.events.on_gui_switch_state_changed, onGuiElemChanged)
script.on_event(defines.events.on_gui_selected_tab_changed, onGuiElemChanged)
script.on_event(defines.events.on_research_finished, onTechnologyFinished)
script.on_event(defines.events.on_selected_entity_changed, onSelectedEntityChanged)
script.on_event(defines.events.on_entity_settings_pasted, onSettingsPasted)
script.on_event(defines.events.on_force_created, onForceCreated)
script.on_event(defines.events.on_player_changed_force, onPlayerChangedForce)
script.on_event(defines.events.on_player_setup_blueprint, onPlayerSetupBlueprint)
script.on_event(defines.events.on_string_translated, onStringTranslated)
script.on_event(defines.events.on_entity_rotated, onEntityRotated)
script.on_event(defines.events.on_lua_shortcut, onShortcutPressed)
