#!/bin/bash
# to use arduino-cli for esp32 and arduino uno

set -euo pipefail

BOARD_TYPE="${1:?Error: Board type argument is missing. Usage: $0 <esp32|uno> [port]}"
PORT="${2:-}"

if [ "$BOARD_TYPE" = "esp32" ]; then
    FQBN="esp32:esp32:esp32"
    DEFAULT_PORT="/dev/ttyUSB0"
elif [ "$BOARD_TYPE" = "uno" ]; then
    FQBN="arduino:avr:uno"
    DEFAULT_PORT="/dev/ttyACM0"
else
    echo "Error: Unsupported board type '$BOARD_TYPE'. Use 'esp32' or 'uno'." >&2
    exit 1
fi

PORT="${PORT:-$DEFAULT_PORT}"
SKETCH="."

arduino-cli compile --fqbn "$FQBN" "$SKETCH"
arduino-cli upload -p "$PORT" --fqbn "$FQBN" "$SKETCH"
