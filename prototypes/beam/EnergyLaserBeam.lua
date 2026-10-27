----------------- ENERGY LASER BEAM -----------------
-- General Iddle Beam --
local iddleBeam = {}
iddleBeam.type = "beam"
iddleBeam.name = "IddleBeam"
iddleBeam.flags = {"not-on-map"}
iddleBeam.width = 1
iddleBeam.damage_interval = 20
iddleBeam.random_target_offset = true
iddleBeam.action_triggered_automatically = false
iddleBeam.action = nil
iddleBeam.graphics_set = {
    beam = {
        head = {
            layers = {{
                filename = "__Mobile_Factory_Space_Age__/graphics/beams/IddleBeam.png",
                flags = beam_non_light_flags,
                line_length = 2,
                width = 30,
                height = 30,
                frame_count = 2,
                scale = 1.0,
                animation_speed = 0.025,
                blend_mode = laser_beam_blend_mode
            }, {
                filename = "__Mobile_Factory_Space_Age__/graphics/beams/IddleBeamLight.png",
                draw_as_light = true,
                line_length = 2,
                width = 30,
                height = 30,
                scale = 1.0,
                animation_speed = 0.025,
                frame_count = 2
            }}
        }
    }
}
iddleBeam.graphics_set.beam.tail = iddleBeam.graphics_set.beam.head
iddleBeam.graphics_set.beam.body = iddleBeam.graphics_set.beam.head

data:extend{iddleBeam}

-- Energy Laser MK1 --

-- Connected Beam --
local mk1ConnectedBeam = {}
mk1ConnectedBeam.type = "beam"
mk1ConnectedBeam.name = "MK1ConnectedBeam"
mk1ConnectedBeam.flags = {"not-on-map"}
mk1ConnectedBeam.width = 1
mk1ConnectedBeam.damage_interval = 20
mk1ConnectedBeam.random_target_offset = true
mk1ConnectedBeam.action_triggered_automatically = false
mk1ConnectedBeam.action = nil
mk1ConnectedBeam.graphics_set = {
    beam = {
        head = {
            layers = {{
                filename = "__Mobile_Factory_Space_Age__/graphics/beams/MK1ConnectedBeam.png",
                flags = beam_non_light_flags,
                line_length = 2,
                width = 90,
                height = 90,
                frame_count = 2,
                scale = 1 / 2.7,
                animation_speed = 0.025,
                blend_mode = laser_beam_blend_mode
            }, {
                filename = "__Mobile_Factory_Space_Age__/graphics/beams/MK1ConnectedBeamLight.png",
                draw_as_light = true,
                line_length = 2,
                width = 90,
                height = 90,
                scale = 1 / 2.7,
                animation_speed = 0.025,
                frame_count = 2
            }}
        }
    }
}

mk1ConnectedBeam.graphics_set.beam.tail = mk1ConnectedBeam.graphics_set.beam.head
mk1ConnectedBeam.graphics_set.beam.body = mk1ConnectedBeam.graphics_set.beam.head

data:extend{mk1ConnectedBeam}

-- Send Beam --
local mk1SendBeam = {}
mk1SendBeam.type = "beam"
mk1SendBeam.name = "MK1SendBeam"
mk1SendBeam.flags = {"not-on-map"}
mk1SendBeam.width = 1
mk1SendBeam.damage_interval = 20
mk1SendBeam.random_target_offset = true
mk1SendBeam.action_triggered_automatically = false
mk1SendBeam.action = nil
mk1SendBeam.graphics_set = {
    beam = {
        head = {
            layers = {{
                filename = "__Mobile_Factory_Space_Age__/graphics/beams/MK1SendBeam.png",
                flags = beam_non_light_flags,
                line_length = 4,
                width = 90,
                height = 90,
                frame_count = 4,
                scale = 1 / 2.7,
                animation_speed = 0.4,
                blend_mode = laser_beam_blend_mode
            }, {
                filename = "__Mobile_Factory_Space_Age__/graphics/beams/MK1SendBeamLight.png",
                draw_as_light = true,
                line_length = 4,
                width = 90,
                height = 90,
                scale = 1 / 2.7,
                animation_speed = 0.4,
                frame_count = 4
            }}
        }
    }
}
mk1SendBeam.graphics_set.beam.tail = mk1SendBeam.graphics_set.beam.head
mk1SendBeam.graphics_set.beam.body = mk1SendBeam.graphics_set.beam.head
data:extend{mk1SendBeam}

----------------- ENERGY LASER BEAM -----------------

-- General Iddle Beam --
local iddleBeam = {}
iddleBeam.type = "beam"
iddleBeam.name = "IddleBeam"
iddleBeam.flags = {"not-on-map"}
iddleBeam.width = 1
iddleBeam.damage_interval = 20
iddleBeam.random_target_offset = true
iddleBeam.action_triggered_automatically = false
iddleBeam.action = nil
iddleBeam.graphics_set = {
    beam = {
        head = {
            layers = {{
                filename = "__Mobile_Factory_Space_Age__/graphics/beams/IddleBeam.png",
                flags = beam_non_light_flags,
                line_length = 2,
                width = 30,
                height = 30,
                frame_count = 2,
                scale = 1.0,
                animation_speed = 0.025,
                blend_mode = laser_beam_blend_mode
            }, {
                filename = "__Mobile_Factory_Space_Age__/graphics/beams/IddleBeamLight.png",
                draw_as_light = true,
                line_length = 2,
                width = 30,
                height = 30,
                scale = 1.0,
                animation_speed = 0.025,
                frame_count = 2
            }}
        }
    }
}
iddleBeam.graphics_set.beam.tail = iddleBeam.graphics_set.beam.head
iddleBeam.graphics_set.beam.body = iddleBeam.graphics_set.beam.head
data:extend{iddleBeam}

-- Quatron Laser MK1 --

-- Connected Beam --
local mk1QuatronConnectedBeam = {}
mk1QuatronConnectedBeam.type = "beam"
mk1QuatronConnectedBeam.name = "MK1QuatronConnectedBeam"
mk1QuatronConnectedBeam.flags = {"not-on-map"}
mk1QuatronConnectedBeam.width = 1
mk1QuatronConnectedBeam.damage_interval = 20
mk1QuatronConnectedBeam.random_target_offset = true
mk1QuatronConnectedBeam.action_triggered_automatically = false
mk1QuatronConnectedBeam.action = nil
mk1QuatronConnectedBeam.graphics_set = {
    beam = {
        head = {
            layers = {{
                filename = "__Mobile_Factory_Space_Age__/graphics/beams/MK1ConnectedBeam.png",
                flags = beam_non_light_flags,
                line_length = 2,
                width = 90,
                height = 90,
                frame_count = 2,
                scale = 1 / 2.7,
                animation_speed = 0.025,
                blend_mode = laser_beam_blend_mode
            }, {
                filename = "__Mobile_Factory_Space_Age__/graphics/beams/MK1ConnectedBeamLight.png",
                draw_as_light = true,
                line_length = 2,
                width = 90,
                height = 90,
                scale = 1 / 2.7,
                animation_speed = 0.025,
                frame_count = 2
            }}
        }
    }
}
mk1QuatronConnectedBeam.graphics_set.beam.tail = mk1QuatronConnectedBeam.graphics_set.beam.head
mk1QuatronConnectedBeam.graphics_set.beam.body = mk1QuatronConnectedBeam.graphics_set.beam.head
data:extend{mk1QuatronConnectedBeam}

-- Send Beam --
local mk1QuatronSendBeam = {}
mk1QuatronSendBeam.type = "beam"
mk1QuatronSendBeam.name = "MK1QuatronSendBeam"
mk1QuatronSendBeam.flags = {"not-on-map"}
mk1QuatronSendBeam.width = 1
mk1QuatronSendBeam.damage_interval = 20
mk1QuatronSendBeam.random_target_offset = true
mk1QuatronSendBeam.action_triggered_automatically = false
mk1QuatronSendBeam.action = nil
mk1QuatronSendBeam.graphics_set = {
    beam = {
        head = {
            layers = {{
                filename = "__Mobile_Factory_Space_Age__/graphics/beams/MK1SendBeam.png",
                flags = beam_non_light_flags,
                line_length = 4,
                width = 90,
                height = 90,
                frame_count = 4,
                scale = 1 / 2.7,
                animation_speed = 0.4,
                blend_mode = laser_beam_blend_mode
            }, {
                filename = "__Mobile_Factory_Space_Age__/graphics/beams/MK1SendBeamLight.png",
                draw_as_light = true,
                line_length = 4,
                width = 90,
                height = 90,
                scale = 1 / 2.7,
                animation_speed = 0.4,
                frame_count = 4
            }}
        }
    }
}
mk1QuatronSendBeam.graphics_set.beam.tail = mk1QuatronSendBeam.graphics_set.beam.head
mk1QuatronSendBeam.graphics_set.beam.body = mk1QuatronSendBeam.graphics_set.beam.head
data:extend{mk1QuatronSendBeam}
