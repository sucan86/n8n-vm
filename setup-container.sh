#!/bin/bash
set -e

echo "### Verzeichnis für Setup erstellen..."
mkdir -p ~/docker-setup
cd ~/docker-setup

echo "### docker-compose.yml für Portainer und Nginx Manager erstellen..."
cat <<EOF > docker-compose.yml
version: "3.8"
services:
  portainer:
    image: portainer/portainer-ce
    container_name: portainer
    restart: always
    ports:
      - "9000:9000"
      - "8000:8000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data

  nginx-manager:
    image: jc21/nginx-proxy-manager:latest
    container_name: nginx-manager
    restart: always
    ports:
      - "8001:80"
      - "80:81"
      - "443:443"
    volumes:
      - nginx_data:/data
      - nginx_letsencrypt:/etc/letsencrypt

volumes:
  portainer_data:
  nginx_data:
  nginx_letsencrypt:
EOF

echo "### docker-compose für Portainer und Nginx Manager starten..."
docker compose up -d

echo "### Repository n8n Self-Hosted AI Starter Kit herunterladen..."
cd ~
git clone https://github.com/n8n-io/self-hosted-ai-starter-kit.git
cd self-hosted-ai-starter-kit

echo "### .env-Datei erstellen..."
cat <<EOF > .env
# n8n Settings
N8N_HOST=localhost
N8N_PORT=5678
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=admin

# Postgres
POSTGRES_DB=n8n
POSTGRES_USER=n8n
POSTGRES_PASSWORD=n8npassword

# Optional OpenAI Key
OPENAI_API_KEY=

# External URL (optional)
WEBHOOK_URL=http://localhost:5678/
EOF

echo "### docker-compose für n8n-Projekt starten..."
docker compose up -d

echo "### Setup abgeschlossen!"
