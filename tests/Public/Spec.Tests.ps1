<#
.NOTES
    Copyright 1990-2025 Celerium

    NAME: Spec.Tests.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        EMAIL:   celerium@Celerium.org

.SYNOPSIS
    Pester tests that the OpenAPI spec, docs\endpoints.csv, & the module files are in sync

.DESCRIPTION
    Every path & method of docs\Auvik-v1.json (without the leading /v1) must have a function in
    docs\endpoints.csv & every function in docs\endpoints.csv must exist in the module

    These tests fail when the spec & the generated code drift apart. Run build\New-PublicFunctions.ps1
    to generate the functions again

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
    Invoke-Pester -Path .\Spec.Tests.ps1

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

        $TestsPath = $PSScriptRoot
        while ($TestsPath -and -not (Test-Path -Path (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1'))) { $TestsPath = Split-Path -Path $TestsPath -Parent }
        . (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1')

        $PesterTestName = (Get-Item -Path $PSCommandPath).Name

        $SpecEndpoints = @(Get-TestSpecEndpoint -Spec (Get-TestSpec) | ForEach-Object { @{ Path = $_.Path; Method = $_.Method } })

        $CsvFunctions = @((Get-TestEndpointData).Rows | Where-Object { $_.Function } | ForEach-Object { @{ FunctionName = $_.Function; Category = $_.Category } } | Sort-Object { $_.FunctionName } -Unique)

    }

    BeforeAll {

        $TestsPath = $PSScriptRoot
        while ($TestsPath -and -not (Test-Path -Path (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1'))) { $TestsPath = Split-Path -Path $TestsPath -Parent }
        . (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1')

        Import-TestModule -ModuleName $ModuleName -Version $Version -BuildTarget $BuildTarget
        Add-TestHttpGuard -MockModule (Get-TestMockModuleName -CommandName 'Invoke-AuvikRequest')

        $Module         = Get-Module -Name $ModuleName
        $CsvRows        = @((Get-TestEndpointData).Rows)
        $SpecEndpointList = @(Get-TestSpecEndpoint -Spec (Get-TestSpec))

    }

    AfterAll {
        Remove-TestModule -ModuleName $ModuleName
    }

#EndRegion  [ Prerequisites ]

Describe "Testing the [ $BuildTarget ] version of [ $ModuleName ] with [ $PesterTestName ]" {

    Context "[ Auvik-v1.json ] endpoints are implemented" {

        It "[ <Method> <Path> ] is in endpoints.csv with a function" -ForEach $SpecEndpoints {

            $Rows = @($CsvRows | Where-Object { $_.EndpointUri -eq $Path -and $_.Method -eq $Method })

            $Rows.Count | Should -Be 1 -Because "[ $Method $Path ] should be listed once in docs\endpoints.csv"
            $Rows[0].Function | Should -Not -BeNullOrEmpty -Because "[ $Method $Path ] has no function in docs\endpoints.csv"
            $Rows[0].Complete | Should -Be 'Yes'

        }

        It "Every endpoint of endpoints.csv is in the spec" {

            $Unknown = @($CsvRows | Where-Object { $_.EndpointUri } | Where-Object {
                $CsvRow = $_
                -not ($SpecEndpointList | Where-Object { $_.Path -eq $CsvRow.EndpointUri -and $_.Method -eq $CsvRow.Method })
            } | ForEach-Object { "$($_.Method) $($_.EndpointUri)" })

            $Unknown | Should -BeNullOrEmpty -Because "[ $($Unknown -join ', ') ] is in docs\endpoints.csv but not in docs\Auvik-v1.json"

        }

        It "Has no duplicate endpoints in endpoints.csv" {

            $Duplicates = @($CsvRows | Where-Object { $_.EndpointUri } | Group-Object -Property { "$($_.Method) $($_.EndpointUri)" } | Where-Object { $_.Count -gt 1 } | ForEach-Object { $_.Name })

            $Duplicates | Should -BeNullOrEmpty

        }

        It "Has a matching number of endpoints in the spec & endpoints.csv" {
            @($CsvRows | Where-Object { $_.EndpointUri }).Count | Should -Be $SpecEndpointList.Count
        }

        It "Has no endpoints left to implement" {
            @($CsvRows | Where-Object { $_.EndpointUri -and -not $_.Function }).Count | Should -Be 0
        }

    }

    Context "[ endpoints.csv ] functions exist in the module" {

        It "Function [ <FunctionName> ] exists in the module" -ForEach $CsvFunctions {
            $Module.ExportedFunctions.Keys | Should -Contain $FunctionName
        }

        It "Function [ <FunctionName> ] is defined in a file named after the function in the [ <Category> ] folder" -ForEach $CsvFunctions {

            $Folder = if ($Category -eq 'Internal') { 'Private' } else { 'Public' }

            $Files = @(Get-TestModuleFile -ModuleName $ModuleName | Where-Object { $_.BaseName -eq $FunctionName })

            $Files.Count | Should -Be 1
            $Files[0].FullName | Should -Match "[\\/]$Folder[\\/]"
            if ($Category -ne 'Internal') { $Files[0].Directory.Name | Should -Be $Category }

        }

        It "Every function of the module files is in endpoints.csv" {

            $Listed     = @($CsvRows | Where-Object { $_.Function } | ForEach-Object { $_.Function })
            $Defined    = foreach ($ModuleFile in (Get-TestModuleFile -ModuleName $ModuleName)) {
                (Get-TestScriptAst -Path $ModuleFile.FullName).Ast.FindAll({ param ($Node) $Node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false) | ForEach-Object { $_.Name }
            }

            $Missing = @($Defined | Where-Object { $_ -notin $Listed })

            $Missing | Should -BeNullOrEmpty -Because "[ $($Missing -join ', ') ] is defined in the module but not listed in docs\endpoints.csv"

        }

        It "Every function of the public folder implements an endpoint" {

            $PublicFunctions = @($Module.ExportedFunctions.Keys | Where-Object {
                $FunctionName = $_
                (Get-TestModuleFile -ModuleName $ModuleName | Where-Object { $_.BaseName -eq $FunctionName -and $_.FullName -match '[\\/]Public[\\/]' })
            })

            $Implemented = @($CsvRows | Where-Object { $_.EndpointUri } | ForEach-Object { $_.Function })
            $Orphans     = @($PublicFunctions | Where-Object { $_ -notin $Implemented })

            $PublicFunctions.Count | Should -BeGreaterThan 0
            $Orphans | Should -BeNullOrEmpty -Because "[ $($Orphans -join ', ') ] does not implement an endpoint of the spec"

        }

    }

}
