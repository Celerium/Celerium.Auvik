function Get-AuvikSNMPPollerSetting {
<#
    .SYNOPSIS
        Read Multiple SNMP Poller Settings / Read Single SNMP Poller Setting

    .DESCRIPTION
        Parameter set [ List ] - The Get-AuvikSNMPPollerSetting cmdlet invokes the GET method of the /settings/snmppoller endpoint (Read Multiple SNMP Poller Settings)

        Use the Read Multiple SNMP Poller Settings API to pull the list of SNMP Poller Settings configured in Auvik.

        Parameter set [ ById ] - The Get-AuvikSNMPPollerSetting cmdlet invokes the GET method of the /settings/snmppoller/{snmpPollerSettingId} endpoint (Read Single SNMP Poller Setting)

        Use the Read Single SNMP Poller Setting API to pull details of a specific SNMP Poller Setting configured in Auvik.

    .PARAMETER SnmpPollerSettingId
        ID of the SNMP Poller Setting to retrieve

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from.

        Accepts multiple values which are sent to the API as a comma delimited list

    .PARAMETER FilterDeviceId
        Filter by device ID

    .PARAMETER FilterUseAs
        Filter by oid type

        Allowed values:
        'serialNo', 'poller'

    .PARAMETER FilterType
        Filter by type

        Allowed values:
        'string', 'numeric'

    .PARAMETER FilterDeviceType
        Filter by device type.

        Allowed values:
        'unknown', 'switch', 'l3Switch', 'router', 'accessPoint', 'firewall', 'workstation', 'server', 'storage', 'printer', 'copier', 'hypervisor', 'multimedia', 'phone', 'tablet', 'handheld', 'virtualAppliance', 'bridge', 'controller', 'hub', 'modem', 'ups', 'module', 'loadBalancer', 'camera', 'telecommunications', 'packetProcessor', 'chassis', 'airConditioner', 'virtualMachine', 'pdu', 'ipPhone', 'backhaul', 'internetOfThings', 'voipSwitch', 'stack', 'backupDevice', 'timeClock', 'lightingDevice', 'audioVisual', 'securityAppliance', 'utm', 'alarm', 'buildingManagement', 'ipmi', 'thinAccessPoint', 'thinClient', 'subnet'

    .PARAMETER FilterMakeModel
        Filter by the device's make and model.

    .PARAMETER FilterVendorName
        Filter by the device's vendor/manufacturer.

    .PARAMETER FilterOid
        Filter by OID

    .PARAMETER FilterName
        Filter by the name of the SNMP poller setting

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
        Get-AuvikSNMPPollerSetting -Tenants '1234567890'

        Returns the result of the /settings/snmppoller endpoint

    .EXAMPLE
        Get-AuvikSNMPPollerSetting -Tenants '1234567890' -PageFirst 10

        Returns the result of the /settings/snmppoller endpoint limited to the defined number of items

    .EXAMPLE
        Get-AuvikSNMPPollerSetting -Tenants '1234567890' -AllResults

        Returns every item from the /settings/snmppoller endpoint by following the pagination links

    .EXAMPLE
        Get-AuvikSNMPPollerSetting -SnmpPollerSettingId '1234567890'

        Returns the result of the /settings/snmppoller/{snmpPollerSettingId} endpoint

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /settings/snmppoller
        Endpoint : GET /settings/snmppoller/{snmpPollerSettingId}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Pollers/Get-AuvikSNMPPollerSetting.html
#>

    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById')]
        [Alias('Id')]
        [ValidateNotNullOrEmpty()]
        [string]$SnmpPollerSettingId,

        [Parameter(Mandatory = $true, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterDeviceId,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('serialNo', 'poller')]
        [string]$FilterUseAs,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('string', 'numeric')]
        [string]$FilterType,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('unknown', 'switch', 'l3Switch', 'router', 'accessPoint', 'firewall', 'workstation', 'server', 'storage', 'printer', 'copier', 'hypervisor', 'multimedia', 'phone', 'tablet', 'handheld', 'virtualAppliance', 'bridge', 'controller', 'hub', 'modem', 'ups', 'module', 'loadBalancer', 'camera', 'telecommunications', 'packetProcessor', 'chassis', 'airConditioner', 'virtualMachine', 'pdu', 'ipPhone', 'backhaul', 'internetOfThings', 'voipSwitch', 'stack', 'backupDevice', 'timeClock', 'lightingDevice', 'audioVisual', 'securityAppliance', 'utm', 'alarm', 'buildingManagement', 'ipmi', 'thinAccessPoint', 'thinClient', 'subnet')]
        [string]$FilterDeviceType,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterMakeModel,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterVendorName,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterOid,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterName,

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
                $ResourceUri = "/settings/snmppoller/$([System.Uri]::EscapeDataString($SnmpPollerSettingId))"
                $NameMap = @{}
            }
            'List' {
                $ResourceUri = '/settings/snmppoller'
                $NameMap = @{
                    Tenants          = 'tenants'
                    FilterDeviceId   = 'filter[deviceId]'
                    FilterUseAs      = 'filter[useAs]'
                    FilterType       = 'filter[type]'
                    FilterDeviceType = 'filter[deviceType]'
                    FilterMakeModel  = 'filter[makeModel]'
                    FilterVendorName = 'filter[vendorName]'
                    FilterOid        = 'filter[oid]'
                    FilterName       = 'filter[name]'
                    PageFirst        = 'page[first]'
                    PageAfter        = 'page[after]'
                    PageLast         = 'page[last]'
                    PageBefore       = 'page[before]'
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
