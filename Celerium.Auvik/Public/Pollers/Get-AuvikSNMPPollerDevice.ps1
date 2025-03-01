function Get-AuvikSNMPPollerDevice {
<#
    .SYNOPSIS
        Provides Details about all the devices associated to a
        specific SNMP Poller Setting.

    .DESCRIPTION
        The Get-AuvikSNMPPollerDevice cmdlet provides Details about all
        the devices associated to a specific SNMP Poller Setting.

    .PARAMETER SNMPPollerSettingId
        ID of the SNMP Poller Setting that the devices apply to

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from

    .PARAMETER FilterOnlineStatus
        Filter by the device's online status

        Allowed values:
            "online", "offline", "unreachable", "testing", "unknown", "dormant", "notPresent", "lowerLayerDown"

    .PARAMETER FilterModifiedAfter
        Filter by date and time, only returning entities modified after provided value

    .PARAMETER FilterNotSeenSince
        Filter by the last seen online time, returning entities not
        seen online after the provided value.

    .PARAMETER FilterDeviceType
        Filter by device type

        Allowed values:
            "unknown", "switch", "l3Switch", "router", "accessPoint", "firewall", "workstation",
            "server", "storage", "printer", "copier", "hypervisor", "multimedia", "phone", "tablet",
            "handheld", "virtualAppliance", "bridge", "controller", "hub", "modem", "ups", "module",
            "loadBalancer", "camera", "telecommunications", "packetProcessor", "chassis", "airConditioner",
            "virtualMachine", "pdu", "ipPhone", "backhaul", "internetOfThings", "voipSwitch", "stack",
            "backupDevice", "timeClock", "lightingDevice", "audioVisual", "securityAppliance", "utm",
            "alarm", "buildingManagement", "ipmi", "thinAccessPoint", "thinClient"

    .PARAMETER FilterMakeModel
        Filter by the device's make and model

    .PARAMETER FilterVendorName
        Filter by the device's vendor/manufacturer

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned
        Used in combination with page[after]

        Default Value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page
        The page size is provided by page[first]

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned
        Used in combination with page[before]

        Default Value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page
        The page size is provided by page[last]

    .PARAMETER AllResults
        Returns all items from an endpoint

        Highly recommended to only use with filters to reduce API errors\timeouts

    .EXAMPLE
        Get-AuvikSNMPPollerDevice -SNMPPollerSettingId MTk5NTAyNzg2ODc3 -Tenants 123456789

        Provides Details about the first 100 devices associated to the defined
        SNMP Poller id


    .EXAMPLE
        Get-AuvikSNMPPollerDevice -SNMPPollerSettingId MTk5NTAyNzg2ODc3 -Tenants 123456789 -PageFirst 1000 -AllResults

        Provides Details about all the devices associated to the defined
        SNMP Poller id

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Pollers/Get-AuvikSNMPPollerDevice.html
#>

    [CmdletBinding(DefaultParameterSetName = 'Index' )]
    Param (
        [Parameter( Mandatory = $true, ValueFromPipeline = $true )]
        [ValidateNotNullOrEmpty()]
        [string]$SNMPPollerSettingId,

        [Parameter( Mandatory = $true )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter( Mandatory = $false )]
        [ValidateSet( "online", "offline", "unreachable", "testing", "unknown", "dormant", "notPresent", "lowerLayerDown" )]
        [string]$FilterOnlineStatus,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterModifiedAfter,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterNotSeenSince,

        [Parameter( Mandatory = $false )]
        [ValidateSet(   "unknown", "switch", "l3Switch", "router", "accessPoint", "firewall", "workstation",
                        "server", "storage", "printer", "copier", "hypervisor", "multimedia", "phone", "tablet",
                        "handheld", "virtualAppliance", "bridge", "controller", "hub", "modem", "ups", "module",
                        "loadBalancer", "camera", "telecommunications", "packetProcessor", "chassis", "airConditioner",
                        "virtualMachine", "pdu", "ipPhone", "backhaul", "internetOfThings", "voipSwitch", "stack",
                        "backupDevice", "timeClock", "lightingDevice", "audioVisual", "securityAppliance", "utm",
                        "alarm", "buildingManagement", "ipmi", "thinAccessPoint", "thinClient"
        )]
        [string]$FilterDeviceType,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterMakeModel,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterVendorName,

        [Parameter( Mandatory = $false )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter( Mandatory = $false )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter( Mandatory = $false )]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = $functionName + '_Parameters'      -replace '-','_'
        $QueryParameterName = $functionName + '_ParametersQuery' -replace '-','_'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = "/settings/snmppoller/$SNMPPollerSettingId/devices"

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -eq 'Index') {
            if ($Tenants)               { $UriParameters['tenantId']                = $Tenants }
            if ($FilterOnlineStatus)    { $UriParameters['filter[onlineStatus]']    = $FilterOnlineStatus }
            if ($FilterModifiedAfter)   { $UriParameters['filter[modifiedAfter]']   = $FilterModifiedAfter }
            if ($FilterNotSeenSince)    { $UriParameters['filter[notSeenSince]']    = $FilterNotSeenSince }
            if ($FilterDeviceType)      { $UriParameters['filter[deviceType]']      = $FilterDeviceType }
            if ($FilterMakeModel)       { $UriParameters['filter[makeModel]']       = $FilterMakeModel }
            if ($FilterVendorName)      { $UriParameters['filter[vendorName]']      = $FilterVendorName }
            if ($PageFirst)             { $UriParameters['page[first]']             = $PageFirst }
            if ($PageAfter)             { $UriParameters['page[after]']             = $PageAfter }
            if ($PageLast)              { $UriParameters['page[last]']              = $PageLast }
            if ($PageBefore)            { $UriParameters['page[before]']            = $PageBefore }
        }

        #EndRegion  [ Parameter Translation ]

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

        return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

    }

    end {}

}
