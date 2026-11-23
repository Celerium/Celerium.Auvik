<#
.NOTES
    Copyright 1990-2025 Celerium

    NAME: Get-AuvikSpec.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        EMAIL:   celerium@Celerium.org

    TODO:

.SYNOPSIS
    Downloads the latest Auvik OpenAPI spec

.DESCRIPTION
    The Get-AuvikSpec.ps1 script downloads the latest Auvik OpenAPI json spec from the
    Auvik API and saves it to the docs folder using the following naming convention:

        {Product}-{Version}.json

    Example: Auvik-v1.json

    The product is defined by the Product parameter & the version is read from the info.version
    value of the downloaded spec. The script only accepts the API version defined by
    the ExpectedVersion parameter so that a different Auvik API version (such as v2)
    is never saved over the v1 spec.

    The script works on Windows PowerShell 5.1, PowerShell 7+, Linux, & macOS

.PARAMETER Uri
    The location of the online Auvik OpenAPI spec

    Default value: https://auvikapi.us1.my.auvik.com/spec

.PARAMETER Product
    The product name used in the file name

    Default value: Auvik

.PARAMETER ExpectedVersion
    The API version that is allowed to be saved. The script stops when the
    online spec is any other version

    Default value: v1

.PARAMETER OutputPath
    The folder to save the spec to

    By default the docs folder in the root of the repository is used

.PARAMETER ArchivePath
    Folder where a different existing spec is copied to before it is replaced

    By default the build\Archive folder in the root of the repository is used (ignored by git)

.EXAMPLE
    .\Get-AuvikSpec.ps1

    Downloads the online spec & saves it as docs\Auvik-v1.json

.EXAMPLE
    .\Get-AuvikSpec.ps1 -WhatIf

    Shows what would be saved without writing the file

.INPUTS
    N/A

.OUTPUTS
    System.IO.FileInfo

.LINK
    https://celerium.org

#>

<############################################################################################
                                        Code
############################################################################################>
#Requires -Version 5.1

#Region     [ Parameters ]

[CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Uri = 'https://auvikapi.us1.my.auvik.com/spec',

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Product = 'Auvik',

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$ExpectedVersion = 'v1',

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$OutputPath,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$ArchivePath
    )

#EndRegion  [ Parameters ]

Write-Verbose ''
Write-Verbose "START - $(Get-Date -Format yyyy-MM-dd-HH:mm)"
Write-Verbose ''

#Region     [ Prerequisites ]

$StartDate = Get-Date

if ($PSEdition -eq 'Desktop') {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
}

$RootPath = Split-Path -Path $PSScriptRoot -Parent
if (-not $OutputPath) { $OutputPath = Join-Path -Path $RootPath -ChildPath 'docs' }

#EndRegion  [ Prerequisites ]

#Region     [ Download Spec ]

try {

    Write-Verbose " - (1/2) - $(Get-Date -Format MM-dd-HH:mm) - Downloading [ $Uri ]"

    $Response   = Invoke-WebRequest -Uri $Uri -UseBasicParsing -ErrorAction Stop
    $Content    = [System.Text.Encoding]::UTF8.GetString($Response.RawContentStream.ToArray())
    $Spec       = $Content | ConvertFrom-Json -ErrorAction Stop

    if (-not $Spec.openapi -or -not $Spec.paths) { throw "The content from [ $Uri ] is not an OpenAPI spec" }

    $Version = "$($Spec.info.version)"
    if ($Version -ne $ExpectedVersion) {
        throw "The online spec is version [ $Version ] but only [ $ExpectedVersion ] can be saved"
    }

    $FileName   = "$Product-$Version.json"
    $FilePath   = Join-Path -Path $OutputPath -ChildPath $FileName

    Write-Verbose " - (2/2) - $(Get-Date -Format MM-dd-HH:mm) - Saving [ $FilePath ]"

    if ($PSCmdlet.ShouldProcess($FilePath, 'Save the Auvik OpenAPI spec')) {

        if (-not (Test-Path -Path $OutputPath -PathType Container)) { New-Item -Path $OutputPath -ItemType Directory > $null }

        # UTF8 without a BOM & with unix line endings so that the file is identical on every platform
        $Utf8NoBom  = New-Object System.Text.UTF8Encoding -ArgumentList $false
        $NewContent = $Content -replace "`r`n", "`n"

        # A different existing spec is copied to build\Archive\<date> first so that nothing is lost
        if ((Test-Path -Path $FilePath -PathType Leaf) -and ([System.IO.File]::ReadAllText($FilePath) -cne $NewContent)) {
            if (-not $ArchivePath) { $ArchivePath = Join-Path -Path (Join-Path -Path $RootPath -ChildPath 'build') -ChildPath 'Archive' }
            $ArchiveFolder = Join-Path -Path $ArchivePath -ChildPath (Get-Date -Format 'yyyyMMdd-HHmmss')
            New-Item -Path $ArchiveFolder -ItemType Directory -Force > $null
            Copy-Item -Path $FilePath -Destination (Join-Path -Path $ArchiveFolder -ChildPath $FileName) -Force
            Write-Verbose "The previous spec was copied to [ $ArchiveFolder ]"
        }

        [System.IO.File]::WriteAllText($FilePath, $NewContent, $Utf8NoBom)

        Get-Item -Path $FilePath

    }

}
catch {
    Write-Error $_
    exit 1
}

#EndRegion  [ Download Spec ]

Write-Verbose ''
Write-Verbose "END - $(Get-Date -Format yyyy-MM-dd-HH:mm)"
Write-Verbose ''

$TimeToComplete = New-TimeSpan -Start $StartDate -End (Get-Date)
Write-Verbose 'Time to complete'
Write-Verbose ($TimeToComplete | Select-Object * -ExcludeProperty Ticks,Total*,Milli* | Out-String)
