function Get-AuvikAlertHistory {
<#
    .SYNOPSIS
        Read Multiple Alerts' Info / Read a Single Alert's Info

    .DESCRIPTION
        Parameter set [ List ] - The Get-AuvikAlertHistory cmdlet invokes the GET method of the /alert/history/info endpoint (Read Multiple Alerts' Info)

        Use the Read Multiple Alerts' Info API to pull the collected information about the various alerts that Auvik has triggered.

        Parameter set [ ById ] - The Get-AuvikAlertHistory cmdlet invokes the GET method of the /alert/history/info/{id} endpoint (Read a Single Alert's Info)

        Use the Read Single Alert's Info API to pull the collected information about a specific alert that Auvik has triggered.

    .PARAMETER Id
        ID of alert

    .PARAMETER FilterAlertDefinitionId
        Filter by alert definition ID.

    .PARAMETER FilterAlertSpecificationId
        Filter by alert specification ID. Use 'alertDefinitionId' instead

    .PARAMETER FilterSeverity
        Filter by alert severity.

        Allowed values:
        'unknown', 'emergency', 'critical', 'warning', 'info'

    .PARAMETER FilterStatus
        Filter by the status of the alert.

        Allowed values:
        'created', 'resolved', 'paused', 'unpaused'

    .PARAMETER FilterEntityId
        Filter by the related entity ID.

    .PARAMETER FilterDismissed
        Filter by the dismissed status.

    .PARAMETER FilterDispatched
        Filter by dispatched status.

    .PARAMETER FilterDetectedTimeAfter
        Filter by the time which is greater than the given timestamp.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterDetectedTimeBefore
        Filter by the time which is less than or equal to the given timestamp.

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
        Get-AuvikAlertHistory

        Returns the result of the /alert/history/info endpoint

    .EXAMPLE
        Get-AuvikAlertHistory -Tenants '1234567890' -PageFirst 10

        Returns the result of the /alert/history/info endpoint limited to the defined tenant

    .EXAMPLE
        Get-AuvikAlertHistory -AllResults

        Returns every item from the /alert/history/info endpoint by following the pagination links

    .EXAMPLE
        Get-AuvikAlertHistory -Id '1234567890'

        Returns the result of the /alert/history/info/{id} endpoint

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /alert/history/info
        Endpoint : GET /alert/history/info/{id}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Alert/Get-AuvikAlertHistory.html
#>

    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById')]
        [ValidateNotNullOrEmpty()]
        [string]$Id,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterAlertDefinitionId,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterAlertSpecificationId,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('unknown', 'emergency', 'critical', 'warning', 'info')]
        [string]$FilterSeverity,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('created', 'resolved', 'paused', 'unpaused')]
        [string]$FilterStatus,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterEntityId,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [bool]$FilterDismissed,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [bool]$FilterDispatched,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [datetime]$FilterDetectedTimeAfter,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [datetime]$FilterDetectedTimeBefore,

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
                $ResourceUri = "/alert/history/info/$([System.Uri]::EscapeDataString($Id))"
                $NameMap = @{}
            }
            'List' {
                $ResourceUri = '/alert/history/info'
                $NameMap = @{
                    FilterAlertDefinitionId    = 'filter[alertDefinitionId]'
                    FilterAlertSpecificationId = 'filter[alertSpecificationId]'
                    FilterSeverity             = 'filter[severity]'
                    FilterStatus               = 'filter[status]'
                    FilterEntityId             = 'filter[entityId]'
                    FilterDismissed            = 'filter[dismissed]'
                    FilterDispatched           = 'filter[dispatched]'
                    FilterDetectedTimeAfter    = 'filter[detectedTimeAfter]'
                    FilterDetectedTimeBefore   = 'filter[detectedTimeBefore]'
                    Tenants                    = 'tenants'
                    PageFirst                  = 'page[first]'
                    PageAfter                  = 'page[after]'
                    PageLast                   = 'page[last]'
                    PageBefore                 = 'page[before]'
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

Set-Alias -Name 'Get-AuvikAlert' -Value 'Get-AuvikAlertHistory'
