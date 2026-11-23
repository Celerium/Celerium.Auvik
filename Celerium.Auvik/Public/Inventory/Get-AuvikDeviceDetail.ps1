function Get-AuvikDeviceDetail {
<#
    .SYNOPSIS
        Read Multiple Devices' Details / Read a Single Device's Details

    .DESCRIPTION
        Parameter set [ List ] - The Get-AuvikDeviceDetail cmdlet invokes the GET method of the /inventory/device/detail endpoint (Read Multiple Devices' Details)

        Use the Read Multiple Devices' Details API to pull extra collected information about the various devices Auvik has discovered not already included in the Device Info API. You'll need the client IDs for the clients you want to run the multiple read against.

        Parameter set [ ById ] - The Get-AuvikDeviceDetail cmdlet invokes the GET method of the /inventory/device/detail/{id} endpoint (Read a Single Device's Details)

        Use the Read Single Device's Details API to pull extra collected information about a specific device Auvik has discovered not already included in the Device Info API. You'll need the device ID for the specific device.

    .PARAMETER Id
        ID of device

    .PARAMETER FilterManageStatus
        Filter by managed status

    .PARAMETER FilterDiscoverySNMP
        Filter by the device's SNMP discovery status.

        Allowed values:
        'disabled', 'determining', 'notSupported', 'notAuthorized', 'authorizing', 'authorized', 'privileged'

    .PARAMETER FilterDiscoveryWMI
        Filter by the device's WMI discovery status.

        Allowed values:
        'disabled', 'determining', 'notSupported', 'notAuthorized', 'authorizing', 'authorized', 'privileged'

    .PARAMETER FilterDiscoveryLogin
        Filter by the device's Login discovery status.

        Allowed values:
        'disabled', 'determining', 'notSupported', 'notAuthorized', 'authorizing', 'authorized', 'privileged'

    .PARAMETER FilterDiscoveryVMware
        Filter by the device's VMware discovery status.

        Allowed values:
        'disabled', 'determining', 'notSupported', 'notAuthorized', 'authorizing', 'authorized', 'privileged'

    .PARAMETER FilterTrafficInsightsStatus
        Filter by the device's TrafficInsights status.

        Allowed values:
        'notDetected', 'detected', 'notApproved', 'approved', 'linking', 'linkingFailed', 'forwarding'

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
        Get-AuvikDeviceDetail

        Returns the result of the /inventory/device/detail endpoint

    .EXAMPLE
        Get-AuvikDeviceDetail -Tenants '1234567890' -PageFirst 10

        Returns the result of the /inventory/device/detail endpoint limited to the defined tenant

    .EXAMPLE
        Get-AuvikDeviceDetail -AllResults

        Returns every item from the /inventory/device/detail endpoint by following the pagination links

    .EXAMPLE
        Get-AuvikDeviceDetail -Id '1234567890'

        Returns the result of the /inventory/device/detail/{id} endpoint

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /inventory/device/detail
        Endpoint : GET /inventory/device/detail/{id}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikDeviceDetail.html
#>

    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById')]
        [ValidateNotNullOrEmpty()]
        [string]$Id,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [bool]$FilterManageStatus,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('disabled', 'determining', 'notSupported', 'notAuthorized', 'authorizing', 'authorized', 'privileged')]
        [string]$FilterDiscoverySNMP,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('disabled', 'determining', 'notSupported', 'notAuthorized', 'authorizing', 'authorized', 'privileged')]
        [string]$FilterDiscoveryWMI,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('disabled', 'determining', 'notSupported', 'notAuthorized', 'authorizing', 'authorized', 'privileged')]
        [string]$FilterDiscoveryLogin,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('disabled', 'determining', 'notSupported', 'notAuthorized', 'authorizing', 'authorized', 'privileged')]
        [string]$FilterDiscoveryVMware,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('notDetected', 'detected', 'notApproved', 'approved', 'linking', 'linkingFailed', 'forwarding')]
        [string]$FilterTrafficInsightsStatus,

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
                $ResourceUri = "/inventory/device/detail/$([System.Uri]::EscapeDataString($Id))"
                $NameMap = @{}
            }
            'List' {
                $ResourceUri = '/inventory/device/detail'
                $NameMap = @{
                    FilterManageStatus          = 'filter[manageStatus]'
                    FilterDiscoverySNMP         = 'filter[discoverySNMP]'
                    FilterDiscoveryWMI          = 'filter[discoveryWMI]'
                    FilterDiscoveryLogin        = 'filter[discoveryLogin]'
                    FilterDiscoveryVMware       = 'filter[discoveryVMware]'
                    FilterTrafficInsightsStatus = 'filter[trafficInsightsStatus]'
                    Tenants                     = 'tenants'
                    PageFirst                   = 'page[first]'
                    PageAfter                   = 'page[after]'
                    PageLast                    = 'page[last]'
                    PageBefore                  = 'page[before]'
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
