output "subnet_ids" {
  description = "Map of subnet name to id."
  value       = module.network.subnet_ids
}

output "tags" {
  description = "The tags applied to the network."
  value       = module.tags.tags
}

output "vnet_id" {
  description = "The id of the virtual network."
  value       = module.network.vnet_id
}
