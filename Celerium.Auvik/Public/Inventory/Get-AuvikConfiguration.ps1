function Get-AuvikConfiguration {
<#
    .SYNOPSIS
        Get Auvik history of device configurations

    .DESCRIPTION
        The Get-AuvikConfiguration cmdlet allows you to view a history of
        device configurations and other related information discovered by Auvik

    .PARAMETER ID
        ID of entity note\audit

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from

    .PARAMETER FilterDeviceId
        Filter by device ID

    .PARAMETER FilterBackupTimeAfter
        Filter by date and time, filtering out configurations backed up before value

    .PARAMETER FilterBackupTimeBefore
        Filter by date and time, filtering out configurations backed up after value

    .PARAMETER FilterIsRunning
        Filter for configurations that are currently running, or filter
        for all configurations which are not currently running

        As of 2023-10, this does not appear to function correctly on this endpoint

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
        Get-AuvikConfiguration

        Gets general information about the first 100 configurations
        Auvik has discovered

    .EXAMPLE
        Get-AuvikConfiguration -ID 123456789

        Gets general information for the defined configuration
        Auvik has discovered

    .EXAMPLE
        Get-AuvikConfiguration -PageFirst 1000 -AllResults

        Gets general information for all configurations found by Auvik

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikConfiguration.html
#>

    [CmdletBinding(DefaultParameterSetName = 'IndexByMultiConfig' )]
    Param (
        [Parameter( Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'IndexBySingleConfig' )]
        [ValidateNotNullOrEmpty()]
        [string]$ID,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiConfig' )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiConfig' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterDeviceId,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiConfig' )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterBackupTimeAfter,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiConfig' )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterBackupTimeBefore,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiConfig' )]
        [switch]$FilterIsRunning,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiConfig' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiConfig' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiConfig' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiConfig' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiConfig' )]
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
            'IndexByMultiConfig'    { $ResourceUri = "/inventory/configuration" }
            'IndexBySingleConfig'   { $ResourceUri = "/inventory/configuration/$ID" }
        }

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -eq 'IndexByMultiConfig') {
            if ($Tenants)                   { $UriParameters['filter[tenant]']              = $Tenants }
            if ($FilterDeviceId)            { $UriParameters['filter[deviceId]']            = $FilterDeviceId }
            if ($FilterBackupTimeAfter)     { $UriParameters['filter[backupTimeAfter]']     = $FilterBackupTimeAfter }
            if ($FilterBackupTimeBefore)    { $UriParameters['filter[backupTimeBefore]']    = $FilterBackupTimeBefore }
            if ($FilterIsRunning)           { $UriParameters['filter[isRunning]']           = $FilterIsRunning }
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
