# Quickshell Migration

## Install & Run

```bash
# Arch Linux (AUR)
yay -S quickshell

# Launch
qs
```

## File Layout

```
~/.config/quickshell/
├── qmldir              # Registers Colors singleton
├── Colors.qml          # Palette (matugen will overwrite this)
├── shell.qml           # Entry point
├── Bar.qml             # Main panel window
├── ScriptModule.qml    # Reusable script wrapper
├── Workspaces.qml      # Hyprland native workspaces
├── ArchIcon.qml        # Arch logo
├── VPN.qml             # VPN status + toggle
├── Brightness.qml      # Brightness with color coding
├── DayOfWeek.qml       # Day of week
├── Battery.qml         # Battery status
└── Volume.qml          # Volume with scroll
```

## Matugen Integration

Update your `~/.config/matugen/config.toml`:

```toml
[templates.quickshell]
input_path = '~/.config/matugen/templates/quickshell-colors.qml.template'
output_path = '~/.config/quickshell/Colors.qml'
```

Use the QML singleton template from the previous message. When you change wallpaper, matugen regenerates `Colors.qml` and Quickshell hot-reloads the new palette instantly.

## Module Mapping

| Waybar Module | Quickshell Component | Notes |
|---------------|----------------------|-------|
| `custom/arch` | `ArchIcon.qml` | Image + optional script fallback |
| `custom/vpn` | `VPN.qml` | Reuses `nordvpn-status-simple.sh` / `nordvpn-toggle-simple.sh` |
| `hyprland/workspaces` | `Workspaces.qml` | Native Hyprland IPC, no polling |
| `custom/brightness` | `Brightness.qml` | JSON parsing for color classes + scroll |
| `custom/day-of-week` | `DayOfWeek.qml` | Reuses script |
| `custom/battery` | `Battery.qml` | Reuses script |
| `custom/volume` | `Volume.qml` | Reuses script + scroll |

## What Was Ported

- **Colors**: Exact hex values from your CSS → `Colors.qml`
- **Fonts**: `JetBrainsMono Nerd Font, Noto Sans CJK JP`
- **Padding**: Mapped from CSS `padding` rules to `leftPadding` / `rightPadding`
- **Hover backgrounds**: Per-module hover tints from CSS
- **Workspace icons**: Japanese characters ひ ら や す み
- **Interactions**: Click, scroll, and tooltips preserved via `MouseArea`
