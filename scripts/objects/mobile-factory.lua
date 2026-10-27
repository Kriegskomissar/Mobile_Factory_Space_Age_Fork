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
    slots = nil, -- [slotID]{entity, way}
    deployedEnts = nil, -- [slotID]{inEntity, outEntity, way}
    -- syncAreaID = 0,
    -- syncAreaInsideID = 0,
    -- syncAreaEnabled = true,
    -- syncAreaScanned = false,
    clonedResourcesTable = nil, -- {original, cloned}
    varTable = nil
}

-- Constructor --
function MF:new(args)
    local t = {}
    local player = nil
    if args then
        if args.refreshObj then
            t = args.refreshObj
        end
        if args.player then
            player = args.player
        end
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
    if not args or not args.refreshObj then
        UpSys.addObj(t)
    end

    return t
end

function MF:refresh()
    MF:new({
        refreshObj = self
    })
end

-- Constructor for a placed Mobile Factory --
function MF:construct(object)
    if object == nil then
        return
    end
    self.ent = object
    if self.fS == nil or self.fS.valid == false then
        self.fS = nil
        createMFSurface(self)
    end
    if self.ccS == nil or self.ccS.valid == false then
        self.ccS = nil
        createControlRoom(self)
    end
    storage.entsTable[object.unit_number] = self
    self.lastSurface = object.surface
    self.lastPosX = object.position.x
    self.lastPosY = object.position.y
end

-- Reconstructor --
function MF:rebuild(object)
    if object == nil then
        return
    end
    local mt = {}
    mt.__index = MF
    setmetatable(object, mt)
    JD:rebuild(object.jumpDriveObj)
    INV:rebuild(object.II)
end

-- Destructor --
function MF:remove()
    self:repack()
    self.ent = nil
    -- self:removeSyncArea()
end

-- Is valid --
function MF:valid()
    return true
end

-- Tooltip Infos --
function MF:getTooltipInfos(GUITable, mainFrame, justCreated)

    if justCreated == true then

        -- Set the GUI Title --
        GUITable.vars.GUITitle.caption = {"gui-description.MobileFactory"}

        -- Set the Main Frame Height --
        -- mainFrame.style.height = 200

        -- Create the Inventory Frame --
        local inventoryFrame = GAPI.addFrame(GUITable, "InventoryFrame", mainFrame, "vertical", true)
        inventoryFrame.style = "MFFrame1"
        inventoryFrame.style.vertically_stretchable = true
        inventoryFrame.style.left_padding = 3
        inventoryFrame.style.right_padding = 3
        inventoryFrame.style.left_margin = 3
        inventoryFrame.style.right_margin = 3

        -- Add the Title --
        GAPI.addSubtitle(GUITable, "", inventoryFrame, {"gui-description.Inventory"})

        -- Create the Inventory Flow and Button --
        local inventoryFlow = GAPI.addFlow(GUITable, "", inventoryFrame, "horizontal")
        inventoryFlow.style.horizontal_align = "center"
        GAPI.addSimpleButton(GUITable, "M.F.OpenInvButton", inventoryFlow, {"gui-description.OpenInventory"}, "", false,
            {
                ID = self.player
            })
end


-- Update the Mobile Factory --
function MF:update(event)

    if self.fS ~= nil and self.fS.valid == false then
        self.fS = nil
    end
    if self.ccS ~= nil and self.ccS.valid == false then
        self.ccS = nil
    end

    -- Set the lastUpdate variable --
    self.lastUpdate = game.tick

    -- Get the current tick --
    local tick = event.tick

    -- Get the Player --
    local player = getPlayer(self.playerIndex)

    -- Update the Internal Inventory capacity --
    if tick % _eventTick80 == 0 then
        if mfCall(self.II.rescan, self.II) then
            player.print({"gui-description.UpdateMF_IIRescanFailed", self.name})
        end
    end
    -- Check if the Mobile Factory has to TP --
    if self.onTP and game.tick - self.tpCurrentTick > 30 then
        self:TPMobileFactoryPart2()
    end
    -- Check the Mobile Factory --
    if self.ent == nil or self.ent.valid == false then
        return
    end

    -- Check if the Deployment should be removed (If the Mobile Factory is moving)
    if (self.ent.speed ~= 0 or self.ent.orientation ~= 0) and self.deployed == true then
        if mfCall(MF.repack, self) == true then
            player.print({"gui-description.UpdateMF_MFRepackFailed", self.name})
        end
    end

    -- Update Teleportation Box --
    if event.tick % _eventTick5 == 0 then
        if mfCall(MF.factoryTeleportBox, self) == true then
            player.print({"gui-description.UpdateMF_UpdateTPFailed", self.name})
        end
    end
    -- Update the Sync Area --
    -- if tick%_eventTick30 == 0 then self:updateSyncArea() end
end


    





-- Update teleportation box --
function MF:factoryTeleportBox()
    -- Mobile Factory Vehicule --
    if self.tpEnabled == true then
        local mfB = self.ent.bounding_box
        local entities = self.ent.surface.find_entities_filtered {
            area = {{mfB.left_top.x - 0.5, mfB.left_top.y - 0.5}, {mfB.right_bottom.x + 0.5, mfB.right_bottom.y + 0.5}},
            type = "character"
        }
        for _, entity in pairs(entities) do
            teleportPlayerInside(entity.player, self)
        end
    end
    -- Factory to Outside --
    if self.fS ~= nil then
        local entities = self.fS.find_entities_filtered {
            area = {{-1, -1}, {1, 1}},
            type = "character"
        }
        for k, entity in pairs(entities) do
            teleportPlayerOutside(entity.player, self)
        end
    end
    -- Factory to Control Center --
    if Util.technologyUnlocked("ControlCenter", getForce(self.player)) ~= false and self.fS ~= nil then
        local entities = self.fS.find_entities_filtered {
            area = {{-3, -34}, {3, -32}},
            type = "character"
        }
        for k, entity in pairs(entities) do
            teleportPlayerToControlCenter(entity.player, self)
        end
    end
    -- Control Center to Factory --
    if Util.technologyUnlocked("ControlCenter", getForce(self.player)) ~= false and self.ccS ~= nil and self.fS ~= nil then
        local entities = self.ccS.find_entities_filtered {
            area = {{-3, 5}, {3, 8}},
            type = "character"
        }
        for k, entity in pairs(entities) do
            teleportPlayerToFactory(entity.player, self)
        end
    end
end

-- Scan modules inside the Equipment Grid --
function MF:scanModules()
    -- Check if the Technology is unlocked --
    if Util.technologyUnlocked("EnergyPowerModule", getForce(self.player)) == nil then
        return
end

-- Call the mobile Factory to the player (Before TP) --
function MF:TPMobileFactoryPart1(location)
    -- Get the Player --
    local player = getPlayer(self.playerIndex)
    -- Check if the Surface Exist --
    if location.surface == nil or game.surfaces[location.surface.name] == nil then
        player.print({"", {"gui-description.TPSurfaceNoFound"}})
        return
    end
    -- Check if the Mobile Factory exist --
    if self.ent == nil or self.ent.valid == false then
        player.print({"", {"gui-description.MFLostOrDestroyed"}})
        return
    end
    -- Check if the Mobile Factory has a Driver --
    if self.ent.get_driver() == nil then
        player.print({"", {"gui-description.TPNoDriver"}})
        return
    end
    -- Try to find the best coords --
    local tpCoords = location.surface.find_non_colliding_position(self.MF.ent.name, {location.posX, location.posY}, 10,
        0.1, false)
    -- Return if no coords was found --
    if tpCoords == nil then
        player.print({"", {"gui-description.TPObstruction"}})
        return
    end
    -- Set the Non-colliding Destination --
    location.posX = tpCoords.x
    location.posY = tpCoords.y
    -- Start the TP --
    self.onTP = true
    self.tpCurrentTick = game.tick
    self.tpLocation = location
    -- Start all Animations --
    local animation1 = rendering.draw_animation {
        animation = "SimpleTPAn",
        animation_speed = 0.5,
        render_layer = 131,
        x_scale = 4,
        y_scale = 3.5,
        target = {self.ent.position.x, self.ent.position.y - 0.7},
        surface = self.ent.surface,
        time_to_live = 150 * 2
    }
    Util.resetAnimation(animation1, 150)
    local animation2 = rendering.draw_animation {
        animation = "SimpleTPAn",
        animation_speed = 0.5,
        render_layer = 131,
        x_scale = 4,
        y_scale = 3.5,
        target = {location.posX, location.posY - 0.7},
        surface = location.surface,
        time_to_live = 150 * 2
    }
    Util.resetAnimation(animation2, 150)
    -- Play all Sounds --
    self.ent.surface.play_sound {
        path = "MFSimpleTP",
        position = self.ent.position
    }
    self.ent.surface.play_sound {
        path = "MFSimpleTP",
        position = player.position
    }
    -- Close the TPGUI --
    local MFPlayer = getMFPlayer(self.playerIndex)
    if MFPlayer.GUI[_mfGUIName.TPGUI] ~= nil then
        MFPlayer.GUI[_mfGUIName.TPGUI].gui.destroy()
        MFPlayer.GUI[_mfGUIName.TPGUI] = nil
    end
end

-- Call the mobile Factory to the player (After TP) --
function MF:TPMobileFactoryPart2()
    -- Get the Player --
    local player = getPlayer(self.playerIndex)
    -- Check if the Surface Exist --
    if self.tpLocation.surface == nil or game.surfaces[self.tpLocation.surface.name] == nil then
        player.print({"", {"gui-description.TPSurfaceNoFound"}})
        -- Stop the TP --
        self.onTP = false
        self.tpCurrentTick = 0
        self.tpLocation = nil
        return
    end
    -- Check if the Mobile Factory exist --
    if self.ent == nil or self.ent.valid == false then
        player.print({"", {"gui-description.MFLostOrDestroyed"}})
        -- Stop the TP --
        self.onTP = false
        self.tpCurrentTick = 0
        self.tpLocation = nil
        return
    end
    -- Check if the Mobile Factory has a Driver --
    if self.ent.get_driver() == nil then
        player.print({"", {"gui-description.TPNoDriver"}})
        -- Stop the TP --
        self.onTP = false
        self.tpCurrentTick = 0
        self.tpLocation = nil
        return
    end
    -- Get the distance --
    local distance = Util.distance({self.tpLocation.posX, self.tpLocation.posY}, self.ent.position)
    -- Remove the Jump Drive Charge --
    EI.removeEnergy(self.jumpDriveObj, distance)
            
    -- Teleport the Mobile Factory to the cords --
    self.ent.teleport({self.tpLocation.posX, self.tpLocation.posY}, self.tpLocation.surface)
    -- Save the position --
    self.lastSurface = self.ent.surface
    self.lastPosX = self.ent.position.x
    self.lastPosY = self.ent.position.y
    -- Stop the TP --
    self.onTP = false
    self.tpCurrentTick = 0
    self.tpLocation = nil
end

-- Remove the Sync Area --
-- function MF:removeSyncArea()
-- 	if self.syncAreaScanned == false then return end
-- 	rendering.destroy(self.syncAreaID)
-- 	rendering.destroy(self.syncAreaInsideID)
-- 	self.syncAreaID = 0
-- 	self.syncAreaInsideID = 0
-- 	self.syncAreaScanned = false
-- 	self:unCloneSyncArea()
-- end

-- Update the Sync Area --
-- function MF:updateSyncArea()
-- 	local radius = 2 * _mfSyncAreaRadius
-- 	local nearbyMFs = self.ent.surface.count_entities_filtered{position = self.ent.position, radius = radius, name = _mfMobileFactories, limit = 2}

-- 	-- Check if the Mobile Factory is moving or the Sync Area is disabled --
-- 	if self.syncAreaEnabled == false or self.ent.speed ~= 0 then
-- 		self:removeSyncArea()
-- 		return
-- 	end

-- 	if nearbyMFs > 1 then
-- 		local player = getPlayer(self.player)
-- 		if player.connected then
-- 			player.create_local_flying_text{text={"info.MF-sync-too-close"}, position = self.ent.position}
-- 		end
-- 		self:removeSyncArea()
-- 		return
-- 	end

-- 	-- Create the Circle --
-- 	if self.syncAreaID == 0 then
-- 		self.syncAreaID = rendering.draw_circle{color={108,52,131}, radius=_mfSyncAreaRadius, width=1, filled=false,target=self.ent, surface=self.ent.surface}
-- 		self.syncAreaInsideID = rendering.draw_circle{color={108,52,131}, radius=_mfSyncAreaRadius, width=1, filled=false,target=_mfSyncAreaPosition, surface=self.fS}
-- 	end

-- 	-- Scan the Area if needed --
-- 	if self.syncAreaScanned == false then
-- 		self:syncAreaScan()
-- 		self.syncAreaScanned = true
-- 		return
-- 	end

-- 	-- Update Cloned Entities and Remove Invalid Pairs --
-- 	self:updateClonedEntities()
-- end

-- Scan around the Mobile Factory for the Sync Area --
-- function MF:syncAreaScan()
-- 	self.clonedResourcesTable = {}
-- 	-- Cloning Tiles --
-- 	local radius = _mfSyncAreaRadius + 1
-- 	local bdb = {{self.ent.position.x - radius, self.ent.position.y - radius},{self.ent.position.x + radius, self.ent.position.y + radius}}
-- 	local clonedBdb = {{_mfSyncAreaPosition.x - radius, _mfSyncAreaPosition.y - radius},{_mfSyncAreaPosition.x + radius, _mfSyncAreaPosition.y + radius}}

-- 	local inside = self.fS
-- 	local outside = self.ent.surface
-- 	local obstructed = nil
-- 	local distancesInBools = {}
-- 	local distancesOutBools = {}

-- 	-- Look for Entities inside the Sync Area --
-- 	local entTableIn = inside.find_entities_filtered{area = clonedBdb}

-- --[[
-- 	-- 06-05-2020: suggestion from Klonan, with idea/contributions from Optera
-- 	-- this is complicated. I don't need entities for obstruction detection, but I need them for cloning
-- 	tiles = outside.find_tiles_filtered{position = sync-area, radius = sync-area-radius}
-- 	inside.count_entities_filtered{area = {{tile.position.x, tile.position.y}, {tile.position.x + 1, tile.position.y + 1}}, collision_mask = tile.prototype.collision_mask, limit = 1}
-- --]]
-- 	-- Check if Entities inside Can't be Placed Outside --
-- 	for k, ent in pairs(entTableIn) do
-- 		if not _mfSyncAreaIgnoredTypes[ent.type] then
-- 			local posX = math.floor(self.ent.position.x) + (ent.position.x - _mfSyncAreaPosition.x)
-- 			local posY = math.floor(self.ent.position.y) + (ent.position.y - _mfSyncAreaPosition.y)

-- 			distancesInBools[k] = Util.distance(ent.position, _mfSyncAreaPosition) < _mfSyncAreaRadius

-- 			-- if we can place it, including marking obstructions for deconstruction... would overlap entities if we have friendly chests etc on the other side
-- 			local arg = {
-- 				name = ent.name,
-- 				position = {posX, posY},
-- 				direction = ent.direction,
-- 				force = ent.force,
-- 				build_check_type = defines.build_check_type.ghost_place,
-- 				forced = true
-- 			}
-- 			-- Will create_entity Fail Without More Details? --
-- 			if _mfSyncAreaExtraDetails[ent.type] then
-- 				for argKey, entKey in pairs(_mfSyncAreaExtraDetails[ent.type]) do
-- 					-- LuaItemStack vs SimpleItemStack (dictionary) --
-- 					if entKey == "stack" then
-- 						--unsure if stack could ever be invalid, but reading would cause an error
-- 						if ent.stack.valid_for_read then
-- 							arg[argKey] = {name = ent.stack.name, count = ent.stack.count}
-- 						else
-- 							--this is such a hackjob
-- 							arg = nil
-- 							break
-- 						end
-- 					else
-- 						arg[argKey] = ent[entKey]
-- 					end
-- 				end
-- 			end
--  			if arg and outside.can_place_entity(arg) == false then
-- 				obstructed = ent.localised_name or {"", ent.name}
-- 				break
-- 			end
-- 		end
-- 	end
-- 	if obstructed then
-- 		local player = nil
-- 		if self.player ~= "" then
-- 			player = getPlayer(self.player)
-- 			if player.connected then
-- 				player.create_local_flying_text{text={"", {"info.MF-sync-collision-in-out"}, ": ", obstructed}, position = self.ent.position}
-- 			end
-- 		end
-- 		return
-- 	end

-- 	-- Look for Entities around the Mobile Factory --
-- 	local entTableOut = outside.find_entities_filtered{area = bdb}

-- 	-- Check if Entities inside Can't be Placed Iutside --
-- 	for k, ent in pairs(entTableOut) do
-- 		if _mfSyncAreaAllowedTypes[ent.type] == true then
-- 			local posX = (ent.position.x - math.floor(self.ent.position.x)) + _mfSyncAreaPosition.x
-- 			local posY = (ent.position.y - math.floor(self.ent.position.y)) + _mfSyncAreaPosition.y

-- 			distancesOutBools[k] = Util.distance(ent.position, {math.floor(self.ent.position.x), math.floor(self.ent.position.y)}) < _mfSyncAreaRadius
-- 			if distancesOutBools[k] and inside.entity_prototype_collides(ent.name, {posX, posY}, false) == true then
-- 				obstructed = ent.localised_name or {"", ent.name}
-- 				break
-- 			end
-- 		end
-- 	end
-- 	if obstructed then
-- 		local player = nil
-- 		if self.player ~= "" then
-- 			player = getPlayer(self.player)
-- 			if player.connected then
-- 				player.create_local_flying_text{text={"", {"info.MF-sync-collision-out-in"}, ": ", obstructed}, position = self.ent.position}
-- 			end
-- 		end
-- 		return
-- 	end

-- 	-- Clone Area to Sync Area --
-- 	-- cloning the area can destroy inside entities (invalid tile placement), thus we checked first
-- 	outside.clone_area{source_area=bdb, destination_area=clonedBdb, destination_surface=inside, clone_entities=false, clone_decoratives=false, clear_destination_entities=false}
-- 	createSyncAreaMFSurface(inside)

-- 	-- Clone Outside Entities --
-- 	for k, ent in pairs(entTableOut) do
-- 		if _mfSyncAreaAllowedTypes[ent.type] == true and distancesOutBools[k] == true and ent.name ~= "InternalEnergyCube" and ent.name ~= "InternalQuatronCube" then
-- 			self:cloneEntity(ent, "in")
-- 		end
-- 	end

-- 	-- Clone Inside Entities --
-- 	for k, ent in pairs(entTableIn) do
-- 		if _mfSyncAreaAllowedTypes[ent.type] == true and distancesInBools[k] == true then
-- 			self:cloneEntity(ent, "out")
-- 		end
-- 		if ent.type == "mining-drill" then
-- 			ent.update_connections()
-- 		end
-- 	end

-- end

-- Clone an Entity --
-- function MF:cloneEntity(ent, side) -- side: in (Clone inside), out (Clone outside)
-- 	if self.ent == nil or self.ent.valid == false then return nil end
-- 	local posX = 0
-- 	local posY = 0
-- 	local surface = nil
-- 	local clone = nil
-- 	-- Calcul the position and set the Surface --
-- 	if side == "in" then
-- 		posX = ent.position.x - math.floor(self.ent.position.x) + _mfSyncAreaPosition.x
-- 		posY = ent.position.y - math.floor(self.ent.position.y) + _mfSyncAreaPosition.y
-- 		surface = self.fS
-- 	end
-- 	if side == "out" then
-- 		posX = math.floor(self.ent.position.x) + ent.position.x - _mfSyncAreaPosition.x
-- 		posY = math.floor(self.ent.position.y) + ent.position.y - _mfSyncAreaPosition.y
-- 		surface = self.ent.surface
-- 	end
-- 	-- Clone the Entity --
-- 	clone = ent.clone{position={posX, posY}, surface=surface}
-- 	if clone ~= nil and clone.valid == true then
-- 		table.insert(self.clonedResourcesTable,  {original=ent, cloned=clone})
-- 		if ent.type == "container" or ent.type == "logistic-container" then
-- 			local cloneInv = clone.get_inventory(defines.inventory.chest)
-- 			cloneInv.clear()
-- 			if cloneInv.supports_bar() then
-- 				local origInv = ent.get_inventory(defines.inventory.chest)
-- 				origInv.set_bar(math.ceil(origInv.get_bar() / 2 + 0.5))
-- 				cloneInv.set_bar(math.ceil(cloneInv.get_bar() / 2 + 0.5))
-- 			end
-- 		end
-- 		if ent.type == "storage-tank" then
-- 			clone.clear_fluid_inside()
-- 		end
-- 		if ent.type == "accumulator" then
-- 			clone.energy = 0
-- 		end
-- 	else
-- 		clone = nil
-- 	end
-- 	return clone
-- end

-- Return Items From Chest2 to Chest1 --
-- local function uncloneChest(chest1, chest2)
-- 	local inv1 = chest1.get_inventory(defines.inventory.chest)
-- 	local inv2 = chest2.get_inventory(defines.inventory.chest)

-- 	if inv1.supports_bar() then
-- 		inv1.set_bar(inv1.get_bar() * 2 - 1)
-- 	end
-- 	for i = 1, #inv2 do
-- 		local stack = inv2[i]
-- 		if stack.valid_for_read == true then
-- 			local itemsInStack = stack.count
-- 			local itemsInserted = inv1.insert(stack)
-- 			if itemsInserted < itemsInStack then
-- 				stack.count = itemsInStack - itemsInserted
-- 				chest1.surface.spill_item_stack(chest1.position, stack, true, nil, false)
-- 			end
-- 		end
-- 	end
-- 	inv2.clear()
-- end

-- Return Fluid From Tank2 to Tank1 --
-- local function uncloneStorageTank(tank1, tank2)

-- 	-- Check the Tanks --
-- 	if tank1.fluidbox[1] == nil and tank2.fluidbox[1] == nil then return end

-- 	-- Get Tanks Fluid --
-- 	local t1FluidName = nil
-- 	local t1FluidAmount = 0
-- 	local t1FluidTemperature = nil
-- 	local t2FluidName = nil
-- 	local t2FluidAmount = 0
-- 	local t2FluidTemperature = nil
-- 	if tank1.fluidbox[1] ~= nil then
-- 		t1FluidName = tank1.fluidbox[1].name
-- 		t1FluidAmount = tank1.fluidbox[1].amount
-- 		t1FluidTemperature = tank1.fluidbox[1].temperature
-- 	end
-- 	if tank2.fluidbox[1] ~= nil then
-- 		t2FluidName = tank2.fluidbox[1].name
-- 		t2FluidAmount = tank2.fluidbox[1].amount
-- 		t2FluidTemperature = tank2.fluidbox[1].temperature
-- 	end

-- 	-- Clear Tank2 --
-- 	tank2.clear_fluid_inside()

-- 	-- Check the Fluids --
-- 	if t1FluidName ~= nil and t2FluidName ~= nil and t1FluidName ~= t2FluidName then return end
-- 	if t1FluidName == nil then t1FluidTemperature = t2FluidTemperature end
-- 	if t2FluidName == nil then t2FluidTemperature = t1FluidTemperature end

-- 	-- Calcul total Fluid --
-- 	local fluidName = t1FluidName or t2FluidName
-- 	local fluidAmount = math.floor(t1FluidAmount + t2FluidAmount)
-- 	local fluidTemperature = math.floor(t1FluidTemperature + t2FluidTemperature)/2

-- 	-- Check the Amount of Fluid --
-- 	if fluidAmount <= 0 then return end

-- 	-- Give Tank1 all Fluid --
-- 	tank1.fluidbox[1] = {name=fluidName, amount=fluidAmount, temperature=fluidTemperature}

-- end

-- Send Energy from cloned Accu2 --
-- local function uncloneEnergy(accu1, accu2)
-- 	-- Calcul the total energy --	
-- 	local totalEnergy = accu1.energy + accu2.energy
-- 	-- Set the Energy of the Accu1 --
-- 	accu1.energy = totalEnergy
-- end

-- Send Quatron from cloned Accu2 --
-- local function uncloneQuatron(accu1, accu2)
-- 	local obj1 = storage.entsTable[accu1.unit_number]
-- 	local obj2 = storage.entsTable[accu2.unit_number]
-- 	-- Calcul the total quatron --
-- 	local effectiveCharge = obj1.quatronCharge * math.pow(obj1.quatronLevel, _mfQuatronScalePower) + obj2.quatronCharge * math.pow(obj2.quatronLevel, _mfQuatronScalePower)
-- 	local totalCharge = obj1.quatronCharge + obj2.quatronCharge
-- 	local effectiveLevel = math.pow(effectiveCharge / totalCharge, 1/_mfQuatronScalePower)
-- 	-- Set the Quatron of the Accu1 --
-- 	obj1.quatronCharge = math.min(totalCharge, obj1.quatronMax)
-- 	obj1.quatronLevel = effectiveLevel
-- end

-- function MF:uncloneEntity(original, clone)
-- 	if original.type == "container" or original.type == "logistic-container" then
-- 		uncloneChest(original, clone)
-- 	elseif original.type == "storage-tank" then
-- 		uncloneStorageTank(original, clone)
-- 	elseif original.name == "QuatronCubeMK1" then
-- 		uncloneQuatron(original, clone)
-- 	elseif original.type == "accumulator" then
-- 		uncloneEnergy(original, clone)
-- 	end
-- 	clone.destroy{raise_destroy=true}
-- end

-- Unclone all Entities inside the Sync Area --
-- function MF:unCloneSyncArea()
-- 	-- Set default Tiles --
-- 	createSyncAreaMFSurface(self.fS, true)
-- 	-- Update Before Trying to Unclone --
-- 	self:updateClonedEntities()
-- 	-- Remove all cloned Entities --
-- 	for i, ents in pairs(self.clonedResourcesTable) do
-- 		self:uncloneEntity(ents.original, ents.cloned)
-- 	end
-- 	self.clonedResourcesTable = {}
-- end

-- Update Entities inside the Sync Area --
-- function MF:updateClonedEntities()
-- 	for i, ents in pairs(self.clonedResourcesTable) do
-- 		self:updateClonedEntity(ents)
-- 		if ents.original == nil or ents.original.valid == false then
-- 			-- only checking original because both are nil/invalid after updating
-- 			table.remove(self.clonedResourcesTable, i)
-- 		end
-- 	end
-- end

-- Update an Entity inside the Sync Area --
-- function MF:updateClonedEntity(ents)
-- 	-- Check the Entities --
-- 	if ents == nil then return end
-- 	if ents.original == nil or ents.original.valid == false then
-- 		if ents.cloned ~= nil and ents.cloned.valid == true then
-- 			ents.cloned.destroy({raise_destroy = true})
-- 		end
-- 		return
-- 	end
-- 	if ents.cloned == nil or ents.cloned.valid == false then
-- 		if ents.original ~= nil and ents.original.valid == true then
-- 			ents.original.destroy({raise_destroy = true})
-- 		end
-- 		return
-- 	end
-- 	if ents.original.type == "resource" then
-- 		-- If the Entity is a resource --
-- 		if ents.cloned.amount < ents.original.amount then
-- 			ents.original.amount = ents.cloned.amount
-- 		end
-- 		if ents.cloned.amount > ents.original.amount then
-- 			ents.cloned.amount = ents.original.amount
-- 		end
-- 		if ents.original.amount <= 0 then
-- 			ents.original.destroy()
-- 			ents.cloned.destroy()
-- 		end
-- 	elseif ents.original.type == "container" or ents.original.type == "logistic-container" then
-- 		-- If the Entity is a Chest --
-- 		Util.syncChest(ents.original, ents.cloned)
-- 	elseif ents.original.type == "storage-tank" then
-- 		-- If the Entity is a Storage Tank --
-- 		syncTank(ents.original, ents.cloned)
-- 	elseif ents.original.name == "QuatronCubeMK1" then
-- 		-- If the Entity is a Quatron Cube --
-- 		syncQuatron(ents.original, ents.cloned)
-- 	elseif ents.original.type == "accumulator" then
-- 		-- If the Entity is an Accumulator --
-- 		syncEnergy(ents.original, ents.cloned)
-- 	end
-- end

-- Deploy the Mobile Factory --
function MF:deploy()
    -- Check the Mobile Factory --
    if self.ent == nil or self.ent.valid == false then
        return
    end
    -- Clear the deployedEnts Table --
    self.deployedEnts = {}
    -- Read all Slots --
    for k, slot in pairs(self.slots) do
        local inEnt = nil
        local outEnt = nil
        if (string.match(slot.entity, "Pump")) then
            outEnt = self.ent.surface.create_entity {
                name = slot.entity,
                position = slotToPos(k, self.ent.position.x, self.ent.position.y),
                direction = slotToDirection(k, slot.entity),
                force = self.ent.force,
                player = self.playerIndex
            }

            local entityName = nil
            if (string.match(slot.entity, "output")) then
                entityName = slot.entity:gsub("output", "input")
            else
                entityName = slot.entity:gsub("input", "output")
            end

            inEnt = self.fS.create_entity {
                name = entityName,
                position = slotToPos(k, 0, 0),
                direction = slotToDirection(k, slot.entity),
                force = self.ent.force,
                player = self.playerIndex
            }

            outEnt.add_fluid_box_linked_connection(0, inEnt, 0)
        else
            -- Create the Entities --
            outEnt = self.ent.surface.create_entity {
                name = slot.entity,
                position = slotToPos(k, self.ent.position.x, self.ent.position.y),
                direction = slotToDirection(k, slot.entity),
                force = self.ent.force,
                player = self.playerIndex
            }
            inEnt = self.fS.create_entity {
                name = slot.entity,
                position = slotToPos(k, 0, 0),
                direction = slotToDirection(k, slot.entity),
                force = self.ent.force,
                player = self.playerIndex
            }
        end

        -- Check if the Entities was correctly deployed --
        if outEnt ~= nil and outEnt.valid == true and inEnt ~= nil and inEnt.valid == true then
            self.deployedEnts[k] = {
                inEntity = inEnt,
                outEntity = outEnt,
                way = slot.way
            }
            -- If the Entities are Belts --
            if string.match(slot.entity, "Belt") then
                if slot.way == "input" then
                    outEnt.linked_belt_type = "input"
                    inEnt.linked_belt_type = "output"
                elseif slot.way == "output" then
                    outEnt.linked_belt_type = "output"
                    inEnt.linked_belt_type = "input"
                end
                inEnt.connect_linked_belts(outEnt)
            end
            -- If the Entities are Poles --
            if string.match(slot.entity, "Pole") then
                local ocWC = outEnt.get_wire_connector(defines.wire_connector_id.pole_copper, true)
                local orWC = outEnt.get_wire_connector(defines.wire_connector_id.circuit_red, true)
                local ogWC = outEnt.get_wire_connector(defines.wire_connector_id.circuit_green, true)

                local icWC = inEnt.get_wire_connector(defines.wire_connector_id.pole_copper, true)
                local irWC = inEnt.get_wire_connector(defines.wire_connector_id.circuit_red, true)
                local igWC = inEnt.get_wire_connector(defines.wire_connector_id.circuit_green, true)

                ocWC.connect_to(icWC, false)
                orWC.connect_to(irWC, false)
                ogWC.connect_to(igWC, false)
            end
        end
    end
    self.deployed = true
end

-- Repack the Mobile Factory --
function MF:repack()
    -- Remove all Entities --
    for _, dEnt in pairs(self.deployedEnts) do
        if dEnt.inEntity ~= nil and dEnt.inEntity.valid == true then
            dEnt.inEntity.destroy()
        end
        if dEnt.outEntity ~= nil and dEnt.outEntity.valid == true then
            dEnt.outEntity.destroy()
        end
    end
    -- Clear the Table --
    self.deployedEnts = {}
    self.deployed = false
end

-- Check stored data, and remove invalid record
function MF:validate()
    -- Jump Drive location icons
    for _, loc in pairs(self.jumpDriveObj.locationTable or {}) do
        if loc.filter ~= nil and prototypes.recipe[loc.filter] == nil then
            loc.filter = nil
        end
    end
    -- Internal Inventory items
    for item, _ in pairs(self.II.inventory) do
        if prototypes.item[item] == nil then
            self.II.inventory[item] = nil
        end
    end
end

-- Called if the Player interacted with the GUI --
function MF.interaction(event, player, MFPlayer)
    -- Open Inventory --
    if string.match(event.element.name, "M.F.OpenInvButton") then
        -- Get the Object --
        local objId = event.element.tags.ID
        local ent = storage.MFTable[objId].ent
        if ent ~= nil and ent.valid == true then
            player.opened = ent
        end
        return
    end
    -- Energy Lasers --
    if string.match(event.element.name, "M.F.EnergyLasersSwitch") then
        -- Look for the Mobile Factory ID --
        local objId = event.element.tags.ID
        local MF = getMF(objId)
        -- Change the Energy Laser to Drain/Send --
        if event.element.switch_state == "left" then
            MF.selectedEnergyLaserMode = "input"
        else
            MF.selectedEnergyLaserMode = "output"
        end
        return
    end
    -- Quatron Lasers --
    if string.match(event.element.name, "M.F.QuatronLasersSwitch") then
        -- Look for the Mobile Factory ID --
        local objId = event.element.tags.ID
        local MF = getMF(objId)
        -- Change the Matter Serializer targeted Inventory --
        if event.element.switch_state == "left" then
            MF.selectedQuatronLaserMode = "input"
        else
            MF.selectedQuatronLaserMode = "output"
        end
        return
    end
    -- Fluid Lasers --
    if string.match(event.element.name, "M.F.FluidLasersSwitch") then
        -- Look for the Mobile Factory ID --
        local objId = event.element.tags.ID
        local MF = getMF(objId)
        -- Change the Mode --
        if event.element.switch_state == "left" then
            MF.selectedFluidLaserMode = "input"
        else
            MF.selectedFluidLaserMode = "output"
        end
        return
    end
    -- Fluid Lasers Target --
    if string.match(event.element.name, "M.F.FluidLasersTargetDD") then
        -- Look for the Mobile Factory ID --
        local objId = event.element.tags.ID
        local MF = getMF(objId)
        -- Change the Fluid Interactor Target --
        MF:fluidLaserTarget(tonumber(event.element.items[event.element.selected_index][4]))
        return
    end
end
