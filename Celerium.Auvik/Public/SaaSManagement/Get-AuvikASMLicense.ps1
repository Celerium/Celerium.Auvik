function Get-AuvikASMLicense {
<#
    .SYNOPSIS
        Read Multiple ASM Licenses' Info

    .DESCRIPTION
        The Get-AuvikASMLicense cmdlet invokes the GET method of the /asm/license/info endpoint (Read Multiple ASM Licenses' Info)

        Use the Read Multiple ASM Licenses' Info endpoint to retrieve information about an application licenses discovered within an ASM client deployment. This data includes the license type and associated user email assigned to each license, alongside other key metadata such as last login time. To access this data, a SaaS Ops integration with the desired application must be configured.

    .PARAMETER FilterClientId
        Filter by client ID.

    .PARAMETER FilterApplicationId
        Unique identifier of the application.

    .PARAMETER FilterEmail
        Filter results by a specific license email.

    .PARAMETER FilterLicenseType
        Filter results by license type.

    .PARAMETER FilterLastLoginBefore
        Returns only users whose last login was before the given date or have no last login time.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterUnderutilizedOnly
        If included, filters to users flagged as underutilized.

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
        Get-AuvikASMLicense -FilterClientId 'Example' -FilterApplicationId 'Example'

        Returns the result of the /asm/license/info endpoint

    .EXAMPLE
        Get-AuvikASMLicense -FilterClientId 'Example' -FilterApplicationId 'Example' -PageFirst 10

        Returns the result of the /asm/license/info endpoint limited to the defined number of items

    .EXAMPLE
        Get-AuvikASMLicense -FilterClientId 'Example' -FilterApplicationId 'Example' -AllResults

        Returns every item from the /asm/license/info endpoint by following the pagination links

    .INPUTS
        None

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /asm/license/info
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/SaaSManagement/Get-AuvikASMLicense.html
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterClientId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterApplicationId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterEmail,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterLicenseType,

        [Parameter(Mandatory = $false)]
        [datetime]$FilterLastLoginBefore,

        [Parameter(Mandatory = $false)]
        [bool]$FilterUnderutilizedOnly,

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

        $ResourceUri = '/asm/license/info'
        $NameMap = @{
            FilterClientId          = 'filter[clientId]'
            FilterApplicationId     = 'filter[applicationId]'
            FilterEmail             = 'filter[email]'
            FilterLicenseType       = 'filter[licenseType]'
            FilterLastLoginBefore   = 'filter[lastLoginBefore]'
            FilterUnderutilizedOnly = 'filter[underutilizedOnly]'
            PageFirst               = 'page[first]'
            PageAfter               = 'page[after]'
            PageLast                = 'page[last]'
            PageBefore              = 'page[before]'
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
