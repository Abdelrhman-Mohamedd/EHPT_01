# Lab 01: NexaCorp Enterprise Employee Portal (Ethical Hacking Lab)

This repository contains the complete implementation of **Lab 01** for Ethical Hacking training.

## Features & Vulnerabilities Included

1. **Document Center (`document_center.php`)** - Local File Inclusion (LFI) via `?doc=`
2. **IT Tools (`config_loader.php`)** - Remote File Inclusion (RFI) via `?template=`
3. **Profile Management (`download_report.php`)** - Path Traversal (Arbitrary File Read via `readfile()`)
4. **HR Portal (`upload_resume.php`)** - Unrestricted File Upload
5. **IT Diagnostics (`network_diagnostics.php`)** - Command Injection via `shell_exec()`

## Quick Start

```bash
# Provision user, directories, PHP-FPM pool, and Apache virtualhost
sudo ./setup.sh

# (Optional) Start offline RFI helper HTTP server
./attacker_helper.py
```

Portal URL: `http://employeeportal.local:8081`

See [RUBRIC.md](RUBRIC.md) for report grading criteria.
