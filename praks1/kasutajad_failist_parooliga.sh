#!/bin/bash
# kasutajad_failist_parooliga.sh
# Võtab failinime. Iga rida on kujul kasutajanimi:parool.
# Lisab kasutaja (lisa_kasutaja.sh abil) ja seadistab parooli.

if [ -z "$1" ]; then
    echo "Kasutus: $0 failinimi"
    exit 1
fi

# Skripti kataloog, et lisa_kasutaja.sh leiduks igalt poolt
DIR="$(dirname "$(readlink -f "$0")")"

# IFS=: jagab rea kaheks: enne koolonit kasutaja, pärast parool
# "|| [ -n ... ]" võtab ka viimase rea, kus pole reavahetust
while IFS=: read -r kasutaja parool || [ -n "$kasutaja" ]; do
    sh "$DIR/lisa_kasutaja.sh" "$kasutaja"
    if [ -n "$parool" ]; then
        # chpasswd võtab kujul kasutaja:parool ja krüpteerib ise
        echo "$kasutaja:$parool" | chpasswd
        echo "Parool seatud kasutajale $kasutaja"
    fi
done < "$1"
