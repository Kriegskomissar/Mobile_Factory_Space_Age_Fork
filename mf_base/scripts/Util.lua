Util = Util or {}

-- Advenced print --
function dprint(v)
	game.print(serpent.block(v))
end

-- Print all Keys --
function dprintKeys(t)
	dprint("--- KEYS ---")
	for k, _ in pairs(t) do
		dprint(k)
	end
	dprint("------------")
end

-- Used to do a protected Function call --
function mfCall(fName, ...)
	-- Secure call the Function --
	local result, error = pcall(fName, ...)

	-- Check if the Function was correctly executed --
	if result == false then
		log("Mobile Factory error: " .. tostring(error))
		-- Display the Error to all Player --
		for _, player in pairs(game.players) do
			GAPI.createErrorWindow(error, player)
		end
		return true
	end
end

-- Return the player object with his id --
function getPlayer(id)
	return game.players[id]
end

-- Round a Number --
function Util.round(n)
	return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)
end


-- Return a splitted table of a string --
function Util.split(str, char)
	char = "[^" .. char .."]+"
	local parts = {__index = table.insert}
	setmetatable(parts, parts)
	str:gsub(char, parts)
	setmetatable(parts, nil)
	parts.__index = nil
	return parts
end

-- Return a comprehensible time --
function Util.getRealTime(time)
	local second = time * 86400
	local minute = math.floor(second / 60) % 60
	local hour = math.floor(second/3600)
	local AMPM = hour > 12 and "AM" or "PM"
	if hour == 12 then hour = 0 elseif hour == 0 then hour = 12 end
	if hour > 12 then hour = hour - 12 end
	if hour == 0 then AMPM = "AM" end
	if minute < 10 then minute = 0 .. tostring(minute) else minute = tostring(minute) end
	if hour < 10 then hour = 0 .. tostring(hour) else hour = tostring(hour) end
	local realTime = {"", hour, "H", minute, " ", AMPM}
	return realTime
end

-- Return the localised Entity Name --
function Util.getLocEntityName(entName)
	if prototypes.entity[entName] ~= nil then
		return prototypes.entity[entName].localised_name
	end
end

-- Return the localised Item Name --
function Util.getLocItemName(itemName)
	local name = itemName
	if (type(itemName) == "table") then
		name = itemName.name
	end
	if prototypes.item[name] ~= nil then
		return prototypes.item[name].localised_name
	end
end

-- Return the localised Fluid Name --
function Util.getLocFluidName(fluidName)
	if prototypes.fluid[fluidName] ~= nil then
		return prototypes.fluid[fluidName].localised_name
	end
end

-- Return the localised Recipe Name --
function Util.getLocRecipeName(recipeName)
	if prototypes.recipe[recipeName] ~= nil then
		return prototypes.recipe[recipeName].localised_name
	end
end

-- Reset an Animation --
function Util.resetAnimation(anim, totalFrame)
	local animSpeed = anim.animation_speed
	local currentFrame = math.floor((game.tick * animSpeed) % totalFrame)
	anim.animation_offset = 0 - currentFrame
end

-- Unlock a recipe for all Players --
function Util.unlockRecipeForAll(recipeName, techCondition)
	if recipeName == nil then return end
	for k, force in pairs(game.forces) do
		if techCondition ~= nil and Util.technologyUnlocked(techCondition, force) == true then
			force.recipes[recipeName].enabled = true
		end
	end
end

-- Test if player have this technologie unlocked --
function Util.technologyUnlocked(name, force)
	if force == nil then force = game.forces["player"] end
	if force == nil then return false end
	if force.technologies[name] ~= nil and force.technologies[name].researched then return true end
	return false
end

-- Create Tiles at the given position and radius --
function Util.createTilesAtPosition(position, radius, surface, tileName, force)
	-- Check all variables --
	if position == nil or radius == nil or surface == nil then return end
	if tileName == nil then tileName = "tutorial-grid" end
	-- Ajust the radius --
	radius = radius - 1
	-- Create all tiles --
	local tilesTable = {}
	for x = 0 - radius, radius do
		for y = 0 - radius, radius do
			posX = math.floor(position.x) + x
			posY = math.floor(position.y) + y
			tilesFind = surface.find_tiles_filtered{area={{posX, posY},{posX+1, posY+1}}}
			local replace = true
			for k, tile in pairs(tilesFind) do
				-- this check can somehow destroy Equalizer and kill player. See knownbugs.txt[1]
				if tileName == "tutorial-grid" and tile.name ~= "VoidTile" then
					replace = false
				end
			end
			if force == true or replace == true then
				table.insert(tilesTable, {name=tileName, position={posX, posY}})
			end
		end
	end
	-- Set tiles --
	if table_size(tilesTable) > 0 then surface.set_tiles(tilesTable) end
end

-- Create a frame from an Item --
function Util.itemToFrame(name, count, GUIObj, gui)
	-- Create the Button --
	local button = GUIObj:addButton("", gui, "item/" .. name, "item/" .. name, {"", Util.getLocItemName(name), ": ", Util.toRNumber(count)}, 37, true, true, count)
	button.style = "MF_Fake_Button_Blue"
	button.style.padding = 0
	button.style.margin = 0
end

-- Create a frame from a Fluid --
function Util.fluidToFrame(name, count, GUITable, gui)
	-- Create the Button --
	local button = GAPI.addButton(GUITable, "", gui, "fluid/" .. name, "fluid/" .. name, {"", Util.getLocFluidName(name), ": ", Util.toRNumber(count)}, 37, true, true, count)
	button.style = "MF_Fake_Button_Purple"
	button.style.padding = 0
	button.style.margin = 0
end

-- Randomize Table --
function Util.shuffle(array)
	for i = table_size(array), 2, -1 do
		local j = math.random(i)
		array[i], array[j] = array[j], array[i]
	end
	return array
end

-- Calcule the Distance between two Positions --
function Util.distance(position1, position2)
	local x1 = position1[1] or position1.x
	local y1 = position1[2] or position1.y
	local x2 = position2[1] or position2.x
	local y2 = position2[2] or position2.y
	return ((x1 - x2) ^ 2 + (y1 - y2) ^ 2) ^ 0.5
end

-- Calcule the distance in Tiles between two Positions --
function Util.distanceByTiles(position1, position2)
	local x1 = position1[1] or position1.x
	local y1 = position1[2] or position1.y
	local x2 = position2[1] or position2.x
	local y2 = position2[2] or position2.y
	return math.max(math.abs(x1-x2), math.abs(y1-y2))
end

-- Transform big numbers to readable numbers --
function Util.toRNumber(number)
	if number == nil then return 0 end
	local rNumber = number
	local rSuffix = "";
	if number >= 1000000000 then
		rNumber = number/1000000000
		rSuffix = " G"
	elseif number >= 1000000 then
		rNumber = number/1000000
		rSuffix = " M"
	elseif number >= 1000 then
		rNumber = number/1000 
		rSuffix = " k"
	end

	return string.format("%.2f", rNumber):gsub("%.0+$", "") .. rSuffix
end

-- Copy a Table --
function Util.copyTable(t1)
	local t2 = {}
	for k, j in pairs(t1 or {}) do
		t2[k] = j
	end
	return t2
end

-- Factorio 2.1 items and recipes may belong to more than one category.
function Util.fuelMatchesBurner(fuel, burner)
	for _, category in ipairs(fuel.fuel_categories or {}) do
		if burner.fuel_categories[category] then return true end
	end
	return false
end

function Util.isRecipeBlacklisted(recipe)
	for _, category in ipairs(recipe.categories) do
		if storage.dataAssemblerBlacklist[category] then return true end
	end
	return false
end

-- One shared roll is used for all products of a craft/mining operation in 2.1.
function Util.productSucceeds(product, sharedRoll)
	local shared = product.shared_probability
	if shared and (sharedRoll < shared.min or sharedRoll >= shared.max) then return false end
	local probability = product.independent_probability or product.probability or 1
	return probability >= 1 or (probability > 0 and math.random() < probability)
end

function Util.rollProductAmount(product, sharedRoll)
	if not Util.productSucceeds(product, sharedRoll) then return 0 end
	local amount = product.amount
	if amount == nil then
		if product.type == "fluid" then
			amount = product.amount_min + math.random() * (product.amount_max - product.amount_min)
		else
			amount = math.random(product.amount_min, product.amount_max)
		end
	end
	if product.extra_count_fraction and math.random() < product.extra_count_fraction then amount = amount + 1 end
	return amount
end

-- The data network stores names and counts only. Keep stateful stacks in the source.
function Util.canSerializeStack(stack)
	if not stack.valid_for_read or stack.item_number ~= nil or stack.quality.name ~= "normal" or stack.health < 1 then return false end
	if stack.prototype.get_spoil_ticks() > 0 then return false end
	if stack.is_ammo and stack.ammo < stack.prototype.magazine_size then return false end
	if stack.is_tool and stack.durability < stack.prototype.get_durability() then return false end
	return true
end
