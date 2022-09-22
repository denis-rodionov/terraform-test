output "vms" {
  value = "${azurerm_linux_virtual_machine.vm.*.public_ip_address}"
}

output "ping_results" {
  value = local.ping_result
}

output "passwords" {
  value = random_password.password.*.result
  sensitive = true
}