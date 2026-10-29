require("scripts/objects/internal-inventory.lua")

-- MOBILE FACTORY RUNTIME OBJECT ---------------------------------------------
-- One runtime object belongs to one placed factory entity. storage.MFTable is
-- keyed by entity unit_number, so a player can own any number of factories.
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
    tpPlan = nil,
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
        t.playerIndex = player.index
        t.player = player.name
        t.name = player.name .. "'s Mobile Factory"
    end

    t.II = t.II or INV:new("Internal Inventory")
    t.II.MF = t
    t.jumpDriveObj = t.jumpDriveObj or JD:new(t)
    t.MF = t

    if not args or not args.refreshObj then
        UpSys.addObj(t)
    end
    return t
end

function MF:refresh()
    MF:new({refreshObj = self})
end

function MF:construct(object)
    if object == nil or not object.valid then return end
    self.ent = object
    self.ccS = nil

    storage.MFTable = storage.MFTable or {}
    storage.MFTable[object.unit_number] = self
    storage.entsTable[object.unit_number] = self

    if self.fS == nil or not self.fS.valid then
        self.fS = nil
        createMFSurface(self)
    end

    self.lastSurface = object.surface
    self.lastPosX = object.position.x
    self.lastPosY = object.position.y
    self.name = (self.player ~= "" and self.player .. "'s " or "") .. object.name
    UpSys.addObj(self)
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
    if self.fS and self.fS.valid then
        MFInterior.destroy(self)
    end
    if self.ent and self.ent.unit_number then
        storage.entsTable[self.ent.unit_number] = nil
        storage.MFTable[self.ent.unit_number] = nil
    end
    local MFPlayer = self.playerIndex and getMFPlayer(self.playerIndex) or nil
    if MFPlayer and MFPlayer.currentMF == self then
        MFPlayer.currentMF = nil
    end
    self.ent = nil
end

function MF:valid()
    return self.ent ~= nil and self.ent.valid == true
end

function MF:update(event)
    if self.fS ~= nil and self.fS.valid == false then self.fS = nil end
    self.ccS = nil
    self.lastUpdate = game.tick
    local tick = event.tick
    local player = getPlayer(self.playerIndex)

    if tick % _eventTick80 == 0 and self.II and self.II.rescan then
        if mfCall(self.II.rescan, self.II) and player then
            player.print({"gui-description.UpdateMF_IIRescanFailed", self.name})
        end
    end

    if self.onTP and game.tick - self.tpCurrentTick > 30 then
        self:TPMobileFactoryPart2()
    end
    if self.ent == nil or self.ent.valid == false then return end

    if (self.ent.speed ~= 0 or self.ent.orientation ~= 0) and self.deployed == true then
        if mfCall(MF.repack, self) == true and player then
            player.print({"gui-description.UpdateMF_MFRepackFailed", self.name})
        end
    end
end

function MF:factoryTeleportBox()
    return false
end

function MF:TPMobileFactoryPart1(location)
    local player = getPlayer(self.playerIndex)
    if location.surface == nil or game.surfaces[location.surface.name] == nil then
        if player then player.print({"", {"gui-description.TPSurfaceNoFound"}}) end
        return
    end
    if self.ent == nil or self.ent.valid == false then
        if player then player.print({"", {"gui-description.MFLostOrDestroyed"}}) end
        return
    end
    if self.ent.get_driver() == nil then
        if player then player.print({"", {"gui-description.TPNoDriver"}}) end
        return
    end
    local tpCoords = location.surface.find_non_colliding_position(self.ent.name, {location.posX, location.posY}, 10, 0.1, false)
    if tpCoords == nil then
        if player then player.print({"", {"gui-description.TPObstruction"}}) end
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
        self.onTP = false; self.tpCurrentTick = 0; self.tpLocation = nil
        return
    end
    if self.ent == nil or self.ent.valid == false then
        self.onTP = false; self.tpCurrentTick = 0; self.tpLocation = nil
        return
    end
    if self.ent.get_driver() == nil then
        if player then player.print({"", {"gui-description.TPNoDriver"}}) end
        self.onTP = false; self.tpCurrentTick = 0; self.tpLocation = nil
        return
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
        local inEnt, outEnt
        if string.match(slot.entity, "Pump") then
            outEnt = self.ent.surface.create_entity{
                name = slot.entity,
                position = slotToPos(k, self.ent.position.x, self.ent.position.y),
                direction = slotToDirection(k, slot.entity),
                force = self.ent.force,
                player = self.playerIndex
            }
            local entityName = string.match(slot.entity, "output") and slot.entity:gsub("output", "input") or slot.entity:gsub("input", "output")
            inEnt = self.fS.create_entity{
                name = entityName,
                position = slotToPos(k, 0, 0),
                direction = slotToDirection(k, slot.entity),
                force = self.ent.force,
                player = self.playerIndex
            }
            if outEnt and inEnt then outEnt.add_fluid_box_linked_connection(0, inEnt, 0) end
        else
            outEnt = self.ent.surface.create_entity{
                name = slot.entity,
                position = slotToPos(k, self.ent.position.x, self.ent.position.y),
                direction = slotToDirection(k, slot.entity),
                force = self.ent.force,
                player = self.playerIndex
            }
            inEnt = self.fS.create_entity{
                name = slot.entity,
                position = slotToPos(k, 0, 0),
                direction = slotToDirection(k, slot.entity),
                force = self.ent.force,
                player = self.playerIndex
            }
        end
        if outEnt and outEnt.valid and inEnt and inEnt.valid then
            self.deployedEnts[k] = {inEntity = inEnt, outEntity = outEnt, way = slot.way}
            if string.match(slot.entity, "Belt") then
                if slot.way == "input" then
                    outEnt.linked_belt_type = "input"; inEnt.linked_belt_type = "output"
                elseif slot.way == "output" then
                    outEnt.linked_belt_type = "output"; inEnt.linked_belt_type = "input"
                end
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
    for _, dEnt in pairs(self.deployedEnts or {}) do
        if dEnt.inEntity and dEnt.inEntity.valid then dEnt.inEntity.destroy() end
        if dEnt.outEntity and dEnt.outEntity.valid then dEnt.outEntity.destroy() end
    end
    self.deployedEnts = {}
    self.deployed = false
end

function MF:validate()
    if self.II and self.II.inventory then
        for item, _ in pairs(self.II.inventory) do
            if prototypes.item[item] == nil then self.II.inventory[item] = nil end
        end
    end
end
