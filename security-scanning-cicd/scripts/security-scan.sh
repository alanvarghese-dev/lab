#!/usr/bin/env bash

set -euo pipefail

echo "================================="
echo "Running Gitleaks..."
echo "================================="

gitleaks dir . --verbose

echo "================================="
echo "Security scan completed successfully."
echo "================================="

echo "================================="
echo "Running Semgrep..."
echo "================================="

semgrep scan \
  --config security/semgrep.yml \
  .

echo "================================="
echo "Security scans completed."
echo "================================="

echo "================================="
echo "Running pip-audit..."
echo "================================="

pip-audit -r requirements.txt

echo "================================="
echo "Security scans completed."
echo "================================="
