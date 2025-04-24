import os
import requests
import json
from datetime import datetime

DATA_PATH = "/data/last_ip.txt"
TOKEN = os.getenv("HASSIO_TOKEN", "")
ADDON_OPTIONS_URL = "http://localhost:80/options"

def get_addon_options():
    headers = {
        "Authorization": f"Bearer {TOKEN}",
        "Content-Type": "application/json"
    }
    response = requests.get(ADDON_OPTIONS_URL, headers=headers)
    response.raise_for_status()
    return response.json()

def get_public_ip():
    try:
        response = requests.get("https://ipinfo.io/json", timeout=10)
        response.raise_for_status()
        return response.json()["ip"]
    except Exception as e:
        print(f"Fehler beim Abrufen der öffentlichen IP von ipinfo.io: {e}")
        return None

def get_last_ip():
    if os.path.exists(DATA_PATH):
        with open(DATA_PATH, "r") as f:
            return f.read().strip()
    return None

def save_current_ip(ip):
    with open(DATA_PATH, "w") as f:
        f.write(ip)

def get_record_id(headers, record_name):
    records = requests.get("https://dns.hetzner.com/api/v1/records", headers=headers).json()
    for record in records['records']:
        if record['name'] == record_name:
            return record['id'], record['type'], record['zone_id']
    raise Exception(f"Record {record_name} not found.")

def update_record(record_id, zone_id, record_type, name, ip, headers):
    update_url = f"https://dns.hetzner.com/api/v1/records/{record_id}"
    payload = {
        "value": ip,
        "ttl": 60,
        "type": record_type,
        "name": name,
        "zone_id": zone_id
    }
    r = requests.put(update_url, headers=headers, data=json.dumps(payload))
    r.raise_for_status()
    print(f"Updated {name} to {ip}")

def main():
    print(f"[{datetime.now()}] Starte Hetzner IP Updater...")
    opts = get_addon_options()
    token = opts['hetzner_token']
    zone = opts['dns_zone']
    record_name = opts['dns_record_name']
    
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }

    current_ip = get_public_ip()
    last_ip = get_last_ip()

    if current_ip == last_ip:
        print(f"IP hat sich nicht geändert ({current_ip}) – kein Update notwendig.")
        return

    print("IP hat sich geändert, aktualisiere DNS...")
    record_id, record_type, zone_id = get_record_id(headers, record_name.split('.')[0])
    update_record(record_id, zone_id, record_type, record_name.split('.')[0], current_ip, headers)
    save_current_ip(current_ip)

if __name__ == "__main__":
    main()
