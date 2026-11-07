#!/bin/bash
# lisa_kasutaja - loob kasutaja koos kodukataloogiga

if [ -z "$1" ]; then
    echo "Kasutus: $0 kasutajanimi"
    exit 1
fi

useradd -m -s /bin/bash "$1"

# kontroll
grep "^$1:" /etc/passwd
grep "^$1:" /etc/shadow
ls -la /home/"$1"
