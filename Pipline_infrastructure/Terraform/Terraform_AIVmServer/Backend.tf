terraform {
    backend "azurerm" {
        resource_group_name  = "DevOpsRG"
        storage_account_name = "devopsstorage0089"
        container_name       = "devopsstoragecontainer009"
        key                  = "terraform.tfstate"
    }
}