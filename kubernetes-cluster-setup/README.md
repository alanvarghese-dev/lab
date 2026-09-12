# Kubernetes Homelab Cluster Setup

[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.x-326CE5?logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![KinD](https://img.shields.io/badge/Cluster-KinD-2560E0?logo=kubernetes&logoColor=white)](https://kind.sigs.k8s.io/)
[![Docker](https://img.shields.io/badge/Runtime-Docker-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Mise](https://img.shields.io/badge/Tooling-Mise-4A154B)](https://mise.jdx.dev/)
[![DevContainer](https://img.shields.io/badge/DevContainer-Ubuntu_24.04-blue?logo=visualstudiocode&logoColor=white)](https://containers.dev/)

A reproducible, declarative local multi-node Kubernetes homelab environment running on **KinD** (Kubernetes in Docker), provisioned within a **Dev Container / DevPod** development environment and managed via **Mise**.

---

## Table of Contents

- [Overview](#overview)
- [Architecture & Topology](#architecture--topology)
- [Repository Structure](#repository-structure)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
  - [1. Development Environment Setup](#1-development-environment-setup)
  - [2. Create the KinD Cluster](#2-create-the-kind-cluster)
  - [3. Verify Cluster Health](#3-verify-cluster-health)
  - [4. Deploy Sample Application](#4-deploy-sample-application)
  - [5. Verify & Test Workloads](#5-verify--test-workloads)
  - [6. Cluster Teardown](#6-cluster-teardown)
- [Networking & Dev Container Insights](#networking--dev-container-insights)
- [Layer-by-Layer Troubleshooting](#layer-by-layer-troubleshooting)
- [License & Reference](#license--reference)

---

## Overview

This project provides an Infrastructure-as-Code (IaC) setup for local Kubernetes exploration and testing:
- **Multi-Node Cluster**: 1 Control-Plane node and 2 Worker nodes emulated via KinD containers.
- **Containerized Dev Environment**: Preconfigured `.devcontainer` (Ubuntu 24.04) with Docker socket bind mount for seamless container-in-container orchestration.
- **Deterministic Tooling**: Version-pinned CLI utilities (`docker-cli`, `kind`, `kubectl`) managed through `mise.toml`.
- **Sample Workload**: Multi-replica Nginx deployment with a ClusterIP service for verifying pod scheduling and internal networking.
- **Troubleshooting Knowledge Base**: In-depth field notes documenting real-world networking, TLS certificates, and DNS challenges.

---

## Architecture & Topology

```
+-----------------------------------------------------------------------+
| Host Machine (macOS / Linux / Windows)                                |
|                                                                       |
|   +---------------------------------------------------------------+   |
|   | Dev Container / DevPod (Ubuntu 24.04 via Docker Socket Bind)   |   |
|   | Tooling: mise (docker-cli, kind, kubectl)                      |   |
|   +---------------------------------------------------------------+   |
|                                |                                      |
|                       Docker Engine Daemon                            |
|                                |                                      |
|   +----------------------------+----------------------------------+   |
|   | KinD Docker Network (kind bridge)                             |   |
|   |                                                               |   |
|   |  +------------------------+      +-------------------------+  |   |
|   |  | control-plane          |      | worker-1                |  |   |
|   |  | - kube-apiserver:6443  |      | - nginx pod replica 1   |  |   |
|   |  | - etcd, controller-mgr |      | - nginx pod replica 2   |  |   |
|   |  | - scheduler            |      +-------------------------+  |   |
|   |  +------------------------+      +-------------------------+  |   |
|   |                                  | worker-2                |  |   |
|   |                                  | - nginx pod replica 3   |  |   |
|   |                                  +-------------------------+  |   |
|   +---------------------------------------------------------------+   |
+-----------------------------------------------------------------------+
```

### Cluster Specification (`kind-config.yaml`)

- **API Server Binding**: `0.0.0.0`
- **Nodes**:
  - `1 x control-plane`
  - `2 x worker`

---

## Repository Structure

```text
.
├── .devcontainer/
│   ├── Dockerfile            # Custom Ubuntu 24.04 environment with mise installed
│   └── devcontainer.json     # Dev container configuration with Docker socket mount
├── docs/
│   └── errors.md             # Field guide: errors encountered, root causes & learnings
├── k8s/
│   ├── deployment.yaml       # 3-replica Nginx application deployment
│   └── service.yaml          # ClusterIP service definition routing to port 80
├── .gitignore                # Rules ignoring logs, local kubeconfigs, and editor files
├── kind-config.yaml          # 3-node KinD cluster topology definition
├── mise.toml                 # Tool version configurations (docker-cli, kind, kubectl)
└── README.md                 # Project documentation and quickstart guide
```

---

## Prerequisites

Before starting, ensure you have:

- [Docker](https://docs.docker.com/get-docker/) installed and running on your host system.
- Either:
  - **DevPod** or **VS Code with Remote - Containers extension** (recommended), or
  - [Mise](https://mise.jdx.dev/) installed locally on your host.

---

## Getting Started

### 1. Development Environment Setup

#### Option A: Using DevContainer / DevPod (Recommended)
Open this folder in VS Code or DevPod. The `.devcontainer` configuration will:
1. Build the base container (`Ubuntu 24.04`).
2. Bind-mount the host Docker socket (`/var/run/docker.sock`).
3. Install and activate `mise`.
4. Install all dependencies defined in `mise.toml`.

#### Option B: Using Mise Directly on Host
If developing directly on your host machine:
```bash
# Install tool versions specified in mise.toml
mise install

# Activate mise environment in your shell
eval "$(mise activate zsh)"  # or bash
```

Verify installed tools:
```bash
docker version
kind version
kubectl version --client
```

---

### 2. Create the KinD Cluster

Create the 3-node cluster using the configuration file:

```bash
kind create cluster --config kind-config.yaml --name kubernetes-lab
```

KinD will:
1. Pull the node image.
2. Provision the control-plane container.
3. Provision the two worker containers.
4. Bootstrap Kubernetes components (`kube-apiserver`, `etcd`, `coredns`, etc.).
5. Generate and configure your `~/.kube/config`.

---

### 3. Verify Cluster Health

Check cluster status and confirm all three nodes are `Ready`:

```bash
# Check cluster connectivity
kubectl cluster-info

# View cluster nodes
kubectl get nodes -o wide
```

Expected output:
```text
NAME                           STATUS   ROLES           AGE   VERSION
kubernetes-lab-control-plane   Ready    control-plane   1m    v1.x.x
kubernetes-lab-worker          Ready    <none>          1m    v1.x.x
kubernetes-lab-worker2         Ready    <none>          1m    v1.x.x
```

---

### 4. Deploy Sample Application

Apply the manifests located in the `k8s/` directory:

```bash
# Deploy both Deployment and Service
kubectl apply -f k8s/
```

This provisions:
- An **Nginx Deployment** configured for 3 replicas ([k8s/deployment.yaml](file:///Users/iti/Documents/My%20Mac%20Docu/HOMELAB/kubernetes-cluster-setup/k8s/deployment.yaml)).
- A **ClusterIP Service** exposing port 80 across all replicas ([k8s/service.yaml](file:///Users/iti/Documents/My%20Mac%20Docu/HOMELAB/kubernetes-cluster-setup/k8s/service.yaml)).

---

### 5. Verify & Test Workloads

#### Inspect Pod Scheduling Across Nodes
```bash
kubectl get pods -o wide
```
Observe how the Kubernetes scheduler distributes the 3 Nginx pods across `kubernetes-lab-worker` and `kubernetes-lab-worker2`.

#### Inspect the Service
```bash
kubectl get service nginx
```

#### Test End-to-End Connectivity via Port Forwarding
Forward traffic from your local environment to the ClusterIP service:
```bash
kubectl port-forward svc/nginx 8080:80
```
In another terminal, test HTTP response:
```bash
curl http://localhost:8080
```
You should see the default `"Welcome to nginx!"` HTML landing page.

---

### 6. Cluster Teardown

To delete the cluster and reclaim resources:

```bash
kind delete cluster --name kubernetes-lab
```

---

## Networking & Dev Container Insights

Running KinD inside a Dev Container creates multiple networking boundaries:

```
Mac Host  ──>  Docker Daemon  ──>  DevPod Container  ──>  KinD Nodes (Docker-in-Docker)
```

### Key Considerations

1. **`localhost` Ambiguity**:
   - `localhost` inside DevPod is not the same as `localhost` on the Docker host or inside a KinD node.
   - Published container ports exist on the Docker host interface, not automatically on another sibling container unless reached via Docker network IP or `host.docker.internal`.

2. **TLS Certificate SANs**:
   - The Kubernetes API server validates TLS against Subject Alternative Names (SANs).
   - If connecting via an IP or custom hostname not in the certificate (such as `host.docker.internal`), TLS verification will fail unless the hostname is mapped to a valid SAN (e.g. `kubernetes-lab-control-plane` via `/etc/hosts`).

3. **Cluster CA vs System Trust**:
   - KinD generates its own Certificate Authority (CA) on cluster initialization.
   - `kubectl` trusts this CA automatically because credentials are embedded in `kubeconfig`. Standard tools like `curl` require `-k` (insecure) or explicit CA path passing (`--cacert`).

---

## Layer-by-Layer Troubleshooting

When troubleshooting connectivity or cluster issues in containerized environments, troubleshoot systematically layer-by-layer:

| Step | Layer | Verification Command | Description |
| :--- | :--- | :--- | :--- |
| **1** | Docker Container | `docker ps` | Verify the control-plane container is running |
| **2** | API Server Process | `docker exec -it <control-plane> pgrep kube-apiserver` | Verify `kube-apiserver` is active inside the node |
| **3** | Listening Port | `docker exec -it <control-plane> ss -tulpn` | Confirm port `6443` is listening |
| **4** | Direct API Health | `curl -k https://<control-plane-ip>:6443/healthz` | Confirm API responds with `ok` |
| **5** | Docker Network | `docker network inspect kind` | Check subnet and container IP allocation |
| **6** | DNS / Host Resolution | `ping -c 1 kubernetes-lab-control-plane` | Check hostname resolvable from client shell |
| **7** | TLS SAN Matching | Inspect certificate SAN list | Ensure connecting host matches certificate names |
| **8** | Kubeconfig | `kubectl config view --minify` | Inspect current context, server URL, and CA data |
| **9** | Client Access | `kubectl get nodes` | Confirm authenticated client operations succeed |
| **10**| Workload Scheduling | `kubectl get pods -A -o wide` | Diagnose pod placement, scheduling, and service endpoints |

> [!TIP]
> For detailed explanations, actual errors encountered, root-cause analyses, and solutions, see [docs/errors.md](file:///Users/iti/Documents/My%20Mac%20Docu/HOMELAB/kubernetes-cluster-setup/docs/errors.md).

---

## License & Reference

This repository is maintained for homelab learning, testing, and Kubernetes experimentation. Feel free to adapt the configuration files for your own setup.
