#!/usr/bin/env bash
# ==============================================================================
# Lab 01 Idempotent Deployment Script for Rocky Linux / RHEL / Ubuntu
# Target Architecture: Isolated PHP-FPM Pool + Apache VirtualHost
# ==============================================================================

set -e

if [ "$EUID" -ne 0 ]; then
  echo "[-] Error: Please run setup.sh as root (e.g., sudo ./setup.sh)"
  exit 1
fi

echo "[+] Step 1: Checking system user 'lab01'..."
if ! id -u lab01 >/dev/null 2>&1; then
    useradd --system --no-create-home --shell=/usr/sbin/nologin lab01
    echo "    Created user lab01"
else
    echo "    User lab01 already exists."
fi

echo "[+] Step 2: Provisioning directory structure under /srv/labs/lab01..."
mkdir -p /srv/labs/lab01/{public,data,public/uploads,sessions}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[+] Step 3: Copying application public and data files..."
cp -r "${SCRIPT_DIR}/public/"* /srv/labs/lab01/public/
cp -r "${SCRIPT_DIR}/data/"* /srv/labs/lab01/data/

echo "[+] Step 4: Setting directory ownership and strict security permissions..."
# Group membership for web server process
if id -u apache >/dev/null 2>&1; then
    usermod -aG lab01 apache
elif id -u www-data >/dev/null 2>&1; then
    usermod -aG lab01 www-data
fi

chown -R lab01:lab01 /srv/labs/lab01
chmod 700 /srv/labs/lab01 /srv/labs/lab01/sessions
chmod 755 /srv/labs/lab01/public /srv/labs/lab01/data
chmod 777 /srv/labs/lab01/public/uploads

echo "[+] Step 5: Installing PHP-FPM pool configuration..."
FPM_CONF_COPIED=0
for FPM_DIR in "/etc/php-fpm.d" "/etc/php/8.3/fpm/pool.d" "/etc/php/8.2/fpm/pool.d" "/etc/php/8.1/fpm/pool.d" "/etc/php/8.0/fpm/pool.d"; do
    if [ -d "$FPM_DIR" ]; then
        cp "${SCRIPT_DIR}/config/lab01-php-fpm.conf" "${FPM_DIR}/lab01.conf"
        echo "    Copied PHP-FPM pool config to ${FPM_DIR}/lab01.conf"
        FPM_CONF_COPIED=1
        break
    fi
done

if [ "$FPM_CONF_COPIED" -eq 0 ]; then
    echo "    [*] PHP-FPM pool directory not auto-detected; copied config to /etc/php-fpm.d/lab01.conf"
    mkdir -p /etc/php-fpm.d
    cp "${SCRIPT_DIR}/config/lab01-php-fpm.conf" /etc/php-fpm.d/lab01.conf
fi

echo "[+] Step 6: Installing Apache VirtualHost configuration..."
if [ -d "/etc/httpd/conf.d" ]; then
    cp "${SCRIPT_DIR}/config/lab01-apache.conf" /etc/httpd/conf.d/lab01.conf
    echo "    Copied Apache VirtualHost to /etc/httpd/conf.d/lab01.conf"
elif [ -d "/etc/apache2/sites-available" ]; then
    cp "${SCRIPT_DIR}/config/lab01-apache.conf" /etc/apache2/sites-available/lab01.conf
    a2ensite lab01.conf || true
    echo "    Copied Apache VirtualHost to /etc/apache2/sites-available/lab01.conf"
fi

echo "[+] Step 7: Configuring /etc/hosts mapping..."
if ! grep -q "employeeportal.local" /etc/hosts; then
    echo "127.0.0.1 employeeportal.local" >> /etc/hosts
    echo "    Added employeeportal.local to /etc/hosts"
fi

echo "[+] Step 8: Reloading services..."
systemctl reload php-fpm || systemctl restart php-fpm || systemctl reload php8.3-fpm || systemctl reload php8.2-fpm || true
systemctl reload httpd || systemctl restart httpd || systemctl reload apache2 || systemctl restart apache2 || true

echo "=============================================================================="
echo "[🎉] Lab 01 Environment Setup Complete!"
echo "     Portal URL: http://employeeportal.local:8081 or http://127.0.0.1:8081"
echo "=============================================================================="
