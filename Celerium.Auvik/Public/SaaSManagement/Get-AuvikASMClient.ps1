function Get-AuvikASMClient {
<#
    .SYNOPSIS
        Read Multiple ASM Clients' Info

    .DESCRIPTION
        The Get-AuvikASMClient cmdlet invokes the GET method of the /asm/client/info endpoint (Read Multiple ASM Clients' Info)

        The Read Multiple ASM Clients' Info API returns relevant meta data about clients that exist within the Auvik SaaS Management product. The response includes the number of total users as well as clientIDs which may be used to filter other relevant API calls.

    .PARAMETER Include
        Use to include extended details of the client.

        Allowed values:
        'totals'

    .PARAMETER FilterQueryDate
        Only count breaches added after this date. Only useful when include=totals is set.

        Accepts a date & time which is sent to the API in UTC

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
        Get-AuvikASMClient

        Returns the result of the /asm/client/info endpoint

    .EXAMPLE
        Get-AuvikASMClient -PageFirst 10

        Returns the result of the /asm/client/info endpoint limited to the defined number of items

    .EXAMPLE
        Get-AuvikASMClient -AllResults

        Returns every item from the /asm/client/info endpoint by following the pagination links

    .INPUTS
        None

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /asm/client/info
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/SaaSManagement/Get-AuvikASMClient.html
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('totals')]
        [string]$Include,

        [Parameter(Mandatory = $false)]
        [datetime]$FilterQueryDate,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter(Mandatory = $false)]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = '/asm/client/info'
        $NameMap = @{
            Include         = 'include'
            FilterQueryDate = 'filter[queryDate]'
            PageFirst       = 'page[first]'
            PageAfter       = 'page[after]'
            PageLast        = 'page[last]'
            PageBefore      = 'page[before]'
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
