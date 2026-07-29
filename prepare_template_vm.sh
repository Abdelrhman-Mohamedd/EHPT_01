#!/usr/bin/env bash
# ==============================================================================
# prepare_template_vm.sh — Instructor-Run Golden Template Preparation Script
# Run this ONCE on the base Rocky Linux VM (as root) to lock it down before
# distributing to students. Students will NOT need root or sudo for anything
# except the single whitelisted setup.sh call via first_boot_setup.sh.
#
# Usage: sudo ./prepare_template_vm.sh
# ==============================================================================

set -e

if [ "$EUID" -ne 0 ]; then
    echo "[-] Please run as root: sudo ./prepare_template_vm.sh"
    exit 1
fi

STUDENT_USER="cyberlabs"
EHPT_DIR="/home/${STUDENT_USER}/EHPT_01"

echo "=============================================================================="
echo "[*] Preparing Lab 01 Black-Box Template VM"
echo "=============================================================================="

# ---- 1. Ensure student user 'cyberlabs' exists ----
echo "[+] Step 1: Creating student user '${STUDENT_USER}' (no sudo, locked password)..."
if ! id -u "$STUDENT_USER" >/dev/null 2>&1; then
    useradd -m -s /bin/bash "$STUDENT_USER"
    echo "    Created user ${STUDENT_USER}"
fi

# Ensure student is NOT in any admin/sudo groups
gpasswd -d "$STUDENT_USER" wheel 2>/dev/null || true
gpasswd -d "$STUDENT_USER" sudo  2>/dev/null || true

# Set a simple known password for the student login (instructor changes this or uses autologin)
echo "${STUDENT_USER}:labpassword" | chpasswd
echo "    Password set to: labpassword  (change this before distributing!)"

# ---- 2. Clone / update the EHPT_01 repo into student home ----
echo "[+] Step 2: Deploying EHPT_01 repository to ${EHPT_DIR}..."
if [ ! -d "$EHPT_DIR/.git" ]; then
    git clone https://github.com/Abdelrhman-Mohamedd/EHPT_01.git "$EHPT_DIR"
else
    git -C "$EHPT_DIR" pull
fi

# ---- 3. Lock setup.sh — root owns it, student cannot edit it ----
echo "[+] Step 3: Locking setup.sh so student cannot modify it..."
chown root:root "${EHPT_DIR}/setup.sh"
chmod 755 "${EHPT_DIR}/setup.sh"
chown -R root:root "${EHPT_DIR}"
chmod -R a-w "${EHPT_DIR}"
# Allow student to read/traverse the repo directory (read-only)
chmod a+rX "${EHPT_DIR}"
chmod a+rX "${EHPT_DIR}/"*
echo "    ${EHPT_DIR}/setup.sh is now root-owned and read-only for student."

# ---- 4. Install the first-boot wizard ----
echo "[+] Step 4: Installing first_boot_setup.sh wizard..."
cp "${EHPT_DIR}/first_boot_setup.sh" "/home/${STUDENT_USER}/first_boot_setup.sh"
chown root:root "/home/${STUDENT_USER}/first_boot_setup.sh"
chmod 755 "/home/${STUDENT_USER}/first_boot_setup.sh"

# Trigger it on first login via .bash_profile
PROFILE="/home/${STUDENT_USER}/.bash_profile"
if ! grep -q "first_boot_setup.sh" "$PROFILE" 2>/dev/null; then
    echo 'bash /home/cyberlabs/first_boot_setup.sh' >> "$PROFILE"
    chown "${STUDENT_USER}:${STUDENT_USER}" "$PROFILE"
fi

# ---- 5. Configure Narrowly Scoped sudoers Rule ----
echo "[+] Step 5: Configuring restricted sudoers rule..."
cat << EOF > /etc/sudoers.d/lab01-setup
# Lab 01 Restricted sudo: cyberlabs may only run setup.sh as root
# This specific path is root-owned, so the student cannot tamper with its contents.
cyberlabs ALL=(root) NOPASSWD: /home/cyberlabs/EHPT_01/setup.sh *
EOF
chmod 440 /etc/sudoers.d/lab01-setup
echo "    Sudoers rule installed at /etc/sudoers.d/lab01-setup"

# Verify sudoers syntax is valid
visudo -c -f /etc/sudoers.d/lab01-setup && echo "    Sudoers syntax OK." || echo "[!] WARNING: sudoers syntax error — fix before distributing!"

# ---- 6. Harden SSH: disable root login and password auth (optional but recommended) ----
echo "[+] Step 6: Hardening SSH configuration..."
SSHD_CONF="/etc/ssh/sshd_config"
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' "$SSHD_CONF"
systemctl reload sshd 2>/dev/null || true
echo "    Root SSH login disabled."

# ---- 7. Set appliance-mode login banner ----
echo "[+] Step 7: Setting pre-login banner..."
cat << 'BANNER' > /etc/issue.net
╔═══════════════════════════════════════════════════════════════════╗
║          NexaCorp Ethical Hacking Lab 01 — Black-Box Appliance    ║
║     Unauthorized access is strictly prohibited.                    ║
╚═══════════════════════════════════════════════════════════════════╝
Login as: cyberlabs / labpassword (change before distributing)
BANNER

# ---- 8. Lock root password to prevent su escalation ----
echo "[+] Step 8: Locking root password..."
passwd -l root
echo "    Root account is now locked. Only sudo via sudoers rule is possible."

# ---- Summary ----
echo "=============================================================================="
echo "[✅] Template VM Preparation Complete!"
echo ""
echo "     Student User    : ${STUDENT_USER} / labpassword"
echo "     First-Boot Flow : Login -> type Student ID -> lab auto-provisions"
echo "     Student Sudo    : ONLY allowed to run setup.sh (nothing else)"
echo "     Root Login      : LOCKED"
echo ""
echo "     Before distribution:"
echo "       1. Change student password:  passwd ${STUDENT_USER}"
echo "       2. Export the VM to .OVA or .qcow2 and hand out one copy per student."
echo "=============================================================================="
