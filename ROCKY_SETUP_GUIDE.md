# Step-by-Step Guide: Deploying EHPT_01 on Rocky Linux / RHEL VM

Follow these steps to provision and deploy the **Lab 01 NexaCorp Employee Portal** environment on Rocky Linux (Rocky 8 / 9).

---

## 📋 Prerequisites & Package Installation

Open a terminal on your Rocky Linux VM and install Apache (`httpd`), PHP-FPM, Git, and SELinux management tools:

```bash
# 1. Update system packages
sudo dnf update -y

# 2. Install Apache (httpd), PHP, PHP-FPM, Git, and SELinux policy management utilities
sudo dnf install -y httpd php php-fpm git policycoreutils-python-utils

# 3. Enable and start Apache and PHP-FPM services
sudo systemctl enable --now httpd php-fpm
```

---

## 🔒 Automated SELinux & Firewall Configuration

`setup.sh` handles SELinux port labeling (`8081`), directory file contexts (`httpd_sys_rw_content_t`), and permissions out-of-the-box.

If setting up firewall manually:
```bash
sudo firewall-cmd --permanent --add-port=8081/tcp
sudo firewall-cmd --reload
```

---

## 🚀 Provisioning Lab 01 with `setup.sh`

### 1. Clone the Repository to a Workspace Folder (e.g. `~/EHPT_01`)
> **Important:** Do NOT clone directly into `/srv/labs/lab01`. Clone to `~/EHPT_01` and let `setup.sh` populate `/srv/labs/lab01`.

```bash
cd ~
git clone https://github.com/Abdelrhman-Mohamedd/EHPT_01.git
cd EHPT_01
```

### 2. Run Provisioning Script with Student ID
Execute `setup.sh` as root with the target Student ID:

```bash
# Syntax: sudo ./setup.sh <STUDENT_ID> [SECRET_SALT] [--production]
sudo ./setup.sh abdelrhman_h_2026
```

### What `setup.sh` Automatically Fixes & Provisions:
1. **PHP-FPM Process Manager Fix**: Configures `pm = dynamic` in `/etc/php-fpm.d/lab01.conf` so PHP-FPM starts without exit code 78 errors.
2. **Apache Port 8081 Binding**: Adds `Listen 8081` to `/etc/httpd/conf.d/lab01.conf`.
3. **SELinux Port Labeling**: Automatically runs `semanage port -m -t http_port_t -p tcp 8081` to allow Apache to bind to port 8081.
4. **Directory Traversal Permissions**: Sets `/srv/labs/lab01` ownership to `root:lab01` and permissions to `750` so Apache (in `lab01` group) can access `/srv/labs/lab01/public` without 403 Forbidden errors.
5. **Dynamic Cryptographic Flag Binding**: Injects student-unique SHA-256 flags into target files.

---

## 🧪 Verifying the Deployment

### 1. Test Web Access
- **URL:** `http://employeeportal.local:8081` or `http://127.0.0.1:8081`

### 2. Check Services Status
```bash
sudo systemctl status httpd
sudo systemctl status php-fpm
```

### 3. Verify Flags (Instructor Tool)
```bash
./generate_student_flags.py abdelrhman_h_2026
```
