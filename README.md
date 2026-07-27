# Lab 01: NexaCorp Enterprise Employee Portal (Ethical Hacking Lab)

This repository contains the complete implementation of **Lab 01** for Ethical Hacking training.

## Repository Structure

```
Lab 1/
├── attacker_helper.py
├── config/
│   ├── lab01-apache.conf
│   └── lab01-php-fpm.conf
├── data/                       ← Protected outside DocumentRoot
│   ├── documents/
│   │   ├── policy.pdf
│   │   ├── security_guidelines.txt
│   │   └── welcome.txt
│   └── reports/
│       ├── q3_eval_2025.pdf
│       └── report.pdf
├── public/                     ← Apache DocumentRoot
│   ├── assets/css/style.css
│   ├── uploads/                ← Writable upload dir (kept inside public/ for web shell execution)
│   ├── config_loader.php
│   ├── default.php
│   ├── document_center.php
│   ├── download_report.php
│   ├── footer.php
│   ├── header.php
│   ├── hr_portal.php
│   ├── index.php
│   ├── it_tools.php
│   ├── network_diagnostics.php
│   ├── profile.php
│   └── upload_resume.php
├── README.md
├── RUBRIC.md
└── setup.sh
```

## Features & Vulnerabilities Included

1. **Document Center (`document_center.php`)** - Local File Inclusion (LFI) via `?doc=` (includes from `../data/documents/`)
2. **IT Tools (`config_loader.php`)** - Remote File Inclusion (RFI) via `?template=`
3. **Profile Management (`download_report.php`)** - Path Traversal (Arbitrary File Read from `../data/reports/` via `readfile()`)
4. **HR Portal (`upload_resume.php`)** - Unrestricted File Upload (uploads to `/uploads/` inside DocumentRoot)
5. **IT Diagnostics (`network_diagnostics.php`)** - Command Injection via `shell_exec()`

## Quick Start

```bash
# Provision user, directories, PHP-FPM pool, and Apache VirtualHost
sudo ./setup.sh

# (Optional) Start offline RFI helper HTTP server
./attacker_helper.py
```

Portal URL: `http://employeeportal.local:8081`

See [RUBRIC.md](RUBRIC.md) for report grading criteria.
