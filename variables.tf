variable "dns_servers" {
  description = "The DNS servers to be used with vNet."
  type        = list(string)
  default     = []
}

variable "location" {
  description = "The location for this resource to be put in"
  type        = string
}

variable "nsg_ids" {
  description = "A map of subnet name to Network Security Group IDs"
  type        = map(string)
  default     = {}
}

variable "rg_name" {
  description = "The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists"
  type        = string
  validation {
    condition     = length(var.rg_name) > 1 && length(var.rg_name) <= 24
    error_message = "Resource group name is not valid."
  }
}

variable "route_tables" {
  description = "Map of Route Tables to be created, where the key is the name of the Route Table."
  type = map(object({
    routes = map(object({
      address_prefix         = string
      next_hop_type          = string
      next_hop_in_ip_address = optional(string)
    }))
  }))
  default = {}
}

variable "route_tables_ids" {
  description = "A map of subnet name to Route table ids"
  type        = map(string)
  default     = {}
}

variable "subnet_delegations_actions" {
  type = map(list(string))
  default = {
    "GitHub.Network/networkSettings"                  = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.ApiManagement/service"                 = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.App/environments"                      = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.App/testClients"                       = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Apollo/npu"                            = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.AVS/PrivateClouds"                     = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.AzureCosmosDB/clusters"                = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.BareMetal/AzureHPC"                    = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.BareMetal/AzureHostedService"          = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.BareMetal/AzurePaymentHSM"             = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.BareMetal/AzureVMware"                 = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
    "Microsoft.BareMetal/CrayServers"                 = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
    "Microsoft.BareMetal/MonitoringServers"           = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Batch/batchAccounts"                   = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.CloudTest/hostedpools"                 = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.CloudTest/images"                      = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.CloudTest/pools"                       = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Codespaces/plans"                      = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.ContainerInstance/containerGroups"     = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.ContainerService/managedClusters"      = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.ContainerService/TestClients"          = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Databricks/workspaces"                 = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action", "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"]
    "Microsoft.DBforMySQL/flexibleServers"            = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.DBforMySQL/servers"                    = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.DBforMySQL/serversv2"                  = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.DBforPostgreSQL/flexibleServers"       = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.DBforPostgreSQL/serversv2"             = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    "Microsoft.DBforPostgreSQL/singleServers"         = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.DelegatedNetwork/controller"           = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.DevCenter/networkConnection"           = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.DocumentDB/cassandraClusters"          = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Fidalgo/networkSettings"               = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.HardwareSecurityModules/dedicatedHSMs" = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
    "Microsoft.Kusto/clusters"                        = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.LabServices/labplans"                  = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Logic/integrationServiceEnvironments"  = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.MachineLearningServices/workspaces"    = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Netapp/volumes"                        = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
    "Microsoft.Network/dnsResolvers"                  = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    "Microsoft.Network/fpgaNetworkInterfaces"         = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Network/managedResolvers"              = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Network/networkWatchers."              = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Network/virtualNetworkGateways"        = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Orbital/orbitalGateways"               = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.PowerPlatform/enterprisePolicies"      = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.PowerPlatform/vnetaccesslinks"         = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.ServiceFabricMesh/networks"            = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.ServiceNetworking/trafficControllers"  = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Singularity/accounts/networks"         = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Singularity/accounts/npu"              = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Sql/managedInstances"                  = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action", "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"]
    "Microsoft.Sql/managedInstancesOnebox"            = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Sql/managedInstancesStage"             = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Sql/managedInstancesTest"              = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Sql/servers"                           = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.StoragePool/diskPools"                 = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.StreamAnalytics/streamingJobs"         = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    "Microsoft.Synapse/workspaces"                    = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Web/hostingEnvironments"               = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Web/serverFarms"                       = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "NGINX.NGINXPLUS/nginxDeployments"                = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "PaloAltoNetworks.Cloudngfw/firewalls"            = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Qumulo.Storage/fileSystems"                      = ["Microsoft.Network/virtualNetworks/subnets/action"]
  }
  description = "List of delegation actions when delegations of subnets is used, will be done for query"
}

variable "subnet_enforce_private_link_endpoint_network_policies" {
  description = "A map of subnet name to enable/disable private link endpoint network policies on the subnet."
  type        = map(bool)
  default     = {}
}

variable "subnet_enforce_private_link_service_network_policies" {
  description = "A map of subnet name to enable/disable private link service network policies on the subnet."
  type        = map(bool)
  default     = {}
}

variable "subnet_route_table_associations" {
  description = "Map where the key is the subnet name and the value is the name of the route table to associate with."
  type        = map(string)
  default     = {}
}

variable "subnet_service_endpoints" {
  description = "A map of subnet name to service endpoints to add to the subnet."
  type        = map(any)
  default     = {}
}

variable "subnets" {
  description = "Map of subnets with their properties"
  type = map(object({
    address_prefixes                              = set(string)
    private_endpoint_network_policies_enabled     = optional(bool, true)
    private_link_service_network_policies_enabled = optional(bool, false)
    service_endpoint_policy_ids                   = optional(set(string))
    delegation = optional(list(object({
      type   = optional(string)
      action = optional(list(string)) # Optional user-defined action
    })))
    service_endpoints = optional(list(string))
  }))
  default = {}
}

variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(string)
}

variable "vnet_address_space" {
  type        = list(string)
  description = "The address space that is used by the virtual network."

  validation {
    condition     = can([for cidr in var.vnet_address_space : cidrsubnet(cidr, 0, 0)])
    error_message = "Each item in vnet_address_space must be a valid CIDR notation."
  }
}

variable "vnet_location" {
  description = "The location of the vnet to create. Defaults to the location of the resource group."
  type        = string
}

variable "vnet_name" {
  description = "Name of the vnet to create"
  type        = string
}
