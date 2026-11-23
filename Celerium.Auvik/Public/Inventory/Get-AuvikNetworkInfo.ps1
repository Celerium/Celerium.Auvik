function Get-AuvikNetworkInfo {
<#
    .SYNOPSIS
        Read Multiple Networks' Info / Read a Single Network's Info

    .DESCRIPTION
        Parameter set [ List ] - The Get-AuvikNetworkInfo cmdlet invokes the GET method of the /inventory/network/info endpoint (Read Multiple Networks' Info)

        Use the Read Multiple Networks' Info API to pull the collected information about the various networks Auvik has discovered. You'll need the client IDs for the clients you want to run the multiple read against.

        Parameter set [ ById ] - The Get-AuvikNetworkInfo cmdlet invokes the GET method of the /inventory/network/info/{id} endpoint (Read a Single Network's Info)

        Use the Read Single Network's Info API to pull the collected information about a specific network Auvik has discovered. You'll need the network ID for the specific network.

    .PARAMETER Id
        ID of network

    .PARAMETER Include
        Use to include the full resource objects of any of the network's relationships.

        Allowed values:
        'networkDetail'

    .PARAMETER FieldsNetworkDetail
        Use to limit the attributes that will be returned in the included detail object to only what is specified by this query parameter. Requires include=networkDetail

        Allowed values:
        'scope', 'primaryCollector', 'secondaryCollectors', 'collectorSelection', 'excludedIpAddresses'

    .PARAMETER FilterNetworkType
        Filter by network type.

        Allowed values:
        'routed', 'vlan', 'wifi', 'loopback', 'network', 'layer2', 'internet'

    .PARAMETER FilterScanStatus
        Filter by the network's scan status.

        Allowed values:
        'true', 'false', 'notAllowed', 'unknown'

    .PARAMETER FilterDevices
        Filter by IDs of devices on this network. Filter by multiple values by providing a comma delimited list.

        Accepts multiple values which are sent to the API as a comma delimited list

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
        Get-AuvikNetworkInfo

        Returns the result of the /inventory/network/info endpoint

    .EXAMPLE
        Get-AuvikNetworkInfo -Tenants '1234567890' -PageFirst 10

        Returns the result of the /inventory/network/info endpoint limited to the defined tenant

    .EXAMPLE
        Get-AuvikNetworkInfo -AllResults

        Returns every item from the /inventory/network/info endpoint by following the pagination links

    .EXAMPLE
        Get-AuvikNetworkInfo -Id '1234567890'

        Returns the result of the /inventory/network/info/{id} endpoint

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /inventory/network/info
        Endpoint : GET /inventory/network/info/{id}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikNetworkInfo.html
#>

    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById')]
        [ValidateNotNullOrEmpty()]
        [string]$Id,

        [Parameter(Mandatory = $false, ParameterSetName = 'ById')]
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('networkDetail')]
        [string]$Include,

        [Parameter(Mandatory = $false, ParameterSetName = 'ById')]
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('scope', 'primaryCollector', 'secondaryCollectors', 'collectorSelection', 'excludedIpAddresses')]
        [string]$FieldsNetworkDetail,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('routed', 'vlan', 'wifi', 'loopback', 'network', 'layer2', 'internet')]
        [string]$FilterNetworkType,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('true', 'false', 'notAllowed', 'unknown')]
        [string]$FilterScanStatus,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string[]]$FilterDevices,

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
                $ResourceUri = "/inventory/network/info/$([System.Uri]::EscapeDataString($Id))"
                $NameMap = @{
                    Include             = 'include'
                    FieldsNetworkDetail = 'fields[networkDetail]'
                }
            }
            'List' {
                $ResourceUri = '/inventory/network/info'
                $NameMap = @{
                    FilterNetworkType   = 'filter[networkType]'
                    FilterScanStatus    = 'filter[scanStatus]'
                    FilterDevices       = 'filter[devices]'
                    FilterModifiedAfter = 'filter[modifiedAfter]'
                    Tenants             = 'tenants'
                    PageFirst           = 'page[first]'
                    PageAfter           = 'page[after]'
                    PageLast            = 'page[last]'
                    PageBefore          = 'page[before]'
                    Include             = 'include'
                    FieldsNetworkDetail = 'fields[networkDetail]'
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

Set-Alias -Name 'Get-AuvikNetwork' -Value 'Get-AuvikNetworkInfo'
