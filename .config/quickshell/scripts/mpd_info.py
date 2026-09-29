#!/usr/bin/env python3
import subprocess, json, os, sys

home = os.path.expanduser("~")
art_path = f"{home}/.config/quickshell/current_art.jpg"

def mpc(*args):
    return subprocess.run(["mpc", *args], capture_output=True, text=True)

# Get current song info
title = mpc("-f", "%title%").stdout.strip()
artist = mpc("-f", "%artist%").stdout.strip()
album = mpc("-f", "%album%").stdout.strip()
file_path = mpc("-f", "%file%").stdout.strip()

if not file_path:
    print(json.dumps({"title":"","artist":"","album":"","art":"","status":"stopped","elapsed":0,"duration":0,"pct":0}))
    sys.exit(0)

# Find album art
music_dir = f"{home}/Music"
full_path = os.path.join(music_dir, file_path)
song_dir = os.path.dirname(full_path)

art = ""
for name in ["cover.jpg", "folder.jpg", "album.jpg", "front.jpg", "Cover.jpg", "Folder.jpg"]:
    candidate = os.path.join(song_dir, name)
    if os.path.isfile(candidate):
        art = candidate
        break

# Extract embedded art if no file found
if not art and os.path.isfile(full_path):
    subprocess.run(["ffmpeg", "-y", "-i", full_path, "-an", "-vcodec", "copy", art_path],
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    if os.path.isfile(art_path):
        art = art_path

# Get status
status_lines = mpc("status").stdout.strip().split("\n")
status = "stopped"
elapsed = 0
duration = 1
pct = 0

if len(status_lines) >= 2:
    parts = status_lines[1].split()
    if len(parts) >= 3:
        status = parts[0].strip("[]")
        time_part = parts[2]
        if "/" in time_part:
            el, dur = time_part.split("/")
            def to_sec(t):
                try:
                    m, s = map(int, t.split(":"))
                    return m * 60 + s
                except: return 0
            elapsed = to_sec(el)
            duration = max(to_sec(dur), 1)
            pct = elapsed / duration

print(json.dumps({
    "title": title or "Unknown",
    "artist": artist or "Unknown Artist",
    "album": album or "",
    "art": art,
    "status": status,
    "elapsed": elapsed,
    "duration": duration,
    "pct": round(pct, 3)
}))
