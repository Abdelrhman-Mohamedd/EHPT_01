#!/usr/bin/env bash
# ==============================================================================
# prepare_template_vm.sh — Instructor-Run Golden Template Preparation Script
# Run this ONCE on the base Rocky Linux VM (as root) to lock it down before
# distributing to students. Students will NOT need root or sudo for anything
# except the single whitelisted setup.sh call via first_boot_setup.sh.
#
# Usage: sudo ./prepare_template_vm.sh [SECRET_SALT]
# ==============================================================================

set -e

if [ "$EUID" -ne 0 ]; then
    echo "[-] Please run as root: sudo ./prepare_template_vm.sh [SECRET_SALT]"
    exit 1
fi

STUDENT_USER="student"
SECRET_SALT="${1:-EHPT01_SECRET_SALT_2026}"

# EHPT_01 repo goes to /opt/lab01-setup/ (root:root 700 — invisible to student)
EHPT_DIR="/opt/lab01-setup"

echo "=============================================================================="
echo "[*] Preparing Lab 01 Black-Box Template VM"
echo "=============================================================================="

# ---- 1. Create student user 'student' ----
echo "[+] Step 1: Creating student user '${STUDENT_USER}' (no sudo, locked password)..."
if ! id -u "$STUDENT_USER" >/dev/null 2>&1; then
    useradd -m -s /bin/bash "$STUDENT_USER"
    echo "    Created user ${STUDENT_USER}"
fi

# Ensure student is NOT in any admin/sudo groups
gpasswd -d "$STUDENT_USER" wheel 2>/dev/null || true
gpasswd -d "$STUDENT_USER" sudo  2>/dev/null || true

# Set a simple known password (instructor changes before distributing)
echo "${STUDENT_USER}:labpassword" | chpasswd
echo "    Password set to: labpassword  (change this before distributing!)"

# ---- 2. Install zenity for GUI dialogs ----
echo "[+] Step 2: Installing zenity (GUI dialog dependency)..."
dnf install -y zenity >/dev/null 2>&1 && echo "    zenity installed." || echo "    [!] zenity install failed — check DNF."

# ---- 3. Write the secret salt to /etc/lab01.conf (root:root 600 — student CANNOT read) ----
echo "[+] Step 3: Storing secret salt in /etc/lab01.conf (root-only)..."
echo "${SECRET_SALT}" > /etc/lab01.conf
chown root:root /etc/lab01.conf
chmod 600 /etc/lab01.conf
echo "    Salt stored at /etc/lab01.conf  (mode: 600 — student access: DENIED)"

# ---- 4. Clone EHPT_01 repo to /opt/lab01-setup/ (outside student home, root-only) ----
echo "[+] Step 4: Deploying EHPT_01 repo to ${EHPT_DIR} (root-only, invisible to student)..."
if [ ! -d "${EHPT_DIR}/.git" ]; then
    git clone https://github.com/Abdelrhman-Mohamedd/EHPT_01.git "$EHPT_DIR"
else
    git -C "$EHPT_DIR" pull
fi

# Root owns everything — student cannot list, read, or enter this directory
chown -R root:root "$EHPT_DIR"
chmod 700 "$EHPT_DIR"                       # directory: student access = DENIED
find "$EHPT_DIR" -type d -exec chmod 700 {} \;  # all subdirs: blocked
find "$EHPT_DIR" -type f -exec chmod 600 {} \;  # all files: blocked
chmod 500 "${EHPT_DIR}/setup.sh"            # setup.sh: root can execute via sudo; student: DENIED
echo "    ${EHPT_DIR}  mode=700 (root:root) — student cannot ls, read, or enter"
echo "    setup.sh     mode=500 (root:root) — executable only by root via sudo"

# ---- 5. Install the first-boot wizard (ONLY file student can see — contains NO salt) ----
echo "[+] Step 5: Installing first_boot_setup.sh wizard (salt-free)..."
cp "${EHPT_DIR}/first_boot_setup.sh" "/home/${STUDENT_USER}/first_boot_setup.sh"
chown root:root "/home/${STUDENT_USER}/first_boot_setup.sh"
chmod 755 "/home/${STUDENT_USER}/first_boot_setup.sh"
echo "    Installed at /home/${STUDENT_USER}/first_boot_setup.sh"
echo "    This file contains NO salt — student learns nothing from reading it."

# Trigger via GNOME autostart .desktop entry (NOT .bash_profile)
AUTOSTART_DIR="/home/${STUDENT_USER}/.config/autostart"
mkdir -p "$AUTOSTART_DIR"
cat > "${AUTOSTART_DIR}/lab01-setup.desktop" << 'DESKTOP'
[Desktop Entry]
Type=Application
Name=Lab 01 First Boot Setup
Exec=bash /home/student/first_boot_setup.sh
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Delay=3
DESKTOP
chown -R "${STUDENT_USER}:${STUDENT_USER}" "/home/${STUDENT_USER}/.config"
echo "    GNOME autostart entry created — runs after desktop loads, not on login shell."

# ---- 6. Configure Narrowly Scoped sudoers Rule (path updated to /opt/lab01-setup/) ----
echo "[+] Step 6: Configuring restricted sudoers rule..."
cat << EOF > /etc/sudoers.d/lab01-setup
# Lab 01 Restricted sudo: student may ONLY run setup.sh as root
# setup.sh lives in /opt/lab01-setup/ (root:root 500) — student cannot read or modify it.
student ALL=(root) NOPASSWD: /opt/lab01-setup/setup.sh *
EOF
chmod 440 /etc/sudoers.d/lab01-setup
visudo -c -f /etc/sudoers.d/lab01-setup && echo "    Sudoers rule OK at /etc/sudoers.d/lab01-setup" || echo "[!] sudoers syntax error!"

# ---- 7. Harden SSH: disable root login ----
echo "[+] Step 7: Hardening SSH configuration..."
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl reload sshd 2>/dev/null || true
echo "    Root SSH login disabled."

# ---- 8. Set appliance-mode login banner ----
echo "[+] Step 8: Setting pre-login banner..."
cat << 'BANNER' > /etc/issue.net
╔═══════════════════════════════════════════════════════════════════╗
║          NexaCorp Ethical Hacking Lab 01 — Black-Box Appliance    ║
║     Unauthorized access is strictly prohibited.                    ║
╚═══════════════════════════════════════════════════════════════════╝
Login as: student / labpassword (change before distributing)
BANNER

# ---- 9. Lock root password ----
echo "[+] Step 9: Locking root password..."
passwd -l root
echo "    Root account locked. Only sudo via sudoers rule is possible."

# ---- Summary ----
echo "=============================================================================="
echo "[✅] Template VM Preparation Complete!"
echo ""
echo "     Student User    : ${STUDENT_USER} / labpassword"
echo "     EHPT_01 Repo    : /opt/lab01-setup/  (root:root 700 — student cannot see)"
echo "     Secret Salt     : /etc/lab01.conf    (root:root 600 — student cannot read)"
echo "     Student Sudo    : ONLY /opt/lab01-setup/setup.sh (nothing else)"
echo "     First-Boot UI   : /home/student/first_boot_setup.sh (contains NO salt)"
echo "     Root Login      : LOCKED"
echo ""
echo "     Before distribution:"
echo "       1. Change student password:  passwd ${STUDENT_USER}"
echo "       2. Export the VM to .OVA or .qcow2 and hand out one copy per student."
echo "=============================================================================="
