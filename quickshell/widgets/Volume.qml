import QtQuick
import Quickshell

Item {
    id: volumeDisplay
    property var shell
    property int volume: 0
    property bool volumeMuted: false

    readonly property int iconSize: 22
    readonly property int pillHeight: 22
    readonly property int pillPaddingHorizontal: 14
    readonly property int pillOverlap: iconSize / 2

    property int maxPillWidth: 0
    property bool showPercentage: false

    // Dark theme colors (matching our bar theme)
    readonly property color surfaceVariant: "#333333"
    readonly property color accentPrimary: "#4a9eff"
    readonly property color textPrimary: "#ffffff"
    readonly property color backgroundPrimary: "#1a1a1a"

    // Outer width includes icon plus pill width minus overlap
    // Ensure minimum width to avoid zero width warning
    width: Math.max(iconSize, showPercentage ? iconSize + maxPillWidth - pillOverlap : iconSize)
    height: pillHeight

    // Watch for volume changes
    onVolumeChanged: {
        if (!showPercentage) {
            showPercentage = true
            showHideAnimation.start()
        } else {
            showHideAnimation.restart()
        }
    }

    Component.onCompleted: {
        maxPillWidth = percentageText.implicitWidth + pillPaddingHorizontal * 2 + pillOverlap
        percentageContainer.width = 0
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        Rectangle {
            id: percentageContainer
            topLeftRadius: pillHeight / 2
            bottomLeftRadius: pillHeight / 2
            color: surfaceVariant
            height: pillHeight
            width: 0  // start collapsed
            anchors.verticalCenter: parent.verticalCenter

            // Align right edge with circle center
            x: (iconCircle.x + iconCircle.width / 2) - width

            opacity: 0
            visible: width > 0  // Hide when collapsed to avoid zero width warning

            Text {
                id: percentageText
                anchors.centerIn: parent
                text: volume + "%"
                font.pixelSize: 14
                font.weight: Font.Bold
                color: textPrimary
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                clip: true
            }
        }

        Rectangle {
            id: iconCircle
            width: iconSize
            height: iconSize
            radius: width / 2
            color: showPercentage ? accentPrimary : "transparent"
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            smooth: true

            Behavior on color {
                ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }
        }

        Text {
            id: icon
            anchors.centerIn: iconCircle
            font.family: "Material Symbols Outlined"
            font.pixelSize: 14
            color: showPercentage ? backgroundPrimary : textPrimary
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter

            text: {
                if (volumeMuted || volume === 0)
                    return "🔇"  // Muted icon
                else if (volume > 0 && volume < 30)
                    return "🔉"  // Low volume icon
                else
                    return "🔊"  // High volume icon
            }
        }

        // Mouse area for volume control
        MouseArea {
            anchors.fill: iconCircle
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            
            onClicked: function(mouse) {
                if (mouse.button === Qt.LeftButton) {
                    // Left click: toggle mute
                    if (shell && shell.defaultAudioSink && shell.defaultAudioSink.audio) {
                        shell.defaultAudioSink.audio.muted = !shell.defaultAudioSink.audio.muted
                    }
                } else if (mouse.button === Qt.RightButton) {
                    // Right click: open system volume control
                    Qt.openUrlExternally("pavucontrol")
                }
            }
            
            onWheel: function(wheel) {
                // Scroll wheel: adjust volume
                if (shell && shell.defaultAudioSink && shell.defaultAudioSink.audio) {
                    var delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05  // 5% steps
                    var newVolume = Math.max(0, Math.min(1, shell.defaultAudioSink.audio.volume + delta))
                    shell.defaultAudioSink.audio.volume = newVolume
                }
            }
        }
    }

    SequentialAnimation {
        id: showHideAnimation
        running: false

        // Show animation: expand width and fade in
        ParallelAnimation {
            NumberAnimation {
                target: percentageContainer
                property: "width"
                from: 0
                to: maxPillWidth
                duration: 250
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: percentageContainer
                property: "opacity"
                from: 0
                to: 1
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        PauseAnimation {
            duration: 2500
        }

        // Hide animation: collapse width and fade out
        ParallelAnimation {
            NumberAnimation {
                target: percentageContainer
                property: "width"
                from: maxPillWidth
                to: 0
                duration: 250
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                target: percentageContainer
                property: "opacity"
                from: 1
                to: 0
                duration: 250
                easing.type: Easing.InCubic
            }
        }

        onStopped: {
            showPercentage = false
        }
    }
} 