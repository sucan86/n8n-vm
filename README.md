# Einrichtung von n8n auf einer HsH-VM (Ubuntu)

Der folgende Einleitung soll das Einrichten von n8n und weiteren Diensten wie. u.a. Portainer für HsH-VMs erleitern. Für die VMs sind nur beschränkte Ports offen und müssen daher mittels eines Reverse Proxy (NGINX Proxy Manager) angepasst werden, sodass auch alle Dienste nach außen über HTTPS (Port 443) erreichbar sind.


## 1. Systemupdate durchführen und Docker installieren

Den Inhalt der **setup.sh** in eine Datei speichern

```bash
nano setup.sh
```

und anschließend ausführbar machen.

```bash
sudo chmod +x setup.sh
```

Abschließend lässt sich das Script kopieren

```bash
 ./setup.sh 
 ```

Starte danach ggf. einmal neu oder führe newgrp docker aus, damit die Docker-Gruppe sofort wirksam wird.

**Hinweis:** Das Script erwartet eine frische Ubuntu-Installation mit Internetzugan


## 2. Container laden und ausführen

Den Inhalt der **setup-container.sh** in eine Datei kopieren

```bash
nano setup-container.sh
```

und anschließend ausführbar machen.

```bash
sudo chmod +x setup-container.sh
```

Abschließend lässt sich das Script ausführen
```bash
 ./setup-container.sh 
 ```

Es wird nun eine docker-compose.yml mit Portainer und NGINX Proxy Manager (NPM) erstellt und und ausgeführt. Im zweiten Schritt wird das Repository [n8n Self-hosted AI starter kit](https://github.com/n8n-io/self-hosted-ai-starter-kit.git) heruntergeladen und mit allen Diensten gestartet.

**Hinweis:** NPM wird mit veränderten Ports gestarte damit die Nginx Proxy Manager UI über den Port 80 erreichbar ist.

## 3. Einrichten NGINX Proxy Manager (Reverse Proxy)

Ziel nach erfolgreicher Einrichtung sollte es sein, dass folgende Subdomains die folgenden Dienste ansprechen und darüber erreichbar sind.

| Konfiguration         | Subdomain                 |
|-----------------------|---------------------------|
http://portainer:8000   | portainer.deinedomaine.de |
http://n8n:5678         | n8n.deinedomaine.de       |
http://npm:81           | npm.deinedomaine.de       |


### 3.1. Manuelle Schritte im Nginx Proxy Manager UI

#### 3.1.1. Öffne Nginx Proxy Manager (NPM):
- URL: http://< Deine-IP >:80 (Normalzustand wäre Port 81)
- Default Login:
    - Benutzer: admin@example.com
    - Passwort: changeme
- Nach dem Login Passwort & Mail ändern

#### 3.1.2. Neuen Proxy Host hinzufügen:
- Menü: "Proxy Hosts" → "Add Proxy Host"
Domain Names: deinedomain.de (z. B. n8n.deinedomaine.de)
- Forward Hostname / IP: n8n oder localhost (wenn n8n im  gleichen Docker-Netzwerk ist)
- Forward Port: 5678
- Websockets aktivieren: ✔️ Websockets Support aktivieren
- Block Common Exploits: ✔️

#### 3.1.3. SSL aktivieren:
- Tab: SSL
- SSL Certificate: "Request a new SSL Certificate"
- Email: Deine Mailadresse
- Force SSL: ✔️ aktivieren
- HTTP/2 Support: ✔️ aktivieren
- Speichern & starten

#### (Alternative) NPM mit Cloudflare einrichten
Eine ausführliche Einleitung findet sich im folgenden Beitrag:  
[HomeLab: Nginx-Proxy-Manager: Setup SSL Certificate with Domain Name in Cloudflare DNS](https://medium.com/@life-is-short-so-enjoy-it/homelab-nginx-proxy-manager-setup-ssl-certificate-with-domain-name-in-cloudflare-dns-732af64ddc0b)


### 3.2. NPM-Port anpassen und neustarten
Im nächsten Schritt müssen Sie den Container NPM stoppen. Hierzu müssen Sie sich im Verzeichnes befinden, wo auch die Datei *docker-compose.yml* mit portainer und npm zufinden ist.

```bash
docker compose stop
```

Die Datei mit *nano* editieren

```bash
nano docker-compose.yml
```

den Port für NPM von 80 in 81 und 8001 in 80 (Normalzustand) abändern und die Datei speichern

```bash
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
```

Abschließend die beiden Container erneut starten

```bash
docker compose stop -d
```


## 4. Inbetriebnehmen von n8n

n8n sollte nun unter
- URL: https://n8n.deinedomaine.de (http://< Deine-IP >:5678)
- Benutzer: admin
- Passwort: admin

erreichbar sein.

