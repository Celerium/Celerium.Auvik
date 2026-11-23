function Get-AuvikASMSecurityLog {
<#
    .SYNOPSIS
        Read Multiple ASM Security Logs' Info

    .DESCRIPTION
        The Get-AuvikASMSecurityLog cmdlet invokes the GET method of the /asm/securityLog/info endpoint (Read Multiple ASM Security Logs' Info)

        Use the Read Multiple ASM Security Logs' Info API to retrieve in depth information about the security logs within an Auvik SaaS Management client. Security logs include specific SaaS events, such as logins or downloads with timestamps for each event.

    .PARAMETER FilterClientId
        Filter by client ID.

    .PARAMETER Include
        Use to include extended details of the security log or of its related objects.

        Allowed values:
        'users', 'applications'

    .PARAMETER FilterQueryDate
        Only return security logs added after this date.

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
        Get-AuvikASMSecurityLog -FilterClientId 'Example'

        Returns the result of the /asm/securityLog/info endpoint

    .EXAMPLE
        Get-AuvikASMSecurityLog -FilterClientId 'Example' -PageFirst 10

        Returns the result of the /asm/securityLog/info endpoint limited to the defined number of items

    .EXAMPLE
        Get-AuvikASMSecurityLog -FilterClientId 'Example' -AllResults

        Returns every item from the /asm/securityLog/info endpoint by following the pagination links

    .INPUTS
        None

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /asm/securityLog/info
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/SaaSManagement/Get-AuvikASMSecurityLog.html
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterClientId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('users', 'applications')]
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

        $ResourceUri = '/asm/securityLog/info'
        $NameMap = @{
            FilterClientId  = 'filter[clientId]'
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
