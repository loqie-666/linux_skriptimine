#!/bin/bash
# php_paigaldus.sh
# Paigaldab PHP koos veebiserveris töötamiseks vajalike pakettidega.
# Väljund on sarnane apache_paigaldus.sh skriptiga.

# php                 - PHP ise
# libapache2-mod-php  - tugi Apache veebiserveri jaoks
# php-mysql           - hilisem MySQL kasutus
PAKETID="php libapache2-mod-php php-mysql"
PUUDUVAD=""

# Kontrollime iga paketti eraldi
for pakett in $PAKETID; do
    if dpkg-query -W -f='${Status}' "$pakett" 2>/dev/null | grep -q "ok installed"; then
        echo "$pakett on juba paigaldatud."
    else
        echo "$pakett ei ole paigaldatud."
        PUUDUVAD="$PUUDUVAD $pakett"
    fi
done

# Paigaldame ainult need, mida puudu on
if [ -n "$PUUDUVAD" ]; then
    echo "Paigaldan:$PUUDUVAD"
    apt update
    apt install -y $PUUDUVAD
    # Konfiguratsiooni rakendamiseks taaskäivitame Apache
    systemctl restart apache2
    echo "PHP on paigaldatud."
else
    echo "Kõik PHP paketid on juba paigaldatud."
fi

# Näitame tulemust
php -v
systemctl status apache2 --no-pager
