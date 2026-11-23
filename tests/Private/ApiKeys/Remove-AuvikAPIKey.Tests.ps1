<#
.NOTES
    Copyright 1990-2025 Celerium

    NAME: Remove-AuvikAPIKey.Tests.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        EMAIL:   celerium@Celerium.org

.SYNOPSIS
    Pester tests for the Remove-AuvikAPIKey function

.DESCRIPTION
    Pester tests for the Remove-AuvikAPIKey function

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
    Invoke-Pester -Path .\Remove-AuvikAPIKey.Tests.ps1

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

    Context "[ Remove-AuvikAPIKey ] when the API key is set" {

        BeforeEach {
            Add-AuvikAPIKey -Username 'user@example.com' -ApiKey 'fake-api-key'
        }

        It "Removes the username & the API key" {
            Remove-AuvikAPIKey

            Get-Variable -Name 'AuvikModuleUserName' -Scope Global -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
            Get-Variable -Name 'AuvikModuleApiKey' -Scope Global -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
        }

        It "Does not warn or return anything" {
            $Result = Remove-AuvikAPIKey -WarningVariable RemoveWarning -WarningAction SilentlyContinue

            $Result | Should -BeNullOrEmpty
            $RemoveWarning | Should -BeNullOrEmpty
        }

        It "Makes Get-AuvikAPIKey warn afterwards" {
            Remove-AuvikAPIKey

            $Result = Get-AuvikAPIKey -WarningVariable ApiKeyWarning -WarningAction SilentlyContinue
            $Result | Should -BeNullOrEmpty
            "$ApiKeyWarning" | Should -Match 'not set'
        }

        It "Does not remove anything with -WhatIf" {
            Remove-AuvikAPIKey -WhatIf *> $null

            $AuvikModuleUserName | Should -Be 'user@example.com'
            $AuvikModuleApiKey | Should -BeOfType [securestring]
        }

        It "Does not remove the base URI" {
            Remove-AuvikAPIKey
            $AuvikModuleBaseURI | Should -Not -BeNullOrEmpty
        }

    }

    Context "[ Remove-AuvikAPIKey ] when the API key is not set" {

        It "Warns that there is nothing to remove without an error" {
            Remove-AuvikAPIKey -WarningVariable RemoveWarning -WarningAction SilentlyContinue -ErrorVariable RemoveError -ErrorAction SilentlyContinue

            "$RemoveWarning" | Should -Match 'Nothing to remove'
            $RemoveError | Should -BeNullOrEmpty
        }

    }

}
