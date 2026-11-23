<#
.NOTES
    Copyright 1990-2025 Celerium

    NAME: Get-AuvikAPIKey.Tests.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        EMAIL:   celerium@Celerium.org

.SYNOPSIS
    Pester tests for the Get-AuvikAPIKey function

.DESCRIPTION
    Pester tests for the Get-AuvikAPIKey function

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
    Invoke-Pester -Path .\Get-AuvikAPIKey.Tests.ps1

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

    Context "[ Get-AuvikAPIKey ] when the API key is set" {

        BeforeEach {
            Add-AuvikAPIKey -Username 'user@example.com' -ApiKey 'fake-api-key'
        }

        It "Returns the username & the API key as a SecureString" {
            $Result = Get-AuvikAPIKey

            $Result.UserName | Should -Be 'user@example.com'
            $Result.ApiKey | Should -BeOfType [securestring]
        }

        It "Does not expose the API key as plain text by default" {
            $Result = Get-AuvikAPIKey
            ($Result | Out-String) | Should -Not -Match 'fake-api-key'
            ($Result | ConvertTo-Json -Depth 3 -WarningAction SilentlyContinue) | Should -Not -Match 'fake-api-key'
        }

        It "Returns the API key as plain text with -AsPlainText" {
            $Result = Get-AuvikAPIKey -AsPlainText

            $Result.UserName | Should -Be 'user@example.com'
            $Result.ApiKey | Should -BeOfType [string]
            $Result.ApiKey | Should -BeExactly 'fake-api-key'
        }

        It "Does not warn" {
            $null = Get-AuvikAPIKey -WarningVariable ApiKeyWarning -WarningAction SilentlyContinue
            $ApiKeyWarning | Should -BeNullOrEmpty
        }

        It "Returns the key that was added last" {
            Add-AuvikAPIKey -Username 'other@example.com' -ApiKey 'other-key'

            $Result = Get-AuvikAPIKey -AsPlainText
            $Result.UserName | Should -Be 'other@example.com'
            $Result.ApiKey | Should -Be 'other-key'
        }

    }

    Context "[ Get-AuvikAPIKey ] when the API key is not set" {

        It "Warns & returns nothing" {
            $Result = Get-AuvikAPIKey -WarningVariable ApiKeyWarning -WarningAction SilentlyContinue

            $Result | Should -BeNullOrEmpty
            "$ApiKeyWarning" | Should -Match 'key is not set'
        }

        It "Warns & returns nothing with -AsPlainText" {
            $Result = Get-AuvikAPIKey -AsPlainText -WarningVariable ApiKeyWarning -WarningAction SilentlyContinue

            $Result | Should -BeNullOrEmpty
            "$ApiKeyWarning" | Should -Match 'key is not set'
        }

    }

}
