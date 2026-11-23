function Get-AuvikBillingUsageDevice {
<#
    .SYNOPSIS
        Read Device Usage

    .DESCRIPTION
        The Get-AuvikBillingUsageDevice cmdlet invokes the GET method of the /billing/usage/device/{id} endpoint (Read Device Usage)

        Use the Read Device Usage API to pull a summary of a client's (and client's children if a multi-client) usage for a given time range.

    .PARAMETER Id
        ID of device

    .PARAMETER FilterFromDate
        Date from which you want to query

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterThruDate
        Date to which you want to query

        Accepts a date & time which is sent to the API in UTC

    .EXAMPLE
        Get-AuvikBillingUsageDevice -Id '1234567890' -FilterFromDate '2025-01-01T00:00:00Z' -FilterThruDate '2025-01-01T00:00:00Z'

        Returns the result of the /billing/usage/device/{id} endpoint

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /billing/usage/device/{id}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Billing/Get-AuvikBillingUsageDevice.html
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Id,

        [Parameter(Mandatory = $true)]
        [datetime]$FilterFromDate,

        [Parameter(Mandatory = $true)]
        [datetime]$FilterThruDate
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = "/billing/usage/device/$([System.Uri]::EscapeDataString($Id))"
        $NameMap = @{
            FilterFromDate = 'filter[fromDate]'
            FilterThruDate = 'filter[thruDate]'
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}
