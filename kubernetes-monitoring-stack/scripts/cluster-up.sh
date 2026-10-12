#!/usr/bin/env bash

set -euo pipefail

CLUSTER_NAME="monitoring"
CONFIG_FILE="kind/cluster.yaml"

echo "==> Checking required tools..."

command -v kind >/dev/null 2>&1 || {
  echo "ERROR: kind is not installed."
  exit 1
}

command -v kubectl >/dev/null 2>&1 || {
  echo "ERROR: kubectl is not installed."
  exit 1
}

echo "==> Checking existing cluster..."

if kind get clusters | grep -qx "${CLUSTER_NAME}"; then
  echo "Cluster '${CLUSTER_NAME}' already exists."
else
  echo "==> Creating kind cluster '${CLUSTER_NAME}'..."
  kind create cluster \
    --name "${CLUSTER_NAME}" \
    --config "${CONFIG_FILE}"
fi

echo "==> Selecting Kubernetes context..."

kubectl config use-context "kind-${CLUSTER_NAME}"

echo "==> Waiting for node..."

kubectl wait \
  --for=condition=Ready \
  node \
  --all \
  --timeout=180s

echo
echo "==> Cluster ready."
kubectl get nodes
