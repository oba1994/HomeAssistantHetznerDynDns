#!/bin/bash

CONFIG_PATH=/data/options.json

TOKEN=$(jq -r '.hetzner_cloud_token' "$CONFIG_PATH")
ZONE_NAME=$(jq -r '.zone_name' "$CONFIG_PATH")
RECORD_NAME=$(jq -r '.record_name' "$CONFIG_PATH")
RECORD_TYPE=$(jq -r '.record_type' "$CONFIG_PATH")

AUTH_HEADER="Authorization: Bearer $TOKEN"

# IPv4 ermitteln
PUBLIC_IPV4=$(curl -4 -s https://ipinfo.io/ip)

# IPv6 ermitteln
PUBLIC_IPV6=$(curl -6 -s https://ipinfo.io/ip 2>/dev/null)

if [[ "$RECORD_TYPE" == "A" || "$RECORD_TYPE" == "Both" ]]; then
    if [[ -z "$PUBLIC_IPV4" ]]; then
        echo "Fehler: IPv4-Adresse konnte nicht ermittelt werden."
        exit 1
    fi
fi

if [[ "$RECORD_TYPE" == "AAAA" || "$RECORD_TYPE" == "Both" ]]; then
    if [[ -z "$PUBLIC_IPV6" ]]; then
        echo "Warnung: IPv6-Adresse konnte nicht ermittelt werden."
    fi
fi

echo "IPv4: $PUBLIC_IPV4"
echo "IPv6: $PUBLIC_IPV6"

#
# Zone-ID ermitteln
#
ZONE_ID=$(
curl -s \
    -H "$AUTH_HEADER" \
    https://api.hetzner.cloud/v1/zones |
jq -r --arg zone "$ZONE_NAME" '
    .zones[] | select(.name==$zone) | .id
'
)

if [[ -z "$ZONE_ID" || "$ZONE_ID" == "null" ]]; then
    echo "Fehler: Zone '$ZONE_NAME' nicht gefunden."
    exit 1
fi

echo "Zone-ID: $ZONE_ID"

update_record() {

    local TYPE=$1
    local TARGET_IP=$2

    [[ -z "$TARGET_IP" ]] && return

    echo "Prüfe $TYPE Record..."

    CURRENT_DATA=$(
    curl -s \
        -H "$AUTH_HEADER" \
        "https://api.hetzner.cloud/v1/zones/$ZONE_ID/rrsets/$RECORD_NAME/$TYPE"
    )

    CURRENT_IP=$(
    echo "$CURRENT_DATA" |
    jq -r '.rrset.records[0].value'
    )

    if [[ "$CURRENT_IP" == "$TARGET_IP" ]]; then
        echo "$TYPE bereits aktuell ($TARGET_IP)"
        return
    fi

    PAYLOAD=$(jq -n \
        --arg ip "$TARGET_IP" \
        '{
            records: [
                {
                    value: $ip
                }
            ]
        }')

    RESPONSE=$(
    curl -s \
        -X PUT \
        -H "$AUTH_HEADER" \
        -H "Content-Type: application/json" \
        -d "$PAYLOAD" \
        "https://api.hetzner.cloud/v1/zones/$ZONE_ID/rrsets/$RECORD_NAME/$TYPE/actions/set_records' "
    )

    echo "$TYPE aktualisiert auf $TARGET_IP"
    echo "$RESPONSE"
}

case "$RECORD_TYPE" in

    A)
        update_record "A" "$PUBLIC_IPV4"
        ;;

    AAAA)
        update_record "AAAA" "$PUBLIC_IPV6"
        ;;

    Both)
        update_record "A" "$PUBLIC_IPV4"
        update_record "AAAA" "$PUBLIC_IPV6"
        ;;

    *)
        echo "Ungültiger record_type: $RECORD_TYPE"
        exit 1
        ;;

esac