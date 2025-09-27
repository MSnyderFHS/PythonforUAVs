#!/usr/bin/env bash
set -euo pipefail

AP_DIR="$HOME/ardupilot"
if [ ! -d "$AP_DIR" ]; then
  git clone https://github.com/ArduPilot/ardupilot.git "$AP_DIR"
fi

cd "$AP_DIR"
git submodule update --init --recursive

# Python tooling for waf
python3 -m pip install --user empy==3.3.4 pexpect

# Configure & build SITL
./waf configure --board sitl
./waf copter

echo "ArduPilot SITL build complete: $AP_DIR/build/sitl/bin/arducopter"
