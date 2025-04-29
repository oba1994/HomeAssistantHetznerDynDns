#!/bin/bash

CONFIG_PATH=/data/options.json
TOKEN=$(jq -r '.hetzner_token' $CONFIG_PATH)
RECORD_NAME=$(jq -r '.record_name' $CONFIG_PATH)
ZONE_NAME=$(jq -r '.zone_name' $CONFIG_PATH)

# Öffentliche IP abfragen
IP=$(curl -s https://ipinfo.io/ip)

if [[ -z "$IP" ]]; then
  echo "Fehler: Konnte öffentliche IP nicht abrufen."
  exit 1
fi

# Zone-ID anhand des Zonen-Namens abrufen
ZONES=$(curl -s -H "Auth-API-Token: $TOKEN" "https://dns.hetzner.com/api/v1/zones")
ZONE_ID=$(echo "$ZONES" | jq -r --arg name "$ZONE_NAME" '.zones[] | select(.name == $name) | .id')

if [[ -z "$ZONE_ID" ]]; then
  echo "Fehler: Konnte Zone-ID für $ZONE_NAME nicht finden."
  exit 1
fi

# DNS-Einträge der Zone abrufen
RECORDS=$(curl -s -H "Auth-API-Token: $TOKEN" \
  "https://dns.hetzner.com/api/v1/records?zone_id=$ZONE_ID")

RECORD_ID=$(echo "$RECORDS" | jq -r --arg name "$RECORD_NAME" '.records[] | select(.name==$name and .type=="A") | .id')

if [[ -z "$RECORD_ID" ]]; then
  echo "Fehler: A-Record für $RECORD_NAME nicht gefunden."
  exit 1
fi

CURRENT_IP=$(echo "$RECORDS" | jq -r --arg id "$RECORD_ID" '.records[] | select(.id==$id) | .value')

if [[ "$CURRENT_IP" == "$IP" ]]; then
  echo "IP hat sich nicht geändert: $IP"
  exit 0
fi

# Record aktualisieren
UPDATE_PAYLOAD=$(jq -n \
  --arg id "$RECORD_ID" \
  --arg name "$RECORD_NAME" \
  --arg zone "$ZONE_ID" \
  --arg ip "$IP" \
  '{
    id: $id,
    type: "A",
    name: $name,
    value: $ip,
    ttl: 300,
    zone_id: $zone
  }')

RESPONSE=$(curl -s -X PUT \
  -H "Content-Type: application/json" \
  -H "Auth-API-Token: $TOKEN" \
  -d "$UPDATE_PAYLOAD" \
  "https://dns.hetzner.com/api/v1/records/$RECORD_ID")

if echo "$RESPONSE" | grep -q '"record"'; then
  echo "DNS A-Record aktualisiert auf IP $IP"
else
  echo "Fehler beim Aktualisieren des DNS-Eintrags:"
  echo "$RESPONSE"
  exit 1
fi
