require("utils/functions.lua")

-- Add an Object to the Update System --
function UpSys.addObj(obj)
  if valid(obj) == false then return end
  -- Add the Object --
  UpSys.addObject(obj)
end

-- Remove an Object from the Update System --
function UpSys.removeObj(obj)
	-- Remove the Object --
	if obj.entID then
		storage.entsTable[obj.entID] = nil
	end
end

-- Update System: Scan Entities --
function UpSys.scanObjs()

  -- Clear the Entities Table --
  storage.entsTable = {}

  -- Clear the Tick Table --
  for k, _ in pairs(storage.upsysTickTable) do
    if k < game.tick then
      storage.upsysTickTable[k] = nil
    end
  end

  -- Add all Objects to --
  for _, obj in pairs(storage.objTable) do
    if obj.noUpsys ~= true then
      UpSys.addTable(storage[obj.tableName])
    end
  end

  -- Add all Internal Energy Cubes and Internal Quatron Cubes --
  for _, MF in pairs(storage.MFTable) do
    UpSys.addObject(MF.dataNetwork)
    UpSys.addObject(MF.networkController)
    UpSys.addObject(MF.internalEnergyObj)
    UpSys.addObject(MF.internalQuatronObj)
    UpSys.addObject(MF.jumpDriveObj)
  end

  -- Save the last scan tick --
  storage.upSysLastScan = game.tick
  
end

-- Update System: Add an Object to the MF Entities Table --
function UpSys.addObject(obj)
  if storage.upsysTickTable == nil then storage.upsysTickTable = {} end
  if storage.entsTable == nil then storage.entsTable = {} end
  -- Check the size of the UpSys Table --
  if table_size(storage.upsysTickTable) > 300 then
    game.print("Mobile Factory - Upsys Error: table size too hight, unable to update Entities")
	storage.upsysTickTable = {}
    return
  end
  -- Check if the Object is not null --
  if obj ~= nil and getmetatable(obj) ~= nil then
    if obj:valid() ~= true then
      -- Delete the Entity --
      obj:remove()
    else
      -- Add the Object to the Entity Table --
      if obj.ent ~= nil and obj.ent.valid == true then
        storage.entsTable[obj.ent.unit_number] = obj
      end
      -- Check if the Object has to be updated --
	  if obj.updateTick > 0 then
        -- Set Update --
        local nextUpdate = game.tick + (game.tick - obj.lastUpdate)
        if obj.lastUpdate == 0 or game.tick - obj.lastUpdate > obj.updateTick*2 then
          -- Look for the best Tick to update --
          local bestTick = 1
          for i = 1, 60 do
            if table_size(storage.upsysTickTable[game.tick+i] or {}) < table_size(storage.upsysTickTable[game.tick+bestTick] or {}) then
              bestTick = i
              if storage.upsysTickTable[game.tick+i] == nil then
                break
              end
            end
          end
          nextUpdate = game.tick + bestTick 
          if storage.upsysTickTable[nextUpdate] == nil then storage.upsysTickTable[nextUpdate] = {} end
          table.insert(storage.upsysTickTable[nextUpdate], obj)
          obj.lastUpdate = 1
        end
      end
      return true
    end
  end
return false
end

-- Update System: Add a Table to the MF Entities Table --
function UpSys.addTable(array)
  -- Create the Table if needed --
  if array == nil then array = {} end
  -- Itinerate the Table --
    for k, obj in pairs(array) do
      -- Add the Object --
      if UpSys.addObject(obj) == false then
      array[k] = nil
    end
  end
end

-- Update System: Update Entities --
function UpSys.update(event)
  -- Check all Object --
  if game.tick - storage.upSysLastScan > _mfScanTicks * 10 then
    UpSys.scanObjs()
  end
  -- if true then return end
  -- Check if there are something to update --
  if storage.upsysTickTable[game.tick] == nil then return end
  -- Create the updated Index --
  local updated = 1
  -- Update Object --
  for _, obj in pairs(storage.upsysTickTable[game.tick]) do
    -- If more objects can be updated --
	if valid(obj) == true and obj.update ~= nil then
      if updated <= storage.entsUpPerTick then
        if mfCall(obj.update, obj, event) == true then
          game.print({"gui-description.UpSysupdateEntity_Failed", obj.ent.name})
        end
        updated = updated + 1
        if storage.upsysTickTable[game.tick + obj.updateTick] == nil then
          storage.upsysTickTable[game.tick + obj.updateTick] = {}
        end
        table.insert(storage.upsysTickTable[game.tick + obj.updateTick], obj)
      -- Else if there are no more update available --
      else
        if storage.upsysTickTable[game.tick+1] == nil then
          storage.upsysTickTable[game.tick+1] = {}
        end
        table.insert(storage.upsysTickTable[game.tick+1], obj)
      end
    end
  end
  -- Delete the Table --
  storage.upsysTickTable[game.tick] = nil
end

-- Index all Erya Structures --
-- function Erya.indexEryaStructures()
--   storage.eryaIndexedTable = {}
--   local i = 0
--   for k, es in pairs(storage.eryaTable) do
--     i = i + 1
--     if valid(es) then
--       storage.eryaIndexedTable[i] = es
--     else
--       storage.eryaTable[k] = nil
--     end
--   end
-- end

-- function Erya.updateEryaStructures(event)
--   for i=0, 10 do
--     if storage.updateEryaIndex > table_size(storage.eryaIndexedTable) then
--       storage.updateEryaIndex = 1
--       Erya.indexEryaStructures()
--       return
--     end
--     local es = storage.eryaIndexedTable[storage.updateEryaIndex]
--     if valid(es) == true and es.lastUpdate + es.updateTick < event.tick then
--       es:update()
--     end
--     storage.updateEryaIndex = storage.updateEryaIndex + 1
--   end
-- end