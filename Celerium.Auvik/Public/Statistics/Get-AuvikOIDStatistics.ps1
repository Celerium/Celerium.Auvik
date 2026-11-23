function Get-AuvikOIDStatistics {
<#
    .SYNOPSIS
        Read OID Statistics

    .DESCRIPTION
        The Get-AuvikOIDStatistics cmdlet invokes the GET method of the /stat/oid/{statId} endpoint (Read OID Statistics)

        Use the Read OID Statistics API to fetch the last recorded value of a monitored device OID.

    .PARAMETER StatId
        ID of statistic to return

        Allowed values:
        'deviceMonitor'

    .PARAMETER FilterDeviceId
        Filter by device ID

    .PARAMETER FilterDeviceType
        Filter by device type.

        Allowed values:
        'unknown', 'switch', 'l3Switch', 'router', 'accessPoint', 'firewall', 'workstation', 'server', 'storage', 'printer', 'copier', 'hypervisor', 'multimedia', 'phone', 'tablet', 'handheld', 'virtualAppliance', 'bridge', 'controller', 'hub', 'modem', 'ups', 'module', 'loadBalancer', 'camera', 'telecommunications', 'packetProcessor', 'chassis', 'airConditioner', 'virtualMachine', 'pdu', 'ipPhone', 'backhaul', 'internetOfThings', 'voipSwitch', 'stack', 'backupDevice', 'timeClock', 'lightingDevice', 'audioVisual', 'securityAppliance', 'utm', 'alarm', 'buildingManagement', 'ipmi', 'thinAccessPoint', 'thinClient', 'subnet'

    .PARAMETER FilterOid
        Filter by OID

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
        Get-AuvikOIDStatistics -StatId 'd'

        Returns the result of the /stat/oid/{statId} endpoint

    .EXAMPLE
        Get-AuvikOIDStatistics -StatId 'd' -Tenants '1234567890' -PageFirst 10

        Returns the result of the /stat/oid/{statId} endpoint limited to the defined tenant

    .EXAMPLE
        Get-AuvikOIDStatistics -StatId 'd' -AllResults

        Returns every item from the /stat/oid/{statId} endpoint by following the pagination links

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /stat/oid/{statId}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Statistics/Get-AuvikOIDStatistics.html
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('deviceMonitor')]
        [string]$StatId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterDeviceId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('unknown', 'switch', 'l3Switch', 'router', 'accessPoint', 'firewall', 'workstation', 'server', 'storage', 'printer', 'copier', 'hypervisor', 'multimedia', 'phone', 'tablet', 'handheld', 'virtualAppliance', 'bridge', 'controller', 'hub', 'modem', 'ups', 'module', 'loadBalancer', 'camera', 'telecommunications', 'packetProcessor', 'chassis', 'airConditioner', 'virtualMachine', 'pdu', 'ipPhone', 'backhaul', 'internetOfThings', 'voipSwitch', 'stack', 'backupDevice', 'timeClock', 'lightingDevice', 'audioVisual', 'securityAppliance', 'utm', 'alarm', 'buildingManagement', 'ipmi', 'thinAccessPoint', 'thinClient', 'subnet')]
        [string]$FilterDeviceType,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterOid,

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

        $ResourceUri = "/stat/oid/$([System.Uri]::EscapeDataString($StatId))"
        $NameMap = @{
            FilterDeviceId   = 'filter[deviceId]'
            FilterDeviceType = 'filter[deviceType]'
            FilterOid        = 'filter[oid]'
            Tenants          = 'tenants'
            PageFirst        = 'page[first]'
            PageAfter        = 'page[after]'
            PageLast         = 'page[last]'
            PageBefore       = 'page[before]'
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

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
