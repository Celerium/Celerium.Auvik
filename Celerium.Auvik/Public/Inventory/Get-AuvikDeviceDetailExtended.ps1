function Get-AuvikDeviceDetailExtended {
<#
    .SYNOPSIS
        Read Multiple Devices' Extended Details / Read a Single Device's Extended Details

    .DESCRIPTION
        Parameter set [ List ] - The Get-AuvikDeviceDetailExtended cmdlet invokes the GET method of the /inventory/device/detail/extended endpoint (Read Multiple Devices' Extended Details)

        Use the Read Multiple Devices' Extended Details API to get many devices' extended details. Many device types have information collected and tracked by Auvik that are unique to that device type. Use this endpoint to access such information for a given device. You'll need the client IDs for the clients you want to run the multiple read against.

        Parameter set [ ById ] - The Get-AuvikDeviceDetailExtended cmdlet invokes the GET method of the /inventory/device/detail/extended/{id} endpoint (Read a Single Device's Extended Details)

        Use the Read Single Device's Extended Details API to get a device's extended details. Many device types have information collected and tracked by Auvik that are unique to that device type. Use this endpoint to access such information for a given device.

    .PARAMETER Id
        ID of device

    .PARAMETER FilterDeviceType
        Filter by device type.

        Allowed values:
        'unknown', 'switch', 'l3Switch', 'router', 'accessPoint', 'firewall', 'workstation', 'server', 'storage', 'printer', 'copier', 'hypervisor', 'multimedia', 'phone', 'tablet', 'handheld', 'virtualAppliance', 'bridge', 'controller', 'hub', 'modem', 'ups', 'module', 'loadBalancer', 'camera', 'telecommunications', 'packetProcessor', 'chassis', 'airConditioner', 'virtualMachine', 'pdu', 'ipPhone', 'backhaul', 'internetOfThings', 'voipSwitch', 'stack', 'backupDevice', 'timeClock', 'lightingDevice', 'audioVisual', 'securityAppliance', 'utm', 'alarm', 'buildingManagement', 'ipmi', 'thinAccessPoint', 'thinClient', 'subnet'

    .PARAMETER FilterModifiedAfter
        Filter by date and time, only returning entities modified after provided value.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterNotSeenSince
        Filter by the last seen online time, returning entities not seen online after the provided value.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterStateKnown
        Filter by devices with recently updated data, for more consistent results.

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
        Get-AuvikDeviceDetailExtended -FilterDeviceType 'unknown'

        Returns the result of the /inventory/device/detail/extended endpoint

    .EXAMPLE
        Get-AuvikDeviceDetailExtended -FilterDeviceType 'unknown' -Tenants '1234567890' -PageFirst 10

        Returns the result of the /inventory/device/detail/extended endpoint limited to the defined tenant

    .EXAMPLE
        Get-AuvikDeviceDetailExtended -FilterDeviceType 'unknown' -AllResults

        Returns every item from the /inventory/device/detail/extended endpoint by following the pagination links

    .EXAMPLE
        Get-AuvikDeviceDetailExtended -Id '1234567890'

        Returns the result of the /inventory/device/detail/extended/{id} endpoint

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /inventory/device/detail/extended
        Endpoint : GET /inventory/device/detail/extended/{id}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikDeviceDetailExtended.html
#>

    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById')]
        [ValidateNotNullOrEmpty()]
        [string]$Id,

        [Parameter(Mandatory = $true, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('unknown', 'switch', 'l3Switch', 'router', 'accessPoint', 'firewall', 'workstation', 'server', 'storage', 'printer', 'copier', 'hypervisor', 'multimedia', 'phone', 'tablet', 'handheld', 'virtualAppliance', 'bridge', 'controller', 'hub', 'modem', 'ups', 'module', 'loadBalancer', 'camera', 'telecommunications', 'packetProcessor', 'chassis', 'airConditioner', 'virtualMachine', 'pdu', 'ipPhone', 'backhaul', 'internetOfThings', 'voipSwitch', 'stack', 'backupDevice', 'timeClock', 'lightingDevice', 'audioVisual', 'securityAppliance', 'utm', 'alarm', 'buildingManagement', 'ipmi', 'thinAccessPoint', 'thinClient', 'subnet')]
        [string]$FilterDeviceType,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [datetime]$FilterModifiedAfter,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [datetime]$FilterNotSeenSince,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [bool]$FilterStateKnown,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        switch ($PSCmdlet.ParameterSetName) {
            'ById' {
                $ResourceUri = "/inventory/device/detail/extended/$([System.Uri]::EscapeDataString($Id))"
                $NameMap = @{}
            }
            'List' {
                $ResourceUri = '/inventory/device/detail/extended'
                $NameMap = @{
                    FilterDeviceType    = 'filter[deviceType]'
                    FilterModifiedAfter = 'filter[modifiedAfter]'
                    FilterNotSeenSince  = 'filter[notSeenSince]'
                    FilterStateKnown    = 'filter[stateKnown]'
                    Tenants             = 'tenants'
                    PageFirst           = 'page[first]'
                    PageAfter           = 'page[after]'
                    PageLast            = 'page[last]'
                    PageBefore          = 'page[before]'
                }
            }
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
