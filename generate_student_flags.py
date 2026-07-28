#!/usr/bin/env python3
"""
Instructor Tool: Student Flag Generator & Submission Verifier for Lab 01
Uses SHA-256 HMAC-style deterministic key derivation matching setup.sh logic.
"""

import sys
import hashlib
import argparse

DEFAULT_SALT = "EHPT01_SECRET_SALT_2026"

def derive_flag(student_id: str, vuln_type: str, salt: str = DEFAULT_SALT) -> str:
    seed = f"{student_id}_{vuln_type}_{salt}".encode('utf-8')
    digest = hashlib.sha256(seed).hexdigest()[:32]
    return f"FLAG{{{digest}}}"

def get_student_flags(student_id: str, salt: str = DEFAULT_SALT) -> dict:
    return {
        "LFI": derive_flag(student_id, "LFI", salt),
        "RFI": derive_flag(student_id, "RFI", salt),
        "TRAVERSAL": derive_flag(student_id, "PATHTRAV", salt),
        "UPLOAD": derive_flag(student_id, "UPLOAD", salt),
        "CMDI": derive_flag(student_id, "CMDI", salt)
    }

def main():
    parser = argparse.ArgumentParser(description="Lab 01 Student Flag Generator & Anti-Cheat Verifier")
    parser.add_argument("student_id", nargs="?", help="Student ID (e.g., abdelrhman_h_2026)")
    parser.add_argument("--salt", default=DEFAULT_SALT, help="Course secret salt")
    parser.add_argument("--verify", help="Flag string to verify against student ID")

    args = parser.parse_args()

    if args.verify and args.student_id:
        flags = get_student_flags(args.student_id, args.salt)
        matched = [k for k, v in flags.items() if v == args.verify or v.strip('FLAG{}') == args.verify.strip('FLAG{}')]
        if matched:
            print(f"[✅] MATCH SUCCESSFUL! Student '{args.student_id}' owns flag for vulnerability: {matched[0]}")
            sys.exit(0)
        else:
            print(f"[❌] INVALID FLAG! Flag does NOT belong to student '{args.student_id}'. Plagiarism/sharing alert!")
            sys.exit(1)

    if not args.student_id:
        parser.print_help()
        sys.exit(1)

    flags = get_student_flags(args.student_id, args.salt)
    print(f"==============================================================================")
    print(f"  Lab 01 Expected Flags for Student: {args.student_id}")
    print(f"  Secret Salt: {args.salt}")
    print(f"==============================================================================")
    for vuln, flag in flags.items():
        print(f"  {vuln:<10}: {flag}")
    print(f"==============================================================================")

if __name__ == "__main__":
    main()
