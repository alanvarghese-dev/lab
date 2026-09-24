#!/usr/bin/env bash

set -euo pipefail

echo "================================="
echo "Running Gitleaks..."
echo "================================="

mise exec -- gitleaks dir . --verbose

echo "================================="
echo "Security scan completed successfully."
echo "================================="

echo "================================="
echo "Running Semgrep..."
echo "================================="

mise exec -- semgrep scan \
  --config security/semgrep.yml \
  .

echo "================================="
echo "Security scans completed."
echo "================================="

echo "================================="
echo "Running pip-audit..."
echo "================================="

mise exec -- uv tool run pip-audit -r requirements.txt

echo "================================="
echo "Security scans completed."
echo "================================="
