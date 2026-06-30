# Plan-time tests for the module. The azurerm provider is mocked, so no credentials, no
# features block, and no cloud calls are needed:
#   terraform init -backend=false && terraform test

mock_provider "azurerm" {}

variables {
  vnet_name         = "vnet-ldo-uks-tst-001"
  resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ldo-uks-tst-001"
  location          = "uksouth"
  address_space     = ["10.0.0.0/16"]
  subnets = {
    "snet-app-vnet-ldo-uks-tst-001" = {
      address_prefixes = ["10.0.1.0/24"]
    }
  }
}

run "creates_vnet_and_subnet" {
  command = plan

  assert {
    condition     = azurerm_virtual_network.this.name == "vnet-ldo-uks-tst-001"
    error_message = "The virtual network should use the requested name."
  }

  assert {
    condition     = length(azurerm_subnet.this) == length(var.subnets)
    error_message = "One subnet should be created per entry."
  }

  assert {
    condition     = output.subnet_ids_zipmap["snet-app-vnet-ldo-uks-tst-001"].name == "snet-app-vnet-ldo-uks-tst-001"
    error_message = "subnet_ids_zipmap should map each subnet name to a { name, id } object."
  }
}

run "parses_resource_group_id" {
  command = plan

  assert {
    condition     = output.resource_group_name == "rg-ldo-uks-tst-001"
    error_message = "resource_group_name should be parsed from resource_group_id."
  }

  assert {
    condition     = output.subscription_id == "00000000-0000-0000-0000-000000000000"
    error_message = "subscription_id should be parsed from resource_group_id."
  }
}

run "rejects_non_resource_group_id" {
  command = plan

  variables {
    resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Storage/storageAccounts/sa"
  }

  expect_failures = [var.resource_group_id]
}

run "subnet_secure_defaults" {
  command = plan

  assert {
    condition     = azurerm_subnet.this["snet-app-vnet-ldo-uks-tst-001"].private_endpoint_network_policies == "Enabled"
    error_message = "private_endpoint_network_policies should default to Enabled."
  }

  assert {
    condition     = azurerm_subnet.this["snet-app-vnet-ldo-uks-tst-001"].default_outbound_access_enabled == false
    error_message = "default_outbound_access_enabled should default to false."
  }
}

run "no_associations_without_ids" {
  command = plan

  assert {
    condition     = length(azurerm_subnet_network_security_group_association.this) == 0 && length(azurerm_subnet_route_table_association.this) == 0
    error_message = "No NSG or route table associations should be created when no ids are supplied."
  }
}

run "associations_created_when_ids_supplied" {
  command = plan

  variables {
    subnets = {
      "snet-app-vnet-ldo-uks-tst-001" = {
        address_prefixes = ["10.0.1.0/24"]
        delegations      = ["Microsoft.Web/serverFarms"]
      }
    }
    nsg_associations = {
      "snet-app-vnet-ldo-uks-tst-001" = "/subscriptions/0000/resourceGroups/rg/providers/Microsoft.Network/networkSecurityGroups/nsg-app"
    }
    route_table_associations = {
      "snet-app-vnet-ldo-uks-tst-001" = "/subscriptions/0000/resourceGroups/rg/providers/Microsoft.Network/routeTables/rt-app"
    }
  }

  assert {
    condition     = length(azurerm_subnet_network_security_group_association.this) == 1 && length(azurerm_subnet_route_table_association.this) == 1
    error_message = "An NSG and a route table association should be created when association maps are supplied."
  }
}

run "rejects_invalid_private_endpoint_network_policies" {
  command = plan

  variables {
    subnets = {
      "snet-bad" = {
        address_prefixes                  = ["10.0.1.0/24"]
        private_endpoint_network_policies = "Sometimes"
      }
    }
  }

  expect_failures = [var.subnets]
}

run "rejects_address_space_and_ip_address_pool_together" {
  command = plan

  variables {
    ip_address_pool = { id = "/subscriptions/0000/resourceGroups/rg/providers/Microsoft.Network/networkManagers/nm/ipamPools/pool", number_of_ip_addresses = "256" }
  }

  expect_failures = [var.address_space]
}

run "rejects_short_vnet_name" {
  command = plan

  variables {
    vnet_name = "v"
  }

  expect_failures = [var.vnet_name]
}

run "rejects_flow_timeout_out_of_range" {
  command = plan

  variables {
    flow_timeout_in_minutes = 60
  }

  expect_failures = [var.flow_timeout_in_minutes]
}
