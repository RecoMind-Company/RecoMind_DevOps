terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "azurerm" {
  features {}

  # subscription_id = var.subscription_id
  # tenant_id       = var.tenant_id
  # client_id       = var.client_id
  # client_secret   = var.client_secret

}


# Resource Group
data "azurerm_resource_group" "rg" {
  name     = "DevOpsRG"     
  }

resource "azurerm_storage_account" "storage" {
  name                     = "devopsstorage008"
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  
}

resource "azurerm_storage_container" "container" {
  name                  = "devopsstoragecontainer00"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
  
}

output "storage_account_name" {
  value = azurerm_storage_account.storage.name
}

output "container_name" {
  value = azurerm_storage_container.container.name
}