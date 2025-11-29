# RecoMind DevOps

This repository contains the DevOps infrastructure and CI/CD pipelines for the RecoMind AI platform. It manages infrastructure provisioning on Azure using Terraform, configuration management with Ansible, and automated deployments through Jenkins pipelines.

## Repository Structure

```
RecoMind_DevOps/
├── Pipline_AiServer/           # AI Server deployment pipeline
│   ├── Jenkins/                # CI/CD Jenkinsfiles
│   │   ├── jenkinsfile-ci      # Continuous Integration pipeline
│   │   └── jenkinsfile-cd      # Continuous Deployment pipeline
│   ├── ansible/                # Ansible playbooks for deployment
│   │   ├── Roles/              # Ansible roles
│   │   └── playbook-cd.yml     # CD playbook
│   └── docker-compose.yml      # Docker Compose for AI services
│
└── Pipline_infrastructure/     # Infrastructure provisioning pipeline
    ├── Terraform/              # Infrastructure as Code
    │   ├── Terraform_AIVmServer/      # Azure VM provisioning
    │   └── Terraform_Create_Storage/  # Azure Storage for Terraform state
    ├── ansible/                # Server configuration playbooks
    │   ├── Roles/              # Ansible roles for server setup
    │   └── SetupVmPlaybook.yml # VM setup playbook
    └── jenkins/                # Infrastructure Jenkinsfile
        └── jenkinsfile-Dev     # Infrastructure pipeline
```

## Architecture Overview

The RecoMind platform consists of the following components:

- **Data Embedding API** - FastAPI service for data embedding operations (Port 8000)
- **Reporting System API** - Reporting service (Port 8001)
- **Redis** - Message queue for Celery workers
- **Celery Workers** - Background task processing
- **Nginx** - Reverse proxy for routing requests

## CI/CD Pipeline

### CI Pipeline (`Pipline_AiServer/Jenkins/jenkinsfile-ci`)

The Continuous Integration pipeline performs the following stages:

1. **Checkout Source Code** - Clones the RecoMind-AI repository
2. **OWASP Dependency Check** - Security vulnerability scanning
3. **SonarQube Scan** - Code quality analysis via SonarCloud
4. **Build Docker Images** - Builds data_embedding and reporting_system images in parallel
5. **Trivy Security Scan** - Container image vulnerability scanning
6. **Push to DockerHub** - Pushes images to the registry
7. **Trigger CD Pipeline** - Initiates deployment

### CD Pipeline (`Pipline_AiServer/Jenkins/jenkinsfile-cd`)

The Continuous Deployment pipeline:

1. **Get Artifacts** - Retrieves infrastructure outputs
2. **Prepare Ansible Files** - Sets up deployment configuration
3. **SSH Connection** - Establishes connection to AI Server
4. **Run Ansible Playbook** - Configures Nginx and deploys files
5. **Docker Operations** - Stops, pulls, and starts containers

## Infrastructure Provisioning

### Prerequisites

- Azure subscription
- Azure Service Principal with Contributor role
- SSH key pair for VM access
- Jenkins with required plugins

### Azure Resources

The Terraform configuration provisions:

- **Resource Group** - `DevOpsRG_AI`
- **Virtual Network** - `vnet-terraform` (10.0.0.0/16)
- **Subnet** - `subnet1` (10.0.1.0/24)
- **Network Security Group** - With rules for SSH (22), HTTP (80), and App (8000)
- **Linux VM** - Ubuntu 20.04 LTS (`Standard_D4s_v3`)

### Terraform Backend

State is stored in Azure Storage:
- Storage Account: `devopsstorage0089`
- Container: `devopsstoragecontainer009`

## Jenkins Credentials Required

| Credential ID | Type | Description |
|--------------|------|-------------|
| `Docker_Hub_Hossam` | Username/Password | DockerHub credentials |
| `SonarQube_jenkins` | Secret text | SonarQube token |
| `sonarCloud` | Secret text | SonarCloud token |
| `Git_hub` | Username/Password | GitHub credentials |
| `SSH_USER` | SSH Private Key | VM SSH access |
| `CLIENT_ID` | Secret text | Azure Service Principal |
| `CLIENT_SECRET` | Secret text | Azure Service Principal |
| `SUBSCRIPTION_ID` | Secret text | Azure Subscription |
| `TENANT_ID` | Secret text | Azure Tenant |
| `SSH_PUBLIC_KEY` | Secret text | SSH public key |

## Docker Services

The `docker-compose.yml` defines the following services:

| Service | Container Name | Port | Description |
|---------|---------------|------|-------------|
| redis | recomind-redis | 6379 | Redis message queue |
| data_embedding_api | recomind-ingestion-api | 8000 | Data embedding API |
| data_embedding_worker | recomind-ingestion-worker | - | Celery worker |
| reporting_system_api | recomind-reporting-system | 8001 | Reporting API |
| reporting_system_worker | recomind-reporting-system-worker | - | Reporting worker |

## Environment Variables

Create a `.env` file with the following variables:

```bash
# AI API Configuration
OPENROUTER_API_KEY=your_api_key
BASE_URL=your_base_url
crewai_LLM_MODEL=your_model_name

# Additional environment variables as needed
```

## Quick Start

### 1. Infrastructure Setup

```bash
# Initialize Terraform (first time)
cd Pipline_infrastructure/Terraform/Terraform_Create_Storage
terraform init
terraform apply

# Provision AI Server VM
cd ../Terraform_AIVmServer
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### 2. Server Configuration

```bash
# Create inventory file
cd Pipline_infrastructure/ansible
echo "[all]" > ansible_inventory.ini
echo "server ansible_host=<PUBLIC_IP> ansible_user=AI_Server ansible_ssh_private_key_file=~/.ssh/id_rsa" >> ansible_inventory.ini

# Run setup playbook
ansible-playbook -i ansible_inventory.ini SetupVmPlaybook.yml
```

### 3. Deploy Application

```bash
# Deploy using CD playbook
cd Pipline_AiServer/ansible
ansible-playbook -i ansible_inventory.ini playbook-cd.yml
```

## Contributing

1. Create a feature branch from `main`
2. Make your changes
3. Ensure CI pipeline passes
4. Submit a pull request

## License

This project is proprietary to RecoMind Company.
