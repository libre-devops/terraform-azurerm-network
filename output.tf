output "vnet_id" {
  description = "The id of the newly created vNet"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "The Name of the newly created vNet"
  value       = azurerm_virtual_network.vnet.name
}

output "vnet_location" {
  description = "The location of the newly created vNet"
  value       = azurerm_virtual_network.vnet.location
}

output "vnet_address_space" {
  description = "The address space of the newly created vNet"
  value       = azurerm_virtual_network.vnet.address_space
}

output "vnet_rg_name" {
  description = "The resource group name which the VNet is in"
  value       = azurerm_virtual_network.vnet.resource_group_name
}

output "vnet_subnets" {
  description = "The ids of subnets created inside the newly created vNet"
  value       = azurerm_subnet.subnet.*.id
}

output "subnets_name" {
  value = {
    for index, subnet in azurerm_subnet.subnet :
    subnet.name => subnet.name
  }
  description = "The name of the subnets created"
}

output "subnets_ids" {
  value = {
    for index, subnet in azurerm_subnet.subnet :
    subnet.name => subnet.id
  }
  description = "The ids of the subnets created"
}