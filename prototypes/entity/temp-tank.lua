-- TEMP TANK --

-- Entity --
ttE = table.deepcopy(data.raw["storage-tank"]["storage-tank"])
ttE.type = "storage-tank"
ttE.name = "TempTank"
ttE.order = "zzz"
ttE.flags = {}
ttE.minable = {mining_time = 0.8}
ttE.max_health = 9999
ttE.fast_replaceable_group = nil
ttE.next_upgrade = nil
ttE.fluid_box =
    {
      volume = 10000,
      pipe_covers = pipecoverspictures(),
	  pipe_connections = {}
    }
data:extend{ttE}