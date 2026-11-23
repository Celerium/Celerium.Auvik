<#
.NOTES
    Copyright 1990-2025 Celerium

    NAME: Get-AuvikBaseURI.Tests.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        EMAIL:   celerium@Celerium.org

.SYNOPSIS
    Pester tests for the Get-AuvikBaseURI function

.DESCRIPTION
    Pester tests for the Get-AuvikBaseURI function

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
    Invoke-Pester -Path .\Get-AuvikBaseURI.Tests.ps1

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

    Context "[ Get-AuvikBaseURI ]" {

        It "Returns the default base URI" {
            Get-AuvikBaseURI | Should -Be 'https://auvikapi.us1.my.auvik.com/v1'
        }

        It "Returns the base URI that was set" {
            Add-AuvikBaseURI -DataCenter eu2
            Get-AuvikBaseURI | Should -Be 'https://auvikapi.eu2.my.auvik.com/v1'
        }

        It "Does not warn when the base URI is set" {
            $null = Get-AuvikBaseURI -WarningVariable BaseUriWarning -WarningAction SilentlyContinue
            $BaseUriWarning | Should -BeNullOrEmpty
        }

        It "Warns & returns nothing when the base URI is not set" {
            Remove-AuvikBaseURI

            $Result = Get-AuvikBaseURI -WarningVariable BaseUriWarning -WarningAction SilentlyContinue

            $Result | Should -BeNullOrEmpty
            "$BaseUriWarning" | Should -Match 'base URI is not set'
        }

    }

}
