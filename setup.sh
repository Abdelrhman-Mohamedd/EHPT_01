#!/usr/bin/env bash
# ==============================================================================
# Lab 01 Idempotent Deployment, Cryptographic Personalization & Hardening Script
# Target Architecture: Isolated Black-Box Appliance (PHP-FPM Pool + Apache VirtualHost)
# ==============================================================================

set -e

if [ "$EUID" -ne 0 ]; then
  echo "[-] Error: Please run setup.sh as root (e.g., sudo ./setup.sh <STUDENT_ID> [SECRET_SALT] [--production])"
  exit 1
fi

STUDENT_ID="${1:-abdelrhman_h_2026}"
SECRET_SALT="${2:-EHPT01_SECRET_SALT_2026}"
IS_PRODUCTION=0

for arg in "$@"; do
    if [ "$arg" == "--production" ]; then
        IS_PRODUCTION=1
    fi
done

echo "=============================================================================="
echo "[🔒] Personalizing & Hardening Lab 01 VM for Student ID: ${STUDENT_ID}"
echo "=============================================================================="

# Deterministic Flag Derivation
FLAG_LFI=$(echo -n "${STUDENT_ID}_LFI_${SECRET_SALT}" | sha256sum | cut -c1-32)
FLAG_RFI=$(echo -n "${STUDENT_ID}_RFI_${SECRET_SALT}" | sha256sum | cut -c1-32)
FLAG_TRAVERSAL=$(echo -n "${STUDENT_ID}_PATHTRAV_${SECRET_SALT}" | sha256sum | cut -c1-32)
FLAG_UPLOAD=$(echo -n "${STUDENT_ID}_UPLOAD_${SECRET_SALT}" | sha256sum | cut -c1-32)
FLAG_CMDI=$(echo -n "${STUDENT_ID}_CMDI_${SECRET_SALT}" | sha256sum | cut -c1-32)

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

echo "[+] Step 4: Injecting personalized cryptographic flags into target locations..."
# LFI Flag in Document Center
cat << EOF > /srv/labs/lab01/data/documents/security_guidelines.txt
=== NexaCorp Information Security Guidelines ===

1. Passwords must be at least 12 characters and changed every 90 days.
2. Remote access is strictly permitted through official VPN connections only.
3. System administrators must monitor PHP-FPM pool logs regularly.
4. Open ports and diagnostic endpoints are restricted to authorized subnets.

Personalized Verification Flag:
FLAG{${FLAG_LFI}}
EOF

# Path Traversal Flag in Profile Reports
cat << EOF > /srv/labs/lab01/data/reports/report.pdf
Employee Evaluation Report - John Smith (Systems Analyst)
Department: IT Infrastructure
Status: Meets Expectations
Personalized Path Traversal Flag: FLAG{${FLAG_TRAVERSAL}}
EOF

# Upload Marker Flag
echo "FLAG{${FLAG_UPLOAD}}" > /srv/labs/lab01/public/uploads/.upload_marker
echo "FLAG{${FLAG_RFI}}" > /srv/labs/lab01/public/uploads/.rfi_marker

# Command Injection Flag (System Root Path)
echo "FLAG{${FLAG_CMDI}}" > /etc/lab_cmdi_flag
chmod 644 /etc/lab_cmdi_flag

echo "[+] Step 5: Binding VM Identity & Generating Metadata..."
BUILD_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
MACHINE_HASH="N/A"
if [ -f /etc/machine-id ]; then
    MACHINE_HASH=$(sha256sum /etc/machine-id | cut -c1-32)
fi

# Write metadata file for web portal
cat << EOF > /srv/labs/lab01/data/.studentinfo
STUDENT_ID=${STUDENT_ID}
BUILD_TIME=${BUILD_TIME}
EOF

# Write hidden .buildinfo for anti-cheat verification
cat << EOF > /srv/labs/lab01/.buildinfo
STUDENT_ID=${STUDENT_ID}
BUILD_TIMESTAMP=${BUILD_TIME}
MACHINE_HASH=${MACHINE_HASH}
FLAG_LFI=FLAG{${FLAG_LFI}}
FLAG_RFI=FLAG{${FLAG_RFI}}
FLAG_TRAVERSAL=FLAG{${FLAG_TRAVERSAL}}
FLAG_UPLOAD=FLAG{${FLAG_UPLOAD}}
FLAG_CMDI=FLAG{${FLAG_CMDI}}
EOF

echo "[+] Step 6: Hardening file system ownership & access control (Anti-Tamper)..."
# Group membership for web server process
if id -u apache >/dev/null 2>&1; then
    usermod -aG lab01 apache
elif id -u www-data >/dev/null 2>&1; then
    usermod -aG lab01 www-data
fi

# Ownership set to root:lab01 to prevent modification by web user lab01 or local unprivileged users
chown -R root:lab01 /srv/labs/lab01

# Permissions:
# Root has full access (7), lab01 service has read/exec (5), Others have NO ACCESS (0)
chmod 750 /srv/labs/lab01 /srv/labs/lab01/public /srv/labs/lab01/data /srv/labs/lab01/sessions
chmod 700 /srv/labs/lab01/.buildinfo

# Files read-only for lab01 group, inaccessible to others
find /srv/labs/lab01/public -type f -not -path "*/uploads/*" -exec chmod 640 {} \;
find /srv/labs/lab01/data -type f -exec chmod 640 {} \;

# Only public/uploads is writable by lab01 process
chown -R lab01:lab01 /srv/labs/lab01/public/uploads
chmod 770 /srv/labs/lab01/public/uploads
chmod 644 /srv/labs/lab01/public/uploads/.upload_marker /srv/labs/lab01/public/uploads/.rfi_marker

echo "[+] Step 7: Setting Hostname & Appliance Boot Banner..."
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
  Portal Access URL   : http://<VM_IP>:8081 or http://employeeportal.local:8081
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

echo "[+] Step 10: Configuring /etc/hosts mapping..."
if ! grep -q "employeeportal.local" /etc/hosts; then
    echo "127.0.0.1 employeeportal.local" >> /etc/hosts
fi

echo "[+] Step 11: Reloading web services..."
systemctl reload php-fpm || systemctl restart php-fpm || systemctl reload php8.3-fpm || systemctl reload php8.2-fpm || true
systemctl reload httpd || systemctl restart httpd || systemctl reload apache2 || systemctl restart apache2 || true

# Production Purge Mode: Clean source repository, setup scripts, and instructor tools from VM image
if [ "$IS_PRODUCTION" -eq 1 ]; then
    echo "[+] Step 12: Executing Production Security Purge (Removing build scripts & salt tools)..."
    rm -f "${SCRIPT_DIR}/setup.sh"
    rm -f "${SCRIPT_DIR}/generate_student_flags.py"
    rm -rf "${SCRIPT_DIR}/.git"
    echo "    Purged setup.sh, generate_student_flags.py, and .git history from VM image."
fi

echo "=============================================================================="
echo "[🎉] Black-Box Appliance Lab 01 Provisioned & Hardened for ${STUDENT_ID}!"
echo "     Portal URL: http://employeeportal.local:8081"
echo "     Access Mode: Network-only Black-Box"
echo "=============================================================================="
