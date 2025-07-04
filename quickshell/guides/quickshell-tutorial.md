# 🚀 Complete Quickshell Tutorial: Building a Functional Top Bar

## 📋 Overview

This comprehensive tutorial will guide you through creating a fully functional top bar for Quickshell with Hyprland integration. You'll learn how to build a dark-themed bar featuring clickable workspaces and a live date/time display.

## 🎯 What You'll Build

- **Dark-themed top bar** spanning the full width of your screen
- **Interactive workspaces** that show your current Hyprland workspaces
- **Live date and time display** that updates every second
- **Proper window management** with panel positioning

## 📁 Project Structure

```
tut/
├── shell.qml              # Main entry point
└── modules/
    └── bar/
        └── Bar.qml        # Top bar component
```

## 🔧 Step 1: Main Shell Configuration

Create `shell.qml` - this is the entry point for your Quickshell configuration:

```qml
//@ pragma UseQApplication
// ^ This pragma tells Quickshell to use QApplication instead of QGuiApplication
// This is required for proper application behavior and window management

import QtQuick
// ^ Import the QtQuick module for basic QML components like Rectangle, Text, etc.

import Quickshell
// ^ Import Quickshell's core functionality including ShellRoot and panel management

import "./modules/bar/"
// ^ Import our custom bar module from the local modules/bar/ directory

ShellRoot {
    // ShellRoot is the main container for your Quickshell configuration
    // It manages the overall shell environment and coordinates all components
    id: root
    // ^ Give this component an ID so we can reference it from other components if needed

    // Direct Loader without container - matches the repository pattern
    Loader {
        // Loader is a component that can dynamically load and unload other components
        // This allows for efficient memory usage and modular design
        active: true
        // ^ Set active to true to immediately load the component
        // If false, the component wouldn't be loaded until explicitly activated
        
        sourceComponent: Bar {}
        // ^ Instead of loading from a file, we're creating an instance of our Bar component
        // This is more efficient than using the 'source' property with a file path
    }
}
```

## 🎨 Step 2: Creating the Top Bar Component

Create `modules/bar/Bar.qml` - this contains the main bar logic:

```qml
import QtQuick
// ^ Import QtQuick for basic QML components (Rectangle, Text, MouseArea, etc.)

import Quickshell
// ^ Import Quickshell for PanelWindow and shell-specific functionality

import Quickshell.Hyprland
// ^ Import Hyprland integration for workspace management and window manager communication

// Create a proper panel window
PanelWindow {
    // PanelWindow is a special Quickshell component designed for creating bars/panels
    // It automatically handles positioning, layering, and window manager integration
    id: panel
    // ^ Assign an ID to reference this panel from child components
    
    // Panel configuration - span full width
    anchors {
        // Anchors define how this panel attaches to screen edges
        top: true
        // ^ Anchor to the top edge of the screen
        left: true
        // ^ Anchor to the left edge of the screen  
        right: true
        // ^ Anchor to the right edge of the screen
        // Together, these make the panel span the full width at the top
    }
    
    implicitHeight: 40
    // ^ Set the height of the panel to 40 pixels
    // Using implicitHeight instead of height avoids deprecation warnings
    
    margins {
        // Margins create space between the panel and screen edges
        top: 8
        // ^ 8 pixels of space from the top of the screen
        left: 0
        // ^ No space from the left edge (full width)
        right: 0
        // ^ No space from the right edge (full width)
    }
    
    // The actual bar content - dark mode
    Rectangle {
        // Rectangle provides the visual background and container for our bar
        id: bar
        // ^ ID for referencing this rectangle from child components
        
        anchors.fill: parent
        // ^ Make the rectangle fill the entire PanelWindow
        
        color: "#1a1a1a"  // Dark background
        // ^ Dark gray background color for the bar (hex color code)
        
        radius: 0  // Full width bar without rounded corners
        // ^ No border radius for sharp, clean edges
        
        border.color: "#333333"
        // ^ Slightly lighter gray for a subtle border
        
        border.width: 1
        // ^ 1 pixel border width for definition

        // Workspaces on the far left - connected to Hyprland
        Row {
            // Row arranges child components horizontally in a line
            id: workspacesRow
            // ^ ID for referencing this row container
            
            anchors {
                // Position the workspace row on the left side of the bar
                left: parent.left
                // ^ Anchor to the left edge of the parent (bar rectangle)
                
                verticalCenter: parent.verticalCenter
                // ^ Center vertically within the parent
                
                leftMargin: 16
                // ^ 16 pixels of space from the left edge
            }
            
            spacing: 8
            // ^ 8 pixels of space between each workspace button
            
            // Real Hyprland workspace data
            Repeater {
                // Repeater creates multiple instances of a component based on a model
                model: Hyprland.workspaces
                // ^ Use Hyprland's workspace data as the model
                // This automatically updates when workspaces change
                
                Rectangle {
                    // Each workspace is represented as a rectangle button
                    width: 32
                    // ^ 32 pixels wide for each workspace button
                    
                    height: 24
                    // ^ 24 pixels tall for each workspace button
                    
                    radius: 4
                    // ^ Slightly rounded corners (4 pixel radius)
                    
                    color: modelData.active ? "#4a9eff" : "#333333"
                    // ^ Blue color if this workspace is active, dark gray if inactive
                    // modelData.active is provided by Hyprland integration
                    
                    border.color: "#555555"
                    // ^ Medium gray border for definition
                    
                    border.width: 1
                    // ^ 1 pixel border width
                    
                    // Make workspaces clickable
                    MouseArea {
                        // MouseArea detects mouse clicks and other mouse events
                        anchors.fill: parent
                        // ^ Cover the entire workspace rectangle
                        
                        onClicked: Hyprland.dispatch("workspace " + modelData.id)
                        // ^ When clicked, tell Hyprland to switch to this workspace
                        // modelData.id contains the workspace number/ID
                        // Hyprland.dispatch sends commands to the Hyprland window manager
                    }
                    
                    Text {
                        // Display the workspace number/ID
                        text: modelData.id
                        // ^ Show the workspace ID (1, 2, 3, etc.)
                        
                        anchors.centerIn: parent
                        // ^ Center the text within the workspace rectangle
                        
                        color: modelData.active ? "#ffffff" : "#cccccc"
                        // ^ White text for active workspace, light gray for inactive
                        
                        font.pixelSize: 12
                        // ^ 12 pixel font size for readability
                        
                        font.family: "Inter, sans-serif"
                        // ^ Use Inter font if available, fallback to sans-serif
                    }
                }
            }
            
            // Fallback if no workspaces are detected
            Text {
                // This text only shows if there are no workspaces
                visible: Hyprland.workspaces.length === 0
                // ^ Only visible when the workspace array is empty
                
                text: "No workspaces"
                // ^ Helpful debug message
                
                color: "#ffffff"
                // ^ White text color
                
                font.pixelSize: 12
                // ^ 12 pixel font size
            }
        }
        
        // Time on the far right
        Text {
            // Text component for displaying date and time
            id: timeDisplay
            // ^ ID for referencing from the Timer component
            
            anchors {
                // Position the time display on the right side of the bar
                right: parent.right
                // ^ Anchor to the right edge of the parent (bar rectangle)
                
                verticalCenter: parent.verticalCenter
                // ^ Center vertically within the parent
                
                rightMargin: 16
                // ^ 16 pixels of space from the right edge
            }
            
            property string currentTime: ""
            // ^ Custom property to store the current time string
            // This allows us to update the time from the Timer component
            
            text: currentTime
            // ^ Display the current time stored in our custom property
            
            color: "#ffffff"
            // ^ White text color for good contrast on dark background
            
            font.pixelSize: 14
            // ^ 14 pixel font size (slightly larger than workspace text)
            
            font.family: "Inter, sans-serif"
            // ^ Use Inter font if available, fallback to sans-serif
            
            // Update time every second
            Timer {
                // Timer component triggers events at regular intervals
                interval: 1000
                // ^ 1000 milliseconds = 1 second interval
                
                running: true
                // ^ Start the timer immediately when the component is created
                
                repeat: true
                // ^ Keep repeating the timer (don't stop after first trigger)
                
                onTriggered: {
                    // This code runs every second when the timer triggers
                    var now = new Date()
                    // ^ Create a new Date object with the current date/time
                    
                    timeDisplay.currentTime = Qt.formatDate(now, "MMM dd") + " " + Qt.formatTime(now, "hh:mm:ss")
                    // ^ Format the date as "Jan 07" and time as "14:30:45"
                    // Qt.formatDate formats the date portion
                    // Qt.formatTime formats the time portion
                    // We concatenate them with a space in between
                }
            }
            
            // Initialize time immediately
            Component.onCompleted: {
                // This code runs once when the component is fully loaded
                var now = new Date()
                // ^ Create a Date object with the current date/time
                
                currentTime = Qt.formatDate(now, "MMM dd") + " " + Qt.formatTime(now, "hh:mm:ss")
                // ^ Set the initial time display immediately
                // Without this, the time would be blank until the first timer trigger
            }
        }
    }
}
```

## 🚀 Step 3: Running Your Configuration

1. **Save both files** in the correct directory structure
2. **Run Quickshell** with your configuration:
   ```bash
   qs -c /path/to/your/tut/directory
   ```

## 🎨 Customization Options

### 🎨 Color Scheme
- **Bar background**: `#1a1a1a` (dark gray)
- **Active workspace**: `#4a9eff` (blue)
- **Inactive workspace**: `#333333` (medium gray)
- **Text colors**: `#ffffff` (white) and `#cccccc` (light gray)

### 📏 Sizing
- **Bar height**: 40 pixels
- **Workspace buttons**: 32x24 pixels
- **Font sizes**: 12px for workspaces, 14px for time

### 🔧 Positioning
- **Top margin**: 8 pixels from screen edge
- **Side margins**: 16 pixels from bar edges
- **Workspace spacing**: 8 pixels between buttons

## 🔍 Key Concepts Explained

### 🏗️ Component Architecture
- **ShellRoot**: Main container managing the entire shell
- **PanelWindow**: Specialized window for bars and panels
- **Loader**: Dynamic component loading for modularity

### 🔄 Data Binding
- **Hyprland.workspaces**: Live data from window manager
- **modelData.active**: Reactive workspace state
- **Timer updates**: Real-time clock functionality

### 🎯 Event Handling
- **MouseArea.onClicked**: Workspace switching
- **Timer.onTriggered**: Time updates
- **Component.onCompleted**: Initialization

## 🐛 Troubleshooting

### ❌ Common Issues

1. **"No workspaces" appears**: Hyprland integration not working
2. **Time not updating**: Timer not running properly
3. **Clicks not working**: MouseArea not properly configured
4. **Bar not visible**: PanelWindow positioning issues

### ✅ Solutions

1. **Check Hyprland is running**: `ps aux | grep hypr`
2. **Verify imports**: Ensure `Quickshell.Hyprland` is imported
3. **Test with console.log**: Add debugging to click handlers
4. **Check margins**: Ensure panel isn't positioned off-screen

## 🎉 Conclusion

You now have a fully functional Quickshell top bar with:
- ✅ **Live workspace switching** integrated with Hyprland
- ✅ **Real-time date and time display** updating every second
- ✅ **Modern dark theme** with proper contrast
- ✅ **Responsive design** that spans the full screen width
- ✅ **Clean, maintainable code** with detailed documentation

This bar serves as a solid foundation for further customization and additional features! 