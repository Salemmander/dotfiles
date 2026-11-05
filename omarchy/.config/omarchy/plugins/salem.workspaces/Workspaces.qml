import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.workspaces"

  // Omarchy 4.5 gives each monitor a block of ten workspaces (1-10, 11-20, ...)
  // and records connector -> block in ~/.local/state/omarchy/monitor-workspaces.
  readonly property int slots: 10
  property var blocks: ({})

  function readBlocks(text) {
    var next = {}
    var lines = String(text || "").split("\n")
    for (var i = 0; i < lines.length; i++) {
      var fields = lines[i].split("\t")
      if (fields.length >= 3 && fields[1] !== "") next[fields[1]] = parseInt(fields[0], 10)
    }
    root.blocks = next
  }

  FileView {
    path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/omarchy/monitor-workspaces"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.readBlocks(text())
    onLoadFailed: root.readBlocks("")
  }

  function blockOf(id) {
    return Math.floor((id - 1) / root.slots)
  }

  function slotOf(id) {
    return (id - 1) % root.slots + 1
  }

  function monitorBlock(monitor) {
    if (!monitor) return 0
    var block = root.blocks[monitor.name]
    if (block !== undefined) return block
    var active = root.activeIdOf(monitor)
    return active > 0 ? root.blockOf(active) : 0
  }

  // Monitors ordered left to right on the desk.
  readonly property var sortedMonitors: {
    var list = Hyprland.monitors ? Hyprland.monitors.values.slice() : []
    list.sort(function(a, b) { return a.x - b.x })
    return list
  }
  readonly property bool dual: sortedMonitors.length >= 2
  readonly property var leftMonitor: dual ? sortedMonitors[0] : null
  readonly property var rightMonitor: dual ? sortedMonitors[sortedMonitors.length - 1] : null
  readonly property int leftBase: root.monitorBlock(leftMonitor) * root.slots
  readonly property int rightBase: root.monitorBlock(rightMonitor) * root.slots

  readonly property int focusedId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 0
  readonly property bool leftActive: dual && root.blockOf(focusedId) === root.monitorBlock(leftMonitor)
  readonly property bool rightActive: dual && root.blockOf(focusedId) === root.monitorBlock(rightMonitor)
  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  // Quickshell's monitor.activeWorkspace can go stale across monitors, so read
  // the id from Hyprland's own monitor JSON, refreshed on every workspace event.
  function activeIdOf(monitor) {
    if (!monitor) return -1
    var ipc = monitor.lastIpcObject
    if (ipc && ipc.activeWorkspace && ipc.activeWorkspace.id !== undefined) return ipc.activeWorkspace.id
    return monitor.activeWorkspace ? monitor.activeWorkspace.id : -1
  }

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }
    return null
  }

  // The first five of a monitor's block, plus any others in it that exist.
  function blockIds(base) {
    var block = root.blockOf(base + 1)
    var ids = [base + 1, base + 2, base + 3, base + 4, base + 5]
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      var id = values[i].id
      if (id > 0 && root.blockOf(id) === block && ids.indexOf(id) === -1) ids.push(id)
    }
    ids.sort(function(left, right) { return left - right })
    return ids
  }

  function workspaceIds() {
    return root.blockIds(root.monitorBlock(Hyprland.focusedMonitor) * root.slots)
  }

  function focusWorkspace(id, monitor) {
    if (!root.bar) return
    var expression = monitor
      ? "o.workspaces.focus(" + root.slotOf(id) + ", \"" + monitor.name + "\")"
      : "o.workspaces.focus(" + root.slotOf(id) + ")"
    root.bar.run("hyprctl dispatch " + Util.shellQuote(expression))
  }

  // Quickshell credits workspace switches to the focused monitor, so ask
  // Hyprland for the truth when workspaces move or renumber.
  Component.onCompleted: {
    Hyprland.refreshMonitors()
    Hyprland.refreshWorkspaces()
  }

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      var name = event ? String(event.name) : ""
      if (name === "workspacev2" || name === "moveworkspacev2" || name === "changeworkspaceid") {
        Hyprland.refreshMonitors()
        Hyprland.refreshWorkspaces()
      }
    }
  }

  component Slot: WidgetButton {
    required property int workspaceId
    required property var monitor

    readonly property var workspace: root.workspaceById(workspaceId)
    readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
    readonly property bool focused: root.activeIdOf(monitor) === workspaceId

    bar: root.bar
    text: focused ? "\uDB85\uDCFB" : (root.slotOf(workspaceId) === root.slots ? "0" : String(root.slotOf(workspaceId)))
    opacity: occupied || focused ? 1 : 0.5
    horizontalMargin: 6
    verticalPadding: 6
    fixedWidth: root.vertical ? root.barSize : Style.space(20)
    fixedHeight: root.barSize
    onPressed: function() { root.focusWorkspace(workspaceId, monitor) }
  }

  implicitWidth: layoutLoader.implicitWidth + trailingGap
  implicitHeight: layoutLoader.implicitHeight

  // Only build the active layout; each WidgetButton is costly to create.
  Loader {
    id: layoutLoader
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    sourceComponent: root.dual ? dualLayout : singleLayout
  }

  Component {
    id: singleLayout

    GridLayout {
      columns: root.vertical ? 1 : root.workspaceIds().length
      columnSpacing: root.vertical ? 0 : Style.space(1)
      rowSpacing: root.vertical ? Style.space(2) : 0

      Repeater {
        model: root.workspaceIds()

        WidgetButton {
          required property int modelData

          readonly property var workspace: root.workspaceById(modelData)
          readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
          readonly property bool focused: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === modelData

          bar: root.bar
          text: focused ? "\uDB85\uDCFB" : (root.slotOf(modelData) === root.slots ? "0" : String(root.slotOf(modelData)))
          opacity: occupied || focused ? 1 : 0.5
          horizontalMargin: 6
          verticalPadding: 6
          fixedWidth: root.vertical ? root.barSize : Style.space(20)
          fixedHeight: root.barSize
          onPressed: function() { root.focusWorkspace(modelData) }
        }
      }
    }
  }

  Component {
    id: dualLayout

    RowLayout {
      spacing: Style.space(1)

      RowLayout {
        spacing: Style.space(1)
        opacity: root.leftActive ? 1 : 0.35
        Behavior on opacity { NumberAnimation { duration: 140 } }

        Repeater {
          model: root.blockIds(root.leftBase)
          Slot {
            required property int modelData
            workspaceId: modelData
            monitor: root.leftMonitor
          }
        }
      }

      Text {
        text: "│"
        color: root.bar ? root.bar.barForeground : Color.foreground
        font.family: root.bar ? root.bar.fontFamily : Style.font.family
        font.pixelSize: Style.font.body
        opacity: 0.35
        Layout.leftMargin: Style.space(2)
        Layout.rightMargin: Style.space(2)
      }

      RowLayout {
        spacing: Style.space(1)
        opacity: root.rightActive ? 1 : 0.35
        Behavior on opacity { NumberAnimation { duration: 140 } }

        Repeater {
          model: root.blockIds(root.rightBase)
          Slot {
            required property int modelData
            workspaceId: modelData
            monitor: root.rightMonitor
          }
        }
      }
    }
  }
}
