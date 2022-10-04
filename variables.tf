variable "vm_count" {
  default     = 2
  description = "Number of machines to create"
}

variable "resource_group_location" {
  default     = "eastus"
  description = "Location of the resource group."
}

variable "vm_parameters" {
  type = map(object({
    ubuntu_image = string
    size         = string
  }))
  description = "Parameters for each VM, where the key is VM index in the VM array and value is the vm parameters."
  default = {
  }
}
