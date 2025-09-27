# pfSense+ Rules (LAN → Server)

**Allow inbound to the SITL server (LAN interface):**
- Protocol: **TCP**
- Destination: **SITL server IP**
- Ports: **15000–15050**
- Description: QGC/MAVProxy student connections

(If you also expose to a different VLAN/subnet, mirror the rule.)

**We do not expose SITL UDP externally** in this setup. All internal legs are localhost.

**NAT/Firewall gotchas**
- If students connect across VLANs, ensure inter-VLAN firewall allows TCP to 15000–15050.
- If using WAN access (not recommended for class), you must add port-forward + WAN rules with caution.
