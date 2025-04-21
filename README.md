# HomeAssistantHetznerDynDns
HomeAssistant Addon Hetzner DynDns


# Home Assistant Add-on: Hetzner IP Updater

Dieses Add-on aktualisiert deine öffentliche IP-Adresse bei Hetzner DNS automatisch.

## 🔧 Konfiguration

Füge in der `config.yaml` deine Daten ein:

```yaml
options:
  hetzner_token: "YOUR_HETZNER_API_TOKEN"
  dns_zone: "example.com"
  dns_record_name: "home.example.com"
