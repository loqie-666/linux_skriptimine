#!/bin/bash
# mysql-server.sh
# Paigaldab Oracle MySQL 8.0 serveri täielikult automaatselt.

# Kui mõni käsk annab vea, lõpetame skripti kohe,
# et ei jääks poolikult paigaldatud süsteemi.
set -e

# apt ja dpkg ei küsi midagi, kasutavad ette antud vastuseid
export DEBIAN_FRONTEND=noninteractive

DEB_URL="https://dev.mysql.com/get/mysql-apt-config_0.8.40-1_all.deb"
DEB_FAIL="/tmp/mysql-apt-config.deb"
ROOT_PAROOL="qwerty"   # ainult õppetööks!

# --- 1. Vajalikud tööriistad ---
apt update
apt install -y gnupg ca-certificates debconf-utils wget

# --- 2. Vastused mysql-apt-config paketi küsimustele ---
# Valime serveriks mysql-8.0, tööriistu ei lisa
echo "mysql-apt-config mysql-apt-config/select-server select mysql-8.0" | debconf-set-selections
echo "mysql-apt-config mysql-apt-config/select-tools select Disabled" | debconf-set-selections
echo "mysql-apt-config mysql-apt-config/select-product select Ok" | debconf-set-selections

# --- 3. Vastused serveri paigalduse küsimustele (root-parool) ---
echo "mysql-community-server mysql-community-server/root-pass password $ROOT_PAROOL" | debconf-set-selections
echo "mysql-community-server mysql-community-server/re-root-pass password $ROOT_PAROOL" | debconf-set-selections
echo "mysql-community-server mysql-server/default-auth-override select Use Strong Password Encryption (RECOMMENDED)" | debconf-set-selections

# --- 4. Lisame Oracle'i ametliku repositooriumi ---
wget -O "$DEB_FAIL" "$DEB_URL"
dpkg -i "$DEB_FAIL"

# --- 5. Paigaldame MySQL serveri ---
apt update
apt install -y mysql-server

# --- 6. Käivitame teenuse ja lubame automaatkäivituse ---
systemctl enable --now mysql

# --- 7. .my.cnf, et "mysql" käsk ei küsiks parooli ---
cat > /root/.my.cnf <<EOF
[client]
host=localhost
user=root
password=$ROOT_PAROOL
EOF
chmod 600 /root/.my.cnf

echo "Valmis: Oracle MySQL 8.0 on paigaldatud. Root-parool: $ROOT_PAROOL"
mysql --version || true
