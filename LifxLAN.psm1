<#
.SYNOPSIS
A PowerShell Module to interact with Lifx devices
.DESCRIPTION
This PowerShell module wraps the Lifx LAN Protocol into dedicated PowerShell functions to perform remote command line
administration of Lifx devices.
#>

# Load Private Functions
Get-ChildItem -Path "$PSScriptRoot\Private" -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}

# Load Public Functions
Get-ChildItem -Path "$PSScriptRoot\Public" -Recurse -Filter *.ps1 | ForEach-Object {
    . $_.FullName
    Export-ModuleMember -Function ($_.BaseName)
}
