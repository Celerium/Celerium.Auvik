<#
.NOTES
    Copyright 1990-2025 Celerium

    NAME: Get-AuvikModuleSetting.Tests.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        EMAIL:   celerium@Celerium.org

.SYNOPSIS
    Pester tests for the Get-AuvikModuleSetting function

.DESCRIPTION
    Pester tests for the Get-AuvikModuleSetting function

    The configuration file is always read from the Pester TestDrive, never from the profile of the user

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
    Invoke-Pester -Path .\Get-AuvikModuleSetting.Tests.ps1

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

        $MockModule = Get-TestMockModuleName -CommandName 'Get-AuvikModuleSetting'

    }

    AfterAll {
        Remove-TestModule -ModuleName $ModuleName
    }

#EndRegion  [ Prerequisites ]

Describe "Testing the [ $BuildTarget ] version of [ $ModuleName ] with [ $PesterTestName ]" {

    BeforeEach {
        Reset-TestModuleState

        $ConfigPath = Join-Path -Path $TestDrive -ChildPath 'AuvikGet'
        $ConfigFile = Join-Path -Path $ConfigPath -ChildPath 'config.psd1'

        New-Item -Path $ConfigPath -ItemType Directory -Force | Out-Null
    }

    AfterEach {
        if (Test-Path -Path $ConfigPath) { Remove-Item -Path $ConfigPath -Recurse -Force }
    }

    Context "[ Get-AuvikModuleSetting ]" {

        It "Returns the content of the configuration file" {
            Set-Content -Path $ConfigFile -Value "@{ AuvikModuleBaseURI = 'https://auvikapi.eu1.my.auvik.com/v1'; AuvikModuleUserName = 'user@example.com'; AuvikJSONConversionDepth = '50' }"

            $Result = Get-AuvikModuleSetting -AuvikConfigPath $ConfigPath

            $Result.AuvikModuleBaseURI | Should -Be 'https://auvikapi.eu1.my.auvik.com/v1'
            $Result.AuvikModuleUserName | Should -Be 'user@example.com'
            $Result.AuvikJSONConversionDepth | Should -Be '50'
        }

        It "Reads a custom file name" {
            Set-Content -Path (Join-Path -Path $ConfigPath -ChildPath 'custom.psd1') -Value "@{ AuvikModuleUserName = 'custom@example.com' }"

            (Get-AuvikModuleSetting -AuvikConfigPath $ConfigPath -AuvikConfigFile 'custom.psd1').AuvikModuleUserName | Should -Be 'custom@example.com'
        }

        It "Does not change the module settings" {
            Set-Content -Path $ConfigFile -Value "@{ AuvikModuleBaseURI = 'https://auvikapi.eu1.my.auvik.com/v1' }"

            $null = Get-AuvikModuleSetting -AuvikConfigPath $ConfigPath

            $AuvikModuleBaseURI | Should -Be 'https://auvikapi.us1.my.auvik.com/v1'
        }

        It "Returns nothing when there is no configuration file" {
            Get-AuvikModuleSetting -AuvikConfigPath (Join-Path -Path $TestDrive -ChildPath 'DoesNotExist') | Should -BeNullOrEmpty
        }

        It "Returns nothing when the configuration file does not exist in the folder" {
            Get-AuvikModuleSetting -AuvikConfigPath $ConfigPath | Should -BeNullOrEmpty
        }

        It "Opens the configuration file with -OpenConfigFile" {
            Mock Test-Path -ModuleName $MockModule -MockWith { $true }
            Mock Invoke-Item -ModuleName $MockModule -MockWith { }

            $null = Get-AuvikModuleSetting -OpenConfigFile

            Should -Invoke Invoke-Item -ModuleName $MockModule -Times 1 -Exactly -ParameterFilter { $Path -like '*config.psd1' }
        }

    }

}
