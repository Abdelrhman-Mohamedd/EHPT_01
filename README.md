# Lab 01: NexaCorp Enterprise Employee Portal (Ethical Hacking Lab)

This repository contains the complete source code, isolation configs, setup scripts, and instructor verification tools for **Lab 01**.

## Appliance Hardening & Anti-Tampering Model

To ensure students **never have direct file system access to lab files, source code, or flags**, Lab 01 is deployed as a **Hardened Black-Box Virtual Appliance**:

1. **Network-Only Black-Box Access**: Students interact with the web app exclusively over HTTP (`http://<VM_IP>:8081`). No console/SSH access is provided.
2. **Anti-Tamper Permissions (`root:lab01`)**: All files under `/srv/labs/lab01` are owned by `root:lab01` with strict `750`/`640` permissions. The web application process `lab01` has read-only access to source code and cannot rewrite files.
3. **Cryptographic Flag Binding**: Flags are derived dynamically from `sha256(STUDENT_ID + VULN_TYPE + SECRET_SALT)`.
4. **Production Security Purge**: Running `./setup.sh <STUDENT_ID> --production` purges build scripts, secret keys, and git history from the guest VM disk before export.

## Quick Start (Instructor Setup)

```bash
# Provision student VM in production mode
sudo ./setup.sh abdelrhman_h_2026 EHPT01_SECRET_SALT_2026 --production

# Verify student flags (on instructor system)
./generate_student_flags.py abdelrhman_h_2026
```

See [APPLIANCE_HARDENING_GUIDE.md](APPLIANCE_HARDENING_GUIDE.md) and [RUBRIC.md](RUBRIC.md) for complete details.
