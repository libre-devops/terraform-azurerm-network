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
