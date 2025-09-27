#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/.env"

# Kill previous sessions
echo "--- Stopping any previous SITL/MAVProxy/screen sessions ---"
pkill -9 arducopter || true
pkill -f mavproxy.py || true
pkill screen || true
sleep 2

# Ensure venv exists for CLI `mavproxy.py` (not required for SITL)
if [ -f "$VENV_PATH" ]; then
  source "$VENV_PATH"
  python3 -m pip install --upgrade pip >/dev/null
  python3 -m pip install MAVProxy >/dev/null
  deactivate || true
fi

echo "--- Launching ${NUM_VEHICLES} ArduCopter SITL instances ---"
for ((i=0; i<NUM_VEHICLES; i++)); do
  TEAM=$((i+1))
  INST=$i
  screen -dmS "sitl${TEAM}" bash -lc "
    cd ${ARDUPILOT_HOME}/ArduCopter && \
    ${ARDUPILOT_HOME}/build/sitl/bin/arducopter \
      -S \
      -I${INST} \
      --model + \
      --speedup 1 \
      --defaults ${ARDUPILOT_HOME}/Tools/autotest/default_params/copter.parm
  "
done

echo "Waiting for SITL to open TCP consoles..."
sleep 8

echo "--- Launching MAVProxy routers ---"
for ((i=0; i<NUM_VEHICLES; i++)); do
  TEAM=$((i+1))
  SITL_UDP_PORT=$((SITL_UDP_BASE + i*10))
  GCS_TCP_PORT=$((GCS_TCP_BASE + i*10))

  screen -dmS "proxy${TEAM}" bash -lc "
    source ${VENV_PATH} 2>/dev/null || true; \
    mavproxy.py \
      --retries=100 \
      --master=udp:127.0.0.1:${SITL_UDP_PORT} \
      --out=tcpin:0.0.0.0:${GCS_TCP_PORT}
  "
done

echo
echo "=== Mapping for students ==="
printf "%-8s %-22s %-22s\n" "Team" "QGC TCP" "Note"
for ((i=0; i<NUM_VEHICLES; i++)); do
  TEAM=$((i+1))
  GCS_TCP_PORT=$((GCS_TCP_BASE + i*10))
  printf "Team %-3s: %s:%-5s   (connect via TCP)\n" "$TEAM" "$SERVER_IP" "$GCS_TCP_PORT"
done

echo
echo "Use 'screen -ls' to list, 'screen -r sitlN'/'proxyN' to attach, Ctrl-A D to detach."
echo "To stop everything: pkill -9 arducopter; pkill -f mavproxy.py; pkill screen"
