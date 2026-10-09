#!/usr/bin/env python3
import os
import re
import colorsys

def hex_to_hls(hex_color):
    hex_color = hex_color.lstrip('#')
    r = int(hex_color[0:2], 16) / 255.0
    g = int(hex_color[2:4], 16) / 255.0
    b = int(hex_color[4:6], 16) / 255.0
    h, l, s = colorsys.rgb_to_hls(r, g, b)
    return h, l, s

def hls_to_hex(h, l, s):
    r, g, b = colorsys.hls_to_rgb(h, l, s)
    return '#{:02x}{:02x}{:02x}'.format(int(r*255), int(g*255), int(b*255))

def lighten(hex_color, amount=0.18):
    h, l, s = hex_to_hls(hex_color)
    new_l = min(0.96, l + amount)
    return hls_to_hex(h, new_l, s)

def main():
    wal_path = os.path.expanduser("~/.cache/wal/colors-kitty.conf")
    out_path = os.path.expanduser("~/.config/kitty/colors-matugen.conf")

    if not os.path.exists(wal_path):
        print(f"Error: {wal_path} not found. Run wal first.")
        return

    with open(wal_path, 'r') as f:
        lines = f.readlines()

    new_lines = []
    for line in lines:
        line = line.strip()
        if not line or line.startswith('#'):
            new_lines.append(line)
            continue

        # Match color definitions: color0 #hex, background #hex, etc.
        match = re.match(r'^(\w+)\s+(#[0-9a-fA-F]{6})$', line)
        if match:
            name, hex_val = match.groups()
            # Lighten all colors except background and foreground
            if name in ('background', 'cursor', 'cursor_text_color'):
                new_lines.append(f"{name} {hex_val}")
            elif name == 'foreground':
                # Slightly brighten foreground for readability
                new_lines.append(f"{name} {lighten(hex_val, 0.08)}")
            else:
                new_lines.append(f"{name} {lighten(hex_val, 0.18)}")
        else:
            new_lines.append(line)

    with open(out_path, 'w') as f:
        f.write('
'.join(new_lines) + '
')

    print(f"Lightened colors written to {out_path}")

if __name__ == '__main__':
    main()
