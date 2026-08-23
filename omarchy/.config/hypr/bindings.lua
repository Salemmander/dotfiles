-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Super+Shift+A was ChatGPT; Super+Shift+Alt+A was Grok.
hl.unbind("SUPER + SHIFT + A")
hl.unbind("SUPER + SHIFT + ALT + A")
o.bind("SUPER + SHIFT + A", "Grok", { webapp = "https://grok.com" })

-- Super+Shift+E was Hey email.
hl.unbind("SUPER + SHIFT + E")
o.bind("SUPER + SHIFT + E", "Gmail", { webapp = "https://mail.google.com/mail/u/0/#inbox" })

-- Super+Shift+/ was 1Password.
hl.unbind("SUPER + SHIFT + SLASH")
o.bind("SUPER + SHIFT + SLASH", "Bitwarden", { launch = "bitwarden" })

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

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
