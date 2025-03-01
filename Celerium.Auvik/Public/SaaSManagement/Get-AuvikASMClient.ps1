function Get-AuvikASMClient {
    <#
        .SYNOPSIS
            Get Auvik ASM meta client information

        .DESCRIPTION
            The Get-AuvikASMClient cmdlet gets multiple ASM meta clients' info
            to retrieve the information related to the SaaS meta clients discovered
            within an ASM client deployment

        .PARAMETER Include
            Use to include extended details of the client

            Allowed values:
                "totals"

        .PARAMETER FilterQueryDate
            Only count breaches added after this date. Only useful when include=totals is set

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
            Get-AuvikASMClient

            Get Auvik ASM meta client information

        .EXAMPLE
            Get-AuvikASMClient -PageFirst 1000 -AllResults

            Get Auvik ASM meta client information for all devices found by Auvik

        .NOTES
        N\A

        .LINK
            https://celerium.github.io/Celerium.Auvik/site/SaaSManagement/Get-AuvikASMClient.html
    #>

        [CmdletBinding(DefaultParameterSetName = 'Index')]
        Param (
            [Parameter( Mandatory = $false)]
            [ValidateSet( "totals" )]
            [string]$Include,

            [Parameter( Mandatory = $false)]
            [DateTime]$FilterQueryDate,

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

            $ResourceUri = "/asm/client/info"

            $UriParameters = @{}

            #Region     [ Parameter Translation ]

            if ($PSCmdlet.ParameterSetName -eq 'Index') {
                if ($Include)           { $UriParameters['include']             = $Include }
                if ($FilterQueryDate)   { $UriParameters['filter[queryDate]']   = $FilterQueryDate }
                if ($PageFirst)         { $UriParameters['page[first]']         = $PageFirst }
                if ($PageAfter)         { $UriParameters['page[after]']         = $PageAfter }
                if ($PageLast)          { $UriParameters['page[last]']          = $PageLast }
                if ($PageBefore)        { $UriParameters['page[before]']        = $PageBefore }
            }

            #EndRegion  [ Parameter Translation ]

            Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
            Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

            return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

        }

        end {}

    }
