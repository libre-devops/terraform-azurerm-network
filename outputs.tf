output "resource_group_name" {
  description = "Resource group name parsed from resource_group_id."
  value       = local.resource_group_name
}

output "subnet_address_prefixes" {
  description = "Map of subnet name to its address prefixes."
  value       = { for name, subnet in azurerm_subnet.this : name => subnet.address_prefixes }
}

output "subnet_ids" {
  description = "Map of subnet name to its id."
  value       = { for name, subnet in azurerm_subnet.this : name => subnet.id }
}

output "subnet_ids_zipmap" {
  description = "Map of subnet name to a { name, id } object, so the whole object can be passed where something needs the name and id together."
  value       = { for name, subnet in azurerm_subnet.this : name => { name = subnet.name, id = subnet.id } }
}

output "subnet_names" {
  description = "The subnet names."
  value       = keys(azurerm_subnet.this)
}

output "subnet_nsg_association_ids" {
  description = "Map of subnet name to its network security group association id."
  value       = { for name, assoc in azurerm_subnet_network_security_group_association.this : name => assoc.id }
}

output "subnet_route_table_association_ids" {
  description = "Map of subnet name to its route table association id."
  value       = { for name, assoc in azurerm_subnet_route_table_association.this : name => assoc.id }
}

output "subnets" {
  description = "The full azurerm_subnet resources, keyed by subnet name."
  value       = azurerm_subnet.this
}

output "subscription_id" {
  description = "Subscription id parsed from resource_group_id."
  value       = local.rg.subscription_id
}

output "vnet_address_space" {
  description = "The address space of the virtual network."
  value       = azurerm_virtual_network.this.address_space
}

output "vnet_dns_servers" {
  description = "The DNS servers set on the virtual network."
  value       = azurerm_virtual_network.this.dns_servers
}

output "vnet_guid" {
  description = "The GUID of the virtual network."
  value       = azurerm_virtual_network.this.guid
}

output "vnet_id" {
  description = "The id of the virtual network."
  value       = azurerm_virtual_network.this.id
}

output "vnet_location" {
  description = "The region of the virtual network."
  value       = azurerm_virtual_network.this.location
}

output "vnet_name" {
  description = "The name of the virtual network."
  value       = azurerm_virtual_network.this.name
}

output "vnet_resource_group_name" {
  description = "The resource group of the virtual network."
  value       = azurerm_virtual_network.this.resource_group_name
}

output "vnet_tags" {
  description = "The tags on the virtual network."
  value       = azurerm_virtual_network.this.tags
}
