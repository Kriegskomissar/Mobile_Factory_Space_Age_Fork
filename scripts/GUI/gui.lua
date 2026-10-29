-- CURRENT MOBILE FACTORY GUI -------------------------------------------------
-- The factory GUI is opened by Factorio's normal entity interaction. There is
-- no permanent floating panel and no GUI state is stored in `storage`.

GUI = GUI or {}

function GUI.openFactoryGUI(player, MF)
    if player == nil or not player.valid or MF == nil or MF.ent == nil or not MF.ent.valid then return end
    MFInterior.openTerminal(player, MF)
end

function GUI.guiOpened(event)
    local player = game.players[event.player_index]
    local entity = event.entity
    if player == nil or entity == nil or not entity.valid then return false end

    if entity.name == "SmallFactory" or entity.name == "SuperFactory" or entity.name == "MegaFactory" then
        local MF = MFInterior.getByEntity(entity)
        if MF ~= nil then
            GUI.openFactoryGUI(player, MF)
            return true
        end
    elseif entity.name == "mf-interior-terminal-car" then
        local MF = MFInterior.getByEntity(entity) or MFInterior.getBySurface(entity.surface)
        if MF ~= nil then
            GUI.openFactoryGUI(player, MF)
            return true
        end
    end
    return false
end

function GUI.guiClosed(event)
    local player = game.players[event.player_index]
    if player == nil or not player.valid then return false end
    local gui = player.gui.screen["MFInteriorTerminalGUI"]
    if gui and gui.valid then gui.destroy() end
    return false
end

function GUI.buttonClicked(event)
    local player = game.players[event.player_index]
    if player == nil or not player.valid or event.element == nil or not event.element.valid then return false end
    local name = event.element.name
    if string.sub(name, 1, 11) == "MFInterior." then
        return MFInterior.handleGuiClick(event)
    end
    return false
end

function GUI.onGuiElemChanged(event)
    return false
end

function GUI.onStringTranslated(event)
    return false
end
