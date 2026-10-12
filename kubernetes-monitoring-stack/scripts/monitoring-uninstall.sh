#!/usr/bin/env bash

set -euo pipefail

NAMESPACE="monitoring"
RELEASE="monitoring"

if helm status "${RELEASE}" -n "${NAMESPACE}" >/dev/null 2>&1; then
  echo "==> Removing monitoring Helm release..."

  helm uninstall "${RELEASE}" \
    --namespace "${NAMESPACE}"
else
  echo "Monitoring Helm release does not exist."
fi

echo "==> Removing demo workload..."

kubectl delete \
  -f k8s/test-workload.yaml \
  --ignore-not-found

echo "==> Monitoring stack removed."
