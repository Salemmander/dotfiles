-- Dual Acer PC. Loaded from hyprland.lua via pcall when this package is stowed.

-- Omarchy 4.5 gives each monitor its own workspaces 1-10 (left VG270 and
-- right VG272U each get a block of ten; see default/hypr/monitor-workspaces.lua),
-- and binds Super+N to the Nth workspace on the focused monitor itself.

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

-- Super+L was toggle workspace layout (dwindle/scrolling).
hl.unbind("SUPER + L")

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
