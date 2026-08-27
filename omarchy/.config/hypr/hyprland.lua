-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- Pin workspaces to monitors so Super+N cannot create/steal a workspace on
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


-- Bitwarden Brave extension popup. Omarchy only covers the chrome- class;
-- float/center only — no size override so the extension keeps its natural size.
o.window("brave-nngceckbapebfimnlniiiahkandclblb-Default", {
  no_screen_share = true,
  float = true,
  center = true,
})

-- Black Ops 3 under Proton/Wine: keep XWayland menu input reliable.
o.window(".*[Bb]lack.*[Oo]ps.*3.*", {
  allows_input = true,
  tag = "-default-opacity",
  opacity = "1 1",
})
o.window({ title = ".*[Bb]lack.*[Oo]ps.*3.*" }, { allows_input = true })

-- Zoom (XWayland): hovering the meeting spawns extra windows (toolbar,
-- tooltips, menus). follow_mouse focuses them, Zoom thinks the cursor
-- left, destroys the popup, and the tiled meeting resizes in a loop.
-- Keep the main meeting/home windows tiled; float everything else.
o.window({
  class = "^zoom$",
  title = "negative:^(Meeting|Zoom Meeting|Zoom Workplace)$",
}, {
  float = true,
  no_anim = true,
  no_initial_focus = true,
  no_follow_mouse = true,
  allows_input = true,
})
o.window({ class = "^zoom$", title = "^(annotate_toolbar|as_toolbar)$" }, {
  float = true,
  no_anim = true,
  no_initial_focus = true,
  no_follow_mouse = true,
  allows_input = true,
  size = { 900, 80 },
})
o.window("zoom", { no_anim = true })
