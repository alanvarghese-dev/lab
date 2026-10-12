#!/usr/bin/env bash

set -euo pipefail

echo "========================================"
echo " Kubernetes Monitoring Stack"
echo "========================================"

echo
echo "==> Cluster"
kubectl get nodes -o wide

echo
echo "==> Monitoring namespace"
kubectl get all -n monitoring

echo
echo "==> Helm release"
helm list -n monitoring

echo
echo "==> Monitoring services"
kubectl get svc -n monitoring

echo
echo "==> Prometheus resources"
kubectl get prometheus -n monitoring

echo
echo "==> Alertmanager resources"
kubectl get alertmanager -n monitoring

echo
echo "========================================"
