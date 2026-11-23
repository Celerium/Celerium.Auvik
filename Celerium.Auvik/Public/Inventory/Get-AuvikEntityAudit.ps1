function Get-AuvikEntityAudit {
<#
    .SYNOPSIS
        Read Multiple Entity Audits / Read a Single Entity Audit

    .DESCRIPTION
        Parameter set [ List ] - The Get-AuvikEntityAudit cmdlet invokes the GET method of the /inventory/entity/audit endpoint (Read Multiple Entity Audits)

        Use the Read Multiple Entity Audits API pull information about multiple entity audits for you clients. You'll need the client IDs for the clients you want to run the multiple read against.

        Parameter set [ ById ] - The Get-AuvikEntityAudit cmdlet invokes the GET method of the /inventory/entity/audit/{id} endpoint (Read a Single Entity Audit)

        Use the Single Multiple Entity Audit API pull information about a single entity audit. You'll need the audit entry ID for the specific audit.

    .PARAMETER Id
        ID of entity audit

    .PARAMETER FilterUser
        Filter by user name associated to the audit.

    .PARAMETER FilterCategory
        Filter by the audit's category.

        Allowed values:
        'unknown', 'tunnel', 'terminal', 'remoteBrowser'

    .PARAMETER FilterStatus
        Filter by the audit's status.

        Allowed values:
        'unknown', 'initiated', 'created', 'closed', 'failed'

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
        Get-AuvikEntityAudit

        Returns the result of the /inventory/entity/audit endpoint

    .EXAMPLE
        Get-AuvikEntityAudit -Tenants '1234567890' -PageFirst 10

        Returns the result of the /inventory/entity/audit endpoint limited to the defined tenant

    .EXAMPLE
        Get-AuvikEntityAudit -AllResults

        Returns every item from the /inventory/entity/audit endpoint by following the pagination links

    .EXAMPLE
        Get-AuvikEntityAudit -Id '1234567890'

        Returns the result of the /inventory/entity/audit/{id} endpoint

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /inventory/entity/audit
        Endpoint : GET /inventory/entity/audit/{id}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikEntityAudit.html
#>

    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById')]
        [ValidateNotNullOrEmpty()]
        [string]$Id,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterUser,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('unknown', 'tunnel', 'terminal', 'remoteBrowser')]
        [string]$FilterCategory,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('unknown', 'initiated', 'created', 'closed', 'failed')]
        [string]$FilterStatus,

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
                $ResourceUri = "/inventory/entity/audit/$([System.Uri]::EscapeDataString($Id))"
                $NameMap = @{}
            }
            'List' {
                $ResourceUri = '/inventory/entity/audit'
                $NameMap = @{
                    FilterUser          = 'filter[user]'
                    FilterCategory      = 'filter[category]'
                    FilterStatus        = 'filter[status]'
                    FilterModifiedAfter = 'filter[modifiedAfter]'
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
