variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
  default     = "rg-terraform-lab"
}

variable "location" {
  description = "Azure region for the infrastructure"
  type        = string
  default     = "Central India"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "subnet_address_prefixes" {
  description = "Address range for the application subnet"
  type        = list(string)
  default     = ["10.10.1.0/24"]
}
