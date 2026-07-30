#!/usr/bin/env bash
# ==============================================================================
# first_boot_setup.sh — Student First-Boot Personalization Wizard
# Runs automatically on first login, prompts for Student ID, provisions lab,
# then removes itself from .bash_profile so it only runs once.
# ==============================================================================

SETUP_SCRIPT="/home/student/EHPT_01/setup.sh"
SALT="EHPT01_SECRET_SALT_2026"
FIRST_BOOT_FLAG="/home/student/.lab01_provisioned"
PROFILE_FILE="/home/student/.bash_profile"

# ---- Guard: only run once ----
if [ -f "$FIRST_BOOT_FLAG" ]; then
    exit 0
fi

clear
cat << 'BANNER'
╔══════════════════════════════════════════════════════════════════╗
║          NexaCorp Ethical Hacking Lab — First Boot Setup         ║
║                     Black-Box Appliance v1.0                     ║
╚══════════════════════════════════════════════════════════════════╝

Welcome to your personalized Lab 01 environment.

Before you can begin, this VM must be initialized using your unique
Student ID. This process takes approximately 30 seconds.

BANNER

# ---- Input Validation Loop ----
while true; do
    read -rp "  Enter your Student ID (e.g. 231027680): " SID
    SID="${SID// /_}"   # Replace spaces with underscores

    if [[ -z "$SID" ]]; then
        echo "  [!] Student ID cannot be empty. Please try again."
    elif [[ ! "$SID" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "  [!] Invalid characters. Only letters, digits, hyphens, and underscores are allowed."
    else
        break
    fi
done

echo ""
echo "  [*] Confirm: Your Student ID is: ${SID}"
read -rp "  Proceed? (yes/no): " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
    echo "  [!] Aborted. Please re-login and try again."
    exit 1
fi

echo ""
echo "  [+] Starting lab personalization... Please wait..."
echo ""

# ---- Run setup.sh via restricted sudo (single allowed command) ----
sudo "$SETUP_SCRIPT" "$SID" "$SALT" --production

EXIT_CODE=$?

if [ "$EXIT_CODE" -eq 0 ]; then
    # Mark as provisioned so this wizard never runs again
    touch "$FIRST_BOOT_FLAG"

    # Remove trigger from .bash_profile
    sed -i '/first_boot_setup\.sh/d' "$PROFILE_FILE" 2>/dev/null || true

    clear
    cat << DONE
╔══════════════════════════════════════════════════════════════════╗
║              Lab 01 Personalization Complete! 🎉                  ║
╚══════════════════════════════════════════════════════════════════╝

  Student ID   : ${SID}
  Portal URL   : http://$(hostname -I | awk '{print $1}'):8081
  Alternative  : http://employeeportal.local:8081

  Open a browser and navigate to the portal URL above to begin.

  Your task is to find and exploit all vulnerabilities in the
  NexaCorp Employee Portal and document your findings.

  Good luck!

══════════════════════════════════════════════════════════════════
DONE
else
    echo ""
    echo "  [!] Error: Lab provisioning failed (exit code: ${EXIT_CODE})."
    echo "      Please contact your instructor for assistance."
    exit 1
fi
