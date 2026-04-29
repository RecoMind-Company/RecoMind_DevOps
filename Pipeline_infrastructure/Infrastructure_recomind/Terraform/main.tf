provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# VNet
resource "azurerm_virtual_network" "vnet" {
  name                = "aks-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/8"]
}

# Subnet
resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.240.0.0/16"]
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name                 = "default"
    vm_size              = var.vm_size
    auto_scaling_enabled = true
    min_count            = var.min_count
    max_count            = var.max_count
    vnet_subnet_id       = azurerm_subnet.aks_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
  }

  tags = {
    environment = var.environment
  }
}

# Extra Node Pool (heavy workloads)
resource "azurerm_kubernetes_cluster_node_pool" "extra" {
  name                  = "ai-nodepool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.extra_vm_size

  auto_scaling_enabled = true
  min_count            = 1
  max_count            = 2

  vnet_subnet_id = azurerm_subnet.aks_subnet.id
}






















# provider "azurerm" {
#   features {}
#   subscription_id = var.subscription_id
#   tenant_id       = var.tenant_id
#   client_id       = var.client_id
#   client_secret   = var.client_secret
# }

# # Resource Group
# resource "azurerm_resource_group" "rg" {

#   name     = var.name_rg
#   location = var.location_rg

# }

# # Virtual Network
# resource "azurerm_virtual_network" "vnet" {
#   name                = "vnet-terraform"
#   address_space       = ["10.0.0.0/16"]
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
# }

# # Subnet
# resource "azurerm_subnet" "subnet" {
#   name                 = "subnet1"
#   resource_group_name  = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes     = ["10.0.1.0/24"]
# }

# # Network Security Group (NSG)
# resource "azurerm_network_security_group" "nsg" {
#   name                = "myNSG"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name

#   security_rule {
#     name                       = "SSH"
#     priority                   = 1001
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "22"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }

#   security_rule {
#     name                       = "app"
#     priority                   = 100
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "8000"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }

#   security_rule {
#     name                       = "http"
#     priority                   = 1000
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "80"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
# }

# # ربط NSG بالـ Subnet
# resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
#   subnet_id                 = azurerm_subnet.subnet.id
#   network_security_group_id = azurerm_network_security_group.nsg.id
# }

# # Public IP
# resource "azurerm_public_ip" "public_ip" {
#   name                = "vm-public-ip"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   allocation_method   = "Static"
# }

# # Network Interface
# resource "azurerm_network_interface" "nic" {
#   name                = "vm-nic"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name

#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = azurerm_subnet.subnet.id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = azurerm_public_ip.public_ip.id
#   }
# }

# # ربط NSG بالـ NIC (اختياري لو حابب بدل ربطه بالـ Subnet)
# # resource "azurerm_network_interface_security_group_association" "nic_nsg" {
# #   network_interface_id      = azurerm_network_interface.nic.id
# #   network_security_group_id = azurerm_network_security_group.nsg.id
# # }

# # Linux Virtual Machine
# resource "azurerm_linux_virtual_machine" "vm" {
#   name                = "AI-VM-Server"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   size                = "Standard_D4s_v3"
#   admin_username      = "AI_Server"
#   network_interface_ids = [
#     azurerm_network_interface.nic.id,
#   ]

#   admin_ssh_key {
#     username   = "AI_Server"
#     public_key = var.ssh_public_key
#   }

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#     disk_size_gb = 256
#   }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-focal"
#     sku       = "20_04-lts"
#     version   = "latest"
#   }
# }

# # Output public IP
# output "public_ip" {
#   value = azurerm_public_ip.public_ip.ip_address
# }

# # Output VM Admin Username
# output "vm_admin_username" {
#   value = azurerm_linux_virtual_machine.vm.admin_username
# }


