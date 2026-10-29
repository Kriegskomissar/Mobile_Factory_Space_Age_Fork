require("scripts/GUI/main-gui.lua")
require("scripts/GUI/info-gui.lua")
require("scripts/GUI/option-gui.lua")
require("scripts/GUI/tooltip-gui.lua")
require("scripts/GUI/options.lua")
require("scripts/GUI/deploy-gui.lua")
require("scripts/GUI/tp-gui.lua")
require("scripts/GUI/switchMF-gui.lua")
require("scripts/GUI/recipe-gui.lua")
require("scripts/objects/mobile-factory-interior.lua")
require("utils/functions.lua")

function GUI.updateAllGUIs(force)
    for _, player in pairs(game.connected_players) do
        local MFPlayer = getMFPlayer(player.name)
        if MFPlayer ~= nil then
            if game.tick%_eventTick7 == 0 or force then
                if MFPlayer.GUI ~= nil and MFPlayer.GUI.MFTooltipGUI ~= nil and MFPlayer.GUI.MFTooltipGUI.DA ~= nil then
                    if mfCall(MFPlayer.GUI.MFTooltipGUI.DA.updatePBars, MFPlayer.GUI.MFTooltipGUI) == true then end
                end
            end
            if game.tick%_eventTick55 == 0 or force then
                for _, GUItable in pairs(MFPlayer.GUI or {}) do
                    if GUItable.gui ~= nil and GUItable.gui.valid == true and GUI["update" .. GUItable.gui.name] ~= nil then
                        if mfCall(GUI["update" .. GUItable.gui.name], GUItable) == true then
                            player.print({"gui-description.updatingGUI_Failed"})
                            mfCall(Event.clearGUI, {player_index=player.index})
                        end
                    end
                end
            end
        end
    end
end

function GUI.openTTGui(MFPlayer, player, entity)
    if entity == nil or entity.valid == false then return end
    if entity.name == "mf-interior-terminal-car" then
        local MF = MFInterior.getBySurface(entity.surface)
        if MF ~= nil then MFInterior.openTerminal(player, MF) end
        return
    end
    local cursorStack = player.cursor_stack
    if cursorStack and cursorStack.valid_for_read and (cursorStack.name == "green-wire" or cursorStack.name == "red-wire" or cursorStack.type == "repair-tool") then return end
    local obj = storage.entsTable[entity.unit_number] or storage.objectsTable[entity.unit_number]
    if valid(obj) == false or (obj.getTooltipInfos == nil and obj.meta == nil) then return end
    if canUse(MFPlayer, obj) == false then player.opened = nil return end
    local GUITable = GUI.createTooltipGUI(player, obj)
    player.opened = GUITable.gui
    MFPlayer.GUI[_mfGUIName.TooltipGUI] = GUITable
end

function GUI.guiOpened(event)
    if event.entity == nil or event.entity.valid == false then return end
    local player = getPlayer(event.player_index)
    local MFPlayer = getMFPlayer(event.player_index)
    if mfCall(GUI.openTTGui, MFPlayer, player, event.entity) == true then
        player.print({"gui-description.openTTGui_Failed"})
        Event.clearGUI(event)
    end
end

function GUI.guiClosed(event)
    if event.element == nil or event.element.valid ~= true then return end
    local MFPlayer = getMFPlayer(event.player_index)
    local names = {_mfGUIName.InfoGUI, _mfGUIName.OptionGUI, _mfGUIName.TooltipGUI, _mfGUIName.DeployGUI, _mfGUIName.TPGUI, _mfGUIName.SwitchMF, _mfGUIName.RecipeGUI, _mfGUIName.RecipeInfoGUI}
    for _, name in pairs(names) do
        if event.element.name == name and MFPlayer.GUI[name] ~= nil then
            MFPlayer.GUI[name].gui.destroy(); MFPlayer.GUI[name] = nil; return
        end
    end
end

function GUI.buttonClicked(event)
    local playerIndex = event.player_index
    local player = getPlayer(playerIndex)
    local MFPlayer = getMFPlayer(playerIndex)
    if player == nil or MFPlayer == nil then return end
    if MFInterior.handleGuiClick(event) then return end

    local MF = getMF(player.name)
    if MF == nil then return end
    local currentMF = getCurrentMF(player.name) or MF
    local mainGUI = MFPlayer.GUI[_mfGUIName.MainGUI]

    if event.element.name == "MainGUIInfosButton" then
        if MFPlayer.GUI[_mfGUIName.InfoGUI] == nil then
            local GUITable = GUI.createInfoGui(player); MFPlayer.GUI[_mfGUIName.InfoGUI] = GUITable; player.opened = GUITable.gui
        else
            MFPlayer.GUI[_mfGUIName.InfoGUI].gui.destroy(); MFPlayer.GUI[_mfGUIName.InfoGUI] = nil
        end
        return
    end
    if event.element.name == "MainGUIOptionButton" then
        if MFPlayer.GUI[_mfGUIName.OptionGUI] == nil then
            local GUITable = GUI.createOptionGUI(player); MFPlayer.GUI[_mfGUIName.OptionGUI] = GUITable; player.opened = GUITable.gui
        else
            MFPlayer.GUI[_mfGUIName.OptionGUI].gui.destroy(); MFPlayer.GUI[_mfGUIName.OptionGUI] = nil
        end
        return
    end
    if event.element.name == "MFEnterInsideButton" then
        MFInterior.enter(currentMF, player)
        return
    end
    if event.element.name == "MFDeployButton" then
        if event.button == defines.mouse_button_type.right then player.clear_cursor(); player.cursor_stack.set_stack({name="MFDeploy", count=1}); return end
        if MFPlayer.GUI[_mfGUIName.DeployGUI] == nil then local GUITable = GUI.createDeployGUI(player); MFPlayer.GUI[_mfGUIName.DeployGUI] = GUITable; player.opened = GUITable.gui else MFPlayer.GUI[_mfGUIName.DeployGUI].gui.destroy(); MFPlayer.GUI[_mfGUIName.DeployGUI] = nil end
        return
    end
    if event.element.name == "JumpDriveButton" then
        if MFPlayer.GUI[_mfGUIName.TPGUI] == nil then local GUITable = GUI.createTPGui(player); MFPlayer.GUI[_mfGUIName.TPGUI] = GUITable; player.opened = GUITable.gui else MFPlayer.GUI[_mfGUIName.TPGUI].gui.destroy(); MFPlayer.GUI[_mfGUIName.TPGUI] = nil end
        return
    end
    if event.element.name == "PortOutsideButton" then
        if event.button == defines.mouse_button_type.right then teleportPlayerToDriverSeat(player) else MFInterior.exit(currentMF, player) end
        return
    end
    if event.element.name == "FindMFButton" then fixMB(event, currentMF); return end
    if event.element.name == "TPInsideButton" then currentMF.tpEnabled = not currentMF.tpEnabled; GUI.updateAllGUIs(true); return end
    if event.element.name == "LockMFButton" then currentMF.locked = not currentMF.locked; GUI.updateAllGUIs(true); return end
    if event.element.name == "EnergyDrainButton" then currentMF.energyLaserActivated = not currentMF.energyLaserActivated; GUI.updateAllGUIs(true); return end
    if event.element.name == "FluidDrainButton" then currentMF.fluidLaserActivated = not currentMF.fluidLaserActivated; GUI.updateAllGUIs(true); return end
    if event.element.name == "ItemDrainButton" then currentMF.itemLaserActivated = not currentMF.itemLaserActivated; GUI.updateAllGUIs(true); return end
    if event.element.name == "QuatronDrainButton" then currentMF.quatronLaserActivated = not currentMF.quatronLaserActivated; GUI.updateAllGUIs(true); return end
    if event.element.name == _mfGUIName.InfoGUI .. "CloseButton" or event.element.name == _mfGUIName.OptionGUI .. "CloseButton" or event.element.name == _mfGUIName.TooltipGUI .. "CloseButton" or event.element.name == _mfGUIName.DeployGUI .. "CloseButton" or event.element.name == _mfGUIName.TPGUI .. "CloseButton" or event.element.name == _mfGUIName.SwitchMF .. "CloseButton" or event.element.name == _mfGUIName.RecipeGUI .. "CloseButton" or event.element.name == _mfGUIName.RecipeInfoGUI .. "CloseButton" then
        local prefixes = {_mfGUIName.InfoGUI, _mfGUIName.OptionGUI, _mfGUIName.TooltipGUI, _mfGUIName.DeployGUI, _mfGUIName.TPGUI, _mfGUIName.SwitchMF, _mfGUIName.RecipeGUI, _mfGUIName.RecipeInfoGUI}
        for _, name in pairs(prefixes) do if event.element.name == name .. "CloseButton" and MFPlayer.GUI[name] ~= nil then MFPlayer.GUI[name].gui.destroy(); MFPlayer.GUI[name] = nil end end
        return
    end
    if event.element.name == "MainGUIOpen" then mainGUI.MFPlayer.varTable.MainGUIOpen = true; GUI.updateMFMainGUI(mainGUI); return end
    if event.element.name == "MainGUIClose" then mainGUI.MFPlayer.varTable.MainGUIOpen = false; GUI.updateMFMainGUI(mainGUI); return end
    if string.match(event.element.name, "Inf.GUI.") then GUI.infoGUIInteraction(event, player, MFPlayer); GUI.updateAllGUIs(true); return end
    if string.match(event.element.name, "Opt.GUI.") then GUI.readOptions(event.element, player); GUI.updateAllGUIs(true); return end
    if string.match(event.element.name, "Swi.GUI.") then GUI.switchMFGUIInteraction(event, player, MFPlayer); GUI.updateAllGUIs(true); return end
    if string.match(event.element.name, "TP.GUI.") then GUI.TPMFGUIInteraction(event, MFPlayer, currentMF); GUI.updateAllGUIs(true); return end
    if string.match(event.element.name, "DP.GUI.") then GUI.MFDPGUIInteraction(event, MFPlayer, currentMF); GUI.updateAllGUIs(true); return end
    if string.match(event.element.name, "Rec.GUI.") then GUI.recipeGUIInteraction(event, MFPlayer); GUI.updateAllGUIs(true); return end
    if string.match(event.element.name, "M.F.") then MF.interaction(event, player, MFPlayer); GUI.updateAllGUIs(true); return end
end

function GUI.onGuiElemChanged(event)
    if event.element == nil or event.element.valid == false then return end
    if event.element.get_mod() ~= "Mobile_Factory_Space_Age" then return end
    local player = getPlayer(event.player_index)
    local MFPlayer = getMFPlayer(event.player_index)
    if player == nil or MFPlayer == nil then return end
    local MF = getMF(player.name)
    if MF == nil then return end
    if string.match(event.element.name, "Opt.GUI.") then GUI.readOptions(event.element, player); GUI.updateAllGUIs(true); return end
    if string.match(event.element.name, "Inf.GUI.") then GUI.infoGUIInteraction(event, player, MFPlayer); GUI.updateAllGUIs(true); return end
    if string.match(event.element.name, "Swi.GUI.") then GUI.switchMFGUIInteraction(event, player, MFPlayer); GUI.updateAllGUIs(true); return end
    if string.match(event.element.name, "TP.GUI.") then GUI.TPMFGUIInteraction(event, MFPlayer, getCurrentMF(player.name) or MF); GUI.updateAllGUIs(true); return end
end
