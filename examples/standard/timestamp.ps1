#!/usr/bin/env pwsh

# Generate the current timestamp in the required format
$date = Get-Date -Format "dd-MM-yyyy:HH:mm"

# Convert it to a JSON output for Terraform's external data source
$jsonOutput = @{
    id        = $date
    timestamp = $date
} | ConvertTo-Json

# Print the JSON output
Write-Output $jsonOutput
