# 🏠 DevOps & Cloud Infrastructure Homelab

[![Git](https://img.shields.io/badge/VCS-Git_Flow-F05032?logo=git&logoColor=white)](https://git-scm.com/)
[![DevPod](https://img.shields.io/badge/Env-DevPod_Containers-7C3AED?logo=docker&logoColor=white)](https://devpod.sh/)
[![Mise](https://img.shields.io/badge/Toolchain-Mise_En_Place-F97316)](https://mise.jdx.dev/)
[![Docker](https://img.shields.io/badge/Docker-Containerization-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Docker Compose](https://img.shields.io/badge/Docker_Compose-v2-2496ED?logo=docker&logoColor=white)](https://docs.docker.com/compose/)
[![Jenkins](https://img.shields.io/badge/CI-Jenkins_Pipeline-D24939?logo=jenkins&logoColor=white)](https://www.jenkins.io/)
[![GitHub Actions](https://img.shields.io/badge/CI-GitHub_Actions-2088FF?logo=github-actions&logoColor=white)](https://github.com/features/actions)
[![Python](https://img.shields.io/badge/Python-3.12+-3776AB?logo=python&logoColor=white)](https://www.python.org/)
[![Flask](https://img.shields.io/badge/Flask-3.x-000000?logo=flask&logoColor=white)](https://flask.palletsprojects.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Nginx](https://img.shields.io/badge/Nginx-Alpine-009639?logo=nginx&logoColor=white)](https://nginx.org/)
[![Gunicorn](https://img.shields.io/badge/Gunicorn-WSGI-499848?logo=gunicorn&logoColor=white)](https://gunicorn.org/)
[![Ruff](https://img.shields.io/badge/Linter-Ruff-E11D48)](https://docs.astral.sh/ruff/)
[![Pytest](https://img.shields.io/badge/Testing-pytest-0A9EDC?logo=pytest&logoColor=white)](https://docs.pytest.org/)
[![Registry v2](https://img.shields.io/badge/Registry-Docker_v2_TLS-blue?logo=docker&logoColor=white)](https://hub.docker.com/_/registry)

Welcome to my central **DevOps & Cloud Infrastructure Homelab**! This repository serves as a hands-on proving ground and professional engineering portfolio for modern continuous integration, automated release delivery, containerization, image optimization, multi-tier microservice orchestration, private cloud registry infrastructure, reproducible development environments, and automated quality gates.

---

## 🎯 Vision & Core Principles

The projects across this homelab adhere strictly to production-grade DevOps methodologies and cloud-native architectural patterns:

1. **Reproducible Development Environments**: Leveraging [DevPod](https://devpod.sh/) and [Devcontainers](https://containers.dev/) backed by Docker Desktop to eliminate *"works on my machine"* syndrome across local workstations and remote build runners.
2. **Deterministic Polyglot Toolchains**: Managing language runtimes, linters, and test runners declaratively using [Mise](https://mise.jdx.dev/) via version-pinned `mise.toml` configurations.
3. **Dual-Engine CI/CD Orchestration**: Designing robust pipelines across self-hosted orchestrators ([Jenkins](https://www.jenkins.io/)) with ephemeral container agents and cloud-native workflows ([GitHub Actions](https://github.com/features/actions)).
4. **Automated Release Engineering**: Converting Git tag events into fully automated release packaging, checksum generation, and published GitHub Releases with attached artifacts.
5. **Container Engineering & Optimization**: Crafting minimal, layer-cached, production-grade Docker images with non-root security compliance, achieving up to an **87.2% reduction in image weight**.
6. **Multi-Tier Microservice Topology**: Orchestrating full-stack services (Reverse Proxy, REST API, Relational Database) using Docker Compose with inter-service DNS, healthcheck dependencies, and persistent volumes.
7. **Private Infrastructure & Artifact Hosting**: Deploying an on-premise private Docker Registry v2 secured by TLS certificates with Subject Alternative Names (SANs) and HTTP Basic Authentication.
8. **Strict Quality Gates & Test Automation**: Enforcing automated static analysis ([Ruff](https://docs.astral.sh/ruff/)) and unit test suites ([pytest](https://docs.pytest.org/)) before any artifact build or merge.
9. **Standardized Branching & Release Management**: Implementing structured Git branching models (Feature/Develop/Main) with semantic version tagging and controlled conflict resolution.

---

## 🏗️ Homelab Architecture Overview

```mermaid
flowchart TD
    subgraph DevWorkspace["💻 Local Developer Workspace (DevPod / Docker)"]
        Dev["Developer"] --> DevPod["DevPod Devcontainer (Ubuntu 24.04)"]
        DevPod --> MiseLocal["Mise Tool Manager\n(mise.toml)"]
        MiseLocal --> DevTools["Python 3.12+ | Ruff | Pytest | Docker CLI"]
        DevTools --> LocalCheck["Local Pre-flight: ruff check & pytest -vv"]
    end

    subgraph VCS["🌱 Version Control & Release Flow (Git / GitHub)"]
        LocalCheck -->|Git Push / PR| GitFlow{"Git Flow"}
        GitFlow -->|feature/*| DevBranch["develop"]
        DevBranch -->|PR / Merge| MainBranch["main"]
        MainBranch -->|Tag: v1.0.0| GitTag["Git Tag Event"]
    end

    subgraph CI_Pipelines["⚡ Continuous Integration Engines"]
        direction TB
        MainBranch -.->|Webhook / SSH| JenkinsController["Jenkins Controller\n(Master Orchestrator)"]
        JenkinsController --> DevPodAgent["Ephemeral DevPod Agent\n(Label: 'devpod')"]
        DevPodAgent --> J_Test["mise exec -- pytest"]

        MainBranch -->|Push / PR Trigger| GHA["GitHub Actions Runner\n(ubuntu-latest)"]
        GHA --> GHA_Gate["jdx/mise-action@v2\nruff check & pytest -vv"]
    end

    subgraph CD_Release["🚀 Continuous Delivery & Release"]
        GitTag --> ReleaseAction["softprops/action-gh-release@v2"]
        ReleaseAction --> Tarball["Package: automated-release-pipeline.tar.gz"]
        Tarball --> GH_Release["🎉 Published GitHub Release v1.0.0"]
    end

    subgraph Container_Lab["🐳 Containerization & Optimization"]
        direction TB
        BasicDocker["containarize-web-app\n(Flask + python:3.12-slim)"]
        OptimizedDocker["docker-image-optimization\n(87.2% Size Reduction | Gunicorn | Non-root)"]
        MultiContainer["multi-container-web-app\n(Nginx:8081 + Flask:5002 + PostgreSQL:5432)"]
    end

    subgraph Private_Infra["🔒 Private Cloud Infrastructure"]
        PrivateReg["private-docker-registry\n(Registry v2 HTTPS :5005)"]
        TLS["Self-Signed TLS with SANs\nhost.docker.internal"]
        Auth["htpasswd (bcrypt) + Named Volumes"]
        PrivateReg --- TLS
        PrivateReg --- Auth
    end

    OptimizedDocker -->|docker push| PrivateReg
    MultiContainer -->|Persistent Volume| DBData[("postgres_data")]
    PrivateReg -->|Persistent Volume| RegData[("registry-data")]
```

---

## 📊 Homelab Projects Portfolio Matrix

| # | Project / Lab | Directory | Primary Stack | Key Capabilities & Concepts | Readme Reference |
| :-: | :--- | :--- | :--- | :--- | :--- |
| **1** | **Git Branching & Conflict Resolution** | [`git_branching_workflow_Demo/`](./git_branching_workflow_Demo/) | Git, HTML5, CSS3, ES6 JavaScript | Feature/Develop/Main branching, manual merge conflict resolution, semantic tagging | [`todo-app/README.md`](./git_branching_workflow_Demo/todo-app/README.md) |
| **2** | **Jenkins + Ephemeral DevPod CI Agent** | [`jenkins-pipeline/`](./jenkins-pipeline/) | Jenkins, DevPod, Docker, Mise, Python 3, Pytest | Controller-Agent SSH architecture, non-interactive `/bin/sh` handling with `mise exec`, monorepo scoping | [`README.md`](./jenkins-pipeline/README.md) |
| **3** | **Multi-Branch Pipeline Automation** | [`Multi-Branch_pipeline_Automation/`](./Multi-Branch_pipeline_Automation/) | Jenkinsfile, Docker, Python, Pytest, Mise | Declarative multibranch automation, dynamic branch testing, automated Docker image build | [`Multi-Branch Directory`](./Multi-Branch_pipeline_Automation/) |
| **4** | **GitHub Actions CI with DevPod & Mise** | [`github-actions-devpod-ci/`](./github-actions-devpod-ci/) | GitHub Actions, Mise, Ruff, Pytest, DevPod | Cloud-native CI runner, zero dev/CI drift, Ruff linting & Pytest test gates, intentional failure testing | [`README.md`](./github-actions-devpod-ci/README.md) |
| **5** | **Automated CI/CD Release Pipeline** | [`automated-release-pipeline/`](./automated-release-pipeline/) | GitHub Actions, Mise, Pytest, Ruff, GH Release v2 | Tag-triggered release flow, automated `.tar.gz` distribution packaging, auto-generated changelog & assets | [`README.md`](./automated-release-pipeline/README.md) |
| **6** | **Containerize a Web Application** | [`containarize-web-app/`](./containarize-web-app/) | Docker, Python 3.12-slim, Flask, DevPod, Mise | Multi-layer caching, `0.0.0.0` network binding, host port forwarding, Docker socket bind-mount | [`readme.md`](./containarize-web-app/readme.md) |
| **7** | **Docker Image Optimization & Hardening** | [`docker-image-optimization/`](./docker-image-optimization/) | Docker, Python 3.12-slim, Gunicorn, Pytest | **87.2% size reduction** (442MB ➔ 56.6MB), minimal base, layer caching order, non-root `appuser`, Gunicorn | [`README.md`](./docker-image-optimization/README.md) |
| **8** | **Multi-Container Web Application** | [`multi-container-web-app/`](./multi-container-web-app/) | Docker Compose v2, Nginx Alpine, Flask, PostgreSQL 16 | 3-tier microservice architecture, internal DNS, automated healthchecks (`pg_isready`), named volume persistence, CORS | [`README.md`](./multi-container-web-app/README.md) |
| **9** | **Private Docker Registry v2 with TLS & Auth** | [`private-docker-registry/`](./private-docker-registry/) | Docker Registry v2, OpenSSL TLS, Compose v2, htpasswd | TLS HTTPS with SANs, Basic Auth (`htpasswd` bcrypt), Docker named volumes, credential helper isolation | [`readme.md`](./private-docker-registry/readme.md) |

---

## 🚀 Featured Projects & Labs

### 1. Git Branching Workflow & Conflict Resolution
> **Directory**: [`git_branching_workflow_Demo/`](./git_branching_workflow_Demo/) | **Sub-App**: [`todo-app/`](./git_branching_workflow_Demo/todo-app/) | **Documentation**: [`README.md`](./git_branching_workflow_Demo/todo-app/README.md)

A foundational lab demonstrating production-grade Git branching models, collaborative team workflows, and systematic merge conflict resolution using a client-side web application.

```text
main ──────●─────────────────────────────● [v1.0.0 Tagged Release]
           │                             ▲
develop    └──●───────────●──────────●───┘ [Integration Branch]
              │           ▲          ▲
feature/*     └──[feature]┘          └──[merge conflict resolution]
```

* **Branching Strategy**:
  * `main`: Protected production branch containing only tested, tagged releases (`v1.0.0`).
  * `develop`: Integration branch where features are aggregated and validated.
  * `feature/*`: Short-lived task branches (`feature/add-task`, `feature/update-ui`) isolated from integration code.
* **Key Scenarios Practiced**:
  * Branch creation (`git checkout -b feature/add-task develop`), feature implementation, and local PR simulation.
  * Deliberate merge conflict injection between `develop` and `feature/update-ui` in shared UI components (`<h1>` title tag).
  * Manual conflict resolution, state verification, and clean fast-forward / merge commits.
* **Underlying App**: Vanilla HTML5, modern CSS3 Flexbox layout, and ES6+ JavaScript task tracker.

---

### 2. Jenkins + Ephemeral DevPod CI Agent
> **Directory**: [`jenkins-pipeline/`](./jenkins-pipeline/) | **Documentation**: [`README.md`](./jenkins-pipeline/README.md) & [`jenkins-devpod-things-learned-and-errors.md`](./jenkins-pipeline/jenkins-devpod-things-learned-and-errors.md)

A containerized Jenkins pipeline architecture where the **Jenkins Controller** delegates job execution over SSH to an isolated, reproducible **DevPod agent** running an Ubuntu 24.04 container managed with **Mise**.

```mermaid
flowchart LR
    subgraph Controller["Jenkins Controller"]
        Scheduler["Job Scheduler &\nPipeline Engine"]
    end

    subgraph Agent["DevPod Agent Node (label: 'devpod')"]
        SSH["SSH Server"]
        Mise["Mise Runtime Manager"]
        PyRuntime["Python 3 Runtime"]
        Suite["pytest test suite"]
    end

    Scheduler -->|SSH Session| SSH
    SSH --> Mise
    Mise --> PyRuntime
    PyRuntime --> Suite
```

* **Key Highlights & Technical Achievements**:
  * **Controller / Agent Separation**: Preserved controller stability and security by running builds exclusively on ephemeral DevPod worker nodes labeled `devpod`.
  * **Non-Interactive Shell Mastery**: Solved `/bin/sh` shell limitations in CI by using explicit `mise exec python -- <command>` invocations instead of relying on `.bashrc`/`.zshrc` profile loading.
  * **Monorepo Directory Scoping**: Leveraged Jenkins `dir('jenkins-pipeline')` step scoping so `mise.toml` is correctly identified and executed relative to project subdirectories.
  * **Declarative Pipeline**: Automated checkout, environment provisioning (`mise install`), dependency installation, and test execution (`pytest`).

---

### 3. Multi-Branch Pipeline Automation
> **Directory**: [`Multi-Branch_pipeline_Automation/`](./Multi-Branch_pipeline_Automation/) | **Specification**: [`Jenkinsfile`](./Multi-Branch_pipeline_Automation/Jenkinsfile) & [`mise.toml`](./Multi-Branch_pipeline_Automation/mise.toml)

An automated CI automation pipeline configured for multi-branch repositories. It detects dynamic branch changes, executes unit test suites, and generates container artifacts automatically upon branch validation.

```text
[Multi-Branch Event: PR / Commit on feature/* or main]
       │
       ▼
┌─────────────────────────────────────────────────────────────┐
│ Jenkins Pipeline Engine                                     │
│  ├─ Stage 1: Checkout SCM (Dynamic Branch Resolution)       │
│  ├─ Stage 2: Install Dependencies (pip install pytest)      │
│  ├─ Stage 3: Automated Quality Gate (pytest -v)             │
│  └─ Stage 4: Artifact Generation (docker build -t app .)    │
└─────────────────────────────────────────────────────────────┘
       │
       ▼
[Status: SUCCESS ✅]
```

* **Key Highlights & Technical Achievements**:
  * **Dynamic Branch Testing**: Executes builds on any active branch in the repository without hardcoded pipeline definitions.
  * **Integrated Container Packaging**: Concludes pipeline runs with an automated Docker container build stage (`docker build -t multi-branch-pipeline-app .`).
  * **Declarative Toolchain**: Environment managed through `mise.toml` declaring Python, pytest, Ruff, Java, and Node runtimes.

---

### 4. GitHub Actions CI with DevPod & Mise Toolchain
> **Directory**: [`github-actions-devpod-ci/`](./github-actions-devpod-ci/) | **Documentation**: [`README.md`](./github-actions-devpod-ci/README.md) & [`errors.md`](./github-actions-devpod-ci/errors.md)

A cloud-native Continuous Integration pipeline built with **GitHub Actions**, matching a containerized local development workflow powered by **DevPod** and **Mise**.

```text
[Trigger: Push / PR to main]
       │
       ▼
┌─────────────────────────────────────────────────────────────┐
│ GitHub Actions Runner (ubuntu-latest)                       │
│  ├─ 1. actions/checkout@v4                                  │
│  ├─ 2. jdx/mise-action@v2 (Install Mise toolchain)         │
│  ├─ 3. mise install (Python 3.12+, Ruff, pytest, pipx)      │
│  ├─ 4. mise exec -- ruff check . (Linter & style gate)      │
│  └─ 5. mise exec -- pytest -vv (5/5 Automated unit tests)   │
└─────────────────────────────────────────────────────────────┘
       │
       ▼
[Status: SUCCESS ✅]
```

* **Key Highlights & Technical Achievements**:
  * **Zero Dev/CI Drift**: Identical tool versions declared in `mise.toml` are used across local DevPod containers and GitHub Actions runners via `jdx/mise-action@v2`.
  * **Strict Quality Gates**: Automated formatting and static analysis with **Ruff**, combined with granular test suites in **pytest**.
  * **Python Path Resolution**: Solved test discovery and relative module import issues across monorepos via `pytest.ini` (`pythonpath = .`).
  * **Validated Failure Resilience**: Verified pipeline integrity by injecting deliberate assertions (`assert add(2, 2) == 5`), observing pipeline failure, and verifying automated recovery upon fix.
  * **Systematic Post-Mortem**: Documented complete 10-step troubleshooting protocol and resolution steps in [`errors.md`](./github-actions-devpod-ci/errors.md).

---

### 5. Automated CI/CD Release Pipeline
> **Directory**: [`automated-release-pipeline/`](./automated-release-pipeline/) | **Documentation**: [`README.md`](./automated-release-pipeline/README.md)

An end-to-end automated Continuous Integration and Continuous Delivery (CI/CD) release pipeline for Python applications using **GitHub Actions**, **Mise**, **Pytest**, **Ruff**, and **DevPod**.

```mermaid
flowchart TD
    A["Developer pushes Git Tag (e.g., v1.0.0)"] --> B["GitHub Actions Triggered"]
    B --> C["Checkout Repository (actions/checkout@v4)"]
    C --> D["Install Mise (jdx/mise-action@v3)"]
    D --> E["Install Tools (mise install)"]
    E --> F["Lint Code (mise exec -- ruff check .)"]
    F --> G["Execute Tests (mise exec -- pytest)"]
    G --> H["Build Release Tarball (dist/automated-release-pipeline.tar.gz)"]
    H --> I["Upload Artifact (actions/upload-artifact@v4)"]
    I --> J["Create GitHub Release (softprops/action-gh-release@v2)"]
    J --> K["🎉 Release Published with Artifact Attached"]

    F -.->|Failure| L["❌ Stop Pipeline"]
    G -.->|Failure| L
```

* **Key Highlights & Technical Achievements**:
  * **Tag-Triggered Distribution**: Automatically triggered when Git tags (e.g. `v1.0.0`) are pushed via `git push origin refs/tags/v1.0.0`.
  * **Deterministic Tooling**: Runtimes and linters pinned declaratively in `mise.toml` (Python 3.12, Ruff, Pytest, pipx).
  * **Artifact Packaging**: Packages verified source files, tool configs, and test setups into versioned archives (`dist/automated-release-pipeline.tar.gz`).
  * **Automated GitHub Releases**: Uses `softprops/action-gh-release@v2` with `contents: write` permissions to publish release notes and attach distribution archives.

---

### 6. Containerize a Web Application
> **Directory**: [`containarize-web-app/`](./containarize-web-app/) | **Documentation**: [`readme.md`](./containarize-web-app/readme.md) & [`what_i_learned.txt`](./containarize-web-app/what_i_learned.txt)

A practical containerization lab transforming a lightweight Python Flask web service into an isolated, reproducible Docker container, bridging Docker client operations between DevPod and Docker Desktop on macOS.

```mermaid
flowchart TD
    subgraph Host ["Host Workstation (Mac / Browser)"]
        Browser["HTTP Request (http://localhost:5001)"]
    end

    subgraph DockerHost ["Docker Engine / Docker Desktop"]
        PortMapping["Port Mapping (-p 5001:5000)\nHost: 5001 ──> Container: 5000"]
        
        subgraph Container ["Docker Container: containarize-web-app"]
            AppInterface["0.0.0.0:5000 (All Container Interfaces)"]
            Flask["Flask App (app.py)"]
        end
    end

    Browser -->|Port 5001| PortMapping
    PortMapping -->|Port 5000| AppInterface
    AppInterface --> Flask
```

* **Key Highlights & Technical Achievements**:
  * **Docker Layer Caching**: Ordered Dockerfile instructions to copy `requirements.txt` and run `pip install` **before** copying `app.py`, ensuring fast incremental rebuilds.
  * **DevPod Socket Passthrough**: Mounted `/var/run/docker.sock` in `.devcontainer/devcontainer.json` to enable rootless/containerized Docker CLI execution against the host Docker daemon.
  * **Network Binding vs Port Forwarding**: Configured Flask to listen on `0.0.0.0:5000` (all interfaces) rather than `127.0.0.1`, and mapped host port `5001:5000` to avoid macOS AirPlay Receiver port collisions.
  * **Build Context Optimization**: Crafted `.dockerignore` to exclude Git history, Python caches (`__pycache__`), and local virtual environments from build contexts.

---

### 7. Docker Image Optimization & Security Hardening
> **Directory**: [`docker-image-optimization/`](./docker-image-optimization/) | **Documentation**: [`README.md`](./docker-image-optimization/README.md) & [`error_dock_opt_img.md`](./docker-image-optimization/error_dock_opt_img.md)

A deep-dive production engineering study on containerizing a Python/Flask web microservice. Contrasts an unoptimized baseline container with a hardened, minimal production container, achieving an **87.2% reduction in image size** and **85.4% reduction in disk usage**.

```text
BASELINE (Dockerfile.baseline)       OPTIMIZED (Dockerfile.optimized)
┌─────────────────────────────┐      ┌─────────────────────────────┐
│ Base: python:3.12           │      │ Base: python:3.12-slim      │
│ Extra: curl, git, vim       │ ──>  │ No extra OS packages        │
│ Cache: Broken layer order   │      │ Cache: Dependencies first   │
│ Server: Flask dev server    │      │ Server: Gunicorn WSGI       │
│ User: root (UID 0)          │      │ User: appuser (Unprivileged)│
└─────────────────────────────┘      └─────────────────────────────┘
  Image Size: 442 MB                   Image Size: 56.6 MB (-87.2%)
  Disk Usage: 1.75 GB                  Disk Usage: 256 MB (-85.4%)
```

* **Key Highlights & Technical Achievements**:
  * **Minimal Base Image Selection**: Switched from `python:3.12` (full Debian, 442 MB) to `python:3.12-slim` (56.6 MB), pruning ~385 MB of unused toolchains and build utilities.
  * **OS Package Pruning**: Removed unnecessary `apt-get install` packages (`curl`, `git`, `vim`), eliminating ~74 MB of bloat and reducing attack surface.
  * **Layer Caching Optimization**: Reordered instructions so `COPY requirements.txt` and `pip install` occur before application files, enabling instant rebuilds upon code changes.
  * **Production WSGI Server**: Replaced Flask's single-threaded development server with **Gunicorn** (`gunicorn --bind 0.0.0.0:5000 app:app`) for production concurrency.
  * **Security Hardening (Non-Root)**: Created dedicated unprivileged system user `appuser` (`USER appuser`, `COPY --chown=appuser:appuser`) to protect host systems against container breakout exploits.

---

### 8. Multi-Container Web Application (3-Tier Architecture)
> **Directory**: [`multi-container-web-app/`](./multi-container-web-app/) | **Documentation**: [`README.md`](./multi-container-web-app/README.md) & [`things_i_learned.md`](./multi-container-web-app/things_i_learned.md)

A multi-tier web application orchestrated with **Docker Compose v2**, featuring an **Nginx** reverse/static frontend, a **Python Flask** REST API backend, and a **PostgreSQL 16** relational database.

```text
                         Host Machine (Browser / curl)
                                     |
               +---------------------+---------------------+
               |                                           |
               | http://localhost:8081                     | http://localhost:5002
               v                                           v
       +---------------+                           +---------------+
       |   frontend    |  (Browser API Fetch)      |    backend    |
       |  Nginx Alpine |-------------------------->|     Flask     |
       | (Port 80)     |                           | (Port 5000)   |
       +---------------+                           +-------+-------+
                                                           |
                                                           | database:5432
                                                           v
                                                   +---------------+
                                                   |   database    |
                                                   | PostgreSQL 16 |
                                                   | (Port 5432)   |
                                                   +-------+-------+
                                                           |
                                                           v
                                                  [ postgres_data ]
                                                   (Named Volume)
```

* **Service Topology**:
  * **`frontend`** (Nginx Alpine): Port `80` (Container) ➔ Port `8081` (Host) – Serves static HTML/JS UI.
  * **`backend`** (Python 3.12 / Flask): Port `5000` (Container) ➔ Port `5002` (Host) – REST API & DB client.
  * **`database`** (PostgreSQL 16): Port `5432` (Container) – Internal bridge network only.
* **Key Highlights & Technical Achievements**:
  * **Automated Health Checks**: PostgreSQL verified via `pg_isready`, Flask via `urllib.request`, and Nginx via `wget --spider`.
  * **Dependency Orchestration**: Backend startup is gated by `depends_on` with `condition: service_healthy` on `database`. Flask does not launch until PostgreSQL is fully accepting queries.
  * **CORS Management**: Configured `Flask-CORS` to securely permit cross-origin asynchronous requests from frontend (`localhost:8081`) to backend (`localhost:5002`).
  * **Data Persistence**: Backed by Docker named volume `postgres_data`, ensuring database records persist through container stops, deletions, and rebuilds.

---

### 9. Standalone Private Docker Registry v2 with TLS & Authentication
> **Directory**: [`private-docker-registry/`](./private-docker-registry/) | **Documentation**: [`readme.md`](./private-docker-registry/readme.md) & [`error_private-dock-reg.md`](./private-docker-registry/error_private-dock-reg.md)

A secure, standalone private Docker Registry (v2) configured with HTTPS (TLS), basic authentication (`htpasswd`), persistent Docker named volumes, and integration with containerized development environments on macOS.

```mermaid
flowchart TD
    subgraph Client["Client Environment (Host / DevPod)"]
        CLI["Docker CLI\n(DOCKER_CONFIG=~/.docker-registry)"]
        CertStore["Docker Certs Trust\n(~/.docker/certs.d/host.docker.internal:5005/ca.crt)"]
    end

    subgraph DockerHost["Docker Host (Port :5005)"]
        subgraph RegistryContainer["private-registry (registry:2)"]
            Port["0.0.0.0:5000 (HTTPS)"]
            AuthEngine["Auth Module (htpasswd / bcrypt)"]
            CryptoEngine["TLS Engine (domain.crt + domain.key)"]
            StorageDriver["Storage Engine (/var/lib/registry)"]
        end

        subgraph NamedVolumes["Persistent Named Volumes"]
            VolCerts[("registry-certs (ro)\n/certs/domain.crt\n/certs/domain.key")]
            VolAuth[("private-docker-registry_registry-auth\n/auth/htpasswd")]
            VolData[("registry-data\n/var/lib/registry")]
        end
    end

    CLI -->|"1. HTTPS Handshake & Verify Cert"| CryptoEngine
    CertStore -.->|"Trust Anchor"| CLI
    CLI -->|"2. Basic Auth (registryuser)"| AuthEngine
    CLI -->|"3. Push / Pull Image Blobs"| StorageDriver

    CryptoEngine --- VolCerts
    AuthEngine --- VolAuth
    StorageDriver --- VolData
```

* **Key Highlights & Technical Achievements**:
  * **TLS / HTTPS Security**: Self-signed x509 certificates generated with OpenSSL containing Subject Alternative Names (SANs) for `host.docker.internal`, `localhost`, and `127.0.0.1`.
  * **Daemon Trust Store Integration**: Ingested CA certificates into Docker's trust store (`~/.docker/certs.d/host.docker.internal:5005/ca.crt`) to prevent `x509: certificate signed by unknown authority` errors.
  * **HTTP Basic Authentication**: Enforced bcrypt-hashed credentials stored securely in a dedicated `htpasswd` volume.
  * **Named Volume Decoupling**: Solved macOS Docker Desktop bind-mount latency, missing path sharing permissions, and read-only mount issues by utilizing Docker-managed named volumes (`registry-data`, `registry-certs`, `registry-auth`).
  * **Credential Helper Isolation**: Outlined a dedicated `DOCKER_CONFIG=~/.docker-registry` workflow to prevent desktop credential helper mismatches during automated push/pull operations.

---

## 📊 Technical Comparison Matrices

### 1. CI/CD & Automation Pipelines Comparison

| Capability | Jenkins CI Lab (`jenkins-pipeline`) | Multi-Branch Lab (`Multi-Branch_pipeline_Automation`) | GitHub Actions CI (`github-actions-devpod-ci`) | Automated Release Lab (`automated-release-pipeline`) |
| :--- | :--- | :--- | :--- | :--- |
| **Orchestration Model** | Self-hosted controller + SSH agent | Self-hosted multibranch engine | Managed cloud runner (`ubuntu-latest`) | Managed cloud runner (`ubuntu-latest`) |
| **Agent Environment** | Ephemeral DevPod container (Ubuntu 24.04) | Jenkins Docker agent (`ubuntu-24.04`) | Ephemeral GitHub Actions VM | Ephemeral GitHub Actions VM |
| **Runtime Management** | Mise (`mise.toml` via `mise exec`) | Mise (`mise.toml`) | Mise (`jdx/mise-action@v2`) | Mise (`jdx/mise-action@v3`) |
| **Configuration Format**| Declarative Groovy (`Jenkinsfile`) | Declarative Groovy (`Jenkinsfile`) | Declarative YAML (`.github/workflows/*.yml`) | Declarative YAML (`.github/workflows/*.yml`) |
| **Trigger Mechanism** | SCM poll / manual trigger | Dynamic branch push / PR | Push / PR against `main` | Tag push (`refs/tags/v*`) |
| **Quality Gates** | Automated `pytest` execution | Automated `pytest -v` execution | `ruff check .` + `pytest -vv` | `ruff check .` + `pytest` |
| **Artifact Output** | Test execution reports | Built Docker container image | Verified green build commit | `.tar.gz` attached to GitHub Release |

### 2. Containerization & Infrastructure Comparison

| Capability | Containerize Web App (`containarize-web-app`) | Image Optimization (`docker-image-optimization`) | Multi-Container Stack (`multi-container-web-app`) | Private Registry (`private-docker-registry`) |
| :--- | :--- | :--- | :--- | :--- |
| **Base Image** | `python:3.12-slim` | `python:3.12-slim` (vs `python:3.12`) | `python:3.12-slim`, `nginx:alpine`, `postgres:16` | `registry:2` (Official Registry) |
| **Primary Tool** | Docker CLI | Docker CLI (`Dockerfile.optimized`) | Docker Compose v2 (`docker-compose.yml`) | Docker Compose v2 + OpenSSL + htpasswd |
| **Image Size** | Standard slim (~150 MB) | **56.6 MB** (87.2% reduction) | Multi-image stack | Lightweight Go registry binary |
| **Network Exposure** | Port `5001:5000` | Port `5001:5000` | Frontend: `8081:80`, Backend: `5002:5000` | HTTPS Port `5005:5000` |
| **Concurrency / Server**| Flask dev server | Gunicorn WSGI | Flask + Gunicorn / Nginx proxy | Built-in Go HTTPS Registry server |
| **Security Posture** | Default container user | Non-root `appuser` | Container network isolation | TLS HTTPS with SANs + bcrypt htpasswd |
| **Data Persistence** | Stateless | Stateless | Named Volume (`postgres_data`) | Named Volumes (`registry-data`, `auth`, `certs`) |

---

## 📂 Repository Directory Structure

```text
.
├── README.md                                  # Central Homelab documentation & portfolio overview
│
├── git_branching_workflow_Demo/               # Project 1: Production Git workflows & conflict resolution
│   └── todo-app/                              # Pure client-side web application
│       ├── index.html                         # Markup & structure
│       ├── style.css                          # Modern Flexbox styling
│       ├── app.js                             # Logic & DOM event handlers
│       ├── README.md                          # Git workflow & conflict guide
│       └── screenshots/                       # Visual logs of branching & merge resolution
│
├── jenkins-pipeline/                          # Project 2: Self-hosted Jenkins + DevPod SSH CI
│   ├── .devcontainer.json                     # Devcontainer agent configuration
│   ├── Dockerfile                             # Ubuntu 24.04 agent base with Mise
│   ├── Jenkinsfile                            # Declarative Jenkins pipeline definition
│   ├── mise.toml                              # Toolchain config (Python, Java 21, Node, Jenkins CLI)
│   ├── app.py                                 # Application entrypoint
│   ├── test_app.py                            # Pytest test suite
│   ├── requirements.txt                       # Python dependencies
│   ├── README.md                              # Detailed Jenkins CI documentation
│   ├── jenkins-devpod-things-learned-and-errors.md # Comprehensive debugging log
│   └── screenshots/                           # Jenkins dashboard & build execution proof
│
├── Multi-Branch_pipeline_Automation/          # Project 3: Jenkins Multi-Branch Pipeline
│   ├── .devcontainer.json                     # DevPod configuration
│   ├── Dockerfile                             # Container agent definition
│   ├── Jenkinsfile                            # Multibranch pipeline script
│   ├── mise.toml                              # Mise tool configuration
│   ├── pytest.ini                             # Pytest settings
│   ├── app.py                                 # Core application code
│   └── tests/                                 # Unit test suite
│       └── test_app.py
│
├── github-actions-devpod-ci/                  # Project 4: Cloud-native GitHub Actions + DevPod CI
│   ├── .devcontainer.json                     # DevPod container configuration
│   ├── Dockerfile                             # Devcontainer image with Mise
│   ├── mise.toml                              # Declarative tools (Python 3.12, Ruff, pytest)
│   ├── pytest.ini                             # Pytest configuration (pythonpath = .)
│   ├── README.md                              # Detailed GitHub Actions lab guide
│   ├── errors.md                              # 10-step troubleshooting guide & error resolutions
│   ├── src/                                   # Application source code
│   │   ├── __init__.py
│   │   └── main.py                            # Core calculation module
│   └── tests/                                 # Automated test suite
│       └── test_main.py                       # Pytest test cases
│
├── automated-release-pipeline/                # Project 5: Tag-driven automated CI/CD release pipeline
│   ├── .devcontainer/                         # DevPod container setup
│   │   ├── .devcontainer.json
│   │   └── Dockerfile
│   ├── app.py                                 # Application entrypoint
│   ├── mise.toml                              # Declarative tools (Python 3.12, Ruff, Pytest, pipx)
│   ├── pytest.ini                             # Discovery configuration (pythonpath = .)
│   ├── README.md                              # Release engineering documentation
│   ├── dist/                                  # Generated release packages
│   │   └── automated-release-pipeline.tar.gz
│   └── tests/                                 # Test suite
│       └── test_app.py
│
├── containarize-web-app/                      # Project 6: Flask containerization & DevPod Docker socket
│   ├── .devcontainer/                         # DevPod dev environment with docker.sock mount
│   │   ├── devcontainer.json
│   │   └── Dockerfile
│   ├── .dockerignore                          # Build context exclusion rules
│   ├── Dockerfile                             # Minimal Python 3.12-slim production image
│   ├── app.py                                 # Flask web application (0.0.0.0:5000)
│   ├── mise.toml                              # Toolchain manager (python, pipx, docker-cli)
│   ├── requirements.txt                       # Application dependencies (Flask)
│   ├── what_i_learned.txt                     # Container networking & socket logs
│   └── readme.md                              # Step-by-step containerization guide
│
├── docker-image-optimization/                 # Project 7: Container optimization & security hardening
│   ├── .devcontainer/                         # Dev container configuration
│   │   ├── devcontainer.json
│   │   └── Dockerfile
│   ├── .dockerignore                          # Build context optimization
│   ├── Dockerfile.baseline                    # Reference unoptimized Dockerfile (442 MB)
│   ├── Dockerfile.optimized                   # Hardened production Dockerfile (56.6 MB)
│   ├── app.py                                 # Flask application service
│   ├── error_dock_opt_img.md                  # Debugging log & performance analysis
│   ├── mise.toml                              # Local tool versions
│   ├── optimization.md                        # Size reduction summary metrics
│   ├── pytest.ini                             # Pytest configuration
│   ├── requirements.txt                       # Dependencies (Flask, Gunicorn, pytest)
│   ├── README.md                              # Comprehensive optimization documentation
│   └── tests/                                 # Route & health check tests
│       └── test_app.py
│
├── multi-container-web-app/                   # Project 8: 3-tier microservice architecture with Compose
│   ├── .devcontainer/                         # Dev environment setup
│   │   ├── devcontainer.json
│   │   └── Dockerfile
│   ├── backend/                               # Flask REST API service
│   │   ├── Dockerfile                         # Python 3.12-slim backend container
│   │   ├── app.py                             # API routes, CORS & PostgreSQL client
│   │   ├── pytest.ini                         # Pytest configuration
│   │   ├── requirements.txt                   # Flask, psycopg2-binary, flask-cors
│   │   └── tests/                             # API unit test suite
│   │       └── test_app.py
│   ├── frontend/                              # Static frontend UI service
│   │   ├── Dockerfile                         # Nginx Alpine web server container
│   │   └── index.html                         # Interactive UI & fetch API logic
│   ├── docker-compose.yml                     # Service orchestration, healthchecks & networks
│   ├── things_i_learned.md                    # Compose networking & CORS journal
│   ├── mise.toml                              # Docker CLI & Python tool versions
│   └── README.md                              # Multi-container stack documentation
│
└── private-docker-registry/                   # Project 9: Standalone Private Docker Registry v2
    ├── .devcontainer/                         # DevContainer setup with Docker socket passthrough
    │   ├── devcontainer.json
    │   └── Dockerfile
    ├── auth/                                  # Authentication directory
    │   └── htpasswd                           # Bcrypt-hashed credentials (gitignored)
    ├── certs/                                 # Cryptographic credentials
    │   ├── domain.crt                         # TLS Certificate with SAN (gitignored)
    │   └── domain.key                         # Private key (gitignored)
    ├── test-image/                            # Verification sample image
    │   └── Dockerfile                         # Minimal Alpine test container
    ├── docker-compose.yml                     # Registry service & named volume bindings
    ├── error_private-dock-reg.md              # Real-world debugging journal
    ├── mise.toml                              # Tool version definitions
    └── readme.md                              # Step-by-step registry setup guide
```

---

## 🛠️ Quickstart: Running Environments Locally

### Prerequisites

Ensure the following tools are installed on your workstation:
* [Docker Desktop](https://docs.docker.com/get-docker/) (or Docker Engine on Linux)
* [DevPod](https://devpod.sh/) CLI or GUI
* [Mise](https://mise.jdx.dev/) tool manager
* [Git](https://git-scm.com/)

---

### 1. Launch a Project in DevPod

Spin up an isolated, reproducible container environment for any project in seconds:

```bash
# Launch GitHub Actions CI lab
devpod up github-actions-devpod-ci --provider docker

# Launch Jenkins Pipeline lab
devpod up jenkins-pipeline --provider docker

# Launch Container Optimization lab
devpod up docker-image-optimization --provider docker
```

---

### 2. Run Container Labs with Docker & Docker Compose

#### Containerize Web App
```bash
cd containarize-web-app
docker build -t containarize-web-app .
docker run -d --name containarize-web-app -p 5001:5000 containarize-web-app
curl http://localhost:5001
```

#### Docker Image Optimization
```bash
cd docker-image-optimization
# Build baseline vs optimized
docker build -f Dockerfile.baseline -t docker-opt:baseline .
docker build -f Dockerfile.optimized -t docker-opt:optimized .
# Compare sizes
docker images docker-opt
# Run optimized image
docker run -d --name docker-opt -p 5001:5000 docker-opt:optimized
curl http://localhost:5001/health
```

#### Multi-Container Web Application
```bash
cd multi-container-web-app
# Build and boot the 3-tier stack
docker-compose up -d --build
# Verify health of all services
docker-compose ps
# Access frontend (http://localhost:8081) and API (http://localhost:5002)
curl http://localhost:5002/health
```

#### Private Docker Registry v2
```bash
cd private-docker-registry
# Start registry container with TLS and Auth
docker compose up -d
# Authenticate using isolated config
DOCKER_CONFIG=~/.docker-registry docker login host.docker.internal:5005 -u registryuser -p SecurePassword123
# Push test image
DOCKER_CONFIG=~/.docker-registry docker push host.docker.internal:5005/test-image:1.0.0
# Query catalog
curl --cacert certs/domain.crt -u registryuser:SecurePassword123 https://host.docker.internal:5005/v2/_catalog
```

---

### 3. Run Quality Gates & Tests Locally via Mise

Inside any project folder:

```bash
# Install exact tools declared in mise.toml
mise install

# Run static analysis and linting (Ruff)
mise exec -- ruff check .

# Run automated unit tests (pytest)
mise exec -- pytest -vv
```

---

## 🧭 Systematic Debugging & Troubleshooting Protocol

All pipeline errors, container networking hurdles, and runtime issues encountered throughout these projects are resolved following a standardized 10-step diagnostic workflow:

```text
 1. Read the full error output and stack trace.
 2. Identify the exact failing command and current working directory (`pwd`).
 3. Isolate the affected architecture layer (Host, Docker, DevPod, Mise, Runtime, Git, CI).
 4. Verify binary resolution paths (`which <tool>`, `mise which <tool>`).
 5. Check declared vs runtime versions (`<tool> --version`, `python --version`).
 6. Isolate and test the smallest unit locally (e.g. `python -c "from app import add"`).
 7. Implement exactly ONE deliberate change at a time.
 8. Re-run validation under identical execution conditions.
 9. Confirm the fix without applying anti-patterns or code duplication.
10. Document root causes and prevention steps in the project error log.
```

### Real-World Failure Modes & Solutions Discovered

| Domain | Issue / Error | Root Cause | Engineering Solution |
| :--- | :--- | :--- | :--- |
| **CI / Pytest** | `ModuleNotFoundError: No module named 'src'` | Project root was omitted from Python's module search path during test execution. | Configured `pytest.ini` with `pythonpath = .` and `testpaths = tests`. |
| **Git / Release** | `src refspec v1.0.0 does not match any` | Git could not resolve local tag references during push. | Created annotated tags (`git tag -a v1.0.0 -m "Release"`) and pushed via `refs/tags/v1.0.0`. |
| **Docker / DevPod** | `Cannot connect to the Docker daemon` inside DevPod | `/var/run/docker.sock` was not passed into the container workspace. | Bind-mounted `/var/run/docker.sock` in `.devcontainer/devcontainer.json`. |
| **Networking** | Port collision (`address already in use`) | Host port `5000` was occupied by macOS AirPlay Receiver. | Re-mapped published port to `5001:5000` via Docker `-p` or `docker-compose.yml`. |
| **Compose** | Frontend cannot read API (`CORS error`) | Browser security policy blocks requests across different origins (`8081` vs `5002`). | Integrated `Flask-CORS` in backend Flask routes to permit cross-origin requests. |
| **Compose** | Backend crashes before PostgreSQL initializes | `depends_on` only waits for container creation, not database engine readiness. | Configured healthcheck (`pg_isready`) and added `condition: service_healthy` to `depends_on`. |
| **Registry** | `x509: certificate signed by unknown authority` | Docker CLI did not trust the self-signed TLS certificate. | Installed CA certificate into `~/.docker/certs.d/host.docker.internal:5005/ca.crt`. |
| **Registry** | macOS bind mount permission error | Docker Desktop could not share the DevPod project path. | Migrated to Docker-managed named volumes (`registry-data`, `registry-auth`, `registry-certs`). |
| **Registry** | Credential helper "No basic auth" error | Desktop credential helper intercepted credentials for `localhost`. | Isolated Docker client config via `DOCKER_CONFIG=~/.docker-registry`. |

---

## 🗺️ Homelab Roadmap

* [x] **Git Branching Strategies & Merge Conflict Resolution** (`git_branching_workflow_Demo`)
* [x] **Self-Hosted Jenkins CI with DevPod Container SSH Agents** (`jenkins-pipeline`)
* [x] **Jenkins Multi-Branch Automated CI Pipelines** (`Multi-Branch_pipeline_Automation`)
* [x] **Cloud-Native GitHub Actions CI with Mise & Ruff/Pytest Gates** (`github-actions-devpod-ci`)
* [x] **Tag-Driven Automated CI/CD Release Pipelines & Packaging** (`automated-release-pipeline`)
* [x] **Lightweight Containerization & Docker Socket Passthrough** (`containarize-web-app`)
* [x] **Docker Image Optimization & Security Hardening (87.2% Size Reduction)** (`docker-image-optimization`)
* [x] **3-Tier Microservices Orchestration with Docker Compose & Healthchecks** (`multi-container-web-app`)
* [x] **Standalone Private Docker Registry v2 with TLS & Authentication** (`private-docker-registry`)
* [ ] **Kubernetes Cluster Deployments & Manifest Orchestration**
* [ ] **Infrastructure as Code (IaC) with Terraform**
* [ ] **GitOps Continuous Delivery with ArgoCD / Flux**
* [ ] **Prometheus & Grafana Observability Stack**

---

## 📄 License & Notes

This repository is maintained as a personal DevOps homelab and professional portfolio. All configurations, scripts, and documentation are designed for learning, experimentation, and reference. Feel free to explore and adapt!
