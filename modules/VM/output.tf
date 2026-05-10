output "private_ip" {
  value = azurerm_network_interface.nic.private_ip_address
}

output "nic_id" {
  value = azurerm_network_interface.nic.id
}

output "vm_id" {
  value = azurerm_linux_virtual_machine.vm.id
}