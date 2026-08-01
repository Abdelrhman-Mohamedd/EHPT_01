# Black-Box Appliance Hardening & Anti-Tampering Guide (Lab 01)

To ensure students **cannot access, cheat, read source flags directly, or tamper with lab files**, Lab 01 is designed to be distributed as a **Hardened Black-Box Virtual Appliance** (similar to CTF environments on HackTheBox or VulnHub).

---

## 🔒 4-Layer Anti-Tampering & Anti-Cheating Protection

### Layer 1: Network-Only Appliance Model & UI Isolation
- The VM boots into GDM. The instructor account (`cyberlabs`) is hidden from the login screen.
- Students log in as `student` (a low-privileged user).
- A Zenity UI (`first_boot_setup.sh`) prompts for their Student ID, runs the provisioning script in the background via restricted `sudo`, and then self-deletes.
- Root and user console logins (via SSH) are disabled for students.
- Students interact with the lab **strictly over the network** from their host OS or Kali Linux attack VM via HTTP (`http://<VM_IP>:8081`).

### Layer 2: Strict File Ownership & Group Isolation (`root:lab01`)
- All lab source files under `/srv/labs/lab01` are owned by `root:lab01`.
- Permission mask set to `750` for directories and `640` for PHP application files. Subdirectories inside `public/` are set to `750`.
- Target files like `/etc/lab_cmdi_flag`, `.upload_marker`, and `.rfi_marker` are owned by `root:lab01` or `lab01:lab01` with `640` permissions, so they can only be read by the web server process, not by a student's bash shell.
- Even if a student gains remote code execution as web user `lab01`, user `lab01` has **read-only access** to the PHP source files (`root:lab01 640`). They **cannot tamper with, rewrite, or deface** the web application source code.
- Only `/srv/labs/lab01/public/uploads/` is writable (`770`) for testing the File Upload vulnerability.

### Layer 3: Instructor Tool & Build Script Purging/Hiding
- The entire `EHPT_01` repository is moved to `/opt/lab01-setup/` and owned by `root:root` with `700` permissions. The `student` user gets a `Permission denied` error if they try to read or list it.
- The `SECRET_SALT` is stored in `/etc/lab01.conf` (`root:root 600`), completely invisible to the student. The GUI wizard (`first_boot_setup.sh`) contains no salt or sensitive data.
- The `sudoers` rule strictly limits the `student` user to executing `/opt/lab01-setup/setup.sh`.
- Build scripts and git history are completely hidden or purged.

### Layer 4: Cryptographic Flag Binding
- Flags are deterministically generated from `sha256(STUDENT_ID + VULN_TYPE + SECRET_SALT)`.
- A flag copied from a classmate will not match the instructor's lookup verification tool.

---

## ⚙️ How the Instructor Prepares & Exports Student VMs

When preparing a VM for a student:

### 1. Provision & Personalize the VM
On the template VM, execute `prepare_template_vm.sh`:

```bash
# Syntax: sudo ./prepare_template_vm.sh [SECRET_SALT]
sudo ./prepare_template_vm.sh
```

This command automatically:
1. Creates the `student` user and hides the instructor account from GDM.
2. Relocates the repository to `/opt/lab01-setup/` and sets up `/etc/lab01.conf`.
3. Sets up the GUI autostart wizard (`first_boot_setup.sh`) for the `student` user.
4. Locks the root account.

### 2. Lock Down OS Console & Export VM
1. Change the student password:
   ```bash
   sudo passwd student
   ```
2. Export the VM to `.OVA` or `.qcow2` format and distribute it to the student.

---

## 📊 Grading Submitted Reports

On the instructor's machine (which retains the `SECRET_SALT`):

```bash
# View expected flags for student
./generate_student_flags.py abdelrhman_h_2026

# Verify submitted flag string
./generate_student_flags.py abdelrhman_h_2026 --verify FLAG{5b03425554da4aede733fb9f1fcf83b7}
```
