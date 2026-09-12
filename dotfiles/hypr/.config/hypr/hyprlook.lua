hl.config({
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },
})

hl.config({
    general = {
        gaps_in  = 2,
        gaps_out = 8,
        border_size = 2,
        col = {
            active_border   = { colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
    },
    decoration = {
        rounding       = 10,
        rounding_power = 2,
        active_opacity   = 0.87,
        inactive_opacity = 0.87,
        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },
        blur = {
            enabled   = true,
            size      = 2,
            passes    = 4,
            vibrancy  = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})
