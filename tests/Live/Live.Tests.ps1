<#
.NOTES
    Copyright 1990-2025 Celerium

    NAME: Live.Tests.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        EMAIL:   celerium@Celerium.org

.SYNOPSIS
    Optional read only integration tests against a real Auvik account

.DESCRIPTION
    Pester tests that make real GET requests against the Auvik API. The tests are tagged with 'Live' & are skipped unless
    the following environment variables are set:

        AUVIK_USERNAME      The email address of the Auvik API user
        AUVIK_API_KEY       The API key of the user

    Optional environment variables:

        AUVIK_BASE_URI      The base URI or host of the account, such as us2.my.auvik.com (default: US1)
        AUVIK_SITE_NAME     The exact display name of the ONE tenant (client) the data tests are allowed to read

    Without AUVIK_SITE_NAME, or when no single tenant has that display name, only the credentials & the tenant
    list are read & every test that reads tenant data is skipped. No unscoped data request is ever sent

    The tests find the tenant with the display name AUVIK_SITE_NAME & scope every request to it with the Tenants
    parameter. Only GET requests are sent, a request with another method is blocked. No function that writes
    (such as Send-AuvikAlertDismiss) is ever used. The requests are spaced 500 ms apart & limited to 60 per run

    No secret is ever written to the output or to a file

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
    $env:AUVIK_USERNAME = 'user@example.com'; $env:AUVIK_API_KEY = '<api key>'; $env:AUVIK_SITE_NAME = '<tenant name>'
    .\build\Invoke-PesterTests.ps1 -Version 2.0.0 -IncludeTag Live -ExcludeTag Online

    Runs only the live tests against the tenant with the display name <tenant name>

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

        $LiveConfigured = [bool]([Environment]::GetEnvironmentVariable('AUVIK_USERNAME') -and [Environment]::GetEnvironmentVariable('AUVIK_API_KEY'))

        # Read only list endpoints that are scoped to the tenant with the Tenants parameter
        $ListCases = @(
            @{ FunctionName = 'Get-AuvikDeviceInfo' }
            @{ FunctionName = 'Get-AuvikDeviceDetail' }
            @{ FunctionName = 'Get-AuvikDeviceWarranty' }
            @{ FunctionName = 'Get-AuvikDeviceLifecycle' }
            @{ FunctionName = 'Get-AuvikNetworkInfo' }
            @{ FunctionName = 'Get-AuvikNetworkDetail' }
            @{ FunctionName = 'Get-AuvikInterfaceInfo' }
            @{ FunctionName = 'Get-AuvikComponentInfo' }
            @{ FunctionName = 'Get-AuvikConfiguration' }
            @{ FunctionName = 'Get-AuvikAlertHistory' }
            @{ FunctionName = 'Get-AuvikSNMPPollerSetting' }
        )

    }

    BeforeAll {

        $TestsPath = $PSScriptRoot
        while ($TestsPath -and -not (Test-Path -Path (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1'))) { $TestsPath = Split-Path -Path $TestsPath -Parent }
        . (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1')

        $SiteName       = [Environment]::GetEnvironmentVariable('AUVIK_SITE_NAME')
        $LiveConfigured = [bool]([Environment]::GetEnvironmentVariable('AUVIK_USERNAME') -and [Environment]::GetEnvironmentVariable('AUVIK_API_KEY'))
        $TenantId       = $null

        # Live requests are spaced out & limited so that the tests stay far below the rate limits of the API
        $global:AuvikTestLiveBudget = 60

        if ($LiveConfigured) {

            # The module configures itself from the AUVIK_ environment variables when it is imported
            Import-TestModule -ModuleName $ModuleName -Version $Version -BuildTarget $BuildTarget -KeepEnvironment

            if (-not [Environment]::GetEnvironmentVariable('AUVIK_BASE_URI')) { Add-AuvikBaseURI }

            $MockModule = Get-TestMockModuleName -CommandName 'Invoke-AuvikRequest'

            # Only GET requests are allowed. Every request is recorded so the tests can verify what was sent
            $global:AuvikTestLiveCalls = [System.Collections.Generic.List[object]]::new()

            Mock Invoke-WebRequest -ModuleName $MockModule -ParameterFilter { $Method -ne 'GET' } -MockWith {
                throw "The live tests only send GET requests, a [ $Method ] request to [ $($Uri.AbsolutePath) ] was blocked"
            }

            Mock Invoke-WebRequest -ModuleName $MockModule -MockWith {
                if ($global:AuvikTestLiveCalls.Count -ge $global:AuvikTestLiveBudget) {
                    throw "The live tests are limited to [ $($global:AuvikTestLiveBudget) ] requests, the request to [ $($Uri.AbsolutePath) ] was blocked"
                }
                if ($global:AuvikTestLiveCalls.Count -gt 0) { Start-Sleep -Milliseconds 500 }
                $global:AuvikTestLiveCalls.Add([PSCustomObject]@{ Method = $Method; Path = $Uri.AbsolutePath; Query = $Uri.Query })
                Microsoft.PowerShell.Utility\Invoke-WebRequest @PesterBoundParameters
            }

            function Get-TestPagedId {
                # Follows the pagination links by hand, returns $null when there are more pages than allowed
                param (
                    [string]$FunctionName,
                    [int]$PageSize = 5,
                    [int]$MaxPages = 3
                )

                $Ids    = [System.Collections.Generic.List[string]]::new()
                $Page   = & $FunctionName -Tenants $TenantId -PageFirst $PageSize

                for ($PageCount = 1; $Page; $PageCount++) {

                    foreach ($Item in @($Page.data | Where-Object { $null -ne $_ })) { $Ids.Add("$($Item.id)") }

                    if (-not $Page.links.next) { return ,$Ids }
                    if ($PageCount -ge $MaxPages) { return $null }

                    $Cursor = (Get-TestQuery -Uri $Page.links.next)['page[after]']
                    if (-not $Cursor) { return ,$Ids }

                    $Page = & $FunctionName -Tenants $TenantId -PageFirst $PageSize -PageAfter $Cursor

                }

                return ,$Ids
            }

            function Get-TestItemTenantId {
                # The tenant of a response item when the response says which tenant it belongs to
                param ($Item)

                $Candidates = @($Item.relationships.tenant.data.id, $Item.attributes.tenantId, $Item.attributes.tenantID)
                return @($Candidates | Where-Object { $_ } | Select-Object -First 1)
            }

            function Get-TestResponseItem {
                param ($Response)
                return @($Response.data | Where-Object { $null -ne $_ })
            }

            # The tenant (client) the tests are allowed to read. Only the main (multi client) account is asked for the tenant details
            $RootTenants    = Get-AuvikTenant
            $RootPrefixes   = @($RootTenants.data | Where-Object { $_.attributes.tenantType -eq 'multiClient' } | ForEach-Object { $_.attributes.domainPrefix } | Where-Object { $_ })
            if ($RootPrefixes.Count -eq 0) { $RootPrefixes = @($RootTenants.data | Select-Object -First 1 | ForEach-Object { $_.attributes.domainPrefix } | Where-Object { $_ }) }

            # Without AUVIK_SITE_NAME no tenant is looked up & the tests that read tenant data are skipped
            $MatchingTenants = @(if ($SiteName) {
                foreach ($RootPrefix in $RootPrefixes) {
                    (Get-AuvikTenantDetail -TenantDomainPrefix $RootPrefix).data | Where-Object { $_.attributes.displayName -ceq $SiteName }
                }
            })

            $TenantId = if ($MatchingTenants.Count -eq 1) { "$($MatchingTenants[0].id)" } else { $null }

        }

    }

    AfterAll {

        if ($LiveConfigured) { Remove-TestModule -ModuleName $ModuleName }

    }

#EndRegion  [ Prerequisites ]

Describe "Testing the [ $BuildTarget ] version of [ $ModuleName ] with [ $PesterTestName ]" -Tag 'Live' -Skip:(-not $LiveConfigured) {

    Context "Credentials & tenant" {

        It "Verifies the credentials" {
            Get-AuvikAuthenticationVerify | Should -BeTrue
        }

        It "Reads the root tenant" {
            $RootTenants | Should -Not -BeNullOrEmpty
            $RootTenants.PSObject.Properties.Name | Should -Contain 'data'
            $RootPrefixes.Count | Should -BeGreaterThan 0 -Because 'a tenant has a domain prefix'

            foreach ($RootTenant in $RootTenants.data) {
                $RootTenant.id | Should -Not -BeNullOrEmpty
                $RootTenant.type | Should -Not -BeNullOrEmpty
            }
        }

        It "Finds exactly one tenant with the display name of AUVIK_SITE_NAME" {
            if (-not $SiteName) { Set-ItResult -Skipped -Because 'AUVIK_SITE_NAME is not set'; return }
            if ($MatchingTenants.Count -eq 0) { Set-ItResult -Skipped -Because 'no tenant has the display name of AUVIK_SITE_NAME, the tenant data tests are skipped'; return }
            $MatchingTenants.Count | Should -Be 1 -Because 'the display name must match exactly one tenant'
            $TenantId | Should -Not -BeNullOrEmpty
        }

        It "Reads the tenant by Id" {
            if (-not $TenantId) { Set-ItResult -Skipped -Because 'the AUVIK_SITE_NAME tenant was not found, no unscoped request is sent'; return }
            $RootPrefix = $RootPrefixes[0]

            $Response = Get-AuvikTenantDetail -TenantDomainPrefix $RootPrefix -Id $TenantId

            $Response.data | Should -Not -BeNullOrEmpty
            @($Response.data).Count | Should -Be 1
            "$(@($Response.data)[0].id)" | Should -Be $TenantId
            @($Response.data)[0].attributes.displayName | Should -BeExactly $SiteName
        }

    }

    Context "Reading data of the tenant" {

        It "[ <FunctionName> ] returns a page of items that is scoped to the tenant" -ForEach $ListCases {
            if (-not $TenantId) { Set-ItResult -Skipped -Because 'the AUVIK_SITE_NAME tenant was not found, no unscoped request is sent'; return }

            $Response = & $FunctionName -Tenants $TenantId -PageFirst 5

            $Response | Should -Not -BeNullOrEmpty -Because "[ $FunctionName ] should return a response"
            $Response.PSObject.Properties.Name | Should -Contain 'data'

            $Items = Get-TestResponseItem -Response $Response
            # The Auvik API only returns the links (& meta) of a response that has items
            if ($Items.Count -gt 0) { $Response.PSObject.Properties.Name | Should -Contain 'links' }
            $Items.Count | Should -BeLessOrEqual 5

            foreach ($Item in $Items) {
                $Item.id | Should -Not -BeNullOrEmpty
                $Item.type | Should -Not -BeNullOrEmpty

                $ItemTenant = Get-TestItemTenantId -Item $Item
                if ($ItemTenant) { "$ItemTenant" | Should -Be $TenantId }
            }

            @($Items | ForEach-Object { $_.id } | Select-Object -Unique).Count | Should -Be $Items.Count -Because 'the ids of a page are unique'
        }

        It "Returns a single item by Id" {
            if (-not $TenantId) { Set-ItResult -Skipped -Because 'the AUVIK_SITE_NAME tenant was not found, no unscoped request is sent'; return }

            $Page = Get-AuvikDeviceInfo -Tenants $TenantId -PageFirst 1
            $Items = Get-TestResponseItem -Response $Page

            if ($Items.Count -eq 0) { Set-ItResult -Skipped -Because 'the tenant has no devices'; return }

            $Response = Get-AuvikDeviceInfo -Id $Items[0].id

            @($Response.data).Count | Should -Be 1
            @($Response.data)[0].id | Should -Be $Items[0].id
            @($Response.data)[0].type | Should -Be $Items[0].type

            $ItemTenant = Get-TestItemTenantId -Item @($Response.data)[0]
            if ($ItemTenant) { "$ItemTenant" | Should -Be $TenantId }

        }

        It "Includes the detail of the devices" {
            if (-not $TenantId) { Set-ItResult -Skipped -Because 'the AUVIK_SITE_NAME tenant was not found, no unscoped request is sent'; return }

            $Response = Get-AuvikDeviceInfo -Tenants $TenantId -PageFirst 2 -Include deviceDetail
            $Items = Get-TestResponseItem -Response $Response

            if ($Items.Count -eq 0) { Set-ItResult -Skipped -Because 'the tenant has no devices'; return }

            $Response.PSObject.Properties.Name | Should -Contain 'included'
            @($Response.included | ForEach-Object { $_.type } | Select-Object -Unique) | Should -Contain 'deviceDetail'

        }

        It "Filters the devices by device type" {
            if (-not $TenantId) { Set-ItResult -Skipped -Because 'the AUVIK_SITE_NAME tenant was not found, no unscoped request is sent'; return }

            $Page = Get-AuvikDeviceInfo -Tenants $TenantId -PageFirst 5
            $Items = Get-TestResponseItem -Response $Page

            if ($Items.Count -eq 0) { Set-ItResult -Skipped -Because 'the tenant has no devices'; return }

            $DeviceType = @($Items | ForEach-Object { $_.attributes.deviceType } | Where-Object { $_ })[0]
            if (-not $DeviceType) { Set-ItResult -Skipped -Because 'the devices have no device type'; return }

            $Filtered = Get-TestResponseItem -Response (Get-AuvikDeviceInfo -Tenants $TenantId -PageFirst 5 -FilterDeviceType $DeviceType)

            $Filtered.Count | Should -BeGreaterThan 0
            @($Filtered | ForEach-Object { $_.attributes.deviceType } | Select-Object -Unique) | Should -Be @($DeviceType)

        }

        It "[ <FunctionName> ] returns the same unique items with -AllResults as when following the links by hand" -ForEach @(
            @{ FunctionName = 'Get-AuvikNetworkInfo' }
            @{ FunctionName = 'Get-AuvikAlertHistory' }
        ) {
            if (-not $TenantId) { Set-ItResult -Skipped -Because 'the AUVIK_SITE_NAME tenant was not found, no unscoped request is sent'; return }

            # At most 3 pages of 5 items are read by hand so that -AllResults is only used when it needs a few requests
            $Expected = Get-TestPagedId -FunctionName $FunctionName -PageSize 5 -MaxPages 3
            if ($null -eq $Expected) { Set-ItResult -Skipped -Because 'the tenant has too many items to read every page'; return }

            $All = & $FunctionName -Tenants $TenantId -PageFirst 5 -AllResults
            $AllItems = Get-TestResponseItem -Response $All

            if ($Expected.Count -eq 0) { $AllItems.Count | Should -Be 0; return }

            $All.PSObject.Properties.Name | Should -Contain 'data'
            @($AllItems | ForEach-Object { $_.id } | Select-Object -Unique).Count | Should -Be $AllItems.Count -Because 'every item is returned once'
            @($AllItems | ForEach-Object { "$($_.id)" } | Sort-Object) | Should -Be @($Expected | Sort-Object)

            foreach ($Item in $AllItems) {
                $ItemTenant = Get-TestItemTenantId -Item $Item
                if ($ItemTenant) { "$ItemTenant" | Should -Be $TenantId }
            }

        }

        It "Reads the statistics of the tenant without a FilterThruTime" {
            if (-not $TenantId) { Set-ItResult -Skipped -Because 'the AUVIK_SITE_NAME tenant was not found, no unscoped request is sent'; return }

            $Response = Get-AuvikDeviceAvailabilityStatistics -StatId uptime -Tenants $TenantId -FilterFromTime (Get-Date).AddDays(-1) -FilterInterval hour

            $Response | Should -Not -BeNullOrEmpty
            $Response.PSObject.Properties.Name | Should -Contain 'data'

            $Call = $global:AuvikTestLiveCalls | Where-Object { $_.Path -like '*/stat/deviceAvailability/uptime' } | Select-Object -Last 1
            $Call.Query | Should -Match 'thruTime' -Because 'the API requires filter[thruTime]'
        }

    }

    Context "Requests that were sent" {

        It "Only sent GET requests" {
            $global:AuvikTestLiveCalls.Count | Should -BeGreaterThan 0
            @($global:AuvikTestLiveCalls | Where-Object { $_.Method -ne 'GET' }).Count | Should -Be 0
        }

        It "Scoped every request for data to the tenant" {

            $RootPaths = '/v1/authentication/verify', '/v1/tenants', '/v1/tenants/detail'

            $Unscoped = @($global:AuvikTestLiveCalls | Where-Object {
                $_.Path -notin $RootPaths -and
                $_.Path -notmatch '^/v1/tenants/detail/[^/]+$' -and
                $_.Path -notmatch '^/v1/inventory/[^/]+/[^/]+/[^/]+$' -and
                $_.Query -notmatch "(?i)[?&]tenants=$([regex]::Escape($TenantId))(&|$)"
            } | ForEach-Object { $_.Path })

            $Unscoped | Should -BeNullOrEmpty -Because "every request should have the Tenants parameter. Unscoped: $($Unscoped -join ', ')"

        }

        It "Never sent a request to dismiss an alert" {
            @($global:AuvikTestLiveCalls | Where-Object { $_.Path -like '/v1/alert/dismiss*' }).Count | Should -Be 0
        }

    }

    Context "Secrets" {

        It "Does not store the API key in the debug variables" {

            $Secret = [Environment]::GetEnvironmentVariable('AUVIK_API_KEY')

            $Leaks = @(Get-Variable -Scope Global | Where-Object { $_.Name -match '^\w*Auvik\w*Parameters(Query)?$' } | Where-Object {
                $Text = $_.Value | ConvertTo-Json -Depth 4 -WarningAction SilentlyContinue
                $Text.Contains($Secret)
            } | ForEach-Object { $_.Name })

            # The key is never part of the message of a failure, only the names of the variables are
            $Leaks | Should -BeNullOrEmpty

        }

        It "Returns false for an API key that is not valid" {

            $Username = [Environment]::GetEnvironmentVariable('AUVIK_USERNAME')

            try {
                Add-AuvikAPIKey -Username $Username -ApiKey 'this-is-not-a-valid-api-key'
                Get-AuvikAuthenticationVerify | Should -BeFalse
            }
            finally {
                Add-AuvikAPIKey -Username $Username -ApiKey ([Environment]::GetEnvironmentVariable('AUVIK_API_KEY'))
            }

        }

    }

}
