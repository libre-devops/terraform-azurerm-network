variable "address_space" {
  description = "Address space (CIDR ranges) for the virtual network. Set this OR ip_address_pool, not both."
  type        = list(string)
  default     = []

  validation {
    condition     = (length(var.address_space) > 0) != (var.ip_address_pool != null)
    error_message = "Set exactly one of address_space or ip_address_pool on the virtual network."
  }
}

variable "bgp_community" {
  description = "BGP community for the virtual network, in the format <as-number>:<community-value>. Null for none."
  type        = string
  default     = null
}

variable "ddos_protection_plan_id" {
  description = "Resource id of a DDoS protection plan to associate (enabled when set). Null for none."
  type        = string
  default     = null
}

variable "dns_servers" {
  description = "Custom DNS servers for the virtual network. Empty uses Azure-provided DNS."
  type        = list(string)
  default     = []
}

variable "edge_zone" {
  description = "Edge zone within the Azure region. Null for none."
  type        = string
  default     = null
}

variable "encryption_enforcement" {
  description = "When set, enables virtual network encryption with this enforcement. Allowed: AllowUnencrypted, DropUnencrypted. Null leaves encryption unset (encryption needs supported VM SKUs, so it is opt-in)."
  type        = string
  default     = null

  validation {
    condition     = var.encryption_enforcement == null ? true : contains(["AllowUnencrypted", "DropUnencrypted"], var.encryption_enforcement)
    error_message = "encryption_enforcement must be AllowUnencrypted or DropUnencrypted."
  }
}

variable "flow_timeout_in_minutes" {
  description = "Flow timeout in minutes (4 to 30). Null uses the Azure default."
  type        = number
  default     = null

  validation {
    condition     = var.flow_timeout_in_minutes == null ? true : (var.flow_timeout_in_minutes >= 4 && var.flow_timeout_in_minutes <= 30)
    error_message = "flow_timeout_in_minutes must be between 4 and 30."
  }
}

variable "ip_address_pool" {
  description = "Allocate the virtual network's address space from a Network Manager IPAM pool. Set this OR address_space, not both."
  type = object({
    id                     = string
    number_of_ip_addresses = string
  })
  default = null
}

variable "location" {
  description = "Azure region for the virtual network."
  type        = string
}

variable "private_endpoint_vnet_policies" {
  description = "Private endpoint policy mode for the virtual network. Allowed: Disabled, Basic."
  type        = string
  default     = "Disabled"

  validation {
    condition     = contains(["Disabled", "Basic"], var.private_endpoint_vnet_policies)
    error_message = "private_endpoint_vnet_policies must be Disabled or Basic."
  }
}

variable "resource_group_id" {
  description = "Resource id of the resource group to create the virtual network and subnets in. The name and subscription are parsed from it (pass the rg module's ids output, for example module.rg.ids[\"rg-...\"])."
  type        = string

  validation {
    condition     = try(provider::azurerm::parse_resource_id(var.resource_group_id).resource_type, "") == "resourceGroups"
    error_message = "resource_group_id must be a resource group id of the form /subscriptions/<sub>/resourceGroups/<name>."
  }
}

variable "subnet_delegation_actions" {
  description = "Lookup of subnet delegation service name to its delegated actions. A subnet's delegations reference these by service name; a service not listed here falls back to the platform-inferred actions."
  type        = map(list(string))
  default = {
    "GitHub.Network/networkSettings"         = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.ApiManagement/service"        = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.App/environments"             = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.App/testClients"              = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Apollo/npu"                   = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.AVS/PrivateClouds"            = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.AzureCosmosDB/clusters"       = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.BareMetal/AzureHPC"           = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.BareMetal/AzureHostedService" = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.BareMetal/AzurePaymentHSM"    = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.BareMetal/AzureVMware" = [
      "Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"
    ]
    "Microsoft.BareMetal/CrayServers" = [
      "Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"
    ]
    "Microsoft.BareMetal/MonitoringServers"       = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Batch/batchAccounts"               = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.CloudTest/hostedpools"             = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.CloudTest/images"                  = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.CloudTest/pools"                   = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Codespaces/plans"                  = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.ContainerInstance/containerGroups" = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.ContainerService/managedClusters"  = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.ContainerService/TestClients"      = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Databricks/workspaces" = [
      "Microsoft.Network/virtualNetworks/subnets/join/action",
      "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
      "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
    ]
    "Microsoft.DBforMySQL/flexibleServers"      = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.DBforMySQL/servers"              = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.DBforMySQL/serversv2"            = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.DBforPostgreSQL/flexibleServers" = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.DBforPostgreSQL/serversv2"       = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    "Microsoft.DBforPostgreSQL/singleServers"   = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.DelegatedNetwork/controller"     = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.DevCenter/networkConnection"     = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.DevOpsInfrastructure/pools"      = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    "Microsoft.DocumentDB/cassandraClusters"    = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Fidalgo/networkSettings"         = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.HardwareSecurityModules/dedicatedHSMs" = [
      "Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"
    ]
    "Microsoft.Kusto/clusters"                       = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.LabServices/labplans"                 = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Logic/integrationServiceEnvironments" = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.MachineLearningServices/workspaces"   = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Netapp/volumes" = [
      "Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"
    ]
    "Microsoft.Network/dnsResolvers"                 = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    "Microsoft.Network/fpgaNetworkInterfaces"        = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Network/managedResolvers"             = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Network/networkWatchers"              = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Network/virtualNetworkGateways"       = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Orbital/orbitalGateways"              = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.PowerPlatform/enterprisePolicies"     = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.PowerPlatform/vnetaccesslinks"        = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.ServiceFabricMesh/networks"           = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.ServiceNetworking/trafficControllers" = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Singularity/accounts/networks"        = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Singularity/accounts/npu"             = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Sql/managedInstances" = [
      "Microsoft.Network/virtualNetworks/subnets/join/action",
      "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
      "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
    ]
    "Microsoft.Sql/managedInstancesOnebox"    = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Sql/managedInstancesStage"     = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Sql/managedInstancesTest"      = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Sql/servers"                   = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.StoragePool/diskPools"         = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.StreamAnalytics/streamingJobs" = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    "Microsoft.Synapse/workspaces"            = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Web/hostingEnvironments"       = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Web/serverFarms"               = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "NGINX.NGINXPLUS/nginxDeployments"        = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "PaloAltoNetworks.Cloudngfw/firewalls"    = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Qumulo.Storage/fileSystems"              = ["Microsoft.Network/virtualNetworks/subnets/action"]
  }
}

variable "subnets" {
  description = <<-EOT
    Subnets to create in the virtual network, keyed by subnet name. Each subnet sets its address
    prefixes and optional service endpoints, delegations (service names only; the actions are looked
    up from subnet_delegation_actions), and an optional NSG / route table id to associate.

    Secure defaults: private_endpoint_network_policies defaults to "Enabled" (enforces NSG and route
    table rules on private endpoints), and default_outbound_access_enabled defaults to false (no
    implicit outbound internet; Azure is retiring default outbound, so attach an explicit egress such
    as the nat-gateway module). Both are overridable per subnet.
  EOT
  type = map(object({
    address_prefixes                              = optional(list(string), [])
    ip_address_pool                               = optional(object({ id = string, number_of_ip_addresses = string }), null)
    service_endpoints                             = optional(list(string), [])
    service_endpoint_policy_ids                   = optional(list(string), [])
    delegations                                   = optional(list(string), [])
    private_endpoint_network_policies             = optional(string, "Enabled")
    private_link_service_network_policies_enabled = optional(bool, true)
    default_outbound_access_enabled               = optional(bool, false)
    sharing_scope                                 = optional(string, null)
    nsg_id                                        = optional(string, null)
    route_table_id                                = optional(string, null)
  }))
  default = {}

  validation {
    condition     = alltrue([for name in keys(var.subnets) : length(name) >= 1 && length(name) <= 80])
    error_message = "Each subnet name must be 1 to 80 characters (the Azure subnet name limit)."
  }

  validation {
    condition     = alltrue([for s in values(var.subnets) : (length(s.address_prefixes) > 0) != (s.ip_address_pool != null)])
    error_message = "Each subnet must set exactly one of address_prefixes or ip_address_pool."
  }

  validation {
    condition     = alltrue([for s in values(var.subnets) : contains(["Disabled", "Enabled", "NetworkSecurityGroupEnabled", "RouteTableEnabled"], s.private_endpoint_network_policies)])
    error_message = "subnets[*].private_endpoint_network_policies must be Disabled, Enabled, NetworkSecurityGroupEnabled, or RouteTableEnabled."
  }

  validation {
    condition     = alltrue([for s in values(var.subnets) : s.sharing_scope == null || s.sharing_scope == "Tenant"])
    error_message = "subnets[*].sharing_scope must be null or \"Tenant\"."
  }

  validation {
    condition     = alltrue([for s in values(var.subnets) : s.sharing_scope == null || s.default_outbound_access_enabled == false])
    error_message = "subnets[*].sharing_scope can only be set when default_outbound_access_enabled is false."
  }
}

variable "tags" {
  description = "Tags to apply to the virtual network."
  type        = map(string)
  default     = {}
}

variable "vnet_name" {
  description = "Name of the virtual network."
  type        = string

  validation {
    condition     = length(var.vnet_name) >= 2 && length(var.vnet_name) <= 64
    error_message = "vnet_name must be 2 to 64 characters (the Azure virtual network name limit)."
  }
}
