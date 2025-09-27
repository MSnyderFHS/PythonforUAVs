#!/usr/bin/env bash
# Reset one team lane: kills SITL+MAVProxy screens, restarts them.
set -euo pipefail
if [ $# -ne 1 ]; then
  echo "Usage: $0 <team-number-1..6>"
  exit 1
fi
TEAM="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/.env"

INST=$((TEAM-1))
SITL_UDP_PORT=$((SITL_UDP_BASE + INST*10))
GCS_TCP_PORT=$((GCS_TCP_BASE + INST*10))

# Kill old screens
screen -S "proxy${TEAM}" -X quit || true
screen -S "sitl${TEAM}"  -X quit || true
sleep 1

# Restart SITL
screen -dmS "sitl${TEAM}" bash -lc "
  cd ${ARDUPILOT_HOME}/ArduCopter && \
  ${ARDUPILOT_HOME}/build/sitl/bin/arducopter \
    -S -I${INST} --model + --speedup 1 \
    --defaults ${ARDUPILOT_HOME}/Tools/autotest/default_params/copter.parm
"
sleep 5

# Restart MAVProxy
screen -dmS "proxy${TEAM}" bash -lc "
  source ${VENV_PATH} 2>/dev/null || true; \
  mavproxy.py --retries=100 \
    --master=udp:127.0.0.1:${SITL_UDP_PORT} \
    --out=tcpin:0.0.0.0:${GCS_TCP_PORT}
"

echo "Team ${TEAM} reset complete (TCP ${GCS_TCP_PORT})."
