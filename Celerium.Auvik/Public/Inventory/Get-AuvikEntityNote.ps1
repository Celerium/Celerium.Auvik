function Get-AuvikEntityNote {
<#
    .SYNOPSIS
        Read Multiple Entity Notes / Read a Single Entity Note

    .DESCRIPTION
        Parameter set [ List ] - The Get-AuvikEntityNote cmdlet invokes the GET method of the /inventory/entity/note endpoint (Read Multiple Entity Notes)

        Use the Read Multiple Entity Notes API pull information about multiple entity notes. You'll need the client IDs for the clients you want to run the multiple read against.

        Parameter set [ ById ] - The Get-AuvikEntityNote cmdlet invokes the GET method of the /inventory/entity/note/{id} endpoint (Read a Single Entity Note)

        Use the Read Single Entity Note API to pull the information about a specific entity note. You'll need the entity note ID for the specific entity note.

    .PARAMETER Id
        ID of entity note

    .PARAMETER FilterEntityId
        Filter by the entity's ID.

    .PARAMETER FilterEntityType
        Filter by the entity's type.

        Allowed values:
        'root', 'device', 'network', 'interface'

    .PARAMETER FilterEntityName
        Filter by the entity's name.

    .PARAMETER FilterLastModifiedBy
        Filter by the user the note was last modified by.

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
        Get-AuvikEntityNote

        Returns the result of the /inventory/entity/note endpoint

    .EXAMPLE
        Get-AuvikEntityNote -Tenants '1234567890' -PageFirst 10

        Returns the result of the /inventory/entity/note endpoint limited to the defined tenant

    .EXAMPLE
        Get-AuvikEntityNote -AllResults

        Returns every item from the /inventory/entity/note endpoint by following the pagination links

    .EXAMPLE
        Get-AuvikEntityNote -Id '1234567890'

        Returns the result of the /inventory/entity/note/{id} endpoint

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /inventory/entity/note
        Endpoint : GET /inventory/entity/note/{id}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikEntityNote.html
#>

    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById')]
        [ValidateNotNullOrEmpty()]
        [string]$Id,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterEntityId,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('root', 'device', 'network', 'interface')]
        [string]$FilterEntityType,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterEntityName,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterLastModifiedBy,

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
                $ResourceUri = "/inventory/entity/note/$([System.Uri]::EscapeDataString($Id))"
                $NameMap = @{}
            }
            'List' {
                $ResourceUri = '/inventory/entity/note'
                $NameMap = @{
                    FilterEntityId       = 'filter[entityId]'
                    FilterEntityType     = 'filter[entityType]'
                    FilterEntityName     = 'filter[entityName]'
                    FilterLastModifiedBy = 'filter[lastModifiedBy]'
                    FilterModifiedAfter  = 'filter[modifiedAfter]'
                    Tenants              = 'tenants'
                    PageFirst            = 'page[first]'
                    PageAfter            = 'page[after]'
                    PageLast             = 'page[last]'
                    PageBefore           = 'page[before]'
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

Set-Alias -Name 'Get-AuvikEntity' -Value 'Get-AuvikEntityNote'
