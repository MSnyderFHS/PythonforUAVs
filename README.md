# Classroom SITL Server (ArduPilot + MAVProxy + Web Reset)

This repo documents and automates a **Software-In-The-Loop (SITL)** server used in a high-school course “Python for UAVs”. It provisions:

- **6 parallel ArduCopter SITL instances** (screen sessions `sitl1..sitl6`)
- **6 MAVProxy routers** (screen sessions `proxy1..proxy6`)
- A small **Flask web app** to reset a single team’s simulator on demand
- A consistent **TCP port map** for students (15000, 15010, 15020, 15030, 15040, 15050)
- Optional nginx + systemd service for the web UI

> **Platform:** Ubuntu Server 24.04 LTS used.  

---

## Quick start (fresh VM)

> Run as a non-root sudo user. Replace `SERVER_IP` with your server’s LAN IP.

```bash
sudo apt update
sudo apt -y install git
git clone https://github.com/<your-org>/python-for-uavs-sitl.git
cd python-for-uavs-sitl

# 1) OS & tools
bash scripts/install_vm_prereqs.sh

# 2) Build ArduPilot (SITL)
bash scripts/build_ardupilot.sh

# 3) Configure environment
cp scripts/env.example scripts/.env
# edit scripts/.env to set SERVER_IP, token, etc.

# 4) Start 6 lanes (SITL + MAVProxy screens)
bash scripts/start_control_sitl.sh

# 5) Web reset app (Flask via systemd)
python3 -m venv /opt/sitlweb-venv
source /opt/sitlweb-venv/bin/activate
pip install -r sitlweb/requirements.txt
deactivate
sudo cp systemd/sitlweb.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now sitlweb
