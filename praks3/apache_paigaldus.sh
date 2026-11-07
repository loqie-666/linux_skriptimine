#!/bin/bash
# apache_paigaldus.sh
# Kontrollib, kas apache2 on paigaldatud.
# Kui ei ole, paigaldab. Kui on, annab teada ja näitab staatust.

PAKETT="apache2"

# dpkg-query näitab paketi staatust, grep otsib sealt "ok installed".
# grep -q ei prindi midagi, vaid tagastab 0, kui leiti.
if dpkg-query -W -f='${Status}' "$PAKETT" 2>/dev/null | grep -q "ok installed"; then
    echo "$PAKETT on juba paigaldatud."
    systemctl status "$PAKETT" --no-pager
else
    echo "$PAKETT ei ole paigaldatud. Paigaldan..."
    apt update
    apt install -y "$PAKETT"
    echo "$PAKETT on paigaldatud."
fi
