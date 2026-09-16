<div style="text-align: center; margin-top: 50px;">
  <h1 style="color: #2c3e50; font-size: 3em; border-bottom: 2px solid #3498db; padding-bottom: 10px;">NexaCorp Employee Portal</h1>
  <h2 style="color: #7f8c8d; font-weight: 300;">Ethical Hacking Lab 01 &mdash; Student Manual</h2>
</div>

<br><br>

<div style="background-color: #ecf0f1; padding: 20px; border-left: 5px solid #e74c3c; border-radius: 5px;">
  <h3 style="margin-top: 0; color: #c0392b;">🚨 Rules of Engagement</h3>
  <ul>
    <li><strong>Target Scope:</strong> You may only attack the NexaCorp Employee Portal hosted at <code>http://&lt;VM_IP&gt;:8081</code>.</li>
    <li><strong>Out of Scope:</strong> Do NOT attempt to brute-force SSH, attack the host operating system, or escalate privileges on the <code>student</code> account. The vulnerabilities are entirely within the web application.</li>
    <li><strong>Integrity:</strong> Flags are cryptographically bound to your Student ID. Submitting a flag belonging to another student will result in an automatic failure.</li>
  </ul>
</div>

---

## 🏢 Scenario

You have been hired as a Junior Penetration Tester by **NexaCorp**. Your first assignment is to perform a security assessment of their new internal Employee Portal before it goes live to the entire company.

The developers claim the portal is "secure by design," but your manager suspects otherwise. Your objective is to **identify and exploit security vulnerabilities** hidden within the normal features of the portal, locate the hidden verification flags, and document your findings in a professional penetration testing report.

---

## 🎯 Lab Objectives

You must identify, exploit, and document **five (5) distinct security vulnerabilities** hidden within the portal's features. Each successful exploitation will reveal a unique `FLAG{...}` verification token bound to your Student ID.

<table style="width: 100%; border-collapse: collapse;">
  <thead>
    <tr style="background-color: #34495e; color: white;">
      <th style="padding: 10px; border: 1px solid #bdc3c7;">#</th>
      <th style="padding: 10px; border: 1px solid #bdc3c7;">Category</th>
      <th style="padding: 10px; border: 1px solid #bdc3c7;">Flag Format</th>
      <th style="padding: 10px; border: 1px solid #bdc3c7;">Points</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="padding: 10px; border: 1px solid #bdc3c7; text-align: center;">1</td>
      <td style="padding: 10px; border: 1px solid #bdc3c7;">Vulnerability A</td>
      <td style="padding: 10px; border: 1px solid #bdc3c7;"><code>FLAG{...}</code></td>
      <td style="padding: 10px; border: 1px solid #bdc3c7; text-align: center;">20</td>
    </tr>
    <tr style="background-color: #f9f9f9;">
      <td style="padding: 10px; border: 1px solid #bdc3c7; text-align: center;">2</td>
      <td style="padding: 10px; border: 1px solid #bdc3c7;">Vulnerability B</td>
      <td style="padding: 10px; border: 1px solid #bdc3c7;"><code>FLAG{...}</code></td>
      <td style="padding: 10px; border: 1px solid #bdc3c7; text-align: center;">20</td>
    </tr>
    <tr>
      <td style="padding: 10px; border: 1px solid #bdc3c7; text-align: center;">3</td>
      <td style="padding: 10px; border: 1px solid #bdc3c7;">Vulnerability C</td>
      <td style="padding: 10px; border: 1px solid #bdc3c7;"><code>FLAG{...}</code></td>
      <td style="padding: 10px; border: 1px solid #bdc3c7; text-align: center;">20</td>
    </tr>
    <tr style="background-color: #f9f9f9;">
      <td style="padding: 10px; border: 1px solid #bdc3c7; text-align: center;">4</td>
      <td style="padding: 10px; border: 1px solid #bdc3c7;">Vulnerability D</td>
      <td style="padding: 10px; border: 1px solid #bdc3c7;"><code>FLAG{...}</code></td>
      <td style="padding: 10px; border: 1px solid #bdc3c7; text-align: center;">20</td>
    </tr>
    <tr>
      <td style="padding: 10px; border: 1px solid #bdc3c7; text-align: center;">5</td>
      <td style="padding: 10px; border: 1px solid #bdc3c7;">Vulnerability E</td>
      <td style="padding: 10px; border: 1px solid #bdc3c7;"><code>FLAG{...}</code></td>
      <td style="padding: 10px; border: 1px solid #bdc3c7; text-align: center;">20</td>
    </tr>
  </tbody>
</table>

---

## 🛠️ Methodology

Approach this assessment as you would a real-world penetration test:

<div style="display: flex; flex-wrap: wrap; gap: 15px;">

<div style="flex: 1; min-width: 300px; background-color: #fdfefe; border: 1px solid #dcdde1; padding: 15px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05);">
  <h4 style="color: #2980b9; margin-top: 0;">🔍 1. Reconnaissance & Enumeration</h4>
  <p>Explore the portal like a legitimate user. Map out all pages, features, forms, and interactive elements. Take note of how the application handles user input and how data flows between the browser and server. Examine URLs, request parameters, and response headers carefully.</p>
</div>

<div style="flex: 1; min-width: 300px; background-color: #fdfefe; border: 1px solid #dcdde1; padding: 15px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05);">
  <h4 style="color: #27ae60; margin-top: 0;">🧪 2. Testing & Exploitation</h4>
  <p>Based on your reconnaissance findings, identify inputs that interact with server-side resources. Test each input for improper validation, unsafe handling, and unexpected behaviors. Think about what the server might be doing with your input behind the scenes.</p>
</div>

<div style="flex: 1; min-width: 300px; background-color: #fdfefe; border: 1px solid #dcdde1; padding: 15px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05);">
  <h4 style="color: #8e44ad; margin-top: 0;">🏁 3. Flag Collection</h4>
  <p>When you successfully exploit a vulnerability, a unique <code>FLAG{...}</code> token will appear in the server's response. Record each flag carefully — each one proves you understood and executed a specific attack technique.</p>
</div>

<div style="flex: 1; min-width: 300px; background-color: #fdfefe; border: 1px solid #dcdde1; padding: 15px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05);">
  <h4 style="color: #f39c12; margin-top: 0;">📝 4. Documentation</h4>
  <p>Document every finding as you go. A vulnerability without documentation is a vulnerability not found. Your report is graded on methodology, not just flags.</p>
</div>

</div>

---

## 💡 Tiered Hint System

If you are stuck, you may request hints from your instructor. Each tier provides progressively more detail but incurs a **point deduction** from your final score.

<table style="width: 100%; border-collapse: collapse; margin-top: 10px;">
  <thead>
    <tr style="background-color: #34495e; color: white;">
      <th style="padding: 10px; border: 1px solid #bdc3c7;">Tier</th>
      <th style="padding: 10px; border: 1px solid #bdc3c7;">Level of Detail</th>
      <th style="padding: 10px; border: 1px solid #bdc3c7;">Deduction</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="padding: 10px; border: 1px solid #bdc3c7; text-align: center; font-weight: bold;">Tier 1</td>
      <td style="padding: 10px; border: 1px solid #bdc3c7;">General category nudge — tells you what <em>type</em> of weakness to look for</td>
      <td style="padding: 10px; border: 1px solid #bdc3c7; text-align: center; color: #e67e22;">−2 pts</td>
    </tr>
    <tr style="background-color: #f9f9f9;">
      <td style="padding: 10px; border: 1px solid #bdc3c7; text-align: center; font-weight: bold;">Tier 2</td>
      <td style="padding: 10px; border: 1px solid #bdc3c7;">Narrows to a specific portal component or feature area</td>
      <td style="padding: 10px; border: 1px solid #bdc3c7; text-align: center; color: #e74c3c;">−5 pts</td>
    </tr>
    <tr>
      <td style="padding: 10px; border: 1px solid #bdc3c7; text-align: center; font-weight: bold;">Tier 3</td>
      <td style="padding: 10px; border: 1px solid #bdc3c7;">Full technique and payload guidance</td>
      <td style="padding: 10px; border: 1px solid #bdc3c7; text-align: center; color: #c0392b;">−10 pts</td>
    </tr>
  </tbody>
</table>

<p style="color: #7f8c8d; font-size: 0.85rem; margin-top: 10px;"><em>Hints are cumulative per vulnerability. Requesting all three tiers for one vulnerability costs −17 pts total for that finding.</em></p>

---

## 📝 Report Requirements

Your final submission must be a **professional penetration testing report**. Submitting just the flags is not enough; you must prove **how** you obtained them.

For **each** vulnerability, your report must include:

1. **Vulnerability Type & Location:** The class of vulnerability and where you found it in the application.
2. **Exploit Payload:** The exact URL, parameter, or HTTP request used to trigger the vulnerability.
3. **Step-by-Step Reproduction:** Clear instructions so the developers can reproduce the issue.
4. **Proof of Concept (PoC):** An uncropped screenshot showing the successful exploit and the visible `FLAG{...}` token. The screenshot must show your assigned Student ID (visible in the portal header/footer) or your VM hostname in the terminal prompt.
5. **Root Cause Analysis:** Explain *why* this vulnerability exists — what mistake did the developer make?
6. **Remediation Recommendation:** A brief explanation of how to fix the vulnerability (code fix, configuration change, or architectural improvement).

---

## 📊 Grading Summary

| Category | Points |
| :--- | :---: |
| Executive Summary & Methodology | 15 pts |
| Vulnerability Findings & PoCs (5 × 10 pts) | 50 pts |
| Root Cause Analysis | 15 pts |
| Remediation & Hardening Recommendations | 20 pts |
| **Total** | **100 pts** |

<br>

<div style="text-align: center; padding: 20px; background-color: #2c3e50; color: white; border-radius: 5px;">
  <h3 style="margin: 0;">Good luck, and hack responsibly!</h3>
</div>
