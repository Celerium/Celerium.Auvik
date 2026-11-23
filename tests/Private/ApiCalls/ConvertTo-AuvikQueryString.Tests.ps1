<#
.NOTES
    Copyright 1990-2025 Celerium

    NAME: ConvertTo-AuvikQueryString.Tests.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        EMAIL:   celerium@Celerium.org

.SYNOPSIS
    Pester tests for the ConvertTo-AuvikQueryString function

.DESCRIPTION
    Pester tests for the ConvertTo-AuvikQueryString function

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
    Invoke-Pester -Path .\ConvertTo-AuvikQueryString.Tests.ps1

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

    }

    AfterAll {
        Remove-TestModule -ModuleName $ModuleName
    }

#EndRegion  [ Prerequisites ]

Describe "Testing the [ $BuildTarget ] version of [ $ModuleName ] with [ $PesterTestName ]" {

    BeforeEach {
        Reset-TestModuleState
    }

    Context "[ ConvertTo-AuvikQueryString ] building the uri" {

        It "Returns a UriBuilder made of the base URI & the resource uri" {
            $Result = ConvertTo-AuvikQueryString -ResourceUri '/inventory/device/info'
            $Result | Should -BeOfType [System.UriBuilder]
            $Result.Uri.AbsoluteUri | Should -Be 'https://auvikapi.us1.my.auvik.com/v1/inventory/device/info'
            $Result.Query | Should -BeNullOrEmpty
        }

        It "Uses a custom base URI" {
            Add-AuvikBaseURI -DataCenter eu
            (ConvertTo-AuvikQueryString -ResourceUri '/tenants').Uri.AbsoluteUri | Should -Be 'https://auvikapi.eu1.my.auvik.com/v1/tenants'
        }

        It "Throws when the base URI is not set" {
            Remove-AuvikBaseURI
            { ConvertTo-AuvikQueryString -ResourceUri '/tenants' } | Should -Throw '*base URI is not set*'
        }

        It "Does not add a query when the filter is empty" {
            $Result = ConvertTo-AuvikQueryString -UriFilter @{} -ResourceUri '/tenants'
            $Result.Uri.Query | Should -BeNullOrEmpty
        }

        It "Accepts the filter from the pipeline" {
            $Result = @{ tenants = 'abc' } | ConvertTo-AuvikQueryString -ResourceUri '/tenants'
            (Get-TestQuery -Uri $Result.Uri).tenants | Should -Be 'abc'
        }

    }

    Context "[ ConvertTo-AuvikQueryString ] converting values" {

        It "Sends strings & numbers as they are" {
            $Query = Get-TestQuery -Uri (ConvertTo-AuvikQueryString -UriFilter @{ 'filter[deviceType]' = 'router'; 'page[first]' = 10 } -ResourceUri '/x').Uri
            $Query.Count | Should -Be 2
            $Query['filter[deviceType]'] | Should -Be 'router'
            $Query['page[first]'] | Should -Be '10'
        }

        It "Encodes the brackets of the keys" {
            $Result = ConvertTo-AuvikQueryString -UriFilter @{ 'filter[deviceType]' = 'router' } -ResourceUri '/x'
            $Result.Query | Should -Match '(?i)filter%5bdeviceType%5d=router'
            $Result.Query | Should -Not -Match '\['
        }

        It "Sends arrays as a comma delimited list" {
            $Query = Get-TestQuery -Uri (ConvertTo-AuvikQueryString -UriFilter @{ tenants = @('111', '222', '333') } -ResourceUri '/x').Uri
            $Query['tenants'] | Should -Be '111,222,333'
        }

        It "Sends an array with one item without a comma" {
            $Query = Get-TestQuery -Uri (ConvertTo-AuvikQueryString -UriFilter @{ tenants = [string[]]@('111') } -ResourceUri '/x').Uri
            $Query['tenants'] | Should -Be '111'
        }

        It "Sends booleans in lowercase" {
            $Query = Get-TestQuery -Uri (ConvertTo-AuvikQueryString -UriFilter @{ 'filter[stateKnown]' = $true; 'filter[dismissed]' = $false } -ResourceUri '/x').Uri
            $Query['filter[stateKnown]'] | Should -BeExactly 'true'
            $Query['filter[dismissed]'] | Should -BeExactly 'false'
        }

        It "Sends dates in UTC" {
            $Date = [datetime]::new(2025, 1, 2, 3, 4, 5, [System.DateTimeKind]::Utc)
            $Query = Get-TestQuery -Uri (ConvertTo-AuvikQueryString -UriFilter @{ 'filter[modifiedAfter]' = $Date } -ResourceUri '/x').Uri
            $Query['filter[modifiedAfter]'] | Should -Be '2025-01-02T03:04:05.000Z'
        }

        It "Converts dates with an offset to UTC" {
            $Date = [datetime]::Parse('2025-01-02T03:04:05+02:00')
            $Query = Get-TestQuery -Uri (ConvertTo-AuvikQueryString -UriFilter @{ 'filter[modifiedAfter]' = $Date } -ResourceUri '/x').Uri
            $Query['filter[modifiedAfter]'] | Should -Be '2025-01-02T01:04:05.000Z'
        }

        It "Keeps the milliseconds of a date" {
            $Date = [datetime]::new(2025, 1, 2, 3, 4, 5, 678, [System.DateTimeKind]::Utc)
            $Query = Get-TestQuery -Uri (ConvertTo-AuvikQueryString -UriFilter @{ 'filter[notSeenSince]' = $Date } -ResourceUri '/x').Uri
            $Query['filter[notSeenSince]'] | Should -Be '2025-01-02T03:04:05.678Z'
        }

        It "Sends [ <Key> ] dates as yyyy-MM-dd" -ForEach @(
            @{ Key = 'filter[fromDate]' }
            @{ Key = 'filter[thruDate]' }
        ) {
            $Date = [datetime]::new(2025, 1, 2, 23, 59, 59, [System.DateTimeKind]::Utc)
            $Query = Get-TestQuery -Uri (ConvertTo-AuvikQueryString -UriFilter @{ $Key = $Date } -ResourceUri '/x').Uri
            $Query[$Key] | Should -Be '2025-01-02'
        }

        It "Skips null values" {
            $Query = Get-TestQuery -Uri (ConvertTo-AuvikQueryString -UriFilter @{ 'filter[deviceType]' = $null; tenants = 'abc' } -ResourceUri '/x').Uri
            $Query.Keys | Should -Not -Contain 'filter[deviceType]'
            $Query['tenants'] | Should -Be 'abc'
        }

        It "Encodes special characters in values" {
            $Value = 'a b&c=d/e?f'
            $Result = ConvertTo-AuvikQueryString -UriFilter @{ 'filter[makeModel]' = $Value } -ResourceUri '/x'
            $Result.Query | Should -Not -Match '&c='
            (Get-TestQuery -Uri $Result.Uri)['filter[makeModel]'] | Should -Be $Value
        }

        It "Keeps the cursor of a page value intact" {
            $Cursor = 'Y3Vyc29yOjE5OTc2MjIzNTAxNTE2ODAwNCwxOTk3NjI0ODM4MzI2MTI2MTE='
            $Query = Get-TestQuery -Uri (ConvertTo-AuvikQueryString -UriFilter @{ 'page[after]' = $Cursor } -ResourceUri '/x').Uri
            $Query['page[after]'] | Should -Be $Cursor
        }

    }

}
