# 🐳 Docker Image Optimization & Security Hardening

[![Docker](https://img.shields.io/badge/Docker-Containerization-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Python](https://img.shields.io/badge/Python-3.12-3776AB?logo=python&logoColor=white)](https://www.python.org/)
[![Flask](https://img.shields.io/badge/Flask-Web%20Framework-000000?logo=flask&logoColor=white)](https://flask.palletsprojects.com/)
[![Gunicorn](https://img.shields.io/badge/Gunicorn-WSGI%20Server-499848?logo=gunicorn&logoColor=white)](https://gunicorn.org/)
[![Pytest](https://img.shields.io/badge/Pytest-Automated%20Tests-0A9EDC?logo=pytest&logoColor=white)](https://docs.pytest.org/)
[![Size Reduction](https://img.shields.io/badge/Image%20Reduction-87.2%25-brightgreen)](#-optimization-results)

A practical homelab and production-readiness study on containerizing a Python/Flask web microservice. This project demonstrates how systematic Dockerfile restructuring, minimal base image selection, build context management, layer caching, WSGI production serving, and non-root security hardening achieved an **87.2% reduction in image size** (from **442 MB** down to **56.6 MB**).

---

## 📑 Table of Contents

- [Overview](#-overview)
- [Optimization Results](#-optimization-results)
- [Key Optimizations Applied](#-key-optimizations-applied)
  - [1. Choosing a Minimal Base Image](#1-choosing-a-minimal-base-image)
  - [2. Pruning Unnecessary OS Packages & Layers](#2-pruning-unnecessary-os-packages--layers)
  - [3. Restricting Build Context with `.dockerignore`](#3-restricting-build-context-with-dockerignore)
  - [4. Optimizing Docker Layer Caching](#4-optimizing-docker-layer-caching)
  - [5. Production WSGI Server (Gunicorn)](#5-production-wsgi-server-gunicorn)
  - [6. Security Hardening: Running as Non-Root](#6-security-hardening-running-as-non-root)
- [Dockerfile Comparison](#-dockerfile-comparison)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
  - [Prerequisites](#prerequisites)
  - [Building the Images](#building-the-images)
  - [Running the Containers](#running-the-containers)
  - [Health Checks & Verification](#health-checks--verification)
  - [Running Automated Tests](#running-automated-tests)
- [Troubleshooting & Key Learnings](#-troubleshooting--key-learnings)

---

## 🎯 Overview

Deploying microservices inside containers often suffers from container bloat, prolonged CI/CD pipeline build times, excessive registry bandwidth usage, and enlarged security attack surfaces when images are constructed without deliberate optimization.

This repository contrasts a standard **baseline** container build with a hardened, **optimized** container build for the same Python Flask service, proving that performance and security can be drastically enhanced with minimal complexity.

---

## 📊 Optimization Results

| Metric | Baseline (`Dockerfile.baseline`) | Optimized (`Dockerfile.optimized`) | Improvement |
| :--- | :--- | :--- | :--- |
| **Base Image** | `python:3.12` (full Debian-based) | `python:3.12-slim` | Streamlined runtime |
| **Image Content Size** | **442 MB** | **56.6 MB** | **-385.4 MB (~87.19% reduction)** |
| **Disk Usage** | **1.75 GB** | **256 MB** | **-1.49 GB (~85.37% reduction)** |
| **OS Packages** | Extra tools (`curl`, `git`, `vim`) | None (only application dependencies) | Eliminates ~74 MB of bloat |
| **Build Context** | Full workspace (`COPY . .`) | Scoped via `.dockerignore` | Faster context transfer |
| **Layer Caching** | Broken (re-installs dependencies on code edits) | Optimized (cached dependency layer) | Near-instant incremental builds |
| **Application Server**| Flask Built-in Dev Server | Gunicorn WSGI Server | Production-ready concurrency |
| **User Privileges** | `root` (Default UID 0) | Unprivileged `appuser` | Least-privilege compliance |

---

## ⚙️ Key Optimizations Applied

### 1. Choosing a Minimal Base Image
- **Baseline:** Used the standard `python:3.12` image which bundles complete toolchains, compilers, build utilities, and system libraries.
- **Optimized:** Switched to `python:3.12-slim`. It delivers the official Python 3.12 runtime with only the bare minimal Debian base packages required to run standard applications.

### 2. Pruning Unnecessary OS Packages & Layers
- **Baseline:** Executed `RUN apt-get update` and `RUN apt-get install -y curl git vim` across separate layers. This introduced:
  - Over **74 MB** of unused binaries and package managers.
  - Separate filesystem layers that persisted temporary package cache files.
- **Optimized:** Completely omitted manual OS package installation, keeping the runtime clean and removing unnecessary attack vectors.

### 3. Restricting Build Context with `.dockerignore`
- Added a `.dockerignore` file to prevent the Docker daemon from ingesting extraneous project artifacts into the build context:
  ```text
  .git
  .gitignore
  __pycache__
  .pytest_cache
  .venv
  tests
  *.pyc
  README.md
  Dockerfile*
  ```
- **Benefits:** Minimizes memory and I/O overhead during `docker build`, and eliminates the risk of accidentally leaking `.git` history or test cache files into the final image.

### 4. Optimizing Docker Layer Caching
- **Baseline:** Used `COPY . .` followed by `RUN pip install ...`. Any modification to `app.py` busted the Docker layer cache, forcing a complete `pip install` rerun on every build.
- **Optimized:** Ordered instructions according to rate-of-change:
  1. `COPY requirements.txt .`
  2. `RUN pip install --no-cache-dir -r requirements.txt`
  3. `COPY --chown=appuser:appuser app.py .`
- Changes to source code now reuse the pre-built dependency cache layer, allowing rebuilds in seconds.

### 5. Production WSGI Server (Gunicorn)
- **Baseline:** Ran `CMD ["python", "app.py"]`, launching Flask's single-threaded development server (not designed for production traffic).
- **Optimized:** Deployed with **Gunicorn**:
  ```dockerfile
  CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
  ```

### 6. Security Hardening: Running as Non-Root
- Containers should not execute processes as `root` unless strictly required.
- Created a dedicated system user and assigned ownership of application code:
  ```dockerfile
  RUN useradd --create-home --shell /bin/bash appuser
  COPY --chown=appuser:appuser app.py .
  USER appuser
  ```
- Protects the host system against container breakout exploits and enforces least privilege.

---

## 🔍 Dockerfile Comparison

```dockerfile
# ==============================================================================
# BASELINE: Dockerfile.baseline (442 MB content / 1.75 GB disk)
# ==============================================================================
FROM python:3.12

WORKDIR /app

# Inefficient: copies everything before installing dependencies
COPY . .

# Inefficient: extra OS packages in separate layers
RUN apt-get update
RUN apt-get install -y curl git vim

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 5000

# Insecure & non-production dev server running as root
CMD ["python", "app.py"]
```

```dockerfile
# ==============================================================================
# OPTIMIZED: Dockerfile.optimized (56.6 MB content / 256 MB disk)
# ==============================================================================
FROM python:3.12-slim

WORKDIR /app

# Layer caching: copy and install dependencies first
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Security: create dedicated unprivileged user
RUN useradd --create-home --shell /bin/bash appuser

# Copy application files with appropriate ownership
COPY --chown=appuser:appuser app.py .

# Switch away from root
USER appuser 

EXPOSE 5000

# Production WSGI application server
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
```

---

## 📂 Project Structure

```text
docker-image-optimization/
├── .devcontainer/               # VS Code / Codespaces development container setup
│   ├── Dockerfile
│   └── devcontainer.json
├── tests/
│   └── test_app.py              # Pytest endpoint verification (/ and /health)
├── .dockerignore                # Excludes unwanted files from build context
├── .gitignore                   # Git ignore patterns
├── Dockerfile.baseline          # Unoptimized reference Dockerfile
├── Dockerfile.optimized         # Hardened, minimal production Dockerfile
├── app.py                       # Lightweight Flask service
├── mise.toml                    # Mise runtime configuration (Python & Docker CLI)
├── optimization.md              # Size comparison summary metrics
├── pytest.ini                   # Pytest test discovery configuration
├── requirements.txt             # Python dependencies (flask, gunicorn, pytest)
└── README.md                    # Project documentation
```

---

## 🚀 Getting Started

### Prerequisites
- [Docker](https://docs.docker.com/get-docker/) installed and running.
- [Mise](https://mise.jdx.dev/) or Python 3.12+ (optional, for local development and test execution).

---

### Building the Images

1. **Build the Baseline Image:**
   ```bash
   docker build -f Dockerfile.baseline -t docker-image-optimization:baseline .
   ```

2. **Build the Optimized Image:**
   ```bash
   docker build -f Dockerfile.optimized -t docker-image-optimization:optimized .
   ```

3. **Compare Image Sizes:**
   ```bash
   docker images docker-image-optimization
   ```

---

### Running the Containers

Because local host port `5000` is frequently occupied (e.g., macOS AirPlay Receiver), we map host port `5001` to container port `5000`:

```bash
# Run the optimized container in detached mode
docker run -d \
  --name docker-opt-optimized \
  -p 5001:5000 \
  docker-image-optimization:optimized
```

Inspect container status and logs:
```bash
docker ps
docker logs docker-opt-optimized
```

---

### Health Checks & Verification

1. **Verify HTTP endpoints:**
   ```bash
   # Root route
   curl http://localhost:5001/
   # Output: Docker Image Optimization Project

   # Health check route
   curl http://localhost:5001/health
   # Output: {"status":"healthy"}
   ```

2. **Verify Non-Root Execution:**
   ```bash
   docker exec docker-opt-optimized whoami
   # Output: appuser
   ```

3. **Inspect Layer Breakdown:**
   ```bash
   docker history docker-image-optimization:optimized
   ```

4. **Cleanup:**
   ```bash
   docker rm -f docker-opt-optimized
   ```

---

### Running Automated Tests

Run the unit and route tests using `pytest` (or via `mise`):

```bash
# Using pytest directly
pytest

# Or using mise
mise exec -- pytest
```

---

## 💡 Troubleshooting & Key Learnings

1. **Disk Usage vs. Content Size:**
   - Docker reports both uncompressed *Disk usage* and compressed *Content size*.
   - When evaluating container optimization, always measure and report using consistent metrics.
2. **Port Collisions:**
   - Remember that Docker port mapping syntax is `HOST_PORT:CONTAINER_PORT`. Rebinding `-p 5001:5000` isolates container services from conflicting host daemon ports.
3. **Verify Functionality Post-Optimization:**
   - A smaller image is only successful if the workload remains functional. Always couple size optimization with runtime health checks and unit tests.
4. **Holistic Container Engineering:**
   - True container optimization goes beyond layer reduction: it encompasses build context isolation, layer caching performance, security hardening, and resilient production server configuration.
