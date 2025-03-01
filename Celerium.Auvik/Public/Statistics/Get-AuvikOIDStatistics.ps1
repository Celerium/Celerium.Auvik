function Get-AuvikOIDStatistics {
<#
    .SYNOPSIS
        Provides the current value for numeric SNMP Pollers

    .DESCRIPTION
        The Get-AuvikOIDStatistics cmdlet provides the current
        value for numeric SNMP Pollers

    .PARAMETER StatId
        ID of statistic to return

        Example: "deviceMonitor"

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from

    .PARAMETER FilterDeviceId
        Filter by device ID

    .PARAMETER FilterDeviceType
        Filter by device type

        Allowed values:
            "unknown", "switch", "l3Switch", "router", "accessPoint", "firewall",
            "workstation", "server", "storage", "printer", "copier", "hypervisor",
            "multimedia", "phone", "tablet", "handheld", "virtualAppliance", "bridge",
            "controller", "hub", "modem", "ups", "module", "loadBalancer", "camera",
            "telecommunications", "packetProcessor", "chassis", "airConditioner",
            "virtualMachine", "pdu", "ipPhone", "backhaul", "internetOfThings",
            "voipSwitch", "stack", "backupDevice", "timeClock", "lightingDevice",
            "audioVisual", "securityAppliance", "utm", "alarm", "buildingManagement",
            "ipmi", "thinAccessPoint", "thinClient"

    .PARAMETER FilterOID
        Filter by OID

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
        Get-AuvikOIDStatistics -StatId deviceMonitor

        Provides the first 100 values for numeric SNMP Pollers

    .EXAMPLE
        Get-AuvikOIDStatistics -StatId deviceMonitor -PageFirst 1000 -AllResults

        Provides all values for numeric SNMP Pollers

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Statistics/Get-AuvikOIDStatistics.html
#>

    [CmdletBinding(DefaultParameterSetName = 'Index' )]
    Param (
        [Parameter( Mandatory = $true )]
        [ValidateNotNullOrEmpty()]
        [string]$StatId,

        [Parameter( Mandatory = $false, ValueFromPipeline = $true )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterDeviceId,

        [Parameter( Mandatory = $false )]
        [ValidateSet(   "unknown", "switch", "l3Switch", "router", "accessPoint", "firewall",
                        "workstation", "server", "storage", "printer", "copier", "hypervisor",
                        "multimedia", "phone", "tablet", "handheld", "virtualAppliance", "bridge",
                        "controller", "hub", "modem", "ups", "module", "loadBalancer", "camera",
                        "telecommunications", "packetProcessor", "chassis", "airConditioner",
                        "virtualMachine", "pdu", "ipPhone", "backhaul", "internetOfThings",
                        "voipSwitch", "stack", "backupDevice", "timeClock", "lightingDevice",
                        "audioVisual", "securityAppliance", "utm", "alarm", "buildingManagement",
                        "ipmi", "thinAccessPoint", "thinClient"
        )]
        [string]$FilterDeviceType,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterOID,

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

        $ResourceUri = "/stat/oid/$StatId"

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -eq 'Index') {
            if ($Tenants)           { $UriParameters['tenants']             = $Tenants }
            if ($FilterDeviceId)    { $UriParameters['filter[deviceId]']    = $FilterDeviceId }
            if ($FilterDeviceType)  { $UriParameters['filter[deviceType]']  = $FilterDeviceType }
            if ($FilterOID)         { $UriParameters['filter[oid]']         = $FilterOID}
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
