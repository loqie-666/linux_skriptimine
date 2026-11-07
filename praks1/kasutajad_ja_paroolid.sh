#!/bin/bash
# kasutajad_ja_paroolid.sh
# Parameetrid: kasutajate_fail paroolide_fail
# Rida N kasutajate failis vastab reale N paroolide failis.
# Kõik on selles skriptis, teisi skripte ei kutsuta.

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Kasutus: $0 kasutajate_fail paroolide_fail"
    exit 1
fi

# paste -d: ühendab kaks faili ritta kujul kasutaja:parool
paste -d: "$1" "$2" | while IFS=: read -r kasutaja parool; do
    useradd -m -s /bin/bash "$kasutaja"
    echo "$kasutaja:$parool" | chpasswd
    echo "Lisatud: $kasutaja"
done
