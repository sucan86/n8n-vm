
# Einrichtung von n8n auf einer HsH-VM (Ubuntu)

Diese Anleitung beschreibt die Einrichtung von n8n sowie weiterer Dienste wie z. B. Portainer auf einer HsH-VM. Da auf den VMs nur beschränkt Ports freigegeben sind, müssen die Dienste über einen Reverse Proxy (NGINX Proxy Manager) so konfiguriert werden, dass sie von außen über HTTPS (Port 443) erreichbar sind.

---

## 1. Systemupdate durchführen und Docker installieren

Den folgenden Inhalt in eine Datei mit dem Namen **setup.sh** speichern:

```bash
nano setup.sh
```

Anschließend ausführbar machen:

```bash
sudo chmod +x setup.sh
```

Das Script lässt sich nun wie folgt ausführen:

```bash
./setup.sh
```

Starte danach ggf. neu oder führe `newgrp docker` aus, damit die Docker-Gruppe sofort wirksam wird.

**Hinweis:** Das Script setzt eine frische Ubuntu-Installation mit Internetzugang voraus.

---

## 2. Container laden und ausführen

Den folgenden Inhalt in eine Datei mit dem Namen **setup-container.sh** kopieren:

```bash
nano setup-container.sh
```

Anschließend ausführbar machen:

```bash
sudo chmod +x setup-container.sh
```

Script ausführen:

```bash
./setup-container.sh
```

Dabei wird eine `docker-compose.yml` mit Portainer und NGINX Proxy Manager (NPM) erstellt und gestartet. Danach wird das Repository [n8n Self-hosted AI Starter Kit](https://github.com/n8n-io/self-hosted-ai-starter-kit.git) heruntergeladen und mit allen Diensten gestartet.

**Hinweis:** NPM wird mit angepassten Ports gestartet, sodass die Benutzeroberfläche über Port 80 erreichbar ist. 

Ferner beinhaltet die **setup-container.sh** Datei Crediantials, welche unbedingt geändert werrden sollten

Beispielsweise von:
```bash
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

```
zu
```bash
# n8n Settings
N8N_HOST=localhost
N8N_PORT=5678
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=F2LSnK2abTM6raR9Ud

# Postgres
POSTGRES_DB=n8n
POSTGRES_USER=n8ndbuser
POSTGRES_PASSWORD=27Uwk34QPHen6gKX0N
```
---

## 3. Einrichten des NGINX Proxy Manager (Reverse Proxy)

Nach erfolgreicher Einrichtung sollten folgende Subdomains auf die jeweiligen Dienste zeigen:

| Dienst-URL              | Subdomain                 |
|-------------------------|---------------------------|
| http://portainer:8000   | portainer.deinedomaine.de |
| http://n8n:5678         | n8n.deinedomaine.de       |
| http://npm:81           | npm.deinedomaine.de       |

---

### 3.1. Manuelle Schritte in der NGINX Proxy Manager UI

#### 3.1.1. NGINX Proxy Manager öffnen:
- URL: `http://<Deine-IP>:80` (Standard wäre Port 81)
- Standard-Zugangsdaten:
  - Benutzer: `admin@example.com`
  - Passwort: `changeme`
- Nach dem Login: E-Mail-Adresse und Passwort ändern

#### 3.1.2. Neuen Proxy Host hinzufügen:
- Menü: „Proxy Hosts“ → „Add Proxy Host“
- Domain Names: `deinedomaine.de` (z. B. `n8n.deinedomaine.de`)
- Forward Hostname / IP: `n8n` oder `localhost` (sofern im gleichen Docker-Netzwerk)
- Forward Port: `5678`
- Websockets aktivieren: ✔️
- Block Common Exploits: ✔️

#### 3.1.3. SSL aktivieren:
- Tab: **SSL**
- SSL-Zertifikat: „Request a new SSL Certificate“
- E-Mail-Adresse: Deine E-Mail
- Force SSL: ✔️
- HTTP/2 Support: ✔️
- Speichern & starten

#### (Alternative) Einrichtung über Cloudflare:
Eine ausführliche Anleitung findest du hier:  
[HomeLab: Nginx Proxy Manager mit SSL und Cloudflare DNS](https://medium.com/@life-is-short-so-enjoy-it/homelab-nginx-proxy-manager-setup-ssl-certificate-with-domain-name-in-cloudflare-dns-732af64ddc0b)

---

### 3.2. Ports im NPM anpassen und neu starten

Im nächsten Schritt muss der NPM-Container gestoppt werden. Navigiere in das Verzeichnis, in dem sich die Datei `docker-compose.yml` (mit Portainer und NPM) befindet:

```bash
docker compose stop
```

Öffne die Datei mit `nano`:

```bash
nano docker-compose.yml
```

Ändere die Ports von:

```yaml
  ports:
    - "81:80"
    - "80:81"
```

zu:

```yaml
  ports:
    - "80:80"
    - "81:81"
    - "443:443"
```

Dann speichere die Datei und starte die Container neu:

```bash
docker compose up -d
```

---

## 4. Inbetriebnahme von n8n

n8n sollte nun unter folgender Adresse erreichbar sein:

- URL: `https://n8n.deinedomaine.de` (alternativ: `http://<Deine-IP>:5678`)
- Benutzer: `admin`
- Passwort: `admin`
