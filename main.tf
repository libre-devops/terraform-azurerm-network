# Virtual network plus its subnets, and the subnet's optional NSG / route table associations.
# Route tables and NSGs themselves are separate modules: this module associates them by id, so it
# composes with the route-table and nsg modules without depending on them. Standard: resources in
# main.tf only, "this" as the label.
#
# The resource group is passed by id (the rg module exports ids); the name and subscription are
# parsed from it with the azurerm provider function, so callers pass one id rather than name+sub.
locals {
  rg                  = provider::azurerm::parse_resource_id(var.resource_group_id)
  resource_group_name = local.rg.resource_group_name
}

resource "azurerm_virtual_network" "this" {
  name                           = var.vnet_name
  resource_group_name            = local.resource_group_name
  location                       = var.location
  address_space                  = length(var.address_space) > 0 ? var.address_space : null
  dns_servers                    = var.dns_servers
  bgp_community                  = var.bgp_community
  flow_timeout_in_minutes        = var.flow_timeout_in_minutes
  edge_zone                      = var.edge_zone
  private_endpoint_vnet_policies = var.private_endpoint_vnet_policies
  tags                           = var.tags

  dynamic "ip_address_pool" {
    for_each = var.ip_address_pool != null ? [var.ip_address_pool] : []
    content {
      id                     = ip_address_pool.value.id
      number_of_ip_addresses = ip_address_pool.value.number_of_ip_addresses
    }
  }

  dynamic "ddos_protection_plan" {
    for_each = var.ddos_protection_plan_id != null ? [1] : []
    content {
      id     = var.ddos_protection_plan_id
      enable = true
    }
  }

  dynamic "encryption" {
    for_each = var.encryption_enforcement != null ? [1] : []
    content {
      enforcement = var.encryption_enforcement
    }
  }
}

resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                                          = each.key
  resource_group_name                           = local.resource_group_name
  virtual_network_name                          = azurerm_virtual_network.this.name
  address_prefixes                              = length(each.value.address_prefixes) > 0 ? each.value.address_prefixes : null
  service_endpoints                             = each.value.service_endpoints
  service_endpoint_policy_ids                   = each.value.service_endpoint_policy_ids
  private_endpoint_network_policies             = each.value.private_endpoint_network_policies
  private_link_service_network_policies_enabled = each.value.private_link_service_network_policies_enabled
  default_outbound_access_enabled               = each.value.default_outbound_access_enabled
  sharing_scope                                 = each.value.sharing_scope

  dynamic "ip_address_pool" {
    for_each = each.value.ip_address_pool != null ? [each.value.ip_address_pool] : []
    content {
      id                     = ip_address_pool.value.id
      number_of_ip_addresses = ip_address_pool.value.number_of_ip_addresses
    }
  }

  dynamic "delegation" {
    for_each = each.value.delegations
    content {
      name = delegation.value
      service_delegation {
        name    = delegation.value
        actions = lookup(var.subnet_delegation_actions, delegation.value, null)
      }
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = { for name, subnet in var.subnets : name => subnet.nsg_id if subnet.nsg_id != null }

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = each.value
}

resource "azurerm_subnet_route_table_association" "this" {
  for_each = { for name, subnet in var.subnets : name => subnet.route_table_id if subnet.route_table_id != null }

  subnet_id      = azurerm_subnet.this[each.key].id
  route_table_id = each.value
}
