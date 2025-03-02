function Get-AuvikAlert {
<#
    .SYNOPSIS
        Get Auvik alert events that have been triggered by your Auvik collector(s)

    .DESCRIPTION
        The Get-AuvikAlert cmdlet allows you to view the alert events
        that has been triggered by your Auvik collector(s)

    .PARAMETER ID
        ID of alert

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from

    .PARAMETER FilterAlertDefinitionId
        Filter by alert definition ID

    .PARAMETER FilterSeverity
        Filter by alert severity

        Allowed values:
            "unknown", "emergency", "critical", "warning", "info"

    .PARAMETER FilterStatus
        Filter by the status of the alert

        Allowed values:
            "created", "resolved", "paused", "unpaused"

    .PARAMETER FilterEntityId
        Filter by the related entity ID

    .PARAMETER FilterDismissed
        Filter by the dismissed status

        As of 2023-10 this parameter does not appear to work

    .PARAMETER FilterDispatched
        Filter by dispatched status

        As of 2023-10 this parameter does not appear to work

    .PARAMETER FilterDetectedTimeAfter
        Filter by the time which is greater than the given timestamp

    .PARAMETER FilterDetectedTimeBefore
        Filter by the time which is less than or equal to the given timestamp

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
        Get-AuvikAlert

        Gets general information about the first 100 alerts
        Auvik has discovered

    .EXAMPLE
        Get-AuvikAlert -ID 123456789

        Gets general information for the defined alert
        Auvik has discovered

    .EXAMPLE
        Get-AuvikAlert -PageFirst 1000 -AllResults

        Gets general information for all alerts found by Auvik

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Alert/Get-AuvikAlert.html
#>

    [CmdletBinding(DefaultParameterSetName = 'IndexByMultiAlert' )]
    Param (
        [Parameter( Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'IndexBySingleAlert' )]
        [ValidateNotNullOrEmpty()]
        [string]$ID,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiAlert' )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiAlert' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterAlertDefinitionId,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiAlert' )]
        [ValidateSet( "unknown", "emergency", "critical", "warning", "info" )]
        [string]$FilterSeverity,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiAlert' )]
        [ValidateSet( "created", "resolved", "paused", "unpaused" )]
        [string]$FilterStatus,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiAlert' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterEntityId,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiAlert' )]
        [switch]$FilterDismissed,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiAlert' )]
        [switch]$FilterDispatched,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiAlert' )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterDetectedTimeAfter,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiAlert' )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterDetectedTimeBefore,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiAlert' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiAlert' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiAlert' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiAlert' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiAlert' )]
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
            'IndexByMultiAlert'  { $ResourceUri = "/alert/history/info" }
            'IndexBySingleAlert' { $ResourceUri = "/alert/history/info/$ID" }
        }

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -eq 'IndexByMultiAlert') {
            if ($Tenants)                   { $UriParameters['tenants']                     = $Tenants }
            if ($FilterAlertDefinitionId)   { $UriParameters['filter[alertDefinitionId]']   = $FilterAlertDefinitionId }
            if ($FilterSeverity)            { $UriParameters['filter[severity]']            = $FilterSeverity }
            if ($FilterStatus)              { $UriParameters['filter[status]']              = $FilterStatus }
            if ($FilterEntityId)            { $UriParameters['filter[entityId]']            = $FilterEntityId }
            if ($FilterDismissed)           { $UriParameters['filter[dismissed]']           = $FilterDismissed }
            if ($FilterDispatched)          { $UriParameters['filter[dispatched]']          = $FilterDispatched }
            if ($FilterDetectedTimeAfter)   { $UriParameters['filter[detectedTimeAfter]']   = $FilterDetectedTimeAfter }
            if ($FilterDetectedTimeBefore)  { $UriParameters['filter[detectedTimeBefore]']  = $FilterDetectedTimeBefore }
            if ($PageFirst)                 { $UriParameters['page[first]']                 = $PageFirst }
            if ($PageAfter)                 { $UriParameters['page[after]']                 = $PageAfter }
            if ($PageLast)                  { $UriParameters['page[last]']                  = $PageLast }
            if ($PageBefore)                { $UriParameters['page[before]']                = $PageBefore }
        }

        #EndRegion  [ Parameter Translation ]

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

        return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

    }

    end {}

}
