# RecoMind Infrastructure Pipeline

This directory contains the infrastructure provisioning and server configuration components for the RecoMind platform.

## Overview

The infrastructure pipeline handles:

1. **Terraform Provisioning** - Creates Azure resources including VMs, networking, and storage
2. **Ansible Configuration** - Configures servers with required software (Docker, Nginx, Python)
3. **Jenkins Pipeline** - Orchestrates the entire infrastructure deployment

## Directory Structure

```
Pipline_infrastructure/
├── Terraform/
│   ├── Terraform_AIVmServer/    # Main VM infrastructure
│   │   ├── main.tf              # Azure resources definition
│   │   ├── variables.tf         # Input variables
│   │   └── Backend.tf           # Remote state configuration
│   └── Terraform_Create_Storage/ # Storage for Terraform state
│       ├── main.tf
│       └── variables.tf
├── ansible/
│   ├── Roles/
│   │   ├── tasks/
│   │   │   ├── main.yml
│   │   │   └── templatesTasks/
│   │   │       ├── Docker.yml       # Docker installation
│   │   │       ├── nginx-setup.yml  # Nginx installation
│   │   │       └── install-Python.yml # Python setup
│   │   └── defaults/
│   │       └── main.yml
│   └── SetupVmPlaybook.yml      # Main setup playbook
└── jenkins/
    └── jenkinsfile-Dev          # Infrastructure pipeline
```

## Terraform Resources

### AI Server VM (`Terraform_AIVmServer`)

| Resource | Name | Description |
|----------|------|-------------|
| Resource Group | DevOpsRG_AI | Container for all resources |
| Virtual Network | vnet-terraform | 10.0.0.0/16 address space |
| Subnet | subnet1 | 10.0.1.0/24 |
| NSG | myNSG | Network security rules |
| Public IP | vm-public-ip | Static IP for VM |
| VM | AI-VM-Server | Ubuntu 20.04 LTS (Standard_D4s_v3) |

### Security Rules

| Rule | Port | Priority | Description |
|------|------|----------|-------------|
| SSH | 22 | 1001 | Remote access |
| HTTP | 80 | 1000 | Web traffic |
| App | 8000 | 100 | Application API |

## Ansible Roles

The setup playbook installs and configures:

- **Python 3.10** - System Python with pip and venv
- **Nginx** - Web server and reverse proxy
- **Docker** - Container runtime with docker-compose

## Jenkins Pipeline Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| SKIP_TERRAFORM | false | Skip infrastructure provisioning |
| SKIP_ANSIBLE | false | Skip server configuration |

## Usage

### Running via Jenkins

The pipeline can be triggered from Jenkins with optional parameters to skip certain stages.

### Manual Terraform Commands

```bash
cd Terraform/Terraform_AIVmServer

# Set environment variables
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"
export TF_VAR_ssh_public_key="your-ssh-public-key"

# Initialize and apply
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### Manual Ansible Commands

```bash
cd ansible

# Create inventory
cat > ansible_inventory.ini << EOF
[all]
server ansible_host=<IP> ansible_user=AI_Server ansible_ssh_private_key_file=~/.ssh/id_rsa
EOF

# Run playbook
ansible-playbook -i ansible_inventory.ini SetupVmPlaybook.yml
```

## Outputs

After Terraform apply, the following outputs are available:

- `public_ip` - The VM's public IP address
- `vm_admin_username` - The VM admin username (AI_Server)
