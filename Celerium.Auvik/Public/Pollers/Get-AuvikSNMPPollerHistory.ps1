function Get-AuvikSNMPPollerHistory {
<#
    .SYNOPSIS
        Get Auvik historical values of SNMP Poller settings

    .DESCRIPTION
        The Get-AuvikSNMPPolllerHistory cmdlet allows you to view
        historical values of SNMP Poller settings

        There are two endpoints available in the SNMP Poller History API

        Read String SNMP Poller Setting History:
            Provides historical values of String SNMP Poller Settings
        Read Numeric SNMP Poller Setting History:
            Provides historical values of Numeric SNMP Poller Settings

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from

    .PARAMETER FilterFromTime
        Timestamp from which you want to query

    .PARAMETER FilterThruTime
        Timestamp to which you want to query (defaults to current time)

    .PARAMETER FilterCompact
        Whether to show compact view of the results or not

        Compact view only shows changes in value
        If compact view is false, dateTime range can be a maximum of 24h

    .PARAMETER FilterInterval
        Statistics reporting interval

        Allowed values:
            "minute", "hour", "day"

    .PARAMETER FilterDeviceId
        Filter by device ID

    .PARAMETER FilterSNMPPollerSettingId
        Comma delimited list of SNMP poller setting IDs to request info from

        Note this is internal SNMPPollerSettingId
        The user can get the list of IDs for a specific poller using the
        GET /settings/snmppoller endpoint

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
        Get-AuvikSNMPPolllerHistory -FilterFromTime 2023-10-01 -Tenants 123456789

        Gets general information about the first 100 historical SNMP
        string poller settings

    .EXAMPLE
        Get-AuvikSNMPPolllerHistory -FilterFromTime 2023-10-01 -Tenants 123456789 -FilterInterval day

        Gets general information about the first 100 historical SNMP
        numerical poller settings

    .EXAMPLE
        Get-AuvikSNMPPolllerHistory -FilterFromTime 2023-10-01 -Tenants 123456789 -PageFirst 1000 -AllResults

        Gets general information about all historical SNMP
        string poller settings

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Pollers/Get-AuvikSNMPPolllerHistory.html
#>

    [CmdletBinding(DefaultParameterSetName = 'IndexByStringSNMP' )]
    Param (
        [Parameter( Mandatory = $true, ParameterSetName = 'IndexByStringSNMP' )]
        [Parameter( Mandatory = $true, ParameterSetName = 'IndexByNumericSNMP' )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter( Mandatory = $true, ParameterSetName = 'IndexByStringSNMP' )]
        [Parameter( Mandatory = $true, ParameterSetName = 'IndexByNumericSNMP' )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterFromTime,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByStringSNMP' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByNumericSNMP' )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterThruTime,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByStringSNMP' )]
        [switch]$FilterCompact,

        [Parameter( Mandatory = $true, ParameterSetName = 'IndexByNumericSNMP' )]
        [ValidateSet( "minute", "hour", "day")]
        [string]$FilterInterval,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByStringSNMP' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByNumericSNMP' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterDeviceId,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByStringSNMP' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByNumericSNMP' )]
        [ValidateNotNullOrEmpty()]
        [string[]]$FilterSNMPPollerSettingId,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByStringSNMP' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByNumericSNMP' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByStringSNMP' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByNumericSNMP' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByStringSNMP' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByNumericSNMP' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByStringSNMP' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByNumericSNMP' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByStringSNMP' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByNumericSNMP' )]
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
            'IndexByStringSNMP'     { $ResourceUri = "/stat/snmppoller/string" }
            'IndexByNumericSNMP'    { $ResourceUri = "/stat/snmppoller/int" }
        }

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -eq 'IndexByStringSNMP') {
            if ($FilterCompact)             { $UriParameters['filter[compact]']              = $FilterCompact }
        }

        if ($PSCmdlet.ParameterSetName -eq 'IndexByNumericSNMP') {
            if ($FilterInterval)            { $UriParameters['filter[interval]']            = $FilterInterval }
        }

        if ($PSCmdlet.ParameterSetName -like 'Index*') {
            if ($tenants)                   { $UriParameters['filter[tenants]']             = $Tenants }
            if ($FilterFromTime)            { $UriParameters['filter[fromTime]']            = $FilterFromTime }
            if ($FilterThruTime)            { $UriParameters['filter[thruTime]']            = $FilterThruTime }
            if ($FilterDeviceId)            { $UriParameters['filter[deviceId]']            = $FilterDeviceId }
            if ($FilterSNMPPollerSettingId) { $UriParameters['filter[snmpPollerSettingId]'] = $FilterSNMPPollerSettingId }
            if ($PageFirst)                 { $UriParameters['page[first]']                 = $PageFirst }
            if ($PageAfter)                 { $UriParameters['page[after]']                 = $PageAfter }
            if ($PageLast)                  { $UriParameters['page[last]']                  = $PageLast }
            if ($PageBefore)                { $UriParameters['page[before]']                = $PageBefore }
        }

        #EndRegion     [ Parameter Translation ]

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

        return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

    }

    end {}

}
