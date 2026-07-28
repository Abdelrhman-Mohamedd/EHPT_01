# Black-Box Appliance Hardening & Anti-Tampering Guide (Lab 01)

To ensure students **cannot access, cheat, read source flags directly, or tamper with lab files**, Lab 01 is designed to be distributed as a **Hardened Black-Box Virtual Appliance** (similar to CTF environments on HackTheBox or VulnHub).

---

## 🔒 4-Layer Anti-Tampering & Anti-Cheating Protection

### Layer 1: Network-Only Appliance Model (No Local Console Access)
- The VM boots directly into a clean login screen displaying the IP address and web portal URL (`http://<VM_IP>:8081`).
- Root and user console logins are locked or disabled for students.
- Students interact with the lab **strictly over the network** from their host OS or Kali Linux attack VM.

### Layer 2: Strict File Ownership & Group Isolation (`root:lab01`)
- All lab source files under `/srv/labs/lab01` are owned by `root:lab01`.
- Permission mask set to `750` for directories and `640` for PHP application files.
- `Others` (any student shell user account on the VM) have **`0` access** (cannot read, list, enter, or modify `/srv/labs/lab01`).
- Even if a student gains remote code execution as web user `lab01`, user `lab01` has **read-only access** to the PHP source files (`root:lab01 640`). They **cannot tamper with, rewrite, or deface** the web application source code.
- Only `/srv/labs/lab01/public/uploads/` is writable (`770`) for testing the File Upload vulnerability.

### Layer 3: Instructor Tool & Build Script Purging
- Build scripts (`setup.sh`, `generate_student_flags.py`, `.git` directory) are **purged from the student VM image** during final image production.
- The `SECRET_SALT` and flag derivation script exist **only on the instructor's host system**.
- Flags in target locations (e.g. `/etc/lab_cmdi_flag`, `security_guidelines.txt`) are personalized SHA-256 hashes generated dynamically per student ID.

### Layer 4: Cryptographic Flag Binding
- Flags are deterministically generated from `sha256(STUDENT_ID + VULN_TYPE + SECRET_SALT)`.
- A flag copied from a classmate will not match the instructor's lookup verification tool.

---

## ⚙️ How the Instructor Prepares & Exports Student VMs

When preparing a VM for a student:

### 1. Provision & Personalize the VM
On the template VM, execute `setup.sh` with the `--production` flag:

```bash
# Syntax: sudo ./setup.sh <STUDENT_ID> [SECRET_SALT] --production
sudo ./setup.sh abdelrhman_h_2026 EHPT01_SECRET_SALT_2026 --production
```

This command automatically:
1. Injects personalized SHA-256 flags into target locations.
2. Applies `root:lab01` anti-tamper permissions (`chmod 750` / `640`).
3. Purges `setup.sh`, `generate_student_flags.py`, and `.git` from the guest file system.

### 2. Lock Down OS Console & Export VM
1. Lock root password:
   ```bash
   sudo passwd -l root
   ```
2. Export the VM to `.OVA` or `.qcow2` format and distribute it to the student.

---

## 📊 Grading Submitted Reports

On the instructor's machine:

```bash
# View expected flags for student
./generate_student_flags.py abdelrhman_h_2026

# Verify submitted flag string
./generate_student_flags.py abdelrhman_h_2026 --verify FLAG{5b03425554da4aede733fb9f1fcf83b7}
```
