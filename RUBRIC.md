# Lab 01 Assessment & Anti-Cheating Grading Rubric: Employee Portal Penetration Test

## Lab Overview
- **Scenario:** NexaCorp Enterprise Employee Portal Audit
- **Target URL:** `http://employeeportal.local:8081`
- **Build Isolation:** Per-student VM build with cryptographic flag binding
- **Total Points:** 100 Points

---

## Anti-Cheating & Report Submission Requirements

Because each VM is generated with build-time identity binding, students must strictly adhere to the following evidence submission rules:

### Mandatory Proof-of-Work Rules
1. **Cryptographic Flag Verification**:
   - Every flag submitted in the report must match the student's unique SHA-256 derived flag string (verified via instructor lookup tool `generate_student_flags.py`).
   - Submitting flags belonging to another student results in an **instant grade of zero (0/100)** and a plagiarism referral.

2. **Uncropped Screenshot Proof**:
   - Screenshots of command execution (e.g., Command Injection, File Upload, LFI) must show the **full terminal prompt displaying the student's assigned hostname** (e.g., `lab01-abdelrhman-h-2026`).
   - Browser screenshots must show the **portal header/footer displaying the assigned Student ID**.

3. **Plagiarism & Buildinfo Checks**:
   - All written exploit narratives are evaluated using report similarity checks.
   - Submitted `.buildinfo` metadata hashes are cross-checked across all submissions to detect VM image sharing.

---

## Grading Breakdown

| Category | Description | Points |
| :--- | :--- | :---: |
| **1. Executive Summary & Methodology** | High-level summary, scope verification, tool usage, methodology structure | 15 pts |
| **2. Vulnerability Findings & PoCs** | Technical identification, steps to reproduce, screenshot proof with student ID, & valid flag submission | 50 pts |
| **3. Root Cause Analysis** | Explaining underlying code flaws, PHP configuration misconfigurations | 15 pts |
| **4. Remediation & Hardening** | Actionable code fixes, PHP-FPM pool hardening, defense-in-depth | 20 pts |
| **Total** | | **100 pts** |

---

## Detailed Evaluation Criteria

### 1. Executive Summary & Discovery Methodology (15 Points)
- **15-13 Points:** Clear executive overview suitable for non-technical leadership. Systematic enumeration process documented (dir busting/crawling, parameter discovery).
- **12-8 Points:** Acceptable summary, basic description of discovery methodology.
- **7-0 Points:** Missing executive summary or incomplete enumeration narrative.

---

### 2. Vulnerability Findings & Proof-of-Concept (50 Points total / 10 pts each)

#### A. Document Center — Local File Inclusion (LFI) (10 Points)
- **Target Endpoint:** `document_center.php?doc=...`
- **Criteria:**
  - Identifies `include("../data/documents/" . $doc)` vulnerability.
  - Demonstrates traversal to system files (e.g. `/etc/passwd`) or PHP wrappers (e.g. `php://filter/read=convert.base64-encode/resource=...`).
  - Obtains student's unique LFI flag: `FLAG{<student_lfi_hash>}`.

#### B. IT Tools — Remote File Inclusion (RFI) (10 Points)
- **Target Endpoint:** `config_loader.php?template=...`
- **Criteria:**
  - Identifies dynamic `include($template . '.php')` with `allow_url_include = On`.
  - Demonstrates execution of remote payload (using `attacker_helper.py` or local HTTP listener).
  - Obtains student's unique RFI flag: `FLAG{<student_rfi_hash>}`.

#### C. Profile Management — Path Traversal (10 Points)
- **Target Endpoint:** `download_report.php?file=...`
- **Criteria:**
  - Distinguishes path traversal (`readfile()`) from code inclusion (`include()`).
  - Demonstrates reading restricted files outside `reports/` directory.
  - Obtains student's unique Path Traversal flag: `FLAG{<student_pathtrav_hash>}`.

#### D. HR Portal — Unrestricted File Upload (10 Points)
- **Target Endpoint:** `upload_resume.php` / `hr_portal.php`
- **Criteria:**
  - Notes absence of extension validation in `move_uploaded_file()`.
  - Uploads executable `.php` file (e.g. webshell) into `/srv/labs/lab01/public/uploads/`.
  - Demonstrates code execution by navigating to `/uploads/<uploaded_file>.php` and reads `.upload_marker`.
  - Obtains student's unique Upload flag: `FLAG{<student_upload_hash>}`.

#### E. IT Tools — Command Injection (10 Points)
- **Target Endpoint:** `network_diagnostics.php` (POST parameter `host`)
- **Criteria:**
  - Identifies unsanitized shell concatenation in `shell_exec("ping -c 4 " . $host)`.
  - Demonstrates command chain/injection payload (e.g. `8.8.8.8; cat /etc/lab_cmdi_flag`).
  - Obtains student's unique Command Injection flag: `FLAG{<student_cmdi_hash>}`.

---

### 3. Root Cause Analysis (15 Points)
- **15-13 Points:** Accurately explains root cause for all 5 vulnerabilities, including PHP-FPM configuration factors (`allow_url_include = On`, `disable_functions` empty).
- **12-8 Points:** Explains root causes for most vulnerabilities but misses configuration interaction.
- **7-0 Points:** Shallow explanation or incorrect technical details.

---

### 4. Remediation & Secure Coding Recommendations (20 Points)
- **20-17 Points:** Provides secure PHP code snippets for each endpoint:
  - Input sanitization & allowlisting (e.g. `basename()`, `in_array()`).
  - Replacing `shell_exec` with parameterized functions or strict regex (`filter_var($host, FILTER_VALIDATE_IP)`).
  - Restricting upload extensions & storing uploads outside web root.
  - Recommended PHP-FPM pool hardening (`allow_url_include = Off`, `disable_functions = exec,shell_exec,system`).
- **16-10 Points:** Generic recommendations without specific code fixes.
- **9-0 Points:** Minimal or missing remediation advice.
