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
variable "ssh_public_key" {}


variable "resource_group_name" {
  default = "aks-rg-AI"
}

variable "location" {
  default = "spaincentral"
}

variable "cluster_name" {
  default = "AI-aks"
}

variable "dns_prefix" {
  default = "AI-aks"
}

variable "vm_size" {
  default = "Standard_B2s"
}

variable "min_count" {
  default = 1
}

variable "max_count" {
  default = 3
}

variable "environment" {
  default = "dev"
}

# extra pool
variable "extra_vm_size" {
  default = "Standard_D4s_v3"
}