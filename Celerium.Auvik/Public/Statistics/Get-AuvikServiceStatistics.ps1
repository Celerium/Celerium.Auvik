function Get-AuvikServiceStatistics {
<#
    .SYNOPSIS
        Provides historical cloud ping check statistics

    .DESCRIPTION
        The Get-AuvikServiceStatistics cmdlet provides historical
        cloud ping check statistics

    .PARAMETER statId
        ID of statistic to return

        Allowed values:
            "pingTime", "pingPacket"

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

    .PARAMETER FilterServiceId
        Filter by service ID

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
        Get-AuvikServiceStatistics -StatId pingTime -FilterFromTime 2023-10-03 -FilterInterval day

        Provides the first 100 historical cloud ping check statistics

    .EXAMPLE
        Get-AuvikServiceStatistics -StatId pingTime -FilterFromTime 2023-10-03 -FilterInterval day -PageFirst 1000 -AllResults

        Provides all historical cloud ping check statistics

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Statistics/Get-AuvikServiceStatistics.html
#>

    [CmdletBinding(DefaultParameterSetName = 'Index' )]
    Param (
        [Parameter( Mandatory = $true )]
        [ValidateSet( "pingTime", "pingPacket" )]
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
        [string]$FilterServiceId,

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

        $ResourceUri = "/stat/service/$StatId"

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -eq 'Index') {
            if ($Tenants)           { $UriParameters['tenants']             = $Tenants }
            if ($FilterFromTime)    { $UriParameters['filter[fromTime]']    = $FilterFromTime }
            if ($FilterThruTime)    { $UriParameters['filter[thruTime]']    = $FilterThruTime }
            if ($FilterInterval)    { $UriParameters['filter[interval]']    = $FilterInterval }
            if ($FilterServiceId)   { $UriParameters['filter[serviceId]']   = $FilterServiceId }
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
