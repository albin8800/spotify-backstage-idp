# Enterprise Developer Portal (IDP) 🚀

[![Backstage](https://img.shields.io/badge/Spotify-Backstage-blue?logo=spotify)](https://backstage.io/)
[![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL%2016-336791?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Docker](https://img.shields.io/badge/Container-Docker%20Compose-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![GitHub API](https://img.shields.io/badge/Integration-GitHub%20REST%20API-181717?logo=github&logoColor=white)](https://docs.github.com/en/rest)
[![Python](https://img.shields.io/badge/Automation-Python%203-3776AB?logo=python&logoColor=white)](https://www.python.org/)

An enterprise-grade **Internal Developer Portal (IDP)** built from scratch using **Spotify Backstage (New Backend System)**, **PostgreSQL**, the **GitHub API**, and an event-driven **Python Webhook Receiver**.

This project solves the problem of developer cognitive load and microservice sprawl by providing standardized **"Golden Paths"** that reduce new service provisioning time from hours to under 30 seconds.

---

## 🏛️ System Architecture

```
                                  +-------------------------------------+
                                  |         Developer (Browser)         |
                                  +-------------------------------------+
                                                     │
                                                     ▼
+---------------------------------------------------------------------------------------------------+
| Backstage Monorepo (Node.js LTS / React)                                                          |
|                                                                                                   |
|  [ Frontend (Port :3000) ]                                                                        |
|  ├── Software Catalog UI (Service Discovery & Ownership)                                          |
|  └── Scaffolder Form (Parameter inputs & entity picker)                                            |
|                                                                                                   |
|  [ Backend - Modern System (Port :7007) ]                                                         |
|  ├── Scaffolder Engine (Nunjucks templating & execution pipeline)                                 |
|  └── Custom Module: `scaffolderModuleWebhookAction` (Zod-validated Action)                        |
+------------------------------------+-----------------------------+--------------------------------+
                                     │                             │
                     PostgreSQL Pool │        GitHub REST API      │ HTTP POST Webhook
                     (Port :5432)    │        (repo creation)      │ (Port :8080)
                                     ▼                             ▼
                +-------------------------+     +-------------------+     +-------------------------+
                |   PostgreSQL Container  |     |   GitHub Remote   |     | Python Webhook Receiver |
                |      (Docker Compose)   |     |  Repositories     |     |   (scripts/webhook)     |
                |  - Catalog Entities     |     |  - Templated Code |     |  - ChatOps / Slack Hook |
                |  - Knex Migrations      |     |  - catalog-info   |     |  - Security Scanning    |
                +-------------------------+     +-------------------+     +-------------------------+
```

---

## ✨ Key Platform Features

1. **Persistent State Management:**
   - Swapped out default ephemeral in-memory SQLite for a robust containerized **PostgreSQL 16** engine.
   - Database persistence with Docker named volumes (`pgdata`) and healthchecks using `pg_isready`.
   - Automated table schema migrations across all core plugins via Knex.js.

2. **Automated Golden Path Scaffolding:**
   - Interactive multi-step web wizard collecting service metadata (Component ID, Owner, GitHub repository location).
   - Dynamic parameter substitution using Nunjucks templating.
   - Automated git repo initialization, initial commit creation, and branch publishing directly to GitHub via authenticated GitHub PAT.

3. **Custom Platform Extension (`webhook:notify`):**
   - Built a custom Backstage Scaffolder Action adhering to Backstage's **New Backend System** architecture.
   - Enforced type-safe inputs using **Zod schema validation**.
   - Integrated with the Scaffolder extension point (`scaffolderActionsExtensionPoint`).

4. **Event-Driven Post-Provisioning Automation:**
   - Standalone Python HTTP webhook listener (`scripts/webhook_listener.py`) capturing real-time post-scaffold events.
   - Simulates downstream enterprise platform workflows (ChatOps notifications, CMDB registration, and compliance tracking).

---

## 📁 Repository Structure

```text
enterprise-developer-portal/
├── docker/
│   └── docker-compose.yml       # PostgreSQL container definition & healthcheck
├── portal/                      # Spotify Backstage monorepo
│   ├── app-config.yaml          # Master platform configuration
│   ├── app-config.local.yaml    # Local secrets & token overrides (gitignored)
│   ├── packages/
│   │   ├── app/                 # React Material-UI frontend
│   │   └── backend/             # Node.js Express backend
│   │       └── src/
│   │           └── modules/
│   │               └── webhookAction.ts  # Custom Scaffolder Action
│   └── examples/
│       └── template/            # Golden Path template definition
│           └── template.yaml    # Scaffolder execution pipeline
├── scripts/
│   └── webhook_listener.py      # Python post-scaffold event receiver
├── .gitignore                   # Enterprise security exclusion list
└── README.md                    # Platform documentation & runbook
```

---

## 🚀 Quickstart Runbook

### Prerequisites
- **Node.js**: v20 or v24
- **Yarn**: Classic v1.x
- **Docker & Docker Compose**
- **Python**: 3.10+
- **GitHub Personal Access Token (Classic)** with `repo` scope

### 1. Start the PostgreSQL Persistence Layer
```bash
docker compose -f docker/docker-compose.yml up -d
docker ps --filter "name=backstage-postgres"
```

### 2. Configure GitHub Authentication
Create `portal/app-config.local.yaml` (automatically gitignored):
```yaml
integrations:
  github:
    - host: github.com
      token: ghp_your_personal_access_token_here
```

### 3. Launch the Python Webhook Listener
In a separate terminal tab:
```bash
python3 scripts/webhook_listener.py
```

### 4. Boot the Developer Portal
```bash
cd portal
yarn start
```
* **Frontend:** [http://localhost:3000](http://localhost:3000)
* **Backend API:** [http://localhost:7007](http://localhost:7007)

---

## 🧪 Verification & Demo

1. Open your browser to `http://localhost:3000/create`.
2. Select the **Example Node.js Template**.
3. Enter your component details and GitHub username.
4. Click **Create** and observe:
   - Green checkmarks across template fetching, GitHub publication, and catalog registration.
   - The custom step **Trigger Platform Automation Webhook** executing.
   - The Python terminal logging the received payload in real time:

```text
============================================================
🚀 [POST-SCAFFOLD EVENT RECEIVED]
============================================================
{
  "service": "enterprise-service-v3",
  "repoUrl": "https://github.com/albin8800/enterprise-service-v3.git",
  "status": "SUCCESS"
}
============================================================
⚡ Triggering simulated post-provisioning tasks...
   [+] Registered enterprise-service-v3 with Platform Catalog
   [+] Slack alert dispatched for repository
============================================================
```

---

## 🛡️ Security & Best Practices

- **Zero Secret Sprawl:** Secrets are strictly decoupled using `.local.yaml` overrides and environment variables.
- **Role-Based Workspaces:** Adheres to Yarn monorepo isolation and Backstage dependency injection boundaries.
- **Fail-Safe Persistence:** Uses PostgreSQL Docker volumes rather than ephemeral memory to guarantee zero data loss on service restarts.
