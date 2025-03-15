<#
    .SYNOPSIS
        Pester tests for the Celerium.Auvik ModuleSetting functions

    .DESCRIPTION
        Pester tests for the Celerium.Auvik ModuleSetting functions

    .PARAMETER moduleName
        The name of the local module to import

    .PARAMETER Version
        The version of the local module to import

    .PARAMETER buildTarget
        Which version of the module to run tests against

        Allowed values:
            'built', 'notBuilt'

    .EXAMPLE
        Invoke-Pester -Path .\Tests\Private\ModuleSetting\Remove-AuvikModuleSetting.Tests.ps1

        Runs a pester test and outputs simple results

    .EXAMPLE
        Invoke-Pester -Path .\Tests\Private\ModuleSetting\Remove-AuvikModuleSetting.Tests.ps1 -Output Detailed

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
        $invalidPath = $(Join-Path -Path $home -ChildPath "invalidApiPath")
        if ($IsWindows -or $PSEdition -eq 'Desktop') {
            $exportPath = $(Join-Path -Path $home -ChildPath "Celerium.Auvik_Test")
        }
        else{
            $exportPath = $(Join-Path -Path $home -ChildPath ".Celerium.Auvik_Test")
        }

        Import-Module -Name $modulePsd1 -ErrorAction Stop -ErrorVariable moduleError *> $null

        if ($moduleError) {
            $moduleError
            exit 1
        }

    }

    AfterAll{

        Remove-AuvikModuleSetting -AuvikConfigPath $exportPath -WarningAction SilentlyContinue

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

Describe "Testing [ $commandName ] function with [ $pester_TestName ]" -Tag @('moduleSettings') {

    Context "[ $commandName ] testing function" {

        It "No configuration should throw a warning" {
            Remove-AuvikModuleSetting -AuvikConfigPath $invalidPath -WarningAction SilentlyContinue -WarningVariable moduleSettingsWarning

            [bool]$moduleSettingsWarning | Should -BeTrue
        }

        It "Saved configuration should be removed" {
            Add-AuvikBaseUri
            Add-AuvikAPIKey -Username 'Celerium@Celerium.org' -ApiKey "AuvikKey"

            Export-AuvikModuleSetting -AuvikConfigPath $exportPath -WarningAction SilentlyContinue
            Remove-AuvikModuleSetting -AuvikConfigPath $exportPath

            Test-Path -Path $exportPath | Should -BeFalse
            [bool](Get-Variable -Name AuvikModuleBaseURI -ErrorAction SilentlyContinue)   | Should -BeTrue
            [bool](Get-Variable -Name AuvikModuleUserName -ErrorAction SilentlyContinue) | Should -BeTrue
            [bool](Get-Variable -Name AuvikModuleApiKey -ErrorAction SilentlyContinue) | Should -BeTrue
        }

        It "Saved configuration & variables should be removed" {
            Add-AuvikBaseUri
            Add-AuvikAPIKey -Username 'Celerium@Celerium.org' -ApiKey "AuvikKey"

            Export-AuvikModuleSetting -AuvikConfigPath $exportPath -WarningAction SilentlyContinue
            Remove-AuvikModuleSetting -AuvikConfigPath $exportPath -AndVariables

            Test-Path -Path $exportPath | Should -BeFalse
            [bool](Get-Variable -Name AuvikModuleBaseURI -ErrorAction SilentlyContinue)   | Should -BeFalse
            [bool](Get-Variable -Name AuvikModuleUserName -ErrorAction SilentlyContinue) | Should -BeFalse
            [bool](Get-Variable -Name AuvikModuleApiKey -ErrorAction SilentlyContinue) | Should -BeFalse
        }

    }

}