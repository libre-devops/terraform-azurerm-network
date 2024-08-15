resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.rg_name
  location            = var.location
  address_space       = var.vnet_address_space
  dns_servers         = var.dns_servers
  tags                = var.tags
}

resource "azurerm_subnet" "subnet" {
  for_each = var.subnets

  name                                          = each.key
  resource_group_name                           = var.rg_name
  virtual_network_name                          = azurerm_virtual_network.vnet.name
  address_prefixes                              = toset(each.value.address_prefixes)
  service_endpoints                             = toset(each.value.service_endpoints)
  service_endpoint_policy_ids                   = toset(each.value.service_endpoint_policy_ids)
  private_endpoint_network_policies             = each.value.private_endpoint_network_policies
  private_link_service_network_policies_enabled = each.value.private_link_service_network_policies_enabled

  dynamic "delegation" {
    for_each = each.value.delegation != null ? each.value.delegation : []
    content {
      name = delegation.value.type
      service_delegation {
        name    = delegation.value.type
        actions = lookup(var.subnet_delegations_actions, delegation.value.type, delegation.value.action)
      }
    }
  }
}

locals {
  subnets = {
    for subnet in azurerm_subnet.subnet :
    subnet.name => subnet.id
  }
}

resource "azurerm_subnet_network_security_group_association" "vnet" {
  for_each                  = var.nsg_ids != null ? var.nsg_ids : {}
  subnet_id                 = local.subnets[each.key]
  network_security_group_id = each.value
}

locals {
  route_table_associations = { for assoc in azurerm_subnet_route_table_association.this : assoc.id => { subnet_id = assoc.subnet_id, route_table_id = assoc.route_table_id } }

  grouped_by_route_table = { for rt_id in distinct([for assoc in local.route_table_associations : local.route_table_associations[assoc].route_table_id]) :
    rt_id => [for assoc in local.route_table_associations : local.route_table_associations[assoc].subnet_id if local.route_table_associations[assoc].route_table_id == rt_id]
  }
}


resource "azurerm_route_table" "this" {
  for_each = var.route_tables

  name                          = each.key
  location                      = var.location
  resource_group_name           = var.rg_name
  bgp_route_propagation_enabled = false

  dynamic "route" {
    for_each = each.value.routes
    content {
      name                   = route.key
      address_prefix         = route.value.address_prefix
      next_hop_type          = route.value.next_hop_type
      next_hop_in_ip_address = lookup(route.value, "next_hop_in_ip_address", null)
    }
  }
}

resource "azurerm_subnet_route_table_association" "this" {
  depends_on     = [azurerm_subnet.subnet]
  for_each       = var.subnet_route_table_associations
  subnet_id      = local.subnets[each.key]
  route_table_id = azurerm_route_table.this[each.value].id
}
