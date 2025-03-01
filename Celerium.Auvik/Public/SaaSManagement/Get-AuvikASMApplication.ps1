function Get-AuvikASMApplication {
    <#
        .SYNOPSIS
            Get Auvik ASM application information

        .DESCRIPTION
            The Get-AuvikASMApplication cmdlet gets multiple ASM applications' info
            to retrieve the information related to the SaaS applications discovered
            within an ASM client deployment

        .PARAMETER FilterClientId
            Filter by client ID

        .PARAMETER FilterDateAddedBefore
            Return applications added before this date

        .PARAMETER FilterDateAddedAfter
            Return applications added after this date

        .PARAMETER FilterQueryDate
            Return associated breaches added after this date

        .PARAMETER FilterUserLastUsedAfter
            Return associated users added after this date

        .PARAMETER FilterUserLastUsedBefore
            Return associated users before this date

        .PARAMETER Include
            Use to include extended details of the application or of its related objects

            Allowed values:
                "all" "breaches" "users" "contracts" "publisher" "accessData"

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
            Get-AuvikASMApplication

            Get Auvik ASM application information

        .EXAMPLE
            Get-AuvikASMApplication -PageFirst 1000 -AllResults

            Get Auvik ASM application information for all devices found by Auvik

        .NOTES
        N\A

        .LINK
            https://celerium.github.io/Celerium.Auvik/site/SaaSManagement/Get-AuvikASMApplication.html
    #>

        [CmdletBinding(DefaultParameterSetName = 'Index')]
        Param (
            [Parameter( Mandatory = $false, ValueFromPipeline = $true)]
            [ValidateNotNullOrEmpty()]
            [string]$FilterClientId,

            [Parameter( Mandatory = $false)]
            [ValidateNotNullOrEmpty()]
            [DateTime]$FilterDateAddedBefore,

            [Parameter( Mandatory = $false)]
            [DateTime]$FilterDateAddedAfter,

            [Parameter( Mandatory = $false)]
            [DateTime]$FilterQueryDate,

            [Parameter( Mandatory = $false)]
            [DateTime]$FilterUserLastUsedAfter,

            [Parameter( Mandatory = $false)]
            [DateTime]$FilterUserLastUsedBefore,

            [Parameter( Mandatory = $false)]
            [ValidateSet( "all", "breaches", "users", "contracts", "publisher", "accessData" )]
            [string[]]$Include,

            [Parameter( Mandatory = $false)]
            [ValidateRange(1, [int64]::MaxValue)]
            [int64]$PageFirst,

            [Parameter( Mandatory = $false)]
            [ValidateNotNullOrEmpty()]
            [string]$PageAfter,

            [Parameter( Mandatory = $false)]
            [ValidateRange(1, [int64]::MaxValue)]
            [int64]$PageLast,

            [Parameter( Mandatory = $false)]
            [ValidateNotNullOrEmpty()]
            [string]$PageBefore,

            [Parameter( Mandatory = $false)]
            [switch]$AllResults
        )

        begin {

            $FunctionName       = $MyInvocation.InvocationName
            $ParameterName      = $functionName + '_Parameters'      -replace '-','_'
            $QueryParameterName = $functionName + '_ParametersQuery' -replace '-','_'

        }

        process {

            Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

            $ResourceUri = "/asm/app/info"

            $UriParameters = @{}

            #Region     [ Parameter Translation ]

            if ($PSCmdlet.ParameterSetName -eq 'Index') {
                if ($FilterClientId)            { $UriParameters['filter[clientId]']             = $FilterClientId }
                if ($FilterDateAddedBefore)     { $UriParameters['filter[dateAddedBefore]']       = $FilterDateAddedBefore }
                if ($FilterDateAddedAfter)      { $UriParameters['filter[dateAddedAfter]']       = $FilterDateAddedAfter }
                if ($FilterQueryDate)           { $UriParameters['filter[queryDate]']            = $FilterQueryDate }
                if ($FilterUserLastUsedAfter)   { $UriParameters['filter[user_lastUsedAfter]']   = $FilterUserLastUsedAfter }
                if ($FilterUserLastUsedBefore)  { $UriParameters['filter[user_lastUsedBefore]']  = $FilterUserLastUsedBefore }
                if ($Include)                   { $UriParameters['include']                      = $Include }
                if ($PageFirst)                 { $UriParameters['page[first]']                  = $PageFirst }
                if ($PageAfter)                 { $UriParameters['page[after]']                  = $PageAfter }
                if ($PageLast)                  { $UriParameters['page[last]']                   = $PageLast }
                if ($PageBefore)                { $UriParameters['page[before]']                 = $PageBefore }
            }

            #EndRegion  [ Parameter Translation ]

            Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
            Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

            return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

        }

        end {}

    }
