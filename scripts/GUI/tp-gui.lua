-- Create the Jump Drive GUI ---------------------------------------------------
function GUI.createTPGui(player)
    local MFPlayer = getMFPlayer(player.name)
    local GUITable = GAPI.createBaseWindows(_mfGUIName.TPGUI, {"gui-description.MFTPGUITitle"}, MFPlayer, true, true, false, "vertical", "horizontal")
    local mainFrame = GUITable.vars.MainFrame

    GAPI.addCloseButton(GUITable)

    local infoFrame = GAPI.addFrame(GUITable, "InfoFrame", mainFrame, "vertical", true)
    local markerFrame = GAPI.addFrame(GUITable, "MarkerFrame", mainFrame, "vertical", true)

    infoFrame.style = "MFFrame1"
    markerFrame.style = "MFFrame1"
    infoFrame.style.left_padding = 7
    infoFrame.style.right_padding = 7
    infoFrame.style.right_margin = 3
    markerFrame.style.left_padding = 7
    markerFrame.style.right_padding = 7
    markerFrame.style.right_margin = 3
    infoFrame.style.vertically_stretchable = true
    markerFrame.style.vertically_stretchable = true

    GAPI.addSubtitle(GUITable, "", markerFrame, {"gui-description.JumpMarkers"})

    local topFlow = GAPI.addFlow(GUITable, "MarkerTopFlow", markerFrame, "horizontal")
    topFlow.style.bottom_margin = 5
    GAPI.addButton(GUITable, "TP.GUI.OpenMap", topFlow, "utility/map", "utility/map", {"gui-description.JDOpenMap"}, 32, false, true)
    GAPI.addLabel(GUITable, "", topFlow, {"gui-description.JDMapHint"}, _mfWhite)

    local markerPane = GAPI.addScrollPane(GUITable, "MarkerScrollPane", markerFrame, 700, true, "MF_TPGUI_scroll_pan")
    markerPane.style.minimal_height = 350
    markerPane.style.minimal_width = 420
    markerPane.style.bottom_margin = 3

    GUI.updateMFTPGUI(GUITable, true)
    return GUITable
end

function GUI.updateMFTPGUI(GUITable, justCreated)
    GUI.updateInfo(GUITable)
    GUI.updateMarkers(GUITable)
end

function GUI.updateInfo(GUITable)
    local infoFrame = GUITable.vars.InfoFrame
    local MF = getCurrentMF(GUITable.MFPlayer)
    infoFrame.clear()

    GAPI.addSubtitle(GUITable, "", infoFrame, {"gui-description.Information"})
    if MF.ent == nil or MF.ent.valid == false then
        GAPI.addLabel(GUITable, "", infoFrame, {"gui-description.MFNotFound"}, _mfRed)
        return
    end

    GAPI.addLabel(GUITable, "", infoFrame, {"gui-description.JumpDriveSubTitle"}, nil, nil, false, nil, _mfLabelType.yellowTitle)
    GAPI.addDualLabel(GUITable, infoFrame, {"", {"gui-description.JumpDriveStatue"}, ":"},
        Util.toRNumber(MF.jumpDriveObj.charge) .. " / " .. Util.toRNumber(MF.jumpDriveObj.maxCharge) ..
        " (+" .. Util.toRNumber(MF.jumpDriveObj.chargeRate) .. "/s)", _mfOrange, _mfYellow)
    GAPI.addDualLabel(GUITable, infoFrame, {"", {"gui-description.JumpChargerCount"}, ":"},
        table_size(MF.jumpDriveObj.jumpChargerTable), _mfOrange, _mfYellow)

    if MF.jumpDriveObj.drive ~= nil then
        GAPI.addDualLabel(GUITable, infoFrame, {"", {"gui-description.JumpDriveMark"}, ":"},
            MF.jumpDriveObj.drive.mark, _mfOrange, _mfYellow)
        GAPI.addDualLabel(GUITable, infoFrame, {"", {"gui-description.JumpDrivePulsePower"}, ":"},
            Util.toRNumber(MF.jumpDriveObj.drive.power) .. "W", _mfOrange, _mfYellow)
    end

    GAPI.addLabel(GUITable, "", infoFrame, {"gui-description.MobileFactorySubtitle"}, nil, nil, false, nil, _mfLabelType.yellowTitle)
    GAPI.addDualLabel(GUITable, infoFrame, {"", {"gui-description.World"}, ":"}, MF.ent.surface.name, _mfOrange, _mfYellow)
    GAPI.addDualLabel(GUITable, infoFrame, {"", {"gui-description.PosX"}, ":"}, math.floor(MF.ent.position.x), _mfOrange, _mfYellow)
    GAPI.addDualLabel(GUITable, infoFrame, {"", {"gui-description.PosY"}, ":"}, math.floor(MF.ent.position.y), _mfOrange, _mfYellow)
end

function GUI.updateMarkers(GUITable)
    local markerPane = GUITable.vars.MarkerScrollPane
    local MF = getCurrentMF(GUITable.MFPlayer)
    markerPane.clear()

    if MF.ent == nil or not MF.ent.valid then
        GAPI.addLabel(GUITable, "", markerPane, {"gui-description.MFNotFound"}, _mfRed)
        return
    end

    local markers = MF.jumpDriveObj:getMarkers()
    local markerCount = 0

    for _, tag in pairs(markers) do
        if tag ~= nil and tag.valid then
            markerCount = markerCount + 1
            local location = {surface = tag.surface, posX = tag.position.x, posY = tag.position.y}
            local canTP = MF.jumpDriveObj:canTP(location)
            local distance = math.ceil(Util.distance(MF.ent.position, {location.posX, location.posY}))
            local plan = MF.jumpDriveObj:getJumpPlan(location)

            local row = GAPI.addFrame(GUITable, "", markerPane, "horizontal")
            row.style = "MFFrame1"
            row.style.left_padding = 5
            row.style.right_padding = 5
            row.style.top_padding = 4
            row.style.bottom_padding = 4

            local iconFlow = GAPI.addFlow(GUITable, "", row, "vertical")
            iconFlow.style.vertical_align = "center"
            GAPI.addButton(GUITable, "TP.GUI.Loc,", iconFlow, "MFJDIcon", "MFJDIcon", {"gui-description.StartJump"}, 42, false, true, nil, nil, {loc = tag.tag_number})

            local info = GAPI.addTable(GUITable, "", row, 1)
            info.style.horizontally_stretchable = true
            local name = tag.text or "Jump Marker"
            if string.sub(name, 1, 7) == "[MF-JD] " then name = string.sub(name, 8) end
            GAPI.addLabel(GUITable, "", info, name, nil, "Jump Marker", false, nil, _mfLabelType.yellowTitle)
            GAPI.addLabel(GUITable, "", info,
                {"", tag.surface.name, " (", math.floor(tag.position.x), " ; ", math.floor(tag.position.y), ")"}, _mfWhite)

            if plan ~= nil then
                GAPI.addLabel(GUITable, "", info,
                    {"", {"gui-description.JumpCost"}, ": ", Util.toRNumber(plan.energy), "J  •  ", distance, "m  •  ",
                        {"gui-description.JumpPulseTime"}, ": ", string.format("%.2f", plan.duration), "s"}, _mfWhite)
            else
                GAPI.addLabel(GUITable, "", info, {"gui-description.JDUnavailable"}, _mfRed)
            end

            local buttonFlow = GAPI.addFlow(GUITable, "", row, "vertical")
            buttonFlow.style.vertical_align = "center"
            local jumpButton = GAPI.addButton(GUITable, "TP.GUI.Loc,", buttonFlow,
                canTP and "MFJDIcon" or "MFJDIcon", "MFJDIcon",
                canTP and {"gui-description.StartJump"} or {"gui-description.JDUnavailable"}, 32, false, true, nil, nil, {loc = tag.tag_number})
            jumpButton.enabled = canTP
            GAPI.addButton(GUITable, "TP.GUI.RemoveLoc,", buttonFlow, "utility/remove", "utility/remove", {"gui-description.RemoveLocation"}, 28, false, true, nil, nil, {loc = tag.tag_number})
        end
    end

    if markerCount == 0 then
        GAPI.addLabel(GUITable, "", markerPane, {"gui-description.JDNoMarkers"}, _mfWhite)
    end
end

function GUI.TPMFGUIInteraction(event, MFPlayer, currentMF)
    local jumpDrive = currentMF.jumpDriveObj

    if event.element.name == "TP.GUI.OpenMap" then
        jumpDrive:openMap()
        return
    end

    if string.match(event.element.name, "TP.GUI.Loc") then
        local tagNumber = event.element.tags.loc
        local tag = nil
        for _, marker in pairs(jumpDrive:getMarkers()) do
            if marker.tag_number == tagNumber then
                tag = marker
                break
            end
        end
        if tag == nil then return end
        if event.button == defines.mouse_button_type.left then
            jumpDrive:jump(tag.text)
        end
        return
    end

    if string.match(event.element.name, "TP.GUI.RemoveLoc") then
        local tagNumber = event.element.tags.loc
        for _, marker in pairs(jumpDrive:getMarkers()) do
            if marker.tag_number == tagNumber then
                marker.destroy()
                break
            end
        end
        GUI.updateAllGUIs(true)
        return
    end
end
