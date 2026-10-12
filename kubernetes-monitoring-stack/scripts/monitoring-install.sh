#!/usr/bin/env bash

set -euo pipefail

NAMESPACE="monitoring"
RELEASE="monitoring"
CHART="prometheus-community/kube-prometheus-stack"

echo "==> Adding Prometheus Community Helm repository..."

helm repo add prometheus-community \
  https://prometheus-community.github.io/helm-charts \
  --force-update

echo "==> Updating Helm repositories..."

helm repo update

echo "==> Creating namespace if necessary..."

kubectl apply -f k8s/namespace.yaml

echo "==> Installing/upgrading monitoring stack..."

helm upgrade --install "${RELEASE}" "${CHART}" \
  --namespace "${NAMESPACE}" \
  --values helm/monitoring-values.yaml \
  --wait \
  --timeout 10m

echo
echo "==> Monitoring stack installed."
echo
helm status "${RELEASE}" \
  --namespace "${NAMESPACE}"
