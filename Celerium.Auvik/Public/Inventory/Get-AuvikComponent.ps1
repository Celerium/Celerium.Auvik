function Get-AuvikComponent {
<#
    .SYNOPSIS
        Get Auvik components and other related information

    .DESCRIPTION
        The Get-AuvikComponent cmdlet allows you to view an inventory of
        components and other related information discovered by Auvik

    .PARAMETER ID
        ID of component

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from

    .PARAMETER FilterModifiedAfter
        Filter by date and time, only returning entities modified after provided value

    .PARAMETER FilterDeviceId
        Filter by the component's parent device's ID

    .PARAMETER FilterDeviceName
        Filter by the component's parent device's name

    .PARAMETER FilterCurrentStatus
        Filter by the component's current status

        Allowed values:
            "ok", "degraded", "failed"

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
        Get-AuvikComponent

        Gets general information about the first 100 components
        Auvik has discovered

    .EXAMPLE
        Get-AuvikComponent -ID 123456789

        Gets general information for the defined component
        Auvik has discovered

    .EXAMPLE
        Get-AuvikComponent -PageFirst 1000 -AllResults

        Gets general information for all components found by Auvik

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikComponent.html
#>

    [CmdletBinding(DefaultParameterSetName = 'IndexByMultiComponent' )]
    Param (
        [Parameter( Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'IndexBySingleComponent' )]
        [ValidateNotNullOrEmpty()]
        [string]$ID,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiComponent' )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiComponent' )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterModifiedAfter,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiComponent' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterDeviceId,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiComponent' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterDeviceName,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiComponent' )]
        [ValidateSet( "ok", "degraded", "failed" )]
        [string]$FilterCurrentStatus,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiComponent' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiComponent' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiComponent' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiComponent' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiComponent' )]
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
            'IndexByMultiComponent'  { $ResourceUri = "/inventory/component/info" }
            'IndexBySingleComponent' { $ResourceUri = "/inventory/component/info/$ID" }
        }

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -eq 'IndexByMultiComponent') {
            if ($Tenants)               { $UriParameters['filter[tenantId]']        = $Tenants }
            if ($FilterModifiedAfter)   { $UriParameters['filter[modifiedAfter]']   = $FilterModifiedAfter }
            if ($FilterDeviceId)        { $UriParameters['filter[deviceId]']        = $FilterDeviceId }
            if ($FilterDeviceName)      { $UriParameters['filter[deviceName]']      = $FilterDeviceName }
            if ($FilterCurrentStatus)   { $UriParameters['filter[currentStatus]']   = $FilterCurrentStatus }
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
