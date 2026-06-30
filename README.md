<!--
  This is the template for every Libre DevOps Terraform module. When you create a module from it:
    - replace the title, tagline, and the CI workflow / repo name in the badge URLs
    - replace the resources in main.tf, and the variables, outputs, and examples to match
    - run `just docs` (or Sort-LdoTerraform.ps1) to regenerate the section between the markers
-->
<!--
  Keep the title and badges OUTSIDE the centered <div>: the Terraform Registry's markdown renderer
  does not parse markdown inside an HTML block, so a # heading or [![badge]] in the div renders as
  literal text on the registry. Only the logo (HTML) goes in the div.
-->
<div align="center">
  <a href="https://libredevops.org">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://libredevops.org/assets/libre-devops-white.png">
      <img alt="Libre DevOps" src="https://libredevops.org/assets/libre-devops-black.png" width="300">
    </picture>
  </a>
</div>

# Terraform Azure Network

Creates an Azure virtual network and its subnets, with each subnet's optional NSG and route table
associations. Route tables and NSGs are separate modules; this one associates them by id.

[![CI](https://github.com/libre-devops/terraform-azurerm-network/actions/workflows/ci.yml/badge.svg)](https://github.com/libre-devops/terraform-azurerm-network/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/libre-devops/terraform-azurerm-network?sort=semver&label=release)](https://github.com/libre-devops/terraform-azurerm-network/releases/latest)
[![Terraform Registry](https://img.shields.io/badge/registry-libre--devops-7B42BC?logo=terraform&logoColor=white)](https://registry.terraform.io/namespaces/libre-devops)
[![License](https://img.shields.io/github/license/libre-devops/terraform-azurerm-network)](./LICENSE)

---

## Overview

A single virtual network plus its subnets (keyed map, stable `for_each`). Each subnet sets its
prefixes, service endpoints, delegations (name the service; the actions are looked up from
`subnet_delegation_actions`), and an optional NSG / route table id that the module associates. NSGs
and route tables are owned by the separate `nsg` and `route-table` modules, so this composes by id
without depending on them. Need subnets on an existing vnet from another stack? Use the standalone
`subnet` module, which shares this subnet schema.

**Secure defaults:** subnets default to `private_endpoint_network_policies = "Enabled"` (enforces NSG
and route rules on private endpoints) and `default_outbound_access_enabled = false` (no implicit
outbound; Azure is retiring default outbound, so attach an explicit egress such as the `nat-gateway`
module). Both are overridable per subnet.

## Usage

```hcl
module "network" {
  source  = "libre-devops/network/azurerm"
  version = "~> 4.0"

  vnet_name           = "vnet-ldo-uks-prd-001"
  resource_group_name = module.rg.names["rg-ldo-uks-prd-001"]
  location            = "uksouth"
  address_space       = ["10.0.0.0/16"]

  subnets = {
    "snet-app-vnet-ldo-uks-prd-001" = {
      address_prefixes  = ["10.0.1.0/24"]
      service_endpoints = ["Microsoft.Storage"]
      delegations       = ["Microsoft.Web/serverFarms"]
    }
  }

  # Associations are keyed by subnet name; the ids may be computed in the same apply.
  nsg_associations = {
    "snet-app-vnet-ldo-uks-prd-001" = module.nsg.id
  }
}
```

## Examples

- [`examples/minimal`](./examples/minimal) - a virtual network with one subnet.
- [`examples/complete`](./examples/complete) - multiple subnets with service endpoints, a delegation,
  and NSG / route table associations.

Both examples call the tags and rg modules first, then this module.

## Developing

Local work needs **PowerShell 7+** and **[`just`](https://github.com/casey/just)**, because the recipes
wrap the [LibreDevOpsHelpers](https://www.powershellgallery.com/packages/LibreDevOpsHelpers)
PowerShell module (the same engine the `libre-devops/terraform-azure` action runs in CI). Install
just with `brew install just`, or `uv tool add rust-just` then `uv run just <recipe>`.

Run `just` to list recipes: `just update-ldo-pwsh` (install or force-update LibreDevOpsHelpers from
PSGallery), `just validate`, `just scan` (Trivy only), `just pwsh-analyze` (PSScriptAnalyzer only),
`just plan`, `just apply`, `just destroy`, `just e2e`, `just test`, and `just docs` (the
plan/apply/destroy recipes mirror the action, including the storage firewall dance; `just e2e`
applies an example then always destroys it, defaulting to `minimal`, so nothing is left running).
Releasing is also `just`:
`just increment-release [patch|minor|major]` bumps, tags, and publishes a GitHub release, and the
Terraform Registry picks up the tag.

## Security scan exceptions

This module is scanned with [Trivy](https://github.com/aquasecurity/trivy); HIGH and CRITICAL
findings fail the build. Any waiver is a deliberate, reviewed decision, never a way to quiet a
finding that should be fixed. Waivers live in [`.trivyignore.yaml`](./.trivyignore.yaml) (the
machine-applied source of truth, passed to Trivy with `--ignorefile`) and are mirrored in the table
below so the reason is auditable.

| Trivy ID | Resource | Finding | Justification |
|----------|----------|---------|---------------|
| _None_   |          |         |               |

To add an exception: add an entry to `.trivyignore.yaml` (`id`, optional `paths` to scope it, and a
`statement` recording why), then add a matching row here. Where the finding is out of this module's
scope, point the justification at the Libre DevOps module that does address it (for example the
private-endpoint module). Both the file and this table are reviewed in the pull request.

## Reference

The Requirements, Providers, Inputs, Outputs, and Resources below are generated by `terraform-docs`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0, < 5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_route_table_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | Address space (CIDR ranges) for the virtual network. Set this OR ip\_address\_pool, not both. | `list(string)` | `[]` | no |
| <a name="input_bgp_community"></a> [bgp\_community](#input\_bgp\_community) | BGP community for the virtual network, in the format <as-number>:<community-value>. Null for none. | `string` | `null` | no |
| <a name="input_ddos_protection_plan_id"></a> [ddos\_protection\_plan\_id](#input\_ddos\_protection\_plan\_id) | Resource id of a DDoS protection plan to associate (enabled when set). Null for none. | `string` | `null` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | Custom DNS servers for the virtual network. Empty uses Azure-provided DNS. | `list(string)` | `[]` | no |
| <a name="input_edge_zone"></a> [edge\_zone](#input\_edge\_zone) | Edge zone within the Azure region. Null for none. | `string` | `null` | no |
| <a name="input_encryption_enforcement"></a> [encryption\_enforcement](#input\_encryption\_enforcement) | When set, enables virtual network encryption with this enforcement. Allowed: AllowUnencrypted, DropUnencrypted. Null leaves encryption unset (encryption needs supported VM SKUs, so it is opt-in). | `string` | `null` | no |
| <a name="input_flow_timeout_in_minutes"></a> [flow\_timeout\_in\_minutes](#input\_flow\_timeout\_in\_minutes) | Flow timeout in minutes (4 to 30). Null uses the Azure default. | `number` | `null` | no |
| <a name="input_ip_address_pool"></a> [ip\_address\_pool](#input\_ip\_address\_pool) | Allocate the virtual network's address space from a Network Manager IPAM pool. Set this OR address\_space, not both. | <pre>object({<br/>    id                     = string<br/>    number_of_ip_addresses = string<br/>  })</pre> | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the virtual network. | `string` | n/a | yes |
| <a name="input_nsg_associations"></a> [nsg\_associations](#input\_nsg\_associations) | Map of subnet name to network security group id to associate. Keys are subnet names (must exist in subnets); values may be computed in the same apply (the static keys keep for\_each valid). | `map(string)` | `{}` | no |
| <a name="input_private_endpoint_vnet_policies"></a> [private\_endpoint\_vnet\_policies](#input\_private\_endpoint\_vnet\_policies) | Private endpoint policy mode for the virtual network. Allowed: Disabled, Basic. | `string` | `"Disabled"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | Resource id of the resource group to create the virtual network and subnets in. The name and subscription are parsed from it (pass the rg module's ids output, for example module.rg.ids["rg-..."]). | `string` | n/a | yes |
| <a name="input_route_table_associations"></a> [route\_table\_associations](#input\_route\_table\_associations) | Map of subnet name to route table id to associate. Keys are subnet names (must exist in subnets); values may be computed in the same apply. | `map(string)` | `{}` | no |
| <a name="input_subnet_delegation_actions"></a> [subnet\_delegation\_actions](#input\_subnet\_delegation\_actions) | Lookup of subnet delegation service name to its delegated actions. A subnet's delegations reference these by service name; a service not listed here falls back to the platform-inferred actions. | `map(list(string))` | <pre>{<br/>  "GitHub.Network/networkSettings": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.AVS/PrivateClouds": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.ApiManagement/service": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.Apollo/npu": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.App/environments": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.App/testClients": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.AzureCosmosDB/clusters": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.BareMetal/AzureHPC": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.BareMetal/AzureHostedService": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.BareMetal/AzurePaymentHSM": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.BareMetal/AzureVMware": [<br/>    "Microsoft.Network/networkinterfaces/*",<br/>    "Microsoft.Network/virtualNetworks/subnets/join/action"<br/>  ],<br/>  "Microsoft.BareMetal/CrayServers": [<br/>    "Microsoft.Network/networkinterfaces/*",<br/>    "Microsoft.Network/virtualNetworks/subnets/join/action"<br/>  ],<br/>  "Microsoft.BareMetal/MonitoringServers": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.Batch/batchAccounts": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.CloudTest/hostedpools": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.CloudTest/images": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.CloudTest/pools": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.Codespaces/plans": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.ContainerInstance/containerGroups": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.ContainerService/TestClients": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.ContainerService/managedClusters": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.DBforMySQL/flexibleServers": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.DBforMySQL/servers": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.DBforMySQL/serversv2": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.DBforPostgreSQL/flexibleServers": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.DBforPostgreSQL/serversv2": [<br/>    "Microsoft.Network/virtualNetworks/subnets/join/action"<br/>  ],<br/>  "Microsoft.DBforPostgreSQL/singleServers": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.Databricks/workspaces": [<br/>    "Microsoft.Network/virtualNetworks/subnets/join/action",<br/>    "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",<br/>    "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"<br/>  ],<br/>  "Microsoft.DelegatedNetwork/controller": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.DevCenter/networkConnection": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.DevOpsInfrastructure/pools": [<br/>    "Microsoft.Network/virtualNetworks/subnets/join/action"<br/>  ],<br/>  "Microsoft.DocumentDB/cassandraClusters": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.Fidalgo/networkSettings": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.HardwareSecurityModules/dedicatedHSMs": [<br/>    "Microsoft.Network/networkinterfaces/*",<br/>    "Microsoft.Network/virtualNetworks/subnets/join/action"<br/>  ],<br/>  "Microsoft.Kusto/clusters": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.LabServices/labplans": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.Logic/integrationServiceEnvironments": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.MachineLearningServices/workspaces": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.Netapp/volumes": [<br/>    "Microsoft.Network/networkinterfaces/*",<br/>    "Microsoft.Network/virtualNetworks/subnets/join/action"<br/>  ],<br/>  "Microsoft.Network/dnsResolvers": [<br/>    "Microsoft.Network/virtualNetworks/subnets/join/action"<br/>  ],<br/>  "Microsoft.Network/fpgaNetworkInterfaces": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.Network/managedResolvers": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.Network/networkWatchers": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.Network/virtualNetworkGateways": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.Orbital/orbitalGateways": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.PowerPlatform/enterprisePolicies": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.PowerPlatform/vnetaccesslinks": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.ServiceFabricMesh/networks": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.ServiceNetworking/trafficControllers": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.Singularity/accounts/networks": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.Singularity/accounts/npu": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.Sql/managedInstances": [<br/>    "Microsoft.Network/virtualNetworks/subnets/join/action",<br/>    "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",<br/>    "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"<br/>  ],<br/>  "Microsoft.Sql/managedInstancesOnebox": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.Sql/managedInstancesStage": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.Sql/managedInstancesTest": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.Sql/servers": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.StoragePool/diskPools": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.StreamAnalytics/streamingJobs": [<br/>    "Microsoft.Network/virtualNetworks/subnets/join/action"<br/>  ],<br/>  "Microsoft.Synapse/workspaces": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.Web/hostingEnvironments": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Microsoft.Web/serverFarms": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "NGINX.NGINXPLUS/nginxDeployments": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "PaloAltoNetworks.Cloudngfw/firewalls": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ],<br/>  "Qumulo.Storage/fileSystems": [<br/>    "Microsoft.Network/virtualNetworks/subnets/action"<br/>  ]<br/>}</pre> | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Subnets to create in the virtual network, keyed by subnet name. Each subnet sets its address<br/>prefixes (or ip\_address\_pool) and optional service endpoints, delegations (service names only;<br/>the actions are looked up from subnet\_delegation\_actions), and policy flags. NSG and route table<br/>associations are separate inputs (nsg\_associations / route\_table\_associations) so their ids may be<br/>computed in the same apply.<br/><br/>Secure defaults: private\_endpoint\_network\_policies defaults to "Enabled" (enforces NSG and route<br/>table rules on private endpoints), and default\_outbound\_access\_enabled defaults to false (no<br/>implicit outbound internet; Azure is retiring default outbound, so attach an explicit egress such<br/>as the nat-gateway module). Both are overridable per subnet. | <pre>map(object({<br/>    address_prefixes                              = optional(list(string), [])<br/>    ip_address_pool                               = optional(object({ id = string, number_of_ip_addresses = string }), null)<br/>    service_endpoints                             = optional(list(string), [])<br/>    service_endpoint_policy_ids                   = optional(list(string), [])<br/>    delegations                                   = optional(list(string), [])<br/>    private_endpoint_network_policies             = optional(string, "Enabled")<br/>    private_link_service_network_policies_enabled = optional(bool, true)<br/>    default_outbound_access_enabled               = optional(bool, false)<br/>    sharing_scope                                 = optional(string, null)<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the virtual network. | `map(string)` | `{}` | no |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | Name of the virtual network. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Resource group name parsed from resource\_group\_id. |
| <a name="output_subnet_address_prefixes"></a> [subnet\_address\_prefixes](#output\_subnet\_address\_prefixes) | Map of subnet name to its address prefixes. |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | Map of subnet name to its id. |
| <a name="output_subnet_names"></a> [subnet\_names](#output\_subnet\_names) | The subnet names. |
| <a name="output_subnet_nsg_association_ids"></a> [subnet\_nsg\_association\_ids](#output\_subnet\_nsg\_association\_ids) | Map of subnet name to its network security group association id. |
| <a name="output_subnet_route_table_association_ids"></a> [subnet\_route\_table\_association\_ids](#output\_subnet\_route\_table\_association\_ids) | Map of subnet name to its route table association id. |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | The full azurerm\_subnet resources, keyed by subnet name. |
| <a name="output_subscription_id"></a> [subscription\_id](#output\_subscription\_id) | Subscription id parsed from resource\_group\_id. |
| <a name="output_vnet_address_space"></a> [vnet\_address\_space](#output\_vnet\_address\_space) | The address space of the virtual network. |
| <a name="output_vnet_dns_servers"></a> [vnet\_dns\_servers](#output\_vnet\_dns\_servers) | The DNS servers set on the virtual network. |
| <a name="output_vnet_guid"></a> [vnet\_guid](#output\_vnet\_guid) | The GUID of the virtual network. |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | The id of the virtual network. |
| <a name="output_vnet_location"></a> [vnet\_location](#output\_vnet\_location) | The region of the virtual network. |
| <a name="output_vnet_name"></a> [vnet\_name](#output\_vnet\_name) | The name of the virtual network. |
| <a name="output_vnet_resource_group_name"></a> [vnet\_resource\_group\_name](#output\_vnet\_resource\_group\_name) | The resource group of the virtual network. |
| <a name="output_vnet_tags"></a> [vnet\_tags](#output\_vnet\_tags) | The tags on the virtual network. |
<!-- END_TF_DOCS -->
