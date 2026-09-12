hl.on("hyprland.start", function ()
    hl.exec_cmd("noctalia")
end)

require("hyprmonitor")
require("hyprinput")
require("hyprbind")
require("hyprenv")
require("hyprlook")
require("hyprfeel")
require("hyprwindow")

require("noctalia").apply_theme()
