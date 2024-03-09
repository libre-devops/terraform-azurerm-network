```hcl
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
  private_endpoint_network_policies_enabled     = each.value.private_endpoint_network_policies_enabled
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
  disable_bgp_route_propagation = false

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
```
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_route_table.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |
| [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_route_table_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | The DNS servers to be used with vNet. | `list(string)` | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | The location for this resource to be put in | `string` | n/a | yes |
| <a name="input_nsg_ids"></a> [nsg\_ids](#input\_nsg\_ids) | A map of subnet name to Network Security Group IDs | `map(string)` | `{}` | no |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists | `string` | n/a | yes |
| <a name="input_route_tables"></a> [route\_tables](#input\_route\_tables) | Map of Route Tables to be created, where the key is the name of the Route Table. | <pre>map(object({<br>    routes = map(object({<br>      address_prefix         = string<br>      next_hop_type          = string<br>      next_hop_in_ip_address = optional(string)<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_route_tables_ids"></a> [route\_tables\_ids](#input\_route\_tables\_ids) | A map of subnet name to Route table ids | `map(string)` | `{}` | no |
| <a name="input_subnet_delegations_actions"></a> [subnet\_delegations\_actions](#input\_subnet\_delegations\_actions) | List of delegation actions when delegations of subnets is used, will be done for query | `map(list(string))` | <pre>{<br>  "GitHub.Network/networkSettings": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.AVS/PrivateClouds": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.ApiManagement/service": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.Apollo/npu": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.App/environments": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.App/testClients": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.AzureCosmosDB/clusters": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.BareMetal/AzureHPC": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.BareMetal/AzureHostedService": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.BareMetal/AzurePaymentHSM": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.BareMetal/AzureVMware": [<br>    "Microsoft.Network/networkinterfaces/*",<br>    "Microsoft.Network/virtualNetworks/subnets/join/action"<br>  ],<br>  "Microsoft.BareMetal/CrayServers": [<br>    "Microsoft.Network/networkinterfaces/*",<br>    "Microsoft.Network/virtualNetworks/subnets/join/action"<br>  ],<br>  "Microsoft.BareMetal/MonitoringServers": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.Batch/batchAccounts": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.CloudTest/hostedpools": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.CloudTest/images": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.CloudTest/pools": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.Codespaces/plans": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.ContainerInstance/containerGroups": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.ContainerService/TestClients": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.ContainerService/managedClusters": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.DBforMySQL/flexibleServers": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.DBforMySQL/servers": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.DBforMySQL/serversv2": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.DBforPostgreSQL/flexibleServers": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.DBforPostgreSQL/serversv2": [<br>    "Microsoft.Network/virtualNetworks/subnets/join/action"<br>  ],<br>  "Microsoft.DBforPostgreSQL/singleServers": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.Databricks/workspaces": [<br>    "Microsoft.Network/virtualNetworks/subnets/join/action",<br>    "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",<br>    "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"<br>  ],<br>  "Microsoft.DelegatedNetwork/controller": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.DevCenter/networkConnection": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.DocumentDB/cassandraClusters": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.Fidalgo/networkSettings": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.HardwareSecurityModules/dedicatedHSMs": [<br>    "Microsoft.Network/networkinterfaces/*",<br>    "Microsoft.Network/virtualNetworks/subnets/join/action"<br>  ],<br>  "Microsoft.Kusto/clusters": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.LabServices/labplans": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.Logic/integrationServiceEnvironments": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.MachineLearningServices/workspaces": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.Netapp/volumes": [<br>    "Microsoft.Network/networkinterfaces/*",<br>    "Microsoft.Network/virtualNetworks/subnets/join/action"<br>  ],<br>  "Microsoft.Network/dnsResolvers": [<br>    "Microsoft.Network/virtualNetworks/subnets/join/action"<br>  ],<br>  "Microsoft.Network/fpgaNetworkInterfaces": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.Network/managedResolvers": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.Network/networkWatchers.": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.Network/virtualNetworkGateways": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.Orbital/orbitalGateways": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.PowerPlatform/enterprisePolicies": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.PowerPlatform/vnetaccesslinks": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.ServiceFabricMesh/networks": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.ServiceNetworking/trafficControllers": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.Singularity/accounts/networks": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.Singularity/accounts/npu": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.Sql/managedInstances": [<br>    "Microsoft.Network/virtualNetworks/subnets/join/action",<br>    "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",<br>    "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"<br>  ],<br>  "Microsoft.Sql/managedInstancesOnebox": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.Sql/managedInstancesStage": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.Sql/managedInstancesTest": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.Sql/servers": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.StoragePool/diskPools": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.StreamAnalytics/streamingJobs": [<br>    "Microsoft.Network/virtualNetworks/subnets/join/action"<br>  ],<br>  "Microsoft.Synapse/workspaces": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.Web/hostingEnvironments": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.Web/serverFarms": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "NGINX.NGINXPLUS/nginxDeployments": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "PaloAltoNetworks.Cloudngfw/firewalls": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Qumulo.Storage/fileSystems": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ]<br>}</pre> | no |
| <a name="input_subnet_enforce_private_link_endpoint_network_policies"></a> [subnet\_enforce\_private\_link\_endpoint\_network\_policies](#input\_subnet\_enforce\_private\_link\_endpoint\_network\_policies) | A map of subnet name to enable/disable private link endpoint network policies on the subnet. | `map(bool)` | `{}` | no |
| <a name="input_subnet_enforce_private_link_service_network_policies"></a> [subnet\_enforce\_private\_link\_service\_network\_policies](#input\_subnet\_enforce\_private\_link\_service\_network\_policies) | A map of subnet name to enable/disable private link service network policies on the subnet. | `map(bool)` | `{}` | no |
| <a name="input_subnet_route_table_associations"></a> [subnet\_route\_table\_associations](#input\_subnet\_route\_table\_associations) | Map where the key is the subnet name and the value is the name of the route table to associate with. | `map(string)` | `{}` | no |
| <a name="input_subnet_service_endpoints"></a> [subnet\_service\_endpoints](#input\_subnet\_service\_endpoints) | A map of subnet name to service endpoints to add to the subnet. | `map(any)` | `{}` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Map of subnets with their properties | <pre>map(object({<br>    address_prefixes                              = set(string)<br>    private_endpoint_network_policies_enabled     = optional(bool, true)<br>    private_link_service_network_policies_enabled = optional(bool, false)<br>    service_endpoint_policy_ids                   = optional(set(string))<br>    delegation = optional(list(object({<br>      type   = optional(string)<br>      action = optional(list(string)) # Optional user-defined action<br>    })))<br>    service_endpoints = optional(list(string))<br>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to associate with your network and subnets. | `map(string)` | n/a | yes |
| <a name="input_vnet_address_space"></a> [vnet\_address\_space](#input\_vnet\_address\_space) | The address space that is used by the virtual network. | `list(string)` | n/a | yes |
| <a name="input_vnet_location"></a> [vnet\_location](#input\_vnet\_location) | The location of the vnet to create. Defaults to the location of the resource group. | `string` | n/a | yes |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | Name of the vnet to create | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_route_table_ids"></a> [route\_table\_ids](#output\_route\_table\_ids) | Map of Route Table names to their IDs. |
| <a name="output_subnet_ids_associated_with_route_tables"></a> [subnet\_ids\_associated\_with\_route\_tables](#output\_subnet\_ids\_associated\_with\_route\_tables) | The IDs of the subnets associated with each route table |
| <a name="output_subnets_ids"></a> [subnets\_ids](#output\_subnets\_ids) | The ids of the subnets created |
| <a name="output_subnets_names"></a> [subnets\_names](#output\_subnets\_names) | The name of the subnets created |
| <a name="output_vnet_address_space"></a> [vnet\_address\_space](#output\_vnet\_address\_space) | The address space of the newly created vNet |
| <a name="output_vnet_dns_servers"></a> [vnet\_dns\_servers](#output\_vnet\_dns\_servers) | The dns servers of the vnet, if it is using Azure default, this module will return the Azure 'wire' IP as a list of string in the 1st element |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | The id of the newly created vNet |
| <a name="output_vnet_location"></a> [vnet\_location](#output\_vnet\_location) | The location of the newly created vNet |
| <a name="output_vnet_name"></a> [vnet\_name](#output\_vnet\_name) | The Name of the newly created vNet |
| <a name="output_vnet_rg_name"></a> [vnet\_rg\_name](#output\_vnet\_rg\_name) | The resource group name which the VNet is in |
