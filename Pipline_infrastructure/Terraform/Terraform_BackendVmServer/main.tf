
provider "azurerm" {
    features {}
    subscription_id = var.subscription_id
    tenant_id       = var.tenant_id
    client_id       = var.client_id
    client_secret   = var.client_secret
}

# Resource Group
data "azurerm_resource_group" "rg" {
    name = var.name_rg
}

# Virtual Network
data "azurerm_virtual_network" "vnet" {
    name                = "vnet-terraform"
    resource_group_name = data.azurerm_resource_group.rg.name
}

# Subnet
data "azurerm_subnet" "subnet" {
    name                 = "subnet1"
    resource_group_name  = data.azurerm_resource_group.rg.name
    virtual_network_name = data.azurerm_virtual_network.vnet.name
}

# Network Security Group (NSG)
data "azurerm_network_security_group" "nsg" {
    name                = "myNSG"
    resource_group_name = data.azurerm_resource_group.rg.name
}

# ربط NSG بالـ Subnet
resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
    subnet_id                 = data.azurerm_subnet.subnet.id
    network_security_group_id = data.azurerm_network_security_group.nsg.id
}

# Public IP
resource "azurerm_public_ip" "public_ip" {
    name                = "Backend-VM-Server-public-ip"
    location            = data.azurerm_resource_group.rg.location
    resource_group_name = data.azurerm_resource_group.rg.name
    allocation_method   = "Static"
}

# Network Interface
resource "azurerm_network_interface" "nic" {
    name                = "Backend-VM-Server-nic"
    location            = data.azurerm_resource_group.rg.location
    resource_group_name = data.azurerm_resource_group.rg.name

    ip_configuration {
        name                          = "internal"
        subnet_id                     = data.azurerm_subnet.subnet.id
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
    name                = "Backend-VM-Server"
    resource_group_name = data.azurerm_resource_group.rg.name
    location            = data.azurerm_resource_group.rg.location
    size                = "Standard_B2ls_v2"
    admin_username      = "Backend_Server"
    network_interface_ids = [
        azurerm_network_interface.nic.id,
    ]

    admin_ssh_key {
        username   = "Backend_Server"
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