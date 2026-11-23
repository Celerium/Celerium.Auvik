<#
.NOTES
    Copyright 1990-2025 Celerium

    NAME: Repository.Tests.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        EMAIL:   celerium@Celerium.org

.SYNOPSIS
    Pester tests for the coding conventions of the module, build, & test scripts

.DESCRIPTION
    Pester tests that parse every PowerShell script of the module, the build folder, & the tests folder and verify:

        - Every parameter & every variable that is assigned is named in PascalCase
        - The scripts can be read by Windows PowerShell 5.1 (ASCII or UTF8 with a byte order mark)

    The names of automatic & preference variables (such as $_, $PSBoundParameters, & $ErrorActionPreference)
    & the variables of other scopes (such as $env:HOME) are not checked

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
    Invoke-Pester -Path .\Repository.Tests.ps1

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

        $RootPath = Get-TestRootPath

        $ScriptFiles = @(
            Get-TestModuleFile -ModuleName $ModuleName | ForEach-Object { @{ Area = 'module'; FileName = $_.Name; FilePath = $_.FullName } }
            Get-ChildItem -Path (Join-Path -Path $RootPath -ChildPath 'build') -Filter *.ps1 -File | ForEach-Object { @{ Area = 'build'; FileName = $_.Name; FilePath = $_.FullName } }
            Get-ChildItem -Path $TestsPath -Filter *.ps1 -File -Recurse | ForEach-Object { @{ Area = 'tests'; FileName = $_.Name; FilePath = $_.FullName } }
        )

    }

    BeforeAll {

        $TestsPath = $PSScriptRoot
        while ($TestsPath -and -not (Test-Path -Path (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1'))) { $TestsPath = Split-Path -Path $TestsPath -Parent }
        . (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1')

        $PascalCase = '^[A-Z][A-Za-z0-9]*$'

        # Automatic variables, preference variables, & the variables of the PowerShell hosts that can not be renamed
        $IgnoredVariables = @(
            '_', 'PSItem', 'args', 'input', 'this', 'foreach', 'switch', 'matches', 'error', 'true', 'false', 'null',
            'Host', 'Home', 'PWD', 'PID', 'PSBoundParameters', 'MyInvocation', 'PSCmdlet', 'PSScriptRoot', 'PSCommandPath',
            'IsWindows', 'IsLinux', 'IsMacOS', 'IsCoreCLR', 'PSEdition', 'PSVersionTable', 'ExecutionContext', 'LASTEXITCODE',
            'OFS', 'ShellId', 'PSDefaultParameterValues', 'StackTrace', 'PROFILE', 'Event', 'EventArgs', 'EventSubscriber',
            'Sender', 'SourceEventArgs', 'SourceArgs', 'PSCulture', 'PSUICulture', 'NestedPromptLevel', 'ConsoleFileName',
            'MaximumHistoryCount', 'PSSenderInfo', 'PSSessionOption', 'PSEmailServer', 'PSModuleAutoLoadingPreference'
        )

        function Get-TestVariableName {
            # The name of a variable without the scope. Variables of a drive such as $env:HOME return nothing
            param ([System.Management.Automation.Language.VariableExpressionAst]$Variable)

            $Path = $Variable.VariablePath

            if ($Path.IsDriveQualified) { return }

            $Name = $Path.UserPath -replace '^(global|script|local|private|using):', ''

            if ($Name -in $IgnoredVariables -or $Name -like '*Preference') { return }

            return $Name
        }

        function Get-TestParameterOffender {
            param ([string]$Path)

            $Ast = (Get-TestScriptAst -Path $Path).Ast

            foreach ($Parameter in $Ast.FindAll({ param ($Node) $Node -is [System.Management.Automation.Language.ParameterAst] }, $true)) {

                $Name = $Parameter.Name.VariablePath.UserPath
                if ($Name -cnotmatch $PascalCase) { "[ $Name ] parameter on line $($Parameter.Extent.StartLineNumber)" }

            }
        }

        function Get-TestVariableOffender {
            param ([string]$Path)

            $Ast = (Get-TestScriptAst -Path $Path).Ast

            $Variables = [System.Collections.Generic.List[object]]::new()

            # $Name = value, [type]$Name = value, & $First, $Second = values
            foreach ($Assignment in $Ast.FindAll({ param ($Node) $Node -is [System.Management.Automation.Language.AssignmentStatementAst] }, $true)) {

                $Targets = @($Assignment.Left)
                if ($Assignment.Left -is [System.Management.Automation.Language.ArrayLiteralAst]) { $Targets = @($Assignment.Left.Elements) }

                foreach ($Target in $Targets) {

                    while ($Target -is [System.Management.Automation.Language.ConvertExpressionAst]) { $Target = $Target.Child }

                    if ($Target -is [System.Management.Automation.Language.VariableExpressionAst]) { $Variables.Add($Target) }

                }

            }

            foreach ($Loop in $Ast.FindAll({ param ($Node) $Node -is [System.Management.Automation.Language.ForEachStatementAst] }, $true)) { $Variables.Add($Loop.Variable) }

            foreach ($Variable in $Variables) {

                $Name = Get-TestVariableName -Variable $Variable
                if ($Name -and $Name -cnotmatch $PascalCase) { "[ $Name ] variable on line $($Variable.Extent.StartLineNumber)" }

            }

            # -ErrorVariable Name, -WarningVariable Name, -OutVariable Name, -InformationVariable Name, & -PipelineVariable Name
            foreach ($Command in $Ast.FindAll({ param ($Node) $Node -is [System.Management.Automation.Language.CommandAst] }, $true)) {

                $Elements = @($Command.CommandElements)

                for ($Index = 0; $Index -lt $Elements.Count; $Index++) {

                    $Element = $Elements[$Index]
                    if ($Element -isnot [System.Management.Automation.Language.CommandParameterAst]) { continue }
                    if ($Element.ParameterName -notmatch '^(Error|Warning|Out|Information|Pipeline)Variable$|^(EV|WV|OV|IV|PV)$') { continue }

                    $Value = if ($Element.Argument) { $Element.Argument } elseif ($Index + 1 -lt $Elements.Count) { $Elements[$Index + 1] }
                    if ($Value -isnot [System.Management.Automation.Language.StringConstantExpressionAst]) { continue }

                    $Name = $Value.Value -replace '^\+', ''
                    if ($Name -cnotmatch $PascalCase) { "[ $Name ] variable of -$($Element.ParameterName) on line $($Element.Extent.StartLineNumber)" }

                }

            }
        }

    }

#EndRegion  [ Prerequisites ]

Describe "Testing the [ $BuildTarget ] version of [ $ModuleName ] with [ $PesterTestName ]" {

    Context "Parameter names are PascalCase" {

        It "Has only PascalCase parameters in the [ <Area> ] file [ <FileName> ]" -ForEach $ScriptFiles {

            $Offenders = @(Get-TestParameterOffender -Path $FilePath)

            $Offenders | Should -BeNullOrEmpty -Because "parameters should be PascalCase:`n$($Offenders -join "`n")"

        }

    }

    Context "Variable names are PascalCase" {

        It "Has only PascalCase variables in the [ <Area> ] file [ <FileName> ]" -ForEach $ScriptFiles {

            $Offenders = @(Get-TestVariableOffender -Path $FilePath)

            $Offenders | Should -BeNullOrEmpty -Because "variables should be PascalCase:`n$($Offenders -join "`n")"

        }

    }

    Context "Scripts" {

        It "Can be parsed without errors: [ <Area> ] file [ <FileName> ]" -ForEach $ScriptFiles {

            # Scripts that need PowerShell 7 can not be parsed by Windows PowerShell
            $ParsedScript = Get-TestScriptAst -Path $FilePath

            if ($PSVersionTable.PSVersion.Major -lt 7 -and $ParsedScript.Ast.ScriptRequirements.RequiredPSVersion.Major -ge 7) {
                Set-ItResult -Skipped -Because 'the script requires PowerShell 7'
                return
            }

            $ParsedScript.ParseErrors | Should -BeNullOrEmpty
        }

        It "Can be read by Windows PowerShell: [ <Area> ] file [ <FileName> ]" -ForEach $ScriptFiles {

            # Windows PowerShell reads a file without a byte order mark as ANSI, so every character must be ASCII
            $Bytes      = [System.IO.File]::ReadAllBytes($FilePath)
            $HasBom     = ($Bytes.Count -ge 3 -and $Bytes[0] -eq 239 -and $Bytes[1] -eq 187 -and $Bytes[2] -eq 191)
            $NonAscii   = @($Bytes | Where-Object { $_ -gt 127 }).Count

            ($HasBom -or $NonAscii -eq 0) | Should -BeTrue -Because "the file has $NonAscii non ASCII bytes & no byte order mark"

        }

    }

}
