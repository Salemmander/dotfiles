import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

// Left group is workspaces 6-10, right group is 1-5. Both labeled 1-5.
BarWidget {
  id: root
  moduleName: "omarchy.workspaces"

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }
    return null
  }

  function focusWorkspace(id) {
    if (!root.bar) return
    root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
  }

  component Slot: WidgetButton {
    required property int workspaceId
    required property int label

    readonly property var workspace: root.workspaceById(workspaceId)
    readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
    readonly property bool focused: workspace && workspace.monitor && workspace.monitor.activeWorkspace
      && workspace.monitor.activeWorkspace.id === workspaceId

    bar: root.bar
    text: focused ? "\uDB85\uDCFB" : String(label)
    opacity: occupied || focused ? 1 : 0.5
    horizontalMargin: 6
    verticalPadding: 6
    fixedWidth: root.vertical ? root.barSize : Style.space(20)
    fixedHeight: root.barSize
    onPressed: function() { root.focusWorkspace(workspaceId) }
  }

  readonly property int focusedId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 0
  readonly property bool leftActive: focusedId >= 6
  readonly property bool rightActive: focusedId >= 1 && focusedId <= 5
  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  implicitWidth: row.implicitWidth + trailingGap
  implicitHeight: row.implicitHeight

  RowLayout {
    id: row
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    spacing: Style.space(1)

    RowLayout {
      spacing: Style.space(1)
      opacity: root.leftActive ? 1 : 0.35
      Behavior on opacity { NumberAnimation { duration: 140 } }

      Repeater {
        model: [6, 7, 8, 9, 10]
        Slot {
          required property int modelData
          required property int index
          workspaceId: modelData
          label: index + 1
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
        model: [1, 2, 3, 4, 5]
        Slot {
          required property int modelData
          workspaceId: modelData
          label: modelData
        }
      }
    }
  }
}
