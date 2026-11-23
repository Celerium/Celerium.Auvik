<#
.NOTES
    Copyright 1990-2025 Celerium

    NAME: Get-AuvikUriParameter.Tests.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        EMAIL:   celerium@Celerium.org

.SYNOPSIS
    Pester tests for the Get-AuvikUriParameter function

.DESCRIPTION
    Pester tests for the Get-AuvikUriParameter function

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
    Invoke-Pester -Path .\Get-AuvikUriParameter.Tests.ps1

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

        $PesterTestName = (Get-Item -Path $PSCommandPath).Name

    }

    BeforeAll {

        $TestsPath = $PSScriptRoot
        while ($TestsPath -and -not (Test-Path -Path (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1'))) { $TestsPath = Split-Path -Path $TestsPath -Parent }
        . (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1')

        Import-TestModule -ModuleName $ModuleName -Version $Version -BuildTarget $BuildTarget
        Add-TestHttpGuard -MockModule (Get-TestMockModuleName -CommandName 'Invoke-AuvikRequest')

        # Behaves like a public function: the bound parameters are translated to API query parameters
        function Test-UriParameter {
            [CmdletBinding()]
            param (
                [string]$FilterDeviceType,
                [string[]]$Tenants,
                [datetime]$FilterModifiedAfter,
                [bool]$FilterStateKnown,
                [string]$NotMapped
            )

            $NameMap = @{
                FilterDeviceType    = 'filter[deviceType]'
                Tenants             = 'tenants'
                FilterModifiedAfter = 'filter[modifiedAfter]'
                FilterStateKnown    = 'filter[stateKnown]'
            }

            Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap
        }

    }

    AfterAll {
        Remove-TestModule -ModuleName $ModuleName
    }

#EndRegion  [ Prerequisites ]

Describe "Testing the [ $BuildTarget ] version of [ $ModuleName ] with [ $PesterTestName ]" {

    Context "[ Get-AuvikUriParameter ] translating parameters" {

        It "Returns an empty hashtable when no parameter was bound" {
            $Result = Test-UriParameter
            $Result | Should -BeOfType [hashtable]
            $Result.Count | Should -Be 0
        }

        It "Translates a parameter name to the API query name" {
            $Result = Test-UriParameter -FilterDeviceType 'router'
            $Result.Count | Should -Be 1
            $Result['filter[deviceType]'] | Should -Be 'router'
        }

        It "Only returns the parameters that were bound" {
            $Result = Test-UriParameter -Tenants '123' -FilterDeviceType 'switch'
            $Result.Keys | Sort-Object | Should -Be @('filter[deviceType]', 'tenants')
        }

        It "Does not return parameters that are not in the name map" {
            $Result = Test-UriParameter -NotMapped 'abc' -FilterDeviceType 'router'
            $Result.Keys | Should -Not -Contain 'NotMapped'
            $Result.Keys | Should -Not -Contain 'abc'
            $Result.Count | Should -Be 1
        }

        It "Keeps the type of the values" {
            $Date = [datetime]::new(2025, 1, 2, 3, 4, 5, [System.DateTimeKind]::Utc)
            $Result = Test-UriParameter -Tenants 'a', 'b' -FilterModifiedAfter $Date -FilterStateKnown $false

            , $Result['tenants'] | Should -BeOfType [string[]]
            $Result['tenants'] | Should -Be @('a', 'b')
            $Result['filter[modifiedAfter]'] | Should -BeOfType [datetime]
            $Result['filter[stateKnown]'] | Should -BeOfType [bool]
            $Result['filter[stateKnown]'] | Should -BeFalse
        }

        It "Includes a bound parameter that has a false value" {
            (Test-UriParameter -FilterStateKnown $false).ContainsKey('filter[stateKnown]') | Should -BeTrue
        }

        It "Returns an empty hashtable for an empty name map" {
            $Result = Get-AuvikUriParameter -BoundParameter @{ Tenants = '1' } -NameMap @{}
            $Result.Count | Should -Be 0
        }

    }

}
