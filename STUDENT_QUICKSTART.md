# Student Quick-Start Guide

Welcome to **Lab 01: NexaCorp Employee Portal** — your personalized ethical hacking environment.

---

## 🚀 What To Do When You First Boot This VM

### 1. Login
Log in with the credentials provided by your instructor:
- **Username:** `cyberlabs`
- **Password:** *(provided by instructor)*

### 2. Enter Your Student ID
Immediately after login, you will see a setup wizard:

```
╔══════════════════════════════════════════════════════════════════╗
║          NexaCorp Ethical Hacking Lab — First Boot Setup         ║
╚══════════════════════════════════════════════════════════════════╝

Enter your Student ID (e.g. 231027680):
```

Type your Student ID exactly as assigned, press **Enter**, then confirm with `yes`.

### 3. Wait ~30 seconds
The lab provisions automatically. When complete, you'll see your portal URL:

```
Portal URL: http://<VM_IP>:8081
```

### 4. Start Hacking!
Open a browser and navigate to `http://<VM_IP>:8081`.
Your task is to find and exploit all 5 vulnerabilities in the NexaCorp Employee Portal.

---

## ❓ FAQ

**Q: Can I run `sudo` to look around?**
No. This VM is locked down — the only `sudo` permission you have is the one-time lab setup, and that has already run.

**Q: I typed my Student ID wrong — what do I do?**
Contact your instructor. The first-boot wizard only runs once.

**Q: Where is the portal?**
At `http://<VM_IP>:8081` from your browser (on your host OS or a Kali VM on the same network).
