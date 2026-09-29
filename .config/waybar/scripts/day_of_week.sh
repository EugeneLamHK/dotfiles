#!/bin/bash

# Get the current day of week in Japanese (works with any locale)
# Using %u gives day number: 1=Monday, 7=Sunday
day_num=$(date +%u)

case $day_num in
    1) echo "月曜日" ;;
    2) echo "火曜日" ;;
    3) echo "水曜日" ;;
    4) echo "木曜日" ;;
    5) echo "金曜日" ;;
    6) echo "土曜日" ;;
    7) echo "日曜日" ;;
esac
