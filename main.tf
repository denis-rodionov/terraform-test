resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = "rg-bosch-test"
}

resource "azurerm_virtual_network" "test_vpc" {
  name                = "test_vpc"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "test_subnet" {
  name                 = "test_subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.test_vpc.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "vm_public_ip" {
  count               = var.vm_count
  name                = "vm-public-ip-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "vm_nic" {
  count               = var.vm_count
  name                = "vm_nic-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "vm_nic_configuration-${count.index}"
    subnet_id                     = azurerm_subnet.test_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip[count.index].id
  }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "test_nsg" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow-icmp"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    destination_port_range = "*"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Connect the security group to the network interfaces
resource "azurerm_network_interface_security_group_association" "acc_vm1_nic" {
  count                     = var.vm_count
  network_interface_id      = azurerm_network_interface.vm_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.test_nsg.id
}

resource "random_password" "password" {
  count = var.vm_count
  length           = 16
  override_special = "_"
}

# Create virtual machines
resource "azurerm_linux_virtual_machine" "vm" {
  count                 = var.vm_count
  name                  = "vm-${count.index}"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.vm_nic[count.index].id]

  size = "Standard_D1_v2"

  admin_username                  = "vm_admin"
  admin_password                  = random_password.password[count.index].result
  disable_password_authentication = false

  os_disk {
    name                 = "vm-disk-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

data "external" "ping_result" {
  program = ["python3", "${path.module}/ping_result.py"]
  query = {
    list_of_vms = "${join(",", azurerm_linux_virtual_machine.vm.*.name)}"
    list_of_ips = "${join(",", azurerm_linux_virtual_machine.vm.*.public_ip_address)}"
    ssh_username = "vm_admin"
    list_of_passwords = "${join(",", random_password.password.*.result)}"
  }
  depends_on = [azurerm_linux_virtual_machine.vm]
}

locals {
  ping_result = data.external.ping_result.result  
}
