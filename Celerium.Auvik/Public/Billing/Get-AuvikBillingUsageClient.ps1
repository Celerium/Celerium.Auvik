function Get-AuvikBillingUsageClient {
<#
    .SYNOPSIS
        Read Client Usage

    .DESCRIPTION
        The Get-AuvikBillingUsageClient cmdlet invokes the GET method of the /billing/usage/client endpoint (Read Client Usage)

        Use the Read Client Usage API to pull a summary of a client's (and client's children if a multi-client) usage for a given time range.

    .PARAMETER FilterFromDate
        Date from which you want to query

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterThruDate
        Date to which you want to query

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from.

        Accepts multiple values which are sent to the API as a comma delimited list

    .EXAMPLE
        Get-AuvikBillingUsageClient -FilterFromDate '2025-01-01T00:00:00Z' -FilterThruDate '2025-01-01T00:00:00Z'

        Returns the result of the /billing/usage/client endpoint

    .EXAMPLE
        Get-AuvikBillingUsageClient -FilterFromDate '2025-01-01T00:00:00Z' -FilterThruDate '2025-01-01T00:00:00Z' -Tenants '1234567890'

        Returns the result of the /billing/usage/client endpoint limited to the defined tenant

    .INPUTS
        None

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /billing/usage/client
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Billing/Get-AuvikBillingUsageClient.html
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [datetime]$FilterFromDate,

        [Parameter(Mandatory = $true)]
        [datetime]$FilterThruDate,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = '/billing/usage/client'
        $NameMap = @{
            FilterFromDate = 'filter[fromDate]'
            FilterThruDate = 'filter[thruDate]'
            Tenants        = 'tenants'
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

Set-Alias -Name 'Get-AuvikBilling' -Value 'Get-AuvikBillingUsageClient'
