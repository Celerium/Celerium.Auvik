#
# Module manifest for module 'Celerium.Auvik'
#
# Generated by: David Schulte
#
# Generated on: 2025-02-26
#

@{

    # Script module or binary module file associated with this manifest
    RootModule = 'Celerium.Auvik.psm1'

    # Version number of this module.
    # Follows https://semver.org Semantic Versioning 2.0.0
    # Given a version number MAJOR.MINOR.PATCH, increment the:
    # -- MAJOR version when you make incompatible API changes,
    # -- MINOR version when you add functionality in a backwards-compatible manner, and
    # -- PATCH version when you make backwards-compatible bug fixes.

    # Version number of this module.
    ModuleVersion = '1.0.0'

    # Supported PSEditions
    # CompatiblePSEditions = @()

    # ID used to uniquely identify this module
    GUID = 'c4624e25-e787-48eb-a8d5-a4c8e287412f'

    # Author of this module
    Author = 'David Schulte'

    # Company or vendor of this module
    CompanyName = 'Celerium'

    # Copyright information of this module
    Copyright = 'https://github.com/Celerium/Celerium.Auvik/blob/main/LICENSE'

    # Description of the functionality provided by this module
    Description = 'This module provides a PowerShell wrapper for the Auvik API. Auvik APIs are great for pulling data for reporting purposes or for importing into an integration such as BrightGauge, IT Glue, or Passportal.'

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
    # RequiredModules = @( )

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    #ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @('ConvertTo-AuvikQueryString','Get-AuvikMetaData','Invoke-AuvikRequest','Add-AuvikAPIKey','Get-AuvikAPIKey','New-AuvikAESSecret','Remove-AuvikAPIKey','Add-AuvikBaseURI','Get-AuvikBaseURI','Remove-AuvikBaseURI','Export-AuvikModuleSetting','Get-AuvikModuleSetting','Import-AuvikModuleSetting','Initialize-AuvikModuleSetting','Remove-AuvikModuleSetting','Clear-AuvikAlert','Get-AuvikAlert','Get-AuvikBilling','Get-AuvikTenant','Get-AuvikComponent','Get-AuvikConfiguration','Get-AuvikDevice','Get-AuvikDeviceLifecycle','Get-AuvikDeviceWarranty','Get-AuvikEntity','Get-AuvikInterface','Get-AuvikNetwork','Test-AuvikAPICredential','Get-AuvikSNMPPollerDevice','Get-AuvikSNMPPollerHistory','Get-AuvikSNMPPollerSetting','Get-AuvikASMApplication','Get-AuvikASMClient','Get-AuvikASMSecurityLog','Get-AuvikASMTag','Get-AuvikASMUser','Get-AuvikComponentStatistics','Get-AuvikDeviceAvailabilityStatistics','Get-AuvikDeviceStatistics','Get-AuvikInterfaceStatistics','Get-AuvikOIDStatistics','Get-AuvikServiceStatistics')

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = '*'

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @('Set-AuvikAPIKey','Set-AuvikBaseURI')

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('Auvik', 'API', 'SaaS', 'Network Management', 'PowerShell', 'PSEdition_Desktop', 'PSEdition_Core', 'Windows', 'Celerium')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/Celerium/Celerium.Auvik/blob/main/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/Celerium/Celerium.Auvik'

            # A URL to an icon representing this module.
            IconUri = 'https://raw.githubusercontent.com/Celerium/Celerium.Auvik/main/.github/images/Celerium_PoSHGallery_Celerium.Auvik.png'

            # ReleaseNotes of this module
            ReleaseNotes = 'https://github.com/Celerium/Celerium.Auvik/blob/main/README.md'

            # Identifies the module as a prerelease version in online galleries.
            #PreRelease = '-BETA'

            # Indicate whether the module requires explicit user acceptance for install, update, or save.
            RequireLicenseAcceptance = $false

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = 'https://github.com/Celerium/Celerium.Auvik'

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}

