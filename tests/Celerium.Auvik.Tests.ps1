<#
.NOTES
    Copyright 1990-2025 Celerium

    NAME: Celerium.Auvik.Tests.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        EMAIL:   celerium@Celerium.org

.SYNOPSIS
    Pester tests for the Celerium.Auvik module manifest file

.DESCRIPTION
    Pester tests for the Celerium.Auvik module manifest file & the import of the module

    The expected values are calculated from the module files on disk, so adding or
    removing a function does not require any changes to this file

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
    Invoke-Pester -Path .\Celerium.Auvik.Tests.ps1

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

#Available in Describe and Context but NOT It
#Can be used in [ It ] with [ -TestCases @{ VariableName = $VariableName } ]
    BeforeDiscovery {

        $TestsPath = $PSScriptRoot
        while ($TestsPath -and -not (Test-Path -Path (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1'))) { $TestsPath = Split-Path -Path $TestsPath -Parent }
        . (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1')

        $PesterTestName = (Get-Item -Path $PSCommandPath).Name

        # The functions & aliases defined by the source files of the module
        $DiscoveredFunctions = [System.Collections.Generic.List[string]]::new()
        $DiscoveredAliases   = [System.Collections.Generic.List[string]]::new()

        foreach ($ModuleFile in (Get-TestModuleFile -ModuleName $ModuleName)) {

            $ParsedFile = Get-TestScriptAst -Path $ModuleFile.FullName
            foreach ($Function in $ParsedFile.Ast.FindAll({ param ($Node) $Node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false)) { $DiscoveredFunctions.Add($Function.Name) }

            foreach ($AliasMatch in [regex]::Matches((Get-Content -Path $ModuleFile.FullName -Raw), "(?im)^\s*Set-Alias\s+-Name\s+['""]?([\w-]+)")) { $DiscoveredAliases.Add($AliasMatch.Groups[1].Value) }

        }

        $FunctionCases = @($DiscoveredFunctions | Sort-Object | ForEach-Object { @{ FunctionName = $_ } })
        $AliasCases    = @($DiscoveredAliases | Sort-Object | ForEach-Object { @{ AliasName = $_ } })

    }

#Available inside It but NOT Describe or Context
    BeforeAll {

        $TestsPath = $PSScriptRoot
        while ($TestsPath -and -not (Test-Path -Path (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1'))) { $TestsPath = Split-Path -Path $TestsPath -Parent }
        . (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1')

        $ModulePath = Get-TestModulePath -ModuleName $ModuleName -Version $Version -BuildTarget $BuildTarget
        $ModulePsd1 = Join-Path -Path $ModulePath -ChildPath "$ModuleName.psd1"
        $ModulePsm1 = Join-Path -Path $ModulePath -ChildPath "$ModuleName.psm1"

        Import-TestModule -ModuleName $ModuleName -Version $Version -BuildTarget $BuildTarget
        Add-TestHttpGuard -MockModule (Get-TestMockModuleName -CommandName 'Invoke-AuvikRequest')

        $Module         = Get-Module -Name $ModuleName
        $ManifestData   = Import-PowerShellDataFile -Path $ModulePsd1
        $ModuleFiles    = @(Get-ChildItem -Path $ModulePath -File -Recurse)

        $SourceFiles    = @(Get-TestModuleFile -ModuleName $ModuleName)

        $SourceFunctions = foreach ($SourceFile in $SourceFiles) {
            (Get-TestScriptAst -Path $SourceFile.FullName).Ast.FindAll({ param ($Node) $Node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false) | ForEach-Object { $_.Name }
        }
        $SourceFunctions = @($SourceFunctions | Sort-Object)

        # Files that only run code & do not define a function, such as Initialize-AuvikModuleSetting.ps1
        $ScriptOnlyFiles = @($SourceFiles | Where-Object {
            -not (Get-TestScriptAst -Path $_.FullName).Ast.FindAll({ param ($Node) $Node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false)
        } | ForEach-Object { $_.BaseName })

        $SourceAliases = foreach ($SourceFile in $SourceFiles) {
            [regex]::Matches((Get-Content -Path $SourceFile.FullName -Raw), "(?im)^\s*Set-Alias\s+-Name\s+['""]?([\w-]+)") | ForEach-Object { $_.Groups[1].Value }
        }
        $SourceAliases = @($SourceAliases | Sort-Object)

    }

    AfterAll {
        Remove-TestModule -ModuleName $ModuleName
    }

#EndRegion  [ Prerequisites ]

Describe "Testing the [ $BuildTarget ] version of [ $ModuleName ] with [ $PesterTestName ]" {

    Context "[ $ModuleName.psd1 ] general manifest data" {

        It "Manifest [ RootModule ] has valid data" {
            $Module.RootModule | Should -Be 'Celerium.Auvik.psm1'
        }

        It "Manifest [ ModuleVersion ] has valid data" {
            $Module.Version | Should -BeGreaterOrEqual ([version]$Version)
        }

        It "Manifest [ CompatiblePSEditions ] has valid data" {
            $ManifestData.CompatiblePSEditions | Should -Contain 'Desktop'
            $ManifestData.CompatiblePSEditions | Should -Contain 'Core'
        }

        It "Manifest [ GUID ] has valid data" {
            $Module.GUID | Should -Be 'c12d0f6b-e5fa-476f-b3cc-88bac180a278'
        }

        It "Manifest [ GUID ] starts with c12 (Celerium standard)" {
            $Module.GUID.ToString() | Should -Match '^c12'
        }

        It "Manifest [ Author ] has valid data" {
            $Module.Author | Should -Be 'David Schulte'
        }

        It "Manifest [ CompanyName ] has valid data" {
            $Module.CompanyName | Should -Be 'Celerium'
        }

        It "Manifest [ Copyright ] has valid data" {
            $Module.Copyright | Should -Be 'https://github.com/Celerium/Celerium.Auvik/blob/main/LICENSE'
        }

        It "Manifest [ Description ] is not empty" {
            $Module.Description | Should -Not -BeNullOrEmpty
        }

        It "Manifest [ PowerShellVersion ] has valid data" {
            $Module.PowerShellVersion | Should -Be ([version]'5.1')
        }

        It "Manifest [ NestedModules ] has valid data" {

            switch ($BuildTarget) {
                'built'     { @($Module.NestedModules).Count | Should -Be 0 }
                'notBuilt'  {
                    @($Module.NestedModules).Count | Should -Be $SourceFiles.Count
                    @($ManifestData.NestedModules).Count | Should -Be $SourceFiles.Count
                }
            }

        }

        It "Manifest [ NestedModules ] lists every module file & only existing files" -Skip:($BuildTarget -eq 'built') {

            $Listed = @($ManifestData.NestedModules | ForEach-Object { ($_ -replace '\\', '/') } | Sort-Object)
            $Actual = @($SourceFiles | ForEach-Object { $_.FullName.Substring((Join-Path -Path (Get-TestRootPath) -ChildPath $ModuleName).Length + 1) -replace '\\', '/' } | Sort-Object)

            $Missing = @($Actual | Where-Object { $_ -notin $Listed })
            $Missing | Should -BeNullOrEmpty -Because "[ $($Missing -join ', ') ] exists but is not listed in NestedModules"

            $Stale = @($Listed | Where-Object { $_ -notin $Actual })
            $Stale | Should -BeNullOrEmpty -Because "[ $($Stale -join ', ') ] is listed in NestedModules but does not exist"

        }

        It "Manifest [ FunctionsToExport ] does not use wildcards" {
            @($ManifestData.FunctionsToExport).Count | Should -BeGreaterThan 0
            @($ManifestData.FunctionsToExport | Where-Object { $_ -match '[*?\[]' }) | Should -BeNullOrEmpty
        }

        It "Manifest [ FunctionsToExport ] matches the functions defined in the module files" {

            $Exported = @($ManifestData.FunctionsToExport | Sort-Object)

            $Missing = @($SourceFunctions | Where-Object { $_ -notin $Exported })
            $Missing | Should -BeNullOrEmpty -Because "[ $($Missing -join ', ') ] is defined in the module files but is not listed in FunctionsToExport"

            # The build lists the name of every file in FunctionsToExport, including the files that only run code. PowerShell ignores
            # a name that is not a function, so it is only tolerated in the built manifest
            $Allowed = if ($BuildTarget -eq 'built') { @($SourceFunctions) + @($ScriptOnlyFiles) } else { @($SourceFunctions) }

            $Stale = @($Exported | Where-Object { $_ -notin $Allowed })
            $Stale | Should -BeNullOrEmpty -Because "[ $($Stale -join ', ') ] is listed in FunctionsToExport but is not defined in the module files"

        }

        It "Module exports exactly the functions defined in the module files" {
            $Actual = @($Module.ExportedFunctions.Keys | Sort-Object)
            $Actual | Should -Be $SourceFunctions
        }

        It "Module [ ExportedCommands ] only contains functions & aliases" {
            @($Module.ExportedCommands.Values | Where-Object { $_.CommandType -notin 'Function', 'Alias' }) | Should -BeNullOrEmpty
        }

        It "Manifest [ CmdletsToExport ] is empty" {
            @($Module.ExportedCmdlets.Keys).Count | Should -Be 0
            @($ManifestData.CmdletsToExport).Count | Should -Be 0
        }

        It "Manifest [ VariablesToExport ] is empty" {
            @($Module.ExportedVariables.Keys).Count | Should -Be 0
            @($ManifestData.VariablesToExport).Count | Should -Be 0
        }

        It "Manifest [ AliasesToExport ] does not use wildcards" {
            @($ManifestData.AliasesToExport | Where-Object { $_ -match '[*?\[]' }) | Should -BeNullOrEmpty
        }

        It "Manifest [ AliasesToExport ] matches the aliases defined in the module files" {

            $Exported = @($ManifestData.AliasesToExport | Sort-Object)

            $Missing = @($SourceAliases | Where-Object { $_ -notin $Exported })
            $Missing | Should -BeNullOrEmpty -Because "[ $($Missing -join ', ') ] is defined in the module files but is not listed in AliasesToExport"

            $Stale = @($Exported | Where-Object { $_ -notin $SourceAliases })
            $Stale | Should -BeNullOrEmpty -Because "[ $($Stale -join ', ') ] is listed in AliasesToExport but is not defined in the module files"

        }

        It "Manifest [ Tags ] has valid data" {
            $Module.PrivateData.PSData.Tags | Should -Contain 'Auvik'
            $Module.PrivateData.PSData.Tags | Should -Contain 'Celerium'
            $Module.PrivateData.PSData.Tags | Should -Contain 'PSEdition_Desktop'
            $Module.PrivateData.PSData.Tags | Should -Contain 'PSEdition_Core'
            @($Module.PrivateData.PSData.Tags).Count | Should -BeGreaterOrEqual 7
        }

        It "Manifest [ LicenseUri ] has valid data" {
            $Module.LicenseUri | Should -Be 'https://github.com/Celerium/Celerium.Auvik/blob/main/LICENSE'
        }

        It "Manifest [ ProjectUri ] has valid data" {
            $Module.ProjectUri | Should -Be 'https://github.com/Celerium/Celerium.Auvik'
        }

        It "Manifest [ IconUri ] has valid data" {
            $Module.IconUri | Should -Be 'https://raw.githubusercontent.com/Celerium/Celerium.Auvik/main/.github/images/Celerium_PoSHGallery_Celerium.Auvik.png'
        }

        It "Manifest [ ReleaseNotes ] has valid data" {
            $Module.ReleaseNotes | Should -Be 'https://github.com/Celerium/Celerium.Auvik/blob/main/README.md'
        }

        It "Manifest [ HelpInfoUri ] is empty" {
            $Module.HelpInfoUri | Should -BeNullOrEmpty
        }

    }

    Context "[ $ModuleName.psd1 ] exported functions" {

        It "Function [ <FunctionName> ] is defined in the module files & exported" -ForEach $FunctionCases {
            $Module.ExportedFunctions.Keys | Should -Contain $FunctionName
            Get-Command -Name $FunctionName -Module $ModuleName -CommandType Function | Should -Not -BeNullOrEmpty
        }

        It "Alias [ <AliasName> ] is defined in the module files & exported" -ForEach $AliasCases {
            $Module.ExportedAliases.Keys | Should -Contain $AliasName
            (Get-Alias -Name $AliasName).ResolvedCommand | Should -Not -BeNullOrEmpty
        }

    }

    Context "[ $ModuleName.psd1 ] module import test" {

        It "Module contains only PowerShell files (& the OpenAPI spec in the built module)" {
            $Allowed = @('.ps1', '.psm1', '.psd1')
            if ($BuildTarget -eq 'built') { $Allowed += '.json' }

            $Extensions = @($ModuleFiles | ForEach-Object { $_.Extension.ToLowerInvariant() } | Sort-Object -Unique)
            @($Extensions | Where-Object { $_ -notin $Allowed }) | Should -BeNullOrEmpty
        }

        It "The built module includes the OpenAPI spec" -Skip:($BuildTarget -ne 'built') {
            @($ModuleFiles | Where-Object { $_.Name -like 'Auvik-*.json' }).Count | Should -Be 1
        }

        It "Module files exist" {
            $ModulePsd1 | Should -Exist
            $ModulePsm1 | Should -Exist
        }

        It "Should pass Test-ModuleManifest" {
            $Result = Test-ModuleManifest -Path $ModulePsd1 -ErrorAction Stop
            $Result.Name | Should -Be $ModuleName
        }

        It "Should import successfully without errors or warnings" {

            Remove-Module -Name $ModuleName -Force

            $null = Import-Module -Name $ModulePsd1 -Force -ErrorAction Stop -ErrorVariable ImportError -WarningVariable ImportWarning -PassThru
            @($ImportError) | Should -BeNullOrEmpty
            @($ImportWarning) | Should -BeNullOrEmpty
            Get-Module -Name $ModuleName | Should -Not -BeNullOrEmpty

            Reset-TestModuleState

        }

        It "Should load the default settings when imported" {

            Remove-TestState
            Import-Module -Name $ModulePsd1 -Force -ErrorAction Stop

            # The user configuration file could have been loaded, so only check that the values exist
            Get-AuvikBaseURI | Should -Match '^https://'
            $AuvikJSONConversionDepth | Should -BeGreaterThan 0

            Reset-TestModuleState

        }

    }

}
