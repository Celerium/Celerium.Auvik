function Get-AuvikDevice {
<#
    .SYNOPSIS
        Get Auvik devices and other related information

    .DESCRIPTION
        The Get-AuvikDevice cmdlet allows you to view an inventory of
        devices and other related information discovered by Auvik.

        Use the [ -AgentDetail, -AgentExtended, & -AgentInfo  ] parameters
        when wanting to target specific information.

        See Get-Help Get-AuvikDevice -Full for more information on associated parameters

        This function combines 6 endpoints together within the Device API.

        Read Multiple Devices' Info:
            Gets detail about multiple devices discovered on your client's network.
        Read a Single Device's Info:
            Gets detail about a specific device discovered on your client's network.

        Read Multiple Devices' Details:
            Gets details about multiple devices not already Included in the Device Info API.
        Read a Single Device's Details:
            Gets details about a specific device not already Included in the Device Info API.

        Read Multiple Device's Extended Details:
            Gets extended information about multiple devices not already Included in the Device Info API.
        Read a Single Device's Extended Details:
            Gets extended information about a specific device not already Included in the Device Info API.

    .PARAMETER ID
        ID of device

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from

    .PARAMETER FilterNetworks
        Filter by IDs of networks this device is on

    .PARAMETER FilterManageStatus
        Filter by managed status

    .PARAMETER FilterDiscoverySNMP
        Filter by the device's SNMP discovery status

        Allowed values:
            "disabled", "determining", "notSupported", "notAuthorized", "authorizing", "authorized", "privileged"

    .PARAMETER FilterDiscoveryWMI
        Filter by the device's WMI discovery status

        Allowed values:
            "disabled", "determining", "notSupported", "notAuthorized", "authorizing", "authorized", "privileged"

    .PARAMETER FilterDiscoveryLogin
        Filter by the device's Login discovery status

        Allowed values:
            "disabled", "determining", "notSupported", "notAuthorized", "authorizing", "authorized", "privileged"

    .PARAMETER FilterDiscoveryVMware
        Filter by the device's VMware discovery status

        Allowed values:
            "disabled", "determining", "notSupported", "notAuthorized", "authorizing", "authorized", "privileged"

    .PARAMETER FilterTrafficInsightsStatus
        Filter by the device's VMware discovery status

        Allowed values:
            "notDetected", "detected", "notApproved", "approved", "linking", "linkingFailed", "forwarding"

    .PARAMETER FilterDeviceType
        Filter by device type

        Allowed values:
            "accessPoint", "airConditioner", "alarm", "audioVisual", "backhaul", "backupDevice",
            "bridge", "buildingManagement", "camera", "chassis", "controller", "copier", "firewall",
            "handheld", "hub", "hypervisor", "internetOfThings", "ipmi", "ipPhone", "l3Switch",
            "lightingDevice", "loadBalancer", "modem", "module", "multimedia", "packetProcessor",
            "pdu", "phone", "printer", "router", "securityAppliance", "server", "stack", "storage",
            "switch", "tablet", "telecommunications", "thinAccessPoint", "thinClient", "timeClock",
            "unknown", "ups", "utm", "virtualAppliance", "virtualMachine", "voipSwitch", "workstation"

    .PARAMETER FilterMakeModel
        Filter by the device's make and model

    .PARAMETER FilterVendorName
        Filter by the device's vendor/manufacturer

    .PARAMETER FilterOnlineStatus
        Filter by the device's online status

        Allowed values:
        "online", "offline", "unreachable", "testing", "unknown", "dormant", "notPresent", "lowerLayerDown"

    .PARAMETER FilterModifiedAfter
        Filter by date and time, only returning entities modified after provided value

    .PARAMETER FilterNotSeenSince
        Filter by the last seen online time, returning entities not seen online after the provided value

    .PARAMETER FilterStateKnown
        Filter by devices with recently updated data, for more consistent results.

    .PARAMETER Include
        Use to Include the full resource objects of the list device relationships

        Example: Include=deviceDetail

    .PARAMETER FieldsDeviceDetail
        Use to limit the attributes that will be returned in the Included detail object to
        only what is specified by this query parameter

        Requires Include=deviceDetail

    .PARAMETER AgentDetail
        Target the detail agents endpoint

        /Inventory/device/detail & /Inventory/device/detail/{id}

    .PARAMETER AgentExtended
        Target the extended agents endpoint

        /Inventory/device/detail/extended & /Inventory/device/detail/extended/{id}

    .PARAMETER AgentInfo
        Target the info agent endpoint

        Only needed when limiting general search by id, to give the parameter
        set a unique value.

        /Inventory/device/info & /Inventory/device/info

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
        Get-AuvikDevice

        Gets general information about the first 100 devices
        Auvik has discovered

    .EXAMPLE
        Get-AuvikDevice -ID 123456789 -AgentInfo

        Gets general information for the defined device
        Auvik has discovered

    .EXAMPLE
        Get-AuvikDevice -AgentDetail

        Gets detailed information about the first 100 devices
        Auvik has discovered

    .EXAMPLE
        Get-AuvikDevice -ID 123456789 -AgentDetail

        Gets AgentDetail information for the defined device
        Auvik has discovered

    .EXAMPLE
        Get-AuvikDevice -AgentExtended

        Gets extended detail information about the first 100 devices
        Auvik has discovered

    .EXAMPLE
        Get-AuvikDevice -ID 123456789 -AgentExtended

        Gets extended detail information for the defined device
        Auvik has discovered

    .EXAMPLE
        Get-AuvikDevice -PageFirst 1000 -AllResults

        Gets general information for all devices found by Auvik.

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikDevice.html
#>

    [CmdletBinding(DefaultParameterSetName = 'IndexByMultiDeviceInfo' )]
    Param (
        [Parameter( Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'IndexBySingleDeviceInfo' )]
        [Parameter( Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'IndexBySingleDeviceDetail' )]
        [Parameter( Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'IndexBySingleDeviceExtDetail' )]
        [ValidateNotNullOrEmpty()]
        [string]$ID,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceDetail' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceExtDetail' )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterNetworks,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceDetail' )]
        [switch]$FilterManageStatus,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceDetail' )]
        [ValidateSet( "disabled", "determining", "notSupported", "notAuthorized", "authorizing", "authorized", "privileged" )]
        [string]$FilterDiscoverySNMP,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceDetail' )]
        [ValidateSet( "disabled", "determining", "notSupported", "notAuthorized", "authorizing", "authorized", "privileged" )]
        [string]$FilterDiscoveryWMI,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceDetail' )]
        [ValidateSet( "disabled", "determining", "notSupported", "notAuthorized", "authorizing", "authorized", "privileged" )]
        [string]$FilterDiscoveryLogin,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceDetail' )]
        [ValidateSet( "disabled", "determining", "notSupported", "notAuthorized", "authorizing", "authorized", "privileged" )]
        [string]$FilterDiscoveryVMware,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceDetail' )]
        [ValidateSet( "notDetected", "detected", "notApproved", "approved", "linking", "linkingFailed", "forwarding" )]
        [string]$FilterTrafficInsightsStatus,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [Parameter( Mandatory = $true , ParameterSetName = 'IndexByMultiDeviceExtDetail' )]
        [ValidateSet(   "accessPoint", "airConditioner", "alarm", "audioVisual", "backhaul", "backupDevice",
                        "bridge", "buildingManagement", "camera", "chassis", "controller", "copier", "firewall",
                        "handheld", "hub", "hypervisor", "internetOfThings", "ipmi", "ipPhone", "l3Switch",
                        "lightingDevice", "loadBalancer", "modem", "module", "multimedia", "packetProcessor",
                        "pdu", "phone", "printer", "router", "securityAppliance", "server", "stack", "storage",
                        "switch", "tablet", "telecommunications", "thinAccessPoint", "thinClient", "timeClock",
                        "unknown", "ups", "utm", "virtualAppliance", "virtualMachine", "voipSwitch", "workstation"
        )]
        [string]$FilterDeviceType,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterMakeModel,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterVendorName,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [ValidateSet( "online", "offline", "unreachable", "testing", "unknown", "dormant", "notPresent", "lowerLayerDown" )]
        [string]$FilterOnlineStatus,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceExtDetail' )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterModifiedAfter,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceExtDetail' )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterNotSeenSince,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceExtDetail' )]
        [switch]$FilterStateKnown,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexBySingleDeviceInfo' )]
        [ValidateNotNullOrEmpty()]
        [string]$Include,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexBySingleDeviceInfo' )]
        [ValidateSet( "discoveryStatus", "components", "connectedDevices", "configurations", "manageStatus", "interfaces" )]
        [string]$FieldsDeviceDetail,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceDetail' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexBySingleDeviceDetail' )]
        [switch]$AgentDetail,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceExtDetail' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexBySingleDeviceExtDetail' )]
        [switch]$AgentExtended,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexBySingleDeviceInfo' )]
        [switch]$AgentInfo,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceDetail' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceExtDetail' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceDetail' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceExtDetail' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceDetail' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceExtDetail' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceDetail' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceExtDetail' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceDetail' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceExtDetail' )]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = $functionName + '_Parameters'      -replace '-','_'
        $QueryParameterName = $functionName + '_ParametersQuery' -replace '-','_'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        switch ( $($PSCmdlet.ParameterSetName) ) {
            'IndexByMultiDeviceInfo'        { $ResourceUri = "/inventory/device/info" }
            'IndexBySingleDeviceInfo'       { $ResourceUri = "/inventory/device/info/$ID" }

            'IndexByMultiDeviceDetail'      { $ResourceUri = "/inventory/device/detail" }
            'IndexBySingleDeviceDetail'     { $ResourceUri = "/inventory/device/detail/$ID" }

            'IndexByMultiDeviceExtDetail'   { $ResourceUri = "/inventory/device/detail/extended" }
            'IndexBySingleDeviceExtDetail'  { $ResourceUri = "/inventory/device/detail/extended/$ID" }
        }

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -eq 'IndexByMultiDeviceInfo') {
            if ($FilterMakeModel)       { $UriParameters['filter[makeModel]']       = $FilterMakeModel }
            if ($FilterNetworks)        { $UriParameters['filter[networks]']        = $FilterNetworks }
            if ($FilterOnlineStatus)    { $UriParameters['filter[onlineStatus]']    = $FilterOnlineStatus }
            if ($FilterVendorName)      { $UriParameters['filter[vendorName]']      = $FilterVendorName }
        }

        if ($PSCmdlet.ParameterSetName -eq 'IndexByMultiDeviceInfo' -or $PSCmdlet.ParameterSetName -eq 'IndexBySingleDeviceDetail') {
            if ($FieldsDeviceDetail)    { $UriParameters['fields[deviceDetail]']    = $FieldsDeviceDetail }
            if ($Include)               { $UriParameters['include']                 = $Include }
        }

        if ($PSCmdlet.ParameterSetName -eq 'IndexByMultiDeviceDetail') {
            if ($FilterDiscoveryLogin)  { $UriParameters['filter[discoveryLogin]']  = $FilterDiscoveryLogin }
            if ($FilterDiscoverySNMP)   { $UriParameters['filter[discoverySNMP]']   = $FilterDiscoverySNMP }
            if ($FilterDiscoveryVMware) { $UriParameters['filter[discoveryVMware]'] = $FilterDiscoveryVMware }
            if ($FilterDiscoveryWMI)    { $UriParameters['filter[discoveryWMI]']    = $FilterDiscoveryWMI }
            if ($FilterManageStatus)    { $UriParameters['filter[manageStatus]']    = $FilterManageStatus }
            if ($FilterTrafficInsightsStatus) { $UriParameters['filter[trafficInsightsStatus]'] = $FilterTrafficInsightsStatus }
        }

        if ($PSCmdlet.ParameterSetName -like 'IndexByMultiDevice*') {
            if ($FilterDeviceType)      { $UriParameters['filter[deviceType]']      = $FilterDeviceType }
            if ($FilterModifiedAfter)   { $UriParameters['filter[modifiedAfter]']   = $FilterModifiedAfter }
            if ($FilterNotSeenSince)    { $UriParameters['filter[notSeenSince]']    = $FilterNotSeenSince }
            if ($FilterStateKnown)      { $UriParameters['filter[stateKnown]']      = $FilterStateKnown }
            if ($Tenants)               { $UriParameters['tenants']                 = $Tenants }
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
