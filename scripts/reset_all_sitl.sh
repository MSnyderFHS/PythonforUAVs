#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/.env"

for TEAM in $(seq 1 ${NUM_VEHICLES}); do
  "${SCRIPT_DIR}/reset_one_sitl.sh" "$TEAM"
done
