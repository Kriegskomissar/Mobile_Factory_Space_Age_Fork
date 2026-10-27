---------------------------------------------------------- PIPE FUNCTIONS ------------------------------------------------------------
local function tintPipeCovers(pipe_covers, tint)
	--SHOULD NOT HAVE TO DO THIS - hr_version IS ONLY MISSING WHEN A MOD EDITS THE PIPE IN DATA REEEEEEEEEEEE
	--like Industrial Revolution 2 version 2.1.2
	if not pipe_covers then return end
	local directions = {
		"north",
		"east",
		"south",
		"west",
	}
	for _, direction in pairs(directions) do
		local directionLayer1 = pipe_covers[direction].layers[1]
		directionLayer1.tint = tint
		if directionLayer1.hr_version then directionLayer1.hr_version.tint = tint end
	end
end

local function tintPictures(pictures, tint)
	--SHOULD NOT HAVE TO DO THIS - hr_version IS ONLY MISSING WHEN A MOD EDITS THE PIPE IN DATA REEEEEEEEEEEE
	--like Industrial Revolution 2 version 2.1.2
	if not pictures then return end
	local directions = {
		"north",
		"east",
		"south",
		"west",
	}
	for _, direction in pairs(directions) do
		local pictureDirection = pictures[direction]
		if pictureDirection then
			local tableToTint = (pictureDirection.layers and pictureDirection.layers[1]) or pictures[direction]
			tableToTint.tint = tint
			if tableToTint.hr_version then pictureDirection.hr_version.tint = tint end
		end
	end
end

---------------------------------------------------------- DIMENSIONAL PIPE ----------------------------------------------------------

-- Pumps --
local tint1 = {1,1,0.4}
local pumpingSpeed = data.raw["pump"]["pump"].pumping_speed
local pipe2ground = data.raw["pipe-to-ground"]["pipe-to-ground"]

local pump = {
	type = "pump",
	name = "DimensionalPump",
	localised_name = {"entity-name.DimensionalPipe1"},
	icon = pipe2ground.icon,
	icon_size = pipe2ground.icon_size,
	animations = {
		north = pipe2ground.pictures.north,
		east = pipe2ground.pictures.east,
		south = pipe2ground.pictures.south,
		west = pipe2ground.pictures.west
	},
	max_health = 50,
	flags = {"not-blueprintable"},
	minable = {mining_time = 0.5},
	fluid_box = {
		volume = pumpingSpeed,
		pipe_connections = {
			{position = {0,0}, direction = defines.direction.north, flow_direction = "input", connection_type = "normal"},
			{position = {0,0}, direction = defines.direction.south, flow_direction = "output", connection_type = "linked", linked_connection_id = 0}
		},
		pipe_covers = table.deepcopy(pipe2ground.fluid_box.pipe_covers)
	},
	energy_source = {type="void"},
	pumping_speed = pumpingSpeed,
	energy_usage = "1W",
	selection_box = pipe2ground.selection_box,
	collision_box = pipe2ground.collision_box,
	collision_mask = pipe2ground.collision_mask,
	squeak_behaviour = false,
}

-- Tier 1 --
local pumpInIn1 = table.deepcopy(pump)
pumpInIn1.name = "DimensionalPump1-input"
pumpInIn1.icons = {{icon=pump.icon, tint=tint1}}
pumpInIn1.localised_name = {"entity-name.DimensionalPump1"}
tintPictures(pumpInIn1.animations, tint1)
tintPipeCovers(pumpInIn1.fluid_box.pipe_covers, tint1)

local pumpInOut1 = table.deepcopy(pumpInIn1)
pumpInOut1.name = "DimensionalPump1-output"
pumpInOut1.fluid_box.pipe_connections[1].flow_direction = "output"
pumpInOut1.fluid_box.pipe_connections[2].flow_direction = "input"

data:extend{pumpInIn1, pumpInOut1}

-- Tier 2 --
local tint2 = {1,0.4,0.4}
local pumpInIn2 = table.deepcopy(pump)
pumpInIn2.name = "DimensionalPump2-input"
pumpInIn2.icons = {{icon=pump.icon, tint=tint2}}
pumpInIn2.localised_name = {"entity-name.DimensionalPump2"}
pumpInIn2.pumping_speed = pumpingSpeed * 2
tintPictures(pumpInIn2.animations, tint2)
tintPipeCovers(pumpInIn2.fluid_box.pipe_covers, tint2)

local pumpInOut2 = table.deepcopy(pumpInIn2)
pumpInOut2.name = "DimensionalPump2-output"
pumpInOut2.fluid_box.pipe_connections[1].flow_direction = "output"
pumpInOut2.fluid_box.pipe_connections[2].flow_direction = "input"

data:extend{pumpInIn2, pumpInOut2}

local dpT2 = {}
dpT2.name = "DimensionalPipe2"
dpT2.type = "technology"
dpT2.icons = pumpInIn2.icons
dpT2.icon_size = data.raw["pipe-to-ground"]["pipe-to-ground"].icon_size
dpT2.unit = {
	count=1200,
	time=3,
	ingredients={
		{"DimensionalSample", 1}
	}
}
dpT2.prerequisites = {"MFDeploy"}
dpT2.effects =
{
	{type="nothing", effect_description={"description.DimensionalPipe2"}},
}
data:extend{dpT2}

-- Tier 3 --
local tint3 = {0.4,0.6,1}
local pumpInIn3 = table.deepcopy(pump)
pumpInIn3.name = "DimensionalPump3-input"
pumpInIn3.icons = {{icon=pump.icon, tint=tint3}}
pumpInIn3.localised_name = {"entity-name.DimensionalPump3"}
pumpInIn3.pumping_speed = pumpingSpeed * 4
tintPictures(pumpInIn3.animations, tint3)
tintPipeCovers(pumpInIn3.fluid_box.pipe_covers, tint3)

local pumpInOut3 = table.deepcopy(pumpInIn3)
pumpInOut3.name = "DimensionalPump3-output"
pumpInOut3.fluid_box.pipe_connections[1].flow_direction = "output"
pumpInOut3.fluid_box.pipe_connections[2].flow_direction = "input"

data:extend{pumpInIn3, pumpInOut3}

local dpT3 = {}
dpT3.name = "DimensionalPipe3"
dpT3.type = "technology"
dpT3.icons = pumpInIn3.icons
dpT3.icon_size = data.raw["pipe-to-ground"]["pipe-to-ground"].icon_size
dpT3.unit = {
	count=10,
	time=60,
	ingredients={
		{"DimensionalSample", 200},
        {"DimensionalCrystal", 1}
	}
}
dpT3.prerequisites = {"DimensionalPipe2"}
dpT3.effects =
{
	{type="nothing", effect_description={"description.DimensionalPipe3"}},
}
data:extend{dpT3}