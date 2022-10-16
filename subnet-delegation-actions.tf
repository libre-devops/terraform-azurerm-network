variable "subnet_delegations_actions" {
  type = map(list(string))
  default = {
    "Microsoft.Web/serverFarms"                       = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.ContainerInstance/containerGroups"     = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Netapp/volumes"                        = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
    "Microsoft.HardwareSecurityModules/dedicatedHSMs" = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
    "Microsoft.ServiceFabricMesh/networks"            = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Logic/integrationServiceEnvironments"  = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Batch/batchAccounts"                   = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.Sql/managedInstances"                  = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action", "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"]
    "Microsoft.Web/hostingEnvironments"               = ["Microsoft.Network/virtualNetworks/subnets/action"]
    "Microsoft.BareMetal/CrayServers"                 = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
    "Microsoft.Databricks/workspaces"                 = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action", "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"]
    "Microsoft.BareMetal/AzureVMware"                 = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
    "Microsoft.StreamAnalytics/streamingJobs"         = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    "Microsoft.DBforPostgreSQL/serversv2"             = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    "Microsoft.AzureCosmosDB/clusters"                = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    "Microsoft.Network/dnsResolvers"                  = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
  }
  description = "Unused, but composes a list of delegation actions when delegations of subnets is used"
}