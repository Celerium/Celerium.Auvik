<#
.NOTES
    Copyright 1990-2025 Celerium

    NAME: Remove-AuvikModuleSetting.Tests.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        EMAIL:   celerium@Celerium.org

.SYNOPSIS
    Pester tests for the Remove-AuvikModuleSetting function

.DESCRIPTION
    Pester tests for the Remove-AuvikModuleSetting function

    Only folders in the Pester TestDrive are removed, never the configuration folder of the user

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
    Invoke-Pester -Path .\Remove-AuvikModuleSetting.Tests.ps1

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
        Set-TestCredential

        $ConfigPath = Join-Path -Path $TestDrive -ChildPath 'AuvikRemove'

        New-Item -Path $ConfigPath -ItemType Directory -Force | Out-Null
        Set-Content -Path (Join-Path -Path $ConfigPath -ChildPath 'config.psd1') -Value '@{}'
    }

    AfterEach {
        if (Test-Path -Path $ConfigPath) { Remove-Item -Path $ConfigPath -Recurse -Force }
    }

    Context "[ Remove-AuvikModuleSetting ] removing the configuration folder" {

        It "Removes the configuration folder & its files" {
            Remove-AuvikModuleSetting -AuvikConfigPath $ConfigPath | Out-Null

            $ConfigPath | Should -Not -Exist
        }

        It "Reports that the folder was removed" {
            $Result = Remove-AuvikModuleSetting -AuvikConfigPath $ConfigPath

            "$Result" | Should -Match 'removed successfully'
            "$Result" | Should -Match ([regex]::Escape($ConfigPath))
        }

        It "Does not remove the module settings by default" {
            Remove-AuvikModuleSetting -AuvikConfigPath $ConfigPath | Out-Null

            $AuvikModuleUserName | Should -Be 'user@example.com'
            $AuvikModuleBaseURI | Should -Not -BeNullOrEmpty
            $AuvikModuleApiKey | Should -Not -BeNullOrEmpty
        }

        It "Removes the module settings with -AndVariables" {
            Remove-AuvikModuleSetting -AuvikConfigPath $ConfigPath -AndVariables -WarningAction SilentlyContinue | Out-Null

            $ConfigPath | Should -Not -Exist
            Get-Variable -Name 'AuvikModuleUserName' -Scope Global -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
            Get-Variable -Name 'AuvikModuleApiKey' -Scope Global -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
            Get-Variable -Name 'AuvikModuleBaseURI' -Scope Global -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
        }

        It "Does not remove anything with -WhatIf" {
            Remove-AuvikModuleSetting -AuvikConfigPath $ConfigPath -WhatIf -ErrorAction SilentlyContinue *> $null

            Join-Path -Path $ConfigPath -ChildPath 'config.psd1' | Should -Exist
            $AuvikModuleUserName | Should -Be 'user@example.com'
        }

        It "Warns without an error when the folder does not exist" {
            $MissingPath = Join-Path -Path $TestDrive -ChildPath 'DoesNotExist'

            Remove-AuvikModuleSetting -AuvikConfigPath $MissingPath -WarningVariable RemoveWarning -WarningAction SilentlyContinue -ErrorVariable RemoveError -ErrorAction SilentlyContinue

            "$RemoveWarning" | Should -Match 'No configuration folder found'
            $RemoveError | Should -BeNullOrEmpty
        }

    }

}
