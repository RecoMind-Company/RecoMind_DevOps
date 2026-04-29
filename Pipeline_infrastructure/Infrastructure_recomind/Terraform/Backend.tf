terraform {
  backend "azurerm" {
    resource_group_name  = "MainServerRG"
    storage_account_name = "mainserverstorage22"
    container_name       = "mainservercontainer22"
    key                  = "recomind/terraform.tfstate"
    
  }
}


