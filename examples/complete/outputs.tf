output "subnet_ids" {
  description = "Map of subnet name to id."
  value       = module.network.subnet_ids
}

output "subnet_nsg_association_ids" {
  description = "Map of subnet name to its NSG association id."
  value       = module.network.subnet_nsg_association_ids
}

output "subnet_route_table_association_ids" {
  description = "Map of subnet name to its route table association id."
  value       = module.network.subnet_route_table_association_ids
}

output "tags" {
  description = "The tags applied to the network."
  value       = module.tags.tags
}

output "vnet_id" {
  description = "The id of the virtual network."
  value       = module.network.vnet_id
}
