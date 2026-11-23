<#
.NOTES
    Copyright 1990-2025 Celerium

    NAME: Public.Tests.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        EMAIL:   celerium@Celerium.org

.SYNOPSIS
    Pester tests for every public function of the module that are driven by docs\endpoints.csv & docs\Auvik-v1.json

.DESCRIPTION
    A test case is created for every endpoint in docs\endpoints.csv. The expectations (URI path, HTTP method, parameter
    names, mandatory parameters, enums, & types) are calculated from the OpenAPI spec of the Auvik API, so the tests
    fail when the generated functions & the spec drift apart

    Invoke-WebRequest is mocked (and every other request throws), no request is ever sent

.PARAMETER ModuleName
    The name of the local module to import

    Default value: Celerium.Auvik

.PARAMETER Version
    The version of the local module to import

.PARAMETER BuildTarget
    Which version of the module to run tests against

    Allowed values:
        'built', 'notBuilt'

.EXAMPLE
    Invoke-Pester -Path .\Public.Tests.ps1

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
#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='6.0.0' }

#Region     [ Parameters ]

#Available in Discovery & Run
[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$ModuleName = 'Celerium.Auvik',

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Version,

    [Parameter(Mandatory = $true)]
    [ValidateSet('built', 'notBuilt')]
    [string]$BuildTarget
)

#EndRegion  [ Parameters ]

#Region     [ Prerequisites ]

    BeforeDiscovery {

        $TestsPath = $PSScriptRoot
        while ($TestsPath -and -not (Test-Path -Path (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1'))) { $TestsPath = Split-Path -Path $TestsPath -Parent }
        . (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1')

        $PesterTestName = (Get-Item -Path $PSCommandPath).Name

        $Spec           = Get-TestSpec
        $EndpointData   = Get-TestEndpointData

        $Endpoints = @(foreach ($Row in $EndpointData.Implemented) {

            $Model = Get-TestEndpointModel -Spec $Spec -Row $Row

            if ($Model) { $Model.SpecFound = $true }
            else {
                $Model = $Row.Clone()
                $Model.SpecFound        = $false
                $Model.ExpectedPath     = $Row.EndpointUri
                $Model.PathParameters   = @()
                $Model.QueryParameters  = @()
            }

            $Model.EnumParameters   = @($Model.QueryParameters | Where-Object { $_.Enum.Count -gt 0 })
            $Model.Verb             = switch ($Row.HttpMethod) { 'GET' { 'Get' } 'POST' { 'Send' } 'DELETE' { 'Remove' } default { 'Set' } }
            $Model.SetName          = if ($Row.ParameterSet) { $Row.ParameterSet } else { '__AllParameterSets' }
            $Model.HasCursor        = [bool]($Model.QueryParameters | Where-Object { $_.ApiName -eq 'page[after]' })

            # Tests that only apply to some endpoints use a list that is empty for the other endpoints
            $Model.MergedCases     = @(if ($Row.ParameterSet) { @{ MergedSet = $Row.ParameterSet } })
            $Model.WriteCases      = @(if ($Row.IsWrite) { @{ WriteMethod = $Row.HttpMethod } })
            $Model.QueryCases      = @(if ($Model.QueryParameters.Count -gt 0) { @{ QueryCount = $Model.QueryParameters.Count } })

            $Model

        })

    }

    BeforeAll {

        $TestsPath = $PSScriptRoot
        while ($TestsPath -and -not (Test-Path -Path (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1'))) { $TestsPath = Split-Path -Path $TestsPath -Parent }
        . (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1')

        Import-TestModule -ModuleName $ModuleName -Version $Version -BuildTarget $BuildTarget
        Add-TestHttpGuard -MockModule (Get-TestMockModuleName -CommandName 'Invoke-AuvikRequest') -SkipWebRequest

        $Module     = Get-Module -Name $ModuleName
        $MockModule = Get-TestMockModuleName -CommandName 'Get-AuvikDeviceInfo'

        # The mock bodies run in the module, so they share data with the tests through global variables
        # The variables start with AuvikTest so Remove-TestState cleans them up
        Mock Invoke-WebRequest -ModuleName $MockModule -MockWith {
            $global:AuvikTestCalls.Add([PSCustomObject]@{ Method = $Method; Uri = $Uri; Headers = $Headers; Body = $Body })
            return (ConvertTo-AuvikTestWebResponse -InputObject ([PSCustomObject]@{ data = @(); links = $null }))
        }

        $CommonParameters = [System.Management.Automation.PSCmdlet]::CommonParameters + [System.Management.Automation.PSCmdlet]::OptionalCommonParameters

        function New-TestQueryValue {
            # Creates a value for a parameter & the string the API is expected to receive
            param (
                [System.Management.Automation.ParameterMetadata]$Parameter,
                [string]$ApiName
            )

            $Type = $Parameter.ParameterType

            if ($Type -eq [string[]])   { return @{ Value = [string[]]@('first', 'second'); Expected = 'first,second' } }
            if ($Type -eq [datetime]) {

                $Date = [datetime]::new(2025, 1, 2, 3, 4, 5, [System.DateTimeKind]::Utc)
                $Expected = if ($ApiName -match '(fromDate|thruDate)') { '2025-01-02' } else { '2025-01-02T03:04:05.000Z' }

                return @{ Value = $Date; Expected = $Expected }

            }

            $Value = Get-TestParameterValue -Parameter $Parameter
            $Expected = if ($Type -eq [bool]) { "$Value".ToLowerInvariant() } else { "$Value" }

            return @{ Value = $Value; Expected = $Expected }
        }

        function Get-TestMandatoryParameter {
            # Values for the path parameters & the required query parameters of an endpoint
            param ($Endpoint, $Command)

            $Parameters = @{}

            foreach ($PathParameter in $Endpoint.PathParameters) { $Parameters[$PathParameter.PsName] = $PathParameter.Value }

            foreach ($QueryParameter in ($Endpoint.QueryParameters | Where-Object { $_.Required })) {
                $Parameters[$QueryParameter.PsName] = (New-TestQueryValue -Parameter $Command.Parameters[$QueryParameter.PsName] -ApiName $QueryParameter.ApiName).Value
            }

            # Write endpoints ask for a confirmation
            if ($Endpoint.IsWrite) { $Parameters['Confirm'] = $false }

            return $Parameters
        }

    }

    AfterAll {
        Remove-TestModule -ModuleName $ModuleName
    }

#EndRegion  [ Prerequisites ]

Describe "Testing the [ $BuildTarget ] version of [ $ModuleName ] with [ $PesterTestName ]" {

    BeforeEach {
        Set-TestCredential
        $global:AuvikTestCalls = [System.Collections.Generic.List[object]]::new()
    }

    Describe "[ <FunctionName> ] <HttpMethod> <EndpointUri>" -ForEach $Endpoints {

        BeforeAll {

            $Command       = Get-Command -Name $FunctionName -ErrorAction SilentlyContinue
            $SetInfo       = if ($Command) { $Command.ParameterSets | Where-Object { $_.Name -eq $SetName } | Select-Object -First 1 }
            $EndpointModel = @{ PathParameters = $PathParameters; QueryParameters = $QueryParameters; IsWrite = $IsWrite }

        }

        It "Is an endpoint of the Auvik spec" {
            $SpecFound | Should -BeTrue -Because "[ $HttpMethod $EndpointUri ] should exist in docs\Auvik-v1.json"
        }

        It "Exists & is exported" {
            $Command | Should -Not -BeNullOrEmpty
            $Module.ExportedFunctions.Keys | Should -Contain $FunctionName
        }

        It "Uses the [ $Verb ] verb for the [ $HttpMethod ] method" {
            ($FunctionName -split '-')[0] | Should -Be $Verb
        }

        It "Has the [ $SetName ] parameter set" {
            $SetInfo | Should -Not -BeNullOrEmpty

            if (-not $ParameterSet) { @($Command.ParameterSets).Count | Should -Be 1 }
            else { $Command.ParameterSets.Name | Should -Contain $ParameterSet }
        }

        It "Uses [ List ] as the default parameter set of merged functions" -ForEach $MergedCases -AllowNullOrEmptyForEach {
            $Command.DefaultParameterSet | Should -Be 'List'
        }

        It "Has exactly the parameters of the spec in the parameter set" {

            $Expected   = @($PathParameters | ForEach-Object { $_.PsName }) + @($QueryParameters | ForEach-Object { $_.PsName })
            if ($HasCursor) { $Expected += 'AllResults' }

            $Actual     = @($SetInfo.Parameters | Where-Object { $_.Name -notin $CommonParameters } | ForEach-Object { $_.Name })

            $Missing    = @($Expected | Where-Object { $_ -notin $Actual })
            $Extra      = @($Actual | Where-Object { $_ -notin $Expected })

            $Missing | Should -BeNullOrEmpty -Because "[ $($Missing -join ', ') ] is in the spec but not a parameter of the function"
            $Extra | Should -BeNullOrEmpty -Because "[ $($Extra -join ', ') ] is a parameter of the function but is not in the spec"

        }

        It "Has a mandatory [ <PsName> ] path parameter" -ForEach $PathParameters -AllowNullOrEmptyForEach {
            $Parameter = $SetInfo.Parameters | Where-Object { $_.Name -eq $PsName }
            $Parameter | Should -Not -BeNullOrEmpty
            $Parameter.IsMandatory | Should -BeTrue
            $Command.Parameters[$PsName].ParameterType | Should -Be ([string])
        }

        It "Has a [ <PsName> ] parameter for the [ <ApiName> ] query parameter with the same mandatory setting as the spec" -ForEach $QueryParameters -AllowNullOrEmptyForEach {
            $Parameter = $SetInfo.Parameters | Where-Object { $_.Name -eq $PsName }
            $Parameter | Should -Not -BeNullOrEmpty
            $Parameter.IsMandatory | Should -Be $Required
        }

        It "Has a type for [ <PsName> ] that matches the [ <SpecType> ] type of the spec" -ForEach $QueryParameters -AllowNullOrEmptyForEach {

            $Type = $Command.Parameters[$PsName].ParameterType

            # The spec defines some dates as a boolean or a string, a parameter is a date when the name ends with one of these words
            $ApiLeaf = (($ApiName -replace '\]$', '') -split '\[') | Select-Object -Last 1
            $IsDate  = ($ApiName -notlike 'page[[]*') -and ($ApiLeaf -cmatch '(After|Before|Since|Date|Time)$')

            if ($IsDate) { $Type | Should -Be ([datetime]) }
            else {
                switch ($SpecType) {
                    'boolean'   { $Type | Should -Be ([bool]) }
                    'number'    { $Type | Should -Be ([int64]) }
                    'integer'   { $Type | Should -Be ([int64]) }
                    default     { $Type | Should -BeIn @([string], [string[]]) }
                }
            }

        }

        It "Has the values of the spec as the ValidateSet of [ <PsName> ]" -ForEach $QueryParameters -AllowNullOrEmptyForEach {

            $ValidateSet    = $Command.Parameters[$PsName].Attributes | Where-Object { $_ -is [System.Management.Automation.ValidateSetAttribute] } | Select-Object -First 1
            $Actual         = if ($ValidateSet) { @($ValidateSet.ValidValues | Sort-Object) } else { @() }

            $Actual | Should -Be @($Enum | Sort-Object)

        }

        It "Rejects a value that is not in the spec for [ <PsName> ]" -ForEach $EnumParameters -AllowNullOrEmptyForEach {

            $Parameters = Get-TestMandatoryParameter -Endpoint $EndpointModel -Command $Command
            $Parameters[$PsName] = 'not-a-valid-value'

            { & $FunctionName @Parameters } | Should -Throw
            $global:AuvikTestCalls.Count | Should -Be 0

        }

        It "Sends a [ $HttpMethod ] request to the expected path with only the mandatory parameters" {

            $Parameters = Get-TestMandatoryParameter -Endpoint $EndpointModel -Command $Command
            $null = & $FunctionName @Parameters

            $global:AuvikTestCalls.Count | Should -Be 1
            $Call = $global:AuvikTestCalls[0]

            $Call.Method | Should -Be $HttpMethod
            $Call.Uri.Host | Should -Be 'auvikapi.us1.my.auvik.com'
            $Call.Uri.AbsolutePath | Should -Be "/v1$ExpectedPath"

            $Required = @($QueryParameters | Where-Object { $_.Required } | ForEach-Object { $_.ApiName })

            # filter[thruTime] is required by the API although the spec defines it as optional, the functions send the current time when a fromTime is used
            if ($Required -contains 'filter[fromTime]' -and ($QueryParameters | Where-Object { $_.ApiName -eq 'filter[thruTime]' })) { $Required += 'filter[thruTime]' }

            @((Get-TestQuery -Uri $Call.Uri).Keys | Sort-Object) | Should -Be @($Required | Sort-Object)

        }

        It "Sends the Basic authentication header" {

            $Parameters = Get-TestMandatoryParameter -Endpoint $EndpointModel -Command $Command
            $null = & $FunctionName @Parameters

            $Expected = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes('user@example.com:fake-api-key'))
            $global:AuvikTestCalls[0].Headers['Authorization'] | Should -BeExactly $Expected

        }

        It "Sends [ <PsName> ] as the [ <ApiName> ] query parameter" -ForEach $QueryParameters -AllowNullOrEmptyForEach {

            $Parameters = Get-TestMandatoryParameter -Endpoint $EndpointModel -Command $Command
            $TestValue  = New-TestQueryValue -Parameter $Command.Parameters[$PsName] -ApiName $ApiName
            $Parameters[$PsName] = $TestValue.Value

            $null = & $FunctionName @Parameters

            $global:AuvikTestCalls.Count | Should -Be 1
            $Query = Get-TestQuery -Uri $global:AuvikTestCalls[0].Uri

            $Query.Keys | Should -Contain $ApiName
            $Query[$ApiName] | Should -BeExactly $TestValue.Expected

        }

        It "Sends every query parameter together" -ForEach $QueryCases -AllowNullOrEmptyForEach {

            $Parameters = Get-TestMandatoryParameter -Endpoint $EndpointModel -Command $Command
            $Expected   = @{}

            foreach ($QueryParameter in $QueryParameters) {
                $TestValue = New-TestQueryValue -Parameter $Command.Parameters[$QueryParameter.PsName] -ApiName $QueryParameter.ApiName
                $Parameters[$QueryParameter.PsName] = $TestValue.Value
                $Expected[$QueryParameter.ApiName] = $TestValue.Expected
            }

            $null = & $FunctionName @Parameters
            $Query = Get-TestQuery -Uri $global:AuvikTestCalls[0].Uri

            $Query.Count | Should -Be $Expected.Count
            foreach ($ApiName in $Expected.Keys) { $Query[$ApiName] | Should -BeExactly $Expected[$ApiName] }

        }

        It "Does not send a request with -WhatIf" -ForEach $WriteCases -AllowNullOrEmptyForEach {

            $Parameters = Get-TestMandatoryParameter -Endpoint $EndpointModel -Command $Command

            $null = & $FunctionName @Parameters -WhatIf *> $null

            $global:AuvikTestCalls.Count | Should -Be 0

        }

        It "Supports -WhatIf & -Confirm only for write endpoints" {

            $SupportsShouldProcess = $Command.Parameters.ContainsKey('WhatIf') -and $Command.Parameters.ContainsKey('Confirm')
            $SupportsShouldProcess | Should -Be ([bool]$IsWrite)

        }

    }

}
