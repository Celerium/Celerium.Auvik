function Get-AuvikSNMPPollerHistoryInt {
<#
    .SYNOPSIS
        Read Numeric SNMP Poller Setting's History

    .DESCRIPTION
        The Get-AuvikSNMPPollerHistoryInt cmdlet invokes the GET method of the /stat/snmppoller/int endpoint (Read Numeric SNMP Poller Setting's History)

        Use the Read SNMP Poller Setting's History API to fetch the list of historical vaules for a SNMP Poller Setting.

    .PARAMETER FilterFromTime
        Timestamp from which you want to query

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterInterval
        Statistics reporting interval

        Allowed values:
        'minute', 'hour', 'day'

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from.

        Accepts multiple values which are sent to the API as a comma delimited list

    .PARAMETER FilterThruTime
        Timestamp to which you want to query (defaults to current time)

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterDeviceId
        Filter by device ID

    .PARAMETER FilterSnmpPollerSettingId
        Comma delimited list of SNMP poller setting IDs to request info from. Note this is internal snmpPollerSettingId. The user can get the list of IDs for a specific poller using the GET /settings/snmppoller endpoint.

        Accepts multiple values which are sent to the API as a comma delimited list

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned. Used in combination with page[after].

        Default value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page. The page size is provided by page[first].

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned. Used in combination with page[before].

        Default value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page. The page size is provided by page[last].

    .PARAMETER AllResults
        Returns all items from the endpoint by following the pagination links

        When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters

        Highly recommended to only use with filters to reduce API errors & timeouts

    .EXAMPLE
        Get-AuvikSNMPPollerHistoryInt -FilterFromTime '2025-01-01T00:00:00Z' -FilterInterval 'minute' -Tenants '1234567890'

        Returns the result of the /stat/snmppoller/int endpoint

    .EXAMPLE
        Get-AuvikSNMPPollerHistoryInt -FilterFromTime '2025-01-01T00:00:00Z' -FilterInterval 'minute' -Tenants '1234567890' -PageFirst 10

        Returns the result of the /stat/snmppoller/int endpoint limited to the defined number of items

    .EXAMPLE
        Get-AuvikSNMPPollerHistoryInt -FilterFromTime '2025-01-01T00:00:00Z' -FilterInterval 'minute' -Tenants '1234567890' -AllResults

        Returns every item from the /stat/snmppoller/int endpoint by following the pagination links

    .INPUTS
        None

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /stat/snmppoller/int
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Pollers/Get-AuvikSNMPPollerHistoryInt.html
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [datetime]$FilterFromTime,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('minute', 'hour', 'day')]
        [string]$FilterInterval,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter(Mandatory = $false)]
        [datetime]$FilterThruTime,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterDeviceId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string[]]$FilterSnmpPollerSettingId,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter(Mandatory = $false)]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = '/stat/snmppoller/int'
        $NameMap = @{
            FilterFromTime            = 'filter[fromTime]'
            FilterThruTime            = 'filter[thruTime]'
            FilterInterval            = 'filter[interval]'
            Tenants                   = 'tenants'
            FilterDeviceId            = 'filter[deviceId]'
            FilterSnmpPollerSettingId = 'filter[snmpPollerSettingId]'
            PageFirst                 = 'page[first]'
            PageAfter                 = 'page[after]'
            PageLast                  = 'page[last]'
            PageBefore                = 'page[before]'
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        # The API requires filter[thruTime] even though the spec defines it as optional (it defaults to the current time)
        if ($UriParameters.ContainsKey('filter[fromTime]') -and -not $UriParameters.ContainsKey('filter[thruTime]')) { $UriParameters['filter[thruTime]'] = [datetime]::UtcNow }

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
            AllResults  = $AllResults
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}
