function Get-AuvikEntity {
<#
    .SYNOPSIS
        Get Auvik Notes and audit trails associated with the entities

    .DESCRIPTION
        The Get-AuvikEntity cmdlet allows you to view Notes and audit trails associated
        with the entities (devices, networks, and interfaces) that have been discovered
        by Auvik.

        Use the [ -Audits & -Notes  ] parameters when wanting to target
        specific information.

        See Get-Help Get-AuvikEntity -Full for more information on associated parameters

    .PARAMETER ID
        ID of entity note\audit

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from

    .PARAMETER FilterEntityId
        Filter by the entity's ID

    .PARAMETER FilterUser
        Filter by user name associated to the audit

    .PARAMETER FilterCategory
        Filter by the audit's category

        Allowed values:
            "unknown", "tunnel", "terminal", "remoteBrowser"

    .PARAMETER FilterEntityType
        Filter by the entity's type

        Allowed values:
            "root", "device", "network", "interface"

    .PARAMETER FilterEntityName
        Filter by the entity's name

    .PARAMETER FilterLastModifiedBy
        Filter by the user the note was last modified by

    .PARAMETER FilterStatus
        Filter by the audit's status

        Allowed values:
            "unknown", "initiated", "created", "closed", "failed"

    .PARAMETER FilterModifiedAfter
        Filter by date and time, only returning entities modified after provided value

    .PARAMETER Audits
        Target the audit endpoint

        /Inventory/entity/audit & /Inventory/entity/audit/{id}

    .PARAMETER Notes
        Target the note endpoint

        /Inventory/entity/note & /Inventory/entity/note/{id}

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned
        Used in combination with page[after]

        Default Value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page
        The page size is provided by page[first]

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned
        Used in combination with page[before]

        Default Value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page
        The page size is provided by page[last]

    .PARAMETER AllResults
        Returns all items from an endpoint

        Highly recommended to only use with filters to reduce API errors\timeouts

    .EXAMPLE
        Get-AuvikEntity

        Gets general information about the first 100 Notes
        Auvik has discovered

    .EXAMPLE
        Get-AuvikEntity -ID 123456789 -Audits

        Gets general information for the defined audit
        Auvik has discovered

    .EXAMPLE
        Get-AuvikEntity -ID 123456789 -Notes

        Gets general information for the defined note
        Auvik has discovered

    .EXAMPLE
        Get-AuvikEntity -PageFirst 1000 -AllResults

        Gets general information for all note entities found by Auvik.

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikEntity.html
#>

    [CmdletBinding(DefaultParameterSetName = 'IndexByMultiEntityNotes' )]
    Param (
        [Parameter( Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'IndexBySingleEntityNotes' )]
        [Parameter( Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'IndexBySingleEntityAudits' )]
        [ValidateNotNullOrEmpty()]
        [string]$ID,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityNotes' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityAudits' )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityNotes' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterEntityId,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityAudits' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterUser,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityAudits' )]
        [ValidateSet( "unknown", "tunnel", "terminal", "remoteBrowser" )]
        [string]$FilterCategory,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityNotes' )]
        [ValidateSet( "root", "device", "network", "interface" )]
        [string]$FilterEntityType,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityNotes' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterEntityName,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityNotes' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterLastModifiedBy,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityAudits' )]
        [ValidateSet( "unknown", "initiated", "created", "closed", "failed" )]
        [string]$FilterStatus,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityNotes' )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterModifiedAfter,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexBySingleEntityAudits' )]
        [switch]$Audits,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexBySingleEntityNotes' )]
        [switch]$Notes,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityNotes' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityAudits' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityNotes' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityAudits' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityNotes' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityAudits' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityNotes' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityAudits' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityNotes' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityAudits' )]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = $functionName + '_Parameters'      -replace '-','_'
        $QueryParameterName = $functionName + '_ParametersQuery' -replace '-','_'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        switch ( $($PSCmdlet.ParameterSetName) ) {
            'IndexByMultiEntityNotes'   { $ResourceUri = "/inventory/entity/note" }
            'IndexBySingleEntityNotes'  { $ResourceUri = "/inventory/entity/note/$ID" }

            'IndexByMultiEntityAudits'  { $ResourceUri = "/inventory/entity/audit" }
            'IndexBySingleEntityAudits' { $ResourceUri = "/inventory/entity/audit/$ID" }
        }

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -eq 'IndexByMultiEntityNotes') {
            if ($FilterEntityId)            { $UriParameters['filter[entityId]']             = $FilterEntityId }
            if ($FilterEntityType)          { $UriParameters['filter[entityType]']           = $FilterEntityType }
            if ($FilterEntityName)          { $UriParameters['filter[entityName]']           = $FilterEntityName }
            if ($FilterLastModifiedBy)      { $UriParameters['filter[lastModifiedBy]']       = $FilterLastModifiedBy }
        }

        if ($PSCmdlet.ParameterSetName -like 'IndexByMulti*') {
            if ($FilterModifiedAfter)       { $UriParameters['filter[modifiedAfter]']        = $FilterModifiedAfter }
            if ($Tenants)                   { $UriParameters['filter[tenantId]']             = $Tenants }
            if ($PageFirst)                 { $UriParameters['page[first]']                  = $PageFirst }
            if ($PageAfter)                 { $UriParameters['page[after]']                  = $PageAfter }
            if ($PageLast)                  { $UriParameters['page[last]']                   = $PageLast }
            if ($PageBefore)                { $UriParameters['page[before]']                 = $PageBefore }
        }

        if ($PSCmdlet.ParameterSetName -eq 'IndexByMultiEntityAudits') {
            if ($FilterUser)                { $UriParameters['filter[user]']                 = $FilterUser }
            if ($FilterCategory)            { $UriParameters['filter[category]']             = $FilterCategory }
            if ($FilterStatus)              { $UriParameters['filter[status]']               = $FilterStatus }
        }

        #EndRegion  [ Parameter Translation ]

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

        return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

    }

    end {}

}
