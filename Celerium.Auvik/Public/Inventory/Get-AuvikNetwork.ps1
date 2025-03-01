function Get-AuvikNetwork {
<#
    .SYNOPSIS
        Get Auvik networks and other related information

    .DESCRIPTION
        The Get-AuvikNetwork cmdlet allows you to view an inventory of
        networks and other related information discovered by Auvik.

        Use the [ -NetworkDetails & -NetworkInfo  ] parameters when wanting to target
        specific information. See Get-Help Get-AuvikNetwork -Full for
        more information on associated parameters

    .PARAMETER ID
        ID of network

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from

    .PARAMETER FilterNetworkType
        Filter by network type

        Allowed values:
            "routed", "vlan", "wifi", "loopback", "network", "layer2", "internet"

    .PARAMETER FilterScanStatus
        Filter by the network's scan status

        Allowed values:
            "true", "false", "notAllowed", "unknown"

    .PARAMETER FilterDevices
        Filter by IDs of devices on this network

        Filter by multiple values by providing a comma delimited list

    .PARAMETER FilterModifiedAfter
        Filter by date and time, only returning entities modified after provided value

    .PARAMETER FilterScope
        Filter by the network's scope

        Allowed values:
            "private", "public"

    .PARAMETER Include
        Use to Include the full resource objects of the list device relationships

        Example: Include=deviceDetail

    .PARAMETER FieldsNetworkDetail
        Use to limit the attributes that will be returned in the Included detail
        object to only what is specified by this query parameter.

        Allowed values:
            "scope", "primaryCollector", "secondaryCollectors", "collectorSelection", "excludedIpAddresses"

        Requires Include=networkDetail

    .PARAMETER NetworkDetails
        Target the network details endpoint

        /Inventory/network/info & /Inventory/network/info/{id}

    .PARAMETER NetworkInfo
        Target the network info endpoint

        /Inventory/network/detail & /Inventory/network/detail/{id}

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
        Get-AuvikNetwork

        Gets general information about the first 100 networks
        Auvik has discovered

    .EXAMPLE
        Get-AuvikNetwork -ID 123456789 -NetworkInfo

        Gets general information for the defined network
        Auvik has discovered

    .EXAMPLE
        Get-AuvikNetwork -NetworkDetails

        Gets detailed information about the first 100 networks
        Auvik has discovered

    .EXAMPLE
        Get-AuvikNetwork -ID 123456789 -NetworkDetails

        Gets network details information for the defined network
        Auvik has discovered

    .EXAMPLE
        Get-AuvikNetwork -PageFirst 1000 -AllResults

        Gets network info information for all networks found by Auvik

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikNetwork.html
#>

    [CmdletBinding(DefaultParameterSetName = 'IndexByMultiNetworkInfo' )]
    Param (
        [Parameter( Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'IndexBySingleNetworkInfo' )]
        [Parameter( Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'IndexBySingleNetworkDetail' )]
        [ValidateNotNullOrEmpty()]
        [string]$ID,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkDetail' )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkDetail' )]
        [ValidateSet( "routed", "vlan", "wifi", "loopback", "network", "layer2", "internet" )]
        [string]$FilterNetworkType,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkDetail' )]
        [ValidateSet( "true", "false", "notAllowed", "unknown" )]
        [string]$FilterScanStatus,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkDetail' )]
        [ValidateNotNullOrEmpty()]
        [string[]]$FilterDevices,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkDetail' )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterModifiedAfter,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkDetail' )]
        [ValidateSet( "private", "public" )]
        [string]$FilterScope,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexBySingleNetworkInfo' )]
        [ValidateNotNullOrEmpty()]
        [string]$Include,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexBySingleNetworkInfo' )]
        [ValidateSet( "scope", "primaryCollector", "secondaryCollectors", "collectorSelection", "excludedIpAddresses" )]
        [string[]]$FieldsNetworkDetail,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexBySingleNetworkDetail' )]
        [switch]$NetworkDetails,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexBySingleNetworkInfo' )]
        [switch]$NetworkInfo,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkDetail' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkDetail' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkDetail' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkDetail' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkDetail' )]
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
            'IndexByMultiNetworkInfo'       { $ResourceUri = "/inventory/network/info" }
            'IndexBySingleNetworkInfo'      { $ResourceUri = "/inventory/network/info/$ID" }

            'IndexByMultiNetworkDetail'     { $ResourceUri = "/inventory/network/detail" }
            'IndexBySingleNetworkDetail'    { $ResourceUri = "/inventory/network/detail/$ID" }
        }

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -eq 'IndexByMultiNetworkInfo' -or $PSCmdlet.ParameterSetName -eq 'IndexBySingleNetworkInfo') {
            if ($FieldsNetworkDetail)   { $UriParameters['fields[networkDetail]']   = $FieldsNetworkDetail }
            if ($Include)               { $UriParameters['include']                 = $Include }
        }

        if ($PSCmdlet.ParameterSetName -eq 'IndexByMultiNetworkInfo') {
            if ($FilterScope)            { $UriParameters['filter[scope]']          = $FilterScope }
        }

        if ($PSCmdlet.ParameterSetName -eq 'IndexByMultiNetworkInfo' -or $PSCmdlet.ParameterSetName -eq 'IndexByMultiNetworkDetail') {
            if ($Tenants)               { $UriParameters['tenants']                 = $Tenants }
            if ($FilterNetworkType)     { $UriParameters['filter[networkType]']     = $FilterNetworkType }
            if ($FilterScanStatus)      { $UriParameters['filter[scanStatus]']      = $FilterScanStatus }
            if ($FilterDevices)         { $UriParameters['filter[devices]']         = $FilterDevices }
            if ($FilterModifiedAfter)   { $UriParameters['filter[modifiedAfter]']   = $FilterModifiedAfter }
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
