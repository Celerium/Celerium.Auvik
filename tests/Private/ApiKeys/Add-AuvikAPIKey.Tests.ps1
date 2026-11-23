<#
.NOTES
    Copyright 1990-2025 Celerium

    NAME: Add-AuvikAPIKey.Tests.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        EMAIL:   celerium@Celerium.org

.SYNOPSIS
    Pester tests for the Add-AuvikAPIKey function

.DESCRIPTION
    Pester tests for the Add-AuvikAPIKey function

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
    Invoke-Pester -Path .\Add-AuvikAPIKey.Tests.ps1

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

        $MockModule = Get-TestMockModuleName -CommandName 'Add-AuvikAPIKey'

        function ConvertFrom-TestSecureString {
            param ([securestring]$SecureString)

            $Pointer = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
            try     { return [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($Pointer) }
            finally { [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($Pointer) }
        }

    }

    AfterAll {
        Remove-TestModule -ModuleName $ModuleName
    }

#EndRegion  [ Prerequisites ]

Describe "Testing the [ $BuildTarget ] version of [ $ModuleName ] with [ $PesterTestName ]" {

    BeforeEach {
        Reset-TestModuleState
    }

    Context "[ Add-AuvikAPIKey ] with a plain text API key" {

        It "Stores the username" {
            Add-AuvikAPIKey -Username 'user@example.com' -ApiKey 'fake-api-key'
            $AuvikModuleUserName | Should -Be 'user@example.com'
        }

        It "Stores the API key as a SecureString" {
            Add-AuvikAPIKey -Username 'user@example.com' -ApiKey 'fake-api-key'

            $AuvikModuleApiKey | Should -BeOfType [securestring]
            ConvertFrom-TestSecureString -SecureString $AuvikModuleApiKey | Should -Be 'fake-api-key'
        }

        It "Stores the settings as read only global variables" {
            Add-AuvikAPIKey -Username 'user@example.com' -ApiKey 'fake-api-key'

            foreach ($Name in 'AuvikModuleUserName', 'AuvikModuleApiKey') {
                $Variable = Get-Variable -Name $Name -Scope Global
                $Variable.Options.ToString() | Should -Match 'ReadOnly'
            }
        }

        It "Does not return anything" {
            Add-AuvikAPIKey -Username 'user@example.com' -ApiKey 'fake-api-key' | Should -BeNullOrEmpty
        }

        It "Replaces an existing username & API key" {
            Add-AuvikAPIKey -Username 'first@example.com' -ApiKey 'first-key'
            Add-AuvikAPIKey -Username 'second@example.com' -ApiKey 'second-key'

            $AuvikModuleUserName | Should -Be 'second@example.com'
            ConvertFrom-TestSecureString -SecureString $AuvikModuleApiKey | Should -Be 'second-key'
        }

        It "Accepts the username from the pipeline" {
            'piped@example.com' | Add-AuvikAPIKey -ApiKey 'fake-api-key'
            $AuvikModuleUserName | Should -Be 'piped@example.com'
        }

        It "Prompts for the API key when it is not provided" {
            Mock Read-Host -ModuleName $MockModule -MockWith { ConvertTo-SecureString -String 'prompted-key' -AsPlainText -Force }

            $null = Add-AuvikAPIKey -Username 'user@example.com'

            Should -Invoke Read-Host -ModuleName $MockModule -Times 1 -Exactly
            ConvertFrom-TestSecureString -SecureString $AuvikModuleApiKey | Should -Be 'prompted-key'
        }

        It "Works with the Set-AuvikAPIKey alias" {
            Set-AuvikAPIKey -Username 'alias@example.com' -ApiKey 'alias-key'

            $AuvikModuleUserName | Should -Be 'alias@example.com'
            ConvertFrom-TestSecureString -SecureString $AuvikModuleApiKey | Should -Be 'alias-key'
        }

        It "Does not accept an empty username or API key" {
            { Add-AuvikAPIKey -Username '' -ApiKey 'fake-api-key' } | Should -Throw
            { Add-AuvikAPIKey -Username 'user@example.com' -ApiKey '' } | Should -Throw
            $AuvikModuleApiKey | Should -BeNullOrEmpty
        }

    }

    Context "[ Add-AuvikAPIKey ] with a SecureString API key" {

        It "Stores the SecureString as it is" {
            $Secure = ConvertTo-SecureString -String 'secure-key' -AsPlainText -Force

            Add-AuvikAPIKey -Username 'user@example.com' -ApiKeySecureString $Secure

            $AuvikModuleUserName | Should -Be 'user@example.com'
            $AuvikModuleApiKey | Should -BeOfType [securestring]
            ConvertFrom-TestSecureString -SecureString $AuvikModuleApiKey | Should -Be 'secure-key'
        }

        It "Does not accept the plain text & SecureString API key together" {
            $Secure = ConvertTo-SecureString -String 'secure-key' -AsPlainText -Force
            { Add-AuvikAPIKey -Username 'user@example.com' -ApiKey 'plain' -ApiKeySecureString $Secure } | Should -Throw
        }

    }

}
