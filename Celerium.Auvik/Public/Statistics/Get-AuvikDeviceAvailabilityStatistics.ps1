function Get-AuvikDeviceAvailabilityStatistics {
<#
    .SYNOPSIS
        Provides historical device uptime and outage statistics

    .DESCRIPTION
        The Get-AuvikDeviceAvailabilityStatistics cmdlet provides
        historical device uptime and outage statistics

    .PARAMETER StatId
        ID of statistic to return

        Allowed values:
            "uptime", "outage"

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from

    .PARAMETER FilterFromTime
        Timestamp from which you want to query

    .PARAMETER FilterThruTime
        Timestamp to which you want to query (defaults to current time)

    .PARAMETER FilterInterval
        Statistics reporting interval

        Allowed values:
            "minute", "hour", "day"

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

    .PARAMETER FilterDeviceId
        Filter by device ID

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
        Get-AuvikDeviceAvailabilityStatistics -StatId uptime -FilterFromTime 2023-10-03 -FilterInterval day

        Provides the first 100 historical device uptime and outage statistics

    .EXAMPLE
        Get-AuvikDeviceAvailabilityStatistics -StatId uptime -FilterFromTime 2023-10-03 -FilterInterval day -PageFirst 1000 -AllResults

        Provides all historical device uptime and outage statistics

    .NOTES
        N\A


    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Statistics/Get-AuvikDeviceAvailabilityStatistics.html
#>

    [CmdletBinding(DefaultParameterSetName = 'Index' )]
    Param (
        [Parameter( Mandatory = $true )]
        [ValidateSet( "uptime", "outage" )]
        [string]$StatId,

        [Parameter( Mandatory = $false, ValueFromPipeline = $true )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter( Mandatory = $true )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterFromTime,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterThruTime,

        [Parameter( Mandatory = $true )]
        [ValidateSet( "minute", "hour", "day" )]
        [string]$FilterInterval,

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
        [string]$FilterDeviceId,

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

        $ResourceUri = "/stat/deviceAvailability/$StatId"

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -eq 'Index') {
            if ($Tenants)           { $UriParameters['tenants']             = $Tenants }
            if ($FilterFromTime)    { $UriParameters['filter[fromTime]']    = $FilterFromTime }
            if ($FilterThruTime)    { $UriParameters['filter[thruTime]']    = $FilterThruTime }
            if ($FilterDeviceType)  { $UriParameters['filter[deviceType]']  = $FilterDeviceType }
            if ($FilterDeviceId)    { $UriParameters['filter[deviceId]']    = $FilterDeviceId }
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
