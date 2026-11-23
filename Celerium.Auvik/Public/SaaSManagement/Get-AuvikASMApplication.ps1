function Get-AuvikASMApplication {
<#
    .SYNOPSIS
        Read Multiple ASM Applications' Info

    .DESCRIPTION
        The Get-AuvikASMApplication cmdlet invokes the GET method of the /asm/app/info endpoint (Read Multiple ASM Applications' Info)

        Use the Read Multiple ASM Applications' Info to retrieve the information related to the SaaS applications discovered within an ASM client deployment. This data includes the number of users of an application as well as key metadata such as whether the application is approved or unapproved.

    .PARAMETER FilterClientId
        Filter by client ID.

    .PARAMETER FilterDateAddedBefore
        Return applications added before this date.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterDateAddedAfter
        Return applications added after this date.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterQueryDate
        Return associated breaches added after this date.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterUserLastUsedAfter
        Return associated users added after this date.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterUserLastUsedBefore
        Return associated users before this date.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER Include
        Use to include extended details of the application or of its related objects.

        Allowed values:
        'all', 'breaches', 'users', 'contracts', 'publisher', 'accessData'

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
        Get-AuvikASMApplication -FilterClientId 'Example'

        Returns the result of the /asm/app/info endpoint

    .EXAMPLE
        Get-AuvikASMApplication -FilterClientId 'Example' -PageFirst 10

        Returns the result of the /asm/app/info endpoint limited to the defined number of items

    .EXAMPLE
        Get-AuvikASMApplication -FilterClientId 'Example' -AllResults

        Returns every item from the /asm/app/info endpoint by following the pagination links

    .INPUTS
        None

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /asm/app/info
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/SaaSManagement/Get-AuvikASMApplication.html
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterClientId,

        [Parameter(Mandatory = $false)]
        [datetime]$FilterDateAddedBefore,

        [Parameter(Mandatory = $false)]
        [datetime]$FilterDateAddedAfter,

        [Parameter(Mandatory = $false)]
        [datetime]$FilterQueryDate,

        [Parameter(Mandatory = $false)]
        [datetime]$FilterUserLastUsedAfter,

        [Parameter(Mandatory = $false)]
        [datetime]$FilterUserLastUsedBefore,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('all', 'breaches', 'users', 'contracts', 'publisher', 'accessData')]
        [string]$Include,

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

        $ResourceUri = '/asm/app/info'
        $NameMap = @{
            FilterClientId           = 'filter[clientId]'
            FilterDateAddedBefore    = 'filter[dateAddedBefore]'
            FilterDateAddedAfter     = 'filter[dateAddedAfter]'
            FilterQueryDate          = 'filter[queryDate]'
            FilterUserLastUsedAfter  = 'filter[user_lastUsedAfter]'
            FilterUserLastUsedBefore = 'filter[user_lastUsedBefore]'
            Include                  = 'include'
            PageFirst                = 'page[first]'
            PageAfter                = 'page[after]'
            PageLast                 = 'page[last]'
            PageBefore               = 'page[before]'
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
