
provider "azurerm" {
    features {

        resource_group {
            prevent_deletion_if_contains_resources = false
    }
    }
    subscription_id = var.subscription_id
    tenant_id       = var.tenant_id
    client_id       = var.client_id
    client_secret   = var.client_secret

    
}

# Resource Group
resource "azurerm_resource_group" "rg" {

    name     = var.name_rg
    location = var.location_rg

}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
    name                = "vnet-terraform"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

# Subnet
resource "azurerm_subnet" "subnet" {
    name                 = "subnet-terraform"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = ["10.0.2.0/24"]
}

# Network Security Group (NSG)
resource "azurerm_network_security_group" "nsg" {
    name                = "myNSG"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "app"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8000"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "http"
        priority                   = 1000
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

# ربط NSG بالـ Subnet
resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
    subnet_id                 = azurerm_subnet.subnet.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}

# Public IP
resource "azurerm_public_ip" "public_ip" {
    name                = "vm-public-ip"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method   = "Static"
}

# Network Interface
resource "azurerm_network_interface" "nic" {
    name                = "vm-nic"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
        name                          = "internal"
        subnet_id                     = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.public_ip.id
    }
}

# ربط NSG بالـ NIC (اختياري لو حابب بدل ربطه بالـ Subnet)
# resource "azurerm_network_interface_security_group_association" "nic_nsg" {
#   network_interface_id      = azurerm_network_interface.nic.id
#   network_security_group_id = azurerm_network_security_group.nsg.id
# }

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "vm" {
    name                = "AI-VM-Server"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    size                = "Standard_B2s"
    admin_username      = "BackendServer"
    network_interface_ids = [
        azurerm_network_interface.nic.id,
    ]

    admin_ssh_key {
        username   = "BackendServer"
        public_key = var.ssh_public_key
    }

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
        disk_size_gb = 256
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-focal"
        sku       = "20_04-lts"
        version   = "latest"
    }
}

# Output public IP
output "public_ip" {
    value = azurerm_public_ip.public_ip.ip_address
}

# Output VM Admin Username
output "vm_admin_username" {
    value = azurerm_linux_virtual_machine.vm.admin_username
}