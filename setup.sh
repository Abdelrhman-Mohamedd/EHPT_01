#!/usr/bin/env bash
# ==============================================================================
# Lab 01 Idempotent Deployment & Hardening Script (v2 — Dynamic Flags)
# Flags are generated in PHP memory via flag_engine.php, NOT stored on disk.
# ==============================================================================

set -e

if [ "$EUID" -ne 0 ]; then
  echo "[-] Error: Please run setup.sh as root (e.g., sudo ./setup.sh <STUDENT_ID>)"
  exit 1
fi

STUDENT_ID="${1:-abdelrhman_h_2026}"

# ---- Read salt from protected config file ----
SALT_FILE="/etc/lab01.conf"
if [ -f "$SALT_FILE" ]; then
    SECRET_SALT=$(cat "$SALT_FILE")
else
    SECRET_SALT="${2:-EHPT01_SECRET_SALT_2026}"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$SCRIPT_DIR" == "/srv/labs/lab01" ]; then
    echo "[-] Warning: Running setup.sh from within /srv/labs/lab01."
    exit 1
fi

echo "=============================================================================="
echo "[🔒] Personalizing & Hardening Lab 01 VM for Student ID: ${STUDENT_ID}"
echo "=============================================================================="

# NOTE: Flag derivation removed from setup.sh.
# Flags are now generated dynamically in PHP memory by flag_engine.php.
# The instructor can still verify flags using generate_student_flags.py.

echo "[+] Step 1: Checking system user 'lab01'..."
if ! id -u lab01 >/dev/null 2>&1; then
    useradd --system --no-create-home --shell=/usr/sbin/nologin lab01
    echo "    Created user lab01"
else
    echo "    User lab01 already exists."
fi

echo "[+] Step 2: Provisioning directory structure..."
mkdir -p /srv/labs/lab01/{public,data,sessions}
mkdir -p /srv/labs/lab01/uploads    # Outside webroot — for hardened file uploads

echo "[+] Step 3: Copying application files..."
cp -r "${SCRIPT_DIR}/public/"* /srv/labs/lab01/public/
cp -r "${SCRIPT_DIR}/data/"* /srv/labs/lab01/data/

# Clean up legacy upload artifacts (A-04)
rm -f /srv/labs/lab01/public/uploads/.gitkeep
rm -f /srv/labs/lab01/public/uploads/.upload_marker
rm -f /srv/labs/lab01/public/uploads/.rfi_marker

# Remove legacy on-disk flag files (A-01)
rm -f /etc/lab_cmdi_flag

echo "[+] Step 4: Writing student identity metadata..."
BUILD_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
MACHINE_HASH="N/A"
if [ -f /etc/machine-id ]; then
    MACHINE_HASH=$(sha256sum /etc/machine-id | cut -c1-32)
fi

cat << EOF > /srv/labs/lab01/data/.studentinfo
STUDENT_ID=${STUDENT_ID}
BUILD_TIME=${BUILD_TIME}
EOF

# .buildinfo for anti-cheat — NO flag values stored
cat << EOF > /srv/labs/lab01/.buildinfo
STUDENT_ID=${STUDENT_ID}
BUILD_TIMESTAMP=${BUILD_TIME}
MACHINE_HASH=${MACHINE_HASH}
FLAG_ENGINE=dynamic_v2
EOF

echo "[+] Step 5: Setting ownership & access permissions..."
if id -u apache >/dev/null 2>&1; then
    usermod -aG lab01 apache
elif id -u www-data >/dev/null 2>&1; then
    usermod -aG lab01 www-data
fi

chown -R root:lab01 /srv/labs/lab01
chmod 750 /srv/labs/lab01 /srv/labs/lab01/public /srv/labs/lab01/data
chmod 700 /srv/labs/lab01/.buildinfo

find /srv/labs/lab01/public -type d -exec chmod 750 {} \;
find /srv/labs/lab01/data -type d -exec chmod 750 {} \;
find /srv/labs/lab01/public -type f -exec chmod 640 {} \;
find /srv/labs/lab01/data -type f -exec chmod 640 {} \;

# Sessions directory: writable by lab01 process
chown -R lab01:lab01 /srv/labs/lab01/sessions
chmod 770 /srv/labs/lab01/sessions

# New uploads directory (outside webroot): writable by lab01 process
chown -R lab01:lab01 /srv/labs/lab01/uploads
chmod 770 /srv/labs/lab01/uploads

# Legacy public/uploads: deny access (kept for structure, emptied)
mkdir -p /srv/labs/lab01/public/uploads
chown root:lab01 /srv/labs/lab01/public/uploads
chmod 750 /srv/labs/lab01/public/uploads

# Salt file: readable by lab01 group for dynamic flag generation
if [ -f "$SALT_FILE" ]; then
    chown root:lab01 "$SALT_FILE"
    chmod 640 "$SALT_FILE"
    echo "    Salt file permissions set to root:lab01 640"
fi

echo "[+] Step 6: Configuring SELinux Policy & Port 8081..."
if command -v getenforce >/dev/null 2>&1 && [ "$(getenforce)" != "Disabled" ]; then
    echo "    Applying SELinux booleans and context labels..."
    setsebool -P httpd_can_network_connect 1 2>/dev/null || true

    if command -v semanage >/dev/null 2>&1; then
        semanage port -m -t http_port_t -p tcp 8081 2>/dev/null || \
        semanage port -a -t http_port_t -p tcp 8081 2>/dev/null || true

        semanage fcontext -a -t httpd_sys_rw_content_t "/srv/labs/lab01(/.*)?" 2>/dev/null || true
    fi

    if command -v restorecon >/dev/null 2>&1; then
        restorecon -R /srv/labs/lab01 2>/dev/null || true
    fi
fi

echo "[+] Step 7: Setting Hostname & Boot Banner..."
HOSTNAME_TARGET="lab01-${STUDENT_ID//_/-}"
if command -v hostnamectl >/dev/null 2>&1; then
    hostnamectl set-hostname "${HOSTNAME_TARGET}" 2>/dev/null || true
else
    echo "${HOSTNAME_TARGET}" > /etc/hostname
fi

cat << EOF > /etc/motd
==============================================================================
  NexaCorp Ethical Hacking Black-Box Appliance (Lab 01)
  Assigned Student ID : ${STUDENT_ID}
  VM Build Timestamp  : ${BUILD_TIME}
  Portal Access URL   : http://<VM_IP>:8081
==============================================================================
  [!] Direct shell access is disabled for student users.
      All penetration testing must be performed over the network.
==============================================================================
EOF
cp /etc/motd /etc/issue

echo "[+] Step 8: Installing PHP-FPM pool configuration..."
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
    mkdir -p /etc/php-fpm.d
    cp "${SCRIPT_DIR}/config/lab01-php-fpm.conf" /etc/php-fpm.d/lab01.conf
fi

echo "[+] Step 9: Installing Apache VirtualHost configuration..."
if [ -d "/etc/httpd/conf.d" ]; then
    cp "${SCRIPT_DIR}/config/lab01-apache.conf" /etc/httpd/conf.d/lab01.conf
elif [ -d "/etc/apache2/sites-available" ]; then
    cp "${SCRIPT_DIR}/config/lab01-apache.conf" /etc/apache2/sites-available/lab01.conf
    a2ensite lab01.conf || true
fi

echo "[+] Step 10: Installing systemd resource limits (A-05)..."
if [ -d "/etc/systemd/system" ]; then
    # Install drop-in for httpd
    mkdir -p /etc/systemd/system/httpd.service.d
    cp "${SCRIPT_DIR}/config/lab01-resource-limits.conf" /etc/systemd/system/httpd.service.d/lab01-limits.conf 2>/dev/null || true
    # Install drop-in for php-fpm
    mkdir -p /etc/systemd/system/php-fpm.service.d
    cp "${SCRIPT_DIR}/config/lab01-resource-limits.conf" /etc/systemd/system/php-fpm.service.d/lab01-limits.conf 2>/dev/null || true
    systemctl daemon-reload 2>/dev/null || true
fi

echo "[+] Step 11: Configuring /etc/hosts mapping..."
if ! grep -q "employeeportal.local" /etc/hosts; then
    echo "127.0.0.1 employeeportal.local" >> /etc/hosts
fi

echo "[+] Step 12: Cleaning up stale artifacts (A-04, A-06, A-08)..."
# A-06: Remove any dead sudoers entries
rm -f /etc/sudoers.d/lab01-old-setup 2>/dev/null || true
if [ -f /etc/sudoers.d/lab01-setup ]; then
    # Verify current sudoers rule points to correct path
    if grep -q "/usr/lib/php-fpm/setup.sh" /etc/sudoers.d/lab01-setup 2>/dev/null; then
        echo "    [!] Removing dead sudoers rule referencing /usr/lib/php-fpm/setup.sh"
        rm -f /etc/sudoers.d/lab01-setup
    fi
fi
# A-08: Remove unused /var/www/html
if [ -d "/var/www/html" ] && [ ! -L "/var/www/html" ]; then
    rm -rf /var/www/html
    echo "    Removed unused /var/www/html directory"
fi

echo "[+] Step 13: Reloading & restarting web services..."
systemctl restart php-fpm || systemctl restart php8.3-fpm || systemctl restart php8.2-fpm || true
systemctl restart httpd || systemctl restart apache2 || true

echo "=============================================================================="
echo "[🎉] Black-Box Appliance Lab 01 Provisioned & Hardened for ${STUDENT_ID}!"
echo "     Portal URL: http://employeeportal.local:8081"
echo "     Access Mode: Network-only Black-Box"
echo "     Flag Engine: Dynamic (v2 — in-memory only)"
echo "=============================================================================="
