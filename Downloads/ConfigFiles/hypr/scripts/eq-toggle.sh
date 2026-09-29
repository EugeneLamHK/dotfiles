#!/bin/bash
TOGGLE_FILE="$HOME/.local/state/quickshell/eq_toggle"
mkdir -p "$(dirname "$TOGGLE_FILE")"

# Toggle the file between 0 and 1
if [ ! -f "$TOGGLE_FILE" ] || [ "$(cat "$TOGGLE_FILE" 2>/dev/null)" = "0" ]; then
    echo 1 > "$TOGGLE_FILE"
else
    echo 0 > "$TOGGLE_FILE"
fi

# Start quickshell daemon if not running
if ! pgrep -f "quickshell.*main.qml" >/dev/null; then
    quickshell -p "$HOME/.config/hypr/scripts/quickshell/main.qml" >/dev/null 2>&1 &
    disown
fi
