# Lab 01: NexaCorp Enterprise Employee Portal (Ethical Hacking Lab)

This repository contains the complete source code, isolation configs, setup scripts, and instructor verification tools for **Lab 01**.

## Appliance Hardening & Anti-Tampering Model

To ensure students **never have direct file system access to lab files, source code, or flags**, Lab 01 is deployed as a **Hardened Black-Box Virtual Appliance**:

1. **Instructor-Prepared Template**: The instructor runs `prepare_template_vm.sh` once. This locks down the VM, hides the instructor account (`cyberlabs`) from the login screen, and moves all sensitive repo files to `/opt/lab01-setup/` (`root:root 700`), completely invisible to students.
2. **Automated GUI First-Boot Setup**: The student receives the VM and logs into a low-privileged `student` account. A GNOME autostart `zenity` popup appears automatically to ask for their Student ID, provisions the lab using restricted `sudo`, and then the wizard self-deletes. 
3. **Anti-Tamper Permissions (`root:lab01`)**: All files under `/srv/labs/lab01` are owned by `root:lab01` with strict `750`/`640` permissions. The web application process `lab01` has read-only access to source code and cannot rewrite files. Flags like `/etc/lab_cmdi_flag` are secured as `root:lab01 640` to prevent direct shell access.
4. **Cryptographic Flag Binding**: Flags are derived dynamically from `sha256(STUDENT_ID + VULN_TYPE + SECRET_SALT)`. The salt is stored in `/etc/lab01.conf` (`root:root 600`).
5. **Network-Only Black-Box Access**: Students interact with the web app exclusively over HTTP (`http://<VM_IP>:8081`). 

## Quick Start (Instructor Setup)

```bash
# 1. Clone repository
git clone https://github.com/Abdelrhman-Mohamedd/EHPT_01.git
cd EHPT_01

# 2. Prepare the Template VM (Run Once)
sudo ./prepare_template_vm.sh

# 3. Export VM and distribute to students
```

See [APPLIANCE_HARDENING_GUIDE.md](APPLIANCE_HARDENING_GUIDE.md) and [ROCKY_SETUP_GUIDE.md](ROCKY_SETUP_GUIDE.md) for complete details.
