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

## 🚀 Provisioning Lab 01 Template VM

To securely deploy the lab, use the `prepare_template_vm.sh` script. This handles all file permissions, hides instructor accounts, installs the GUI wizard, and relocates sensitive files.

### 1. Clone the Repository
```bash
cd /root
git clone https://github.com/Abdelrhman-Mohamedd/EHPT_01.git
cd EHPT_01
```

### 2. Run Template Preparation Script
Execute `prepare_template_vm.sh` as root:

```bash
sudo ./prepare_template_vm.sh
```

### What `prepare_template_vm.sh` Automatically Fixes & Provisions:
1. **User Isolation**: Creates a low-privileged `student` user, and hides the `cyberlabs` instructor account from GDM.
2. **First-Boot UI**: Installs `first_boot_setup.sh` to trigger on GNOME autostart via `zenity`. Suppresses the GNOME "Welcome to Rocky Linux" initial setup wizard.
3. **Repository Hardening**: Moves the entire `EHPT_01` repo to `/opt/lab01-setup/` (`root:root 700`) so students cannot read or tamper with setup scripts.
4. **Restricted Sudo**: Grants `student` a single `sudoers` rule to run `/opt/lab01-setup/setup.sh`.
5. **Secret Salt Security**: Stores the cryptographic salt in `/etc/lab01.conf` (`root:root 600`), completely hiding it from students.

### 3. Finalize and Export
Set a password for the student account (if needed) and export the VM.
```bash
sudo passwd student
# Export the VM from your hypervisor (e.g., .OVA or .qcow2)
```

---

## 🧪 Verifying the Deployment (Student Experience)

When a student boots the exported VM:
1. Log in as `student`.
2. A Zenity GUI popup appears automatically, asking for the **Student ID**.
3. After confirming, a progress bar shows the environment provisioning in the background using restricted sudo.
4. Upon success, the script self-deletes and shows the portal URL (`http://<IP>:8081`).

---

## 🔒 Automated SELinux & Firewall Configuration

`setup.sh` handles SELinux port labeling (`8081`), directory file contexts (`httpd_sys_rw_content_t`), and permissions out-of-the-box.

If setting up firewall manually:
```bash
sudo firewall-cmd --permanent --add-port=8081/tcp
sudo firewall-cmd --reload
```
