<#
.NOTES
    Copyright 1990-2025 Celerium

    NAME: Invoke-AuvikRequest.Tests.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        EMAIL:   celerium@Celerium.org

.SYNOPSIS
    Pester tests for the Invoke-AuvikRequest function

.DESCRIPTION
    Pester tests for the Invoke-AuvikRequest function

    Invoke-WebRequest is mocked (and every other request throws), no request is ever sent

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
    Invoke-Pester -Path .\Invoke-AuvikRequest.Tests.ps1

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
        Add-TestHttpGuard -MockModule (Get-TestMockModuleName -CommandName 'Invoke-AuvikRequest') -SkipWebRequest

        $MockModule = Get-TestMockModuleName -CommandName 'Invoke-AuvikRequest'

        # The mock bodies run in the module, so they share data with the tests through global variables
        # The variables start with AuvikTest so Remove-TestState cleans them up
        Mock Invoke-WebRequest -ModuleName $MockModule -MockWith {
            $global:AuvikTestCalls.Add([PSCustomObject]@{ Method = $Method; Uri = $Uri; Headers = $Headers; Body = $Body; ContentType = $ContentType })

            if ($global:AuvikTestResponses.Count -gt 0) { $Next = $global:AuvikTestResponses.Dequeue() }
            else { $Next = [PSCustomObject]@{ data = @(); links = $null } }

            if ($Next -is [System.Management.Automation.ErrorRecord]) { throw $Next }
            return (ConvertTo-AuvikTestWebResponse -InputObject $Next)
        }

        Mock Start-Sleep -ModuleName $MockModule -MockWith { $global:AuvikTestSleeps.Add($Seconds) }

        $FakeApiKey         = 'fake-api-key'
        $ExpectedAuthHeader = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("user@example.com:$FakeApiKey"))

        # The error variable also contains the errors the mock throws, only the errors the module wrote are returned
        function Get-RequestErrorText {
            param ($ErrorRecord)

            $Messages = @($ErrorRecord | Where-Object { $_.Exception -and $_.Exception.GetType().Name -ne 'FakeHttpException' } | ForEach-Object { $_.Exception.Message })
            return ($Messages -join "`n")
        }

    }

    AfterAll {
        Remove-TestModule -ModuleName $ModuleName
    }

#EndRegion  [ Prerequisites ]

Describe "Testing the [ $BuildTarget ] version of [ $ModuleName ] with [ $PesterTestName ]" {

    BeforeEach {
        Reset-TestModuleState
        Set-TestCredential -ApiKey $FakeApiKey

        $global:AuvikTestCalls      = [System.Collections.Generic.List[object]]::new()
        $global:AuvikTestSleeps     = [System.Collections.Generic.List[object]]::new()
        $global:AuvikTestResponses  = [System.Collections.Generic.Queue[object]]::new()
    }

    Context "[ Invoke-AuvikRequest ] building the request" {

        It "Sends a GET request by default" {
            $null = Invoke-AuvikRequest -ResourceUri '/inventory/device/info'

            $global:AuvikTestCalls.Count | Should -Be 1
            $global:AuvikTestCalls[0].Method | Should -Be 'GET'
            $global:AuvikTestCalls[0].Uri.AbsoluteUri | Should -Be 'https://auvikapi.us1.my.auvik.com/v1/inventory/device/info'
            $global:AuvikTestCalls[0].Body | Should -BeNullOrEmpty
            $global:AuvikTestCalls[0].ContentType | Should -BeNullOrEmpty
        }

        It "Adds the query string of the filter" {
            $null = Invoke-AuvikRequest -ResourceUri '/inventory/device/info' -UriFilter @{ 'filter[deviceType]' = 'router'; tenants = @('1', '2') }

            $Query = Get-TestQuery -Uri $global:AuvikTestCalls[0].Uri
            $global:AuvikTestCalls[0].Uri.AbsolutePath | Should -Be '/v1/inventory/device/info'
            $Query['filter[deviceType]'] | Should -Be 'router'
            $Query['tenants'] | Should -Be '1,2'
        }

        It "Uses the configured base URI" {
            Add-AuvikBaseURI -DataCenter eu
            $null = Invoke-AuvikRequest -ResourceUri '/tenants'
            $global:AuvikTestCalls[0].Uri.Host | Should -Be 'auvikapi.eu1.my.auvik.com'
        }

        It "Builds a Basic authentication header from the username & API key" {
            $null = Invoke-AuvikRequest -ResourceUri '/authentication/verify'

            $global:AuvikTestCalls[0].Headers['Authorization'] | Should -BeExactly $ExpectedAuthHeader
            $Decoded = [Text.Encoding]::ASCII.GetString([Convert]::FromBase64String(($global:AuvikTestCalls[0].Headers['Authorization'] -replace '^Basic ', '')))
            $Decoded | Should -Be 'user@example.com:fake-api-key'
        }

        It "Sends a POST request as json:api" {
            $null = Invoke-AuvikRequest -Method POST -ResourceUri '/alert/dismiss/123' -Data @{ type = 'alert'; id = '123' }

            $global:AuvikTestCalls[0].Method | Should -Be 'POST'
            $global:AuvikTestCalls[0].ContentType | Should -Be 'application/vnd.api+json; charset=utf-8'

            $Body = $global:AuvikTestCalls[0].Body | ConvertFrom-Json
            $Body.data.type | Should -Be 'alert'
            $Body.data.id | Should -Be '123'
        }

        It "Sends a POST request without a body when no data is used" {
            $null = Invoke-AuvikRequest -Method POST -ResourceUri '/alert/dismiss/123'
            $global:AuvikTestCalls[0].Body | Should -BeNullOrEmpty
        }

        It "Only allows the GET & POST methods" {
            { Invoke-AuvikRequest -Method DELETE -ResourceUri '/tenants' } | Should -Throw
            { Invoke-AuvikRequest -Method PUT -ResourceUri '/tenants' } | Should -Throw
            $global:AuvikTestCalls.Count | Should -Be 0
        }

        It "Returns the response as it was received" {
            $Response = '{"data":[{"id":"1","type":"deviceInfo"}],"links":{"next":null},"meta":{"totalPages":1}}' | ConvertFrom-Json
            $global:AuvikTestResponses.Enqueue($Response)

            $Result = Invoke-AuvikRequest -ResourceUri '/inventory/device/info'

            $Result.data[0].id | Should -Be '1'
            $Result.meta.totalPages | Should -Be 1
        }

    }

    Context "[ Invoke-AuvikRequest ] decoding the response" {

        BeforeAll {
            # Built from character codes so the test does not depend on the encoding of this file in Windows PowerShell
            $Unicode = 'Z' + [char]0x00FC + 'rich ' + [char]0x2013 + ' ' + [char]0x6771 + [char]0x4EAC
        }

        It "Decodes a UTF-8 response with non-English text correctly" {
            $global:AuvikTestResponses.Enqueue('{"data":[{"id":"1","type":"tenant","attributes":{"displayName":"' + $Unicode + '"}}]}')

            $Result = Invoke-AuvikRequest -ResourceUri '/tenants'

            $Result.data[0].attributes.displayName | Should -BeExactly $Unicode
        }

        It "Decodes the non-English text of every page with -AllResults" {
            $global:AuvikTestResponses.Enqueue('{"data":[{"id":"1","attributes":{"name":"' + $Unicode + '"}}],"links":{"next":"https://auvikapi.us1.my.auvik.com/v1/tenants?page%5bafter%5d=AAA"}}')
            $global:AuvikTestResponses.Enqueue('{"data":[{"id":"2","attributes":{"name":"' + $Unicode + '"}}],"links":{}}')

            $Result = Invoke-AuvikRequest -ResourceUri '/tenants' -AllResults

            @($Result.data | ForEach-Object { $_.attributes.name }) | Should -Be @($Unicode, $Unicode)
        }

        It "Ignores a UTF-8 byte order mark" {
            $global:AuvikTestResponses.Enqueue(([string][char]0xFEFF) + '{"data":[{"id":"1"}]}')

            (Invoke-AuvikRequest -ResourceUri '/tenants').data[0].id | Should -Be '1'
        }

        It "Returns nothing for an empty response body" {
            $global:AuvikTestResponses.Enqueue((ConvertTo-AuvikTestWebResponse -InputObject '' -StatusCode 204))

            Invoke-AuvikRequest -ResourceUri '/tenants' | Should -BeNullOrEmpty
        }

        It "Sends the request with basic parsing & without following redirects" {
            $null = Invoke-AuvikRequest -ResourceUri '/tenants'

            Should -Invoke Invoke-WebRequest -ModuleName $MockModule -Times 1 -Exactly -Scope It -ParameterFilter { $UseBasicParsing -and $MaximumRedirection -eq 0 }
        }

    }

    Context "[ Invoke-AuvikRequest ] redirects to another region" {

        It "Follows a redirect error (PowerShell 7) & keeps the Authorization header" {
            $global:AuvikTestResponses.Enqueue((New-TestHttpError -StatusCode 308 -Location 'https://auvikapi.us2.my.auvik.com/v1/tenants'))
            $global:AuvikTestResponses.Enqueue(('{"data":[{"id":"1"}]}' | ConvertFrom-Json))

            $Result = Invoke-AuvikRequest -ResourceUri '/tenants' -WarningAction SilentlyContinue

            $global:AuvikTestCalls.Count | Should -Be 2
            $global:AuvikTestCalls[1].Uri.Host | Should -Be 'auvikapi.us2.my.auvik.com'
            $global:AuvikTestCalls[1].Headers['Authorization'] | Should -Be $ExpectedAuthHeader
            $Result.data[0].id | Should -Be '1'
        }

        It "Follows a redirect response (Windows PowerShell)" {
            $global:AuvikTestResponses.Enqueue((ConvertTo-AuvikTestWebResponse -InputObject '<a href="https://auvikapi.us2.my.auvik.com/v1/tenants">Permanent Redirect</a>' -StatusCode 308 -Headers @{ Location = 'https://auvikapi.us2.my.auvik.com/v1/tenants'; 'Content-Type' = 'text/html' }))
            $global:AuvikTestResponses.Enqueue(('{"data":[{"id":"1"}]}' | ConvertFrom-Json))

            $Result = Invoke-AuvikRequest -ResourceUri '/tenants' -WarningAction SilentlyContinue

            $global:AuvikTestCalls.Count | Should -Be 2
            $global:AuvikTestCalls[1].Uri.Host | Should -Be 'auvikapi.us2.my.auvik.com'
            $Result.data[0].id | Should -Be '1'
        }

        It "Changes the base URI to the region of the redirect & warns" {
            $global:AuvikTestResponses.Enqueue((New-TestHttpError -StatusCode 308 -Location 'https://auvikapi.eu2.my.auvik.com/v1/tenants'))
            $global:AuvikTestResponses.Enqueue(('{"data":[]}' | ConvertFrom-Json))

            $null = Invoke-AuvikRequest -ResourceUri '/tenants' -WarningVariable RedirectWarning -WarningAction SilentlyContinue

            $AuvikModuleBaseURI | Should -Be 'https://auvikapi.eu2.my.auvik.com/v1'
            ($RedirectWarning -join "`n") | Should -Match 'different region'
        }

        It "Never sends the credentials to a location outside of Auvik" {
            $global:AuvikTestResponses.Enqueue((New-TestHttpError -StatusCode 308 -Location 'https://example.com/v1/tenants'))

            $Result = Invoke-AuvikRequest -ResourceUri '/tenants' -ErrorAction SilentlyContinue -ErrorVariable RequestError -WarningAction SilentlyContinue

            $global:AuvikTestCalls.Count | Should -Be 1
            $Result | Should -BeNullOrEmpty
            (Get-RequestErrorText -ErrorRecord $RequestError) | Should -Match 'unexpected location'
        }

    }

    Context "[ Invoke-AuvikRequest ] debug variables" {

        It "Stores the request parameters with a masked Authorization header" {
            $null = Invoke-AuvikRequest -ResourceUri '/tenants'

            $InvokeAuvikRequestParameters | Should -Not -BeNullOrEmpty
            $InvokeAuvikRequestParameters['Headers']['Authorization'] | Should -Be 'Basic *******'
            $InvokeAuvikRequestParameters['Method'] | Should -Be 'GET'
            $InvokeAuvikRequestParameters['Uri'].AbsolutePath | Should -Be '/v1/tenants'
        }

        It "Stores the query string" {
            $null = Invoke-AuvikRequest -ResourceUri '/tenants' -UriFilter @{ 'page[first]' = 5 }
            $InvokeAuvikRequestParametersQuery | Should -BeOfType [System.UriBuilder]
            $InvokeAuvikRequestParametersQuery.Uri.AbsolutePath | Should -Be '/v1/tenants'
        }

        It "Never contains the secret in any debug variable" {
            $null = Invoke-AuvikRequest -ResourceUri '/tenants'

            $Base64Secret = $ExpectedAuthHeader -replace '^Basic ', ''

            foreach ($Name in 'InvokeAuvikRequestParameters', 'InvokeAuvikRequestParametersQuery') {
                $Text = (Get-Variable -Name $Name -Scope Global).Value | ConvertTo-Json -Depth 4 -WarningAction SilentlyContinue
                $Text | Should -Not -Match ([regex]::Escape($FakeApiKey))
                $Text | Should -Not -Match ([regex]::Escape($Base64Secret))
            }
        }

        It "Does not mask the header that is sent" {
            $null = Invoke-AuvikRequest -ResourceUri '/tenants'
            $global:AuvikTestCalls[0].Headers['Authorization'] | Should -Not -Match '\*'
        }

        It "Masks the header when the request fails" {
            $global:AuvikTestResponses.Enqueue((New-TestHttpError -StatusCode 401))
            $null = Invoke-AuvikRequest -ResourceUri '/tenants' -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

            $InvokeAuvikRequestParameters['Headers']['Authorization'] | Should -Be 'Basic *******'
        }

    }

    Context "[ Invoke-AuvikRequest ] -AllResults paging" {

        It "Follows the next links until there are no more pages" {
            $global:AuvikTestResponses.Enqueue(('{"data":[{"id":"1"},{"id":"2"}],"links":{"next":"https://auvikapi.us1.my.auvik.com/v1/inventory/device/info?page%5bfirst%5d=2&page%5bafter%5d=AAA"}}' | ConvertFrom-Json))
            $global:AuvikTestResponses.Enqueue(('{"data":[{"id":"3"},{"id":"4"}],"links":{"next":"https://auvikapi.us1.my.auvik.com/v1/inventory/device/info?page%5bfirst%5d=2&page%5bafter%5d=BBB"}}' | ConvertFrom-Json))
            $global:AuvikTestResponses.Enqueue(('{"data":[{"id":"5"}],"links":{}}' | ConvertFrom-Json))

            $Result = Invoke-AuvikRequest -ResourceUri '/inventory/device/info' -UriFilter @{ 'page[first]' = 2 } -AllResults

            $global:AuvikTestCalls.Count | Should -Be 3
            (Get-TestQuery -Uri $global:AuvikTestCalls[1].Uri)['page[after]'] | Should -Be 'AAA'
            (Get-TestQuery -Uri $global:AuvikTestCalls[2].Uri)['page[after]'] | Should -Be 'BBB'
            @($Result.data).Count | Should -Be 5
            ($Result.data | ForEach-Object { $_.id }) | Should -Be @('1', '2', '3', '4', '5')
        }

        It "Keeps the authentication header on every page" {
            $global:AuvikTestResponses.Enqueue(('{"data":[{"id":"1"}],"links":{"next":"https://auvikapi.us1.my.auvik.com/v1/tenants?page%5bafter%5d=AAA"}}' | ConvertFrom-Json))
            $global:AuvikTestResponses.Enqueue(('{"data":[{"id":"2"}],"links":{}}' | ConvertFrom-Json))

            $null = Invoke-AuvikRequest -ResourceUri '/tenants' -AllResults

            $global:AuvikTestCalls.Count | Should -Be 2
            $global:AuvikTestCalls[1].Headers['Authorization'] | Should -BeExactly $ExpectedAuthHeader
            $global:AuvikTestCalls[1].Method | Should -Be 'GET'
        }

        It "Combines the included items of every page" {
            $global:AuvikTestResponses.Enqueue(('{"data":[{"id":"1"}],"included":[{"id":"d1","type":"deviceDetail"}],"links":{"next":"https://auvikapi.us1.my.auvik.com/v1/inventory/device/info?page%5bafter%5d=AAA"}}' | ConvertFrom-Json))
            $global:AuvikTestResponses.Enqueue(('{"data":[{"id":"2"}],"included":[{"id":"d2","type":"deviceDetail"}],"links":{}}' | ConvertFrom-Json))

            $Result = Invoke-AuvikRequest -ResourceUri '/inventory/device/info' -AllResults

            @($Result.data).Count | Should -Be 2
            @($Result.included).Count | Should -Be 2
            ($Result.included | ForEach-Object { $_.id }) | Should -Be @('d1', 'd2')
        }

        It "Does not return included items when the API did not send any" {
            $global:AuvikTestResponses.Enqueue(('{"data":[{"id":"1"}],"links":{}}' | ConvertFrom-Json))

            $Result = Invoke-AuvikRequest -ResourceUri '/tenants' -AllResults

            $Result.PSObject.Properties.Name | Should -Not -Contain 'included'
        }

        It "Returns nothing when there are no items" {
            $global:AuvikTestResponses.Enqueue(('{"data":[],"links":{}}' | ConvertFrom-Json))
            Invoke-AuvikRequest -ResourceUri '/tenants' -AllResults | Should -BeNullOrEmpty
        }

        It "Returns a single item that is not in an array" {
            $global:AuvikTestResponses.Enqueue(('{"data":{"id":"1"},"links":{}}' | ConvertFrom-Json))

            $Result = Invoke-AuvikRequest -ResourceUri '/tenants' -AllResults

            @($Result.data).Count | Should -Be 1
            $Result.data[0].id | Should -Be '1'
        }

        It "Stops when the next link points to the page that was just requested" {
            $global:AuvikTestResponses.Enqueue(('{"data":[{"id":"1"}],"links":{"next":"https://auvikapi.us1.my.auvik.com/v1/tenants"}}' | ConvertFrom-Json))

            $Result = Invoke-AuvikRequest -ResourceUri '/tenants' -AllResults

            $global:AuvikTestCalls.Count | Should -Be 1
            @($Result.data).Count | Should -Be 1
        }

        It "Does not follow the next link without -AllResults" {
            $global:AuvikTestResponses.Enqueue(('{"data":[{"id":"1"}],"links":{"next":"https://auvikapi.us1.my.auvik.com/v1/tenants?page%5bafter%5d=AAA"}}' | ConvertFrom-Json))

            $Result = Invoke-AuvikRequest -ResourceUri '/tenants'

            $global:AuvikTestCalls.Count | Should -Be 1
            $Result.links.next | Should -Match 'page%5bafter%5d=AAA'
        }

    }

    Context "[ Invoke-AuvikRequest ] retrying requests" {

        It "Retries a rate limited (429) request & returns the response" {
            $global:AuvikTestResponses.Enqueue((New-TestHttpError -StatusCode 429))
            $global:AuvikTestResponses.Enqueue(('{"data":[{"id":"1"}],"links":{}}' | ConvertFrom-Json))

            $Result = Invoke-AuvikRequest -ResourceUri '/tenants' -RetryDelaySeconds 1

            $global:AuvikTestCalls.Count | Should -Be 2
            $Result.data[0].id | Should -Be '1'
        }

        It "Retries a [ <StatusCode> ] response" -ForEach @(
            @{ StatusCode = 500 }
            @{ StatusCode = 502 }
            @{ StatusCode = 503 }
            @{ StatusCode = 504 }
        ) {
            $global:AuvikTestResponses.Enqueue((New-TestHttpError -StatusCode $StatusCode))
            $global:AuvikTestResponses.Enqueue(('{"data":[{"id":"1"}],"links":{}}' | ConvertFrom-Json))

            $Result = Invoke-AuvikRequest -ResourceUri '/tenants' -RetryDelaySeconds 1

            $global:AuvikTestCalls.Count | Should -Be 2
            $Result.data[0].id | Should -Be '1'
        }

        It "Waits longer after every retry" {
            $global:AuvikTestResponses.Enqueue((New-TestHttpError -StatusCode 503))
            $global:AuvikTestResponses.Enqueue((New-TestHttpError -StatusCode 503))
            $global:AuvikTestResponses.Enqueue((New-TestHttpError -StatusCode 429))
            $global:AuvikTestResponses.Enqueue(('{"data":[],"links":{}}' | ConvertFrom-Json))

            $null = Invoke-AuvikRequest -ResourceUri '/tenants' -RetryDelaySeconds 1

            $global:AuvikTestCalls.Count | Should -Be 4
            $global:AuvikTestSleeps | Should -Be @(1, 2, 4)
        }

        It "Gives up after the maximum number of retries" {
            1..5 | ForEach-Object { $global:AuvikTestResponses.Enqueue((New-TestHttpError -StatusCode 503)) }

            $Result = Invoke-AuvikRequest -ResourceUri '/tenants' -MaxRetry 2 -RetryDelaySeconds 1 -ErrorAction SilentlyContinue -ErrorVariable RequestError -WarningAction SilentlyContinue

            $global:AuvikTestCalls.Count | Should -Be 3
            $global:AuvikTestSleeps.Count | Should -Be 2
            $Result | Should -BeNullOrEmpty
            @($RequestError).Count | Should -BeGreaterThan 0
        }

        It "Reports a rate limited request that kept failing" {
            1..2 | ForEach-Object { $global:AuvikTestResponses.Enqueue((New-TestHttpError -StatusCode 429)) }

            $null = Invoke-AuvikRequest -ResourceUri '/tenants' -MaxRetry 1 -RetryDelaySeconds 1 -ErrorAction SilentlyContinue -ErrorVariable RequestError -WarningAction SilentlyContinue

            $global:AuvikTestCalls.Count | Should -Be 2
            (Get-RequestErrorText -ErrorRecord $RequestError) | Should -Match 'rate limited'
        }

        It "Does not retry with -MaxRetry 0" {
            $global:AuvikTestResponses.Enqueue((New-TestHttpError -StatusCode 503))

            $null = Invoke-AuvikRequest -ResourceUri '/tenants' -MaxRetry 0 -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

            $global:AuvikTestCalls.Count | Should -Be 1
            $global:AuvikTestSleeps.Count | Should -Be 0
        }

        It "Does not wait with -RetryDelaySeconds 0" {
            $global:AuvikTestResponses.Enqueue((New-TestHttpError -StatusCode 503))
            $global:AuvikTestResponses.Enqueue(('{"data":[],"links":{}}' | ConvertFrom-Json))

            $null = Invoke-AuvikRequest -ResourceUri '/tenants' -RetryDelaySeconds 0

            $global:AuvikTestCalls.Count | Should -Be 2
            $global:AuvikTestSleeps.Count | Should -Be 0
        }

        It "Retries the page that failed while paging" {
            $global:AuvikTestResponses.Enqueue(('{"data":[{"id":"1"}],"links":{"next":"https://auvikapi.us1.my.auvik.com/v1/tenants?page%5bafter%5d=AAA"}}' | ConvertFrom-Json))
            $global:AuvikTestResponses.Enqueue((New-TestHttpError -StatusCode 429))
            $global:AuvikTestResponses.Enqueue(('{"data":[{"id":"2"}],"links":{}}' | ConvertFrom-Json))

            $Result = Invoke-AuvikRequest -ResourceUri '/tenants' -AllResults -RetryDelaySeconds 1

            $global:AuvikTestCalls.Count | Should -Be 3
            (Get-TestQuery -Uri $global:AuvikTestCalls[2].Uri)['page[after]'] | Should -Be 'AAA'
            ($Result.data | ForEach-Object { $_.id }) | Should -Be @('1', '2')
        }

        It "Does not retry a [ <StatusCode> ] response" -ForEach @(
            @{ StatusCode = 400 }
            @{ StatusCode = 401 }
            @{ StatusCode = 403 }
            @{ StatusCode = 404 }
        ) {
            $global:AuvikTestResponses.Enqueue((New-TestHttpError -StatusCode $StatusCode))
            $global:AuvikTestResponses.Enqueue(('{"data":[{"id":"1"}],"links":{}}' | ConvertFrom-Json))

            $Result = Invoke-AuvikRequest -ResourceUri '/tenants' -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

            $global:AuvikTestCalls.Count | Should -Be 1
            $global:AuvikTestSleeps.Count | Should -Be 0
            $Result | Should -BeNullOrEmpty
        }

        It "Never retries a write (POST) request" {
            $global:AuvikTestResponses.Enqueue((New-TestHttpError -StatusCode 503))
            $global:AuvikTestResponses.Enqueue(('{"data":{"id":"1"}}' | ConvertFrom-Json))

            $Result = Invoke-AuvikRequest -Method POST -ResourceUri '/alert/dismiss/123' -RetryDelaySeconds 1 -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

            $global:AuvikTestCalls.Count | Should -Be 1
            $global:AuvikTestSleeps.Count | Should -Be 0
            $Result | Should -BeNullOrEmpty
        }

    }

    Context "[ Invoke-AuvikRequest ] failed requests" {

        It "Returns nothing & writes an error when the request fails" {
            $global:AuvikTestResponses.Enqueue((New-TestHttpError -StatusCode 404))

            $Result = Invoke-AuvikRequest -ResourceUri '/inventory/device/info/missing' -ErrorAction SilentlyContinue -ErrorVariable RequestError -WarningAction SilentlyContinue

            $Result | Should -BeNullOrEmpty
            (Get-RequestErrorText -ErrorRecord $RequestError) | Should -Match 'Uri not found'
            (Get-RequestErrorText -ErrorRecord $RequestError) | Should -Match 'inventory/device/info/missing'
        }

        It "Does not throw a terminating error" {
            $global:AuvikTestResponses.Enqueue((New-TestHttpError -StatusCode 401))
            { Invoke-AuvikRequest -ResourceUri '/tenants' -ErrorAction SilentlyContinue -WarningAction SilentlyContinue } | Should -Not -Throw
        }

        It "Writes a not authorized error for a 401 response" {
            $global:AuvikTestResponses.Enqueue((New-TestHttpError -StatusCode 401))
            $null = Invoke-AuvikRequest -ResourceUri '/tenants' -ErrorAction SilentlyContinue -ErrorVariable RequestError -WarningAction SilentlyContinue
            (Get-RequestErrorText -ErrorRecord $RequestError) | Should -Match 'Not authorized'
        }

        It "Writes a forbidden error for a 403 response" {
            $global:AuvikTestResponses.Enqueue((New-TestHttpError -StatusCode 403))
            $null = Invoke-AuvikRequest -ResourceUri '/tenants' -ErrorAction SilentlyContinue -ErrorVariable RequestError -WarningAction SilentlyContinue
            (Get-RequestErrorText -ErrorRecord $RequestError) | Should -Match 'Forbidden'
        }

        It "Surfaces the detail of the Auvik json error" {
            $Detail = '{"errors":[{"id":"1","status":"400","title":"Bad Request","detail":"The filter[deviceType] value is not valid"}]}'
            $global:AuvikTestResponses.Enqueue((New-TestHttpError -StatusCode 400 -Detail $Detail))

            $null = Invoke-AuvikRequest -ResourceUri '/inventory/device/info' -ErrorAction SilentlyContinue -ErrorVariable RequestError -WarningAction SilentlyContinue

            (Get-RequestErrorText -ErrorRecord $RequestError) | Should -Match 'The filter\[deviceType\] value is not valid'
        }

        It "Surfaces the title of the Auvik json error when there is no detail" {
            $global:AuvikTestResponses.Enqueue((New-TestHttpError -StatusCode 404 -Detail '{"errors":[{"status":"404","title":"Entity not found"}]}'))

            $null = Invoke-AuvikRequest -ResourceUri '/inventory/device/info/1' -ErrorAction SilentlyContinue -ErrorVariable RequestError -WarningAction SilentlyContinue

            (Get-RequestErrorText -ErrorRecord $RequestError) | Should -Match 'Entity not found'
        }

        It "Still writes an error when the body of the error is not json" {
            $global:AuvikTestResponses.Enqueue((New-TestHttpError -StatusCode 400 -Detail 'plain text failure'))

            $Result = Invoke-AuvikRequest -ResourceUri '/tenants' -ErrorAction SilentlyContinue -ErrorVariable RequestError -WarningAction SilentlyContinue

            $Result | Should -BeNullOrEmpty
            (Get-RequestErrorText -ErrorRecord $RequestError) | Should -Match '400'
        }

        It "Writes the message of an error that is not an HTTP error" {
            $Exception = [System.Exception]::new('The connection was closed')
            $global:AuvikTestResponses.Enqueue([System.Management.Automation.ErrorRecord]::new($Exception, 'ConnectionError', [System.Management.Automation.ErrorCategory]::ConnectionError, $null))

            $Result = Invoke-AuvikRequest -ResourceUri '/tenants' -ErrorAction SilentlyContinue -ErrorVariable RequestError -WarningAction SilentlyContinue

            $Result | Should -BeNullOrEmpty
            $global:AuvikTestCalls.Count | Should -Be 1
            "$($RequestError[0])" | Should -Match 'The connection was closed'
        }

        It "Points to the debug variables with a warning" {
            $global:AuvikTestResponses.Enqueue((New-TestHttpError -StatusCode 404))

            $null = Invoke-AuvikRequest -ResourceUri '/tenants' -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -WarningVariable RequestWarning

            "$RequestWarning" | Should -Match 'InvokeAuvikRequestParameters'
        }

    }

    Context "[ Invoke-AuvikRequest ] missing configuration" {

        It "Writes an error & sends nothing when the API credentials are not set" {
            Remove-AuvikAPIKey -WarningAction SilentlyContinue

            $Result = Invoke-AuvikRequest -ResourceUri '/tenants' -ErrorAction SilentlyContinue -ErrorVariable RequestError -WarningAction SilentlyContinue

            $Result | Should -BeNullOrEmpty
            $global:AuvikTestCalls.Count | Should -Be 0
            (Get-RequestErrorText -ErrorRecord $RequestError) | Should -Match 'API username & key are not set'
        }

        It "Throws when the base URI is not set" {
            Remove-AuvikBaseURI

            { Invoke-AuvikRequest -ResourceUri '/tenants' } | Should -Throw '*base URI is not set*'
            $global:AuvikTestCalls.Count | Should -Be 0
        }

    }

}
