<#
.NOTES
    Copyright 1990-2024 Celerium

    NAME: Invoke-moduleBuild.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        DATE:    2023-04-1
        EMAIL:   celerium@Celerium.org
        Updated: 2023-09-16

    TODO:

.SYNOPSIS
    Builds & prepares a PowerShell module for deployment

.DESCRIPTION
    The Invoke-moduleBuild.ps1 script builds & prepares a PowerShell
    module for deployment

.PARAMETER ModuleName
    The name of the module to build

    Example: Celerium.Auvik

.PARAMETER Version
    The module version (must be a valid System.Version such as PowerShell supports for modules)

.PARAMETER UnversionedOutputDirectory
    Overrides the VersionedOutputDirectory, producing an OutputDirectory without a version number as the last folder

.EXAMPLE
    .\Invoke-moduleBuild.ps1 -Version 1.2.3

    Compiles the module files located in ..\moduleName and builds
    a combined module in ...\build\moduleName\1.2.3

.INPUTS
    N/A

.OUTPUTS
    N/A

.LINK
    https://celerium.org

#>

<############################################################################################
                                        Code
############################################################################################>
#Requires -Version 5.1
#Requires -Modules ModuleBuilder

#Region  [ Parameters ]

[CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$ModuleName = 'Celerium.Auvik',

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Version,

        [Parameter(Mandatory=$false)]
        [switch]$UnversionedOutputDirectory
    )

#EndRegion  [ Parameters ]

Write-Verbose ''
Write-Verbose "START - $(Get-Date -Format yyyy-MM-dd-HH:mm) - [ $($PSCmdlet.ParameterSetName) ]"
Write-Verbose ''

#Region     [ Prerequisites ]

$StartDate = Get-Date

#EndRegion  [ Prerequisites ]

#Region     [ Build Module ]

try {

    $RootPath = Split-Path -Path $PSScriptRoot -Parent

    $ModulePath         = Join-Path -Path $RootPath -ChildPath $ModuleName
    $SourcePath         = Join-Path -Path $ModulePath -ChildPath "$ModuleName.psd1"
    $OutputDirectory    = Join-Path -Path $RootPath -ChildPath "build"

    $Params = @{
        SourcePath      = $SourcePath
        OutputDirectory = $OutputDirectory
        Version         = $Version
        PublicFilter    = Join-Path -Path 'Private','Public' -ChildPath "*.ps1"
        UnversionedOutputDirectory = $UnversionedOutputDirectory
    }

    Build-Module @Params -Verbose

    #Replace & comment out NestedModules from nonBuilt module
    $ModulePathBuilt = if ($UnversionedOutputDirectory) { Join-Path -Path (Join-Path -Path $OutputDirectory -ChildPath $ModuleName) -ChildPath "$ModuleName.psd1" }
                        else { Join-Path -Path (Join-Path -Path (Join-Path -Path $OutputDirectory -ChildPath $ModuleName) -ChildPath $Version) -ChildPath "$ModuleName.psd1" }
    Update-Metadata -Path $ModulePathBuilt -PropertyName NestedModules -Value  @()
    (Get-Content -Path $ModulePathBuilt -Raw) -replace 'NestedModules = @\(\)', '# NestedModules = @()' | Set-Content -Path $ModulePathBuilt

    # The OpenAPI spec (newest Auvik-<version>.json in the docs folder) is part of the built module
    $SpecFile = Get-ChildItem -Path (Join-Path -Path $RootPath -ChildPath 'docs') -Filter 'Auvik-*.json' -File -ErrorAction SilentlyContinue |
                    Sort-Object -Property @{ Expression = { $Text = $_.BaseName -replace '^Auvik-v?', ''; if ($Text -match '^\d+$') { $Text += '.0' }; $Parsed = $null; if ([System.Version]::TryParse($Text, [ref]$Parsed)) { $Parsed } else { [System.Version]'0.0' } } }, LastWriteTime -Descending |
                        Select-Object -First 1

    if ($SpecFile) {
        Copy-Item -Path $SpecFile.FullName -Destination (Split-Path -Path $ModulePathBuilt -Parent) -Force
        Write-Verbose "Copied the OpenAPI spec [ $($SpecFile.Name) ] to the built module"
    }
    else { Write-Warning 'No OpenAPI spec was found in the docs folder, the built module does not include the spec' }

}
catch {
    Write-Error $_
    exit 1
}

#EndRegion  [ Build Module ]

Write-Verbose ''
Write-Verbose "END - $(Get-Date -Format yyyy-MM-dd-HH:mm)"
Write-Verbose ''

$TimeToComplete = New-TimeSpan -Start $StartDate -End (Get-Date)
Write-Verbose 'Time to complete'
Write-Verbose ($TimeToComplete | Select-Object * -ExcludeProperty Ticks,Total*,Milli* | Out-String)