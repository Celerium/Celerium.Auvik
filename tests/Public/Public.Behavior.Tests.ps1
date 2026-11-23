<#
.NOTES
    Copyright 1990-2025 Celerium

    NAME: Public.Behavior.Tests.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        EMAIL:   celerium@Celerium.org

.SYNOPSIS
    Pester tests for the behavior that is shared by the public functions

.DESCRIPTION
    Hand written tests with fixed expectations for query string formatting, paging, escaping of ids, pipeline input,
    legacy aliases, & the functions that are not simple reads. Complements the spec driven Public.Tests.ps1

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
    Invoke-Pester -Path .\Public.Behavior.Tests.ps1

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

        # Alias, the function it points to, & the path of the request it sends
        $LegacyReadAliases = @(
            @{ AliasName = 'Get-AuvikDevice';               FunctionName = 'Get-AuvikDeviceInfo';               ExpectedPath = '/v1/inventory/device/info' }
            @{ AliasName = 'Get-AuvikInterface';            FunctionName = 'Get-AuvikInterfaceInfo';            ExpectedPath = '/v1/inventory/interface/info' }
            @{ AliasName = 'Get-AuvikComponent';            FunctionName = 'Get-AuvikComponentInfo';            ExpectedPath = '/v1/inventory/component/info' }
            @{ AliasName = 'Get-AuvikNetwork';              FunctionName = 'Get-AuvikNetworkInfo';              ExpectedPath = '/v1/inventory/network/info' }
            @{ AliasName = 'Get-AuvikEntity';               FunctionName = 'Get-AuvikEntityNote';               ExpectedPath = '/v1/inventory/entity/note' }
            @{ AliasName = 'Get-AuvikAlert';                FunctionName = 'Get-AuvikAlertHistory';             ExpectedPath = '/v1/alert/history/info' }
        )

        $LegacyAliases = $LegacyReadAliases + @(
            @{ AliasName = 'Get-AuvikBilling';              FunctionName = 'Get-AuvikBillingUsageClient';       ExpectedPath = '' }
            @{ AliasName = 'Get-AuvikSNMPPollerHistory';    FunctionName = 'Get-AuvikSNMPPollerHistoryString';  ExpectedPath = '' }
            @{ AliasName = 'Test-AuvikAPICredential';       FunctionName = 'Get-AuvikAuthenticationVerify';     ExpectedPath = '' }
            @{ AliasName = 'Clear-AuvikAlert';              FunctionName = 'Send-AuvikAlertDismiss';             ExpectedPath = '' }
            @{ AliasName = 'Set-AuvikAPIKey';               FunctionName = 'Add-AuvikAPIKey';                   ExpectedPath = '' }
            @{ AliasName = 'Set-AuvikBaseURI';              FunctionName = 'Add-AuvikBaseURI';                  ExpectedPath = '' }
        )

        $PipelineIdCases = @(
            @{ FunctionName = 'Get-AuvikDeviceInfo';        ExpectedPath = '/v1/inventory/device/info';     ExtraParameters = @{} }
            @{ FunctionName = 'Get-AuvikDeviceDetail';      ExpectedPath = '/v1/inventory/device/detail';   ExtraParameters = @{} }
            @{ FunctionName = 'Get-AuvikNetworkInfo';       ExpectedPath = '/v1/inventory/network/info';    ExtraParameters = @{} }
            @{ FunctionName = 'Get-AuvikAlertHistory';      ExpectedPath = '/v1/alert/history/info';        ExtraParameters = @{} }
            @{ FunctionName = 'Get-AuvikTenantDetail';      ExpectedPath = '/v1/tenants/detail';            ExtraParameters = @{ TenantDomainPrefix = 'celerium' } }
        )

    }

    BeforeAll {

        $TestsPath = $PSScriptRoot
        while ($TestsPath -and -not (Test-Path -Path (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1'))) { $TestsPath = Split-Path -Path $TestsPath -Parent }
        . (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1')

        Import-TestModule -ModuleName $ModuleName -Version $Version -BuildTarget $BuildTarget
        Add-TestHttpGuard -MockModule (Get-TestMockModuleName -CommandName 'Invoke-AuvikRequest') -SkipWebRequest

        $MockModule = Get-TestMockModuleName -CommandName 'Get-AuvikDeviceInfo'

        # The mock bodies run in the module, so they share data with the tests through global variables
        # The variables start with AuvikTest so Remove-TestState cleans them up
        Mock Invoke-WebRequest -ModuleName $MockModule -MockWith {
            $global:AuvikTestCalls.Add([PSCustomObject]@{ Method = $Method; Uri = $Uri; Headers = $Headers; Body = $Body; ContentType = $ContentType })

            if ($global:AuvikTestResponses.Count -gt 0) { $Next = $global:AuvikTestResponses.Dequeue() }
            else { $Next = [PSCustomObject]@{ data = @(); links = $null } }

            if ($Next -is [System.Management.Automation.ErrorRecord]) { throw $Next }
            return (ConvertTo-AuvikTestWebResponse -InputObject $Next)
        }

        Mock Start-Sleep -ModuleName $MockModule -MockWith { }

        function ConvertTo-TestPage {
            # Creates a response with a list of ids & an optional link to the next page
            param (
                [string[]]$Id,
                [string]$Next,
                [string[]]$IncludedId
            )

            $Page = [ordered]@{
                data    = @($Id | ForEach-Object { [PSCustomObject]@{ type = 'deviceInfo'; id = $_ } })
                links   = if ($Next) { [PSCustomObject]@{ next = $Next } } else { [PSCustomObject]@{} }
            }

            if ($IncludedId) { $Page['included'] = @($IncludedId | ForEach-Object { [PSCustomObject]@{ type = 'deviceDetail'; id = $_ } }) }

            return [PSCustomObject]$Page
        }

    }

    AfterAll {
        Remove-TestModule -ModuleName $ModuleName
    }

#EndRegion  [ Prerequisites ]

Describe "Testing the [ $BuildTarget ] version of [ $ModuleName ] with [ $PesterTestName ]" {

    BeforeEach {
        Reset-TestModuleState
        Set-TestCredential

        $global:AuvikTestCalls      = [System.Collections.Generic.List[object]]::new()
        $global:AuvikTestResponses  = [System.Collections.Generic.Queue[object]]::new()
    }

    Context "Query string formatting" {

        It "Sends tenants as a comma delimited list" {
            $null = Get-AuvikDeviceInfo -Tenants '111', '222', '333'

            $global:AuvikTestCalls.Count | Should -Be 1
            (Get-TestQuery -Uri $global:AuvikTestCalls[0].Uri)['tenants'] | Should -Be '111,222,333'
        }

        It "Sends a single tenant without a comma" {
            $null = Get-AuvikDeviceInfo -Tenants '111'
            (Get-TestQuery -Uri $global:AuvikTestCalls[0].Uri)['tenants'] | Should -Be '111'
        }

        It "Sends a tenant from a variable that holds an array" {
            $TenantList = @('1', '2')
            $null = Get-AuvikAlertHistory -Tenants $TenantList
            (Get-TestQuery -Uri $global:AuvikTestCalls[0].Uri)['tenants'] | Should -Be '1,2'
        }

        It "Sends booleans in lowercase" {
            $null = Get-AuvikDeviceInfo -FilterStateKnown $true
            (Get-TestQuery -Uri $global:AuvikTestCalls[0].Uri)['filter[stateKnown]'] | Should -BeExactly 'true'

            $null = Get-AuvikDeviceInfo -FilterStateKnown $false
            (Get-TestQuery -Uri $global:AuvikTestCalls[1].Uri)['filter[stateKnown]'] | Should -BeExactly 'false'
        }

        It "Sends a false boolean even though it looks like an empty value" {
            $null = Get-AuvikAlertHistory -FilterDismissed $false
            (Get-TestQuery -Uri $global:AuvikTestCalls[0].Uri).Keys | Should -Contain 'filter[dismissed]'
        }

        It "Sends dates as UTC with milliseconds" {
            $null = Get-AuvikDeviceInfo -FilterModifiedAfter ([datetime]::Parse('2025-03-04T05:06:07-05:00'))
            (Get-TestQuery -Uri $global:AuvikTestCalls[0].Uri)['filter[modifiedAfter]'] | Should -Be '2025-03-04T10:06:07.000Z'
        }

        It "Sends dates that are already UTC unchanged" {
            $null = Get-AuvikAlertHistory -FilterDetectedTimeAfter ([datetime]::new(2025, 3, 4, 5, 6, 7, [System.DateTimeKind]::Utc)) -FilterDetectedTimeBefore ([datetime]::new(2025, 3, 5, 0, 0, 0, [System.DateTimeKind]::Utc))

            $Query = Get-TestQuery -Uri $global:AuvikTestCalls[0].Uri
            $Query['filter[detectedTimeAfter]'] | Should -Be '2025-03-04T05:06:07.000Z'
            $Query['filter[detectedTimeBefore]'] | Should -Be '2025-03-05T00:00:00.000Z'
        }

        It "Sends from & thru dates as yyyy-MM-dd" {
            $null = Get-AuvikBillingUsageClient -FilterFromDate ([datetime]::new(2025, 1, 1, 0, 0, 0, [System.DateTimeKind]::Utc)) -FilterThruDate ([datetime]::new(2025, 1, 31, 12, 30, 0, [System.DateTimeKind]::Utc))

            $Query = Get-TestQuery -Uri $global:AuvikTestCalls[0].Uri
            $Query['filter[fromDate]'] | Should -Be '2025-01-01'
            $Query['filter[thruDate]'] | Should -Be '2025-01-31'
        }

        It "Sends the paging parameters" {
            $null = Get-AuvikDeviceInfo -PageFirst 25 -PageAfter 'cursor-value'

            $Query = Get-TestQuery -Uri $global:AuvikTestCalls[0].Uri
            $Query['page[first]'] | Should -Be '25'
            $Query['page[after]'] | Should -Be 'cursor-value'
        }

        It "Sends a combination of parameters & nothing else" {
            $null = Get-AuvikDeviceInfo -Tenants 'a', 'b' -PageFirst 10 -FilterDeviceType router -FilterStateKnown $true -Include deviceDetail -FieldsDeviceDetail components -FilterVendorName 'Ubiquiti Networks'

            $Query = Get-TestQuery -Uri $global:AuvikTestCalls[0].Uri

            $Query.Count | Should -Be 7
            $Query['tenants'] | Should -Be 'a,b'
            $Query['page[first]'] | Should -Be '10'
            $Query['filter[deviceType]'] | Should -Be 'router'
            $Query['filter[stateKnown]'] | Should -Be 'true'
            $Query['include'] | Should -Be 'deviceDetail'
            $Query['fields[deviceDetail]'] | Should -Be 'components'
            $Query['filter[vendorName]'] | Should -Be 'Ubiquiti Networks'
        }

        It "Does not send a query when no parameter is used" {
            $null = Get-AuvikDeviceInfo

            $global:AuvikTestCalls[0].Uri.Query | Should -BeNullOrEmpty
            $global:AuvikTestCalls[0].Uri.AbsolutePath | Should -Be '/v1/inventory/device/info'
        }

        It "Sends the tenants request without a query" {
            $null = Get-AuvikTenant

            $global:AuvikTestCalls[0].Uri.AbsolutePath | Should -Be '/v1/tenants'
            $global:AuvikTestCalls[0].Uri.Query | Should -BeNullOrEmpty
        }

        It "Sends the tenant domain prefix of the tenant detail" {
            $null = Get-AuvikTenantDetail -TenantDomainPrefix 'celerium'

            $global:AuvikTestCalls[0].Uri.AbsolutePath | Should -Be '/v1/tenants/detail'
            (Get-TestQuery -Uri $global:AuvikTestCalls[0].Uri)['tenantDomainPrefix'] | Should -Be 'celerium'
        }

        It "Sends the path parameters of a statistics request" {
            $null = Get-AuvikComponentStatistics -ComponentType disk -StatId utilization -FilterFromTime ([datetime]::new(2025, 1, 2, 3, 4, 5, [System.DateTimeKind]::Utc)) -FilterInterval hour

            $global:AuvikTestCalls[0].Uri.AbsolutePath | Should -Be '/v1/stat/component/disk/utilization'
            (Get-TestQuery -Uri $global:AuvikTestCalls[0].Uri)['filter[interval]'] | Should -Be 'hour'
        }

        It "Uses the base URI of the module" {
            Add-AuvikBaseURI -DataCenter eu

            $null = Get-AuvikDeviceInfo -Id '1'

            $global:AuvikTestCalls[0].Uri.Host | Should -Be 'auvikapi.eu1.my.auvik.com'
            $global:AuvikTestCalls[0].Uri.AbsolutePath | Should -Be '/v1/inventory/device/info/1'
        }

    }

    Context "-AllResults paging" {

        It "Follows the next links & returns the items of every page" {
            $global:AuvikTestResponses.Enqueue((ConvertTo-TestPage -Id '1', '2' -Next 'https://auvikapi.us1.my.auvik.com/v1/inventory/device/info?tenants=T1&page%5bfirst%5d=2&page%5bafter%5d=AAA'))
            $global:AuvikTestResponses.Enqueue((ConvertTo-TestPage -Id '3', '4' -Next 'https://auvikapi.us1.my.auvik.com/v1/inventory/device/info?tenants=T1&page%5bfirst%5d=2&page%5bafter%5d=BBB'))
            $global:AuvikTestResponses.Enqueue((ConvertTo-TestPage -Id '5'))

            $Result = Get-AuvikDeviceInfo -Tenants 'T1' -PageFirst 2 -AllResults

            $global:AuvikTestCalls.Count | Should -Be 3
            (Get-TestQuery -Uri $global:AuvikTestCalls[0].Uri).ContainsKey('page[after]') | Should -BeFalse
            (Get-TestQuery -Uri $global:AuvikTestCalls[1].Uri)['page[after]'] | Should -Be 'AAA'
            (Get-TestQuery -Uri $global:AuvikTestCalls[2].Uri)['page[after]'] | Should -Be 'BBB'

            @($Result.data).Count | Should -Be 5
            ($Result.data | ForEach-Object { $_.id }) | Should -Be @('1', '2', '3', '4', '5')
        }

        It "Combines the included items of every page" {
            $global:AuvikTestResponses.Enqueue((ConvertTo-TestPage -Id '1' -IncludedId 'd1' -Next 'https://auvikapi.us1.my.auvik.com/v1/inventory/device/info?include=deviceDetail&page%5bafter%5d=AAA'))
            $global:AuvikTestResponses.Enqueue((ConvertTo-TestPage -Id '2' -IncludedId 'd2'))

            $Result = Get-AuvikDeviceInfo -Include deviceDetail -AllResults

            @($Result.data).Count | Should -Be 2
            ($Result.included | ForEach-Object { $_.id }) | Should -Be @('d1', 'd2')
        }

        It "Returns one page without -AllResults" {
            $global:AuvikTestResponses.Enqueue((ConvertTo-TestPage -Id '1', '2' -Next 'https://auvikapi.us1.my.auvik.com/v1/inventory/device/info?page%5bafter%5d=AAA'))

            $Result = Get-AuvikDeviceInfo -PageFirst 2

            $global:AuvikTestCalls.Count | Should -Be 1
            @($Result.data).Count | Should -Be 2
        }

        It "Is not available when reading a single item" {
            { Get-AuvikDeviceInfo -Id '1' -AllResults } | Should -Throw
            $global:AuvikTestCalls.Count | Should -Be 0
        }

        It "Works with a statistics request" {
            $global:AuvikTestResponses.Enqueue((ConvertTo-TestPage -Id '1' -Next 'https://auvikapi.us1.my.auvik.com/v1/stat/device/bandwidth?page%5bafter%5d=AAA'))
            $global:AuvikTestResponses.Enqueue((ConvertTo-TestPage -Id '2'))

            $Result = Get-AuvikDeviceStatistics -StatId bandwidth -FilterFromTime ([datetime]::new(2025, 1, 2, 3, 4, 5, [System.DateTimeKind]::Utc)) -FilterInterval day -AllResults

            $global:AuvikTestCalls.Count | Should -Be 2
            @($Result.data).Count | Should -Be 2
        }

    }

    Context "Escaping of the Id" {

        It "Escapes a space in the Id" {
            $null = Get-AuvikDeviceInfo -Id 'a b'
            $global:AuvikTestCalls[0].Uri.AbsolutePath | Should -Be '/v1/inventory/device/info/a%20b'
        }

        It "Escapes a slash in the Id so it can not change the path" {
            $null = Get-AuvikDeviceInfo -Id 'a/b'

            $global:AuvikTestCalls[0].Uri.OriginalString | Should -Match '/info/a%2Fb$'
        }

        It "Escapes a question mark & a hash in the Id so they can not become a query or a fragment" {
            $null = Get-AuvikDeviceInfo -Id 'a?b=c#d'

            $global:AuvikTestCalls[0].Uri.Query | Should -BeNullOrEmpty
            $global:AuvikTestCalls[0].Uri.Fragment | Should -BeNullOrEmpty
            $global:AuvikTestCalls[0].Uri.AbsolutePath | Should -Match '/info/a%3Fb%3Dc%23d$'
        }

        It "Does not change an Id that only has safe characters" {
            $null = Get-AuvikDeviceInfo -Id 'MTk5NTAyNzg2ODc3MDYzMTY5'
            $global:AuvikTestCalls[0].Uri.AbsolutePath | Should -Be '/v1/inventory/device/info/MTk5NTAyNzg2ODc3MDYzMTY5'
        }

        It "Escapes the Id of a write request" {
            $null = Send-AuvikAlertDismiss -Id 'a b/c' -Confirm:$false
            $global:AuvikTestCalls[0].Uri.OriginalString | Should -Match '/alert/dismiss/a%20b%2Fc$'
        }

        It "Does not accept an empty Id" {
            { Get-AuvikDeviceInfo -Id '' } | Should -Throw
            { Get-AuvikDeviceInfo -Id $null } | Should -Throw
            $global:AuvikTestCalls.Count | Should -Be 0
        }

    }

    Context "Pipeline input of the Id" {

        It "[ <FunctionName> ] accepts Ids from the pipeline" -ForEach $PipelineIdCases {
            $null = '11', '22' | & $FunctionName @ExtraParameters

            $global:AuvikTestCalls.Count | Should -Be 2
            $global:AuvikTestCalls[0].Uri.AbsolutePath | Should -Be "$ExpectedPath/11"
            $global:AuvikTestCalls[1].Uri.AbsolutePath | Should -Be "$ExpectedPath/22"
        }

        It "Accepts objects with an Id property from the pipeline" {
            $null = [PSCustomObject]@{ Id = '7' }, [PSCustomObject]@{ Id = '8' } | Get-AuvikDeviceInfo

            $global:AuvikTestCalls.Count | Should -Be 2
            $global:AuvikTestCalls[0].Uri.AbsolutePath | Should -Be '/v1/inventory/device/info/7'
            $global:AuvikTestCalls[1].Uri.AbsolutePath | Should -Be '/v1/inventory/device/info/8'
        }

        It "Accepts the id of a response from the pipeline" {
            $global:AuvikTestResponses.Enqueue((ConvertTo-TestPage -Id 'x1', 'x2'))

            $null = (Get-AuvikDeviceInfo).data | Get-AuvikDeviceDetail

            $global:AuvikTestCalls.Count | Should -Be 3
            $global:AuvikTestCalls[1].Uri.AbsolutePath | Should -Be '/v1/inventory/device/detail/x1'
            $global:AuvikTestCalls[2].Uri.AbsolutePath | Should -Be '/v1/inventory/device/detail/x2'
        }

        It "Accepts the SNMP poller setting id as Id from the pipeline" {
            $null = [PSCustomObject]@{ Id = '9' } | Get-AuvikSNMPPollerSetting

            $global:AuvikTestCalls[0].Uri.AbsolutePath | Should -Be '/v1/settings/snmppoller/9'
        }

        It "Accepts the SNMP poller setting id with the Id alias" {
            $null = Get-AuvikSNMPPollerSetting -Id '9'
            $global:AuvikTestCalls[0].Uri.AbsolutePath | Should -Be '/v1/settings/snmppoller/9'
        }

    }

    Context "Send-AuvikAlertDismiss" {

        It "Sends a POST request to dismiss the alert" {
            $null = Send-AuvikAlertDismiss -Id 'alert1' -Confirm:$false

            $global:AuvikTestCalls.Count | Should -Be 1
            $global:AuvikTestCalls[0].Method | Should -Be 'POST'
            $global:AuvikTestCalls[0].Uri.AbsolutePath | Should -Be '/v1/alert/dismiss/alert1'
            $global:AuvikTestCalls[0].ContentType | Should -Match 'application/vnd.api\+json'
        }

        It "Does not send a request with -WhatIf" {
            $null = Send-AuvikAlertDismiss -Id 'alert1' -WhatIf *> $null
            $global:AuvikTestCalls.Count | Should -Be 0
        }

        It "Sends a request for every Id of the pipeline" {
            $null = 'a1', 'a2', 'a3' | Send-AuvikAlertDismiss -Confirm:$false

            $global:AuvikTestCalls.Count | Should -Be 3
            ($global:AuvikTestCalls | ForEach-Object { $_.Uri.AbsolutePath }) | Should -Be @('/v1/alert/dismiss/a1', '/v1/alert/dismiss/a2', '/v1/alert/dismiss/a3')
        }

        It "Accepts objects with an Id property from the pipeline" {
            $null = [PSCustomObject]@{ Id = 'a4' } | Send-AuvikAlertDismiss -Confirm:$false
            $global:AuvikTestCalls[0].Uri.AbsolutePath | Should -Be '/v1/alert/dismiss/a4'
        }

        It "Does not send requests for the Ids of the pipeline with -WhatIf" {
            $null = 'a1', 'a2' | Send-AuvikAlertDismiss -WhatIf *> $null
            $global:AuvikTestCalls.Count | Should -Be 0
        }

        It "Returns the response of the API" {
            $global:AuvikTestResponses.Enqueue([PSCustomObject]@{ data = [PSCustomObject]@{ id = 'a1'; type = 'alertDismiss' } })

            $Result = Send-AuvikAlertDismiss -Id 'a1' -Confirm:$false

            $Result.data.id | Should -Be 'a1'
        }

        It "Has a high confirm impact & supports -WhatIf" {
            $Attribute = (Get-Command -Name Send-AuvikAlertDismiss).ScriptBlock.Attributes | Where-Object { $_ -is [System.Management.Automation.CmdletBindingAttribute] }

            $Attribute.SupportsShouldProcess | Should -BeTrue
            $Attribute.ConfirmImpact.ToString() | Should -Be 'High'
        }

    }

    Context "Get-AuvikAuthenticationVerify" {

        It "Returns true when the credentials are valid" {
            $Result = Get-AuvikAuthenticationVerify

            $Result | Should -BeTrue
            $Result | Should -BeOfType [bool]
            $global:AuvikTestCalls.Count | Should -Be 1
            $global:AuvikTestCalls[0].Uri.AbsolutePath | Should -Be '/v1/authentication/verify'
            $global:AuvikTestCalls[0].Method | Should -Be 'GET'
        }

        It "Returns false when the credentials are not valid" {
            $global:AuvikTestResponses.Enqueue((New-TestHttpError -StatusCode 401))

            $Result = Get-AuvikAuthenticationVerify

            $Result | Should -BeFalse
            $Result | Should -BeOfType [bool]
        }

        It "Does not write an error or a warning when the credentials are not valid" {
            $global:AuvikTestResponses.Enqueue((New-TestHttpError -StatusCode 401))

            $Output = @(Get-AuvikAuthenticationVerify -ErrorAction Stop 3>&1 2>&1)

            $Output.Count | Should -Be 1
            $Output[0] | Should -BeOfType [bool]
        }

        It "Returns false when the API is unavailable" {
            1..4 | ForEach-Object { $global:AuvikTestResponses.Enqueue((New-TestHttpError -StatusCode 503)) }
            Get-AuvikAuthenticationVerify | Should -BeFalse
        }

        It "Returns false without a request when the API credentials are not set" {
            Remove-AuvikAPIKey -WarningAction SilentlyContinue

            Get-AuvikAuthenticationVerify | Should -BeFalse
            $global:AuvikTestCalls.Count | Should -Be 0
        }

        It "Works with the Test-AuvikAPICredential alias" {
            Test-AuvikAPICredential | Should -BeTrue

            $global:AuvikTestResponses.Enqueue((New-TestHttpError -StatusCode 401))
            Test-AuvikAPICredential | Should -BeFalse
        }

    }

    Context "Failed requests" {

        It "Writes an error & returns nothing when the item is not found" {
            $global:AuvikTestResponses.Enqueue((New-TestHttpError -StatusCode 404 -Detail '{"errors":[{"status":"404","title":"Not Found","detail":"Device 1 was not found"}]}'))

            $Result = Get-AuvikDeviceInfo -Id '1' -ErrorAction SilentlyContinue -ErrorVariable DeviceError -WarningAction SilentlyContinue

            $Result | Should -BeNullOrEmpty
            ($DeviceError | Where-Object { $_.Exception.Message -match 'Device 1 was not found' }) | Should -Not -BeNullOrEmpty
        }

        It "Retries a rate limited request" {
            $global:AuvikTestResponses.Enqueue((New-TestHttpError -StatusCode 429))
            $global:AuvikTestResponses.Enqueue((ConvertTo-TestPage -Id '1'))

            $Result = Get-AuvikDeviceInfo

            $global:AuvikTestCalls.Count | Should -Be 2
            $Result.data[0].id | Should -Be '1'
        }

    }

    Context "Parameter validation" {

        It "Does not accept a page size of 0" {
            { Get-AuvikDeviceInfo -PageFirst 0 } | Should -Throw
            $global:AuvikTestCalls.Count | Should -Be 0
        }

        It "Does not accept a device type that is not in the spec" {
            { Get-AuvikDeviceInfo -FilterDeviceType 'toaster' } | Should -Throw
            $global:AuvikTestCalls.Count | Should -Be 0
        }

        It "Does not accept an empty tenant" {
            { Get-AuvikDeviceInfo -Tenants '' } | Should -Throw
            $global:AuvikTestCalls.Count | Should -Be 0
        }

        It "Does not accept a date that is not a date" {
            { Get-AuvikDeviceInfo -FilterModifiedAfter 'yesterday-ish' } | Should -Throw
            $global:AuvikTestCalls.Count | Should -Be 0
        }

    }

    Context "Debug variables" {

        It "Stores the bound parameters & the query of the request" {
            $null = Get-AuvikDeviceInfo -Tenants 'T1' -PageFirst 3

            ($GetAuvikDeviceInfoParameters['Tenants'] -join ',') | Should -Be 'T1'
            ($GetAuvikDeviceInfoParametersQuery['tenants'] -join ',') | Should -Be 'T1'
            $GetAuvikDeviceInfoParametersQuery['page[first]'] | Should -Be 3
        }

        It "Never stores the API key in any debug variable" {
            $null = Get-AuvikDeviceInfo -Tenants 'T1'

            $DebugVariables = @(Get-Variable -Scope Global | Where-Object { $_.Name -match '^\w*Auvik\w*Parameters(Query)?$' })
            $DebugVariables.Count | Should -BeGreaterThan 1

            foreach ($DebugVariable in $DebugVariables) {
                ($DebugVariable.Value | ConvertTo-Json -Depth 4 -WarningAction SilentlyContinue) | Should -Not -Match 'fake-api-key'
            }
        }

    }

    Context "Legacy aliases" {

        It "Alias [ <AliasName> ] points to [ <FunctionName> ]" -ForEach $LegacyAliases {
            $Alias = Get-Alias -Name $AliasName

            $Alias.ResolvedCommand.Name | Should -Be $FunctionName
            (Get-Module -Name $ModuleName).ExportedAliases.Keys | Should -Contain $AliasName
        }

        It "Alias [ <AliasName> ] sends the request of [ <FunctionName> ]" -ForEach $LegacyReadAliases {
            $null = & $AliasName -Tenants '1'

            $global:AuvikTestCalls.Count | Should -Be 1
            $global:AuvikTestCalls[0].Method | Should -Be 'GET'
            $global:AuvikTestCalls[0].Uri.AbsolutePath | Should -Be $ExpectedPath
            (Get-TestQuery -Uri $global:AuvikTestCalls[0].Uri)['tenants'] | Should -Be '1'
        }

        It "Alias [ <AliasName> ] reads a single item by Id" -ForEach $LegacyReadAliases {
            $null = & $AliasName -Id 'abc'

            $global:AuvikTestCalls[0].Uri.AbsolutePath | Should -Be "$ExpectedPath/abc"
        }

        It "Get-AuvikBilling sends the billing request" {
            $null = Get-AuvikBilling -FilterFromDate ([datetime]::new(2025, 1, 1, 0, 0, 0, [System.DateTimeKind]::Utc)) -FilterThruDate ([datetime]::new(2025, 1, 31, 0, 0, 0, [System.DateTimeKind]::Utc))

            $global:AuvikTestCalls[0].Uri.AbsolutePath | Should -Be '/v1/billing/usage/client'
        }

        It "Get-AuvikSNMPPollerHistory sends the SNMP poller history request" {
            $Parameters = Get-TestParameterSet -Command (Get-Command -Name Get-AuvikSNMPPollerHistoryString)

            $null = Get-AuvikSNMPPollerHistory @Parameters

            $global:AuvikTestCalls[0].Uri.AbsolutePath | Should -Be '/v1/stat/snmppoller/string'
        }

        It "Clear-AuvikAlert dismisses an alert" {
            $null = Clear-AuvikAlert -Id 'alert9' -Confirm:$false

            $global:AuvikTestCalls[0].Method | Should -Be 'POST'
            $global:AuvikTestCalls[0].Uri.AbsolutePath | Should -Be '/v1/alert/dismiss/alert9'
        }

        It "Clear-AuvikAlert does not dismiss an alert with -WhatIf" {
            $null = Clear-AuvikAlert -Id 'alert9' -WhatIf *> $null
            $global:AuvikTestCalls.Count | Should -Be 0
        }

        It "Names the debug variables after the alias that was used" {
            $null = Get-AuvikDevice -Tenants 'T1'

            ($GetAuvikDeviceParameters['Tenants'] -join ',') | Should -Be 'T1'
        }

    }

}
