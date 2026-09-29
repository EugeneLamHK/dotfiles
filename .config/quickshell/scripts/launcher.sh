#!/bin/bash

apps_dirs=(
    /usr/share/applications
    "$HOME/.local/share/applications"
)

for dir in "${apps_dirs[@]}"; do
    [ -d "$dir" ] || continue
    for file in "$dir"/*.desktop; do
        [ -f "$file" ] || continue
        
        name=$(grep "^Name=" "$file" | head -n1 | cut -d= -f2-)
        exec=$(grep "^Exec=" "$file" | head -n1 | cut -d= -f2-)
        icon=$(grep "^Icon=" "$file" | head -n1 | cut -d= -f2-)
        hidden=$(grep "^NoDisplay=" "$file" | head -n1 | cut -d= -f2-)
        terminal=$(grep "^Terminal=" "$file" | head -n1 | cut -d= -f2-)
        
        [ "$hidden" = "true" ] && continue
        [ -z "$name" ] && continue
        [ -z "$exec" ] && continue
        
        exec_clean=$(echo "$exec" | sed 's/%[fFuUikv]//g' | sed 's/ *$//')
        
        printf '{"name":"%s","exec":"%s","icon":"%s"}\n' \
            "$(echo "$name" | sed 's/"/\\"/g')" \
            "$(echo "$exec_clean" | sed 's/"/\\"/g')" \
            "$(echo "$icon" | sed 's/"/\\"/g')"
    done
done
