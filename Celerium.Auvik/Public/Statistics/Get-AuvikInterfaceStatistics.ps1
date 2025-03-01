function Get-AuvikInterfaceStatistics {
<#
    .SYNOPSIS
        Provides historical interface statistics such
        as bandwidth and packet loss

    .DESCRIPTION
        The Get-AuvikInterfaceStatistics cmdlet provides historical
        interface statistics such as bandwidth and packet loss

    .PARAMETER StatId
        ID of statistic to return

        Allowed values:
            "bandwidth", "utilization", "packetLoss", "packetDiscard", "packetMulticast", "packetUnicast", "packetBroadcast"

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

    .PARAMETER FilterInterfaceType
        Filter by interface type

        Allowed values:
            "ethernet", "wifi", "bluetooth", "cdma", "coax", "cpu", "distributedVirtualSwitch",
            "firewire", "gsm", "ieee8023AdLag", "inferredWired", "inferredWireless", "interface",
            "linkAggregation", "loopback", "modem", "wimax", "optical", "other", "parallel", "ppp",
            "radiomac", "rs232", "tunnel", "unknown", "usb", "virtualBridge", "virtualNic",
            "virtualSwitch", "vlan"

    .PARAMETER FilterInterfaceId
        Filter by interface ID

    .PARAMETER FilterParentDevice
        Filter by the entity's parent device ID

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
        Get-AuvikInterfaceStatistics -StatId bandwidth -FilterFromTime 2023-10-03 -FilterInterval day

        Provides the first 100 historical interface statistics such
        as bandwidth and packet loss

    .EXAMPLE
        Get-AuvikInterfaceStatistics -StatId bandwidth -FilterFromTime 2023-10-03 -FilterInterval day -PageFirst 1000 -AllResults

        Provides all historical interface statistics such
        as bandwidth and packet loss

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Statistics/Get-AuvikInterfaceStatistics.html
#>

    [CmdletBinding(DefaultParameterSetName = 'Index' )]
    Param (
        [Parameter( Mandatory = $true )]
        [ValidateSet( "bandwidth", "utilization", "packetLoss", "packetDiscard", "packetMulticast", "packetUnicast", "packetBroadcast" )]
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
        [ValidateSet(   "ethernet", "wifi", "bluetooth", "cdma", "coax", "cpu", "distributedVirtualSwitch",
                        "firewire", "gsm", "ieee8023AdLag", "inferredWired", "inferredWireless", "interface",
                        "linkAggregation", "loopback", "modem", "wimax", "optical", "other", "parallel", "ppp",
                        "radiomac", "rs232", "tunnel", "unknown", "usb", "virtualBridge", "virtualNic",
                        "virtualSwitch", "vlan"
        )]
        [string]$FilterInterfaceType,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterInterfaceId,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterParentDevice,

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

        $ResourceUri = "/stat/interface/$StatId"

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -eq 'Index') {
            if ($Tenants)               { $UriParameters['tenants']                 = $Tenants }
            if ($FilterFromTime)        { $UriParameters['filter[fromTime]']        = $FilterFromTime }
            if ($FilterThruTime)        { $UriParameters['filter[thruTime]']        = $FilterThruTime }
            if ($FilterInterval)        { $UriParameters['filter[interval]']        = $FilterInterval }
            if ($FilterInterfaceType)   { $UriParameters['filter[interfaceType]']   = $FilterInterfaceType }
            if ($FilterInterfaceId)     { $UriParameters['filter[interfaceType]']   = $FilterInterfaceType }
            if ($FilterParentDevice)    { $UriParameters['filter[parentDevice]']    = $FilterParentDevice }
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
