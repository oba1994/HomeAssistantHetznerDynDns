import os
import requests
import json

DATA_PATH = "/data/last_ip.txt"

def get_last_ip():
    if os.path.exists(DATA_PATH):
        with open(DATA_PATH, "r") as f:
            return f.read().strip()
    return None

def save_current_ip(ip):
    with open(DATA_PATH, "w") as f:
        f.write(ip)

# ... bestehende Methoden bleiben gleich ...

def main():
    print("Fetching add-on options...")
    opts = get_addon_options()
    token = opts['hetzner_token']
    zone = opts['dns_zone']
    record_name = opts['dns_record_name']
    
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }

    print("Fetching public IP...")
    current_ip = get_public_ip()
    last_ip = get_last_ip()

    if current_ip == last_ip:
        print(f"IP hat sich nicht geändert ({current_ip}) – kein Update notwendig.")
        return

    print("IP hat sich geändert, fahre mit Update fort...")

    record_id, record_type, zone_id = get_record_id(headers, record_name.split('.')[0])
    update_record(record_id, zone_id, record_type, record_name.split('.')[0], current_ip, headers)
    save_current_ip(current_ip)
