#!/bin/bash
# paroolide_genereerimine.sh
# Parameeter: kasutajate fail (üks kasutaja rea kohta).
# Genereerib igale 8-tähelise parooli (pwgen), lisab kasutaja
# ja salvestab kasutaja:parool logifaili.

LOGFAIL="loodud_kasutajad_paroolidega"

# Ülesanne 6: ainult päris root.
# Kui käivitatud sudo kaudu, on muutuja SUDO_USER täidetud.
if [ -n "$SUDO_USER" ]; then
    echo "Viga: ära kasuta sudo-d, logi sisse rootina (nt: sudo su -)."
    exit 1
fi
if [ "$(whoami)" != "root" ]; then
    echo "Viga: skripti võib käivitada ainult root."
    exit 1
fi

if [ -z "$1" ]; then
    echo "Kasutus: $0 kasutajate_fail"
    exit 1
fi

# Kui pwgen puudub, paigaldame
if ! command -v pwgen > /dev/null; then
    apt install -y pwgen
fi

while read -r kasutaja || [ -n "$kasutaja" ]; do
    # pwgen -0: ilma numbriteta, 8 sümbolit, 1 parool
    parool=$(pwgen -0 8 1)
    useradd -m -s /bin/bash "$kasutaja"
    echo "$kasutaja:$parool" | chpasswd
    echo "$kasutaja:$parool" >> "$LOGFAIL"
    echo "Lisatud: $kasutaja"
done < "$1"
