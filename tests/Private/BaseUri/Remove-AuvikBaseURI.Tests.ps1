<#
.NOTES
    Copyright 1990-2025 Celerium

    NAME: Remove-AuvikBaseURI.Tests.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        EMAIL:   celerium@Celerium.org

.SYNOPSIS
    Pester tests for the Remove-AuvikBaseURI function

.DESCRIPTION
    Pester tests for the Remove-AuvikBaseURI function

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
    Invoke-Pester -Path .\Remove-AuvikBaseURI.Tests.ps1

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

    Context "[ Remove-AuvikBaseURI ]" {

        It "Removes the base URI" {
            Remove-AuvikBaseURI
            Get-Variable -Name 'AuvikModuleBaseURI' -Scope Global -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
        }

        It "Does not warn or return anything when the base URI is set" {
            $Result = Remove-AuvikBaseURI -WarningVariable RemoveWarning -WarningAction SilentlyContinue

            $Result | Should -BeNullOrEmpty
            $RemoveWarning | Should -BeNullOrEmpty
        }

        It "Does not remove the base URI with -WhatIf" {
            Remove-AuvikBaseURI -WhatIf *> $null
            $AuvikModuleBaseURI | Should -Be 'https://auvikapi.us1.my.auvik.com/v1'
        }

        It "Removes a custom base URI" {
            Add-AuvikBaseURI -BaseUri 'https://auvikapi.example.com/v1'
            Remove-AuvikBaseURI
            Get-Variable -Name 'AuvikModuleBaseURI' -Scope Global -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
        }

        It "Warns without an error when there is nothing to remove" {
            Remove-AuvikBaseURI
            Remove-AuvikBaseURI -WarningVariable RemoveWarning -WarningAction SilentlyContinue -ErrorVariable RemoveError -ErrorAction SilentlyContinue

            "$RemoveWarning" | Should -Match 'Nothing to remove'
            $RemoveError | Should -BeNullOrEmpty
        }

        It "Does not remove the API key" {
            Add-AuvikAPIKey -Username 'user@example.com' -ApiKey 'fake-api-key'
            Remove-AuvikBaseURI
            $AuvikModuleUserName | Should -Be 'user@example.com'
        }

    }

}
