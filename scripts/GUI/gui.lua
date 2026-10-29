require("scripts/GUI/main-gui.lua")
require("scripts/GUI/info-gui.lua")
require("scripts/GUI/option-gui.lua")
require("scripts/GUI/tooltip-gui.lua")
require("scripts/GUI/options.lua")
require("scripts/GUI/deploy-gui.lua")
require("scripts/GUI/tp-gui.lua")
require("scripts/GUI/switchMF-gui.lua")
require("scripts/GUI/recipe-gui.lua")
require("utils/functions.lua")
require("scripts/objects/mobile-factory-interior.lua")

function GUI.updateAllGUIs(force)
    for _, player in pairs(game.connected_players) do
        local MFPlayer = getMFPlayer(player.name)
        if MFPlayer ~= nil then
            if game.tick%_eventTick7 == 0 or force then
                if MFPlayer.GUI ~= nil and MFPlayer.GUI.MFTooltipGUI ~= nil and MFPlayer.GUI.MFTooltipGUI.DA ~= nil then
                    MFPlayer.GUI.MFTooltipGUI.DA:updatePBars(MFPlayer.GUI.MFTooltipGUI)
                end
            end
            if game.tick%_eventTick55 == 0 or force then
                for _, GUItable in pairs(MFPlayer.GUI or {}) do
                    if GUItable.gui ~= nil and GUItable.gui.valid == true and GUI["update" .. GUItable.gui.name] ~= nil then
                        if mfCall(GUI["update" .. GUItable.gui.name],GUItable) == true then
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
    if cursorStack and cursorStack.valid_for_read then
        if cursorStack.name == "green-wire" or cursorStack.name == "red-wire" or cursorStack.type == "repair-tool" then return end
    end
    local obj = storage.entsTable[entity.unit_number] or storage.objectsTable[entity.unit_number]
    if valid(obj) == false or (obj.getTooltipInfos == nil and (obj.meta == nil or _G[obj.meta] == nil or _G[obj.meta].getTooltipInfos == nil)) then return end
    if canUse(MFPlayer, obj) == false then player.opened = nil return end
    local GUITable = GUI.createTooltipGUI(player, obj)
    player.opened = GUITable.gui
    MFPlayer.GUI[_mfGUIName.TooltipGUI] = GUITable
end

function GUI.guiOpened(event)
    if event.entity == nil or event.entity.valid == false then return end
    local player = getPlayer(event.player_index)
    local MFPlayer = getMFPlayer(event.player_index)
    if event.entity.name == "mf-interior-terminal-car" then
        local MF = MFInterior.getBySurface(event.entity.surface)
        if MF then MFInterior.openTerminal(player, MF) end
        return
    end
    if mfCall(GUI.openTTGui, MFPlayer, player, event.entity) == true then
        player.print({"gui-description.openTTGui_Failed"})
        Event.clearGUI(event)
    end
end

function GUI.guiClosed(event)
    if event.element == nil or event.element.valid ~= true then return end
    local playerIndex = event.player_index
    local MFPlayer = getMFPlayer(playerIndex)
    if event.element.name == _mfGUIName.InfoGUI then MFPlayer.GUI[_mfGUIName.InfoGUI].gui.destroy(); MFPlayer.GUI[_mfGUIName.InfoGUI] = nil; return end
    if event.element.name == _mfGUIName.OptionGUI then MFPlayer.GUI[_mfGUIName.OptionGUI].gui.destroy(); MFPlayer.GUI[_mfGUIName.OptionGUI] = nil; return end
    if event.element.name == _mfGUIName.TooltipGUI then MFPlayer.GUI[_mfGUIName.TooltipGUI].gui.destroy(); MFPlayer.GUI[_mfGUIName.TooltipGUI] = nil; return end
    if event.element.name == _mfGUIName.DeployGUI then MFPlayer.GUI[_mfGUIName.DeployGUI].gui.destroy(); MFPlayer.GUI[_mfGUIName.DeployGUI] = nil; return end
    if event.element.name == _mfGUIName.TPGUI then MFPlayer.GUI[_mfGUIName.TPGUI].gui.destroy(); MFPlayer.GUI[_mfGUIName.TPGUI] = nil; return end
    if event.element.name == _mfGUIName.SwitchMF then MFPlayer.GUI[_mfGUIName.SwitchMF].gui.destroy(); MFPlayer.GUI[_mfGUIName.SwitchMF] = nil; return end
    if string.match(event.element.name, "Camera") then
        local cameraName = event.element.name
        if MFPlayer.GUI[cameraName] ~= nil then MFPlayer.GUI[cameraName].destroy(); MFPlayer.GUI[cameraName] = nil end
        return
    end
end

function GUI.buttonClicked(event)
    local playerIndex = event.player_index
    local player = getPlayer(playerIndex)
    local MFPlayer = getMFPlayer(playerIndex)
    if player == nil or MFPlayer == nil then return end
    local MF = getMF(player.name)
    if MF == nil then return end
    local currentMF = getCurrentMF(player.name) or MF
    local mainGUI = MFPlayer.GUI[_mfGUIName.MainGUI]
    if MFPlayer.GUI[_mfGUIName.InfoGUI] ~= nil then MFPlayer.GUI[_mfGUIName.InfoGUI].vars.freezeTankGUI = false; MFPlayer.GUI[_mfGUIName.InfoGUI].vars.freezeStorageGUI = false end
    if event.element.name == "MFInterior.OpenInventory" or event.element.name == "MFInterior.AssignTeleport" or event.element.name == "MFInterior.Exit" or event.element.name == "MFInterior.InventoryClose" then if MFInterior.handleGuiClick(event) then return end end
    if event.element.name == "MFEnterInsideButton" then MFInterior.enter(currentMF, player); return end
    if event.element.name == "MainGUIInfosButton" then
        if MFPlayer.GUI[_mfGUIName.InfoGUI] == nil then local GUITable = GUI.createInfoGui(player); MFPlayer.GUI[_mfGUIName.InfoGUI] = GUITable; player.opened = GUITable.gui else MFPlayer.GUI[_mfGUIName.InfoGUI].gui.destroy(); MFPlayer.GUI[_mfGUIName.InfoGUI] = nil end; return
    end
    if event.element.name == "MainGUIOptionButton" then
        if MFPlayer.GUI[_mfGUIName.OptionGUI] == nil then local GUITable = GUI.createOptionGUI(player); MFPlayer.GUI[_mfGUIName.OptionGUI] = GUITable; player.opened = GUITable.gui else MFPlayer.GUI[_mfGUIName.OptionGUI].gui.destroy(); MFPlayer.GUI[_mfGUIName.OptionGUI] = nil end; return
    end
    if event.element.name == "MFDeployButton" then
        if event.button == defines.mouse_button_type.right then player.clear_cursor(); player.cursor_stack.set_stack({name="MFDeploy", count=1}); return end
        if MFPlayer.GUI[_mfGUIName.DeployGUI] == nil then local GUITable = GUI.createDeployGUI(player); MFPlayer.GUI[_mfGUIName.DeployGUI] = GUITable; player.opened = GUITable.gui else MFPlayer.GUI[_mfGUIName.DeployGUI].gui.destroy(); MFPlayer.GUI[_mfGUIName.DeployGUI] = nil end; return
    end
    if event.element.name == "JumpDriveButton" then
        if MFPlayer.GUI[_mfGUIName.TPGUI] == nil then local GUITable = GUI.createTPGui(player); MFPlayer.GUI[_mfGUIName.TPGUI] = GUITable; player.opened = GUITable.gui else MFPlayer.GUI[_mfGUIName.TPGUI].gui.destroy(); MFPlayer.GUI[_mfGUIName.TPGUI] = nil end; return
    end
    if event.element.name == "PortOutsideButton" then
        if event.button == defines.mouse_button_type.right then teleportPlayerToDriverSeat(player) else
            if player.surface == currentMF.fS then MFInterior.exit(currentMF, player) else teleportPlayerOutside(player) end
            return
        end
    end
    if event.element.name == "FindMFButton" then fixMB(event, currentMF); return end
    if event.element.name == "TPInsideButton" then currentMF.tpEnabled = not currentMF.tpEnabled; GUI.updateAllGUIs(true); return end
    if event.element.name == "LockMFButton" then currentMF.locked = not currentMF.locked; GUI.updateAllGUIs(true); return end
    if event.element.name == "EnergyDrainButton" then currentMF.energyLaserActivated = not currentMF.energyLaserActivated; GUI.updateAllGUIs(true); return end
    if event.element.name == "FluidDrainButton" then currentMF.fluidLaserActivated = not currentMF.fluidLaserActivated; GUI.updateAllGUIs(true); return end
    if event.element.name == "ItemDrainButton" then currentMF.itemLaserActivated = not currentMF.itemLaserActivated; GUI.updateAllGUIs(true); return end
    if event.element.name == "QuatronDrainButton" then currentMF.quatronLaserActivated = not currentMF.quatronLaserActivated; GUI.updateAllGUIs(true); return end
    if event.element.name == _mfGUIName.InfoGUI .. "CloseButton" then if MFPlayer.GUI[_mfGUIName.InfoGUI] then MFPlayer.GUI[_mfGUIName.InfoGUI].gui.destroy(); MFPlayer.GUI[_mfGUIName.InfoGUI] = nil end; return end
    if event.element.name == _mfGUIName.OptionGUI .. "CloseButton" then if MFPlayer.GUI[_mfGUIName.OptionGUI] then MFPlayer.GUI[_mfGUIName.OptionGUI].gui.destroy(); MFPlayer.GUI[_mfGUIName.OptionGUI] = nil end; return end
    if event.element.name == _mfGUIName.TooltipGUI .. "CloseButton" then if MFPlayer.GUI[_mfGUIName.TooltipGUI] then MFPlayer.GUI[_mfGUIName.TooltipGUI].gui.destroy(); MFPlayer.GUI[_mfGUIName.TooltipGUI] = nil end; return end
    if event.element.name == _mfGUIName.DeployGUI .. "CloseButton" then if MFPlayer.GUI[_mfGUIName.DeployGUI] then MFPlayer.GUI[_mfGUIName.DeployGUI].gui.destroy(); MFPlayer.GUI[_mfGUIName.DeployGUI] = nil end; return end
    if event.element.name == _mfGUIName.SlotGUI .. "CloseButton" then if MFPlayer.GUI[_mfGUIName.SlotGUI] then MFPlayer.GUI[_mfGUIName.SlotGUI].gui.destroy(); MFPlayer.GUI[_mfGUIName.SlotGUI] = nil end; return end
    if event.element.name == _mfGUIName.TPGUI .. "CloseButton" then if MFPlayer.GUI[_mfGUIName.TPGUI] then MFPlayer.GUI[_mfGUIName.TPGUI].gui.destroy(); MFPlayer.GUI[_mfGUIName.TPGUI] = nil end; return end
    if event.element.name == _mfGUIName.SwitchMF .. "CloseButton" then if MFPlayer.GUI[_mfGUIName.SwitchMF] then MFPlayer.GUI[_mfGUIName.SwitchMF].gui.destroy(); MFPlayer.GUI[_mfGUIName.SwitchMF] = nil end; return end
    if event.element.name == _mfGUIName.RecipeGUI .. "CloseButton" then if MFPlayer.GUI[_mfGUIName.RecipeGUI] then MFPlayer.GUI[_mfGUIName.RecipeGUI].gui.destroy(); MFPlayer.GUI[_mfGUIName.RecipeGUI] = nil end; return end
    if event.element.name == _mfGUIName.RecipeInfoGUI .. "CloseButton" then if MFPlayer.GUI[_mfGUIName.RecipeInfoGUI] then MFPlayer.GUI[_mfGUIName.RecipeInfoGUI].gui.destroy(); MFPlayer.GUI[_mfGUIName.RecipeInfoGUI] = nil end; return end
    if string.match(event.element.name, "MFCameraGUICloseButton") then if MFPlayer.GUI[_mfGUIName.CameraGUI] and MFPlayer.GUI[_mfGUIName.CameraGUI].gui then MFPlayer.GUI[_mfGUIName.CameraGUI].gui.destroy(); MFPlayer.GUI[_mfGUIName.CameraGUI] = nil end; return end
    if event.element.name == "MainGUIOpen" then mainGUI.MFPlayer.varTable.MainGUIOpen = true; GUI.updateMFMainGUI(mainGUI); return end
    if event.element.name == "MainGUIClose" then mainGUI.MFPlayer.varTable.MainGUIOpen = false; GUI.updateMFMainGUI(mainGUI); return end
    if string.match(event.element.name, "Inf.GUI.") then GUI.infoGUIInteraction(event, player, MFPlayer); GUI.updateAllGUIs(true); return end
    if string.match(event.element.name, "Opt.GUI.") then GUI.readOptions(event.element, player); GUI.updateAllGUIs(true); return end
    if string.match(event.element.name, "Swi.GUI.") then GUI.switchMFGUIInteraction(event, player, MFPlayer); GUI.updateAllGUIs(true); return end
    if string.match(event.element.name, "TP.GUI.") then GUI.TPMFGUIInteraction(event, MFPlayer, currentMF); GUI.updateAllGUIs(true); return end
    if string.match(event.element.name, "DP.GUI.") then GUI.MFDPGUIInteraction(event, MFPlayer, currentMF); GUI.updateAllGUIs(true); return end
    if string.match(event.element.name, "Rec.GUI.") then GUI.recipeGUIInteraction(event, MFPlayer); GUI.updateAllGUIs(true); return end
    if string.match(event.element.name, "M.F.") then MF.interaction(event, player, MFPlayer); GUI.updateAllGUIs(true); return end
    if string.match(event.element.name, "N.A.P.") then NAP.interaction(event); GUI.updateAllGUIs(true); return end
    if string.match(event.element.name, "M.I.") then MI.interaction(event, player); GUI.updateAllGUIs(true); return end
    if string.match(event.element.name, "D.A.") then DA.interaction(event, MFPlayer); GUI.updateAllGUIs(true); return end
    if string.match(event.element.name, "N.E.") then NE.interaction(event, playerIndex); GUI.updateAllGUIs(true); return end
    if string.match(event.element.name, "R.C.L.") then RCL.interaction(event, MFPlayer); GUI.updateAllGUIs(true); return end
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
    if string.match(event.element.name, "Inf.GUI.") then GUI.infoGUIInteraction(event, player, MFPlayer); GUI.updateAllGUIs(true); if MFPlayer.GUI[_mfGUIName.InfoGUI] then MFPlayer.GUI[_mfGUIName.InfoGUI].vars.freezeTankGUI=false; MFPlayer.GUI[_mfGUIName.InfoGUI].vars.freezeStorageGUI=false end; return end
    if string.match(event.element.name, "Rec.GUI.") then GUI.recipeGUIInteraction(event, player); GUI.updateAllGUIs(true); return end
    if string.match(event.element.name, "M.F.") then MF.interaction(event); GUI.updateAllGUIs(true); return end
    if string.match(event.element.name, "D.N.") then DN.interaction(event, MFPlayer); GUI.updateAllGUIs(true); return end
    if string.match(event.element.name, "D.S.R.") then DSR.interaction(event); GUI.updateAllGUIs(true); return end
    if string.match(event.element.name, "D.T.") then DTK.interaction(event); GUI.updateAllGUIs(true); return end
    if string.match(event.element.name, "M.I.") then MI.interaction(event, player); GUI.updateAllGUIs(true); return end
    if string.match(event.element.name, "F.I.") then FI.interaction(event); GUI.updateAllGUIs(true); return end
    if string.match(event.element.name, "R.C.L.") then RCL.interaction(event, MFPlayer); GUI.updateAllGUIs(true); return end
end

function GUI.onStringTranslated(event)
    local MFPlayer = getMFPlayer(event.player_index)
    if MFPlayer == nil then return end
    local GUITable = MFPlayer.GUI[_mfGUIName.RecipeGUI] or MFPlayer.GUI[_mfGUIName.TooltipGUI]
    if GUITable == nil or GUITable.gui == nil or GUITable.gui.valid == false then return end
    if event.localised_string == nil or event.localised_string[1] == nil then return end
    GUITable.vars.tmpLocal = GUITable.vars.tmpLocal or {}
    GUITable.vars.tmpLocal[event.localised_string[1]] = event.result
end

local _mfInteriorOldMainUpdate = GUI.updateMFMainGUI
function GUI.updateMFMainGUI(GUITable)
    _mfInteriorOldMainUpdate(GUITable)
    if GUITable == nil or GUITable.vars == nil or GUITable.vars.ButtonsTable == nil or not GUITable.vars.ButtonsTable.valid then return end
    if GUITable.vars.ButtonsTable.MFEnterInsideButton == nil then
        local buttonsSize = 14 + (GUITable.MFPlayer.varTable.MainButtonsSize or 5)
        GAPI.addButton(GUITable, "MFEnterInsideButton", GUITable.vars.ButtonsTable, "MFTPIcon", "MFTPIcon", {"gui-description.enterInsideButton"}, buttonsSize, false, true, nil, "frame_action_button")
    end
end
