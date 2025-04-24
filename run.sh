#!/bin/bash

echo "Starte Hetzner IP Updater..."

PYTHON=$(command -v python3 || command -v python)

if [ -z "$PYTHON" ]; then
  echo "Python ist nicht installiert!"
  exit 1
fi

$PYTHON /update_ip.py
