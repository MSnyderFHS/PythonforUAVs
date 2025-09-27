# Port Map

- Student TCP (QGC/MAVProxy):
  - Team 1 → 15000
  - Team 2 → 15010
  - Team 3 → 15020
  - Team 4 → 15030
  - Team 5 → 15040
  - Team 6 → 15050
- ArduPilot SITL instance TCP consoles (internal):
  - Instance 0 → 5770
  - Instance 1 → 5780
  - Instance 2 → 5790
  - … (SITL also opens 5772/5773 etc. for additional serials)
- ArduPilot SITL MAVLink UDP (internal, localhost):
  - Instance 0 → 14550
  - Instance 1 → 14560
  - Instance 2 → 14570
  - …
