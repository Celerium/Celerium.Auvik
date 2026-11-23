function Get-AuvikDeviceAvailabilityStatistics {
<#
    .SYNOPSIS
        Read Device Availability Statistics

    .DESCRIPTION
        The Get-AuvikDeviceAvailabilityStatistics cmdlet invokes the GET method of the /stat/deviceAvailability/{statId} endpoint (Read Device Availability Statistics)

        Use the Read Device Availability Statistics API to fetch detailed availability statistics of a client's (and client's children if a multi-client) devices for a given time range.

    .PARAMETER StatId
        ID of statistic to return

        Allowed values:
        'uptime', 'outage'

    .PARAMETER FilterFromTime
        Timestamp from which you want to query

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterInterval
        Statistics reporting interval

        Allowed values:
        'minute', 'hour', 'day'

    .PARAMETER FilterThruTime
        Timestamp to which you want to query (defaults to current time)

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterDeviceType
        Filter by device type.

        Allowed values:
        'unknown', 'switch', 'l3Switch', 'router', 'accessPoint', 'firewall', 'workstation', 'server', 'storage', 'printer', 'copier', 'hypervisor', 'multimedia', 'phone', 'tablet', 'handheld', 'virtualAppliance', 'bridge', 'controller', 'hub', 'modem', 'ups', 'module', 'loadBalancer', 'camera', 'telecommunications', 'packetProcessor', 'chassis', 'airConditioner', 'virtualMachine', 'pdu', 'ipPhone', 'backhaul', 'internetOfThings', 'voipSwitch', 'stack', 'backupDevice', 'timeClock', 'lightingDevice', 'audioVisual', 'securityAppliance', 'utm', 'alarm', 'buildingManagement', 'ipmi', 'thinAccessPoint', 'thinClient', 'subnet'

    .PARAMETER FilterDeviceId
        Filter by device ID

    .PARAMETER FilterOmitUndiscovered
        When true, omits availability data for time periods before the device was first discovered (See firstDiscoveredDateTime).

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from.

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
        Get-AuvikDeviceAvailabilityStatistics -StatId 'uptime' -FilterFromTime '2025-01-01T00:00:00Z' -FilterInterval 'minute'

        Returns the result of the /stat/deviceAvailability/{statId} endpoint

    .EXAMPLE
        Get-AuvikDeviceAvailabilityStatistics -StatId 'uptime' -FilterFromTime '2025-01-01T00:00:00Z' -FilterInterval 'minute' -Tenants '1234567890' -PageFirst 10

        Returns the result of the /stat/deviceAvailability/{statId} endpoint limited to the defined tenant

    .EXAMPLE
        Get-AuvikDeviceAvailabilityStatistics -StatId 'uptime' -FilterFromTime '2025-01-01T00:00:00Z' -FilterInterval 'minute' -AllResults

        Returns every item from the /stat/deviceAvailability/{statId} endpoint by following the pagination links

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /stat/deviceAvailability/{statId}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Statistics/Get-AuvikDeviceAvailabilityStatistics.html
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('uptime', 'outage')]
        [string]$StatId,

        [Parameter(Mandatory = $true)]
        [datetime]$FilterFromTime,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('minute', 'hour', 'day')]
        [string]$FilterInterval,

        [Parameter(Mandatory = $false)]
        [datetime]$FilterThruTime,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('unknown', 'switch', 'l3Switch', 'router', 'accessPoint', 'firewall', 'workstation', 'server', 'storage', 'printer', 'copier', 'hypervisor', 'multimedia', 'phone', 'tablet', 'handheld', 'virtualAppliance', 'bridge', 'controller', 'hub', 'modem', 'ups', 'module', 'loadBalancer', 'camera', 'telecommunications', 'packetProcessor', 'chassis', 'airConditioner', 'virtualMachine', 'pdu', 'ipPhone', 'backhaul', 'internetOfThings', 'voipSwitch', 'stack', 'backupDevice', 'timeClock', 'lightingDevice', 'audioVisual', 'securityAppliance', 'utm', 'alarm', 'buildingManagement', 'ipmi', 'thinAccessPoint', 'thinClient', 'subnet')]
        [string]$FilterDeviceType,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterDeviceId,

        [Parameter(Mandatory = $false)]
        [bool]$FilterOmitUndiscovered,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

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

        $ResourceUri = "/stat/deviceAvailability/$([System.Uri]::EscapeDataString($StatId))"
        $NameMap = @{
            FilterFromTime         = 'filter[fromTime]'
            FilterThruTime         = 'filter[thruTime]'
            FilterInterval         = 'filter[interval]'
            FilterDeviceType       = 'filter[deviceType]'
            FilterDeviceId         = 'filter[deviceId]'
            FilterOmitUndiscovered = 'filter[omitUndiscovered]'
            Tenants                = 'tenants'
            PageFirst              = 'page[first]'
            PageAfter              = 'page[after]'
            PageLast               = 'page[last]'
            PageBefore             = 'page[before]'
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
