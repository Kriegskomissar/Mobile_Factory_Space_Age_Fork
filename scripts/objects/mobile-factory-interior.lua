-- MOBILE FACTORY INTERIOR ----------------------------------------------------
MFInterior = MFInterior or {}

local TIERS = {
    SmallFactory = {size = 30, half = 15, power = 100e6, tier = 1},
    SuperFactory = {size = 46, half = 23, power = 250e6, tier = 2},
    MegaFactory = {size = 60, half = 30, power = 1000e6, tier = 3}
}

local function tierFor(MF)
    if MF == nil or MF.ent == nil or not MF.ent.valid then return TIERS.SmallFactory end
    return TIERS[MF.ent.name] or TIERS.SmallFactory
end

local function surfaceName(MF)
    return "mf-factory-floor-" .. tostring(MF.ent.unit_number)
end

local function setFloor(surface, half, isMega)
    local allTiles, floor, border, coreBorder = {}, {}, {}, {}
    local outer = half + 3
    for x = -outer, outer do
        for y = -outer, outer do
            table.insert(allTiles, {name = "out-of-map", position = {x, y}})
        end
    end
    surface.set_tiles(allTiles, true)

    for x = -half, half do
        for y = -half, half do
            if math.abs(x) == half or math.abs(y) == half then
                table.insert(border, {name = "refined-hazard-concrete-right", position = {x, y}})
            else
                table.insert(floor, {name = "refined-concrete", position = {x, y}})
            end
        end
    end
    surface.set_tiles(floor, true)
    surface.set_tiles(border, true)

    if isMega then
        for x = -half + 1, half - 1 do
            table.insert(coreBorder, {name = "refined-hazard-concrete-right", position = {x, -half + 12}})
        end
        surface.set_tiles(coreBorder, true)
    end
end

local function createEntity(surface, name, position, force)
    return surface.create_entity{
        name = name,
        position = position,
        force = force,
        raise_built = false,
        create_build_effect_smoke = false
    }
end

local function createWalls(MF, tier)
    if MF.interiorWallHorizontal and MF.interiorWallHorizontal.valid then return end
    local wallY = tier.half
    MF.interiorWallHorizontal = createEntity(MF.fS, "mf-interior-wall-horizontal", {0, wallY}, MF.ent.force)
    MF.interiorWallHorizontal2 = createEntity(MF.fS, "mf-interior-wall-horizontal", {0, -wallY}, MF.ent.force)
    MF.interiorWallVertical = createEntity(MF.fS, "mf-interior-wall-vertical", {wallY, 0}, MF.ent.force)
    MF.interiorWallVertical2 = createEntity(MF.fS, "mf-interior-wall-vertical", {-wallY, 0}, MF.ent.force)
    if MF.ent.name == "MegaFactory" then
        MF.energyCoreWall = createEntity(MF.fS, "mf-interior-wall-horizontal", {0, -tier.half + 12}, MF.ent.force)
    end
end

local function createPowerInterface(MF, tier)
    if not MF.interiorPower or not MF.interiorPower.valid then
        MF.interiorPower = createEntity(MF.fS, "mf-interior-power-interface", {0, tier.half - 2}, MF.ent.force)
    end
end

local function createEnergyCore(MF, tier)
    if MF.ent.name ~= "MegaFactory" then return end
    if MF.energyCoreGenerator == nil or not MF.energyCoreGenerator.valid then
        MF.energyCoreGenerator = createEntity(MF.fS, "mf-energy-core-generator", {-7, -tier.half + 6}, MF.ent.force)
    end
    if MF.energyCoreAccumulator == nil or not MF.energyCoreAccumulator.valid then
        MF.energyCoreAccumulator = createEntity(MF.fS, "mf-energy-core-accumulator", {7, -tier.half + 6}, MF.ent.force)
    end
end

local function createTerminal(MF, tier)
    if MF.interiorTerminal and MF.interiorTerminal.valid then return end
    MF.interiorTerminal = createEntity(MF.fS, "mf-interior-terminal-car", {0, tier.half - 5}, MF.ent.force)
    if MF.interiorTerminal then
        MF.interiorTerminal.tags = {mobile_factory_unit_number = MF.ent.unit_number}
        MF.interiorTerminal.destructible = false
        MF.interiorTerminal.minable = false
    end
end

function MFInterior.create(MF)
    if MF == nil or MF.ent == nil or not MF.ent.valid then return nil end
    local tier = tierFor(MF)
    local name = surfaceName(MF)
    local surface = game.get_surface(name)

    if surface == nil then
        surface = game.create_surface(name, {
            default_enable_all_autoplace_controls = false,
            property_expression_names = {cliffiness = 0},
            peaceful_mode = true,
            starting_area = "none"
        })
        surface.always_day = true
        surface.daytime = 0.5
        surface.wind_speed = 0
        surface.request_to_generate_chunks({0, 0}, 3)
        surface.force_generate_chunk_requests()
        setFloor(surface, tier.half, MF.ent.name == "MegaFactory")
    end

    MF.fS = surface
    createWalls(MF, tier)
    createPowerInterface(MF, tier)
    createTerminal(MF, tier)
    createEnergyCore(MF, tier)
    MF.interiorTier = tier.tier
    MF.interiorSize = tier.size
    return surface
end

function MFInterior.destroy(MF)
    if MF == nil then return end
    for _, key in pairs({
        "interiorTerminal", "interiorPower", "energyCoreGenerator", "energyCoreAccumulator",
        "interiorWallHorizontal", "interiorWallHorizontal2", "interiorWallVertical", "interiorWallVertical2", "energyCoreWall"
    }) do
        local ent = MF[key]
        if ent and ent.valid then ent.destroy() end
        MF[key] = nil
    end
    if MF.fS and MF.fS.valid then
        local surface = MF.fS
        MF.fS = nil
        if game.surfaces[surface.name] then game.delete_surface(surface) end
    end
end

function MFInterior.getBySurface(surface)
    if surface == nil then return nil end
    for _, MF in pairs(storage.MFTable or {}) do
        if MF.fS == surface then return MF end
    end
    return nil
end

function MFInterior.getByEntity(entity)
    if entity == nil or not entity.valid or entity.unit_number == nil then return nil end
    return storage.MFTable and storage.MFTable[entity.unit_number] or nil
end

function MFInterior.enter(MF, player)
    if MF == nil or player == nil or not player.valid or MF.ent == nil or not MF.ent.valid then return false end
    if not MF.fS or not MF.fS.valid then MFInterior.create(MF) end
    local tier = tierFor(MF)
    local target = MF.fS.find_non_colliding_position("character", {0, tier.half - 9}, 6, 0.5)
    if not target then return false end
    player.teleport(target, MF.fS)
    player.opened = nil
    return true
end

function MFInterior.exit(MF, player)
    if MF == nil or player == nil or not player.valid or MF.ent == nil or not MF.ent.valid then return false end
    local target = MF.ent.surface.find_non_colliding_position("character", {MF.ent.position.x, MF.ent.position.y + 6}, 8, 0.5)
    if not target then return false end
    player.teleport(target, MF.ent.surface)
    player.opened = nil
    return true
end

function MFInterior.enterEnergyCore(MF, player)
    if MF == nil or MF.ent == nil or not MF.ent.valid or MF.ent.name ~= "MegaFactory" then return false end
    if MF.fS == nil or not MF.fS.valid then MFInterior.create(MF) end
    local tier = tierFor(MF)
    local target = MF.fS.find_non_colliding_position("character", {0, -tier.half + 6}, 4, 0.5)
    if not target then return false end
    player.teleport(target, MF.fS)
    return true
end

function MFInterior.exitEnergyCore(MF, player)
    if MF == nil or MF.fS == nil or not MF.fS.valid then return false end
    local tier = tierFor(MF)
    local target = MF.fS.find_non_colliding_position("character", {0, -tier.half + 16}, 6, 0.5)
    if not target then return false end
    player.teleport(target, MF.fS)
    return true
end

function MFInterior.enterVehicleFromTerminal(player, terminal)
    if terminal == nil or not terminal.valid or terminal.name ~= "mf-interior-terminal-car" then return false end
    local unit = terminal.tags and terminal.tags.mobile_factory_unit_number
    local MF = unit and storage.MFTable[unit] or nil
    if MF == nil or MF.ent == nil or not MF.ent.valid then return false end
    terminal.set_driver(nil)
    local target = MF.ent.surface.find_non_colliding_position(MF.ent.name, MF.ent.position, 8, 0.5)
    if target == nil then return false end
    player.teleport(target, MF.ent.surface)
    MF.ent.set_driver(player)
    return true
end

local function addButton(flow, name, caption, MF, enabled)
    local button = flow.add{type = "button", name = name, caption = caption}
    button.tags = {mobile_factory_unit_number = MF.ent.unit_number}
    if enabled ~= nil then button.enabled = enabled end
    return button
end

local function closeFactoryGUI(player)
    local gui = player.gui.screen["MFInteriorTerminalGUI"]
    if gui and gui.valid then gui.destroy() end
    player.opened = nil
end

function MFInterior.openTerminal(player, MF)
    if MF == nil or MF.ent == nil or not MF.ent.valid then return end
    local gui = player.gui.screen["MFInteriorTerminalGUI"]
    if gui and gui.valid then gui.destroy() end

    gui = player.gui.screen.add{
        type = "frame",
        name = "MFInteriorTerminalGUI",
        direction = "horizontal",
        caption = {"entity-name." .. MF.ent.name}
    }
    gui.auto_center = true
    gui.tags = {mobile_factory_unit_number = MF.ent.unit_number}

    local left = gui.add{type = "flow", name = "MFInteriorControls", direction = "vertical"}
    left.style.width = 260
    left.add{type = "label", caption = {"gui-description.MFInteriorTerminalHint"}}
    addButton(left, "MFInterior.OpenInventory", {"gui-description.MFInteriorOpenInventory"}, MF)
    addButton(left, "MFInterior.AssignTeleport", {"gui-description.MFInteriorAssignTeleport"}, MF)

    local inCore = false
    if MF.ent.name == "MegaFactory" then
        local tier = tierFor(MF)
        inCore = player.surface == MF.fS and player.position.y < -tier.half + 13
    end
    addButton(
        left,
        "MFInterior.EnergyCore",
        {inCore and "gui-description.MFInteriorExitEnergyCore" or "gui-description.MFInteriorEnterEnergyCore"},
        MF,
        MF.ent.name == "MegaFactory"
    )

    local inside = player.surface == MF.fS
    addButton(
        left,
        "MFInterior.Exit",
        {inside and "gui-description.MFInteriorExit" or "gui-description.MFInteriorEnter"},
        MF
    )

    local inv = MF.ent.get_inventory(defines.inventory.car_trunk)
    if inv ~= nil then
        local invFrame = gui.add{type = "frame", name = "MFInteriorInventoryFrame", direction = "vertical"}
        invFrame.style.width = 520
        invFrame.add{type = "label", caption = {"gui-description.MFInteriorInventory"}}
        local invGui = invFrame.add{type = "inventory", name = "Inventory", slots_per_row = 10}
        invGui.inventory = inv
        invGui.handle_cursor_transfer = true
        invGui.handle_cursor_split = true
    end

    player.opened = gui
end

function MFInterior.assignTeleport(player, MF)
    if MF == nil or MF.ent == nil or not MF.ent.valid then return end
    storage.jumpMarkerMode[player.index] = true
    player.set_controller{
        type = defines.controllers.remote,
        position = player.position,
        surface = player.surface
    }
end

function MFInterior.handleGuiClick(event)
    local player = game.players[event.player_index]
    if not player or not player.valid or not event.element or not event.element.valid then return false end
    local name = event.element.name
    if name ~= "MFInterior.OpenInventory" and name ~= "MFInterior.AssignTeleport"
        and name ~= "MFInterior.Exit" and name ~= "MFInterior.EnergyCore" then return false end

    local unit = event.element.tags and event.element.tags.mobile_factory_unit_number
    local MF = unit and storage.MFTable[unit] or MFInterior.getBySurface(player.surface)
    if MF == nil then return true end

    if name == "MFInterior.OpenInventory" then
        return true
    elseif name == "MFInterior.AssignTeleport" then
        MFInterior.assignTeleport(player, MF)
    elseif name == "MFInterior.EnergyCore" then
        local tier = tierFor(MF)
        local inCore = player.surface == MF.fS and player.position.y < -tier.half + 13
        if inCore then MFInterior.exitEnergyCore(MF, player) else MFInterior.enterEnergyCore(MF, player) end
        MFInterior.openTerminal(player, MF)
    else
        if player.surface == MF.fS then
            closeFactoryGUI(player)
            MFInterior.exit(MF, player)
        else
            MFInterior.enter(MF, player)
            MFInterior.openTerminal(player, MF)
        end
    end
    return true
end

function MFInterior.onGuiOpened(event)
    local player = game.players[event.player_index]
    local entity = event.entity
    if player == nil or entity == nil or not entity.valid then return false end

    local MF = MFInterior.getByEntity(entity)
    if MF == nil and entity.name == "mf-interior-terminal-car" then MF = MFInterior.getBySurface(entity.surface) end
    if MF == nil then return false end

    if entity.name == "mf-interior-terminal-car" or entity.name == "SmallFactory"
        or entity.name == "SuperFactory" or entity.name == "MegaFactory" then
        MFInterior.openTerminal(player, MF)
        return true
    end
    return false
end

function MFInterior.onGuiClosed(event)
    return false
end

function MFInterior.onDrivingChanged(event)
    local player, vehicle = game.players[event.player_index], event.entity
    if player == nil or vehicle == nil or not vehicle.valid or vehicle.name ~= "mf-interior-terminal-car" then return false end
    if vehicle.get_driver() ~= player then return false end
    return MFInterior.enterVehicleFromTerminal(player, vehicle)
end

function MFInterior.update()
    for _, MF in pairs(storage.MFTable or {}) do
        if MF.ent and MF.ent.valid then
            if not MF.fS or not MF.fS.valid then MFInterior.create(MF) end
            local tier = tierFor(MF)
            if MF.interiorTerminal and MF.interiorTerminal.valid and MF.interiorTerminal.get_driver() == nil then
                MF.interiorTerminal.teleport({0, tier.half - 5})
                MF.interiorTerminal.speed = 0
            end
        end
    end
end
