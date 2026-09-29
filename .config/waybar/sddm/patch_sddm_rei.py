#!/usr/bin/env python3
"""
Script to transform SDDM_Reactive_Theme Main.qml into a minimal rei-style layout
while keeping matugen dynamic colors and wallpaper support.
Run with: sudo python3 /tmp/patch_sddm_rei.py
"""

import shutil
import sys
import os

THEME_DIR = "/usr/share/sddm/themes/reactive"
MAIN_QML = os.path.join(THEME_DIR, "Main.qml")
BACKUP = os.path.join(THEME_DIR, "Main.qml.backup-rei")

if not os.path.exists(MAIN_QML):
    print(f"ERROR: {MAIN_QML} not found. Is the theme installed?")
    sys.exit(1)

if os.geteuid() != 0:
    print("ERROR: This script must be run with sudo (modifies /usr/share/sddm/themes/)")
    sys.exit(1)

# 1. Backup
if not os.path.exists(BACKUP):
    shutil.copy2(MAIN_QML, BACKUP)
    print(f"[1/6] Backup created: {BACKUP}")
else:
    print(f"[1/6] Backup already exists: {BACKUP}")

with open(MAIN_QML, "r") as f:
    lines = f.readlines()

new_lines = []
i = 0
while i < len(lines):
    line = lines[i]

    # 2. Hide clockContainer, sessionContainer, powerControlsPill
    if any(x in line for x in ["id: clockContainer", "id: sessionContainer", "id: powerControlsPill"]):
        new_lines.append(line)
        i += 1
        # Insert visible: false right after the opening brace line
        # The line after id: xxx is usually the opening brace or a property
        # We need to find a good spot — just append after the id line if next line is brace
        if i < len(lines) and "{" in lines[i]:
            new_lines.append(lines[i])
            new_lines.append("        visible: false
")
            i += 1
        else:
            new_lines.append("        visible: false
")
        continue

    # 3. Remove splashText block entirely
    if "// Minecraft style splash text" in line:
        # Skip until we close the Text block
        depth = 0
        while i < len(lines):
            current = lines[i]
            depth += current.count("{")
            depth -= current.count("}")
            i += 1
            if depth <= 0:
                break
        continue

    # 4. Center submitButton vertically (rei-style)
    if "id: submitButton" in line:
        new_lines.append(line)
        i += 1
        # Replace the anchor lines in this block
        while i < len(lines) and not lines[i].strip().startswith("layer.enabled"):
            l = lines[i]
            if "anchors.bottom:" in l and "parent.bottom" in l:
                new_lines.append("        anchors.verticalCenter:           parent.verticalCenter
")
                new_lines.append("        anchors.verticalCenterOffset:     Screen.height * 0.12
")
            elif "anchors.bottomMargin:" in l:
                pass  # skip old bottom margin
            elif "anchors.horizontalCenter:" in l:
                new_lines.append(l)  # keep horizontal center
            else:
                new_lines.append(l)
            i += 1
        continue

    new_lines.append(line)
    i += 1

# 5. Insert avatar block before userContainer
avatar_block = """    // Avatar (rei-style square with rounded corners)
    Rectangle {
        id: avatarContainer

        visible: primaryScreen

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom:           userContainer.top
        anchors.bottomMargin:     Screen.height * 0.02

        width:  120
        height: 120
        radius: 30

        color: matugenTheme.primary || "#c3c6fb"
        border.color: matugenTheme.primary || "#c3c6fb"
        border.width: 3

        Image {
            anchors.fill:    parent
            anchors.margins: 3
            source:          "assets/avatar.png"
            fillMode:        Image.PreserveAspectCrop
            visible:         source !== "" && source !== undefined
        }
    }

"""

# Find the line with "// User Selection" or "id: userContainer" and insert before it
final_lines = []
inserted_avatar = False
for idx, line in enumerate(new_lines):
    if not inserted_avatar and ("// User Selection" in line or "id: userContainer" in line):
        # Walk back to find the blank line before the comment/block
        # Insert avatar block here
        final_lines.append(avatar_block)
        inserted_avatar = True
    final_lines.append(line)

with open(MAIN_QML, "w") as f:
    f.writelines(final_lines)

print("[2/6] Hidden clock, session, and power UI elements")
print("[3/6] Removed splashText (meme text) block")
print("[4/6] Centered login area vertically (rei-style)")
print("[5/6] Added square rounded avatar above username")

# 6. Handle avatar image
avatar_path = os.path.join(THEME_DIR, "assets", "avatar.png")
face_path = os.path.expanduser("~/.face")
if os.path.exists(face_path):
    shutil.copy2(face_path, avatar_path)
    print(f"[6/6] Copied ~/.face to {avatar_path}")
else:
    # Create a placeholder transparent PNG so QML doesn't error
    try:
        from PIL import Image as PILImage
        img = PILImage.new("RGBA", (120, 120), (0, 0, 0, 0))
        img.save(avatar_path)
        print(f"[6/6] Created transparent placeholder at {avatar_path}")
        print("      Tip: Replace it with your avatar: sudo cp ~/Pictures/you.png {avatar_path}")
    except ImportError:
        open(avatar_path, "wb").close()
        print(f"[6/6] Created empty placeholder at {avatar_path}")
        print("      Tip: Replace it with your avatar image")

print("\nDone! Regenerate matugen to apply colors:")
print("  matugen image ~/wallpapers/your-wallpaper.jpg")
print("Then reboot to see the changes.")
