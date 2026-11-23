function Get-AuvikTenantDetail {
<#
    .SYNOPSIS
        Read Multiple Tenants Detail / Read Single Tenant Detail

    .DESCRIPTION
        Parameter set [ List ] - The Get-AuvikTenantDetail cmdlet invokes the GET method of the /tenants/detail endpoint (Read Multiple Tenants Detail)

        Use the Read Multiple Tenants API to pull details for multiple multi-clients and clients associated with your main Auvik account.

        Parameter set [ ById ] - The Get-AuvikTenantDetail cmdlet invokes the GET method of the /tenants/detail/{id} endpoint (Read Single Tenant Detail)

        Use the Read a Single Tenant API to pull detail about a specific multi-client and client associated with your main Auvik account. You'll need the tenant ID for the specific multi-client or client you want detail for.

    .PARAMETER Id
        ID of tenant

    .PARAMETER TenantDomainPrefix
        Domain prefix of your main Auvik account (tenant).

    .PARAMETER FilterAvailableTenants
        Filter whether or not a tenant is available, i.e. data can be gotten from them via the API.

    .EXAMPLE
        Get-AuvikTenantDetail -TenantDomainPrefix 'celerium'

        Returns the result of the /tenants/detail endpoint

    .EXAMPLE
        Get-AuvikTenantDetail -Id '1234567890' -TenantDomainPrefix 'celerium'

        Returns the result of the /tenants/detail/{id} endpoint

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /tenants/detail
        Endpoint : GET /tenants/detail/{id}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/ClientManagement/Get-AuvikTenantDetail.html
#>

    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById')]
        [ValidateNotNullOrEmpty()]
        [string]$Id,

        [Parameter(Mandatory = $true, ParameterSetName = 'ById')]
        [Parameter(Mandatory = $true, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$TenantDomainPrefix,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [bool]$FilterAvailableTenants
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
                $ResourceUri = "/tenants/detail/$([System.Uri]::EscapeDataString($Id))"
                $NameMap = @{
                    TenantDomainPrefix = 'tenantDomainPrefix'
                }
            }
            'List' {
                $ResourceUri = '/tenants/detail'
                $NameMap = @{
                    TenantDomainPrefix     = 'tenantDomainPrefix'
                    FilterAvailableTenants = 'filter[availableTenants]'
                }
            }
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
