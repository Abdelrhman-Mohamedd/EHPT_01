#!/bin/bash
echo "Testing localhost..."
curl -v http://127.0.0.1:8081/ 2>&1 | grep -E "HTTP/|Connected|Failed|Timeout"

echo -e "\nTesting employeeportal.local..."
curl -v http://employeeportal.local:8081/ 2>&1 | grep -E "HTTP/|Connected|Failed|Timeout|Could not resolve"
