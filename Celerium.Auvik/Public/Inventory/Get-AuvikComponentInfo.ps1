function Get-AuvikComponentInfo {
<#
    .SYNOPSIS
        Read Multiple Components' Info / Read a Single Component's Info

    .DESCRIPTION
        Parameter set [ List ] - The Get-AuvikComponentInfo cmdlet invokes the GET method of the /inventory/component/info endpoint (Read Multiple Components' Info)

        Use the Read Multiple Components' Info API to pull collected information about various device components Auvik has discovered. You'll need the client IDs for the clients you want to run the multiple read against.

        Parameter set [ ById ] - The Get-AuvikComponentInfo cmdlet invokes the GET method of the /inventory/component/info/{id} endpoint (Read a Single Component's Info)

        Use the Read Single Component's Info API to pull collected information about a specific device component Auvik has discovered. You'll need the component ID you want audit detail for.

    .PARAMETER Id
        ID of component

    .PARAMETER FilterModifiedAfter
        Filter by date and time, only returning entities modified after provided value.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterDeviceId
        Filter by the component's parent device's ID.

    .PARAMETER FilterDeviceName
        Filter by the component's parent device's name.

    .PARAMETER FilterCurrentStatus
        Filter by the component's current status.

        Allowed values:
        'ok', 'degraded', 'failed'

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
        Get-AuvikComponentInfo

        Returns the result of the /inventory/component/info endpoint

    .EXAMPLE
        Get-AuvikComponentInfo -Tenants '1234567890' -PageFirst 10

        Returns the result of the /inventory/component/info endpoint limited to the defined tenant

    .EXAMPLE
        Get-AuvikComponentInfo -AllResults

        Returns every item from the /inventory/component/info endpoint by following the pagination links

    .EXAMPLE
        Get-AuvikComponentInfo -Id '1234567890'

        Returns the result of the /inventory/component/info/{id} endpoint

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /inventory/component/info
        Endpoint : GET /inventory/component/info/{id}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikComponentInfo.html
#>

    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById')]
        [ValidateNotNullOrEmpty()]
        [string]$Id,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [datetime]$FilterModifiedAfter,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterDeviceId,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterDeviceName,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('ok', 'degraded', 'failed')]
        [string]$FilterCurrentStatus,

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
                $ResourceUri = "/inventory/component/info/$([System.Uri]::EscapeDataString($Id))"
                $NameMap = @{}
            }
            'List' {
                $ResourceUri = '/inventory/component/info'
                $NameMap = @{
                    FilterModifiedAfter = 'filter[modifiedAfter]'
                    FilterDeviceId      = 'filter[deviceId]'
                    FilterDeviceName    = 'filter[deviceName]'
                    FilterCurrentStatus = 'filter[currentStatus]'
                    Tenants             = 'tenants'
                    PageFirst           = 'page[first]'
                    PageAfter           = 'page[after]'
                    PageLast            = 'page[last]'
                    PageBefore          = 'page[before]'
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

Set-Alias -Name 'Get-AuvikComponent' -Value 'Get-AuvikComponentInfo'
