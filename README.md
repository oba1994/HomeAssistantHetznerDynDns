# Home Assistant Add-on: Hetzner IP Updater

Dieses Add-on aktualisiert deine öffentliche IP-Adresse stündlich bei Hetzner DNS – aber **nur**, wenn sich die IP geändert hat.

## 🔧 Konfiguration

In `config.yaml` kannst du folgende Optionen setzen:

```yaml
options:
  hetzner_token: "YOUR_HETZNER_API_TOKEN"
  dns_zone: "example.com"
  dns_record_name: "home.example.com"
```

## 🛠 Installation

1. Kopiere dieses Verzeichnis in deinen Home Assistant `addons` Ordner.
2. Gehe zu Supervisor → Add-on Store → mit lokalen Add-ons neu laden.
3. Installiere und starte das Add-on.

## 🔁 Automatisch jede Stunde starten

Entweder:

- Das Add-on dauerhaft laufen lassen (es prüft intern jede Stunde).
- Oder mit einer Home Assistant Automatisierung regelmäßig starten:
  ```yaml
  alias: Hetzner IP stündlich aktualisieren
  trigger:
    - platform: time_pattern
      minutes: "0"
  action:
    - service: hassio.addon_start
      data:
        addon: local_hetzner_ip_updater
  ```

