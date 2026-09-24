#!/usr/bin/env bash

set -euo pipefail

echo "================================="
echo "Running tests..."
echo "================================="

pytest -v

echo "================================="
echo "Tests passed."
echo "================================="
