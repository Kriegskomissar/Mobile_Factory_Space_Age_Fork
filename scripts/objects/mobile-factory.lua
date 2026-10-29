-- Create the Mobile Factory Object --
MF = {
    ent = nil,
    playerIndex = nil,
    player = "",
    name = "",
    updateTick = 1,
    lastUpdate = 0,
    lastSurface = nil,
    lastPosX = 0,
    lastPosY = 0,
    fS = nil,
    ccS = nil,
    II = nil,
    jumpDriveObj = nil,
    tpEnabled = true,
    onTP = false,
    tpCurrentTick = 0,
    tpLocation = nil,
    locked = true,
    deployed = false,
    slots = nil,
    deployedEnts = nil,
    clonedResourcesTable = nil,
    varTable = nil
}

function MF:new(args)
    local t = {}
    local player = nil
    if args then
        if args.refreshObj then t = args.refreshObj end
        if args.player then player = args.player end
    end
    local mt = {}
    setmetatable(t, mt)
    mt.__index = MF
    t.clonedResourcesTable = t.clonedResourcesTable or {}
    t.varTable = t.varTable or {}
    t.varTable.tech = t.varTable.tech or {}
    t.varTable.allowedPlayers = t.varTable.allowedPlayers or {}
    t.slots = t.slots or {}
    t.deployedEnts = t.deployedEnts or {}

    if player then
        storage.MFTable[player.name] = t
        t.playerIndex = player.index
        t.player = player.name
        t.name = player.name .. "'s Mobile Factory"
    end

    t.II = t.II or INV:new("Internal Inventory")
    t.II.MF = t
    t.jumpDriveObj = t.jumpDriveObj or JD:new(t)
    t.MF = t
    if not args or not args.refreshObj then UpSys.addObj(t) end
    return t
end

function MF:refresh()
    MF:new({refreshObj = self})
end

-- Constructor for a placed Mobile Factory. Interior surfaces are tied to the
-- placed entity's unit_number, not to the player, so several factories can
-- exist simultaneously and each keeps its own floor.
function MF:construct(object)
    if object == nil then return end
    self.ent = object
    self.ccS = nil
    if self.fS == nil or self.fS.valid == false then
        self.fS = nil
        createMFSurface(self)
    end
    storage.entsTable[object.unit_number] = self
    self.lastSurface = object.surface
    self.lastPosX = object.position.x
    self.lastPosY = object.position.y
end

function MF:rebuild(object)
    if object == nil then return end
    local mt = {}
    mt.__index = MF
    setmetatable(object, mt)
    JD:rebuild(object.jumpDriveObj)
    if object.II ~= nil and INV ~= nil and INV.rebuild then INV:rebuild(object.II) end
end

function MF:remove()
    self:repack()
    self.ent = nil
end

function MF:valid()
    return true
end

function MF:getTooltipInfos(GUITable, mainFrame, justCreated)
    if justCreated == true then
        GUITable.vars.GUITitle.caption = {"gui-description.MobileFactory"}
        local inventoryFrame = GAPI.addFrame(GUITable, "InventoryFrame", mainFrame, "vertical", true)
        inventoryFrame.style = "MFFrame1"
        inventoryFrame.style.vertically_stretchable = true
        inventoryFrame.style.left_padding = 3
        inventoryFrame.style.right_padding = 3
        inventoryFrame.style.left_margin = 3
        inventoryFrame.style.right_margin = 3
        GAPI.addSubtitle(GUITable, "", inventoryFrame, {"gui-description.Inventory"})
        local inventoryFlow = GAPI.addFlow(GUITable, "", inventoryFrame, "horizontal")
        inventoryFlow.style.horizontal_align = "center"
        GAPI.addSimpleButton(GUITable, "M.F.OpenInvButton", inventoryFlow, {"gui-description.OpenInventory"}, "", false, {ID = self.player})
    end
end

function MF:update(event)
    if self.fS ~= nil and self.fS.valid == false then self.fS = nil end
    self.ccS = nil
    self.lastUpdate = game.tick
    local tick = event.tick
    local player = getPlayer(self.playerIndex)

    if tick % _eventTick80 == 0 and self.II and self.II.rescan then
        if mfCall(self.II.rescan, self.II) then
            player.print({"gui-description.UpdateMF_IIRescanFailed", self.name})
        end
    end

    if self.onTP and game.tick - self.tpCurrentTick > 30 then self:TPMobileFactoryPart2() end
    if self.ent == nil or self.ent.valid == false then return end

    if (self.ent.speed ~= 0 or self.ent.orientation ~= 0) and self.deployed == true then
        if mfCall(MF.repack, self) == true then
            player.print({"gui-description.UpdateMF_MFRepackFailed", self.name})
        end
    end

    -- The old proximity teleport box has been removed. Entering the factory is
    -- now explicit through the outside menu or the interior terminal.
end

-- Kept as a compatibility stub for old saved runtime calls. It intentionally
-- performs no automatic teleportation.
function MF:factoryTeleportBox()
    return false
end

-- Call the mobile Factory to the player (Before TP)
function MF:TPMobileFactoryPart1(location)
    local player = getPlayer(self.playerIndex)
    if location.surface == nil or game.surfaces[location.surface.name] == nil then
        player.print({"", {"gui-description.TPSurfaceNoFound"}})
        return
    end
    if self.ent == nil or self.ent.valid == false then
        player.print({"", {"gui-description.MFLostOrDestroyed"}})
        return
    end
    if self.ent.get_driver() == nil then
        player.print({"", {"gui-description.TPNoDriver"}})
        return
    end
    local tpCoords = location.surface.find_non_colliding_position(self.ent.name, {location.posX, location.posY}, 10, 0.1, false)
    if tpCoords == nil then
        player.print({"", {"gui-description.TPObstruction"}})
        return
    end
    location.posX = tpCoords.x
    location.posY = tpCoords.y
    self.onTP = true
    self.tpCurrentTick = game.tick
    self.tpLocation = location
end

function MF:TPMobileFactoryPart2()
    local player = getPlayer(self.playerIndex)
    if self.tpLocation == nil or self.tpLocation.surface == nil or game.surfaces[self.tpLocation.surface.name] == nil then
        self.onTP = false; self.tpCurrentTick = 0; self.tpLocation = nil; return
    end
    if self.ent == nil or self.ent.valid == false then
        self.onTP = false; self.tpCurrentTick = 0; self.tpLocation = nil; return
    end
    if self.ent.get_driver() == nil then
        player.print({"", {"gui-description.TPNoDriver"}})
        self.onTP = false; self.tpCurrentTick = 0; self.tpLocation = nil; return
    end
    self.ent.teleport({self.tpLocation.posX, self.tpLocation.posY}, self.tpLocation.surface)
    self.lastSurface = self.ent.surface
    self.lastPosX = self.ent.position.x
    self.lastPosY = self.ent.position.y
    self.onTP = false
    self.tpCurrentTick = 0
    self.tpLocation = nil
end

function MF:deploy()
    if self.ent == nil or self.ent.valid == false then return end
    self.deployedEnts = {}
    for k, slot in pairs(self.slots) do
        local inEnt = nil
        local outEnt = nil
        if string.match(slot.entity, "Pump") then
            outEnt = self.ent.surface.create_entity{name = slot.entity, position = slotToPos(k, self.ent.position.x, self.ent.position.y), direction = slotToDirection(k, slot.entity), force = self.ent.force, player = self.playerIndex}
            local entityName = string.match(slot.entity, "output") and slot.entity:gsub("output", "input") or slot.entity:gsub("input", "output")
            inEnt = self.fS.create_entity{name = entityName, position = slotToPos(k, 0, 0), direction = slotToDirection(k, slot.entity), force = self.ent.force, player = self.playerIndex}
            outEnt.add_fluid_box_linked_connection(0, inEnt, 0)
        else
            outEnt = self.ent.surface.create_entity{name = slot.entity, position = slotToPos(k, self.ent.position.x, self.ent.position.y), direction = slotToDirection(k, slot.entity), force = self.ent.force, player = self.playerIndex}
            inEnt = self.fS.create_entity{name = slot.entity, position = slotToPos(k, 0, 0), direction = slotToDirection(k, slot.entity), force = self.ent.force, player = self.playerIndex}
        end
        if outEnt ~= nil and outEnt.valid == true and inEnt ~= nil and inEnt.valid == true then
            self.deployedEnts[k] = {inEntity = inEnt, outEntity = outEnt, way = slot.way}
            if string.match(slot.entity, "Belt") then
                if slot.way == "input" then outEnt.linked_belt_type = "input"; inEnt.linked_belt_type = "output" elseif slot.way == "output" then outEnt.linked_belt_type = "output"; inEnt.linked_belt_type = "input" end
                inEnt.connect_linked_belts(outEnt)
            end
            if string.match(slot.entity, "Pole") then
                local ocWC = outEnt.get_wire_connector(defines.wire_connector_id.pole_copper, true)
                local orWC = outEnt.get_wire_connector(defines.wire_connector_id.circuit_red, true)
                local ogWC = outEnt.get_wire_connector(defines.wire_connector_id.circuit_green, true)
                local icWC = inEnt.get_wire_connector(defines.wire_connector_id.pole_copper, true)
                local irWC = inEnt.get_wire_connector(defines.wire_connector_id.circuit_red, true)
                local igWC = inEnt.get_wire_connector(defines.wire_connector_id.circuit_green, true)
                if ocWC and icWC then ocWC.connect_to(icWC, false) end
                if orWC and irWC then orWC.connect_to(irWC, false) end
                if ogWC and igWC then ogWC.connect_to(igWC, false) end
            end
        end
    end
    self.deployed = true
end

function MF:repack()
    for _, dEnt in pairs(self.deployedEnts) do
        if dEnt.inEntity ~= nil and dEnt.inEntity.valid == true then dEnt.inEntity.destroy() end
        if dEnt.outEntity ~= nil and dEnt.outEntity.valid == true then dEnt.outEntity.destroy() end
    end
    self.deployedEnts = {}
    self.deployed = false
end

function MF:validate()
    for item, _ in pairs((self.II and self.II.inventory) or {}) do
        if prototypes.item[item] == nil then self.II.inventory[item] = nil end
    end
end

function MF.interaction(event, player, MFPlayer)
    if string.match(event.element.name, "M.F.OpenInvButton") then
        local objId = event.element.tags.ID
        local obj = storage.MFTable[objId]
        local ent = obj and obj.ent
        if ent ~= nil and ent.valid == true then player.opened = ent end
        return
    end
end
