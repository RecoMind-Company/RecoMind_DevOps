# variable "name_rg" {
#     default = "DevOpsRG_AI"
# }
# variable "location_rg" {
#     default = "spaincentral"
# }

variable "subscription_id" {}
variable "tenant_id" {}
variable "client_id" {}
variable "client_secret" {}
# variable "ssh_public_key" {}


variable "resource_group_name" {
  default = "aks-rg-Recomind"
}

variable "location" {
  default = "spaincentral"
}

variable "cluster_name" {
  default = "Recomind-aks"
}

variable "dns_prefix" {
  default = "Recomind-aks"
}

variable "vm_size" {
  default = "Standard_D2as_v5"
}

variable "min_count" {
  default = 1
}

variable "max_count" {
  default = 2
}

variable "environment" {
  default = "prod"
}

# extra pool
variable "extra_vm_size" {
  default = "Standard_D4as_v5"
}