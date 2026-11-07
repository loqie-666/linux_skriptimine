#!/bin/bash

set -e
export DEBIAN_FRONTEND=noninteractive

OPILANE="Kevin Inginen-Tõšuk"
GRUPP="ITS24"
MYSQL_PAROOL="qwerty"
DEB_URL="https://dev.mysql.com/get/mysql-apt-config_0.8.40-1_all.deb"
DEB_FAIL="/tmp/mysql-apt-config.deb"

pakett_olemas() {
    dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "ok installed"
}

if [ "$(id -u)" -ne 0 ]; then
    echo "Viga: käivita skript root-kasutajana."
    exit 1
fi

apt update
for pakett in wget ca-certificates gnupg debconf-utils; do
    if pakett_olemas "$pakett"; then
        echo "$pakett on juba paigaldatud."
    else
        echo "Paigaldan $pakett..."
        apt install -y "$pakett"
    fi
done

MYSQL_UUS=0
if pakett_olemas mysql-community-server || pakett_olemas mysql-server-8.0; then
    echo "MySQL 8.0 on juba paigaldatud."
else
    echo "MySQL 8.0 puudub, paigaldan..."

    echo "mysql-apt-config mysql-apt-config/select-server select mysql-8.0" | debconf-set-selections
    echo "mysql-apt-config mysql-apt-config/select-tools select Disabled" | debconf-set-selections
    echo "mysql-apt-config mysql-apt-config/select-product select Ok" | debconf-set-selections

    echo "mysql-community-server mysql-community-server/root-pass password $MYSQL_PAROOL" | debconf-set-selections
    echo "mysql-community-server mysql-community-server/re-root-pass password $MYSQL_PAROOL" | debconf-set-selections
    echo "mysql-community-server mysql-server/default-auth-override select Use Strong Password Encryption (RECOMMENDED)" | debconf-set-selections

    wget -O "$DEB_FAIL" "$DEB_URL"
    dpkg -i "$DEB_FAIL"
    apt update
    apt install -y mysql-server
    MYSQL_UUS=1
fi

systemctl enable --now mysql

if [ "$MYSQL_UUS" -eq 1 ] || [ ! -f /root/.my.cnf ]; then
    cat > /root/.my.cnf <<EOT
[client]
host=localhost
user=root
password=$MYSQL_PAROOL
EOT
    chmod 600 /root/.my.cnf
    echo "Loodud /root/.my.cnf"
fi

APACHE_UUS=0
if pakett_olemas apache2; then
    echo "Apache2 on juba paigaldatud."
else
    echo "Apache2 puudub, paigaldan..."
    apt install -y apache2
    APACHE_UUS=1
fi

systemctl enable --now apache2

if [ "$APACHE_UUS" -eq 1 ] || [ ! -f /var/www/html/index.html ]; then
    cat > /var/www/html/index.html <<EOT
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>LAMP</title></head>
<body>
<h1>LAMP server töötab!</h1>
<p>Õpilane: $OPILANE</p>
<p>Grupp: $GRUPP</p>
<p>LAMP paigaldus õnnestus.</p>
<p>Paigaldatud: $(date "+%Y-%m-%d %H:%M:%S")</p>
</body>
</html>
EOT
fi

if command -v php > /dev/null && php -v | head -n 1 | grep -q "PHP 8"; then
    echo "PHP 8.x on juba paigaldatud: $(php -v | head -n 1)"
else
    echo "PHP 8.x puudub, paigaldan..."
    apt install -y php php-cli php-common php-mysql libapache2-mod-php
    systemctl restart apache2
fi

echo '<?php phpinfo(); ?>' > /var/www/html/info.php

A_STAT=$(systemctl is-active apache2 || true)
A_AUTO=$(systemctl is-enabled apache2 || true)
M_STAT=$(systemctl is-active mysql || true)
M_AUTO=$(systemctl is-enabled mysql || true)

if [ -f /root/.my.cnf ]; then MYCNF="olemas"; else MYCNF="puudub"; fi

echo
echo "========== LAMP REPORT =========="
echo
echo "Apache2:"
echo "Version: $(apache2 -v | head -n 1)"
echo "Status: $A_STAT"
echo "Autostart: $A_AUTO"
echo
echo "PHP:"
echo "Version: $(php -v | head -n 1)"
echo
echo "MySQL:"
echo "Version: $(mysql --version)"
echo "Status: $M_STAT"
echo "Autostart: $M_AUTO"
echo
echo "Apache default page:"
echo "/var/www/html/index.html"
echo
echo "PHP test page:"
echo "/var/www/html/info.php"
echo
echo "MySQL root configuration:"
echo "/root/.my.cnf - $MYCNF"
echo
echo "================================="
