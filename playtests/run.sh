#!/bin/bash
# playtests/run.sh <test.lua> [secs] [chor]
# Copies the app to a scratch dir with the test as scripts/zz_test.lua, runs it
# muted while recording the master bus (CHOR_WAV), then prints levels and timing
# and writes a spectrogram. Needs an engine with CHOR_WAV (petrichor64 main, 13a3dc1+).
# On Hyprland, set HYPRLAND_INSTANCE_SIGNATURE and TEST_WS to run it on a
# hidden headless workspace (see petrichor's AGENTS.md, Testing).
set -e
here=$(cd "$(dirname "$0")/.." && pwd)
test=$(realpath "$1"); secs=${2:-45}; chor=${3:-chor}
out=$(mktemp -d)
rsync -a "$here/" "$out/game/" --exclude .git
cp "$test" "$out/game/scripts/zz_test.lua"
if [ -n "$TEST_WS" ]; then
  printf '#!/bin/sh\nCHOR_WAV=%s/out.wav CHOR_MUTE=1 exec %s %s/game > %s/game.log 2>&1\n' "$out" "$chor" "$out" "$out" > "$out/launch.sh"
  chmod +x "$out/launch.sh"
  hyprctl eval "hl.exec_cmd(\"[workspace $TEST_WS silent] $out/launch.sh\")" >/dev/null
  sleep "$secs"; pkill -f "$out/game" || true
else
  CHOR_WAV="$out/out.wav" CHOR_MUTE=1 timeout "$secs" "$chor" "$out/game" > "$out/game.log" 2>&1 || true
fi
grep -E 'rror|panic|not callable' "$out/game.log" | grep -v fps | head || true
python3 -I "$here/tools/stats.py" "$out/out.wav"
python3 -I "$here/tools/spec.py" "$out/out.wav" "$out/spec.png" > /dev/null
echo "log: $out/game.log  audio: $out/out.wav  spectrogram: $out/spec.png"
