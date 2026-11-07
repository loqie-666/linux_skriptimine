#!/bin/bash
# kasutajad_failist - lisab kasutajad failist

if [ -z "$1" ]; then
    echo "Kasutus: $0 failinimi"
    exit 1
fi

while read -r kasutaja || [ -n "$kasutaja" ]; do
    sh ./lisa_kasutaja.sh "$kasutaja"
done < "$1"
