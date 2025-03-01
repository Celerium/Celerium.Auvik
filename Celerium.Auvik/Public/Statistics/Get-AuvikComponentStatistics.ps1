function Get-AuvikComponentStatistics {
<#
    .SYNOPSIS
        Provides historical statistics for components
        such as CPUs, disks, fans and memory

    .DESCRIPTION
        The Get-AuvikComponentStatistics cmdlet provides historical
        statistics for components such as CPUs, disks, fans and memory

        Make sure to read the documentation when defining ComponentType & StatId,
        as only certain StatId's work with certain ComponentTypes

        https://auvikapi.us1.my.auvik.com/docs#operation/readInterfaceStatistics

    .PARAMETER ComponentType
        Component type of statistic to return

        Allowed values:
            "cpu", "cpuCore", "disk", "fan", "memory", "powerSupply", "systemBoard"

    .PARAMETER StatId
        ID of statistic to return

        Allowed values:
            "capacity", "counters", "idle", "latency", "power", "queueLatency",
            "rate", "readiness", "ready", "speed", "swap", "swapRate", "temperature",
            "totalLatency", "utilization"

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

    .PARAMETER FilterComponentId
        Filter by component ID

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
        Get-AuvikComponentStatistics -ComponentType cpu -StatId latency -FilterFromTime 2023-10-03 -FilterInterval day

        Provides the first 100 historical statistics for CPU components

    .EXAMPLE
        Get-AuvikComponentStatistics -ComponentType cpu -StatId latency -FilterFromTime 2023-10-03 -FilterInterval day -PageFirst 1000 -AllResults

        Provides all historical statistics for CPU components

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Statistics/Get-AuvikComponentStatistics.html
#>

    [CmdletBinding(DefaultParameterSetName = 'Index')]
    Param (
        [Parameter( Mandatory = $true )]
        [ValidateSet( "cpu", "cpuCore", "disk", "fan", "memory", "powerSupply", "systemBoard" )]
        [string]$ComponentType,

        [Parameter( Mandatory = $true )]
        [ValidateSet(   "capacity", "counters", "idle", "latency", "power", "queueLatency",
                        "rate", "readiness", "ready", "speed", "swap", "swapRate", "temperature",
                        "totalLatency", "utilization"
        )]
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
        [ValidateNotNullOrEmpty()]
        [string]$FilterComponentId,

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

        $ResourceUri = "/stat/component/$ComponentType/$StatId"

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -eq 'Index') {
            if ($Tenants)               { $UriParameters['tenants']                 = $Tenants }
            if ($FilterFromTime)        { $UriParameters['filter[fromTime]']        = $FilterFromTime }
            if ($FilterThruTime)        { $UriParameters['filter[thruTime]']        = $FilterThruTime }
            if ($FilterInterval)        { $UriParameters['filter[interval]']        = $FilterInterval }
            if ($FilterComponentId)     { $UriParameters['filter[componentId]']     = $FilterComponentId }
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
