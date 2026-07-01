locals {
  location  = lookup(var.regions, var.loc, "uksouth")
  rg_name   = "rg-${var.short}-${var.loc}-${terraform.workspace}-002"
  vnet_name = "vnet-${var.short}-${var.loc}-${terraform.workspace}-002"
}

module "tags" {
  source  = "libre-devops/tags/azurerm"
  version = "~> 4.0"

  environment     = "prd"
  cost_centre     = "1888/67"
  owner           = "platform@example.com"
  deployed_branch = var.deployed_branch
  deployed_repo   = var.deployed_repo
  additional_tags = { Application = "terraform-azurerm-network" }
}

module "rg" {
  source  = "libre-devops/rg/azurerm"
  version = "~> 4.0"

  resource_groups = [
    {
      name     = local.rg_name
      location = local.location
      tags     = module.tags.tags
    },
  ]
}

# Raw NSG and route table to demonstrate the subnet associations by id. These become the nsg and
# route-table modules later; the network module only associates them, it does not own them.
resource "azurerm_network_security_group" "this" {
  name                = "nsg-${var.short}-${var.loc}-${terraform.workspace}-002"
  resource_group_name = module.rg.names[local.rg_name]
  location            = local.location
  tags                = module.tags.tags
}

resource "azurerm_route_table" "this" {
  name                = "rt-${var.short}-${var.loc}-${terraform.workspace}-002"
  resource_group_name = module.rg.names[local.rg_name]
  location            = local.location
  tags                = module.tags.tags
}

# Complete call: exercises the runnable surface, DNS servers, flow timeout, vnet private-endpoint
# policy, and three subnets covering service endpoints, a delegation, private-endpoint policy and
# default-outbound overrides, and NSG / route table associations.
#
# The remaining optionals need external prerequisites, set them when you have those:
#   ddos_protection_plan   = { id = <ddos plan id>, enable = true }
#   encryption_enforcement = "AllowUnencrypted"                       # vnet-encryption-capable infra
#   ip_address_pool        = { id = <IPAM pool id>, number_of_ip_addresses = "256" }
#   edge_zone              = "<edge zone>"
#   bgp_community          = "12076:20000"                            # ExpressRoute route advertisement
module "network" {
  source = "../../"

  resource_group_id = module.rg.ids[local.rg_name]
  location          = local.location
  tags              = module.tags.tags

  vnet_name                      = local.vnet_name
  address_space                  = ["10.10.0.0/16"]
  dns_servers                    = ["10.10.0.4", "10.10.0.5"]
  flow_timeout_in_minutes        = 10
  private_endpoint_vnet_policies = "Basic"

  subnets = {
    "snet-app-${local.vnet_name}" = {
      address_prefixes                              = ["10.10.1.0/24"]
      service_endpoints                             = ["Microsoft.Storage", "Microsoft.KeyVault"]
      private_link_service_network_policies_enabled = true
    }
    "snet-web-${local.vnet_name}" = {
      address_prefixes = ["10.10.2.0/24"]
      delegations      = ["Microsoft.Web/serverFarms"]
    }
    "snet-pe-${local.vnet_name}" = {
      address_prefixes                  = ["10.10.3.0/24"]
      private_endpoint_network_policies = "Disabled" # a private endpoint subnet
      default_outbound_access_enabled   = true       # override the secure default
    }
  }

  # Associations are separate maps keyed by subnet name, so these ids (created in this same apply)
  # can be computed without breaking for_each.
  nsg_associations = {
    "snet-app-${local.vnet_name}" = azurerm_network_security_group.this.id
    "snet-web-${local.vnet_name}" = azurerm_network_security_group.this.id
    "snet-pe-${local.vnet_name}"  = azurerm_network_security_group.this.id
  }
  route_table_associations = {
    "snet-app-${local.vnet_name}" = azurerm_route_table.this.id
  }
}
