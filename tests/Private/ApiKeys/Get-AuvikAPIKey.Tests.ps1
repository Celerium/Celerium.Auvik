<#
    .SYNOPSIS
        Pester tests for the Celerium.Auvik APIKeys functions

    .DESCRIPTION
        Pester tests for the Celerium.Auvik APIKeys functions

    .PARAMETER moduleName
        The name of the local module to import

    .PARAMETER Version
        The version of the local module to import

    .PARAMETER buildTarget
        Which version of the module to run tests against

        Allowed values:
            'built', 'notBuilt'

    .EXAMPLE
        Invoke-Pester -Path .\Tests\Private\APIKeys\Get-AuvikAPIKey.Tests.ps1

        Runs a pester test and outputs simple results

    .EXAMPLE
        Invoke-Pester -Path .\Tests\Private\APIKeys\Get-AuvikAPIKey.Tests.ps1 -Output Detailed

        Runs a pester test and outputs detailed results

    .INPUTS
        N\A

    .OUTPUTS
        N\A

    .NOTES
        N\A


    .LINK
        https://celerium.org

#>

<############################################################################################
                                        Code
############################################################################################>
#Requires -Version 5.1
#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.5.0' }

#Region     [ Parameters ]

#Available in Discovery & Run
[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [String]$moduleName = 'Celerium.Auvik',

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]$version,

    [Parameter(Mandatory=$true)]
    [ValidateSet('built','notBuilt')]
    [string]$buildTarget
)

#EndRegion  [ Parameters ]

#Region     [ Prerequisites ]

#Available inside It but NOT Describe or Context
    BeforeAll {

        if ($IsWindows -or $PSEdition -eq 'Desktop') {
            $rootPath = "$( $PSCommandPath.Substring(0, $PSCommandPath.IndexOf('\tests', [System.StringComparison]::OrdinalIgnoreCase)) )"
        }
        else{
            $rootPath = "$( $PSCommandPath.Substring(0, $PSCommandPath.IndexOf('/tests', [System.StringComparison]::OrdinalIgnoreCase)) )"
        }

        switch ($buildTarget) {
            'built'     { $modulePath = Join-Path -Path $rootPath -ChildPath "\build\$moduleName\$version" }
            'notBuilt'  { $modulePath = Join-Path -Path $rootPath -ChildPath "$moduleName" }
        }

        if (Get-Module -Name $moduleName) {
            Remove-Module -Name $moduleName -Force
        }

        $modulePsd1 = Join-Path -Path $modulePath -ChildPath "$moduleName.psd1"

        Import-Module -Name $modulePsd1 -ErrorAction Stop -ErrorVariable moduleError *> $null

        if ($moduleError) {
            $moduleError
            exit 1
        }

    }

    AfterAll{

        Remove-AuvikAPIKey -WarningAction SilentlyContinue

        if (Get-Module -Name $moduleName) {
            Remove-Module -Name $moduleName -Force
        }

    }

#Available in Describe and Context but NOT It
#Can be used in [ It ] with [ -TestCases @{ VariableName = $VariableName } ]
    BeforeDiscovery{

        $pester_TestName = (Get-Item -Path $PSCommandPath).Name
        $commandName = $pester_TestName -replace '.Tests.ps1',''

    }

#EndRegion  [ Prerequisites ]

Describe "Testing [ $commandName ] function with [ $pester_TestName ]" -Tag @('APIKeys') {

    Context "[ $commandName ] testing function" {

        It "When both parameters [ -Username ] & [ -ApiKey ] are called they should not return empty" {
            Add-AuvikAPIKey -Username 'Celerium@Celerium.org' -ApiKey "AuvikKey"
            Get-AuvikAPIKey | Should -Not -BeNullOrEmpty
        }

        It "Pipeline  - [ -Username ] should return a string" {
            "AuvikKey" | Add-AuvikAPIKey -Username 'Celerium@Celerium.org'
            (Get-AuvikAPIKey).UserName | Should -BeOfType String
        }

        It "Pipeline  - [ -ApiKey ] should return a secure string" {
            "AuvikKey" | Add-AuvikAPIKey -Username 'Celerium@Celerium.org'
            (Get-AuvikAPIKey).APIKey | Should -BeOfType SecureString
        }

        It "Parameter - [ -Username ] should return a string" {
            Add-AuvikAPIKey -Username 'Celerium@Celerium.org' -ApiKey "AuvikKey"
            (Get-AuvikAPIKey).UserName | Should -BeOfType String
        }

        It "Parameter - [ -ApiKey ] should return a secure string" {
            Add-AuvikAPIKey -Username 'Celerium@Celerium.org' -ApiKey "AuvikKey"
            (Get-AuvikAPIKey).APIKey | Should -BeOfType SecureString
        }

        It "Using [ -AsPlainText ] should return [ -ApiKey ] as a string" {
            Add-AuvikAPIKey -Username 'Celerium@Celerium.org' -ApiKey "AuvikKey"
            (Get-AuvikAPIKey -AsPlainText).APIKey | Should -BeOfType String
        }

        It "Using [ -AsPlainText ] should return the API key entered" {
            Add-AuvikApiKey -ApiKey '12345'
            Get-AuvikApiKey -AsPlainText | Should -Be '12345'
        }

        It "If [ -ApiKey ] is empty it should throw a warning" {
            Remove-AuvikAPIKey
            Get-AuvikAPIKey -WarningAction SilentlyContinue -WarningVariable APIKeyWarning
            [bool]$APIKeyWarning | Should -BeTrue
        }

    }

}