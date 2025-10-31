terraform {
    backend "azurerm" {
        resource_group_name  = "DevOpsRG"
        storage_account_name = "devopsstorage008"
        container_name       = "devopsstoragecontainer00"
        key                  = "terraform.tfstate"
    }
}