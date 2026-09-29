#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../../caching.sh"
qs_ensure_cache "music"

STATE_FILE="$QS_RUN_MUSIC/eq_state.json"
PRESET_DIR="$HOME/.local/share/easyeffects/output"
PRESET_NAME="live_eq"
PRESET_FILE="$PRESET_DIR/${PRESET_NAME}.json"

mkdir -p "$PRESET_DIR"

if ! pgrep -f "easyeffects --gapplication-service" >/dev/null; then
    easyeffects --gapplication-service >/dev/null 2>&1 &
    sleep 2
fi

if [ ! -f "$STATE_FILE" ]; then
 echo '{"b1":0,"b2":0,"b3":0,"b4":0,"b5":0,"b6":0,"b7":0,"b8":0,"b9":0,"b10":0,"preset":"Flat","pending":false}' > "$STATE_FILE"
fi

save_preset() {
  echo "{\"b1\":$1,\"b2\":$2,\"b3\":$3,\"b4\":$4,\"b5\":$5,\"b6\":$6,\"b7\":$7,\"b8\":$8,\"b9\":$9,\"b10\":${10},\"preset\":\"${11}\",\"pending\":false}" > "$STATE_FILE"
}

apply_eq() {
 python3 -c "
import sys, json
try:
 with open('$STATE_FILE', 'r') as f:
   data = json.load(f)
 preset_name = data.get('preset', 'Flat')

 # Initialize all 32 bands to zero
 bands = {}
 for i in range(32):
   bands[f'band{i}'] = {'frequency': 100.0, 'gain': 0.0, 'mode': 'Bell', 'mute': False, 'q': 1.0, 'solo': False, 'slope': 'x1', 'width': 1.0}

 if preset_name == 'Reference':
   # Hisenior Mega5-EST Filters (1).txt — 6 exact parametric filters
   bands['band0']  = {'frequency': 24.0,   'gain': -3.3, 'mode': 'Bell', 'mute': False, 'q': 0.4, 'solo': False, 'slope': 'x1', 'width': 1.0}
   bands['band10'] = {'frequency': 350.0,  'gain':  0.8, 'mode': 'Bell', 'mute': False, 'q': 1.0, 'solo': False, 'slope': 'x1', 'width': 1.0}
   bands['band15'] = {'frequency': 1100.0, 'gain': -1.2, 'mode': 'Bell', 'mute': False, 'q': 1.2, 'solo': False, 'slope': 'x1', 'width': 1.0}
   bands['band19'] = {'frequency': 2700.0, 'gain':  1.0, 'mode': 'Bell', 'mute': False, 'q': 3.0, 'solo': False, 'slope': 'x1', 'width': 1.0}
   bands['band22'] = {'frequency': 4800.0, 'gain':  1.9, 'mode': 'Bell', 'mute': False, 'q': 6.7, 'solo': False, 'slope': 'x1', 'width': 1.0}
   bands['band23'] = {'frequency': 5900.0, 'gain': -2.4, 'mode': 'Bell', 'mute': False, 'q': 5.6, 'solo': False, 'slope': 'x1', 'width': 1.0}
   input_gain = -1.5961

 elif preset_name == 'Mega7':
   # Hisenior Mega5-EST Filters.txt — 7 exact parametric filters
   bands['band0']  = {'frequency': 20.0,   'gain':  1.4, 'mode': 'Bell', 'mute': False, 'q': 0.9, 'solo': False, 'slope': 'x1', 'width': 1.0}
   bands['band5']  = {'frequency': 110.0,  'gain': -1.4, 'mode': 'Bell', 'mute': False, 'q': 1.0, 'solo': False, 'slope': 'x1', 'width': 1.0}
   bands['band9']  = {'frequency': 290.0,  'gain':  0.9, 'mode': 'Bell', 'mute': False, 'q': 1.4, 'solo': False, 'slope': 'x1', 'width': 1.0}
   bands['band14'] = {'frequency': 730.0,  'gain': -0.7, 'mode': 'Bell', 'mute': False, 'q': 2.4, 'solo': False, 'slope': 'x1', 'width': 1.0}
   bands['band19'] = {'frequency': 2500.0, 'gain':  1.4, 'mode': 'Bell', 'mute': False, 'q': 2.5, 'solo': False, 'slope': 'x1', 'width': 1.0}
   bands['band21'] = {'frequency': 3600.0, 'gain': -1.9, 'mode': 'Bell', 'mute': False, 'q': 3.3, 'solo': False, 'slope': 'x1', 'width': 1.0}
   bands['band22'] = {'frequency': 4800.0, 'gain':  0.8, 'mode': 'Bell', 'mute': False, 'q': 7.1, 'solo': False, 'slope': 'x1', 'width': 1.0}
   input_gain = -1.3541

 else:
   # Standard 10-slider graphic EQ mapping
   slider_to_band = {0:0, 1:3, 2:6, 3:9, 4:12, 5:15, 6:18, 7:21, 8:24, 9:27}
   freqs = [32,40,50,63,80,100,125,160,200,250,315,400,500,630,800,1000,1250,1600,2000,2500,3150,4000,5000,6300,8000,10000,12500,16000,20000,22000,24000,24000]
   gains = [data['b1'], data['b2'], data['b3'], data['b4'], data['b5'], data['b6'], data['b7'], data['b8'], data['b9'], data['b10']]
   for i in range(32):
     freq = freqs[i] if i < len(freqs) else 20000.0
     gain = 0.0
     for s_idx, b_idx in slider_to_band.items():
       if i == b_idx:
         gain = gains[s_idx]
         break
     bands[f'band{i}'] = {'frequency':freq,'gain':gain,'mode':'Bell','mute':False,'q':1.0,'solo':False,'slope':'x1','width':1.0}
   input_gain = 0.0

 preset = {
   'input': {'blocklist':[],'plugins_order':[]},
   'output': {
     'blocklist':[],
     'plugins_order':['equalizer'],
     'equalizer': {
       'bypass':False,'input-gain':input_gain,'output-gain':0.0,
       'mode':'IIR','num-bands':32,'split-channels':False,
       'left':bands,'right':bands
     }
   }
 }
 with open('$PRESET_FILE', 'w') as f:
   json.dump(preset, f, indent=2)
except Exception as e:
 print(str(e), file=sys.stderr)
 sys.exit(1)
"

 easyeffects -l "$PRESET_NAME" >/dev/null 2>&1
}

cmd=$1; arg1=$2; arg2=$3

case $cmd in
 "get") cat "$STATE_FILE" ;;
 "set_band")
   tmp=$(cat "$STATE_FILE")
   updated=$(echo "$tmp" | jq -c --arg val "$arg2" ".b$arg1 = \$val | .preset = \"Custom\" | .pending = true")
   echo "$updated" > "$STATE_FILE"
 ;;
 "apply")
   tmp=$(cat "$STATE_FILE")
   updated=$(echo "$tmp" | jq -c ".pending = false")
   echo "$updated" > "$STATE_FILE"
   apply_eq
 ;;
 "preset")
   case $arg1 in
     "Flat")      save_preset 0  0  0  0  0  0  0  0  0  0  "Flat" ;;
     "Bass")      save_preset 5  7  5  2  1  0  0  0  1  2  "Bass" ;;
     "Mega7")     save_preset 1  0 -1  1 -1  0  1 -2  1  0  "Mega7" ;;
     "Vocal")     save_preset -2 -1 1  3  5  5  4  2  1  0  "Vocal" ;;
     "Pop")       save_preset 2  4  2  0  1  2  4  2  1  2  "Pop" ;;
     "Rock")      save_preset 5  4  2 -1 -2 -1 2  4  5  6  "Rock" ;;
     "Reference") save_preset -3 0  0  1  0 -1 1  2 -2  0  "Reference" ;;
     "Classic")   save_preset 0  1  2  2  2  2  1  2  3  4  "Classic" ;;
   esac
   apply_eq
 ;;
esac
