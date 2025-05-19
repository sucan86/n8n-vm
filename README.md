# Einrichtung n8n auf einer VM (ubuntu)

Den Inhalt der setup.sh in eine Datei speichern

```bash
nano setup.sh
```

und anschließend ausführbar machen.

```bash
sudo chmod +x setup.sh
```

Abschließend lässt sich das Script ausführen
```bash
 ./setup.sh 
 ```
 

Starte danach ggf. einmal neu oder führe newgrp docker aus, damit die Docker-Gruppe sofort wirksam wird.

**Hinweis:**
Das Script erwartet eine frische Ubuntu-Installation mit Internetzugan

## Zugangsdaten für n8n
n8n sollte nun unter
- URL: http://<Deine-IP>:5678
- Benutzer: admin
- Passwort: admin

erreichbar sein.

Um n8n über den Nginx Proxy Manager (NPM) mit SSL abzusichern, brauchst du:

Eine Domain, die auf die öffentliche IP deines Servers zeigt.
Ports 80 und 443 freigegeben (z. B. in der Firewall oder Cloud-Konsole).
Eine angepasste Konfiguration im NPM-UI.
Hier sind die Schritte nach dem Setup aus deinem Script:

## Manuelle Schritte im Nginx Proxy Manager UI
#### Öffne Nginx Proxy Manager:
- URL: http://<Deine-IP>:81
- Default Login:
-- Benutzer: admin@example.com
-- Passwort: changeme
- Nach dem Login Passwort & Mail ändern

#### Neuen Proxy Host hinzufügen:
- Menü: "Proxy Hosts" → "Add Proxy Host"
Domain Names: deinedomain.de (z. B. n8n.suatcan.de)
- Forward Hostname / IP: n8n oder localhost (wenn n8n im  gleichen Docker-Netzwerk ist)
- Forward Port: 5678
- Websockets aktivieren: ✔️ Websockets Support aktivieren
- Block Common Exploits: ✔️

#### SSL aktivieren:
- Tab: SSL
- SSL Certificate: "Request a new SSL Certificate"
- Email: Deine Mailadresse
- Force SSL: ✔️ aktivieren
- HTTP/2 Support: ✔️ aktivieren
- Speichern & starten