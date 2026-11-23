<#
.NOTES
    Copyright 1990-2025 Celerium

    NAME: Import-AuvikModuleSetting.Tests.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        EMAIL:   celerium@Celerium.org

.SYNOPSIS
    Pester tests for the Import-AuvikModuleSetting function

.DESCRIPTION
    Pester tests for the Import-AuvikModuleSetting function

    The configuration file is always read from & written to the Pester TestDrive, never the profile of the user

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
    Invoke-Pester -Path .\Import-AuvikModuleSetting.Tests.ps1

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

        # DPAPI does not exist on Linux or macOS so an invalid API key is not detected there
        $OnWindows = ($PSEdition -eq 'Desktop' -or $IsWindows)

    }

    BeforeAll {

        $TestsPath = $PSScriptRoot
        while ($TestsPath -and -not (Test-Path -Path (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1'))) { $TestsPath = Split-Path -Path $TestsPath -Parent }
        . (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1')

        Import-TestModule -ModuleName $ModuleName -Version $Version -BuildTarget $BuildTarget
        Add-TestHttpGuard -MockModule (Get-TestMockModuleName -CommandName 'Invoke-AuvikRequest')

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

        Reset-TestModuleState

        $ConfigPath = Join-Path -Path $TestDrive -ChildPath 'AuvikImport'
        $ConfigFile = Join-Path -Path $ConfigPath -ChildPath 'config.psd1'

        New-Item -Path $ConfigPath -ItemType Directory -Force | Out-Null
    }

    AfterEach {
        foreach ($Name in $EnvironmentNames) { [Environment]::SetEnvironmentVariable($Name, $null) }

        if (Test-Path -Path $ConfigPath) { Remove-Item -Path $ConfigPath -Recurse -Force }
    }

    Context "[ Import-AuvikModuleSetting ] without a configuration file" {

        It "Loads the default base URI & JSON depth" {
            Remove-TestState

            Import-AuvikModuleSetting -AuvikConfigPath $ConfigPath

            $AuvikModuleBaseURI | Should -Be 'https://auvikapi.us1.my.auvik.com/v1'
            $AuvikJSONConversionDepth | Should -Be 100
        }

        It "Replaces the base URI that was set before" {
            Add-AuvikBaseURI -DataCenter eu1

            Import-AuvikModuleSetting -AuvikConfigPath $ConfigPath

            $AuvikModuleBaseURI | Should -Be 'https://auvikapi.us1.my.auvik.com/v1'
        }

        It "Does not set the API credentials" {
            Import-AuvikModuleSetting -AuvikConfigPath $ConfigPath

            Get-Variable -Name 'AuvikModuleUserName' -Scope Global -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
            Get-Variable -Name 'AuvikModuleApiKey' -Scope Global -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
        }

    }

    Context "[ Import-AuvikModuleSetting ] with a configuration file" {

        It "Restores the settings that were exported" {
            Add-AuvikBaseURI -DataCenter eu2
            Add-AuvikAPIKey -Username 'exported@example.com' -ApiKey 'exported-key'
            Export-AuvikModuleSetting -AuvikConfigPath $ConfigPath -WarningAction SilentlyContinue

            Remove-TestState
            Import-AuvikModuleSetting -AuvikConfigPath $ConfigPath

            $AuvikModuleBaseURI | Should -Be 'https://auvikapi.eu2.my.auvik.com/v1'
            $AuvikModuleUserName | Should -Be 'exported@example.com'
            $AuvikModuleApiKey | Should -BeOfType [securestring]
            $AuvikJSONConversionDepth | Should -Be 100

            $Credential = Get-AuvikAPIKey -AsPlainText
            $Credential.UserName | Should -Be 'exported@example.com'
            $Credential.ApiKey | Should -BeExactly 'exported-key'
        }

        It "Reads a custom file name" {
            Add-AuvikAPIKey -Username 'custom@example.com' -ApiKey 'custom-key'
            Export-AuvikModuleSetting -AuvikConfigPath $ConfigPath -AuvikConfigFile 'custom.psd1' -WarningAction SilentlyContinue

            Remove-TestState
            Import-AuvikModuleSetting -AuvikConfigPath $ConfigPath -AuvikConfigFile 'custom.psd1'

            $AuvikModuleUserName | Should -Be 'custom@example.com'
        }

        It "Does not leave temporary variables in the session" {
            Add-AuvikAPIKey -Username 'temp@example.com' -ApiKey 'temp-key'
            Export-AuvikModuleSetting -AuvikConfigPath $ConfigPath -WarningAction SilentlyContinue

            Import-AuvikModuleSetting -AuvikConfigPath $ConfigPath

            Get-Variable -Name 'TempConfig' -Scope Global -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
        }

        It "Removes a trailing slash of the base URI in the file" {
            $Protected = ConvertTo-SecureString -String 'file-key' -AsPlainText -Force | ConvertFrom-SecureString
            Set-Content -Path $ConfigFile -Value "@{ AuvikModuleBaseURI = 'https://auvikapi.eu1.my.auvik.com/v1/'; AuvikModuleUserName = 'file@example.com'; AuvikModuleApiKey = '$Protected'; AuvikJSONConversionDepth = '25' }"

            Import-AuvikModuleSetting -AuvikConfigPath $ConfigPath

            $AuvikModuleBaseURI | Should -Be 'https://auvikapi.eu1.my.auvik.com/v1'
            $AuvikModuleUserName | Should -Be 'file@example.com'
            $AuvikJSONConversionDepth | Should -Be 25
            $AuvikJSONConversionDepth | Should -BeOfType [int]
        }

        It "Warns & loads the defaults when the configuration file is not valid" {
            Set-Content -Path $ConfigFile -Value 'this is not a configuration'

            Import-AuvikModuleSetting -AuvikConfigPath $ConfigPath -WarningVariable ImportWarning -WarningAction SilentlyContinue

            "$ImportWarning" | Should -Match 'could not be loaded'
            $AuvikModuleBaseURI | Should -Be 'https://auvikapi.us1.my.auvik.com/v1'
            $AuvikJSONConversionDepth | Should -Be 100
        }

        It "Warns when the API key in the configuration file can not be decrypted" -Skip:(-not $OnWindows) {
            Set-Content -Path $ConfigFile -Value "@{ AuvikModuleBaseURI = 'https://auvikapi.eu1.my.auvik.com/v1'; AuvikModuleUserName = 'file@example.com'; AuvikModuleApiKey = 'not-an-encrypted-key'; AuvikJSONConversionDepth = '100' }"

            Import-AuvikModuleSetting -AuvikConfigPath $ConfigPath -WarningVariable ImportWarning -WarningAction SilentlyContinue

            "$ImportWarning" | Should -Match 'could not be loaded'
        }

    }

    Context "[ Import-AuvikModuleSetting ] environment variables" {

        It "Sets the base URI from AUVIK_BASE_URI" {
            [Environment]::SetEnvironmentVariable('AUVIK_BASE_URI', 'https://auvikapi.au1.my.auvik.com/v1/')

            Import-AuvikModuleSetting -AuvikConfigPath $ConfigPath

            $AuvikModuleBaseURI | Should -Be 'https://auvikapi.au1.my.auvik.com/v1'
        }

        It "Sets the API credentials from AUVIK_USERNAME & AUVIK_API_KEY" {
            [Environment]::SetEnvironmentVariable('AUVIK_USERNAME', 'env@example.com')
            [Environment]::SetEnvironmentVariable('AUVIK_API_KEY', 'env-key')

            Import-AuvikModuleSetting -AuvikConfigPath $ConfigPath

            $Credential = Get-AuvikAPIKey -AsPlainText
            $Credential.UserName | Should -Be 'env@example.com'
            $Credential.ApiKey | Should -BeExactly 'env-key'
        }

        It "Needs both AUVIK_USERNAME & AUVIK_API_KEY" {
            [Environment]::SetEnvironmentVariable('AUVIK_USERNAME', 'env@example.com')

            Import-AuvikModuleSetting -AuvikConfigPath $ConfigPath

            Get-Variable -Name 'AuvikModuleUserName' -Scope Global -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
            Get-Variable -Name 'AuvikModuleApiKey' -Scope Global -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
        }

        It "Takes priority over the configuration file" {
            $Protected = ConvertTo-SecureString -String 'file-key' -AsPlainText -Force | ConvertFrom-SecureString
            Set-Content -Path $ConfigFile -Value "@{ AuvikModuleBaseURI = 'https://auvikapi.eu1.my.auvik.com/v1'; AuvikModuleUserName = 'file@example.com'; AuvikModuleApiKey = '$Protected'; AuvikJSONConversionDepth = '100' }"

            [Environment]::SetEnvironmentVariable('AUVIK_BASE_URI', 'https://auvikapi.ca1.my.auvik.com/v1')
            [Environment]::SetEnvironmentVariable('AUVIK_USERNAME', 'env@example.com')
            [Environment]::SetEnvironmentVariable('AUVIK_API_KEY', 'env-key')

            Import-AuvikModuleSetting -AuvikConfigPath $ConfigPath

            $AuvikModuleBaseURI | Should -Be 'https://auvikapi.ca1.my.auvik.com/v1'

            $Credential = Get-AuvikAPIKey -AsPlainText
            $Credential.UserName | Should -Be 'env@example.com'
            $Credential.ApiKey | Should -BeExactly 'env-key'
        }

        It "Keeps the file settings that have no environment variable" {
            $Protected = ConvertTo-SecureString -String 'file-key' -AsPlainText -Force | ConvertFrom-SecureString
            Set-Content -Path $ConfigFile -Value "@{ AuvikModuleBaseURI = 'https://auvikapi.eu1.my.auvik.com/v1'; AuvikModuleUserName = 'file@example.com'; AuvikModuleApiKey = '$Protected'; AuvikJSONConversionDepth = '100' }"

            [Environment]::SetEnvironmentVariable('AUVIK_BASE_URI', 'https://auvikapi.ca1.my.auvik.com/v1')

            Import-AuvikModuleSetting -AuvikConfigPath $ConfigPath

            $AuvikModuleBaseURI | Should -Be 'https://auvikapi.ca1.my.auvik.com/v1'
            (Get-AuvikAPIKey -AsPlainText).UserName | Should -Be 'file@example.com'
        }

    }

}
