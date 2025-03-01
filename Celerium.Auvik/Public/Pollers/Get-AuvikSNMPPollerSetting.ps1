function Get-AuvikSNMPPollerSetting {
<#
    .SYNOPSIS
        Provides Details about one or more SNMP Poller Settings.

    .DESCRIPTION
        The Get-AuvikSNMPPollerSetting cmdlet provides Details about
        one or more SNMP Poller Settings.

    .PARAMETER SNMPPollerSettingId
        ID of the SNMP Poller Setting to retrieve

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from

    .PARAMETER FilterDeviceId
        Filter by device ID

    .PARAMETER FilterUseAs
        Filter by oid type

        Allowed values:
            "serialNo", "poller"

    .PARAMETER FilterType
        Filter by type

        Allowed values:
            "string", "numeric"

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

    .PARAMETER FilterOID
        Filter by OID

    .PARAMETER FilterName
        Filter by the name of the SNMP poller setting

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
        Get-AuvikSNMPPollerSetting -Tenants 123456789

        Provides Details about the first 100 SNMP Poller Settings
        associated to the defined tenant

    .EXAMPLE
        Get-AuvikSNMPPollerSetting -Tenants 123456789 -PageFirst 1000 -AllResults

        Provides Details about all the SNMP Poller Settings
        associated to the defined tenant

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Pollers/Get-AuvikSNMPPollerSetting.html
#>

    [CmdletBinding(DefaultParameterSetName = 'IndexByMultiSNMP' )]
    Param (
        [Parameter( Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'IndexBySingleSNMP' )]
        [ValidateNotNullOrEmpty()]
        [string]$SNMPPollerSettingId,

        [Parameter( Mandatory = $true, ParameterSetName = 'IndexByMultiSNMP' )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiSNMP' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterDeviceId,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiSNMP' )]
        [ValidateSet( "serialNo", "poller")]
        [string]$FilterUseAs,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiSNMP' )]
        [ValidateSet( "string", "numeric")]
        [string]$FilterType,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiSNMP' )]
        [ValidateSet(   "unknown", "switch", "l3Switch", "router", "accessPoint", "firewall", "workstation",
                        "server", "storage", "printer", "copier", "hypervisor", "multimedia", "phone", "tablet",
                        "handheld", "virtualAppliance", "bridge", "controller", "hub", "modem", "ups", "module",
                        "loadBalancer", "camera", "telecommunications", "packetProcessor", "chassis", "airConditioner",
                        "virtualMachine", "pdu", "ipPhone", "backhaul", "internetOfThings", "voipSwitch", "stack",
                        "backupDevice", "timeClock", "lightingDevice", "audioVisual", "securityAppliance", "utm",
                        "alarm", "buildingManagement", "ipmi", "thinAccessPoint", "thinClient"
        )]
        [string]$FilterDeviceType,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiSNMP' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterMakeModel,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiSNMP' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterVendorName,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiSNMP' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterOID,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiSNMP' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterName,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiSNMP' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiSNMP' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiSNMP' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiSNMP' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiSNMP' )]
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
            'IndexByMultiSNMP'   { $ResourceUri = "/settings/snmppoller" }
            'IndexBySingleSNMP'  { $ResourceUri = "/settings/snmppoller/$SNMPPollerSettingId" }
        }

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -eq 'IndexByMultiSNMP') {
            if ($Tenants)           { $UriParameters['tenantId']            = $Tenants }
            if ($FilterDeviceId)    { $UriParameters['filter[deviceId]']    = $FilterDeviceId }
            if ($FilterUseAs)       { $UriParameters['filter[useAs]']       = $FilterUseAs }
            if ($FilterType)        { $UriParameters['filter[type]']        = $FilterType }
            if ($FilterDeviceType)  { $UriParameters['filter[deviceType]']  = $FilterDeviceType }
            if ($FilterMakeModel)   { $UriParameters['filter[makeModel]']   = $FilterMakeModel }
            if ($FilterVendorName)  { $UriParameters['filter[vendorName]']  = $FilterVendorName }
            if ($FilterOID)         { $UriParameters['filter[oid]']         = $FilterOID }
            if ($FilterName)        { $UriParameters['filter[name]']        = $FilterName }
            if ($PageFirst)         { $UriParameters['page[first]']         = $PageFirst }
            if ($PageAfter)         { $UriParameters['page[after]']         = $PageAfter }
            if ($PageLast)          { $UriParameters['page[last]']          = $PageLast }
            if ($PageBefore)        { $UriParameters['page[before]']        = $PageBefore }
        }

        #EndRegion  [ Parameter Translation ]

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

        return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

    }

    end {}

}
