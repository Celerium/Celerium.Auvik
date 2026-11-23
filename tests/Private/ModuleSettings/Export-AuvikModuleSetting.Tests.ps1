<#
.NOTES
    Copyright 1990-2025 Celerium

    NAME: Export-AuvikModuleSetting.Tests.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        EMAIL:   celerium@Celerium.org

.SYNOPSIS
    Pester tests for the Export-AuvikModuleSetting function

.DESCRIPTION
    Pester tests for the Export-AuvikModuleSetting function

    The configuration file is always written to the Pester TestDrive, never to the profile of the user

    The API key is protected with DPAPI on Windows. DPAPI does not exist on Linux or macOS so the
    tests that depend on the encryption are skipped on those platforms

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
    Invoke-Pester -Path .\Export-AuvikModuleSetting.Tests.ps1

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

        $OnWindows = ($PSEdition -eq 'Desktop' -or $IsWindows)

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

        $ConfigPath = Join-Path -Path $TestDrive -ChildPath 'AuvikExport'
        $ConfigFile = Join-Path -Path $ConfigPath -ChildPath 'config.psd1'
    }

    AfterEach {
        if (Test-Path -Path $ConfigPath) { Remove-Item -Path $ConfigPath -Recurse -Force }
    }

    Context "[ Export-AuvikModuleSetting ] writing the configuration file" {

        It "Creates the folder & the configuration file" {
            Export-AuvikModuleSetting -AuvikConfigPath $ConfigPath -WarningAction SilentlyContinue

            $ConfigPath | Should -Exist
            $ConfigFile | Should -Exist
        }

        It "Creates missing parent folders" {
            $NestedPath = Join-Path -Path (Join-Path -Path $ConfigPath -ChildPath 'Level1') -ChildPath 'Level2'

            Export-AuvikModuleSetting -AuvikConfigPath $NestedPath -WarningAction SilentlyContinue

            Join-Path -Path $NestedPath -ChildPath 'config.psd1' | Should -Exist
        }

        It "Uses a custom file name" {
            Export-AuvikModuleSetting -AuvikConfigPath $ConfigPath -AuvikConfigFile 'custom.psd1' -WarningAction SilentlyContinue

            Join-Path -Path $ConfigPath -ChildPath 'custom.psd1' | Should -Exist
            $ConfigFile | Should -Not -Exist
        }

        It "Writes a valid PowerShell data file with the module settings" {
            Export-AuvikModuleSetting -AuvikConfigPath $ConfigPath -WarningAction SilentlyContinue

            $Config = Import-PowerShellDataFile -Path $ConfigFile

            $Config.AuvikModuleBaseURI | Should -Be 'https://auvikapi.us1.my.auvik.com/v1'
            $Config.AuvikModuleUserName | Should -Be 'user@example.com'
            $Config.AuvikModuleApiKey | Should -Not -BeNullOrEmpty
            [int]$Config.AuvikJSONConversionDepth | Should -Be 100
        }

        It "Exports a custom base URI" {
            Add-AuvikBaseURI -DataCenter eu1

            Export-AuvikModuleSetting -AuvikConfigPath $ConfigPath -WarningAction SilentlyContinue

            (Import-PowerShellDataFile -Path $ConfigFile).AuvikModuleBaseURI | Should -Be 'https://auvikapi.eu1.my.auvik.com/v1'
        }

        It "Does not store the API key as plain text" -Skip:(-not $OnWindows) {
            Export-AuvikModuleSetting -AuvikConfigPath $ConfigPath -WarningAction SilentlyContinue

            (Get-Content -Path $ConfigFile -Raw) | Should -Not -Match 'fake-api-key'
        }

        It "Hides the configuration folder" -Skip:(-not $OnWindows) {
            Export-AuvikModuleSetting -AuvikConfigPath $ConfigPath -WarningAction SilentlyContinue

            (Get-Item -Path $ConfigPath -Force).Attributes.ToString() | Should -Match 'Hidden'
        }

        It "Warns that the secrets are protected with DPAPI" {
            Export-AuvikModuleSetting -AuvikConfigPath $ConfigPath -WarningVariable ExportWarning -WarningAction SilentlyContinue

            "$ExportWarning" | Should -Match 'DPAPI'
        }

        It "Overwrites an existing configuration file" {
            Export-AuvikModuleSetting -AuvikConfigPath $ConfigPath -WarningAction SilentlyContinue
            Add-AuvikAPIKey -Username 'second@example.com' -ApiKey 'second-key'

            Export-AuvikModuleSetting -AuvikConfigPath $ConfigPath -WarningAction SilentlyContinue

            (Import-PowerShellDataFile -Path $ConfigFile).AuvikModuleUserName | Should -Be 'second@example.com'
        }

    }

    Context "[ Export-AuvikModuleSetting ] -WhatIf & missing settings" {

        It "Does not write anything with -WhatIf" {
            Export-AuvikModuleSetting -AuvikConfigPath $ConfigPath -WhatIf -WarningAction SilentlyContinue *> $null

            $ConfigPath | Should -Not -Exist
        }

        It "Writes an error & no file when the API key is not set" {
            Remove-AuvikAPIKey -WarningAction SilentlyContinue

            Export-AuvikModuleSetting -AuvikConfigPath $ConfigPath -WarningAction SilentlyContinue -ErrorAction SilentlyContinue -ErrorVariable ExportError

            "$ExportError" | Should -Match 'Failed to export'
            $ConfigFile | Should -Not -Exist
        }

        It "Writes an error & no file when the base URI is not set" {
            Remove-AuvikBaseURI

            Export-AuvikModuleSetting -AuvikConfigPath $ConfigPath -WarningAction SilentlyContinue -ErrorAction SilentlyContinue -ErrorVariable ExportError

            "$ExportError" | Should -Match 'Failed to export'
            $ConfigFile | Should -Not -Exist
        }

    }

}
