function Get-AuvikBilling {
<#
    .SYNOPSIS
        Get Auvik billing information

    .DESCRIPTION
        The Get-AuvikBilling cmdlet gets billing information
        to help calculate your invoices

        The dataTime value are converted to UTC, however for these endpoints
        you will only need to defined yyyy-MM-dd

    .PARAMETER FilterFromDate
        Date from which you want to query

        Example: filter[fromDate]=2019-06-01

    .PARAMETER FilterThruDate
        Date to which you want to query

        Example: filter[thruDate]=2019-06-30

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from.

        Example: Tenants=199762235015168516,199762235015168004

    .PARAMETER ID
        ID of device

    .EXAMPLE
        Get-AuvikBilling -FilterFromDate 2023-09-01 -FilterThruDate 2023-09-30

        Gets a summary of a client's (and client's children if a multi-client)
        usage for the given time range.

    .EXAMPLE
        Get-AuvikBilling -FilterFromDate 2023-09-01 -FilterThruDate 2023-09-30 -Tenants 12345,98765

        Gets a summary of the defined client's (and client's children if a multi-client)fromDate
        usage for the given time range.

    .EXAMPLE
        Get-AuvikBilling -FilterFromDate 2023-09-01 -FilterThruDate 2023-09-30 -ID 123456789

        Gets a summary of the define device id's usage for the given time range.

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Billing/Get-AuvikBilling.html
#>

    [CmdletBinding(DefaultParameterSetName = 'IndexByClient')]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterFromDate,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterThruDate,

        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = 'IndexByClient')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'IndexByDevice')]
        [ValidateNotNullOrEmpty()]
        [string]$ID
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = $functionName + '_Parameters'      -replace '-','_'
        $QueryParameterName = $functionName + '_ParametersQuery' -replace '-','_'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        switch ( $($PSCmdlet.ParameterSetName) ) {
            'IndexByClient' { $ResourceUri = "/billing/usage/client" }
            'IndexByDevice' { $ResourceUri = "/billing/usage/device/$ID" }
        }

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -like 'IndexBy*') {
            if ($Tenants) { $UriParameters['tenants']  = $Tenants }
        }

        #Shared Parameters
        if ($FilterFromDate)    { $UriParameters['filter[fromDate]']    = $FilterFromDate }
        if ($FilterThruDate)    { $UriParameters['filter[thruDate]']    = $FilterThruDate }

        #EndRegion  [ Parameter Translation ]

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

        return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

    }

    end {}

}
