#!/bin/bash
set -e

echo "### System aktualisieren..."
sudo apt update && sudo apt upgrade -y

echo "### Docker installieren..."
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "### Docker Compose CLI aktivieren..."
sudo usermod -aG docker $USER
newgrp docker


echo "### Installation von Docker abgeschlossen!"
