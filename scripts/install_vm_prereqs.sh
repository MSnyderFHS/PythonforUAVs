#!/usr/bin/env bash
set -euo pipefail

# Base packages
sudo apt update
sudo apt -y install \
  build-essential clang pkg-config ccache \
  git wget curl unzip tar \
  python3 python3-venv python3-pip python3-dev \
  screen net-tools iproute2 tcpdump \
  libtool libxml2-dev libxslt1-dev \
  libffi-dev libreadline-dev

# MAVProxy deps (will still install via pip in a venv for the web app as needed)
# System pip will remain for your account scripts
pip3 install --upgrade pip

echo "Prereqs installed."
