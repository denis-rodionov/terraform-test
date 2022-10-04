vm_count                = 3
resource_group_location = "eastus"

vm_parameters = {
  "0" = {
    ubuntu_image = "18.04-LTS"
    size         = "Standard_D11_v2"
  },
  "1" = {
    ubuntu_image = "18.04-LTS"
    size         = "Standard_D1_v2"
  }
}