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
        Invoke-Pester -Path .\Tests\Private\APIKeys\Remove-AuvikAPIKey.Tests.ps1

        Runs a pester test and outputs simple results

    .EXAMPLE
        Invoke-Pester -Path .\Tests\Private\APIKeys\Remove-AuvikAPIKey.Tests.ps1 -Output Detailed

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

        It "Running [ $commandName ] should remove all APIKey variables" {
            Add-AuvikAPIKey -Username 'Celerium@Celerium.org' -ApiKey "AuvikKey"
            Remove-AuvikAPIKey
            $AuvikModuleUserName | Should -BeNullOrEmpty
            $AuvikModuleApiKey | Should -BeNullOrEmpty
        }

        It "If the [ AuvikModuleUserName ] is already empty a warning should be thrown" {
            Add-AuvikAPIKey -Username 'Celerium@Celerium.org' -ApiKey "AuvikKey"
            Remove-Variable -Name "AuvikModuleUserName" -Scope global -Force

            Remove-AuvikAPIKey -WarningAction SilentlyContinue -WarningVariable APIKeyWarning
            $APIKeyWarning | Should -Be "The Auvik API [ username ] is not set. Nothing to remove"
        }

        It "If the [ AuvikApiKey ] is already empty a warning should be thrown" {
            Add-AuvikAPIKey -Username 'Celerium@Celerium.org' -ApiKey "AuvikKey"
            Remove-Variable -Name "AuvikModuleApiKey" -Scope global -Force

            Remove-AuvikAPIKey -WarningAction SilentlyContinue -WarningVariable APIKeyWarning
            $APIKeyWarning | Should -Be "The Auvik API [ API ] key is not set. Nothing to remove"
        }

        It "If the APIKeys are already gone two warnings should be thrown" {
            Add-AuvikAPIKey -Username 'Celerium@Celerium.org' -ApiKey "AuvikKey"
            Remove-AuvikAPIKey

            Remove-AuvikAPIKey -WarningAction SilentlyContinue -WarningVariable APIKeyWarning
            $APIKeyWarning.Count | Should -Be '2'
        }

    }

}