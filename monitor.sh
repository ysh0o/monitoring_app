#!/bin/bash

CONFIG_FILE="/etc/myapp/monitor.conf"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"

else
    echo "Config file $CONFIG_FILE not found" >&2

    exit 1
fi

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$APP_URL")

if [ "$RESPONSE" != "200" ]; then

    echo "$TIMESTAMP: ERROR - APP IS DOWN (HTTP $RESPONSE)" >> "$LOG_FILE"

    systemctl restart "$APP_SERVICE"

    echo "$TIMESTAMP: APP RESTARTED" >> "$LOG_FILE"
else

    echo "$TIMESTAMP: APP IS UP" >> "$LOG_FILE"
fi
