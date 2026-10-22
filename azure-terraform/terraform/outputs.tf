output "resource_group_name" {
  description = "Azure resource group name"
  value       = azurerm_resource_group.lab.name
}

output "virtual_network_name" {
  description = "Azure virtual network name"
  value       = azurerm_virtual_network.lab.name
}

output "virtual_network_id" {
  description = "Azure virtual network resource ID"
  value       = azurerm_virtual_network.lab.id
}

output "subnet_id" {
  description = "Application subnet resource ID"
  value       = azurerm_subnet.app.id
}

output "network_security_group_id" {
  description = "Network security group resource ID"
  value       = azurerm_network_security_group.lab.id
}
