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
| [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | The address space that is used by the virtual network. | `list(string)` | <pre>[<br>  "10.0.0.0/16"<br>]</pre> | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | The DNS servers to be used with vNet. | `list(string)` | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | The location for this resource to be put in | `string` | n/a | yes |
| <a name="input_nsg_ids"></a> [nsg\_ids](#input\_nsg\_ids) | A map of subnet name to Network Security Group IDs | `map(string)` | `{}` | no |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists | `string` | n/a | yes |
| <a name="input_route_tables_ids"></a> [route\_tables\_ids](#input\_route\_tables\_ids) | A map of subnet name to Route table ids | `map(string)` | `{}` | no |
| <a name="input_subnet_delegation"></a> [subnet\_delegation](#input\_subnet\_delegation) | A map of subnet name to delegation block on the subnet | `map(map(any))` | `{}` | no |
| <a name="input_subnet_delegations_actions"></a> [subnet\_delegations\_actions](#input\_subnet\_delegations\_actions) | Unused, but composes a list of delegation actions when delegations of subnets is used | `map(list(string))` | <pre>{<br>  "Microsoft.AzureCosmosDB/clusters": [<br>    "Microsoft.Network/virtualNetworks/subnets/join/action"<br>  ],<br>  "Microsoft.BareMetal/AzureVMware": [<br>    "Microsoft.Network/networkinterfaces/*",<br>    "Microsoft.Network/virtualNetworks/subnets/join/action"<br>  ],<br>  "Microsoft.BareMetal/CrayServers": [<br>    "Microsoft.Network/networkinterfaces/*",<br>    "Microsoft.Network/virtualNetworks/subnets/join/action"<br>  ],<br>  "Microsoft.Batch/batchAccounts": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.ContainerInstance/containerGroups": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.DBforPostgreSQL/serversv2": [<br>    "Microsoft.Network/virtualNetworks/subnets/join/action"<br>  ],<br>  "Microsoft.Databricks/workspaces": [<br>    "Microsoft.Network/virtualNetworks/subnets/join/action",<br>    "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",<br>    "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"<br>  ],<br>  "Microsoft.HardwareSecurityModules/dedicatedHSMs": [<br>    "Microsoft.Network/networkinterfaces/*",<br>    "Microsoft.Network/virtualNetworks/subnets/join/action"<br>  ],<br>  "Microsoft.Logic/integrationServiceEnvironments": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.Netapp/volumes": [<br>    "Microsoft.Network/networkinterfaces/*",<br>    "Microsoft.Network/virtualNetworks/subnets/join/action"<br>  ],<br>  "Microsoft.Network/dnsResolvers": [<br>    "Microsoft.Network/virtualNetworks/subnets/join/action"<br>  ],<br>  "Microsoft.ServiceFabricMesh/networks": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.Sql/managedInstances": [<br>    "Microsoft.Network/virtualNetworks/subnets/join/action",<br>    "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",<br>    "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"<br>  ],<br>  "Microsoft.StreamAnalytics/streamingJobs": [<br>    "Microsoft.Network/virtualNetworks/subnets/join/action"<br>  ],<br>  "Microsoft.Web/hostingEnvironments": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ],<br>  "Microsoft.Web/serverFarms": [<br>    "Microsoft.Network/virtualNetworks/subnets/action"<br>  ]<br>}</pre> | no |
| <a name="input_subnet_enforce_private_link_endpoint_network_policies"></a> [subnet\_enforce\_private\_link\_endpoint\_network\_policies](#input\_subnet\_enforce\_private\_link\_endpoint\_network\_policies) | A map of subnet name to enable/disable private link endpoint network policies on the subnet. | `map(bool)` | `{}` | no |
| <a name="input_subnet_enforce_private_link_service_network_policies"></a> [subnet\_enforce\_private\_link\_service\_network\_policies](#input\_subnet\_enforce\_private\_link\_service\_network\_policies) | A map of subnet name to enable/disable private link service network policies on the subnet. | `map(bool)` | `{}` | no |
| <a name="input_subnet_names"></a> [subnet\_names](#input\_subnet\_names) | A list of public subnets inside the vNet. | `list(string)` | <pre>[<br>  "subnet1",<br>  "subnet2",<br>  "subnet3"<br>]</pre> | no |
| <a name="input_subnet_prefixes"></a> [subnet\_prefixes](#input\_subnet\_prefixes) | The address prefix to use for the subnet. | `list(string)` | <pre>[<br>  "10.0.1.0/24"<br>]</pre> | no |
| <a name="input_subnet_service_endpoints"></a> [subnet\_service\_endpoints](#input\_subnet\_service\_endpoints) | A map of subnet name to service endpoints to add to the subnet. | `map(any)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to associate with your network and subnets. | `map(string)` | <pre>{<br>  "ENV": "test"<br>}</pre> | no |
| <a name="input_vnet_location"></a> [vnet\_location](#input\_vnet\_location) | The location of the vnet to create. Defaults to the location of the resource group. | `string` | `null` | no |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | Name of the vnet to create | `string` | `"acctvnet"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_subnets_ids"></a> [subnets\_ids](#output\_subnets\_ids) | The ids of the subnets created |
| <a name="output_subnets_names"></a> [subnets\_names](#output\_subnets\_names) | The name of the subnets created |
| <a name="output_vnet_address_space"></a> [vnet\_address\_space](#output\_vnet\_address\_space) | The address space of the newly created vNet |
| <a name="output_vnet_dns_servers"></a> [vnet\_dns\_servers](#output\_vnet\_dns\_servers) | The dns servers of the vnet, if it is using Azure default, this module will return the Azure 'wire' IP as a list of string in the 1st element |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | The id of the newly created vNet |
| <a name="output_vnet_location"></a> [vnet\_location](#output\_vnet\_location) | The location of the newly created vNet |
| <a name="output_vnet_name"></a> [vnet\_name](#output\_vnet\_name) | The Name of the newly created vNet |
| <a name="output_vnet_rg_name"></a> [vnet\_rg\_name](#output\_vnet\_rg\_name) | The resource group name which the VNet is in |
| <a name="output_vnet_subnets"></a> [vnet\_subnets](#output\_vnet\_subnets) | The ids of subnets created inside the newly created vNet |
