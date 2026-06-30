# check blocks run after every plan and apply and emit a warning (without blocking) when an
# invariant is violated. They are the place to enforce module-wide consistency.

# Catches the classic map for_each pitfall: a subnet entry silently dropped means fewer subnets are
# created than were requested.
check "all_subnets_created" {
  assert {
    condition     = length(azurerm_subnet.this) == length(var.subnets)
    error_message = "Fewer subnets were created than requested; check for duplicate subnet names in var.subnets."
  }
}

# Association map keys must name subnets that exist, otherwise the association silently references a
# missing subnet. (A missing key also errors at plan, but this gives a clearer message.)
check "associations_reference_known_subnets" {
  assert {
    condition = alltrue(concat(
      [for name in keys(var.nsg_associations) : contains(keys(var.subnets), name)],
      [for name in keys(var.route_table_associations) : contains(keys(var.subnets), name)],
    ))
    error_message = "nsg_associations / route_table_associations keys must be subnet names defined in var.subnets."
  }
}

# Every delegated subnet should resolve known actions from subnet_delegation_actions. A delegation
# whose service name is not in the lookup falls back to platform-inferred actions, which usually
# means the service name is a typo, so surface it as a warning.
check "subnet_delegations_are_known" {
  assert {
    condition = alltrue([
      for subnet in values(var.subnets) : alltrue([
        for delegation in subnet.delegations : contains(keys(var.subnet_delegation_actions), delegation)
      ])
    ])
    error_message = "A subnet delegation service name is not in subnet_delegation_actions; confirm the service name is correct (it will otherwise use platform-inferred actions)."
  }
}
