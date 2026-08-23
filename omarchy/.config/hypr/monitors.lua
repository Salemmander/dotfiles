-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

hl.env("GDK_SCALE", "1")

-- Left: Acer VG270 27" 1080p 75Hz
hl.monitor({
  output = "desc:Acer Technologies VG270",
  mode = "1920x1080@74.97",
  position = "0x0",
  scale = 1,
})

-- Right: Acer VG272U 27" 1440p. `preferred` is 59.95Hz; 143.86 is the 144Hz mode.
-- vrr = 2 is adaptive sync in fullscreen only.
hl.monitor({
  output = "desc:Acer Technologies VG272U",
  mode = "2560x1440@143.86",
  position = "1920x0",
  scale = 1,
  vrr = 2,
})

-- Fallback for any other plugged-in display.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.25 })
