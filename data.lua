-- Core prototypes

data:extend{{
    type = "collision-layer",
    name = "layer_52"
}}

data:extend{{
    type = "collision-layer",
    name = "layer_37"
}}

require("prototypes/entity/mobile-factory.lua")
require("prototypes/entity/mobile-factory-interior.lua")
require("prototypes/entity/jump-drive.lua")
require("prototypes/entity/jump-charger.lua")
require("prototypes/entity/temp-chest.lua")
require("prototypes/entity/temp-tank.lua")
require("prototypes/entity/mf-deploy.lua")
require("prototypes/technology/control-center.lua")
require("prototypes/gun/tank-guns.lua")
require("prototypes/animation/MFTP.lua")

------------------ ITEM GROUP ------------------
data:extend{
    {
        type = "item-group",
        name = "MobileFactory",
        icon = "__Mobile_Factory_Space_Age__/graphics/icons/MFIcon.png",
        icon_size = 32,
        order = "x"
    }
}

data:extend{
    {
        type = "item-subgroup",
        name = "MobileFactory",
        group = "MobileFactory",
        order = "a"
    }
}

------------------ EQUIPMENT CATEGORY ------------------
data:extend{
    {
        type = "equipment-category",
        name = "mfEquipments",
        order = "a"
    }
}

------------------ EQUIPMENT GRIDS ------------------
local equipments = {"armor", "mfEquipments"}

data:extend{
    {
        type = "equipment-grid",
        equipment_categories = equipments,
        name = "MFEquipmentGrid",
        height = 30,
        width = 30
    }
}

------------------ GUI / ICON SPRITES ------------------
local sprites = {
    {name = "ArrowIconUp", filename = "graphics/icons/ArrowIconUp.png", size = 32},
    {name = "ArrowIconDown", filename = "graphics/icons/ArrowIconDown.png", size = 32},
    {name = "PlusIcon", filename = "graphics/icons/PlusIcon.png", size = 32},
    {name = "OptionIcon", filename = "graphics/icons/OptionIcon.png", size = 32},
    {name = "CloseIcon", filename = "graphics/icons/CloseIcon.png", size = 32},
    {name = "SwitchIcon", filename = "graphics/icons/SwtichArrows.png", size = 32},
    {name = "MFJDIcon", filename = "graphics/entity/JumpDriveI.png", size = 128},
    {name = "MFIconExc", filename = "graphics/icons/MFIconExc.png", size = 32},
    {name = "MFDeploy", filename = "graphics/icons/MFDeployI.png", size = 32},
    {name = "MFTPIcon", filename = "graphics/icons/MFTPIcon.png", size = 32},
    {name = "MFTPIconDisabled", filename = "graphics/icons/MFTPIconDisabled.png", size = 32},
    {name = "MFIconI", filename = "graphics/icons/MFIconI.png", size = 32},
    {name = "PortIcon", filename = "graphics/icons/PortIcon.png", size = 32},
    {name = "LockMFCIcon", filename = "graphics/icons/LockMFC.png", size = 32},
    {name = "LockMFOIcon", filename = "graphics/icons/LockMFO.png", size = 32}
}

for _, sprite in pairs(sprites) do
    sprite.type = "sprite"
    sprite.filename = "__Mobile_Factory_Space_Age__/" .. sprite.filename
    sprite.flags = {"icon"}
    data:extend{sprite}
end

data:extend{
    {
        type = "sprite",
        name = "MFDeployE",
        filename = "__Mobile_Factory_Space_Age__/graphics/icons/MobileFactoryE.png",
        width = 400,
        height = 600,
        flags = {"icon"}
    }
}

------------------ SOUNDS ------------------
data:extend{
    {
        type = "sound",
        name = "MFEnter",
        category = "game-effect",
        filename = "__Mobile_Factory_Space_Age__/sounds/EnterMF.ogg",
        preload = true
    },
    {
        type = "sound",
        name = "MFLeave",
        category = "game-effect",
        filename = "__Mobile_Factory_Space_Age__/sounds/LeaveMF.ogg",
        preload = true
    },
    {
        type = "sound",
        name = "MFSimpleTP",
        category = "game-effect",
        filename = "__Mobile_Factory_Space_Age__/sounds/SimpleTP.ogg",
        preload = true
    }
}

------------------ SHORTCUTS ------------------
data:extend{
    {
        type = "custom-input",
        name = "OpenTTGUI",
        key_sequence = "mouse-button-1"
    },
    {
        type = "custom-input",
        name = "CloseGUI",
        key_sequence = "ESCAPE"
    }
}

------------------ FONTS ------------------
data:extend{
    {
        type = "font",
        name = "TitleFont",
        size = 18,
        from = "default-bold"
    },
    {
        type = "font",
        name = "LabelFont",
        size = 12,
        from = "default"
    },
    {
        type = "font",
        name = "LabelFont2",
        size = 14,
        from = "default"
    }
}

------------------ GUI STYLES ------------------
local outer_frame_light_set = outer_frame_light()
outer_frame_light_set.base.center = {position = {42, 8}, size = 1}

data.raw["gui-style"].default.MF_Inventory_scroll_pan = {
    type = "scroll_pane_style",
    padding = 0,
    extra_padding_when_activated = 0,
    extra_right_padding_when_activated = -12,
    graphical_set = outer_frame_light_set,
    background_graphical_set = {
        base = {
            position = {282, 17},
            corner_size = 8,
            overall_tiling_horizontal_padding = 0,
            overall_tiling_horizontal_size = 37,
            overall_tiling_horizontal_spacing = 0,
            overall_tiling_vertical_padding = 0,
            overall_tiling_vertical_size = 37,
            overall_tiling_vertical_spacing = 0
        }
    }
}

data.raw["gui-style"].default.MF_Options_scroll_pan = {
    type = "scroll_pane_style",
    extra_padding_when_activated = 0,
    graphical_set = {position = {136, 0}, corner_size = 8, shadow = {}},
    background_graphical_set = {position = {136, 0}, corner_size = 8},
    vertical_scrollbar_style = {type = "vertical_scrollbar_style"}
}

local function mfScrollStyle(verticalSize)
    return {
        type = "scroll_pane_style",
        graphical_set = {
            base = {
                position = {17, 0},
                corner_size = 8,
                center = {position = {42, 8}, size = 1},
                draw_type = "outer"
            },
            shadow = default_inner_glow(hard_shadow_color, 0.5)
        },
        background_graphical_set = {
            position = {282, 17},
            corner_size = 8,
            overall_tiling_vertical_size = verticalSize,
            overall_tiling_vertical_spacing = 0,
            overall_tiling_vertical_padding = 0,
            overall_tiling_horizontal_padding = 0
        }
    }
end

data.raw["gui-style"].default.MF_DeepTank_scroll_pan = mfScrollStyle(58)
data.raw["gui-style"].default.MF_DeepStorage_scroll_pan = mfScrollStyle(58)
data.raw["gui-style"].default.MF_SwtichGUI_scroll_pan = mfScrollStyle(58)
data.raw["gui-style"].default.MF_TPGUI_scroll_pan = mfScrollStyle(72)
data.raw["gui-style"].default.MF_DA_scroll_pan = mfScrollStyle(58)
data.raw["gui-style"].default.MF_JD_scroll_pan = mfScrollStyle(84)

data.raw["gui-style"].default.MF_Button_Purple = {
    type = "button_style",
    parent = "shortcut_bar_button",
    default_graphical_set = {base = {position = {346, 759}, corner_size = 8, tint = {150, 50, 160}}, shadow = offset_by_2_default_glow(default_dirt_color, 0.5)},
    hovered_graphical_set = {base = {position = {346, 759}, corner_size = 8, tint = {200, 120, 220}}, shadow = offset_by_2_default_glow(default_dirt_color, 0.5), glow = offset_by_2_default_glow({132, 177, 198, 127}, 0.5)},
    clicked_graphical_set = {base = {position = {363, 759}, corner_size = 8, tint = {200, 120, 220}}, shadow = offset_by_2_default_glow(default_dirt_color, 0.5)}
}

data.raw["gui-style"].default.MF_Fake_Button_invisible = {type = "button_style", parent = "slot_sized_button", default_graphical_set = {base = {position = {312, 744}, corner_size = 8, tint = {0, 0, 0, 0}}, shadow = {}}, disabled_graphical_set = {base = {position = {312, 744}, corner_size = 8, tint = {0, 0, 0, 0}}, shadow = {}}, hovered_graphical_set = {base = {position = {312, 744}, corner_size = 8, tint = {0, 0, 0, 0}}, shadow = {}}, clicked_graphical_set = {base = {position = {312, 744}, corner_size = 8, tint = {0, 0, 0, 0}}, shadow = {}}}
data.raw["gui-style"].default.MF_Button_Blue_GrayWhenDisabled = {type = "button_style", parent = "slot_sized_button", default_graphical_set = {base = {position = {312, 760}, corner_size = 8}, shadow = offset_by_2_default_glow(default_dirt_color, 0.5)}, disabled_graphical_set = {base = {position = {329, 744}, corner_size = 8}, shadow = offset_by_2_default_glow(default_dirt_color, 0.5)}, hovered_graphical_set = {base = {position = {346, 760}, corner_size = 8}, shadow = offset_by_2_default_glow(default_dirt_color, 0.5), glow = offset_by_2_default_glow({132, 177, 198, 127}, 0.5)}, clicked_graphical_set = {base = {position = {363, 760}, corner_size = 8}, shadow = offset_by_2_default_glow(default_dirt_color, 0.5)}}
data.raw["gui-style"].default.MF_Fake_Button_Light_Blue = {type = "button_style", parent = "slot_sized_button", default_graphical_set = {base = {position = {363, 760}, corner_size = 8}, shadow = offset_by_2_default_glow(default_dirt_color, 0.5)}, disabled_graphical_set = {base = {position = {329, 744}, corner_size = 8}, shadow = offset_by_2_default_glow(default_dirt_color, 0.5)}, hovered_graphical_set = {base = {position = {363, 760}, corner_size = 8}, shadow = offset_by_2_default_glow(default_dirt_color, 0.5)}, clicked_graphical_set = {base = {position = {363, 760}, corner_size = 8}, shadow = offset_by_2_default_glow(default_dirt_color, 0.5)}}
data.raw["gui-style"].default.MF_Fake_Button_Blue = {type = "button_style", parent = "shortcut_bar_button", default_graphical_set = {base = {position = {312, 759}, corner_size = 8}, shadow = offset_by_2_default_glow(default_dirt_color, 0.5)}, hovered_graphical_set = {base = {position = {312, 759}, corner_size = 8}, shadow = offset_by_2_default_glow(default_dirt_color, 0.5)}, clicked_graphical_set = {base = {position = {312, 759}, corner_size = 8}, shadow = offset_by_2_default_glow(default_dirt_color, 0.5)}}
data.raw["gui-style"].default.MF_Fake_Button_Green = {type = "button_style", parent = "shortcut_bar_button", default_graphical_set = {base = {position = {312, 792}, corner_size = 8}, shadow = offset_by_2_default_glow(default_dirt_color, 0.5)}, hovered_graphical_set = {base = {position = {312, 792}, corner_size = 8}, shadow = offset_by_2_default_glow(default_dirt_color, 0.5)}, clicked_graphical_set = {base = {position = {312, 792}, corner_size = 8}, shadow = offset_by_2_default_glow(default_dirt_color, 0.5)}}
data.raw["gui-style"].default.MF_Fake_Button_Red = {type = "button_style", parent = "shortcut_bar_button", default_graphical_set = {base = {position = {312, 776}, corner_size = 8}, shadow = offset_by_2_default_glow(default_dirt_color, 0.5)}, hovered_graphical_set = {base = {position = {312, 776}, corner_size = 8}, shadow = offset_by_2_default_glow(default_dirt_color, 0.5)}, clicked_graphical_set = {base = {position = {312, 776}, corner_size = 8}, shadow = offset_by_2_default_glow(default_dirt_color, 0.5)}}
data.raw["gui-style"].default.MF_Fake_Button_Purple = {type = "button_style", parent = "shortcut_bar_button", default_graphical_set = {base = {position = {346, 759}, corner_size = 8, tint = {150, 50, 160}}, shadow = offset_by_2_default_glow(default_dirt_color, 0.5)}, hovered_graphical_set = {base = {position = {346, 759}, corner_size = 8, tint = {150, 50, 160}}, shadow = offset_by_2_default_glow(default_dirt_color, 0.5)}, clicked_graphical_set = {base = {position = {346, 759}, corner_size = 8, tint = {150, 50, 160}}, shadow = offset_by_2_default_glow(default_dirt_color, 0.5)}}
data.raw["gui-style"].default.filter_group_tab_selectable = {type = "button_style", parent = "filter_group_button_tab_slightly_larger", disabled_graphical_set = {base = {position = {363, 744}, corner_size = 8}, shadow = offset_by_2_default_glow(default_dirt_color, 0.5)}}
data.raw["gui-style"].default.MFFrame1 = {type = "frame_style", graphical_set = {}, border = border_image_set(), right_padding = 4, use_header_filler = false, title_style = {type = "label_style", parent = "caption_label"}}
data.raw["gui-style"].default.MFFrame2 = {type = "frame_style", graphical_set = {base = {position = {17, 0}, corner_size = 8, draw_type = "outer", shadow = {}}, shadow = default_inner_shadow}}
data.raw["gui-style"].default.MF_Options_Frame = {type = "frame_style", graphical_set = {base = {position = {136, 0}, corner_size = 8, draw_type = "outer", shadow = {}}, shadow = default_inner_shadow}, border = border_image_set(), right_padding = 4, use_header_filler = false, title_style = {type = "label_style", parent = "caption_label"}}
data.raw["gui-style"].default.MF_Options_Tabbed_Pane = {type = "tabbed_pane_style", vertical_spacing = 0, padding = 0, tab_content_frame = {type = "frame_style", parent = "invisible_frame"}, tab_container = {type = "table_style", left_padding = 12, right_padding = 12, horizontal_spacing = 0}}
data.raw["gui-style"].default.MF_Yellow_Label = {type = "label_style", font = "default", font_color = _mfYellow}
