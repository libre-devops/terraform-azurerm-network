output "route_table_ids" {
  description = "Map of Route Table names to their IDs."
  value       = { for name, rt in azurerm_route_table.this : name => rt.id }
}

output "subnet_ids_associated_with_route_tables" {
  value       = local.grouped_by_route_table
  description = "The IDs of the subnets associated with each route table"
}

output "subnets_ids" {
  value = {
    for key, subnet in azurerm_subnet.subnet :
    key => subnet.id
  }
  description = "The ids of the subnets created"
}

output "subnets_names" {
  value = {
    for index, subnet in azurerm_subnet.subnet :
    subnet.id => subnet.name
  }
  description = "The name of the subnets created"
}

output "vnet_address_space" {
  description = "The address space of the newly created vNet"
  value       = azurerm_virtual_network.vnet.address_space
}

output "vnet_dns_servers" {
  value       = var.dns_servers == [] ? ["168.63.129.16"] : var.dns_servers
  description = "The dns servers of the vnet, if it is using Azure default, this module will return the Azure 'wire' IP as a list of string in the 1st element"
}

output "vnet_id" {
  description = "The id of the newly created vNet"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_location" {
  description = "The location of the newly created vNet"
  value       = azurerm_virtual_network.vnet.location
}

output "vnet_name" {
  description = "The Name of the newly created vNet"
  value       = azurerm_virtual_network.vnet.name
}

output "vnet_rg_name" {
  description = "The resource group name which the VNet is in"
  value       = azurerm_virtual_network.vnet.resource_group_name
}
