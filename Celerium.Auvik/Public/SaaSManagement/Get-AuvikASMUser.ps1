function Get-AuvikASMUser {
<#
    .SYNOPSIS
        Read Multiple ASM Users' Info

    .DESCRIPTION
        The Get-AuvikASMUser cmdlet invokes the GET method of the /asm/user/info endpoint (Read Multiple ASM Users' Info)

        Use the Read Multiple ASM Users' Info API to retrieve information about any monitored users that exist within a specific Auvik SaaS Management tenant. ASM user data includes core information about the SaaS applications a monitored user is using as well as which accounts a user is leveraging to log into those applications.

    .PARAMETER FilterClientId
        Filter by client ID.

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
        Get-AuvikASMUser -FilterClientId 'Example'

        Returns the result of the /asm/user/info endpoint

    .EXAMPLE
        Get-AuvikASMUser -FilterClientId 'Example' -PageFirst 10

        Returns the result of the /asm/user/info endpoint limited to the defined number of items

    .EXAMPLE
        Get-AuvikASMUser -FilterClientId 'Example' -AllResults

        Returns every item from the /asm/user/info endpoint by following the pagination links

    .INPUTS
        None

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /asm/user/info
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/SaaSManagement/Get-AuvikASMUser.html
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterClientId,

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

        $ResourceUri = '/asm/user/info'
        $NameMap = @{
            FilterClientId = 'filter[clientId]'
            PageFirst      = 'page[first]'
            PageAfter      = 'page[after]'
            PageLast       = 'page[last]'
            PageBefore     = 'page[before]'
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
