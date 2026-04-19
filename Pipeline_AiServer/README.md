# RecoMind AI Server Pipeline

This directory contains the CI/CD pipeline and deployment configuration for the RecoMind AI services.

## Overview

The AI Server pipeline handles:

1. **Continuous Integration** - Code scanning, Docker image builds, and security analysis
2. **Continuous Deployment** - Automated deployment to Azure VM
3. **Service Configuration** - Nginx reverse proxy and Docker Compose orchestration

## Directory Structure

```
Pipline_AiServer/
├── Jenkins/
│   ├── jenkinsfile-ci    # CI pipeline - build and push images
│   └── jenkinsfile-cd    # CD pipeline - deploy to server
├── ansible/
│   ├── Roles/
│   │   ├── tasks/
│   │   │   ├── main.yml
│   │   │   └── templatesTasks/
│   │   │       ├── moveFileDockerCompos.yml
│   │   │       └── nginx-confg.yml
│   │   ├── defaults/
│   │   │   └── main.yml
│   │   └── templates/
│   │       └── nginx.conf.j2
│   └── playbook-cd.yml
└── docker-compose.yml    # Service definitions
```

## CI Pipeline Stages

| Stage | Description |
|-------|-------------|
| Checkout Source Code | Clone RecoMind-AI repository |
| Archive Outputs | Save docker-compose.yml artifact |
| OWASP Dependency Check | Scan for vulnerable dependencies |
| SonarQube Scan | Code quality analysis |
| Build Docker Images | Build data_embedding and reporting_system images |
| Trivy Security Scan | Container vulnerability scanning |
| DockerHub Login | Authenticate with registry |
| Push Images | Push to DockerHub |
| Trigger CD Pipeline | Start deployment |

## CD Pipeline Stages

| Stage | Description |
|-------|-------------|
| Get Artifacts | Retrieve infrastructure outputs |
| Prepare Ansible Files | Set up deployment configuration |
| Add IP to Ansible Defaults | Configure server address |
| Connect to AI Server | Verify SSH connectivity |
| Create Inventory | Generate Ansible inventory file |
| Run Ansible Playbook | Deploy Nginx configuration |
| Stop Containers | Gracefully stop running containers |
| Pull Docker Images | Download latest images |
| Start Containers | Launch services |

## Docker Services

| Service | Image | Port | Description |
|---------|-------|------|-------------|
| redis | redis:7-alpine | 6379 | Message queue |
| data_embedding_api | hossamtaha9/recomind-ai-vector-data_embedding:latest | 8000 | Embedding API |
| data_embedding_worker | hossamtaha9/recomind-ai-vector-data_embedding:latest | - | Celery worker |
| reporting_system_api | hossamtaha9/recomind-ai-vector-reporting_system:latest | 8001 | Reporting API |
| reporting_system_worker | hossamtaha9/recomind-ai-vector-reporting_system:latest | - | Reporting worker |

## Nginx Configuration

The Nginx reverse proxy routes traffic as follows:

| Path | Backend | Description |
|------|---------|-------------|
| `/` | Redirect | Redirects to /reporting/ |
| `/reporting/` | localhost:8001 | Reporting System API |
| `/reporting/static/` | File system | Static files |
| `/embedding/` | localhost:8000 | Data Embedding API |
| `/embedding/static/` | File system | Static files |

## Ansible Variables

### Defaults (`Roles/defaults/main.yml`)

| Variable | Default | Description |
|----------|---------|-------------|
| reporting_port | 8001 | Reporting service port |
| reporting_container_name | recomind-reporting-system | Reporting container |
| embedding_port | 8000 | Embedding service port |
| embedding_container_name | recomind-ingestion-api | Embedding container |
| server_domain_or_IP | - | Server address (set by pipeline) |

## Environment Variables

The services require a `.env` file with the following variables:

```bash
# OpenRouter/OpenAI Configuration
OPENROUTER_API_KEY=your_api_key
BASE_URL=https://openrouter.ai/api/v1
crewai_LLM_MODEL=your_model_name

# Redis (configured automatically via docker-compose)
# REDIS_URL=redis://recomind-redis:6379
```

## Manual Deployment

### Deploy with Ansible

```bash
cd ansible

# Create inventory file
cat > ansible_inventory.ini << EOF
[all]
server ansible_host=<SERVER_IP> ansible_user=AI_Server ansible_ssh_private_key_file=~/.ssh/id_rsa
EOF

# Update server IP in defaults
sed -i "s/server_domain_or_IP:.*/server_domain_or_IP: '<SERVER_IP>'/" Roles/defaults/main.yml

# Run playbook
ansible-playbook -i ansible_inventory.ini playbook-cd.yml
```

### Deploy with Docker Compose

```bash
# SSH to server
ssh AI_Server@<SERVER_IP>

# Create .env file
cat > .env << EOF
OPENROUTER_API_KEY=your_key
BASE_URL=your_base_url
crewai_LLM_MODEL=your_model
EOF

# Start services
docker compose pull
docker compose up -d
```

## Monitoring

Check service health:

```bash
# View running containers
docker compose ps

# View logs
docker compose logs -f

# Check specific service
docker compose logs -f data_embedding_api
```
