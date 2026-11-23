# Shared helpers for the Celerium.Auvik Pester tests
# This file is dot-sourced by each test file & is not a test file itself

function Get-TestRootPath {
    # The tests folder lives directly under the repository root
    return (Split-Path -Path $PSScriptRoot -Parent)
}

function Get-TestModulePath {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ModuleName,

        [Parameter(Mandatory = $true)]
        [string]$Version,

        [Parameter(Mandatory = $true)]
        [ValidateSet('built', 'notBuilt')]
        [string]$BuildTarget
    )

    $RootPath = Get-TestRootPath

    switch ($BuildTarget) {
        'built'     { return Join-Path -Path (Join-Path -Path (Join-Path -Path $RootPath -ChildPath 'build') -ChildPath $ModuleName) -ChildPath $Version }
        'notBuilt'  { return Join-Path -Path $RootPath -ChildPath $ModuleName }
    }
}

function Get-TestMockModuleName {
    <#
        Returns the name of the module that defines a command, this is the value to use with [ Mock -ModuleName ]

        Nested .ps1 files of the notBuilt module are dot-sourced into the root module & the built module is a single
        psm1, so both targets resolve to the root module. Resolving it per command keeps the tests correct
        if the module layout ever changes. Aliases are resolved to the command they point at
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$CommandName
    )

    $Command = Get-Command -Name $CommandName -ErrorAction Stop | Select-Object -First 1
    if ($Command.CommandType -eq 'Alias') { $Command = $Command.ResolvedCommand }

    return $Command.ModuleName
}

function Remove-TestState {
    # Removes the global variables the module & the tests create. The module variables are read only, so they need -Force
    foreach ($Name in 'AuvikModuleApiKey', 'AuvikModuleUserName', 'AuvikModuleBaseURI', 'AuvikJSONConversionDepth') {
        Remove-Variable -Name $Name -Scope Global -Force -ErrorAction SilentlyContinue
    }

    # Debug variables such as [ InvokeAuvikRequestParameters ], [ GetAuvikDeviceInfoParametersQuery ], & the tests own variables
    $DebugVariables = @(Get-Variable -Scope Global -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^\w*Auvik\w*Parameters(Query)?$' -or $_.Name -match '^AuvikTest\w*$' })
    foreach ($DebugVariable in $DebugVariables) {
        Remove-Variable -Name $DebugVariable.Name -Scope Global -Force -ErrorAction SilentlyContinue
    }
}

function Reset-TestModuleState {
    # Puts the module in a known state: the default base URI & no credentials
    # Any settings loaded from a configuration file of the user running the tests are discarded
    Remove-TestState
    Add-AuvikBaseURI
    Set-Variable -Name 'AuvikJSONConversionDepth' -Value 100 -Scope Global -Force
}

function Set-TestCredential {
    # Fake credentials, nothing is ever sent anywhere as every request is mocked
    param (
        [string]$Username = 'user@example.com',
        [string]$ApiKey = 'fake-api-key'
    )

    Add-AuvikBaseURI
    Add-AuvikAPIKey -Username $Username -ApiKey $ApiKey
}

function Import-TestModule {
    <#
        Imports the module that is being tested

        Environment variables used to auto configure the module are removed during the import so that
        unit tests always start from a clean state, unless -KeepEnvironment is used (live tests)

        Unless -KeepEnvironment is used the module state is also reset after the import so that a
        configuration file of the user running the tests can not influence the tests
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$ModuleName,

        [Parameter(Mandatory = $true)]
        [string]$Version,

        [Parameter(Mandatory = $true)]
        [ValidateSet('built', 'notBuilt')]
        [string]$BuildTarget,

        [switch]$KeepEnvironment
    )

    $ModulePath = Get-TestModulePath -ModuleName $ModuleName -Version $Version -BuildTarget $BuildTarget
    $ModulePsd1 = Join-Path -Path $ModulePath -ChildPath "$ModuleName.psd1"

    if (Get-Module -Name $ModuleName) { Remove-Module -Name $ModuleName -Force }

    $Saved = @{}
    if (-not $KeepEnvironment) {
        foreach ($Name in 'AUVIK_BASE_URI', 'AUVIK_USERNAME', 'AUVIK_API_KEY') {
            $Saved[$Name] = [Environment]::GetEnvironmentVariable($Name)
            [Environment]::SetEnvironmentVariable($Name, $null)
        }
    }

    try     { Import-Module -Name $ModulePsd1 -Force -ErrorAction Stop *> $null }
    finally { foreach ($Name in $Saved.Keys) { [Environment]::SetEnvironmentVariable($Name, $Saved[$Name]) } }

    if (-not $KeepEnvironment) { Reset-TestModuleState }
}

function Add-TestHttpGuard {
    <#
        Fallback mocks for the unit tests: a request that is not mocked by the test throws instead of
        reaching a real API. Call it from a BeforeAll block after Import-TestModule

        Use -SkipWebRequest in a test file that mocks Invoke-WebRequest itself (the module sends its requests with it)
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$MockModule,

        [switch]$SkipWebRequest
    )

    Mock Invoke-RestMethod -ModuleName $MockModule -MockWith { throw "Unit tests must not send real HTTP requests [ Invoke-RestMethod $Uri ]" }

    if (-not $SkipWebRequest) {
        Mock Invoke-WebRequest -ModuleName $MockModule -MockWith { throw "Unit tests must not send real HTTP requests [ Invoke-WebRequest $Uri ]" }
    }
}

function global:ConvertTo-AuvikTestWebResponse {
    <#
        Creates the response object Invoke-WebRequest -UseBasicParsing returns. The body is the object as UTF-8 json
        (or the string as it is). An object that already is a web response is returned unchanged. The function is
        global because the mock bodies run in the module
    #>
    param (
        $InputObject,

        [int]$StatusCode = 200,

        [hashtable]$Headers = @{}
    )

    if ($null -ne $InputObject -and $InputObject.PSObject.Properties['RawContentStream']) { return $InputObject }

    $ResponseHeaders = @{ 'Content-Type' = 'application/vnd.api+json' }
    foreach ($Key in $Headers.Keys) { $ResponseHeaders[$Key] = $Headers[$Key] }

    $Body = if ($null -eq $InputObject) { '' }
            elseif ($InputObject -is [string]) { $InputObject }
            else { ConvertTo-Json -InputObject $InputObject -Depth 20 -Compress }

    return [PSCustomObject]@{
        StatusCode          = $StatusCode
        Headers             = $ResponseHeaders
        RawContentStream    = [System.IO.MemoryStream]::new([System.Text.Encoding]::UTF8.GetBytes($Body))
    }
}

function Remove-TestModule {
    param ([string]$ModuleName)

    Remove-TestState

    if (Get-Module -Name $ModuleName) { Remove-Module -Name $ModuleName -Force }
}

function Add-FakeHttpException {
    # Windows PowerShell & PowerShell Core use different exception types, this type works for both
    if (-not ('FakeHttpException' -as [type])) {
        Add-Type -TypeDefinition @'
public class FakeHttpException : System.Exception
{
    public object Response { get; set; }
    public FakeHttpException(string message) : base(message) { }
}
'@
    }
}

function New-TestHttpError {
    # Creates the error a failed Invoke-WebRequest call throws. The detail is the json body of the response
    param (
        [Parameter(Mandatory = $true)]
        [int]$StatusCode,

        [string]$Detail,

        # The Location header of a redirect, as PowerShell 7 reports it (HttpResponseHeaders.Location)
        [string]$Location
    )

    Add-FakeHttpException

    $Exception = [FakeHttpException]::new("Response status code does not indicate success: $StatusCode.")
    $Exception.Response = [PSCustomObject]@{ StatusCode = $StatusCode }
    if ($Location) { $Exception.Response | Add-Member -NotePropertyName Headers -NotePropertyValue ([PSCustomObject]@{ Location = [uri]$Location }) }

    $ErrorRecord = [System.Management.Automation.ErrorRecord]::new($Exception, 'FakeHttpError', [System.Management.Automation.ErrorCategory]::InvalidResult, $null)
    if ($Detail) { $ErrorRecord.ErrorDetails = [System.Management.Automation.ErrorDetails]::new($Detail) }

    return $ErrorRecord
}

function Get-TestQuery {
    # Converts the query string of a uri to a hashtable of decoded keys & values
    # The order of the query string & the casing of the percent encoding are not stable between PowerShell versions
    param (
        [Parameter(Mandatory = $true)]
        [uri]$Uri
    )

    $Query = @{}

    foreach ($Pair in ($Uri.Query.TrimStart('?') -split '&' | Where-Object { $_ })) {

        $Parts = $Pair -split '=', 2
        $Key   = [uri]::UnescapeDataString($Parts[0].Replace('+', ' '))
        $Value = if ($Parts.Count -gt 1) { [uri]::UnescapeDataString($Parts[1].Replace('+', ' ')) } else { '' }

        $Query[$Key] = $Value

    }

    return $Query
}

function Test-IsWindowsPlatform {
    return ($PSEdition -eq 'Desktop' -or $IsWindows)
}

function Get-TestScriptAst {
    # Parses a script & returns the abstract syntax tree
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $ParseErrors = $null
    $Tokens      = $null
    $Ast         = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$Tokens, [ref]$ParseErrors)

    return [PSCustomObject]@{
        Ast         = $Ast
        ParseErrors = @($ParseErrors)
    }
}

function Get-TestModuleFile {
    # Every script file of the source module (Private & Public)
    param (
        [Parameter(Mandatory = $true)]
        [string]$ModuleName
    )

    $ModuleRoot = Join-Path -Path (Get-TestRootPath) -ChildPath $ModuleName

    return @(foreach ($Folder in 'Private', 'Public') {
        Get-ChildItem -Path (Join-Path -Path $ModuleRoot -ChildPath $Folder) -Filter *.ps1 -File -Recurse
    })
}

function Get-TestEndpointData {
    # Reads the endpoints.csv tracking file used to generate the public functions & documentation
    $CsvPath = Join-Path -Path (Join-Path -Path (Get-TestRootPath) -ChildPath 'docs') -ChildPath 'endpoints.csv'
    $Rows    = @(Import-Csv -Path $CsvPath)

    $Implemented = @($Rows | Where-Object { $_.Category -ne 'Internal' -and $_.Function } | ForEach-Object {

        $IsWrite = $_.Notes -like '*Write*'

        # Pester only exposes the keys of hashtables as variables in -ForEach tests
        @{
            Category        = $_.Category
            FunctionName    = $_.Function
            EndpointUri     = $_.EndpointUri
            HttpMethod      = $_.Method
            IsWrite         = $IsWrite
            ParameterSet    = if ($_.Notes -like '*Parameter set ById*') { 'ById' } elseif ($_.Notes -like '*Parameter set List*') { 'List' } else { '' }
        }
    })

    [PSCustomObject]@{
        Implemented     = $Implemented
        NotImplemented  = @($Rows | Where-Object { $_.Category -ne 'Internal' -and -not $_.Function })
        Internal        = @($Rows | Where-Object { $_.Category -eq 'Internal' })
        Rows            = $Rows
    }
}

function ConvertTo-TestPascalCase {
    # Same conversion that build\New-PublicFunctions.ps1 uses: filter[deviceType] -> FilterDeviceType
    param ([string]$Text)

    $Parts = $Text -split '[^A-Za-z0-9]+' | Where-Object { $_ }
    return -join ($Parts | ForEach-Object { $_.Substring(0, 1).ToUpper() + $_.Substring(1) })
}

function Get-TestSpec {
    # Reads the OpenAPI spec of the Auvik API
    $SpecPath = Join-Path -Path (Join-Path -Path (Get-TestRootPath) -ChildPath 'docs') -ChildPath 'Auvik-v1.json'
    return (Get-Content -Path $SpecPath -Raw -Encoding UTF8 | ConvertFrom-Json)
}

function Resolve-TestSpecRef {
    # Resolves a $ref such as #/components/schemas/DeviceTypeSchema
    param ($Spec, $Node)

    $Depth = 0
    while ($Node -and $Node.PSObject.Properties['$ref'] -and $Depth -lt 10) {
        $Target = $Spec
        foreach ($Part in (($Node.'$ref' -replace '^#/', '') -split '/')) { $Target = $Target.$Part }
        $Node = $Target
        $Depth++
    }

    return $Node
}

function Get-TestSpecEndpoint {
    # Every path & method of the spec. The leading /v1 of the spec paths is removed as it is part of the base URI
    param ($Spec)

    foreach ($PathProperty in $Spec.paths.PSObject.Properties) {

        foreach ($MethodProperty in $PathProperty.Value.PSObject.Properties) {

            $Path = $PathProperty.Name -replace '^/v1', ''

            [PSCustomObject]@{
                Path        = $Path
                Method      = $MethodProperty.Name.ToUpperInvariant()
                Operation   = $MethodProperty.Value
            }

        }

    }
}

function Get-TestEndpointModel {
    <#
        Combines a row of endpoints.csv with the operation of the spec into everything needed to test a function

        The PowerShell parameter names follow the same rules as build\New-PublicFunctions.ps1: the PascalCase of the API
        name, with the suffix [ Value ] when it collides with a common parameter & the suffix [ Filter ] when it
        collides with a path parameter
    #>
    param (
        $Spec,
        [Parameter(Mandatory = $true)]
        [hashtable]$Row
    )

    $Reserved = 'Verbose', 'Debug', 'ErrorAction', 'WarningAction', 'InformationAction', 'ErrorVariable', 'WarningVariable', 'InformationVariable', 'OutVariable', 'OutBuffer', 'PipelineVariable', 'ProgressAction', 'WhatIf', 'Confirm', 'AllResults',
                'Input', 'Args', 'This', 'Error', 'Host', 'Home', 'Pid', 'Pwd', 'Event', 'Sender', 'Matches', 'Profile', 'ForEach', 'Switch', 'PSItem', 'Null', 'True', 'False', 'Headers', 'Data'

    $Endpoint = Get-TestSpecEndpoint -Spec $Spec | Where-Object { $_.Path -eq $Row.EndpointUri -and $_.Method -eq $Row.HttpMethod } | Select-Object -First 1
    if (-not $Endpoint) { return $null }

    $PathParameters  = [System.Collections.Generic.List[object]]::new()
    $QueryParameters = [System.Collections.Generic.List[object]]::new()

    foreach ($SpecParameter in @($Endpoint.Operation.parameters)) {

        $SpecParameter  = Resolve-TestSpecRef -Spec $Spec -Node $SpecParameter
        $Schema         = Resolve-TestSpecRef -Spec $Spec -Node $SpecParameter.schema
        $Enum           = @($Schema.enum | Where-Object { $null -ne $_ } | ForEach-Object { "$_" })

        if ($SpecParameter.in -eq 'path') {
            $PathParameters.Add(@{ ApiName = $SpecParameter.name; PsName = (ConvertTo-TestPascalCase -Text $SpecParameter.name); Enum = $Enum })
        }
        elseif ($SpecParameter.in -eq 'query') {

            $PsName = ConvertTo-TestPascalCase -Text $SpecParameter.name
            if ($Reserved -contains $PsName) { $PsName = $PsName + 'Value' }

            $QueryParameters.Add(@{
                ApiName     = $SpecParameter.name
                PsName      = $PsName
                Required    = ($SpecParameter.required -eq $true)
                Enum        = $Enum
                SpecType    = $Schema.type
            })

        }

    }

    # A path parameter that the spec does not declare
    foreach ($PathName in ([regex]::Matches($Row.EndpointUri, '\{([^}]+)\}') | ForEach-Object { $_.Groups[1].Value })) {
        if (-not ($PathParameters | Where-Object { $_.ApiName -eq $PathName })) {
            $PathParameters.Add(@{ ApiName = $PathName; PsName = (ConvertTo-TestPascalCase -Text $PathName); Enum = @() })
        }
    }

    foreach ($QueryParameter in $QueryParameters) {
        if ($PathParameters | Where-Object { $_.PsName -ieq $QueryParameter.PsName }) { $QueryParameter.PsName = $QueryParameter.PsName + 'Filter' }
    }

    # Path values are different for every parameter so a swapped parameter is detected
    $ExpectedPath = $Row.EndpointUri
    foreach ($PathParameter in $PathParameters) {
        $PathParameter.Value = if ($PathParameter.Enum.Count -gt 0) { $PathParameter.Enum[0] } else { "sample-$($PathParameter.ApiName)" }
        $ExpectedPath = $ExpectedPath.Replace("{$($PathParameter.ApiName)}", [System.Uri]::EscapeDataString($PathParameter.Value))
    }

    return @{
        FunctionName    = $Row.FunctionName
        EndpointUri     = $Row.EndpointUri
        HttpMethod      = $Row.HttpMethod
        IsWrite         = $Row.IsWrite
        ParameterSet    = $Row.ParameterSet
        ExpectedPath    = $ExpectedPath
        PathParameters  = @($PathParameters)
        QueryParameters = @($QueryParameters)
    }
}

function Get-TestParameterValue {
    # Creates a value that is valid for a function parameter
    param (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.ParameterMetadata]$Parameter
    )

    $ValidateSet    = $Parameter.Attributes | Where-Object { $_ -is [System.Management.Automation.ValidateSetAttribute] } | Select-Object -First 1
    $ValidateRange  = $Parameter.Attributes | Where-Object { $_ -is [System.Management.Automation.ValidateRangeAttribute] } | Select-Object -First 1
    $Type           = $Parameter.ParameterType
    $ElementType    = if ($Type.IsArray) { $Type.GetElementType() } else { $Type }

    $Value = if ($ValidateSet)                                      { $ValidateSet.ValidValues[0] }
             elseif ($ElementType -eq [string])                     { 'abc' }
             elseif ($ElementType -eq [int64])                      { if ($ValidateRange) { $ValidateRange.MinRange } else { 5 } }
             elseif ($ElementType -eq [double])                     { 1.5 }
             elseif ($ElementType -eq [bool])                       { $true }
             elseif ($ElementType -eq [datetime])                   { [datetime]::new(2025, 1, 2, 3, 4, 5, [System.DateTimeKind]::Utc) }
             elseif ($ElementType -eq [hashtable])                  { @{ a = 1 } }
             else                                                   { 'abc' }

    if ($Type.IsArray) { return , @($Value) }
    return $Value
}

function Get-TestParameterSet {
    # Creates a hashtable of values for either the mandatory parameters or every parameter that is not a switch
    # of one parameter set of a command
    param (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.CommandInfo]$Command,

        [string]$ParameterSetName,

        [switch]$All
    )

    $Common = [System.Management.Automation.PSCmdlet]::CommonParameters + [System.Management.Automation.PSCmdlet]::OptionalCommonParameters
    $Set    = @{}

    $SetInfo = if ($ParameterSetName -and $Command.ParameterSets.Count -gt 1) { $Command.ParameterSets | Where-Object { $_.Name -eq $ParameterSetName } | Select-Object -First 1 }
               elseif ($Command.DefaultParameterSet) { $Command.ParameterSets | Where-Object { $_.Name -eq $Command.DefaultParameterSet } | Select-Object -First 1 }
               else { $Command.ParameterSets | Select-Object -First 1 }

    foreach ($Parameter in $SetInfo.Parameters) {

        if ($Parameter.Name -in $Common -or $Parameter.ParameterType -eq [switch]) { continue }

        if ($All -or $Parameter.IsMandatory) { $Set[$Parameter.Name] = Get-TestParameterValue -Parameter $Command.Parameters[$Parameter.Name] }

    }

    return $Set
}
