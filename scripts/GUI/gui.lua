-- CURRENT MOBILE FACTORY GUI -------------------------------------------------
-- The old Mobile Factory GUI depended on removed Control Center, Quatron,
-- Internal Energy and Data Network systems. The current design only needs a
-- small exterior entry button and the dedicated interior terminal GUI.

GUI = GUI or {}

local function destroyMainGUI(player)
    if not player or not player.valid then return end
    local gui = player.gui.screen["MFMainGUI"]
    if gui and gui.valid then gui.destroy() end
end

function GUI.createMFMainGUI(player)
    if player == nil or not player.valid then return nil end

    local MFPlayer = getMFPlayer(player.index)
    if MFPlayer == nil then return nil end
    MFPlayer.GUI = MFPlayer.GUI or {}

    destroyMainGUI(player)

    local frame = player.gui.screen.add{
        type = "frame",
        name = "MFMainGUI",
        direction = "horizontal",
        caption = "Mobile Factory"
    }
    frame.auto_center = false
    frame.location = {x = 20, y = 120}

    frame.add{
        type = "button",
        name = "MFEnterInsideButton",
        caption = "Зайти внутрь"
    }

    MFPlayer.GUI.MFMainGUI = {
        gui = frame,
        MFPlayer = MFPlayer
    }
    return MFPlayer.GUI.MFMainGUI
end

function GUI.updateAllGUIs(force)
    for _, player in pairs(game.connected_players) do
        local MFPlayer = getMFPlayer(player.index)
        if MFPlayer == nil then goto continue end
        local entry = MFPlayer.GUI and MFPlayer.GUI.MFMainGUI
        if entry == nil or entry.gui == nil or not entry.gui.valid then
            GUI.createMFMainGUI(player)
        end
        ::continue::
    end
end

function GUI.openTTGui(MFPlayer, player, entity)
    if entity == nil or not entity.valid or player == nil then return end
    if entity.name == "mf-interior-terminal-car" then
        local MF = MFInterior.getBySurface(entity.surface)
        if MF ~= nil then MFInterior.openTerminal(player, MF) end
    end
end

function GUI.guiOpened(event)
    local player = game.players[event.player_index]
    local entity = event.entity
    if player == nil or entity == nil or not entity.valid then return false end

    if entity.name == "mf-interior-terminal-car" then
        local MF = MFInterior.getBySurface(entity.surface)
        if MF ~= nil then
            MFInterior.openTerminal(player, MF)
            return true
        end
    end

    return false
end

function GUI.guiClosed(event)
    return false
end

function GUI.buttonClicked(event)
    local player = game.players[event.player_index]
    if player == nil or not player.valid or event.element == nil or not event.element.valid then return false end

    local name = event.element.name

    if name == "MFEnterInsideButton" then
        local MF = getCurrentMF(player.index)
        if MF ~= nil then
            MFInterior.enter(MF, player)
        end
        return true
    end

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
