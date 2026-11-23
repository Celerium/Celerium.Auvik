<#
.NOTES
    Copyright 1990-2025 Celerium

    NAME: Initialize-AuvikModuleSetting.Tests.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        EMAIL:   celerium@Celerium.org

.SYNOPSIS
    Pester tests for the settings the module loads when it is imported

.DESCRIPTION
    Pester tests for the Initialize-AuvikModuleSetting script of the module. The script is not a function,
    it runs Import-AuvikModuleSetting when the module is imported

    The environment variables the module uses (AUVIK_BASE_URI, AUVIK_USERNAME, & AUVIK_API_KEY) are
    saved & restored by the tests

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
    Invoke-Pester -Path .\Initialize-AuvikModuleSetting.Tests.ps1

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

        $EnvironmentNames   = 'AUVIK_BASE_URI', 'AUVIK_USERNAME', 'AUVIK_API_KEY'
        $SavedEnvironment   = @{}
        foreach ($Name in $EnvironmentNames) { $SavedEnvironment[$Name] = [Environment]::GetEnvironmentVariable($Name) }

    }

    AfterAll {

        foreach ($Name in $EnvironmentNames) { [Environment]::SetEnvironmentVariable($Name, $SavedEnvironment[$Name]) }

        Remove-TestModule -ModuleName $ModuleName

    }

#EndRegion  [ Prerequisites ]

Describe "Testing the [ $BuildTarget ] version of [ $ModuleName ] with [ $PesterTestName ]" {

    BeforeEach {
        foreach ($Name in $EnvironmentNames) { [Environment]::SetEnvironmentVariable($Name, $null) }

        Remove-TestState
    }

    AfterEach {
        foreach ($Name in $EnvironmentNames) { [Environment]::SetEnvironmentVariable($Name, $null) }
    }

    Context "[ Initialize-AuvikModuleSetting ] importing the module" {

        It "Loads a base URI & the JSON depth" {
            Import-TestModule -ModuleName $ModuleName -Version $Version -BuildTarget $BuildTarget -KeepEnvironment

            # A configuration file in the profile of the user could be loaded, so the exact base URI is not checked
            $AuvikModuleBaseURI | Should -Match '^https://auvikapi\..+/v1$'
            $AuvikJSONConversionDepth | Should -BeGreaterThan 0
        }

        It "Configures the module from the environment variables" {
            [Environment]::SetEnvironmentVariable('AUVIK_BASE_URI', 'https://auvikapi.eu1.my.auvik.com/v1')
            [Environment]::SetEnvironmentVariable('AUVIK_USERNAME', 'env@example.com')
            [Environment]::SetEnvironmentVariable('AUVIK_API_KEY', 'env-key')

            Import-TestModule -ModuleName $ModuleName -Version $Version -BuildTarget $BuildTarget -KeepEnvironment

            $AuvikModuleBaseURI | Should -Be 'https://auvikapi.eu1.my.auvik.com/v1'

            $Credential = Get-AuvikAPIKey -AsPlainText
            $Credential.UserName | Should -Be 'env@example.com'
            $Credential.ApiKey | Should -BeExactly 'env-key'
        }

        It "Does not use the environment variables of the test run" {
            [Environment]::SetEnvironmentVariable('AUVIK_USERNAME', 'env@example.com')
            [Environment]::SetEnvironmentVariable('AUVIK_API_KEY', 'env-key')

            # Import-TestModule clears the variables so unit tests can not be influenced by the environment
            Import-TestModule -ModuleName $ModuleName -Version $Version -BuildTarget $BuildTarget

            Get-Variable -Name 'AuvikModuleUserName' -Scope Global -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
            [Environment]::GetEnvironmentVariable('AUVIK_USERNAME') | Should -Be 'env@example.com'
        }

    }

}
