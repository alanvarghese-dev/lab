# Kubernetes Deployment Lab

[![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=flat&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=flat&logo=docker&logoColor=white)](https://www.docker.com/)
[![kind](https://img.shields.io/badge/kind-Kubernetes%20in%20Docker-blue?style=flat)](https://kind.sigs.k8s.io/)
[![Python](https://img.shields.io/badge/python-3.14--slim-3670A0?style=flat&logo=python&logoColor=ffdd54)](https://www.python.org/)
[![mise](https://img.shields.io/badge/tooling-mise-orange?style=flat)](https://mise.jdx.dev/)

An end-to-end homelab project demonstrating how to develop, containerize, deploy, and manage a Python web application on a local **kind** (Kubernetes IN Docker) cluster inside a containerized development environment (**DevPod** / **Dev Containers** on Docker Desktop).

---

## Table of Contents

- [Overview & Architecture](#overview--architecture)
- [Repository Structure](#repository-structure)
- [Prerequisites & Tooling](#prerequisites--tooling)
- [Step-by-Step Guide](#step-by-step-guide)
  - [1. Development Environment Setup](#1-development-environment-setup)
  - [2. Building and Testing the Docker Image](#2-building-and-testing-the-docker-image)
  - [3. Creating the kind Cluster with Custom SANs](#3-creating-the-kind-cluster-with-custom-sans)
  - [4. Loading Local Images into kind](#4-loading-local-images-into-kind)
  - [5. Deploying the Application to Kubernetes](#5-deploying-the-application-to-kubernetes)
  - [6. Accessing and Testing the Application](#6-accessing-and-testing-the-application)
  - [7. Zero-Downtime Rolling Update (v1 &rarr; v2)](#7-zero-downtime-rolling-update-v1--v2)
  - [8. Verifying Rollout History & Performing a Rollback](#8-verifying-rollout-history--performing-a-rollback)
- [Container & Cluster Networking Deep Dive](#container--cluster-networking-deep-dive)
- [Layer-by-Layer Troubleshooting Guide](#layer-by-layer-troubleshooting-guide)
- [Key Takeaways & Best Practices](#key-takeaways--best-practices)
- [Teardown & Cleanup](#teardown--cleanup)

---

## Overview & Architecture

This project models a real-world containerized DevOps lifecycle within a nested local environment. It covers:

1. **Packaging**: Containerizing a lightweight Python HTTP service with Docker.
2. **Infrastructure as Code**: Declarative Kubernetes manifests for Deployments and Services.
3. **Local Orchestration**: Running a multi-replica Kubernetes cluster using `kind` with TLS certificate Subject Alternative Names (SANs) configured for cross-container access.
4. **Lifecycle Management**: Rolling out zero-downtime application updates and performing instant rollbacks.
5. **Cross-Boundary Networking**: Resolving network boundaries between DevPod containers, the Docker daemon, `kind` control plane containers, and Kubernetes Pods.

### Architecture Diagram

```
+-----------------------------------------------------------------------------------+
| Host Machine (macOS / Docker Desktop)                                             |
|                                                                                   |
|  +--------------------------------+       +------------------------------------+  |
|  | DevPod / Dev Container         |       | kind Cluster (Docker Container)    |  |
|  | (Ubuntu 24.04 + mise)          |       | name: deployment-lab-control-plane |  |
|  |                                |       |                                    |  |
|  |  - kubectl                     |       |  +------------------------------+  |  |
|  |  - kind CLI                    |       |  | Kubernetes API Server (:6443)|  |  |
|  |  - docker CLI (socket mount)   | ----> |  | (certSANs:                   |  |  |
|  |  - python / curl               |       |  |   host.docker.internal)      |  |  |
|  +--------------------------------+       |  +------------------------------+  |  |
|                  |                        |                 |                  |  |
|                  | (host.docker.internal) |                 v                  |  |
|                  +----------------------> |  +------------------------------+  |  |
|                                           |  | Service (:80 / NodePort)     |  |  |
|                                           |  | selector: app=k8s-deployment |  |  |
|                                           |  +------------------------------+  |  |
|                                           |         |              |           |  |
|                                           |         v              v           |  |
|                                           |    +----------+   +----------+     |  |
|                                           |    |  Pod 1   |   |  Pod 2   |     |  |
|                                           |    |  (:8080) |   |  (:8080) |     |  |
|                                           |    +----------+   +----------+     |  |
|                                           +------------------------------------+  |
+-----------------------------------------------------------------------------------+
```

---

## Repository Structure

```text
.
├── .devcontainer/
│   ├── Dockerfile           # Dev container definition (Ubuntu 24.04 with mise)
│   └── devcontainer.json    # Dev container config mounting Docker socket
├── k8s/
│   ├── deployment.yaml      # Kubernetes Deployment (2 replicas, IfNotPresent)
│   └── service.yaml         # Kubernetes Service (NodePort, port 80 -> 8080)
├── app.py                   # Python HTTP server (v1 / v2 endpoints)
├── Dockerfile               # Production Dockerfile (python:3.14-slim)
├── kind-config.yaml         # kind Cluster manifest with certSANs kubeadm patch
├── mise.toml                # mise tool management (docker-cli, kubectl, kind, etc.)
└── .gitignore               # Ignored files and directories
```

---

## Prerequisites & Tooling

All dependencies are defined for automatic setup via [mise](https://mise.jdx.dev/) or the included `.devcontainer`:

- **Docker Desktop** (macOS or Linux)
- **mise** (or the individual CLI tools):
  - `docker-cli`
  - `kind`
  - `kubectl`
  - `python` (3.14+)
  - `node`

To install the CLI tools locally with `mise`:

```bash
mise install
mise activate
```

---

## Step-by-Step Guide

### 1. Development Environment Setup

If developing inside VS Code with Dev Containers or DevPod:
- The `.devcontainer/devcontainer.json` mounts `/var/run/docker.sock` from the host, giving the containerized IDE direct access to the Docker daemon.
- `mise` automatically manages tools inside the container through `.devcontainer/Dockerfile`.

Verify the installed tools:

```bash
docker --version
kind --version
kubectl version --client
python --version
```

---

### 2. Building and Testing the Docker Image

The application in `app.py` is a native Python HTTP server listening on `0.0.0.0:8080`.

#### Step 2.1: Build Version 1.0

Ensure `app.py` returns `Hello from Kubernetes!`:

```bash
docker build -t kubernetes-deployment:1.0 .
```

#### Step 2.2: Test Container Locally via Docker

Run a test container to verify basic functionality:

```bash
docker run -d --name kubernetes-deployment-test -p 8080:8080 kubernetes-deployment:1.0
```

Verify application response:

```bash
# From the host machine:
curl http://localhost:8080

# Or from inside a DevPod/DevContainer:
curl http://host.docker.internal:8080
```

Stop and remove the test container:

```bash
docker stop kubernetes-deployment-test && docker rm kubernetes-deployment-test
```

---

### 3. Creating the kind Cluster with Custom SANs

When connecting to `kind` from within another container (such as DevPod), `kubectl` must route through `host.docker.internal` rather than `127.0.0.1`. For this to succeed without TLS validation failures, the Kubernetes API server's certificate must include `host.docker.internal` in its Subject Alternative Names (SANs).

This is configured in `kind-config.yaml`:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
kubeadmConfigPatches:
  - |
    kind: ClusterConfiguration
    apiServer:
      certSANs:
        - host.docker.internal

nodes:
  - role: control-plane
```

Create the cluster:

```bash
kind create cluster --name deployment-lab --config kind-config.yaml
```

Verify cluster access:

```bash
kubectl cluster-info
kubectl get nodes
```

> [!NOTE]
> If connecting from inside a DevPod container, update your kubeconfig server URL to point to `https://host.docker.internal:<PORT>` where `<PORT>` is the mapped control-plane port from `docker ps`.

---

### 4. Loading Local Images into kind

Because `kind` runs Kubernetes nodes as Docker containers, images built on the Docker host daemon are **not** immediately visible inside the `kind` node runtime.

Load the built image directly into the cluster:

```bash
kind load docker-image kubernetes-deployment:1.0 --name deployment-lab
```

Verify the image is present inside the node:

```bash
docker exec deployment-lab-control-plane crictl images | grep kubernetes-deployment
```

> [!TIP]
> Always set `imagePullPolicy: IfNotPresent` in your Deployment manifest for local `kind` development. This prevents Kubernetes from failing with `ErrImagePull` when attempting to fetch locally built images from Docker Hub.

---

### 5. Deploying the Application to Kubernetes

The Kubernetes configuration is declaratively defined in `k8s/`.

#### Deployment (`k8s/deployment.yaml`)
Runs 2 replicas of the application with matching label selectors:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kubernetes-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: kubernetes-deployment
  template:
    metadata:
      labels:
        app: kubernetes-deployment
    spec:
      containers:
        - name: app
          image: kubernetes-deployment:1.0
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8080
```

#### Service (`k8s/service.yaml`)
Exposes the Pods via a stable network endpoint using `NodePort`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: kubernetes-deployment-service
spec:
  selector:
    app: kubernetes-deployment
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
      nodePort: 30080
  type: NodePort
```

Apply both manifests:

```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

Verify the Deployment, Pods, and Service:

```bash
kubectl get deployments
kubectl get pods -o wide
kubectl get svc kubernetes-deployment-service
kubectl get endpoints kubernetes-deployment-service
```

---

### 6. Accessing and Testing the Application

#### Option A: Port Forwarding (Recommended for Local Testing)

Forward local port `8080` to the Service's port `80`:

```bash
kubectl port-forward service/kubernetes-deployment-service 8080:80
```

In another terminal, test the endpoint:

```bash
curl http://localhost:8080
# Output: Hello from Kubernetes!
```

#### Option B: Accessing via NodePort

Since the service exposes `nodePort: 30080`, you can query the node directly or forward traffic through the control-plane container.

---

### 7. Zero-Downtime Rolling Update (v1 &rarr; v2)

Kubernetes Deployments natively handle rolling updates, gradually spinning up new Pods while terminating old ones to ensure zero downtime.

#### Step 7.1: Update Application Code

Update `app.py` to change the response message:

```python
message = "Hello from Kubernetes v2!"
```

#### Step 7.2: Build and Load Image v2.0

```bash
# Build the new image
docker build -t kubernetes-deployment:2.0 .

# Load the image into the kind cluster
kind load docker-image kubernetes-deployment:2.0 --name deployment-lab
```

#### Step 7.3: Trigger the Rolling Update

Update the Deployment image:

```bash
kubectl set image deployment/kubernetes-deployment app=kubernetes-deployment:2.0
```

#### Step 7.4: Monitor the Rollout

Track rollout progress in real time:

```bash
kubectl rollout status deployment/kubernetes-deployment
```

Test the updated application:

```bash
curl http://localhost:8080
# Output: Hello from Kubernetes v2!
```

---

### 8. Verifying Rollout History & Performing a Rollback

Kubernetes retains revision history, allowing immediate rollback if an issue is detected in a new release.

#### Step 8.1: Inspect Rollout History

```bash
kubectl rollout history deployment/kubernetes-deployment
```

Output:
```text
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
```

To see details of a specific revision:

```bash
kubectl rollout history deployment/kubernetes-deployment --revision=1
```

#### Step 8.2: Undo the Rollout (Rollback to v1)

Revert to the previous stable revision:

```bash
kubectl rollout undo deployment/kubernetes-deployment
```

Monitor rollback progress:

```bash
kubectl rollout status deployment/kubernetes-deployment
```

Verify that the application has returned to version 1:

```bash
curl http://localhost:8080
# Output: Hello from Kubernetes!
```

---

## Container & Cluster Networking Deep Dive

Understanding networking boundaries is crucial when running Kubernetes inside Docker within development containers:

| Environment | `localhost` Meaning | To Reach Docker Host | To Reach kind Cluster |
| :--- | :--- | :--- | :--- |
| **Host Machine (macOS)** | macOS Host | `localhost` | `127.0.0.1:<kind-mapped-port>` |
| **DevPod / Dev Container** | Dev Container | `host.docker.internal` or `172.17.0.1` | `https://host.docker.internal:<kind-port>` |
| **kind Control Plane Node** | kind Container | Docker Host gateway | Local cluster services |
| **Application Pod** | Inside the Pod sandbox | Cluster DNS / Service IP | Service IP / other Pods |

### Common Networking Considerations

1. **`localhost` isolation**: Inside a DevPod or Docker container, `localhost:8080` refers strictly to loopback *within that container*, not Docker Desktop or other sibling containers. Use `host.docker.internal` to route to ports published on the Docker host.
2. **Kubernetes API Server TLS SANs**: When pointing `kubectl` at `https://host.docker.internal:<port>`, the API server rejects connections with `x509: certificate is valid for ... but not host.docker.internal` unless configured with `kubeadmConfigPatches` under `apiServer.certSANs`.
3. **Dynamic kind API Server Ports**: When a `kind` cluster is recreated, Docker dynamically assigns a new host port (e.g., `127.0.0.1:40933 -> 6443`). Always verify the active port using `docker ps`.
4. **Service Selectors & Endpoints**: If `kubectl get endpoints <service-name>` shows `<none>`, verify that `spec.selector` in `service.yaml` exactly matches `spec.template.metadata.labels` in `deployment.yaml`.

---

## Layer-by-Layer Troubleshooting Guide

When an issue occurs, isolate each layer sequentially rather than modifying multiple configurations at once:

```
[Application] -> [Container] -> [Docker Network] -> [K8s Cluster] -> [K8s Pods] -> [K8s Service] -> [Rollout]
```

### Layer 1: Application
Verify the application works directly:
```bash
python app.py
curl http://localhost:8080
```

### Layer 2: Docker Container
Verify container lifecycle and logs:
```bash
docker ps
docker logs <container-name>
docker inspect <container-name>
```

### Layer 3: Docker Host & Cross-Container Networking
Check reachability across container boundaries:
```bash
curl http://host.docker.internal:8080
curl -k https://host.docker.internal:<kind-port>
```

### Layer 4: Kubernetes Cluster & Node Status
Check control plane health:
```bash
kubectl cluster-info
kubectl get nodes
```

### Layer 5: Kubernetes Workloads (Pods)
Inspect Pod phase and container state:
```bash
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Layer 6: Kubernetes Service & Endpoint Discovery
Verify routing between Service and Pods:
```bash
kubectl get svc
kubectl get endpoints <service-name>
kubectl describe svc <service-name>
```

### Layer 7: Deployment Rollouts
Check rollout health and history:
```bash
kubectl rollout status deployment/<deployment-name>
kubectl rollout history deployment/<deployment-name>
```

---

## Key Takeaways & Best Practices

- **Declarative manifests (`k8s/*.yaml`)**: Store all desired state as code to ensure repeatable, version-controlled deployments.
- **`imagePullPolicy: IfNotPresent`**: Essential for local image workflows to prevent Kubernetes from defaulting to remote registry pulls.
- **Node image loading**: `kind load docker-image` bridges the gap between host Docker daemon images and `kind` container runtimes.
- **Labels and Selectors**: Form the fundamental binding contract between Services and Deployments.
- **Rolling updates & rollbacks**: Provide controlled, non-destructive deployment iterations with instant recovery capability.
- **Layered diagnostics**: Systematically testing from the process to container to cluster layer drastically reduces troubleshooting time.

---

## Teardown & Cleanup

To stop and remove all resources:

```bash
# Delete Kubernetes resources
kubectl delete -f k8s/service.yaml
kubectl delete -f k8s/deployment.yaml

# Delete the kind cluster
kind delete cluster --name deployment-lab

# Remove local Docker images (optional)
docker rmi kubernetes-deployment:1.0 kubernetes-deployment:2.0
```
