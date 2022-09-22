variable "vm_count" {
  default     = 2
  description = "Number of machines to create"
}

variable "resource_group_location" {
  default     = "eastus"
  description = "Location of the resource group."
}

variable "vm_size" {
  default = "Standard_D1_v2"
  description = "VM size in Azure"
}

variable "vm_ubuntu_image_sku" {
  default = "18.04-LTS"
  description = "SKU for Ubuntu image"
}