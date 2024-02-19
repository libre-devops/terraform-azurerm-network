data "external" "detect_os" {
  working_dir = path.module
  program     = ["printf", "{\"os\": \"Linux\"}"]
}

locals {
  dynamic_tags = {
    "LastUpdated" = data.external.generate_timestamp.result["timestamp"]
    "Environment" = var.env
  }

  os   = data.external.detect_os.result.os
  tags = merge(var.static_tags, local.dynamic_tags)
}

data "external" "generate_timestamp" {
  program = local.os == "Linux" ? ["${path.module}/timestamp.sh"] : ["powershell", "${path.module}/timestamp.ps1"]
}

variable "static_tags" {
  type        = map(string)
  description = "The tags variable"
  default = {
    "CostCentre" = "671888"
    "ManagedBy"  = "Terraform"
    "Contact"    = "info@cyber.scot"
  }
}
