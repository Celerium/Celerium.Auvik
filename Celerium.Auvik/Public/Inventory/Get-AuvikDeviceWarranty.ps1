function Get-AuvikDeviceWarranty {
    <#
        .SYNOPSIS
            Get Auvik devices and other related information

        .DESCRIPTION
            The Get-AuvikDeviceWarranty cmdlet allows you to view an inventory of
            devices and other related information discovered by Auvik

        .PARAMETER ID
            ID of device

        .PARAMETER Tenants
            Comma delimited list of tenant IDs to request info from

        .PARAMETER FilterCoveredUnderWarranty
            Filter by warranty coverage status

        .PARAMETER FilterCoveredUnderService
            Filter by service coverage status

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
            Get-AuvikDeviceWarranty

            Gets general warranty information about the first 100 devices
            Auvik has discovered

        .EXAMPLE
            Get-AuvikDeviceWarranty -ID 123456789

            Gets general warranty information for the defined device
            Auvik has discovered


        .EXAMPLE
            Get-AuvikDeviceWarranty -PageFirst 1000 -AllResults

            Gets general warranty information for all devices found by Auvik

        .NOTES
        N\A

        .LINK
            https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikDeviceWarranty.html
    #>

        [CmdletBinding(DefaultParameterSetName = 'IndexByMultiDevice' )]
        Param (
            [Parameter( Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'IndexBySingleDevice' )]
            [ValidateNotNullOrEmpty()]
            [string]$ID,

            [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDevice' )]
            [ValidateNotNullOrEmpty()]
            [string[]]$Tenants,

            [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDevice' )]
            [switch]$FilterCoveredUnderWarranty,

            [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDevice' )]
            [switch]$FilterCoveredUnderService,

            [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDevice' )]
            [ValidateRange(1, [int64]::MaxValue)]
            [int64]$PageFirst,

            [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDevice' )]
            [ValidateNotNullOrEmpty()]
            [string]$PageAfter,

            [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDevice' )]
            [ValidateRange(1, [int64]::MaxValue)]
            [int64]$PageLast,

            [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDevice' )]
            [ValidateNotNullOrEmpty()]
            [string]$PageBefore,

            [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDevice' )]
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
                'IndexByMultiDevice'    { $ResourceUri = "/inventory/device/warranty" }
                'IndexBySingleDevice'   { $ResourceUri = "/inventory/device/warranty/$ID" }
            }

            $UriParameters = @{}

            #Region     [ Parameter Translation ]

            if ($PSCmdlet.ParameterSetName -eq 'IndexByMultiDevice') {
                if ($Tenants)                       { $UriParameters['filter[tenantId]']                = $Tenants }
                if ($FilterCoveredUnderWarranty)    { $UriParameters['filter[coveredUnderWarranty]']    = $FilterCoveredUnderWarranty }
                if ($FilterCoveredUnderService)     { $UriParameters['filter[coveredUnderService]']     = $FilterCoveredUnderService }
                if ($PageFirst)                     { $UriParameters['page[first]']                     = $PageFirst }
                if ($PageAfter)                     { $UriParameters['page[after]']                     = $PageAfter }
                if ($PageLast)                      { $UriParameters['page[last]']                      = $PageLast }
                if ($PageBefore)                    { $UriParameters['page[before]']                    = $PageBefore }
            }

            #EndRegion  [ Parameter Translation ]

            Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
            Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

            return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

        }

        end {}

    }
