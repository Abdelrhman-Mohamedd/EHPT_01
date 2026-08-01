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

The developers claim the portal is "secure by design," but your manager suspects they have introduced several classic web vulnerabilities. Your objective is to compromise the portal, locate the hidden flags, and document your findings.

---

## 🎯 Lab Objectives

You must identify, exploit, and document **five** specific vulnerability classes hidden within the normal features of the portal.

<table style="width: 100%; border-collapse: collapse;">
  <thead>
    <tr style="background-color: #34495e; color: white;">
      <th style="padding: 10px; border: 1px solid #bdc3c7;">#</th>
      <th style="padding: 10px; border: 1px solid #bdc3c7;">Vulnerability</th>
      <th style="padding: 10px; border: 1px solid #bdc3c7;">Flag Format</th>
      <th style="padding: 10px; border: 1px solid #bdc3c7;">Points</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="padding: 10px; border: 1px solid #bdc3c7; text-align: center;">1</td>
      <td style="padding: 10px; border: 1px solid #bdc3c7;"><strong>Local File Inclusion (LFI)</strong></td>
      <td style="padding: 10px; border: 1px solid #bdc3c7;"><code>FLAG{...}</code></td>
      <td style="padding: 10px; border: 1px solid #bdc3c7; text-align: center;">20</td>
    </tr>
    <tr style="background-color: #f9f9f9;">
      <td style="padding: 10px; border: 1px solid #bdc3c7; text-align: center;">2</td>
      <td style="padding: 10px; border: 1px solid #bdc3c7;"><strong>Remote File Inclusion (RFI)</strong></td>
      <td style="padding: 10px; border: 1px solid #bdc3c7;"><code>FLAG{...}</code></td>
      <td style="padding: 10px; border: 1px solid #bdc3c7; text-align: center;">20</td>
    </tr>
    <tr>
      <td style="padding: 10px; border: 1px solid #bdc3c7; text-align: center;">3</td>
      <td style="padding: 10px; border: 1px solid #bdc3c7;"><strong>Path Traversal</strong></td>
      <td style="padding: 10px; border: 1px solid #bdc3c7;"><code>FLAG{...}</code></td>
      <td style="padding: 10px; border: 1px solid #bdc3c7; text-align: center;">20</td>
    </tr>
    <tr style="background-color: #f9f9f9;">
      <td style="padding: 10px; border: 1px solid #bdc3c7; text-align: center;">4</td>
      <td style="padding: 10px; border: 1px solid #bdc3c7;"><strong>Unrestricted File Upload</strong></td>
      <td style="padding: 10px; border: 1px solid #bdc3c7;"><code>FLAG{...}</code></td>
      <td style="padding: 10px; border: 1px solid #bdc3c7; text-align: center;">20</td>
    </tr>
    <tr>
      <td style="padding: 10px; border: 1px solid #bdc3c7; text-align: center;">5</td>
      <td style="padding: 10px; border: 1px solid #bdc3c7;"><strong>Command Injection</strong></td>
      <td style="padding: 10px; border: 1px solid #bdc3c7;"><code>FLAG{...}</code></td>
      <td style="padding: 10px; border: 1px solid #bdc3c7; text-align: center;">20</td>
    </tr>
  </tbody>
</table>

---

## 🛠️ Methodology & Hints

<div style="display: flex; flex-wrap: wrap; gap: 15px;">

<div style="flex: 1; min-width: 300px; background-color: #fdfefe; border: 1px solid #dcdde1; padding: 15px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05);">
  <h4 style="color: #2980b9; margin-top: 0;">🔍 1. Reconnaissance</h4>
  <p>Start by clicking around the portal like a normal user. Pay close attention to the URLs. Are there any parameters passing file names or URLs? (e.g., <code>?page=</code>, <code>?doc=</code>, <code>?template=</code>).</p>
</div>

<div style="flex: 1; min-width: 300px; background-color: #fdfefe; border: 1px solid #dcdde1; padding: 15px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05);">
  <h4 style="color: #27ae60; margin-top: 0;">📂 2. File Inclusion & Traversal</h4>
  <p>If the application reads files from the server, try to break out of the intended directory using <code>../</code>. Can you read <code>/etc/passwd</code>? Can you include an external URL to execute code?</p>
</div>

<div style="flex: 1; min-width: 300px; background-color: #fdfefe; border: 1px solid #dcdde1; padding: 15px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05);">
  <h4 style="color: #8e44ad; margin-top: 0;">📤 3. File Uploads</h4>
  <p>The HR portal accepts resumes. What happens if you upload a PHP script instead of a PDF? Where does the file go? Can you access it directly via the browser?</p>
</div>

<div style="flex: 1; min-width: 300px; background-color: #fdfefe; border: 1px solid #dcdde1; padding: 15px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05);">
  <h4 style="color: #f39c12; margin-top: 0;">⚙️ 4. Command Injection</h4>
  <p>Look for administrative or IT tools that interact with the underlying operating system (like ping or traceroute). Can you append additional bash commands using <code>;</code> or <code>&&</code>?</p>
</div>

</div>

---

## 📝 Reporting Rubric

Your final submission must be a professional penetration testing report. Submitting just the flags is not enough; you must prove **how** you obtained them.

For **each** vulnerability, your report must include:

1. **Vulnerability Type & Location:** (e.g., "Command Injection in IT Tools page via the `ip` parameter").
2. **Exploit Payload:** The exact URL, parameter, or HTTP request used to trigger the vulnerability.
3. **Step-by-Step Reproduction:** Clear instructions so the developers can reproduce the issue.
4. **Proof of Concept (PoC):** A screenshot showing the successful exploit and the visible `FLAG{...}`.
5. **Remediation Recommendation:** A brief explanation of how to fix the vulnerability in PHP (e.g., "Use `escapeshellarg()`" or "Disable remote URL includes in `php.ini`").

<br>

<div style="text-align: center; padding: 20px; background-color: #2c3e50; color: white; border-radius: 5px;">
  <h3 style="margin: 0;">Good luck, and hack responsibly!</h3>
</div>
