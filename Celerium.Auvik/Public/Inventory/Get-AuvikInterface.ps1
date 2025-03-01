function Get-AuvikInterface {
<#
    .SYNOPSIS
        Get Auvik interfaces and other related information

    .DESCRIPTION
        The Get-AuvikInterface cmdlet allows you to view an inventory of
        interfaces and other related information discovered by Auvik.

    .PARAMETER ID
        ID of interface

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from

    .PARAMETER FilterInterfaceType
        Filter by interface type

        Allowed values:
            "ethernet", "wifi", "bluetooth", "cdma", "coax", "cpu", "distributedVirtualSwitch",
            "firewire", "gsm", "ieee8023AdLag", "inferredWired", "inferredWireless", "interface",
            "linkAggregation", "loopback", "modem", "wimax", "optical", "other", "parallel", "ppp",
            "radiomac", "rs232", "tunnel", "unknown", "usb", "virtualBridge", "virtualNic",
            "virtualSwitch", "vlan"

    .PARAMETER FilterParentDevice
        Filter by the entity's parent device ID

    .PARAMETER FilterAdminStatus
        Filter by the interface's admin status

    .PARAMETER FilterOperationalStatus
        Filter by the interface's operational status

        Allowed values:
            "online", "offline", "unreachable", "testing", "unknown", "dormant", "notPresent", "lowerLayerDown"

    .PARAMETER FilterModifiedAfter
        Filter by date and time, only returning entities modified after provided value

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
        Get-AuvikInterface

        Gets general information about the first 100 interfaces
        Auvik has discovered

    .EXAMPLE
        Get-AuvikInterface -ID 123456789

        Gets general information for the defined interface
        Auvik has discovered

    .EXAMPLE
        Get-AuvikInterface -PageFirst 1000 -AllResults

        Gets general information for all interfaces found by Auvik.

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikInterface.html
#>

    [CmdletBinding(DefaultParameterSetName = 'IndexByMultiInterface' )]
    Param (
        [Parameter( Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'IndexBySingleInterface' )]
        [ValidateNotNullOrEmpty()]
        [string]$ID,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiInterface' )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiInterface' )]
        [ValidateSet(   "ethernet", "wifi", "bluetooth", "cdma", "coax", "cpu", "distributedVirtualSwitch",
                        "firewire", "gsm", "ieee8023AdLag", "inferredWired", "inferredWireless", "interface",
                        "linkAggregation", "loopback", "modem", "wimax", "optical", "other", "parallel", "ppp",
                        "radiomac", "rs232", "tunnel", "unknown", "usb", "virtualBridge", "virtualNic",
                        "virtualSwitch", "vlan"
        )]
        [string]$FilterInterfaceType,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiInterface' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterParentDevice,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiInterface' )]
        [switch]$FilterAdminStatus,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiInterface' )]
        [ValidateSet( "online", "offline", "unreachable", "testing", "unknown", "dormant", "notPresent", "lowerLayerDown" )]
        [string]$FilterOperationalStatus,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiInterface' )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterModifiedAfter,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiInterface' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiInterface' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiInterface' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiInterface' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiInterface' )]
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
            'IndexByMultiInterface'  { $ResourceUri = "/inventory/interface/info" }
            'IndexBySingleInterface' { $ResourceUri = "/inventory/interface/info/$ID" }
        }

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -eq 'IndexByMultiInterface') {
            if ($Tenants)                   { $UriParameters['tenantId']                = $Tenants }
            if ($FilterInterfaceType)       { $UriParameters['filterInterfaceType']     = $FilterInterfaceType }
            if ($FilterParentDevice)        { $UriParameters['filterParentDevice']      = $FilterParentDevice }
            if ($FilterAdminStatus)         { $UriParameters['filterAdminStatus']       = $FilterAdminStatus }
            if ($FilterOperationalStatus)   { $UriParameters['filterOperationalStatus'] = $FilterOperationalStatus }
            if ($FilterModifiedAfter)       { $UriParameters['filterModifiedAfter']     = $FilterModifiedAfter }
            if ($PageFirst)                 { $UriParameters['page[first]']             = $PageFirst }
            if ($PageAfter)                 { $UriParameters['page[after]']             = $PageAfter }
            if ($PageLast)                  { $UriParameters['page[last]']              = $PageLast }
            if ($PageBefore)                { $UriParameters['page[before]']            = $PageBefore }
        }

        #EndRegion  [ Parameter Translation ]

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

        return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

    }

    end {}

}
