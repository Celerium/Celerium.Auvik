<#
.NOTES
    Copyright 1990-2025 Celerium

    NAME: Compare-AuvikSpec.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        EMAIL:   celerium@Celerium.org

    TODO:

.SYNOPSIS
    Compares the local Auvik OpenAPI spec to the online version

.DESCRIPTION
    The Compare-AuvikSpec.ps1 script downloads the online Auvik OpenAPI json spec & compares
    it to the local copy in the docs folder (Auvik-v1.json by default)

    The comparison reads the json instead of comparing the raw text so formatting differences
    are ignored. The results show the following:

        - Differences in the API version, title, & server url
        - Endpoints (paths & methods) that were added, removed, or changed
        - Schemas (components) that were added, removed, or changed

    A leading /v1 in the endpoint paths and a trailing /v1 in the server url are ignored so that
    specs that define the version in either location are comparable.

    The script works on Windows PowerShell 5.1, PowerShell 7+, Linux, & macOS

.PARAMETER LocalPath
    Path to the local spec

    By default docs\Auvik-v1.json in the root of the repository is used

.PARAMETER Uri
    The location of the online Auvik OpenAPI spec

    Default value: https://auvikapi.us1.my.auvik.com/spec

.PARAMETER FailOnDifference
    Exits with a non zero exit code when the local spec is different than the online spec

.PARAMETER Detailed
    Includes every changed value in the results

.EXAMPLE
    .\Compare-AuvikSpec.ps1

    Compares the local spec to the online spec & returns a summary of the differences

.EXAMPLE
    .\Compare-AuvikSpec.ps1 -Detailed | Select-Object -ExpandProperty Changes

    Returns every value that is different

.EXAMPLE
    .\Compare-AuvikSpec.ps1 -FailOnDifference

    Fails the calling process (such as a GitHub workflow) when the specs are different

.INPUTS
    N/A

.OUTPUTS
    PSCustomObject

.LINK
    https://celerium.org

#>

<############################################################################################
                                        Code
############################################################################################>
#Requires -Version 5.1

#Region     [ Parameters ]

[CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$LocalPath,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Uri = 'https://auvikapi.us1.my.auvik.com/spec',

        [Parameter(Mandatory = $false)]
        [switch]$FailOnDifference,

        [Parameter(Mandatory = $false)]
        [switch]$Detailed
    )

#EndRegion  [ Parameters ]

Write-Verbose ''
Write-Verbose "START - $(Get-Date -Format yyyy-MM-dd-HH:mm)"
Write-Verbose ''

#Region     [ Helper Functions ]

function ConvertTo-FlatSpec {
    # Flattens a json document to a table of "json pointer" = "value" so that two documents can be compared value by value
    param (
        $Node,
        [string]$Pointer,
        [hashtable]$Table
    )

    if ($Node -is [System.Management.Automation.PSCustomObject]) {

        $Properties = @($Node.PSObject.Properties)
        if ($Properties.Count -eq 0) { $Table[$Pointer] = '{}'; return }

        foreach ($Property in $Properties) {
            ConvertTo-FlatSpec -Node $Property.Value -Pointer "$Pointer/$($Property.Name -replace '~', '~0' -replace '/', '~1')" -Table $Table
        }

    }
    elseif ($Node -is [System.Array]) {

        $Items = @($Node)
        if ($Items.Count -eq 0) { $Table[$Pointer] = '[]'; return }

        $HasObjects = [bool]($Items | Where-Object { $_ -is [System.Management.Automation.PSCustomObject] -or $_ -is [System.Array] })

        if ($HasObjects) {
            for ($Index = 0; $Index -lt $Items.Count; $Index++) {
                ConvertTo-FlatSpec -Node $Items[$Index] -Pointer "$Pointer/$Index" -Table $Table
            }
        }
        else {
            # The order of a list of simple values (enum, required, tags) is not important
            $Sorted = [string[]]@($Items | ForEach-Object { "$_" })
            [System.Array]::Sort($Sorted, [System.StringComparer]::Ordinal)
            $Table[$Pointer] = '[' + ($Sorted -join ', ') + ']'
        }

    }
    elseif ($null -eq $Node) { $Table[$Pointer] = 'null' }
    elseif ($Node -is [bool]) { $Table[$Pointer] = "$Node".ToLowerInvariant() }
    else { $Table[$Pointer] = [string]$Node }
}

function Get-NormalizedPointer {
    # Removes the api version from endpoint paths
    param (
        [string]$Pointer,
        [string]$Version
    )

    if ($Version -and $Pointer -like '/paths/*') {
        return $Pointer -replace "^/paths/~1$([regex]::Escape($Version))~1", '/paths/~1'
    }

    return $Pointer
}

function Get-FlatSpec {
    param ($Spec)

    $Version    = "$($Spec.info.version)"
    $Raw        = @{}
    ConvertTo-FlatSpec -Node $Spec -Pointer '' -Table $Raw

    $Flat = @{}
    foreach ($Key in $Raw.Keys) {

        $Value = $Raw[$Key]
        if ($Key -match '^/servers/\d+/url$' -and $Version) { $Value = $Value -replace "/$([regex]::Escape($Version))/?$", '' }

        $Flat[(Get-NormalizedPointer -Pointer $Key -Version $Version)] = $Value

    }

    return $Flat
}

function Get-SpecEndpoint {
    # "METHOD /path" for every operation in the spec
    param ($Flat)

    $Methods = 'get', 'put', 'post', 'delete', 'options', 'head', 'patch', 'trace'
    $Result  = [System.Collections.Generic.HashSet[string]]::new()

    foreach ($Key in $Flat.Keys) {
        if ($Key -match '^/paths/(?<path>[^/]+)/(?<method>get|put|post|delete|options|head|patch|trace)(/|$)') {
            [void]$Result.Add("$($Matches['method'].ToUpperInvariant()) $($Matches['path'].Replace('~1', '/').Replace('~0', '~'))")
        }
    }

    return $Result
}

#EndRegion  [ Helper Functions ]

#Region     [ Prerequisites ]

$StartDate = Get-Date

if ($PSEdition -eq 'Desktop') {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
}

$RootPath = Split-Path -Path $PSScriptRoot -Parent
if (-not $LocalPath) { $LocalPath = Join-Path -Path (Join-Path -Path $RootPath -ChildPath 'docs') -ChildPath 'Auvik-v1.json' }

#EndRegion  [ Prerequisites ]

#Region     [ Compare Spec ]

try {

    if (-not (Test-Path -Path $LocalPath -PathType Leaf)) { throw "The local spec was not found at [ $LocalPath ]. Run Get-AuvikSpec.ps1 to download it" }

    Write-Verbose " - (1/3) - $(Get-Date -Format MM-dd-HH:mm) - Reading the local spec [ $LocalPath ]"
    $LocalSpec = [System.IO.File]::ReadAllText($LocalPath) | ConvertFrom-Json -ErrorAction Stop

    Write-Verbose " - (2/3) - $(Get-Date -Format MM-dd-HH:mm) - Downloading the online spec [ $Uri ]"
    $Response   = Invoke-WebRequest -Uri $Uri -UseBasicParsing -ErrorAction Stop
    $OnlineSpec = [System.Text.Encoding]::UTF8.GetString($Response.RawContentStream.ToArray()) | ConvertFrom-Json -ErrorAction Stop

    Write-Verbose " - (3/3) - $(Get-Date -Format MM-dd-HH:mm) - Comparing the specs"

    $LocalFlat  = Get-FlatSpec -Spec $LocalSpec
    $OnlineFlat = Get-FlatSpec -Spec $OnlineSpec

    $Changes = [System.Collections.Generic.List[object]]::new()
    $AllKeys = [System.Collections.Generic.HashSet[string]]::new([string[]]@($LocalFlat.Keys + $OnlineFlat.Keys))

    foreach ($Key in $AllKeys) {

        $InLocal    = $LocalFlat.ContainsKey($Key)
        $InOnline   = $OnlineFlat.ContainsKey($Key)

        if ($InLocal -and $InOnline) {
            if ($LocalFlat[$Key] -cne $OnlineFlat[$Key]) { $Changes.Add([PSCustomObject]@{ Pointer = $Key; Change = 'Changed'; Local = $LocalFlat[$Key]; Online = $OnlineFlat[$Key] }) }
        }
        elseif ($InOnline)  { $Changes.Add([PSCustomObject]@{ Pointer = $Key; Change = 'Added';   Local = $null; Online = $OnlineFlat[$Key] }) }
        else                { $Changes.Add([PSCustomObject]@{ Pointer = $Key; Change = 'Removed'; Local = $LocalFlat[$Key]; Online = $null }) }

    }

    $LocalEndpoints     = Get-SpecEndpoint -Flat $LocalFlat
    $OnlineEndpoints    = Get-SpecEndpoint -Flat $OnlineFlat

    $EndpointsAdded     = @($OnlineEndpoints | Where-Object { -not $LocalEndpoints.Contains($_) } | Sort-Object)
    $EndpointsRemoved   = @($LocalEndpoints  | Where-Object { -not $OnlineEndpoints.Contains($_) } | Sort-Object)

    $EndpointsChanged = @(
        $Changes | Where-Object { $_.Pointer -like '/paths/*' } | ForEach-Object {
            if ($_.Pointer -match '^/paths/(?<path>[^/]+)/(?<method>get|put|post|delete|options|head|patch|trace)(/|$)') { "$($Matches['method'].ToUpperInvariant()) $($Matches['path'].Replace('~1', '/').Replace('~0', '~'))" }
        } | Where-Object { $_ -notin $EndpointsAdded -and $_ -notin $EndpointsRemoved } | Sort-Object -Unique
    )

    $SchemaChanges = @($Changes | Where-Object { $_.Pointer -match '^/components/schemas/(?<name>[^/]+)' } | ForEach-Object { [void]($_.Pointer -match '^/components/schemas/(?<name>[^/]+)'); [PSCustomObject]@{ Name = $Matches['name']; Change = $_.Change } })
    $LocalSchemas       = @($LocalFlat.Keys  | ForEach-Object { if ($_ -match '^/components/schemas/(?<name>[^/]+)') { $Matches['name'] } } | Select-Object -Unique)
    $OnlineSchemas      = @($OnlineFlat.Keys | ForEach-Object { if ($_ -match '^/components/schemas/(?<name>[^/]+)') { $Matches['name'] } } | Select-Object -Unique)
    $SchemasAdded       = @($OnlineSchemas | Where-Object { $_ -notin $LocalSchemas } | Sort-Object)
    $SchemasRemoved     = @($LocalSchemas  | Where-Object { $_ -notin $OnlineSchemas } | Sort-Object)
    $SchemasChanged     = @($SchemaChanges | Where-Object { $_.Name -notin $SchemasAdded -and $_.Name -notin $SchemasRemoved } | ForEach-Object { $_.Name } | Sort-Object -Unique)

    $Result = [PSCustomObject]@{
        Differs             = ($Changes.Count -gt 0)
        LocalPath           = $LocalPath
        Uri                 = $Uri
        LocalVersion        = "$($LocalSpec.info.version)"
        OnlineVersion       = "$($OnlineSpec.info.version)"
        LocalEndpointCount  = $LocalEndpoints.Count
        OnlineEndpointCount = $OnlineEndpoints.Count
        EndpointsAdded      = $EndpointsAdded
        EndpointsRemoved    = $EndpointsRemoved
        EndpointsChanged    = $EndpointsChanged
        SchemasAdded        = $SchemasAdded
        SchemasRemoved      = $SchemasRemoved
        SchemasChanged      = $SchemasChanged
        ChangeCount         = $Changes.Count
    }

    if ($Detailed) { $Result | Add-Member -NotePropertyName Changes -NotePropertyValue @($Changes | Sort-Object Pointer) }

    if ($Result.Differs) { Write-Warning "The local spec [ $LocalPath ] is different than the online spec. Run Get-AuvikSpec.ps1 & New-PublicFunctions.ps1 to update the module" }
    else { Write-Verbose 'The local spec matches the online spec' }

    $Result

    if ($Result.Differs -and $FailOnDifference) { exit 1 }

}
catch {
    Write-Error $_
    exit 1
}

#EndRegion  [ Compare Spec ]

Write-Verbose ''
Write-Verbose "END - $(Get-Date -Format yyyy-MM-dd-HH:mm)"
Write-Verbose ''

$TimeToComplete = New-TimeSpan -Start $StartDate -End (Get-Date)
Write-Verbose 'Time to complete'
Write-Verbose ($TimeToComplete | Select-Object * -ExcludeProperty Ticks,Total*,Milli* | Out-String)
