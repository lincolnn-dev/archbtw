hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "intl",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

hl.device({
    name        = "compx-vxe-nordicmouse-1k-dongle-1",
    sensitivity = -0.6,
})

hl.device({
    name        = "compx-vxe-nordicmouse-1k-dongle-2",
    sensitivity = -0.6,
})

hl.device({
    name        = "compx-vxe-nordicmouse-1k-dongle-3",
    sensitivity = -0.6,
})
