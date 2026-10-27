-- NETWORK ACCESS POINT OBJECT --
-- Create the Network Access Point base object --
NAP = {
    ent = nil,
    player = "",
    MF = nil,
    entID = 0,
    dataNetwork = nil,
    networkAccessPoint = nil,
    consumption = _mfNAPQuatronDrainPerUpdate,
    totalConsumption = 0,
    showArea = false,
    areaRender = nil,
    anim = nil,
    noQuatronSprite = nil,
    objTable = nil,
    updateTick = 60,
    lastUpdate = 0,
    energyCharge = 0,
    energyLevel = 1,
    energyBuffer = _mfNAPQuatronCapacity
}

-- Constructor --
function NAP:new(object)
    if object == nil then
        return
    end
    local t = {}
    local mt = {}
    setmetatable(t, mt)
    mt.__index = NAP
    t.ent = object
    if object.last_user == nil then
        return
    end
    t.player = object.last_user.name
    t.MF = getMF(t.player)
    t.entID = object.unit_number
    t.dataNetwork = t.MF.dataNetwork
    t.dataNetwork.networkAccessPointTable[object.unit_number] = t
    t.networkAccessPoint = t
    t.objTable = {}
    t.anim = rendering.draw_animation {
        animation = "NetworkAccessPointA",
        target = {object.position.x, object.position.y - 0.9},
        surface = object.surface,
        render_layer = 131
    }
    UpSys.addObj(t)
    return t
end

-- Reconstructor --
function NAP:rebuild(object)
    if object == nil then
        return
    end
    local mt = {}
    mt.__index = NAP
    setmetatable(object, mt)
end

-- Destructor --
function NAP:remove()
    -- Destroy the Animation and the Area --
    if self.anim ~= nil and self.anim.valid then
        self.anim.destroy()
    end
    if self.areaRender ~= nil and self.areaRender.valid then
        self.areaRender.destroy()
    end
    if self.noQuatronSprite ~= nil and self.noQuatronSprite.valid then
        self.noQuatronSprite.destroy()
    end
    -- Remove from the Update System --
    UpSys.removeObj(self)
    -- Remove from the Data Network --
    self.dataNetwork.networkAccessPointTable[self.ent.unit_number] = nil
end

-- Is valid --
function NAP:valid()
    if self.ent ~= nil and self.ent.valid then
        return true
    end
    return false
end

-- Update --
function NAP:update()

    -- Set the lastUpdate variable --
    self.lastUpdate = game.tick

    -- Check the Validity --
    if valid(self) == false then
        self:remove()
        return
    end

    -- Render the powered or unpowered state --
    if EI.energy(self) <= 0 then
        if self.noQuatronSprite == nil or self.noQuatronSprite.valid == false then
            self.noQuatronSprite = rendering.draw_sprite {
                sprite = "QuatronIconDisabled",
                render_layer = 131,
                target = self.ent,
                surface = self.ent.surface,
                x_scale = 0.25,
                y_scale = 0.25
            }
        end
        if self.anim ~= nil and self.anim.valid then
            self.anim.destroy()
        end
        self.anim = nil
    else
        if self.anim == nil or self.anim.valid == false then
            self.anim = rendering.draw_animation {
                animation = "NetworkAccessPointA",
                target = {self.ent.position.x, self.ent.position.y - 0.9},
                surface = self.ent.surface,
                render_layer = 131
            }
        end
        if self.noQuatronSprite ~= nil and self.noQuatronSprite.valid then
            self.noQuatronSprite.destroy()
        end
        self.noQuatronSprite = nil
    end

    -- Render the Area --
    if self.showArea == true then
        if self.areaRender == nil or self.areaRender.valid == false then
            self.areaRender = rendering.draw_rectangle {
                color = _mfGreen,
                width = 5,
                filled = false,
                left_top = {self.ent.position.x - _mfNAPAreaSize, self.ent.position.y - _mfNAPAreaSize},
                right_bottom = {self.ent.position.x + _mfNAPAreaSize, self.ent.position.y + _mfNAPAreaSize},
                surface = self.ent.surface
            }
        end
    elseif self.showArea == false then
        if self.areaRender ~= nil and self.areaRender.valid then
            self.areaRender.destroy()
        end
        self.areaRender = nil
    end

    -- Create the Signals --
    self:createDNSignals()

    -- Calculate the total Consumption --
    self:updateTotalConsumption()

    -- Remove the Quatron --
    self:removeConsumption()
end

-- Tooltip Infos --
function NAP:getTooltipInfos(GUITable, mainFrame, justCreated)

    -- Create the Data Network Frame --
    DN.addDataNetworkFrame(GUITable, mainFrame, self, justCreated)

    if justCreated == true then

        -- Set the GUI Title --
        GUITable.vars.GUITitle.caption = {"gui-description.NetworkAccessPoint"}

        -- Set the Main Frame Height --
        mainFrame.style.height = 450

        -- Create the Information Frame --
        local infoFrame = GAPI.addFrame(GUITable, "", mainFrame, "vertical")
        infoFrame.style = "MFFrame1"
        infoFrame.style.vertically_stretchable = true
        infoFrame.style.minimal_width = 200
        infoFrame.style.left_margin = 3
        infoFrame.style.left_padding = 3
        infoFrame.style.right_padding = 3

        -- Create the Tite --
        GAPI.addSubtitle(GUITable, "", infoFrame, {"gui-description.Information"})

        -- Create the Show Area Label --
        GAPI.addLabel(GUITable, "", infoFrame, {"gui-description.ShowNAPArea"}, nil, nil, false, nil,
            _mfLabelType.yellowTitle)
        GAPI.addSwitch(GUITable, "N.A.P.AreaSwitch,", infoFrame, {"gui-description.Off"}, {"gui-description.On"}, "",
            "", self.showArea == true and "right", false, {
                ID = self.ent.unit_number
            })

        -- Create the Information Flow --
        GAPI.addFlow(GUITable, "InformationFlow", infoFrame, "vertical", true)

        -- Create the Connected Structures Frame --
        local conStructuresFrame = GAPI.addFrame(GUITable, "", mainFrame, "vertical")
        conStructuresFrame.style = "MFFrame1"
        conStructuresFrame.style.vertically_stretchable = true
        conStructuresFrame.style.minimal_width = 200
        conStructuresFrame.style.left_margin = 3
        conStructuresFrame.style.left_padding = 3
        conStructuresFrame.style.right_padding = 3

        -- Create the Tite --
        GAPI.addSubtitle(GUITable, "", conStructuresFrame, {"gui-description.NAPConnectedStructures"})

        -- Create the Scroll Pane --
        local conStructuresSC = GAPI.addScrollPane(GUITable, "", conStructuresFrame, nil, false)
        conStructuresSC.style.vertically_stretchable = true
        conStructuresSC.style.bottom_margin = 3

        -- Create the Connected Structures Table --
        GAPI.addTable(GUITable, "ConnectedStructuresTable", conStructuresSC, 1, true)

    end

    -- Get the Information flow and the Connected Structures Table --
    local infoFlow = GUITable.vars.InformationFlow
    local conStructuresTable = GUITable.vars.ConnectedStructuresTable

    -- Clear the Flow and the Table --
    infoFlow.clear()
    conStructuresTable.clear()

    -- Add the Quatron Charge --
    GAPI.addLabel(GUITable, "", infoFlow, {"gui-description.QuatronCharge", Util.toRNumber(EI.energy(self))}, _mfOrange)
    GAPI.addProgressBar(GUITable, "", infoFlow, "", EI.energy(self) .. "/" .. EI.maxEnergy(self), false, _mfPurple,
        EI.energy(self) / EI.maxEnergy(self), 100)

    -- Create the Quatron Purity --
    GAPI.addLabel(GUITable, "", infoFlow, {"gui-description.Quatronlevel", string.format("%.3f", EI.energyLevel(self))},
        _mfOrange)
    GAPI.addProgressBar(GUITable, "", infoFlow, "", "", false, _mfPurple, EI.energyLevel(self) / 20, 100)

    -- Show the Connected Structures List --
    for _, obj in pairs(self.objTable) do
        -- Check the Structure --
        if valid(obj) == true then
            -- Create the Label --
            GAPI.addLabel(GUITable, "", conStructuresTable, {"", Util.getLocEntityName(obj.ent.name)}, nil, {"",
                                                                                                             {"gui-description.mfPosition"},
                                                                                                             ": ",
                                                                                                             obj.ent
                .position.x, ";", obj.ent.position.y, " - ", obj.ent.surface.name})
        end
    end

end

-- Create all Signals --
function NAP:createDNSignals()
    local behavior = self.ent.get_control_behavior()
    if behavior == nil then
        return
    end

    local itemTotals = {}
    local fluidTotals = {}

    local function addSignalTotal(totals, name, count)
        if name == nil or type(count) ~= "number" or count == 0 then
            return
        end
        totals[name] = (totals[name] or 0) + count
    end

    -- Add the Inventory Signals --
    for name, count in pairs(self.dataNetwork.invObj.inventory) do
        addSignalTotal(itemTotals, name, count)
    end

    -- Create the Deep Storages Signals --
    for _, ds in pairs(self.dataNetwork.DSRTable) do
        if ds.inventoryItem ~= nil then
            addSignalTotal(itemTotals, ds.inventoryItem, ds.inventoryCount)
        end
    end

    -- Create the Deep Tanks Signals --
    for _, dtk in pairs(self.dataNetwork.DTKTable) do
        if dtk.inventoryFluid ~= nil then
            addSignalTotal(fluidTotals, dtk.inventoryFluid, dtk.inventoryCount)
        end
    end

    local filters = {}

    local function appendFilters(signalType, totals)
        local names = {}
        for name, count in pairs(totals) do
            if count ~= 0 then
                table.insert(names, name)
            end
        end
        table.sort(names)

        for _, name in ipairs(names) do
            if #filters >= 999 then
                return
            end
            local count = math.floor(totals[name])
            count = math.max(-2147483648, math.min(count, 2147483647))
            table.insert(filters, {
                value = {
                    type = signalType,
                    name = name,
                    quality = "normal"
                },
                min = count
            })
        end
    end

    appendFilters("item", itemTotals)
    appendFilters("fluid", fluidTotals)

    -- Factorio 2.0 stores constant-combinator signals in logistic sections.
    local section = behavior.get_section(1)
    if section == nil then
        section = behavior.add_section()
    end
    if section == nil or section.is_manual == false then
        return
    end

    section.filters = filters

    -- This entity is managed entirely by Mobile Factory; discard stale extra sections.
    for sectionIndex = behavior.sections_count, 2, -1 do
        behavior.remove_section(sectionIndex)
    end
end

-- Calculate the Total Consumption --
function NAP:updateTotalConsumption()
    local totalConsumption = self.consumption
    for k, obj in pairs(self.objTable) do
        if valid(obj) == false then
            self.objTable[k] = nil
        else
            totalConsumption = totalConsumption + obj.consumption
        end
    end
    -- TODO: NAP doesn't get better with levels, so just reducing consumption for now
    self.totalConsumption = math.ceil(totalConsumption / math.pow(EI.energyLevel(self), _mfQuatronScalePower))
end

-- Remove the Quatron Consumed --
function NAP:removeConsumption()
    -- Check and Remove Quatron --
    if self.totalConsumption >= EI.energy(self) then
        self.energyCharge = 0
    else
        self.energyCharge = EI.energy(self) - self.totalConsumption
    end
end

-- Called if the Player interacted with the GUI --
function NAP.interaction(event)

    -- Show the Area --
    if string.match(event.element.name, "N.A.P.AreaSwitch") then
        -- Get the Object --
        local objID = event.element.tags.ID
        local obj = storage.networkAccessPointTable[objID]
        if valid(obj) == false then
            return
        end
        if event.element.switch_state == "left" then
            obj.showArea = false
        else
            obj.showArea = true
        end
        return
    end

end
