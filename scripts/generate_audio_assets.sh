#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
AUDIO_DIR="$ROOT_DIR/assets/audio"
TMP_DIR="${TMPDIR:-/tmp}/resora_audio_build"

mkdir -p "$AUDIO_DIR" "$TMP_DIR"

generate_ambient() {
  local output="$1"
  local source="$2"
  local filter="$3"

  ffmpeg -y \
    -f lavfi -i "$source" \
    -af "$filter" \
    -c:a libmp3lame -b:a 96k \
    "$output" >/dev/null 2>&1
}

generate_pad() {
  local output="$1"
  local seconds="$2"
  shift 2
  local wav_path="$TMP_DIR/${output:t:r}.wav"

  sox -n -r 44100 -c 1 "$wav_path" synth "$seconds" "$@" >/dev/null 2>&1
  ffmpeg -y \
    -i "$wav_path" \
    -af "highpass=f=70,lowpass=f=2200,volume=1.2" \
    -ar 44100 \
    -c:a libmp3lame -b:a 96k \
    "$output" >/dev/null 2>&1
}

generate_ambient \
  "$AUDIO_DIR/ambient_soft_rain.mp3" \
  "anoisesrc=color=pink:duration=78:sample_rate=44100:amplitude=0.5" \
  "highpass=f=650,lowpass=f=6800,volume=0.16"

generate_ambient \
  "$AUDIO_DIR/ambient_brown_noise.mp3" \
  "anoisesrc=color=brown:duration=115:sample_rate=44100:amplitude=0.55" \
  "lowpass=f=1400,volume=0.2"

generate_pad \
  "$AUDIO_DIR/guided_exhale.mp3" \
  "48" \
  sine 220 sine 330 gain -24 tremolo 4 28 fade q 1 48 3 reverb 24 55 45

generate_pad \
  "$AUDIO_DIR/guided_parenting_calm.mp3" \
  "60" \
  sine 196 sine 294 gain -24 fade q 1 60 3 reverb 28 60 45

generate_pad \
  "$AUDIO_DIR/reset_breath_reset.mp3" \
  "30" \
  sine 261.6 sine 329.6 gain -25 tremolo 5 22 fade q 1 30 2 reverb 18 45 35

generate_pad \
  "$AUDIO_DIR/reset_step_away.mp3" \
  "26" \
  sine 174.6 sine 261.6 gain -25 fade q 1 26 2 reverb 20 48 36

generate_pad \
  "$AUDIO_DIR/reset_ground_54321.mp3" \
  "34" \
  sine 293.7 sine 392 gain -26 tremolo 6 18 fade q 1 34 2 reverb 16 40 32

generate_pad \
  "$AUDIO_DIR/reset_box_breath.mp3" \
  "40" \
  sine 246.9 sine 329.6 gain -25 tremolo 4 30 fade q 1 40 2 reverb 18 44 34

generate_pad \
  "$AUDIO_DIR/reset_cold_water.mp3" \
  "24" \
  sine 440 sine 659.3 gain -28 fade q 0.8 24 1.5 reverb 12 35 24

generate_pad \
  "$AUDIO_DIR/rehearse_partner_after_hard_night.mp3" \
  "36" \
  sine 185 sine 277.2 gain -26 fade q 1 36 2 reverb 18 46 36

generate_pad \
  "$AUDIO_DIR/rehearse_setting_limit.mp3" \
  "34" \
  sine 207.7 sine 311.1 gain -26 fade q 1 34 2 reverb 18 44 34

generate_pad \
  "$AUDIO_DIR/rehearse_ask_for_need.mp3" \
  "32" \
  sine 220 sine 349.2 gain -26 fade q 1 32 2 reverb 18 42 34

generate_pad \
  "$AUDIO_DIR/rehearse_repair_after_temper.mp3" \
  "32" \
  sine 196 sine 293.7 gain -26 fade q 1 32 2 reverb 18 42 34

generate_pad \
  "$AUDIO_DIR/rehearse_hard_conversation_work.mp3" \
  "34" \
  sine 233.1 sine 349.2 gain -26 fade q 1 34 2 reverb 18 44 34

printf 'Generated audio assets in %s\n' "$AUDIO_DIR"
