#!/bin/bash
# backup_home.sh - varundab kõigi kasutajate kodukataloogid
# Arhiivi nimi: kasutaja.PP.KK.AAAA.tar.gz
# Töötab igast kataloogist, sest kõik teed on täielikud.

HOME_DIR="/home"
BACKUP_DIR="/home_bcp"
DATE=$(date +%d.%m.%Y)

mkdir -p "$BACKUP_DIR"

for dir in "$HOME_DIR"/*/; do
    user=$(basename "$dir")
    tar -czf "$BACKUP_DIR/$user.$DATE.tar.gz" -C "$HOME_DIR" "$user"
    echo "Varundatud: $user"
done

echo "Valmis. Arhiivid asuvad: $BACKUP_DIR"
