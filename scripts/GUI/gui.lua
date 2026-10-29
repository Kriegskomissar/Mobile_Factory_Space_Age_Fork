

-- Compatibility handlers retained after the interior GUI refactor.
function GUI.onStringTranslated(event)
    local MFPlayer = getMFPlayer(event.player_index)
    if MFPlayer == nil then return end
    local GUITable = MFPlayer.GUI[_mfGUIName.RecipeGUI] or MFPlayer.GUI[_mfGUIName.TooltipGUI]
    if GUITable == nil or GUITable.gui == nil or GUITable.gui.valid == false then return end
    if event.localised_string == nil or event.localised_string[1] == nil then return end
    GUITable.vars.tmpLocal = GUITable.vars.tmpLocal or {}
    GUITable.vars.tmpLocal[event.localised_string[1]] = event.result
end

local _mfGuiInteriorOldButtonClicked = GUI.buttonClicked
function GUI.buttonClicked(event)
    if event.element and event.element.valid then
        if event.element.name == "MFInterior.OpenInventory" or event.element.name == "MFInterior.AssignTeleport" or event.element.name == "MFInterior.Exit" or event.element.name == "MFInterior.InventoryClose" then
            if MFInterior.handleGuiClick(event) then return end
        end
        if event.element.name == "MFEnterInsideButton" then
            local player = getPlayer(event.player_index)
            local MF = getCurrentMF(player.name) or getMF(player.name)
            if MF then MFInterior.enter(MF, player) end
            return
        end
        if event.element.name == "PortOutsideButton" then
            local player = getPlayer(event.player_index)
            local MF = getCurrentMF(player.name) or getMF(player.name)
            if player and MF and player.surface == MF.fS and event.button ~= defines.mouse_button_type.right then
                MFInterior.exit(MF, player)
                return
            end
        end
    end
    return _mfGuiInteriorOldButtonClicked(event)
end

local _mfGuiInteriorOldGuiOpened = GUI.guiOpened
function GUI.guiOpened(event)
    if event.entity and event.entity.valid and event.entity.name == "mf-interior-terminal-car" then
        local player = getPlayer(event.player_index)
        local MF = MFInterior.getBySurface(event.entity.surface)
        if MF then MFInterior.openTerminal(player, MF) end
        return
    end
    return _mfGuiInteriorOldGuiOpened(event)
end
