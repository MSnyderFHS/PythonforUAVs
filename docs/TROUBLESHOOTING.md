# Troubleshooting

## QGC "Socket operation timed out"
- Verify server reachable: `ping SERVER_IP`.
- Check TCP listening ports: `ss -ltn | grep 1500`
- Ensure pfSense rule allows TCP to 15000–15050 (see pfSense_RULES.md).
- Restart a lane: use the web UI or `bash scripts/reset_one_sitl.sh 1`.

## MAVProxy cannot connect (no heartbeat)
- Confirm SITL screen is running: `screen -ls` → `sitlN` present.
- Check SITL logs: `screen -r sitlN` (Ctrl-A D to detach).
- Verify internal UDP: `ss -lun | grep 1455` (should show 14550/60/…).

## Permission denied when web app runs reset script
- Ensure script is executable and readable by service user:
  `chmod 755 scripts/reset_one_sitl.sh`
- Confirm `User=` in systemd matches your login (`cyber`).
- If `/home` mounted `noexec`, move script to `/usr/local/bin/`.

## ADSB module missing in MAVProxy logs
- Harmless. We don’t need the `adsb` module. Ignore.

## Build errors (waf) about empy/pexpect
- Install Python deps:
  `python3 -m pip install --user empy==3.3.4 pexpect`
- Then re-run:
  `./waf configure --board sitl && ./waf copter`

## No UDP packets on 14550 from containers
- We don’t use Docker here. On this VM approach, TCP 15000+ is what students use.

