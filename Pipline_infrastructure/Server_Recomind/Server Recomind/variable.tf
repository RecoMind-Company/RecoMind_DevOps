variable "subscription_id" {}
variable "tenant_id" {}
variable "client_id" {}
variable "client_secret" {}

variable "ssh_public_key" {}

variable "group_name" {
  default = "MainServerRG"
}
variable "location" {
  default = "spaincentral"
}


variable "network_name" {
  default = "MainServerVNet"
}

variable "subnet_name" {
  default = "MainServerSubnet"
}

variable "nsg_name" {
  default = "MainServerNSG"
}

variable "public_ip_name" {
  default = "MainServerPublicIP"
}

variable "nic_name" {
  default = "MainServerNIC"
}

variable "vm_name" {
  default = "MainServerVM"
}
variable "vm_size" {
  default = "Standard_D2as_v5"
}

variable "admin_username" {
  default = "azureuser"
}



