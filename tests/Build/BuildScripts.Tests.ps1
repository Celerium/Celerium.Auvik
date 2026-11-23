<#
.NOTES
    Copyright 1990-2025 Celerium

    NAME: BuildScripts.Tests.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        EMAIL:   celerium@Celerium.org

.SYNOPSIS
    Pester tests for the scripts in the build folder

.DESCRIPTION
    Pester tests for the scripts in the build folder

    Every script is parsed & the help of Compare-AuvikSpec.ps1 & Get-AuvikSpec.ps1 is checked. Both scripts are
    also run against specs in the Pester TestDrive. Invoke-WebRequest is mocked so these tests are offline

    The tests tagged with 'Online' download the online spec & are excluded by default

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
    Invoke-Pester -Path .\BuildScripts.Tests.ps1

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

        $BuildPath = Join-Path -Path (Get-TestRootPath) -ChildPath 'build'

        $BuildScripts = @(Get-ChildItem -Path $BuildPath -Filter *.ps1 -File | Sort-Object -Property Name | ForEach-Object {

            $ParsedScript = Get-TestScriptAst -Path $_.FullName

            @{
                ScriptName      = $_.Name
                ScriptPath      = $_.FullName
                HasModuleName   = [bool]$ParsedScript.Ast.ParamBlock.Parameters.Where({ $_.Name.VariablePath.UserPath -eq 'ModuleName' })
                RequiresPwsh7   = ($ParsedScript.Ast.ScriptRequirements -and $ParsedScript.Ast.ScriptRequirements.RequiredPSVersion -and $ParsedScript.Ast.ScriptRequirements.RequiredPSVersion.Major -ge 7)
            }

        })

        # Scripts that need PowerShell 7 can not be parsed by Windows PowerShell
        $ParseScripts      = @($BuildScripts | Where-Object { -not ($_.RequiresPwsh7 -and $PSVersionTable.PSVersion.Major -lt 7) })
        $ModuleNameScripts = @($BuildScripts | Where-Object { $_.HasModuleName })

        $HelpScripts = @($BuildScripts | Where-Object { $_.ScriptName -in 'Compare-AuvikSpec.ps1', 'Get-AuvikSpec.ps1' })

    }

    BeforeAll {

        $TestsPath = $PSScriptRoot
        while ($TestsPath -and -not (Test-Path -Path (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1'))) { $TestsPath = Split-Path -Path $TestsPath -Parent }
        . (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1')

        $RootPath       = Get-TestRootPath
        $BuildPath      = Join-Path -Path $RootPath -ChildPath 'build'
        $ComparePath    = Join-Path -Path $BuildPath -ChildPath 'Compare-AuvikSpec.ps1'
        $SavePath       = Join-Path -Path $BuildPath -ChildPath 'Get-AuvikSpec.ps1'
        $SpecPath       = Join-Path -Path (Join-Path -Path $RootPath -ChildPath 'docs') -ChildPath 'Auvik-v1.json'

        $SpecText       = [System.IO.File]::ReadAllText($SpecPath, [System.Text.Encoding]::UTF8)
        $Utf8NoBom      = [System.Text.UTF8Encoding]::new($false)
        $FakeUri        = 'https://auvik.example.invalid/spec'

        # A small spec so the comparison is quick. The real spec is only used by one test
        $MiniText = @"
{
  "openapi": "3.0.1",
  "info": {
    "title": "Mini API",
    "version": "v1"
  },
  "servers": [
    {
      "url": "https://example.invalid"
    }
  ],
  "paths": {
    "/v1/authentication/verify": {
      "get": {
        "summary": "Verify Credentials",
        "operationId": "verifyCredentials",
        "responses": {
          "200": {
            "description": "Your credentials are valid."
          }
        }
      }
    },
    "/v1/tenants": {
      "get": {
        "summary": "Read Tenants",
        "parameters": [
          {
            "name": "filter[stateKnown]",
            "in": "query",
            "schema": {
              "type": "boolean"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "Successful operation"
          }
        }
      }
    },
    "/v1/inventory/device/info": {
      "get": {
        "summary": "Read Devices",
        "parameters": [
          {
            "name": "filter[onlineStatus]",
            "in": "query",
            "schema": {
              "type": "string",
              "enum": [
                "online",
                "offline",
                "unknown"
              ]
            }
          }
        ],
        "responses": {
          "200": {
            "description": "Successful operation"
          }
        }
      }
    },
    "/v1/alert/dismiss/{id}": {
      "post": {
        "summary": "Dismiss an Alert",
        "parameters": [
          {
            "name": "id",
            "in": "path",
            "required": true,
            "schema": {
              "type": "string"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "Successful operation"
          }
        }
      }
    }
  },
  "components": {
    "schemas": {
      "basicError": {
        "title": "JSON API Error Object",
        "type": "object",
        "required": [
          "errors"
        ]
      },
      "tenant": {
        "type": "object",
        "properties": {
          "id": {
            "type": "string"
          }
        }
      }
    }
  }
}
"@
        $MiniPath = Join-Path -Path $TestDrive -ChildPath 'mini-spec.json'
        [System.IO.File]::WriteAllText($MiniPath, $MiniText, $Utf8NoBom)

        # Mocks that are called from a script are found because the script runs in a child scope of the test
        # The mock body shares the response with the test through a global variable that starts with AuvikTest
        Mock Invoke-WebRequest -MockWith {
            if ($global:AuvikTestWebError) { throw $global:AuvikTestWebError }
            return [PSCustomObject]@{ RawContentStream = [System.IO.MemoryStream]::new([System.Text.Encoding]::UTF8.GetBytes($global:AuvikTestWebContent)) }
        }

        function Edit-TestSpecText {
            # Replaces text of the spec & makes sure the text was found, so a test can not pass because nothing changed
            param (
                [string]$Text,
                [string]$Old,
                [string]$New
            )

            $Text.Contains($Old) | Should -BeTrue -Because "[ $Old ] should be in the spec"
            return $Text.Replace($Old, $New)
        }

        function Write-TestSpec {
            param (
                [string]$Path,
                [string]$Text
            )

            [System.IO.File]::WriteAllText($Path, $Text, $Utf8NoBom)
            return $Path
        }

        function Invoke-TestCompare {
            # Runs the script like a user would & returns the output of the script
            param (
                [string]$LocalPath,
                [string]$OnlineContent,
                [switch]$Detailed
            )

            $global:AuvikTestWebContent = $OnlineContent

            if ($Detailed) { & $ComparePath -LocalPath $LocalPath -Uri $FakeUri -Detailed -WarningAction SilentlyContinue }
            else { & $ComparePath -LocalPath $LocalPath -Uri $FakeUri -WarningAction SilentlyContinue }
        }

    }

    AfterAll {
        Remove-TestState
    }

#EndRegion  [ Prerequisites ]

Describe "Testing the [ $BuildTarget ] version of [ $ModuleName ] with [ $PesterTestName ]" {

    BeforeEach {
        $global:AuvikTestWebError   = $null
        $global:AuvikTestWebContent = $null
    }

    Context "Build scripts" {

        It "[ <ScriptName> ] is a valid PowerShell script" -ForEach $ParseScripts {

            (Get-TestScriptAst -Path $ScriptPath).ParseErrors | Should -BeNullOrEmpty
        }

        It "[ <ScriptName> ] has a ModuleName parameter that defaults to Celerium.Auvik" -ForEach $ModuleNameScripts {

            $Ast        = (Get-TestScriptAst -Path $ScriptPath).Ast
            $Parameter  = $Ast.ParamBlock.Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'ModuleName' }

            $Parameter.DefaultValue.Value | Should -Be 'Celerium.Auvik'

        }

        It "[ <ScriptName> ] has comment based help with a synopsis, a description, & an example" -ForEach $HelpScripts {

            $Help = (Get-TestScriptAst -Path $ScriptPath).Ast.GetHelpContent()

            $Help.Synopsis | Should -Not -BeNullOrEmpty
            $Help.Description | Should -Not -BeNullOrEmpty
            @($Help.Examples).Count | Should -BeGreaterOrEqual 1
            @($Help.Links).Count | Should -BeGreaterOrEqual 1

        }

        It "[ <ScriptName> ] documents every parameter" -ForEach $HelpScripts {

            $Ast        = (Get-TestScriptAst -Path $ScriptPath).Ast
            $Help       = $Ast.GetHelpContent()
            $Declared   = @($Ast.ParamBlock.Parameters | ForEach-Object { $_.Name.VariablePath.UserPath })

            $Undocumented = @($Declared | Where-Object { -not $Help.Parameters.ContainsKey($_.ToUpperInvariant()) -or -not $Help.Parameters[$_.ToUpperInvariant()] })

            $Undocumented | Should -BeNullOrEmpty -Because "[ $($Undocumented -join ', ') ] should have a .PARAMETER section"

        }

        It "[ <ScriptName> ] has parameters that are documented & declared" -ForEach $HelpScripts {

            $Ast        = (Get-TestScriptAst -Path $ScriptPath).Ast
            $Help       = $Ast.GetHelpContent()
            $Declared   = @($Ast.ParamBlock.Parameters | ForEach-Object { $_.Name.VariablePath.UserPath.ToUpperInvariant() })

            $Stale = @($Help.Parameters.Keys | Where-Object { $_ -notin $Declared })

            $Stale | Should -BeNullOrEmpty -Because "[ $($Stale -join ', ') ] is documented but is not a parameter"

        }

    }

    Context "[ Compare-AuvikSpec.ps1 ] comparing the specs" {

        It "Finds no differences when the specs are identical" {

            $Result = Invoke-TestCompare -LocalPath $MiniPath -OnlineContent $MiniText

            $Result.Differs | Should -BeFalse
            $Result.ChangeCount | Should -Be 0
            $Result.LocalEndpointCount | Should -Be $Result.OnlineEndpointCount
            $Result.LocalEndpointCount | Should -BeGreaterThan 0
            @($Result.EndpointsAdded).Count | Should -Be 0
            @($Result.EndpointsRemoved).Count | Should -Be 0
            @($Result.EndpointsChanged).Count | Should -Be 0
            @($Result.SchemasAdded).Count | Should -Be 0
            @($Result.SchemasRemoved).Count | Should -Be 0
            @($Result.SchemasChanged).Count | Should -Be 0

        }

        It "Downloads the spec from the Uri" {

            $null = Invoke-TestCompare -LocalPath $MiniPath -OnlineContent $MiniText

            Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ParameterFilter { $Uri -eq $FakeUri }

        }

        It "Returns the paths, versions, & uri that were compared" {

            $Result = Invoke-TestCompare -LocalPath $MiniPath -OnlineContent $MiniText

            $Result.LocalPath | Should -Be $MiniPath
            $Result.Uri | Should -Be $FakeUri
            $Result.LocalVersion | Should -Be 'v1'
            $Result.OnlineVersion | Should -Be 'v1'

        }

        It "Counts the endpoints of the local spec" {

            $Result = Invoke-TestCompare -LocalPath $MiniPath -OnlineContent $MiniText

            $Result.LocalEndpointCount | Should -Be 4

        }

        # The comparison of the real spec takes minutes in Windows PowerShell 5.1
        It "Finds no differences when the local spec is compared to itself" -Skip:($PSVersionTable.PSVersion.Major -lt 7) {

            $Result = Invoke-TestCompare -LocalPath $SpecPath -OnlineContent $SpecText

            $Result.Differs | Should -BeFalse
            $Result.ChangeCount | Should -Be 0
            $Result.LocalEndpointCount | Should -Be @(Get-TestSpecEndpoint -Spec (Get-TestSpec)).Count

        }

        It "Ignores differences in formatting" {

            $Windows = $MiniText.Replace("`r`n", "`n").Replace("`n", "`r`n")

            $Result = Invoke-TestCompare -LocalPath $MiniPath -OnlineContent $Windows

            $Result.Differs | Should -BeFalse

        }

        It "Ignores the order of an enum" {

            $Reordered = [regex]::Replace($MiniText, '"online",(\s*)"offline",', '"offline",$1"online",')
            $Reordered | Should -Not -BeExactly $MiniText

            (Invoke-TestCompare -LocalPath $MiniPath -OnlineContent $Reordered).Differs | Should -BeFalse

        }

        It "Finds endpoints that were added & removed" {

            # The online spec has /tenants, the local spec has /tenantsRenamed
            $Local = Write-TestSpec -Path (Join-Path -Path $TestDrive -ChildPath 'renamed.json') -Text (Edit-TestSpecText -Text $MiniText -Old '"/v1/tenants"' -New '"/v1/tenantsRenamed"')

            $Result = Invoke-TestCompare -LocalPath $Local -OnlineContent $MiniText

            $Result.Differs | Should -BeTrue
            (@($Result.EndpointsAdded) -join ',') | Should -Be 'GET /tenants'
            (@($Result.EndpointsRemoved) -join ',') | Should -Be 'GET /tenantsRenamed'
            @($Result.EndpointsChanged).Count | Should -Be 0
            $Result.LocalEndpointCount | Should -Be $Result.OnlineEndpointCount

        }

        It "Finds an endpoint that was removed from the online spec" {

            $Online = Edit-TestSpecText -Text $MiniText -Old '"/v1/tenants"' -New '"/v1/tenantsRenamed"'

            $Result = Invoke-TestCompare -LocalPath $MiniPath -OnlineContent $Online

            $Result.Differs | Should -BeTrue
            (@($Result.EndpointsRemoved) -join ',') | Should -Be 'GET /tenants'
            (@($Result.EndpointsAdded) -join ',') | Should -Be 'GET /tenantsRenamed'

        }

        It "Finds an endpoint that changed" {

            $Online = Edit-TestSpecText -Text $MiniText -Old '"summary": "Verify Credentials"' -New '"summary": "Verify The Credentials"'

            $Result = Invoke-TestCompare -LocalPath $MiniPath -OnlineContent $Online

            $Result.Differs | Should -BeTrue
            (@($Result.EndpointsChanged) -join ',') | Should -Be 'GET /authentication/verify'
            @($Result.EndpointsAdded).Count | Should -Be 0
            @($Result.EndpointsRemoved).Count | Should -Be 0
            $Result.ChangeCount | Should -Be 1

        }

        It "Finds a parameter that changed" {

            $Online = Edit-TestSpecText -Text $MiniText -Old '"name": "filter[stateKnown]",' -New '"name": "filter[stateKnownRenamed]",'

            $Result = Invoke-TestCompare -LocalPath $MiniPath -OnlineContent $Online

            $Result.Differs | Should -BeTrue
            $Result.EndpointsChanged | Should -Contain 'GET /tenants'

        }

        It "Finds a schema that changed" {

            $Online = Edit-TestSpecText -Text $MiniText -Old '"title": "JSON API Error Object"' -New '"title": "JSON API Error Object Changed"'

            $Result = Invoke-TestCompare -LocalPath $MiniPath -OnlineContent $Online

            $Result.Differs | Should -BeTrue
            $Result.SchemasChanged | Should -Contain 'basicError'
            @($Result.SchemasAdded).Count | Should -Be 0
            @($Result.SchemasRemoved).Count | Should -Be 0

        }

        It "Lists every change with -Detailed" {

            $Online = Edit-TestSpecText -Text $MiniText -Old '"summary": "Verify Credentials"' -New '"summary": "Verify The Credentials"'

            $Result = Invoke-TestCompare -LocalPath $MiniPath -OnlineContent $Online -Detailed

            @($Result.Changes).Count | Should -Be 1
            $Result.Changes[0].Change | Should -Be 'Changed'
            $Result.Changes[0].Pointer | Should -Be '/paths/~1authentication~1verify/get/summary'
            $Result.Changes[0].Local | Should -Be 'Verify Credentials'
            $Result.Changes[0].Online | Should -Be 'Verify The Credentials'

        }

        It "Does not list the changes without -Detailed" {

            $Online = Edit-TestSpecText -Text $MiniText -Old '"summary": "Verify Credentials"' -New '"summary": "Verify The Credentials"'

            (Invoke-TestCompare -LocalPath $MiniPath -OnlineContent $Online).PSObject.Properties.Name | Should -Not -Contain 'Changes'

        }

        It "Warns when the specs are different" {

            $global:AuvikTestWebContent = Edit-TestSpecText -Text $MiniText -Old '"summary": "Verify Credentials"' -New '"summary": "Verify The Credentials"'

            $null = & $ComparePath -LocalPath $MiniPath -Uri $FakeUri -WarningVariable CompareWarning -WarningAction SilentlyContinue

            "$CompareWarning" | Should -Match 'different than the online spec'

        }

        It "Ignores the version in the path of the endpoints" {

            # An online spec that defines the version in the server url instead of in every path
            $Online = $MiniText.Replace('"/v1/', '"/')

            $Result = Invoke-TestCompare -LocalPath $MiniPath -OnlineContent $Online

            @($Result.EndpointsAdded).Count | Should -Be 0
            @($Result.EndpointsRemoved).Count | Should -Be 0

        }

    }

    Context "[ Compare-AuvikSpec.ps1 ] failures" {

        It "Writes an error when the local spec does not exist" {

            $global:AuvikTestWebContent = $MiniText

            $Result = & $ComparePath -LocalPath (Join-Path -Path $TestDrive -ChildPath 'missing.json') -Uri $FakeUri -ErrorAction SilentlyContinue -ErrorVariable CompareError

            $Result | Should -BeNullOrEmpty
            "$CompareError" | Should -Match 'local spec was not found'

        }

        It "Does not download anything when the local spec does not exist" {

            $global:AuvikTestWebContent = $MiniText

            $null = & $ComparePath -LocalPath (Join-Path -Path $TestDrive -ChildPath 'missing.json') -Uri $FakeUri -ErrorAction SilentlyContinue

            Should -Invoke Invoke-WebRequest -Times 0 -Exactly

        }

        It "Writes an error when the download fails" {

            $global:AuvikTestWebError = 'The remote name could not be resolved'

            $Result = & $ComparePath -LocalPath $MiniPath -Uri $FakeUri -ErrorAction SilentlyContinue -ErrorVariable CompareError

            $Result | Should -BeNullOrEmpty
            "$CompareError" | Should -Match 'remote name could not be resolved'

        }

        It "Writes an error when the online content is not json" {

            $global:AuvikTestWebContent = '<html>not a spec</html>'

            $Result = & $ComparePath -LocalPath $MiniPath -Uri $FakeUri -ErrorAction SilentlyContinue -ErrorVariable CompareError

            $Result | Should -BeNullOrEmpty
            $CompareError | Should -Not -BeNullOrEmpty

        }

        It "Sets a failing exit code with -FailOnDifference when the specs are different" {

            $global:AuvikTestWebContent = Edit-TestSpecText -Text $MiniText -Old '"summary": "Verify Credentials"' -New '"summary": "Verify The Credentials"'

            $global:LASTEXITCODE = 0
            $null = & $ComparePath -LocalPath $MiniPath -Uri $FakeUri -FailOnDifference -WarningAction SilentlyContinue

            $LASTEXITCODE | Should -Be 1

        }

        It "Does not set a failing exit code with -FailOnDifference when the specs are identical" {

            $global:AuvikTestWebContent = $MiniText

            $global:LASTEXITCODE = 0
            $null = & $ComparePath -LocalPath $MiniPath -Uri $FakeUri -FailOnDifference -WarningAction SilentlyContinue

            $LASTEXITCODE | Should -Be 0

        }

    }

    Context "[ Get-AuvikSpec.ps1 ] saving the spec" {

        BeforeEach {
            $OutputPath = Join-Path -Path $TestDrive -ChildPath 'SavedSpec'
            if (Test-Path -Path $OutputPath) { Remove-Item -Path $OutputPath -Recurse -Force }
        }

        It "Saves the online spec as Auvik-v1.json" {

            $global:AuvikTestWebContent = $SpecText

            $File = & $SavePath -Uri $FakeUri -OutputPath $OutputPath

            $File | Should -BeOfType [System.IO.FileInfo]
            $File.Name | Should -Be 'Auvik-v1.json'
            Join-Path -Path $OutputPath -ChildPath 'Auvik-v1.json' | Should -Exist
            Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ParameterFilter { $Uri -eq $FakeUri }

        }

        It "Creates the output folder" {

            $global:AuvikTestWebContent = $SpecText

            $null = & $SavePath -Uri $FakeUri -OutputPath (Join-Path -Path $OutputPath -ChildPath 'Nested')

            Join-Path -Path (Join-Path -Path $OutputPath -ChildPath 'Nested') -ChildPath 'Auvik-v1.json' | Should -Exist

        }

        It "Saves a spec that is identical to the online spec" {

            $global:AuvikTestWebContent = $SpecText

            $File = & $SavePath -Uri $FakeUri -OutputPath $OutputPath

            $Saved = [System.IO.File]::ReadAllText($File.FullName, [System.Text.Encoding]::UTF8)
            ($Saved -ceq $SpecText.Replace("`r`n", "`n")) | Should -BeTrue

        }

        It "Saves a spec that the comparison finds identical to the online spec" {

            $global:AuvikTestWebContent = $MiniText

            $File = & $SavePath -Uri $FakeUri -OutputPath $OutputPath

            (Invoke-TestCompare -LocalPath $File.FullName -OnlineContent $MiniText).Differs | Should -BeFalse

        }

        It "Saves UTF8 without a byte order mark & with unix line endings" {

            $global:AuvikTestWebContent = $SpecText.Replace("`n", "`r`n")

            $File   = & $SavePath -Uri $FakeUri -OutputPath $OutputPath
            $Bytes  = [System.IO.File]::ReadAllBytes($File.FullName)

            ($Bytes[0..2] -join ',') | Should -Not -Be '239,187,191'
            [System.Array]::IndexOf($Bytes, [byte]13) | Should -Be -1

        }

        It "Does not save anything with -WhatIf" {

            $global:AuvikTestWebContent = $SpecText

            $null = & $SavePath -Uri $FakeUri -OutputPath $OutputPath -WhatIf *> $null

            $OutputPath | Should -Not -Exist

        }

        It "Uses the product name & version for the file name" {

            $global:AuvikTestWebContent = '{"openapi":"3.0.1","info":{"title":"Test","version":"v2"},"paths":{"/v2/test":{"get":{}}}}'

            $File = & $SavePath -Uri $FakeUri -OutputPath $OutputPath -Product 'Example' -ExpectedVersion 'v2'

            $File.Name | Should -Be 'Example-v2.json'

        }

        It "Stops when the online spec is another version than expected" {

            $global:AuvikTestWebContent = '{"openapi":"3.0.1","info":{"title":"Test","version":"v2"},"paths":{"/v2/test":{"get":{}}}}'

            $Result = & $SavePath -Uri $FakeUri -OutputPath $OutputPath -ErrorAction SilentlyContinue -ErrorVariable SaveError

            $Result | Should -BeNullOrEmpty
            "$SaveError" | Should -Match 'online spec is version \[ v2 \]'
            $OutputPath | Should -Not -Exist

        }

        It "Stops when the content is not an OpenAPI spec" {

            $global:AuvikTestWebContent = '{"hello":"world"}'

            $Result = & $SavePath -Uri $FakeUri -OutputPath $OutputPath -ErrorAction SilentlyContinue -ErrorVariable SaveError

            $Result | Should -BeNullOrEmpty
            "$SaveError" | Should -Match 'not an OpenAPI spec'
            $OutputPath | Should -Not -Exist

        }

        It "Stops when the content is not json" {

            $global:AuvikTestWebContent = '<html>not json</html>'

            $Result = & $SavePath -Uri $FakeUri -OutputPath $OutputPath -ErrorAction SilentlyContinue -ErrorVariable SaveError

            $Result | Should -BeNullOrEmpty
            $SaveError | Should -Not -BeNullOrEmpty
            $OutputPath | Should -Not -Exist

        }

        It "Writes an error when the download fails" {

            $global:AuvikTestWebError = 'The remote name could not be resolved'

            $Result = & $SavePath -Uri $FakeUri -OutputPath $OutputPath -ErrorAction SilentlyContinue -ErrorVariable SaveError

            $Result | Should -BeNullOrEmpty
            "$SaveError" | Should -Match 'remote name could not be resolved'
            $OutputPath | Should -Not -Exist

        }

        It "Does not change the spec in the docs folder" {

            $global:AuvikTestWebContent = $SpecText

            $Before = (Get-FileHash -Path $SpecPath -Algorithm SHA256).Hash

            $null = & $SavePath -Uri $FakeUri -OutputPath $OutputPath

            (Get-FileHash -Path $SpecPath -Algorithm SHA256).Hash | Should -Be $Before

        }

    }

    Context "The local spec is up to date" -Tag 'Online' {

        BeforeAll {
            # The real download is used instead of the mock of the offline tests
            Mock Invoke-WebRequest -MockWith { & (Get-Command -Name Invoke-WebRequest -CommandType Cmdlet) @PesterBoundParameters }
        }

        It "Matches the online spec" {

            $Result = & $ComparePath -LocalPath $SpecPath -WarningAction SilentlyContinue

            $Result | Should -Not -BeNullOrEmpty -Because 'the online spec should be downloaded'

            $Result.Differs | Should -BeFalse -Because "docs\Auvik-v1.json should match the online spec, run build\Get-AuvikSpec.ps1 & build\New-PublicFunctions.ps1 (endpoints added: $($Result.EndpointsAdded -join ', '); removed: $($Result.EndpointsRemoved -join ', '); changed: $($Result.EndpointsChanged -join ', '))"

        }

    }

}
