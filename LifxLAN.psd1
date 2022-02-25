#
# Module manifest for module 'manifest'
#
# Generated by: AdhocAdam
#
# Generated on: 2/25/2022
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'LifxLAN.psm1'

# Version number of this module.
ModuleVersion = '0.0.1'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = 'ddeb61e3-4cbd-4022-b791-71a68defc9b8'

# Author of this module
Author = 'AdhocAdam'

# Company or vendor of this module
CompanyName = 'AdhocAdam'

# Copyright statement for this module
Copyright = '(c) AdhocAdam. All rights reserved.'

# Description of the functionality provided by this module
Description = 'This PowerShell module wraps the Lifx LAN Protocol into dedicated PowerShell functions to perform remote command line administration of Lifx devices'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.1'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @(
        '.\Device\Get-LifxDevice.ps1',
        '.\Device\Initialize-LifxDevice.ps1',
        '.\Device\Set-LifxDevicePower.ps1',
        '.\Device\Set-LifxDeviceColor.ps1',
        '.\Packet\Convert-LifxPacketToBuffer.ps1',
        '.\Packet\New-LifxPacket.ps1'
        )

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
#FunctionsToExport = @()

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
#CmdletsToExport = @()

# Variables to export from this module
# VariablesToExport = @()

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
#AliasesToExport = @()

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}
