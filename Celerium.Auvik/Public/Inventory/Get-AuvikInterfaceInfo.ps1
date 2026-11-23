function Get-AuvikInterfaceInfo {
<#
    .SYNOPSIS
        Read Multiple Interfaces Info / Read a Single Interfaces Info

    .DESCRIPTION
        Parameter set [ List ] - The Get-AuvikInterfaceInfo cmdlet invokes the GET method of the /inventory/interface/info endpoint (Read Multiple Interfaces Info)

        Use the Read Multiple Interfaces Info API to pull the collected information about the various device interfaces Auvik has discovered. You'll need the client IDs for the clients you want to run the multiple read against.

        Parameter set [ ById ] - The Get-AuvikInterfaceInfo cmdlet invokes the GET method of the /inventory/interface/info/{id} endpoint (Read a Single Interfaces Info)

        Use the Read Single Interface Info API to pull the collected information about a specific device interface Auvik has discovered. You'll need the interface ID for the specific interface.

    .PARAMETER Id
        ID of interface

    .PARAMETER FilterInterfaceType
        Filter by interface type.

        Allowed values:
        'ethernet', 'wifi', 'bluetooth', 'cdma', 'coax', 'cpu', 'distributedVirtualSwitch', 'firewire', 'gsm', 'ieee8023AdLag', 'inferredWired', 'inferredWireless', 'interface', 'linkAggregation', 'loopback', 'modem', 'wimax', 'optical', 'other', 'parallel', 'ppp', 'radiomac', 'rs232', 'tunnel', 'unknown', 'usb', 'virtualBridge', 'virtualNic', 'virtualSwitch', 'vlan'

    .PARAMETER FilterParentDevice
        Filter by the entity's parent device ID.

    .PARAMETER FilterAdminStatus
        Filter by the interface's admin status.

    .PARAMETER FilterOperationalStatus
        Filter by the interface's operational status.

        Allowed values:
        'online', 'offline', 'unreachable', 'testing', 'unknown', 'dormant', 'notPresent', 'lowerLayerDown'

    .PARAMETER FilterModifiedAfter
        Filter by date and time, only returning entities modified after provided value.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from.

        Accepts multiple values which are sent to the API as a comma delimited list

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned. Used in combination with page[after].

        Default value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page. The page size is provided by page[first].

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned. Used in combination with page[before].

        Default value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page. The page size is provided by page[last].

    .PARAMETER AllResults
        Returns all items from the endpoint by following the pagination links

        When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters

        Highly recommended to only use with filters to reduce API errors & timeouts

    .EXAMPLE
        Get-AuvikInterfaceInfo

        Returns the result of the /inventory/interface/info endpoint

    .EXAMPLE
        Get-AuvikInterfaceInfo -Tenants '1234567890' -PageFirst 10

        Returns the result of the /inventory/interface/info endpoint limited to the defined tenant

    .EXAMPLE
        Get-AuvikInterfaceInfo -AllResults

        Returns every item from the /inventory/interface/info endpoint by following the pagination links

    .EXAMPLE
        Get-AuvikInterfaceInfo -Id '1234567890'

        Returns the result of the /inventory/interface/info/{id} endpoint

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /inventory/interface/info
        Endpoint : GET /inventory/interface/info/{id}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikInterfaceInfo.html
#>

    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById')]
        [ValidateNotNullOrEmpty()]
        [string]$Id,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('ethernet', 'wifi', 'bluetooth', 'cdma', 'coax', 'cpu', 'distributedVirtualSwitch', 'firewire', 'gsm', 'ieee8023AdLag', 'inferredWired', 'inferredWireless', 'interface', 'linkAggregation', 'loopback', 'modem', 'wimax', 'optical', 'other', 'parallel', 'ppp', 'radiomac', 'rs232', 'tunnel', 'unknown', 'usb', 'virtualBridge', 'virtualNic', 'virtualSwitch', 'vlan')]
        [string]$FilterInterfaceType,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterParentDevice,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [bool]$FilterAdminStatus,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('online', 'offline', 'unreachable', 'testing', 'unknown', 'dormant', 'notPresent', 'lowerLayerDown')]
        [string]$FilterOperationalStatus,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [datetime]$FilterModifiedAfter,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        switch ($PSCmdlet.ParameterSetName) {
            'ById' {
                $ResourceUri = "/inventory/interface/info/$([System.Uri]::EscapeDataString($Id))"
                $NameMap = @{}
            }
            'List' {
                $ResourceUri = '/inventory/interface/info'
                $NameMap = @{
                    FilterInterfaceType     = 'filter[interfaceType]'
                    FilterParentDevice      = 'filter[parentDevice]'
                    FilterAdminStatus       = 'filter[adminStatus]'
                    FilterOperationalStatus = 'filter[operationalStatus]'
                    FilterModifiedAfter     = 'filter[modifiedAfter]'
                    Tenants                 = 'tenants'
                    PageFirst               = 'page[first]'
                    PageAfter               = 'page[after]'
                    PageLast                = 'page[last]'
                    PageBefore              = 'page[before]'
                }
            }
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
            AllResults  = $AllResults
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}

Set-Alias -Name 'Get-AuvikInterface' -Value 'Get-AuvikInterfaceInfo'
