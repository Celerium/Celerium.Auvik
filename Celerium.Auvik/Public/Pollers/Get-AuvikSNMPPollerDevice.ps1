function Get-AuvikSNMPPollerDevice {
<#
    .SYNOPSIS
        Read SNMP Poller Setting's Devices

    .DESCRIPTION
        The Get-AuvikSNMPPollerDevice cmdlet invokes the GET method of the /settings/snmppoller/{snmpPollerSettingId}/devices endpoint (Read SNMP Poller Setting's Devices)

        Use Read SNMP Poller Setting's Devices API to pull the list of devices that apply to a specific SNMP Poller Setting Id.

    .PARAMETER SnmpPollerSettingId
        ID of the SNMP Poller Setting that the devices apply to

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from.

        Accepts multiple values which are sent to the API as a comma delimited list

    .PARAMETER FilterOnlineStatus
        Filter by the device's online status.

        Allowed values:
        'online', 'offline', 'unreachable', 'testing', 'unknown', 'dormant', 'notPresent', 'lowerLayerDown'

    .PARAMETER FilterModifiedAfter
        Filter by date and time, only returning entities modified after provided value.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterNotSeenSince
        Filter by the last seen online time, returning entities not seen online after the provided value.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterDeviceType
        Filter by device type.

        Allowed values:
        'unknown', 'switch', 'l3Switch', 'router', 'accessPoint', 'firewall', 'workstation', 'server', 'storage', 'printer', 'copier', 'hypervisor', 'multimedia', 'phone', 'tablet', 'handheld', 'virtualAppliance', 'bridge', 'controller', 'hub', 'modem', 'ups', 'module', 'loadBalancer', 'camera', 'telecommunications', 'packetProcessor', 'chassis', 'airConditioner', 'virtualMachine', 'pdu', 'ipPhone', 'backhaul', 'internetOfThings', 'voipSwitch', 'stack', 'backupDevice', 'timeClock', 'lightingDevice', 'audioVisual', 'securityAppliance', 'utm', 'alarm', 'buildingManagement', 'ipmi', 'thinAccessPoint', 'thinClient', 'subnet'

    .PARAMETER FilterMakeModel
        Filter by the device's make and model.

    .PARAMETER FilterVendorName
        Filter by the device's vendor/manufacturer.

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
        Get-AuvikSNMPPollerDevice -SnmpPollerSettingId '1234567890' -Tenants '1234567890'

        Returns the result of the /settings/snmppoller/{snmpPollerSettingId}/devices endpoint

    .EXAMPLE
        Get-AuvikSNMPPollerDevice -SnmpPollerSettingId '1234567890' -Tenants '1234567890' -PageFirst 10

        Returns the result of the /settings/snmppoller/{snmpPollerSettingId}/devices endpoint limited to the defined number of items

    .EXAMPLE
        Get-AuvikSNMPPollerDevice -SnmpPollerSettingId '1234567890' -Tenants '1234567890' -AllResults

        Returns every item from the /settings/snmppoller/{snmpPollerSettingId}/devices endpoint by following the pagination links

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /settings/snmppoller/{snmpPollerSettingId}/devices
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Pollers/Get-AuvikSNMPPollerDevice.html
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [ValidateNotNullOrEmpty()]
        [string]$SnmpPollerSettingId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('online', 'offline', 'unreachable', 'testing', 'unknown', 'dormant', 'notPresent', 'lowerLayerDown')]
        [string]$FilterOnlineStatus,

        [Parameter(Mandatory = $false)]
        [datetime]$FilterModifiedAfter,

        [Parameter(Mandatory = $false)]
        [datetime]$FilterNotSeenSince,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('unknown', 'switch', 'l3Switch', 'router', 'accessPoint', 'firewall', 'workstation', 'server', 'storage', 'printer', 'copier', 'hypervisor', 'multimedia', 'phone', 'tablet', 'handheld', 'virtualAppliance', 'bridge', 'controller', 'hub', 'modem', 'ups', 'module', 'loadBalancer', 'camera', 'telecommunications', 'packetProcessor', 'chassis', 'airConditioner', 'virtualMachine', 'pdu', 'ipPhone', 'backhaul', 'internetOfThings', 'voipSwitch', 'stack', 'backupDevice', 'timeClock', 'lightingDevice', 'audioVisual', 'securityAppliance', 'utm', 'alarm', 'buildingManagement', 'ipmi', 'thinAccessPoint', 'thinClient', 'subnet')]
        [string]$FilterDeviceType,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterMakeModel,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterVendorName,

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

        $ResourceUri = "/settings/snmppoller/$([System.Uri]::EscapeDataString($SnmpPollerSettingId))/devices"
        $NameMap = @{
            Tenants             = 'tenants'
            FilterOnlineStatus  = 'filter[onlineStatus]'
            FilterModifiedAfter = 'filter[modifiedAfter]'
            FilterNotSeenSince  = 'filter[notSeenSince]'
            FilterDeviceType    = 'filter[deviceType]'
            FilterMakeModel     = 'filter[makeModel]'
            FilterVendorName    = 'filter[vendorName]'
            PageFirst           = 'page[first]'
            PageAfter           = 'page[after]'
            PageLast            = 'page[last]'
            PageBefore          = 'page[before]'
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
