function Get-AuvikDeviceLifecycle {
<#
    .SYNOPSIS
        Read Multiple Devices' Lifecycle Info / Read a Single Device's Lifecycle Info

    .DESCRIPTION
        Parameter set [ List ] - The Get-AuvikDeviceLifecycle cmdlet invokes the GET method of the /inventory/device/lifecycle endpoint (Read Multiple Devices' Lifecycle Info)

        Use the Read Multiple Devices' Lifecycle API to pull the collected lifecycle information about the various devices Auvik has discovered. You'll need the client IDs for the clients you want to run the multiple read against.

        Parameter set [ ById ] - The Get-AuvikDeviceLifecycle cmdlet invokes the GET method of the /inventory/device/lifecycle/{id} endpoint (Read a Single Device's Lifecycle Info)

        Use the Read Single Device's Lifecycle Info API to pull the collected information about a specific device Auvik has discovered. You'll need the device ID for the specific device.

    .PARAMETER Id
        ID of device

    .PARAMETER FilterSalesAvailability
        Filter by sales availability.

        Allowed values:
        'covered', 'available', 'expired', 'securityOnly', 'unpublished', 'empty'

    .PARAMETER FilterSoftwareMaintenanceStatus
        Filter by software maintenance status.

        Allowed values:
        'covered', 'available', 'expired', 'securityOnly', 'unpublished', 'empty'

    .PARAMETER FilterSecuritySoftwareMaintenanceStatus
        Filter by security software maintenance status.

        Allowed values:
        'covered', 'available', 'expired', 'securityOnly', 'unpublished', 'empty'

    .PARAMETER FilterLastSupportStatus
        Filter by last support status.

        Allowed values:
        'covered', 'available', 'expired', 'securityOnly', 'unpublished', 'empty'

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
        Get-AuvikDeviceLifecycle

        Returns the result of the /inventory/device/lifecycle endpoint

    .EXAMPLE
        Get-AuvikDeviceLifecycle -Tenants '1234567890' -PageFirst 10

        Returns the result of the /inventory/device/lifecycle endpoint limited to the defined tenant

    .EXAMPLE
        Get-AuvikDeviceLifecycle -AllResults

        Returns every item from the /inventory/device/lifecycle endpoint by following the pagination links

    .EXAMPLE
        Get-AuvikDeviceLifecycle -Id '1234567890'

        Returns the result of the /inventory/device/lifecycle/{id} endpoint

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /inventory/device/lifecycle
        Endpoint : GET /inventory/device/lifecycle/{id}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikDeviceLifecycle.html
#>

    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById')]
        [ValidateNotNullOrEmpty()]
        [string]$Id,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('covered', 'available', 'expired', 'securityOnly', 'unpublished', 'empty')]
        [string]$FilterSalesAvailability,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('covered', 'available', 'expired', 'securityOnly', 'unpublished', 'empty')]
        [string]$FilterSoftwareMaintenanceStatus,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('covered', 'available', 'expired', 'securityOnly', 'unpublished', 'empty')]
        [string]$FilterSecuritySoftwareMaintenanceStatus,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('covered', 'available', 'expired', 'securityOnly', 'unpublished', 'empty')]
        [string]$FilterLastSupportStatus,

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
                $ResourceUri = "/inventory/device/lifecycle/$([System.Uri]::EscapeDataString($Id))"
                $NameMap = @{}
            }
            'List' {
                $ResourceUri = '/inventory/device/lifecycle'
                $NameMap = @{
                    FilterSalesAvailability                 = 'filter[salesAvailability]'
                    FilterSoftwareMaintenanceStatus         = 'filter[softwareMaintenanceStatus]'
                    FilterSecuritySoftwareMaintenanceStatus = 'filter[securitySoftwareMaintenanceStatus]'
                    FilterLastSupportStatus                 = 'filter[lastSupportStatus]'
                    Tenants                                 = 'tenants'
                    PageFirst                               = 'page[first]'
                    PageAfter                               = 'page[after]'
                    PageLast                                = 'page[last]'
                    PageBefore                              = 'page[before]'
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
