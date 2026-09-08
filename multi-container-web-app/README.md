# Multi-Container Web Application

[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Python](https://img.shields.io/badge/Python-3.12-3776AB?logo=python&logoColor=white)](https://www.python.org/)
[![Flask](https://img.shields.io/badge/Flask-3.x-000000?logo=flask&logoColor=white)](https://flask.palletsprojects.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Nginx](https://img.shields.io/badge/Nginx-Alpine-009639?logo=nginx&logoColor=white)](https://nginx.org/)
[![Testing](https://img.shields.io/badge/Tested%20with-Pytest-0A9EDC?logo=pytest&logoColor=white)](https://pytest.org/)

A multi-tier web application orchestrated with **Docker Compose**, featuring an **Nginx** reverse/static frontend, a **Python Flask** REST API backend, and a **PostgreSQL 16** database.

This project serves as a reference implementation for container networking, automated health checks, inter-service dependencies, CORS handling, data persistence, and containerized development using Dev Containers / DevPod.

---

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Service Topology & Port Mappings](#service-topology--port-mappings)
- [Project Structure](#project-structure)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Configuration](#configuration)
- [Getting Started](#getting-started)
- [API Reference & Usage](#api-reference--usage)
- [Testing](#testing)
- [Data Persistence](#data-persistence)
- [Key Troubleshooting & Lessons Learned](#key-troubleshooting--lessons-learned)
- [Useful Commands Cheatsheet](#useful-commands-cheatsheet)

---

## Architecture Overview

The application is structured into three isolated services running on an internal Docker bridge network, with explicit host-published ports and service health monitoring.

```
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

---

## Service Topology & Port Mappings

| Service | Technology | Container Port | Host Port | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **`frontend`** | Nginx Alpine | `80` | `8081` | Serves client HTML & JavaScript UI |
| **`backend`** | Python 3.12 / Flask | `5000` | `5002` | REST API endpoints & database abstraction |
| **`database`** | PostgreSQL 16 | `5432` | _Internal only_ | Persistent relational data store |

### Docker Networking Principles
1. **Container-to-Container**: Services communicate via Docker Compose internal DNS names (e.g., the backend connects to PostgreSQL at `database:5432`, **not** `localhost`).
2. **Host-to-Container**: Ports mapped in `docker-compose.yml` (`8081:80` and `5002:5000`) are accessible from the host system at `http://localhost:<host-port>`.
3. **Browser Execution Context**: The frontend web page runs in the host browser, so client-side JavaScript calls the backend via the host port `http://localhost:5002`.

---

## Project Structure

```text
multi-container-web-app/
├── .devcontainer/
│   ├── devcontainer.json     # Dev Container configuration with Docker socket bind
│   └── Dockerfile            # Dev environment image based on Ubuntu 24.04 + mise
├── backend/
│   ├── tests/
│   │   └── test_app.py       # Pytest unit/API test suite
│   ├── app.py                # Flask application routes, DB connections & CORS
│   ├── Dockerfile            # Python 3.12-slim backend container build definition
│   ├── pytest.ini            # Pytest configuration
│   └── requirements.txt      # Python dependencies (Flask, psycopg2-binary, etc.)
├── frontend/
│   ├── Dockerfile            # Nginx alpine container definition
│   └── index.html            # Frontend UI and API integration script
├── db/                       # Database scripts/volume mount placeholder
├── .env                      # Environment variable secrets (DB credentials)
├── .gitignore                # Git ignore rules (.env, Python caches)
├── docker-compose.yml        # Orchestration, healthchecks, networks, volumes
├── mise.toml                 # Tool configuration for mise (docker-cli, python)
└── README.md                 # Project documentation
```

---

## Features

- **Automated Health Checks**:
  - PostgreSQL health verified using `pg_isready`.
  - Flask backend health checked via Python's `urllib.request`.
  - Frontend checked via `wget --spider`.
- **Dependency Orchestration**:
  - Backend startup is gated by `depends_on` with `condition: service_healthy` on `database`. Flask does not launch until PostgreSQL is fully accepting connections.
- **Cross-Origin Resource Sharing (CORS)**:
  - Enabled via `Flask-CORS` to permit cross-origin requests from the frontend (`http://localhost:8081`) to the backend API (`http://localhost:5002`).
- **Data Persistence**:
  - Named volume `postgres_data` retains all database records across container recreations, restarts, and image updates.
- **Reproducible Dev Environment**:
  - Pre-configured `.devcontainer` and `mise.toml` for DevPod / VS Code Dev Containers with rootless Docker-in-Docker / socket support.

---

## Prerequisites

- **Docker Engine** (version 20.10+ recommended)
- **Docker Compose** (v2 recommended)
- *(Optional)* [mise](https://mise.jdx.dev/) or **Python 3.12+** if executing tests directly on host/DevPod.

---

## Configuration

The application uses a `.env` file in the project root to configure PostgreSQL credentials:

```bash
# .env
POSTGRES_DB=appdb
POSTGRES_USER=appuser
POSTGRES_PASSWORD=apppassword
```

These variables are automatically mapped in `docker-compose.yml` to:
- Database container: `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`
- Backend container: `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DB_HOST=database`

> [!NOTE]
> `.env` is ignored by Git in `.gitignore` to prevent sensitive credentials from leaking.

---

## Getting Started

### 1. Start the Multi-Container Stack

Build and start all services in detached mode:

```bash
docker-compose up -d --build
```

### 2. Verify Service Status and Health Checks

Check that all three containers reach a `healthy` state:

```bash
docker-compose ps
```

*Expected output:*
```text
NAME                     IMAGE      COMMAND                  SERVICE    STATUS
multi-container-backend  ...        "python app.py"          backend    Up (healthy)
multi-container-db       ...        "docker-entrypoint.s…"   database   Up (healthy)
multi-container-frontend ...        "/docker-entrypoint.…"   frontend   Up (healthy)
```

### 3. Initialize the Database Schema (First Run)

To create the `users` table for CRUD operations, run:

```bash
docker exec -it multi-container-db psql -U appuser -d appdb -c "
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);"
```

### 4. Access the Services

- **Web Frontend**: Open [http://localhost:8081](http://localhost:8081) in your browser.
- **Backend API**: Send requests to [http://localhost:5002](http://localhost:5002).

---

## API Reference & Usage

The Flask backend exposes the following endpoints:

| Method | Endpoint | Description | Response Example |
| :--- | :--- | :--- | :--- |
| `GET` | `/` | API status message | `{"message": "Backend is running"}` |
| `GET` | `/health` | Application health check | `{"status": "healthy"}` |
| `GET` | `/db-health` | PostgreSQL connectivity probe | `{"database": "connected"}` |
| `POST` | `/users` | Create a new user (`{"name": "string"}`) | `{"id": 1, "name": "Alan"}` |
| `GET` | `/users` | List all registered users | `[{"id": 1, "name": "Alan"}]` |

### Example cURL Commands

```bash
# 1. Health check
curl http://localhost:5002/health

# 2. Database connectivity check
curl http://localhost:5002/db-health

# 3. Create a user
curl -X POST http://localhost:5002/users \
  -H "Content-Type: application/json" \
  -d '{"name": "Ada Lovelace"}'

# 4. Fetch all users
curl http://localhost:5002/users
```

---

## Testing

### Unit & API Testing (Pytest)

The local test suite validates Flask application routes independently using Flask's test client:

```bash
cd backend
pytest
```

If running inside the DevPod / mise environment:

```bash
mise exec -- pytest
```

### End-to-End Integration Verification

Verify end-to-end functionality against the running Docker stack:

```bash
# Verify backend can query PostgreSQL
curl -s http://localhost:5002/db-health | grep '"database":"connected"'

# Verify frontend reaches backend via browser UI
curl -s http://localhost:8081 | grep "Multi-Container Docker Application"
```

---

## Data Persistence

PostgreSQL data is stored in the Docker named volume `postgres_data` mounted to `/var/lib/postgresql/data`.

### Verifying Persistence

1. Add a user:
   ```bash
   curl -X POST http://localhost:5002/users -H "Content-Type: application/json" -d '{"name": "Persistent User"}'
   ```
2. Destroy and recreate the database container:
   ```bash
   docker-compose stop database
   docker-compose rm -f database
   docker-compose up -d database
   ```
3. Verify the user is still present:
   ```bash
   curl http://localhost:5002/users
   ```

> [!WARNING]
> Running `docker-compose down -v` will **permanently delete** named volumes and data. Use `docker-compose down` (without `-v`) to safely stop and remove containers while preserving your data.

---

## Key Troubleshooting & Lessons Learned


1. **Host Port vs. Container Port**:
   - `5002:5000` maps host port `5002` to container port `5000`. Flask inside the container listens on `0.0.0.0:5000`, but host and browser requests must target `http://localhost:5002`.
2. **Container-to-Container DNS**:
   - Containers in the same Compose network must communicate using service names (e.g. `host="database"`), never `localhost`.
3. **CORS on Multi-Origin Architectures**:
   - Browser calls from `http://localhost:8081` to `http://localhost:5002` are cross-origin. Even if backend returns HTTP 200, the browser blocks access unless `flask_cors.CORS(app)` is configured.
4. **Healthchecks vs. Process Startup**:
   - `depends_on` alone only waits for the container process to launch, not for the database engine to finish initialization. Pairing `depends_on` with `condition: service_healthy` ensures reliable startup order.
5. **Environment Variable Alignment**:
   - Variable names defined in `.env` must match the mappings in `docker-compose.yml` and the keys read in Python's `os.getenv()`.
6. **Docker Socket Permissions (DevPod)**:
   - When running Docker commands from a DevPod container via `/var/run/docker.sock`, ensure the runtime user belongs to the group matching the host Docker socket GID.

---

## Useful Commands Cheatsheet

```bash
# Build and run containers in background
docker-compose up -d --build

# View real-time container status & health
docker-compose ps

# Inspect combined/resolved Compose configuration
docker-compose config

# View logs for a specific service
docker-compose logs -f backend
docker-compose logs -f database

# Force-recreate a single service after code changes
docker-compose up -d --build --force-recreate backend

# Inspect container environment variables
docker exec -it multi-container-backend env | grep DB_

# Connect directly to the PostgreSQL shell inside the container
docker exec -it multi-container-db psql -U appuser -d appdb

# Inspect persistent volume metadata
docker volume inspect multi-container-web-app_postgres_data

# Stop all containers safely (preserves database volume)
docker-compose down
```
