#!/usr/bin/env bash
# ==============================================================================
# Lab 01 Automated Environment Deployment Script
# Target Architecture: Isolated PHP-FPM Pool + Apache VirtualHost
# ==============================================================================

set -e

if [ "$EUID" -ne 0 ]; then
  echo "[-] Error: Please run setup.sh as root (e.g., sudo ./setup.sh)"
  exit 1
fi

echo "[+] Step 1: Creating system user 'lab01'..."
if ! id -u lab01 >/dev/null 2>&1; then
    useradd --system --no-create-home --shell=/usr/sbin/nologin lab01
    echo "    Created user lab01"
else
    echo "    User lab01 already exists."
fi

echo "[+] Step 2: Provisioning directory structure under /srv/labs/lab01..."
mkdir -p /srv/labs/lab01/{public,uploads,sessions}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[+] Step 3: Copying public application files to /srv/labs/lab01/public..."
cp -r "${SCRIPT_DIR}/public/"* /srv/labs/lab01/public/

echo "[+] Step 4: Setting directory ownership and strict permissions..."
chown -R lab01:lab01 /srv/labs/lab01
chmod 700 /srv/labs/lab01 /srv/labs/lab01/uploads /srv/labs/lab01/sessions
chmod -R 755 /srv/labs/lab01/public

# Allow Apache server process read access to public and socket permissions
if id -u apache >/dev/null 2>&1; then
    usermod -aG lab01 apache
elif id -u www-data >/dev/null 2>&1; then
    usermod -aG lab01 www-data
fi

echo "[+] Step 5: Installing PHP-FPM pool configuration..."
if [ -d "/etc/php-fpm.d" ]; then
    cp "${SCRIPT_DIR}/config/lab01-php-fpm.conf" /etc/php-fpm.d/lab01.conf
elif [ -d "/etc/php/8.3/fpm/pool.d" ]; then
    cp "${SCRIPT_DIR}/config/lab01-php-fpm.conf" /etc/php/8.3/fpm/pool.d/lab01.conf
elif [ -d "/etc/php/8.2/fpm/pool.d" ]; then
    cp "${SCRIPT_DIR}/config/lab01-php-fpm.conf" /etc/php/8.2/fpm/pool.d/lab01.conf
elif [ -d "/etc/php/8.1/fpm/pool.d" ]; then
    cp "${SCRIPT_DIR}/config/lab01-php-fpm.conf" /etc/php/8.1/fpm/pool.d/lab01.conf
else
    echo "    [*] PHP-FPM pool directory not auto-detected; copied config to ${SCRIPT_DIR}/config/lab01-php-fpm.conf"
fi

echo "[+] Step 6: Installing Apache VirtualHost configuration..."
if [ -d "/etc/httpd/conf.d" ]; then
    cp "${SCRIPT_DIR}/config/lab01-apache.conf" /etc/httpd/conf.d/lab01.conf
elif [ -d "/etc/apache2/sites-available" ]; then
    cp "${SCRIPT_DIR}/config/lab01-apache.conf" /etc/apache2/sites-available/lab01.conf
    a2ensite lab01.conf || true
fi

echo "[+] Step 7: Adding employeeportal.local to /etc/hosts..."
if ! grep -q "employeeportal.local" /etc/hosts; then
    echo "127.0.0.1 employeeportal.local" >> /etc/hosts
fi

echo "[+] Step 8: Restarting PHP-FPM and Apache web server..."
systemctl restart php-fpm || systemctl restart php8.3-fpm || systemctl restart php8.2-fpm || true
systemctl restart httpd || systemctl restart apache2 || true

echo "=============================================================================="
echo "[🎉] Lab 01 Environment Setup Complete!"
echo "     Access Portal at: http://employeeportal.local:8081 or http://127.0.0.1:8081"
echo "=============================================================================="
