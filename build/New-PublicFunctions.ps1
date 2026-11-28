<#
.NOTES
    Copyright 1990-2025 Celerium

    NAME: New-PublicFunctions.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        DATE:    2025-11-01
        EMAIL:   celerium@Celerium.org

    TODO:

.SYNOPSIS
    Generates the public functions from the Auvik OpenAPI spec

.DESCRIPTION
    The New-PublicFunctions.ps1 script reads the Auvik v1 OpenAPI (3.0) json file and generates
    a public function for every endpoint in the spec

    - GET endpoints are generated as Get-Auvik* functions
    - POST endpoints are generated as Send-Auvik* functions
    - PUT & PATCH endpoints are generated as Set-Auvik* functions
    - DELETE endpoints are generated as Remove-Auvik* functions
    - An endpoint & its single item endpoint (/inventory/device/info & /inventory/device/info/{id}) with the same
      method are combined into one function that uses the parameter sets 'List' & 'ById'
    - The names of functions from earlier versions of the module are kept as aliases

    Every function that is not a read only GET function is a "write" function. Write functions support
    -WhatIf & -Confirm (ConfirmImpact High) and are never retried

    The script also keeps the following files in sync with the generated functions:
        - Celerium.Auvik.psd1 (NestedModules, FunctionsToExport, & AliasesToExport)
        - docs\endpoints.csv (every endpoint in the spec, regardless of method)

    The spec can be downloaded with the Get-AuvikSpec.ps1 script & compared to the online
    version with the Compare-AuvikSpec.ps1 script

.PARAMETER ModuleName
    The name of the module to generate functions for

    Example: Celerium.Auvik

.PARAMETER JsonSpec
    Path to the Auvik OpenAPI json file

    By default docs\Auvik-v1.json is used

.PARAMETER GitHubPageUri
    Base uri of the GitHub pages site which is used for the help .LINK values

.EXAMPLE
    .\New-PublicFunctions.ps1

    Regenerates every public function, the module manifest entries, & the endpoints.csv file

.EXAMPLE
    .\New-PublicFunctions.ps1 -WhatIf

    Shows what would be generated without writing any files

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
#Requires -Version 7.0

#Region     [ Parameters ]

[CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$ModuleName = 'Celerium.Auvik',

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$JsonSpec,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$GitHubPageUri = 'https://celerium.github.io/Celerium.Auvik'
    )

#EndRegion  [ Parameters ]

Write-Verbose ''
Write-Verbose "START - $(Get-Date -Format yyyy-MM-dd-HH:mm)"
Write-Verbose ''

$StartDate = Get-Date

#Region     [ Prerequisites ]

$RootPath       = Split-Path -Path $PSScriptRoot -Parent
$ModulePath     = Join-Path -Path $RootPath -ChildPath $ModuleName
$PublicPath     = Join-Path -Path $ModulePath -ChildPath 'Public'
$PrivatePath    = Join-Path -Path $ModulePath -ChildPath 'Private'
$ManifestPath   = Join-Path -Path $ModulePath -ChildPath "$ModuleName.psd1"
$CsvPath        = Join-Path -Path (Join-Path -Path $RootPath -ChildPath 'docs') -ChildPath 'endpoints.csv'

if (-not $JsonSpec) { $JsonSpec = Join-Path -Path (Join-Path -Path $RootPath -ChildPath 'docs') -ChildPath 'Auvik-v1.json' }
if (-not (Test-Path -Path $JsonSpec -PathType Leaf)) { throw "The OpenAPI spec was not found at [ $JsonSpec ]. Run Get-AuvikSpec.ps1 to download it" }

# The folder (category) of the public functions & the documentation of each spec tag
$CategoryMap = @{
    'Device'                = 'Inventory'
    'Network'               = 'Inventory'
    'Interface'             = 'Inventory'
    'Component'             = 'Inventory'
    'Entity'                = 'Inventory'
    'Configuration'         = 'Inventory'
    'Credentials'           = 'Other'
    'Tenants'               = 'ClientManagement'
    'Alert History'         = 'Alert'
    'Alert'                 = 'Alert'
    'Usage'                 = 'Billing'
    'Statistics'            = 'Statistics'
    'SNMP Poller'           = 'Pollers'
    'SNMP Poller History'   = 'Pollers'
    'ASM'                   = 'SaaSManagement'
}

# The noun of the function that is created for each endpoint. Endpoints that are not listed are named after their path
$NounMap = @{
    '/authentication/verify'                        = 'AuthenticationVerify'
    '/inventory/device/info'                        = 'DeviceInfo'
    '/inventory/device/detail'                      = 'DeviceDetail'
    '/inventory/device/detail/extended'             = 'DeviceDetailExtended'
    '/inventory/device/warranty'                    = 'DeviceWarranty'
    '/inventory/device/lifecycle'                   = 'DeviceLifecycle'
    '/inventory/configuration'                      = 'Configuration'
    '/inventory/network/info'                       = 'NetworkInfo'
    '/inventory/network/detail'                     = 'NetworkDetail'
    '/inventory/interface/info'                     = 'InterfaceInfo'
    '/inventory/component/info'                     = 'ComponentInfo'
    '/inventory/entity/note'                        = 'EntityNote'
    '/inventory/entity/audit'                       = 'EntityAudit'
    '/tenants'                                      = 'Tenant'
    '/tenants/detail'                               = 'TenantDetail'
    '/alert/history/info'                           = 'AlertHistory'
    '/alert/dismiss/{id}'                           = 'AlertDismiss'
    '/billing/usage/client'                         = 'BillingUsageClient'
    '/billing/usage/device/{id}'                    = 'BillingUsageDevice'
    '/stat/device/{statId}'                         = 'DeviceStatistics'
    '/stat/deviceAvailability/{statId}'             = 'DeviceAvailabilityStatistics'
    '/stat/service/{statId}'                        = 'ServiceStatistics'
    '/stat/interface/{statId}'                      = 'InterfaceStatistics'
    '/stat/component/{componentType}/{statId}'      = 'ComponentStatistics'
    '/stat/oid/{statId}'                            = 'OIDStatistics'
    '/settings/snmppoller'                          = 'SNMPPollerSetting'
    '/settings/snmppoller/{snmpPollerSettingId}/devices' = 'SNMPPollerDevice'
    '/stat/snmppoller/string'                       = 'SNMPPollerHistoryString'
    '/stat/snmppoller/int'                          = 'SNMPPollerHistoryInt'
    '/asm/app/info'                                 = 'ASMApplication'
    '/asm/client/info'                              = 'ASMClient'
    '/asm/securityLog/info'                         = 'ASMSecurityLog'
    '/asm/tag/info'                                 = 'ASMTag'
    '/asm/user/info'                                = 'ASMUser'
    '/asm/license/info'                             = 'ASMLicense'
}

# Names of functions from earlier versions of the module, they are kept as aliases
$LegacyAliasMap = @{
    'Get-AuvikAuthenticationVerify' = @('Test-AuvikAPICredential')
    'Get-AuvikDeviceInfo'           = @('Get-AuvikDevice')
    'Get-AuvikInterfaceInfo'        = @('Get-AuvikInterface')
    'Get-AuvikComponentInfo'        = @('Get-AuvikComponent')
    'Get-AuvikNetworkInfo'          = @('Get-AuvikNetwork')
    'Get-AuvikEntityNote'           = @('Get-AuvikEntity')
    'Get-AuvikAlertHistory'         = @('Get-AuvikAlert')
    'Send-AuvikAlertDismiss'        = @('Clear-AuvikAlert')
    'Get-AuvikBillingUsageClient'   = @('Get-AuvikBilling')
    'Get-AuvikSNMPPollerHistoryString' = @('Get-AuvikSNMPPollerHistory')
}

# Endpoints that only return a status, the function returns $true when the request succeeded & $false when it failed
$BooleanEndpoints = @('/authentication/verify')

# Public functions that are used by the example scripts
$ExampleMap = @{
    'Get-AuvikAuthenticationVerify'     = 'Connect-AuvikExample.ps1'
    'Get-AuvikTenant'                   = 'Get-DeviceInventoryExample.ps1'
    'Get-AuvikTenantDetail'             = 'Get-DeviceInventoryExample.ps1'
    'Get-AuvikDeviceInfo'               = 'Get-DeviceInventoryExample.ps1'
    'Get-AuvikAlertHistory'             = 'Get-AlertReportExample.ps1'
    'Send-AuvikAlertDismiss'            = 'Legacy/Get-AlertReportExample.ps1'
    'Get-AuvikDeviceStatistics'         = 'Get-DeviceStatisticsExample.ps1'
    'Get-AuvikDeviceLifecycle'          = 'Get-DeviceLifecycleExample.ps1'
    'Get-AuvikDeviceWarranty'           = 'Get-DeviceLifecycleExample.ps1'
}

$CommonParameters   = 'Verbose','Debug','ErrorAction','WarningAction','InformationAction','ErrorVariable','WarningVariable','InformationVariable','OutVariable','OutBuffer','PipelineVariable','ProgressAction','WhatIf','Confirm','AllResults'
$AutomaticVariables = 'Input','Args','This','Error','Host','Home','Pid','Pwd','Event','Sender','Matches','Profile','ForEach','Switch','PSItem','Null','True','False','Headers','Data'

$Utf8NoBom = [System.Text.UTF8Encoding]::new($false)

#EndRegion  [ Prerequisites ]

#Region     [ Helper Functions ]

function ConvertTo-PascalCase {
    param ([string]$Text)
    $Parts = $Text -split '[^A-Za-z0-9]+' | Where-Object { $_ }
    -join ($Parts | ForEach-Object { $_.Substring(0,1).ToUpper() + $_.Substring(1) })
}

function ConvertTo-HelpText {
    param ([string]$Text)

    if (-not $Text) { return '' }

    $Text = $Text -replace '(?i)<br\s*/?>', "`n"
    $Text = $Text -replace '(?i)</?(p|li|ul|ol|div|h\d|pre|table|tr|thead|tbody)(\s[^>]*)?/?>', "`n"
    $Text = $Text -replace '(?i)</?(b|i|u|a|span|code|strong|em|td|th)(\s[^>]*)?/?>', ''
    $Text = $Text -replace '&nbsp;', ' ' -replace '&lt;', '<' -replace '&gt;', '>' -replace '&quot;', '"' -replace '&#39;', "'" -replace '&amp;', '&'
    $Text = $Text -replace "[\u2018\u2019]", "'" -replace '[\u201C\u201D]', '"' -replace '[\u2013\u2014]', '-' -replace '\u2026', '...'
    $Text = $Text -replace '[^\x00-\x7F]', '?'
    $Text = $Text -replace '#>', '# >' -replace '<#', '< #'
    $Text = $Text -replace "`r", ''

    $Lines = foreach ($Line in ($Text -split "`n")) {
        $Line = $Line.Trim() -replace '\s{2,}', ' '
        # A leading .WORD would be read as a help keyword
        $Line -replace '^\.(?=[A-Za-z])', 'Note: .'
    }

    $Result = New-Object System.Collections.Generic.List[string]
    foreach ($Line in $Lines) {
        if ($Line -eq '' -and ($Result.Count -eq 0 -or $Result[$Result.Count - 1] -eq '')) { continue }
        $Result.Add($Line)
    }
    while ($Result.Count -gt 0 -and $Result[$Result.Count - 1] -eq '') { $Result.RemoveAt($Result.Count - 1) }

    return ($Result -join "`n")
}

function Get-OperationDescription {
    # The first paragraph of the spec description, the rest of it is cURL instructions that are not useful in the help
    param ([string]$Text)

    if (-not $Text) { return '' }

    $Text = ($Text -split '(?i)<br\s*/?>' | Select-Object -First 1)
    $Text = ($Text -split '(?i)Looking at the detail screen' | Select-Object -First 1)

    return ((ConvertTo-HelpText -Text $Text) -split "`n\n" | Select-Object -First 1)
}

function Format-HelpBlock {
    param ([string]$Text, [int]$Indent = 8)
    $Pad = ' ' * $Indent
    (($Text -split "`n") | ForEach-Object { if ($_ -eq '') { '' } else { $Pad + $_ } }) -join "`n"
}

function Sort-Ordinal {
    # Culture independent sorting so that Windows, Linux, & macOS generate identical files
    param (
        [object[]]$Items,
        [scriptblock]$Key = { $_ }
    )

    if ($Items.Count -le 1) { return $Items }

    $Keys   = [string[]]@($Items | ForEach-Object { "$(& $Key)" })
    $Sorted = $Items.Clone()
    [System.Array]::Sort($Keys, $Sorted, [System.StringComparer]::Ordinal)

    return $Sorted
}

function Resolve-SpecRef {
    # Resolves a $ref such as #/components/schemas/DeviceTypeSchema
    param ($Node)

    $Depth = 0
    while ($Node -is [System.Collections.IDictionary] -and $Node.Contains('$ref') -and $Depth -lt 10) {
        $Target = $Spec
        foreach ($Part in ($Node['$ref'] -replace '^#/', '' -split '/')) { $Target = $Target[$Part] }
        $Node = $Target
        $Depth++
    }

    return $Node
}

function ConvertTo-FunctionNoun {
    # Names an endpoint that is not listed in the NounMap after its path
    param ([string]$Path)

    $Segments   = $Path.Trim('/') -split '/'
    $Parts      = [System.Collections.Generic.List[string]]::new()
    $Previous   = ''

    foreach ($Segment in $Segments) {

        if ($Segment -match '^\{(.+)\}$') { if ($Segment -eq $Segments[-1]) { $Parts.Add('ById') } else { $Parts.Add('By' + (ConvertTo-PascalCase -Text $Matches[1])) } }
        else {
            $Pascal = ConvertTo-PascalCase -Text $Segment
            if ($Pascal -and $Pascal -ne $Previous) { $Parts.Add($Pascal) }
            $Previous = $Pascal
        }

    }

    return ($Parts -join '')
}

function Get-SampleValue {
    param ($Parameter)

    if ($Parameter.Enum.Count -gt 0) { return "'$($Parameter.Enum[0])'" }

    switch -Regex ($Parameter.PsType) {
        '^\[bool'       { return '$true' }
        '^\[int64'      { return '10' }
        '^\[datetime'   { return "'2025-01-01T00:00:00Z'" }
    }

    if ($Parameter.ApiName -match '(?i)id$')        { return "'1234567890'" }
    if ($Parameter.ApiName -eq 'tenants')           { return "'1234567890'" }
    if ($Parameter.ApiName -eq 'tenantDomainPrefix') { return "'celerium'" }

    return "'Example'"
}

function Get-WriteVerb {
    # POST = Send, PUT\PATCH = Set, DELETE = Remove
    param ([string]$Method)

    switch ($Method) {
        'POST'      { return 'Send' }
        'DELETE'    { return 'Remove' }
        default     { return 'Set' }
    }
}

function Get-ParameterModel {
    param (
        $Operation,
        [string]$Path
    )

    $Parameters = [System.Collections.Generic.List[object]]::new()

    foreach ($Parameter in @($Operation.parameters)) {

        $Parameter = Resolve-SpecRef -Node $Parameter
        if ($null -eq $Parameter) { continue }

        $ApiName    = $Parameter.name
        $In         = $Parameter.in
        $Schema     = Resolve-SpecRef -Node $Parameter.schema
        $Type       = $Schema.type
        $ApiLeaf    = ($ApiName -replace '\]$', '') -split '\[' | Select-Object -Last 1

        $Name = ConvertTo-PascalCase -Text $ApiName
        if ($In -eq 'query' -and ($CommonParameters -contains $Name -or $AutomaticVariables -contains $Name)) { $Name = $Name + 'Value' }

        $Description = ConvertTo-HelpText -Text $Parameter.description

        # The spec defines a few dates as booleans or strings, dates are recognized by the name of the parameter
        $IsDate     = ($In -eq 'query') -and ($ApiName -notlike 'page[[]*') -and ($ApiLeaf -cmatch '(After|Before|Since|Date|Time)$')
        $IsMulti    = ($In -eq 'query') -and ($Type -eq 'string') -and ($Description -match '(?i)comma[ -]delimited')

        $PsType = if ($IsDate)                   { '[datetime]' }
                  elseif ($IsMulti)              { '[string[]]' }
                  elseif ($Type -eq 'boolean')   { '[bool]' }
                  elseif ($Type -eq 'number' -or $Type -eq 'integer') { '[int64]' }
                  else                           { '[string]' }

        $Enum = if ($IsDate -or $PsType -eq '[bool]') { @() } else { @($Schema.enum | Where-Object { $null -ne $_ } | ForEach-Object { "$_" } | Select-Object -Unique) }

        $UseRange = ($PsType -eq '[int64]') -and ($ApiName -like 'page[[]*')

        if (-not $Description) { $Description = "Defines the $ApiName value" }
        if ($Schema.default) { $Description += "`n`nDefault value: $($Schema.default)" }

        $Parameters.Add([PSCustomObject]@{
            Name        = $Name
            ApiName     = $ApiName
            In          = $In
            PsType      = $PsType
            Mandatory   = ($In -eq 'path') -or ($Parameter.required -eq $true)
            Enum        = $Enum
            IsDate      = $IsDate
            IsMulti     = $IsMulti
            IsCursor    = ($ApiName -eq 'page[after]')
            Range       = $UseRange
            Description = $Description
        })

    }

    # A path parameter that the spec does not declare
    foreach ($PathName in ([regex]::Matches($Path, '\{([^}]+)\}') | ForEach-Object { $_.Groups[1].Value })) {
        if (-not ($Parameters | Where-Object { $_.In -eq 'path' -and $_.ApiName -eq $PathName })) {
            $Parameters.Add([PSCustomObject]@{
                Name        = ConvertTo-PascalCase -Text $PathName
                ApiName     = $PathName
                In          = 'path'
                PsType      = '[string]'
                Mandatory   = $true
                Enum        = @()
                IsDate      = $false
                IsMulti     = $false
                IsCursor    = $false
                Range       = $false
                Description = "Defines the $PathName value"
            })
        }
    }

    $PathParameters = @($Parameters | Where-Object In -eq 'path')

    # A query parameter that shares its name with a path parameter is renamed
    foreach ($Parameter in ($Parameters | Where-Object { $_.In -ne 'path' })) {
        if ($PathParameters | Where-Object { $_.Name -ieq $Parameter.Name }) { $Parameter.Name = $Parameter.Name + 'Filter' }
    }

    $Query = @(Sort-Ordinal -Items @($Parameters | Where-Object In -eq 'query') -Key { $_.Name.ToLowerInvariant() })

    # Paging parameters are always last
    $Paging     = @($Query | Where-Object { $_.ApiName -like 'page[[]*' })
    $Filtering  = @($Query | Where-Object { $_.ApiName -notlike 'page[[]*' })

    return [PSCustomObject]@{
        PathParameters      = $PathParameters
        QueryParameters     = $Query
        HasCursor           = [bool]($Query | Where-Object IsCursor)
        OrderedParameters   = @(
                                $PathParameters
                                $Filtering | Where-Object Mandatory
                                $Filtering | Where-Object { -not $_.Mandatory }
                                $Paging
                            ) | Where-Object { $_ }
    }
}

function Get-MemberCode {
    # Creates the code that builds the request for one endpoint of a function
    param (
        $Member,
        [string]$Pad
    )

    $Model      = $Member.Model
    $Endpoint   = $Member.Endpoint
    $Lines      = [System.Collections.Generic.List[string]]::new()

    $UriTemplate = $Endpoint.Path
    foreach ($PathParameter in $Model.PathParameters) {
        $UriTemplate = $UriTemplate.Replace("{$($PathParameter.ApiName)}", "`$([System.Uri]::EscapeDataString(`$$($PathParameter.Name)))")
    }

    if ($UriTemplate -match '\$') { $Lines.Add("$Pad`$ResourceUri = `"$UriTemplate`"") }
    else { $Lines.Add("$Pad`$ResourceUri = '$UriTemplate'") }

    if ($Model.QueryParameters.Count) {

        $Lines.Add("$Pad`$NameMap = @{")
        $Width = ($Model.QueryParameters | ForEach-Object { $_.Name.Length } | Measure-Object -Maximum).Maximum
        foreach ($QueryParameter in $Model.QueryParameters) {
            $Lines.Add("$Pad    $($QueryParameter.Name.PadRight($Width)) = '$($QueryParameter.ApiName)'")
        }
        $Lines.Add("$Pad}")

    }
    else { $Lines.Add("$Pad`$NameMap = @{}") }

    return $Lines
}

#EndRegion  [ Helper Functions ]

#Region     [ Read Spec ]

Write-Verbose " - (1/5) - $(Get-Date -Format MM-dd-HH:mm) - Reading OpenAPI spec"

$Spec = Get-Content -Path $JsonSpec -Raw | ConvertFrom-Json -AsHashtable -Depth 100

if (-not $Spec.paths) { throw "[ $JsonSpec ] is not an OpenAPI spec" }
$ApiVersion = "$($Spec.info.version)"
if ($ApiVersion -ne 'v1') { throw "Only the Auvik v1 API is supported, the spec is version [ $ApiVersion ]" }

# Private functions, they can not be reused as public function names
$PrivateFiles       = @(Get-ChildItem -Path $PrivatePath -Filter '*.ps1' -Recurse | Sort-Object -Property { $_.FullName -replace '\\', '/' } -Culture ([cultureinfo]::InvariantCulture))
$PrivateFunctions   = foreach ($File in $PrivateFiles) {
    $Ast = [System.Management.Automation.Language.Parser]::ParseFile($File.FullName, [ref]$null, [ref]$null)
    $Defined = $Ast.EndBlock.Statements | Where-Object { $_ -is [System.Management.Automation.Language.FunctionDefinitionAst] }
    foreach ($Function in $Defined) { [PSCustomObject]@{ Name = $Function.Name; File = $File } }
}

$Endpoints = [System.Collections.Generic.List[object]]::new()

foreach ($SpecPath in (Sort-Ordinal -Items @($Spec.paths.Keys))) {

    # The version is part of the path in the online spec & part of the server url in older copies of it
    $Path = $SpecPath -replace "^/$ApiVersion(?=/)", ''

    foreach ($Method in 'get','post','put','patch','delete') {

        $Operation = $Spec.paths[$SpecPath][$Method]
        if (-not $Operation) { continue }

        $Tag        = if ($Operation.tags) { @($Operation.tags)[0] } else { 'Other' }
        $Summary    = ((ConvertTo-HelpText -Text $Operation.summary) -split "`n")[0]
        $IsWrite    = ($Method -ne 'get')

        $Endpoints.Add([PSCustomObject]@{
            Path        = $Path
            Method      = $Method.ToUpper()
            Operation   = $Operation
            Tag         = $Tag
            Category    = if ($CategoryMap.ContainsKey($Tag)) { $CategoryMap[$Tag] } else { ConvertTo-PascalCase -Text $Tag }
            Summary     = $Summary
            IsWrite     = $IsWrite
            Verb        = if ($IsWrite) { Get-WriteVerb -Method $Method.ToUpper() } else { 'Get' }
            Function    = $null
            Unit        = $null
            SetName     = $null
        })

    }
}

#EndRegion  [ Read Spec ]

#Region     [ Function Names ]

Write-Verbose " - (2/5) - $(Get-Date -Format MM-dd-HH:mm) - Creating unique function names"

$Reserved = @($PrivateFunctions.Name)

foreach ($Endpoint in $Endpoints) {
    $Noun = if ($NounMap.ContainsKey($Endpoint.Path)) { $NounMap[$Endpoint.Path] } else { ConvertTo-FunctionNoun -Path $Endpoint.Path }
    $Endpoint.Function = "$($Endpoint.Verb)-Auvik$Noun"
}

# Single item endpoints are named after the endpoint they are combined with
foreach ($Endpoint in $Endpoints) {
    if ($Endpoint.Path -match '^(?<parent>[^{}]+)/\{[^/{}]+\}$' -and $NounMap.ContainsKey($Matches['parent']) -and -not $NounMap.ContainsKey($Endpoint.Path)) {
        $Endpoint.Function = "$($Endpoint.Verb)-Auvik$($NounMap[$Matches['parent']])"
    }
}

# Different methods with the same verb (such as PUT & PATCH) need the method in the name
$Duplicates = $Endpoints | Where-Object { -not ($_.Path -match '^(?<parent>[^{}]+)/\{[^/{}]+\}$') } | Group-Object -Property Function | Where-Object { $_.Count -gt 1 -or $_.Name -in $Reserved }
foreach ($Group in $Duplicates) {
    foreach ($Endpoint in $Group.Group) { $Endpoint.Function = $Endpoint.Function + (ConvertTo-PascalCase -Text $Endpoint.Method.ToLowerInvariant()) }
}

#EndRegion  [ Function Names ]

#Region     [ Combine Endpoints ]

Write-Verbose " - (3/5) - $(Get-Date -Format MM-dd-HH:mm) - Combining list & single item endpoints"

foreach ($Endpoint in $Endpoints) {
    $Endpoint | Add-Member -NotePropertyName Model -NotePropertyValue (Get-ParameterModel -Operation $Endpoint.Operation -Path $Endpoint.Path)
}

$Units = [System.Collections.Generic.List[object]]::new()

foreach ($Endpoint in $Endpoints) {

    if ($Endpoint.Unit) { continue }

    $Child  = $null
    $Parent = $Endpoint

    # An endpoint is only combined with its single item endpoint, such as /inventory/device/info & /inventory/device/info/{id}
    if ($Endpoint.Path -notmatch '\{') {

        $Candidates = @($Endpoints | Where-Object {
            -not $_.Unit -and $_.Path -match '^(?<parent>[^{}]+)/\{[^/{}]+\}$' -and $Matches['parent'] -eq $Endpoint.Path -and
            $_.Method -eq $Endpoint.Method -and $_.Verb -eq $Endpoint.Verb -and $_.Category -eq $Endpoint.Category
        })

        foreach ($Candidate in $Candidates) {

            # A parameter that is in both endpoints is shared by both parameter sets, unless its type differs
            $Conflicts = @(foreach ($ChildParameter in $Candidate.Model.OrderedParameters) {
                $ParentParameter = $Endpoint.Model.OrderedParameters | Where-Object { $_.Name -ieq $ChildParameter.Name } | Select-Object -First 1
                if ($ParentParameter -and ($ParentParameter.PsType -ne $ChildParameter.PsType -or ($ParentParameter.Enum -join '|') -ne ($ChildParameter.Enum -join '|'))) { $ChildParameter.Name }
                elseif ($ChildParameter.Name -eq 'AllResults') { $ChildParameter.Name }
            })

            if ($Conflicts.Count -eq 0) { $Child = $Candidate; break }
            Write-Verbose "Not combining [ $($Candidate.Function) ] into [ $($Endpoint.Function) ], parameters with different types [ $($Conflicts -join ', ') ]"

        }

    }

    $Unit = [PSCustomObject]@{
        Function        = $Parent.Function
        Verb            = $Parent.Verb
        Method          = $Parent.Method
        Category        = $Parent.Category
        IsWrite         = $Parent.IsWrite
        IsBoolean       = $Parent.Path -in $BooleanEndpoints
        Members         = @()
        Aliases         = @()
    }

    $Members = @( [PSCustomObject]@{ Endpoint = $Parent; Model = $Parent.Model; Unit = $Unit; SetName = $null } )

    if ($Child) {
        $Members[0].SetName = 'List'
        $Members += [PSCustomObject]@{ Endpoint = $Child; Model = $Child.Model; Unit = $Unit; SetName = 'ById' }
        $Child.Unit         = $Unit
        $Child.Function     = $Parent.Function
        $Child.SetName      = 'ById'
        $Parent.SetName     = 'List'
    }

    $Unit.Members   = $Members
    $Parent.Unit    = $Unit
    $Units.Add($Unit)

}

$Units = @(Sort-Ordinal -Items @($Units) -Key { "$($_.Category)|$($_.Function)" })

$Duplicates = $Units | Group-Object -Property Function | Where-Object { $_.Count -gt 1 -or $_.Name -in $Reserved }
if ($Duplicates) { throw "Unable to create unique function names for [ $($Duplicates.Name -join ', ') ]" }

#EndRegion  [ Combine Endpoints ]

#Region     [ Generate Functions ]

Write-Verbose " - (4/5) - $(Get-Date -Format MM-dd-HH:mm) - Generating [ $($Units.Count) ] functions"

if ($PSCmdlet.ShouldProcess($PublicPath, 'Remove existing generated public functions')) {

    # Files are removed first, deleting a whole folder tree can fail on Windows when another process (such as an antivirus) has a handle open
    if (Test-Path -Path $PublicPath) {
        Get-ChildItem -Path $PublicPath -Recurse -File | Remove-Item -Force
        Get-ChildItem -Path $PublicPath -Recurse -Directory | Sort-Object { $_.FullName.Length } -Descending | Where-Object { -not (Get-ChildItem -Path $_.FullName -Force) } | Remove-Item -Force -ErrorAction SilentlyContinue
    }

    if (-not (Test-Path -Path $PublicPath)) { New-Item -Path $PublicPath -ItemType Directory > $null }

}

$GeneratedFiles = [System.Collections.Generic.List[string]]::new()

foreach ($Unit in $Units) {

    $FunctionName   = $Unit.Function
    $Merged         = $Unit.Members.Count -gt 1
    $Members        = $Unit.Members
    $AllModels      = @($Members.Model)

    $AnyCursor      = [bool]($AllModels | Where-Object HasCursor)

    #Region     [ Help ]

    $Help = [System.Collections.Generic.List[string]]::new()
    $Help.Add('<#')
    $Help.Add('    .SYNOPSIS')
    $Help.Add((Format-HelpBlock -Text (($Members | ForEach-Object { $_.Endpoint.Summary } | Select-Object -Unique) -join ' / ')))
    $Help.Add('')
    $Help.Add('    .DESCRIPTION')

    foreach ($Member in $Members) {

        $Endpoint       = $Member.Endpoint
        $Summary        = if ($Endpoint.Summary) { $Endpoint.Summary } else { "Calls the $($Endpoint.Path) endpoint" }
        $Description    = Get-OperationDescription -Text $Endpoint.Operation.description
        if (-not $Description) { $Description = $Summary }

        $Prefix = if ($Merged) { "Parameter set [ $($Member.SetName) ] - " } else { '' }
        $Help.Add((Format-HelpBlock -Text "${Prefix}The $FunctionName cmdlet invokes the $($Endpoint.Method) method of the $($Endpoint.Path) endpoint ($($Summary.TrimEnd('.')))"))
        $Help.Add('')
        $Help.Add((Format-HelpBlock -Text $Description))
        $Help.Add('')

        if ($Endpoint.Operation.deprecated -eq $true -or $Endpoint.Operation.summary -match 'DEPRECATED') {
            $Help.Add('        This endpoint is deprecated by Auvik and may be removed in a future API version')
            $Help.Add('')
        }

    }

    if ($Unit.IsWrite) {
        $Help.Add('        This is a write function. It changes data in Auvik. Use -WhatIf to see the request without sending it')
    }
    else { $Help.RemoveAt($Help.Count - 1) }

    $Documented = @{}
    foreach ($Member in ($Members | Sort-Object { $_.SetName -ne 'ById' })) {
        foreach ($Parameter in $Member.Model.OrderedParameters) {

            if ($Documented.ContainsKey($Parameter.Name)) { continue }
            $Documented[$Parameter.Name] = $true

            $Help.Add('')
            $Help.Add("    .PARAMETER $($Parameter.Name)")
            $Help.Add((Format-HelpBlock -Text $Parameter.Description))

            if ($Parameter.Enum.Count -gt 0) {
                $Help.Add('')
                $Help.Add('        Allowed values:')
                $Help.Add("        $(($Parameter.Enum | ForEach-Object { "'$_'" }) -join ', ')")
            }

            if ($Parameter.IsMulti) {
                $Help.Add('')
                $Help.Add('        Accepts multiple values which are sent to the API as a comma delimited list')
            }

            if ($Parameter.IsDate) {
                $Help.Add('')
                $Help.Add('        Accepts a date & time which is sent to the API in UTC')
            }

        }
    }

    if ($AnyCursor) {
        $Help.Add('')
        $Help.Add('    .PARAMETER AllResults')
        $Help.Add('        Returns all items from the endpoint by following the pagination links')
        $Help.Add('')
        $Help.Add('        When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters')
        $Help.Add('')
        $Help.Add('        Highly recommended to only use with filters to reduce API errors & timeouts')
    }

    foreach ($Member in $Members) {

        $Endpoint   = $Member.Endpoint
        $Model      = $Member.Model

        $MandatorySplat = ($Model.OrderedParameters | Where-Object Mandatory | ForEach-Object { "-$($_.Name) $(Get-SampleValue -Parameter $_)" }) -join ' '
        $BaseCommand    = (@($FunctionName, $MandatorySplat) | Where-Object { $_ }) -join ' '

        $Help.Add('')
        $Help.Add('    .EXAMPLE')
        $Help.Add("        $BaseCommand$(if ($Endpoint.IsWrite) { ' -WhatIf' })")
        $Help.Add('')

        if ($Endpoint.IsWrite)  { $Help.Add("        Shows the $($Endpoint.Method) request to the $($Endpoint.Path) endpoint without sending it") }
        else                    { $Help.Add("        Returns the result of the $($Endpoint.Path) endpoint") }

        $Tenants = @($Model.QueryParameters | Where-Object { $_.ApiName -eq 'tenants' -and -not $_.Mandatory })
        $Paging  = @($Model.QueryParameters | Where-Object { $_.ApiName -eq 'page[first]' })

        if (-not $Endpoint.IsWrite -and ($Tenants.Count -or $Paging.Count)) {

            $ExtraParts = @()
            if ($Tenants.Count) { $ExtraParts += "-Tenants '1234567890'" }
            if ($Paging.Count)  { $ExtraParts += '-PageFirst 10' }

            $Help.Add('')
            $Help.Add('    .EXAMPLE')
            $Help.Add("        $((@($BaseCommand) + $ExtraParts) -join ' ')")
            $Help.Add('')
            $Help.Add("        Returns the result of the $($Endpoint.Path) endpoint limited to the defined $(if ($Tenants.Count) { 'tenant' } else { 'number of items' })")

        }

        if ($Model.HasCursor) {
            $Help.Add('')
            $Help.Add('    .EXAMPLE')
            $Help.Add("        $BaseCommand -AllResults")
            $Help.Add('')
            $Help.Add("        Returns every item from the $($Endpoint.Path) endpoint by following the pagination links")
        }

    }

    $Help.Add('')
    $Help.Add('    .INPUTS')
    if (@($AllModels | Where-Object { $_.PathParameters.Count -eq 1 }).Count) { $Help.Add('        System.String') }
    else { $Help.Add('        None') }

    $Help.Add('')
    $Help.Add('    .OUTPUTS')
    if ($Unit.IsBoolean) { $Help.Add('        System.Boolean') }
    else { $Help.Add('        System.Management.Automation.PSCustomObject') }

    $Help.Add('')
    $Help.Add('    .NOTES')

    foreach ($Member in $Members) {
        $Help.Add("        Endpoint : $($Member.Endpoint.Method) $($Member.Endpoint.Path)")
    }

    $Help.Add('        The Auvik API user needs the role permissions that are required by the endpoint')

    if ($Members | Where-Object { $_.Endpoint.Path -like '*{componentType}*' }) {
        $Help.Add('        Not every StatId is valid for every ComponentType, the API returns a 400 error with the valid values when the combination is not valid')
    }

    if ($Unit.IsBoolean) {
        $Help.Add('')
        $Help.Add('        This function returns $true when the credentials are valid & $false when they are not')
    }

    $Help.Add('')
    $Help.Add('    .LINK')
    $Help.Add("        $GitHubPageUri/site/$($Unit.Category)/$FunctionName.html")
    $Help.Add('#>')

    #EndRegion  [ Help ]

    #Region     [ Code ]

    $Aliases = @(if ($LegacyAliasMap.ContainsKey($FunctionName)) { $LegacyAliasMap[$FunctionName] })
    $Unit.Aliases = $Aliases

    $Binding = @()
    if ($Merged) { $Binding += "DefaultParameterSetName = 'List'" }
    if ($Unit.IsWrite) { $Binding += 'SupportsShouldProcess = $true'; $Binding += "ConfirmImpact = 'High'" }

    $Code = [System.Collections.Generic.List[string]]::new()
    $Code.Add("function $FunctionName {")
    foreach ($Line in $Help) { $Code.Add($Line) }
    $Code.Add('')
    $Code.Add("    [CmdletBinding($($Binding -join ', '))]")
    $Code.Add('    param (')

    $ParamLines = [System.Collections.Generic.List[string]]::new()

    # A parameter that is in more than one parameter set is only declared once
    $Declared = [ordered]@{}
    foreach ($Member in ($Members | Sort-Object { $_.SetName -ne 'ById' })) {
        $Position = 0
        foreach ($Parameter in $Member.Model.OrderedParameters) {
            $Key = $Parameter.Name.ToLowerInvariant()
            if (-not $Declared.Contains($Key)) { $Declared[$Key] = [System.Collections.Generic.List[object]]::new() }
            $Declared[$Key].Add([PSCustomObject]@{ Member = $Member; Parameter = $Parameter; Position = $(if ($Parameter.In -eq 'path') { $Position++; $Position - 1 }) })
        }
    }

    foreach ($Entries in $Declared.Values) {

        $First  = $Entries[0].Parameter
        $Lines  = [System.Collections.Generic.List[string]]::new()

        foreach ($Entry in $Entries) {

            $SetText = if ($Entry.Member.SetName) { ", ParameterSetName = '$($Entry.Member.SetName)'" } else { '' }

            if ($Entry.Parameter.In -eq 'path') {
                $Pipeline = if ($Entry.Member.Model.PathParameters.Count -eq 1) { 'ValueFromPipeline = $true, ' } else { '' }
                $Lines.Add("        [Parameter(Mandatory = `$true, Position = $($Entry.Position), ${Pipeline}ValueFromPipelineByPropertyName = `$true$SetText)]")
            }
            else {
                $Lines.Add("        [Parameter(Mandatory = `$$($Entry.Parameter.Mandatory.ToString().ToLower())$SetText)]")
            }

        }

        $PathEntry = $Entries | Where-Object { $_.Parameter.In -eq 'path' } | Select-Object -First 1
        if ($PathEntry) {

            $PathParameter      = $PathEntry.Parameter
            $ParameterAliases   = [System.Collections.Generic.List[string]]::new()
            if ($PathEntry.Member.Model.PathParameters.Count -eq 1 -and $PathParameter.ApiName -match '(?i)id$' -and $PathParameter.Name -ine 'id' -and -not ($Declared.Keys | Where-Object { $_ -eq 'id' })) { $ParameterAliases.Add("'Id'") }
            if ($PathParameter.Name -ine $PathParameter.ApiName) { $ParameterAliases.Add("'$($PathParameter.ApiName)'") }
            if ($ParameterAliases.Count) { $Lines.Add("        [Alias($($ParameterAliases -join ', '))]") }

        }

        if ($PathEntry -or $First.PsType -in '[string]', '[string[]]') { $Lines.Add('        [ValidateNotNullOrEmpty()]') }
        if ($First.Enum.Count -gt 0) { $Lines.Add("        [ValidateSet($(($First.Enum | ForEach-Object { "'" + ($_ -replace "'", "''") + "'" }) -join ', '))]") }
        if ($First.Range) { $Lines.Add('        [ValidateRange(1, [int64]::MaxValue)]') }

        $Lines.Add("        $($First.PsType)`$$($First.Name)")
        $ParamLines.Add(($Lines -join "`n"))

    }

    if ($AnyCursor) {
        $CursorSet = ($Members | Where-Object { $_.Model.HasCursor } | Select-Object -First 1).SetName
        $CursorSetText = if ($CursorSet) { ", ParameterSetName = '$CursorSet'" } else { '' }
        $ParamLines.Add("        [Parameter(Mandatory = `$false$CursorSetText)]`n        [switch]`$AllResults")
    }

    $Code.Add(($ParamLines -join ",`n`n"))
    $Code.Add('    )')
    $Code.Add('')
    $Code.Add('    begin {')
    $Code.Add('')
    $Code.Add('        $FunctionName       = $MyInvocation.InvocationName')
    $Code.Add('        $ParameterName      = ($FunctionName -replace ''-'', '''') + ''Parameters''')
    $Code.Add('        $QueryParameterName = $ParameterName + ''Query''')
    $Code.Add('')
    $Code.Add('    }')
    $Code.Add('')
    $Code.Add('    process {')
    $Code.Add('')
    $Code.Add('        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"')
    $Code.Add('')

    if ($Merged) {

        $Code.Add('        switch ($PSCmdlet.ParameterSetName) {')
        foreach ($Member in ($Members | Sort-Object { $_.SetName -ne 'ById' })) {
            $Label = "'$($Member.SetName)'"
            $Code.Add("            $Label {")
            foreach ($Line in (Get-MemberCode -Member $Member -Pad '                ')) { $Code.Add($Line) }
            $Code.Add('            }')
        }
        $Code.Add('        }')

    }
    else {
        foreach ($Line in (Get-MemberCode -Member $Members[0] -Pad '        ')) { $Code.Add($Line) }
    }

    $Code.Add('')
    $Code.Add('        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap')

    if ($AllModels.QueryParameters | Where-Object { $_.ApiName -eq 'filter[thruTime]' }) {
        $Code.Add('')
        $Code.Add('        # The API requires filter[thruTime] even though the spec defines it as optional (it defaults to the current time)')
        $Code.Add('        if ($UriParameters.ContainsKey(''filter[fromTime]'') -and -not $UriParameters.ContainsKey(''filter[thruTime]'')) { $UriParameters[''filter[thruTime]''] = [datetime]::UtcNow }')
    }
    $Code.Add('')
    $Code.Add('        $InvokeParams = @{')
    $Code.Add("            Method      = '$($Unit.Method)'")
    $Code.Add('            ResourceUri = $ResourceUri')
    $Code.Add('            UriFilter   = $UriParameters')
    if ($AnyCursor) { $Code.Add('            AllResults  = $AllResults') }
    $Code.Add('        }')
    $Code.Add('')
    $Code.Add('        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false')
    $Code.Add('        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false')
    $Code.Add('')

    if ($Unit.IsWrite) {
        $Code.Add("        if (`$PSCmdlet.ShouldProcess(`$ResourceUri, `"`$(`$MyInvocation.MyCommand.Name) ($($Unit.Method))`")) {")
        $Code.Add('            return Invoke-AuvikRequest @InvokeParams')
        $Code.Add('        }')
    }
    elseif ($Unit.IsBoolean) {
        $Code.Add('        try {')
        $Code.Add('            $null = Invoke-AuvikRequest @InvokeParams -ErrorAction Stop -WarningAction SilentlyContinue')
        $Code.Add('            return $true')
        $Code.Add('        }')
        $Code.Add('        catch { return $false }')
    }
    else {
        $Code.Add('        return Invoke-AuvikRequest @InvokeParams')
    }

    $Code.Add('')
    $Code.Add('    }')
    $Code.Add('')
    $Code.Add('    end {}')
    $Code.Add('')
    $Code.Add('}')

    # Aliases are created at script level so that they work in the source & the built module
    if ($Aliases.Count) { $Code.Add('') }
    foreach ($Alias in $Aliases) { $Code.Add("Set-Alias -Name '$Alias' -Value '$FunctionName'") }

    #EndRegion  [ Code ]

    $FolderPath = Join-Path -Path $PublicPath -ChildPath $Unit.Category
    $FilePath   = Join-Path -Path $FolderPath -ChildPath "$FunctionName.ps1"

    if ($PSCmdlet.ShouldProcess($FilePath, 'Create public function')) {
        if (-not (Test-Path -Path $FolderPath)) { New-Item -Path $FolderPath -ItemType Directory > $null }
        [System.IO.File]::WriteAllText($FilePath, (($Code -join "`n") + "`n"), $Utf8NoBom)
    }

    $GeneratedFiles.Add($FilePath)

}

#EndRegion  [ Generate Functions ]

#Region     [ Manifest & CSV ]

Write-Verbose " - (5/5) - $(Get-Date -Format MM-dd-HH:mm) - Updating module manifest & endpoints.csv"

$ModuleFileEntries = @(
    foreach ($File in $PrivateFiles) { 'Private/' + (($File.FullName.Substring($ModulePath.Length + 1)) -replace '^Private[\\/]', '' -replace '\\', '/') }
    foreach ($File in (Sort-Ordinal -Items @($GeneratedFiles) -Key { $_ -replace '\\', '/' })) { 'Public/' + (($File.Substring($PublicPath.Length + 1)) -replace '\\', '/') }
)

$NestedModules      = ($ModuleFileEntries | ForEach-Object { "        '$_'" }) -join ",`n"
$ExportedFunctions  = (@(Sort-Ordinal -Items @((@($PrivateFunctions.Name) + @($Units.Function) | Select-Object -Unique))) | ForEach-Object { "        '$_'" }) -join ",`n"

$PrivateAliases = foreach ($File in $PrivateFiles) {
    $Ast = [System.Management.Automation.Language.Parser]::ParseFile($File.FullName, [ref]$null, [ref]$null)
    $AliasCommands = $Ast.FindAll({ param($Node) $Node -is [System.Management.Automation.Language.CommandAst] -and $Node.GetCommandName() -in 'Set-Alias', 'New-Alias' }, $false)
    foreach ($Command in $AliasCommands) {
        $Bound = [System.Management.Automation.Language.StaticParameterBinder]::BindCommand($Command)
        if ($Bound.BoundParameters.ContainsKey('Name')) { $Bound.BoundParameters['Name'].ConstantValue }
    }
}

$AllAliases         = @(@($PrivateAliases) + @($Units.Aliases) | Where-Object { $_ } | Select-Object -Unique)
$ExportedAliases    = (@(Sort-Ordinal -Items $AllAliases) | ForEach-Object { "        '$_'" }) -join ",`n"

if ($PSCmdlet.ShouldProcess($ManifestPath, 'Update NestedModules, FunctionsToExport, & AliasesToExport')) {

    $Manifest = [System.IO.File]::ReadAllText($ManifestPath)

    $Manifest = [regex]::Replace($Manifest, '(?s)    NestedModules = @\(.*?\r?\n    \)', [System.Text.RegularExpressions.MatchEvaluator]{ "    NestedModules = @(`n$NestedModules`n    )" })
    $Manifest = [regex]::Replace($Manifest, '(?s)    FunctionsToExport = @\(.*?\r?\n    \)', [System.Text.RegularExpressions.MatchEvaluator]{ "    FunctionsToExport = @(`n$ExportedFunctions`n    )" })
    $Manifest = [regex]::Replace($Manifest, '(?s)    AliasesToExport = @\(.*?\r?\n    \)', [System.Text.RegularExpressions.MatchEvaluator]{ "    AliasesToExport = @(`n$ExportedAliases`n    )" })

    [System.IO.File]::WriteAllText($ManifestPath, $Manifest, $Utf8NoBom)

}

# endpoints.csv
$CsvRows = [System.Collections.Generic.List[object]]::new()

foreach ($Function in (Sort-Ordinal -Items @($PrivateFunctions) -Key { $_.File.FullName -replace '\\', '/' })) {

    $Method = switch -Regex ($Function.Name) {
        '^(Get|Test|Invoke|ConvertTo|Import)-'          { 'GET' }
        '^Remove-'                                      { 'DELETE' }
        default                                         { 'PUT' }
    }

    $CsvRows.Add([PSCustomObject]@{ Category = 'Internal'; EndpointUri = ''; Method = $Method; Function = $Function.Name; Example = 'N/A'; Complete = 'Yes'; Notes = '' })

}

foreach ($Endpoint in (Sort-Ordinal -Items @($Endpoints) -Key { "$($_.Path)|$(@('GET','POST','PUT','PATCH','DELETE').IndexOf($_.Method))" })) {

    $Notes = [System.Collections.Generic.List[string]]::new()

    if ($Endpoint.SetName) { $Notes.Add("Parameter set $($Endpoint.SetName)") }
    if ($Endpoint.IsWrite) { $Notes.Add('Write') }

    $Example = if ($ExampleMap.ContainsKey($Endpoint.Function)) { $ExampleMap[$Endpoint.Function] } else { '' }

    $CsvRows.Add([PSCustomObject]@{ Category = $Endpoint.Category; EndpointUri = $Endpoint.Path; Method = $Endpoint.Method; Function = $Endpoint.Function; Example = $Example; Complete = 'Yes'; Notes = ($Notes -join '; ') })

}

if ($PSCmdlet.ShouldProcess($CsvPath, 'Update endpoints.csv')) {
    # LF line endings so that the file is identical on Windows, Linux, & macOS
    $CsvText = ($CsvRows | ConvertTo-Csv -NoTypeInformation -UseQuotes AsNeeded) -join "`n"
    [System.IO.File]::WriteAllText($CsvPath, $CsvText + "`n", $Utf8NoBom)
}

#EndRegion  [ Manifest & CSV ]

Write-Verbose ''
Write-Verbose "END - $(Get-Date -Format yyyy-MM-dd-HH:mm)"
Write-Verbose ''

$TimeToComplete = New-TimeSpan -Start $StartDate -End (Get-Date)
Write-Verbose 'Time to complete'
Write-Verbose ($TimeToComplete | Select-Object * -ExcludeProperty Ticks,Total*,Milli* | Out-String)

$MergedCount    = @($Units | Where-Object { $_.Members.Count -gt 1 }).Count
$WriteCount     = @($Units | Where-Object IsWrite).Count

Write-Output "Generated [ $($Units.Count) ] functions ([ $WriteCount ] write, [ $MergedCount ] combined) across [ $(($Units.Category | Select-Object -Unique).Count) ] categories, tracked [ $($Endpoints.Count) ] endpoints"
