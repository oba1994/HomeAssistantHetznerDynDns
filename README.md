# Home Assistant Add-on: Hetzner IP Updater

Dieses Add-on aktualisiert deine öffentliche IP-Adresse bei Hetzner DNS – aber **nur**, wenn sich die IP geändert hat.

## 🔧 Konfiguration

In `config.yaml` kannst du folgende Optionen setzen:

```yaml
options:
  hetzner_token: "YOUR_HETZNER_API_TOKEN"
  zone_name: "example.com"
  record_name: "home"
```

## 🔁 Automatisch jede Stunde starten

Mit einer Home Assistant Automatisierung regelmäßig starten:
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

