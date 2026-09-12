hl.bind("SUPER + C", hl.dsp.window.close())
hl.bind("SUPER + space", hl.dsp.window.fullscreen({ mode = 1 }))
hl.bind("SUPER + F", function()
    local w = hl.get_active_window()
    if w == nil then return end
    if w.floating then
        hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    else
        hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
        hl.dispatch(hl.dsp.window.resize({ x = 1280, y = 720, relative = false }))
        hl.dispatch(hl.dsp.window.center())
    end
end)

hl.bind("SUPER + Q", hl.dsp.exec_cmd("kitty"))
hl.bind("SUPER + E", hl.dsp.exec_cmd("kitty -e yazi"))
hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd("thunar"))
hl.bind("SUPER + B", hl.dsp.exec_cmd("helium-browser"))

hl.bind("SUPER + P", hl.dsp.window.pseudo())
hl.bind("SUPER + J", hl.dsp.layout("togglesplit"))
hl.bind("SUPER + R", hl.dsp.layout("movetoroot active unstable"))
hl.bind("SUPER + O", hl.dsp.window.set_prop({ prop = "opaque", value = "toggle" }))
hl.bind("SUPER + T", function()
    local workspace = hl.get_active_special_workspace() or hl.get_active_workspace()
    if not workspace then return end

    local next_layout = "scrolling"
    if workspace.tiled_layout == "scrolling" then
        next_layout = "dwindle"
    end

    if workspace.special then
        hl.workspace_rule({ workspace = tostring(workspace.name), layout = next_layout })
    else
        hl.workspace_rule({ workspace = tostring(workspace.id), layout = next_layout })
    end
end)

hl.bind("SUPER + return", hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"))
hl.bind("SUPER + escape", hl.dsp.exec_cmd("noctalia msg panel-toggle session"))
hl.bind("SUPER + V", hl.dsp.exec_cmd("noctalia msg panel-toggle clipboard"))
hl.bind("SUPER + H", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center"))
hl.bind("SUPER + S", hl.dsp.exec_cmd("noctalia msg screenshot-region"))
hl.bind("SUPER + L", hl.dsp.exec_cmd("noctalia msg session lock"))
hl.bind("ALT + TAB", hl.dsp.exec_cmd("noctalia msg window-switcher"))
hl.bind("SUPER + slash", hl.dsp.exec_cmd("noctalia msg panel-toggle noctalia/notes:panel"))
hl.bind("SUPER + N", hl.dsp.exec_cmd("noctalia msg nightlight-toggle"))

hl.bind("SUPER + left",  hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up",    hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + SHIFT + left",  hl.dsp.window.swap({ direction = "left" }))
hl.bind("SUPER + SHIFT + right", hl.dsp.window.swap({ direction = "right" }))
hl.bind("SUPER + SHIFT + up",    hl.dsp.window.swap({ direction = "up" }))
hl.bind("SUPER + SHIFT + down",  hl.dsp.window.swap({ direction = "down" }))
for i = 1, 10 do
    local key = i % 10
    hl.bind("SUPER + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind("SUPER + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

hl.bind("SUPER + M",         hl.dsp.workspace.toggle_special("magic"))
hl.bind("SUPER + SHIFT + M", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind("SUPER + mouse_down", function()
    local ws = hl.get_active_special_workspace() or hl.get_active_workspace()
    if not ws or ws.tiled_layout ~= "scrolling" then return end
    hl.dispatch(hl.dsp.layout("focus d"))
end)
hl.bind("SUPER + mouse_up", function()
    local ws = hl.get_active_special_workspace() or hl.get_active_workspace()
    if not ws or ws.tiled_layout ~= "scrolling" then return end
    hl.dispatch(hl.dsp.layout("focus u"))
end)

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.bind("SUPER + delete", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
