<#
.NOTES
    Copyright 1990-2025 Celerium

    NAME: Add-AuvikBaseURI.Tests.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        EMAIL:   celerium@Celerium.org

.SYNOPSIS
    Pester tests for the Add-AuvikBaseURI function

.DESCRIPTION
    Pester tests for the Add-AuvikBaseURI function

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
    Invoke-Pester -Path .\Add-AuvikBaseURI.Tests.ps1

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

        # The regions of the API & the host name of the base URI they use. us & eu are aliases of the first data center of the region
        $DataCenterCases = @(
            @{ DataCenter = 'au1'; Region = 'au1' }
            @{ DataCenter = 'ca1'; Region = 'ca1' }
            @{ DataCenter = 'eu';  Region = 'eu1' }
            @{ DataCenter = 'eu1'; Region = 'eu1' }
            @{ DataCenter = 'eu2'; Region = 'eu2' }
            @{ DataCenter = 'us';  Region = 'us1' }
            @{ DataCenter = 'us1'; Region = 'us1' }
            @{ DataCenter = 'us2'; Region = 'us2' }
            @{ DataCenter = 'us3'; Region = 'us3' }
            @{ DataCenter = 'us4'; Region = 'us4' }
            @{ DataCenter = 'us5'; Region = 'us5' }
            @{ DataCenter = 'us6'; Region = 'us6' }
        )

    }

    BeforeAll {

        $TestsPath = $PSScriptRoot
        while ($TestsPath -and -not (Test-Path -Path (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1'))) { $TestsPath = Split-Path -Path $TestsPath -Parent }
        . (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1')

        Import-TestModule -ModuleName $ModuleName -Version $Version -BuildTarget $BuildTarget
        Add-TestHttpGuard -MockModule (Get-TestMockModuleName -CommandName 'Invoke-AuvikRequest')

    }

    AfterAll {
        Remove-TestModule -ModuleName $ModuleName
    }

#EndRegion  [ Prerequisites ]

Describe "Testing the [ $BuildTarget ] version of [ $ModuleName ] with [ $PesterTestName ]" {

    BeforeEach {
        Reset-TestModuleState
    }

    Context "[ Add-AuvikBaseURI ] with a base URI" {

        It "Defaults to the US1 data center" {
            Remove-AuvikBaseURI
            Add-AuvikBaseURI
            $AuvikModuleBaseURI | Should -Be 'https://auvikapi.us1.my.auvik.com/v1'
        }

        It "Stores the base URI" {
            Add-AuvikBaseURI -BaseUri 'https://auvikapi.example.com/v1'
            $AuvikModuleBaseURI | Should -Be 'https://auvikapi.example.com/v1'
        }

        It "Removes a trailing slash" {
            Add-AuvikBaseURI -BaseUri 'https://auvikapi.example.com/v1/'
            $AuvikModuleBaseURI | Should -Be 'https://auvikapi.example.com/v1'
        }

        It "Converts the Auvik host [ <Value> ] to the API base URI" -ForEach @(
            @{ Value = 'us2.my.auvik.com' }
            @{ Value = 'https://us2.my.auvik.com' }
            @{ Value = 'auvikapi.us2.my.auvik.com' }
            @{ Value = 'https://auvikapi.US2.my.auvik.com/v1/' }
        ) {
            Add-AuvikBaseURI -BaseUri $Value
            $AuvikModuleBaseURI | Should -Be 'https://auvikapi.us2.my.auvik.com/v1'
        }

        It "Uses https for a custom URI without a scheme" {
            Add-AuvikBaseURI -BaseUri 'gateway.example.com/auvik'
            $AuvikModuleBaseURI | Should -Be 'https://gateway.example.com/auvik'
        }

        It "Keeps the scheme of a custom URI" {
            Add-AuvikBaseURI -BaseUri 'http://localhost:8080/v1'
            $AuvikModuleBaseURI | Should -Be 'http://localhost:8080/v1'
        }

        It "Does not change a base URI without a trailing slash" {
            Add-AuvikBaseURI -BaseUri 'https://auvikapi.eu1.my.auvik.com/v1'
            $AuvikModuleBaseURI | Should -Be 'https://auvikapi.eu1.my.auvik.com/v1'
        }

        It "Accepts the base URI from the pipeline" {
            'https://auvikapi.piped.com/v1/' | Add-AuvikBaseURI
            $AuvikModuleBaseURI | Should -Be 'https://auvikapi.piped.com/v1'
        }

        It "Stores the base URI as a read only global variable" {
            Add-AuvikBaseURI -BaseUri 'https://auvikapi.example.com/v1'
            (Get-Variable -Name 'AuvikModuleBaseURI' -Scope Global).Options.ToString() | Should -Match 'ReadOnly'
        }

        It "Replaces an existing base URI" {
            Add-AuvikBaseURI -BaseUri 'https://auvikapi.first.com/v1'
            Add-AuvikBaseURI -BaseUri 'https://auvikapi.second.com/v1'
            $AuvikModuleBaseURI | Should -Be 'https://auvikapi.second.com/v1'
        }

        It "Works with the Set-AuvikBaseURI alias" {
            Set-AuvikBaseURI -BaseUri 'https://auvikapi.alias.com/v1'
            $AuvikModuleBaseURI | Should -Be 'https://auvikapi.alias.com/v1'
        }

        It "Does not return anything" {
            Add-AuvikBaseURI -BaseUri 'https://auvikapi.example.com/v1' | Should -BeNullOrEmpty
        }

    }

    Context "[ Add-AuvikBaseURI ] with a data center" {

        It "Maps the [ <DataCenter> ] data center to the [ <Region> ] host" -ForEach $DataCenterCases {
            Add-AuvikBaseURI -DataCenter $DataCenter
            $AuvikModuleBaseURI | Should -Be "https://auvikapi.$Region.my.auvik.com/v1"
        }

        It "Uses the data center instead of the base URI" {
            Add-AuvikBaseURI -BaseUri 'https://auvikapi.example.com/v1' -DataCenter us2
            $AuvikModuleBaseURI | Should -Be 'https://auvikapi.us2.my.auvik.com/v1'
        }

        It "Does not accept an unknown data center" {
            { Add-AuvikBaseURI -DataCenter 'mars1' } | Should -Throw
        }

    }

}
