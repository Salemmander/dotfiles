-- Dual Acer PC. Loaded from hyprland.lua via pcall when this package is stowed.

-- Pin workspaces so Super+N cannot create/steal a workspace on
-- whichever screen happens to be focused.
-- Right VG272U (primary): 1-5. Left VG270 (secondary): 6-10.
local primary = "desc:Acer Technologies VG272U"
local secondary = "desc:Acer Technologies VG270"

for i = 1, 5 do
  hl.workspace_rule({
    workspace = tostring(i),
    monitor = primary,
    persistent = true,
    default = (i == 1),
  })
end

for i = 6, 10 do
  hl.workspace_rule({
    workspace = tostring(i),
    monitor = secondary,
    persistent = true,
    default = (i == 6),
  })
end

-- Super+1-5 was global workspace N. Make it the Nth workspace on the
-- focused monitor instead (right VG272U: 1-5, left VG270: 6-10).
local function warp_to_active_monitor()
  local mon = hl.get_active_monitor()
  if not mon then
    return
  end

  local pos = mon.position
  local x = type(pos) == "table" and (pos.x or pos[1]) or 0
  local y = type(pos) == "table" and (pos.y or pos[2]) or 0
  hl.dispatch(hl.dsp.cursor.move({
    x = x + (mon.width or 0) / 2,
    y = y + (mon.height or 0) / 2,
  }))
end

for slot = 1, 5 do
  local key = "code:" .. tostring(slot + 9)
  hl.unbind("SUPER + " .. key)
  hl.unbind("SUPER + SHIFT + " .. key)
  hl.unbind("SUPER + SHIFT + ALT + " .. key)
  o.bind(
    "SUPER + " .. key,
    "Switch to workspace " .. slot .. " on focused monitor",
    hl.dsp.focus({ workspace = "r~" .. slot })
  )
  o.bind(
    "SUPER + SHIFT + " .. key,
    "Move window to workspace " .. slot .. " on focused monitor",
    hl.dsp.window.move({ workspace = "r~" .. slot })
  )
  o.bind(
    "SUPER + SHIFT + ALT + " .. key,
    "Move window silently to workspace " .. slot .. " on focused monitor",
    hl.dsp.window.move({ workspace = "r~" .. slot, follow = false })
  )
end

-- Super+L was toggle workspace layout (dwindle/scrolling).
hl.unbind("SUPER + L")
hl.unbind("SUPER + GRAVE")
hl.unbind("SUPER + SHIFT + GRAVE")

o.bind("SUPER + H", "Focus left monitor", function()
  hl.dispatch(hl.dsp.focus({ monitor = "l" }))
  warp_to_active_monitor()
end)

o.bind("SUPER + L", "Focus right monitor", function()
  hl.dispatch(hl.dsp.focus({ monitor = "r" }))
  warp_to_active_monitor()
end)

o.bind("SUPER + SHIFT + H", "Move window to left monitor", function()
  hl.dispatch(hl.dsp.window.move({ monitor = "l", follow = true }))
  warp_to_active_monitor()
end)

o.bind("SUPER + SHIFT + L", "Move window to right monitor", function()
  hl.dispatch(hl.dsp.window.move({ monitor = "r", follow = true }))
  warp_to_active_monitor()
end)
