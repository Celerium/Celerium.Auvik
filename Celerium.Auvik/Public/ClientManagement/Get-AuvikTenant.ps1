function Get-AuvikTenant {
<#
    .SYNOPSIS
        Get Auvik tenant information

    .DESCRIPTION
        The Get-AuvikTenant cmdlet get Auvik general or detailed
        tenant information associated to your Auvik user account

    .PARAMETER TenantDomainPrefix
        Domain prefix of your main Auvik account (tenant)

    .PARAMETER FilterAvailableTenants
        Filter whether or not a tenant is available,
        i.e. data can be gotten from them via the API

    .PARAMETER ID
        ID of tenant

    .EXAMPLE
        Get-AuvikTenant

        Gets general information about multiple multi-clients and
        clients associated with your Auvik user account

    .EXAMPLE
        Get-AuvikTenant -TenantDomainPrefix CeleriumMSP

        Gets detailed information about multiple multi-clients and
        clients associated with your main Auvik account

    .EXAMPLE
        Get-AuvikTenant -TenantDomainPrefix CeleriumMSP -ID 123456789

        Gets detailed information about a single tenant from
        your main Auvik account

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/ClientManagement/Get-AuvikTenant.html
#>

    [CmdletBinding(DefaultParameterSetName = 'IndexMultiTenant')]
    Param (
        [Parameter(Mandatory = $true, ParameterSetName = 'IndexMultiTenantDetails')]
        [Parameter(Mandatory = $true, ParameterSetName = 'IndexSingleTenantDetails')]
        [ValidateNotNullOrEmpty()]
        [string]$TenantDomainPrefix,

        [Parameter(Mandatory = $false, ParameterSetName = 'IndexMultiTenantDetails')]
        [switch]$FilterAvailableTenants,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'IndexSingleTenantDetails')]
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
            'IndexMultiTenant'          { $ResourceUri = "/tenants" }
            'IndexMultiTenantDetails'   { $ResourceUri = "/tenants/detail" }
            'IndexSingleTenantDetails'  { $ResourceUri = "/tenants/detail/$ID" }
        }

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -eq 'IndexMultiTenantDetails') {
            if ($FilterAvailableTenants) { $UriParameters['filter[availableTenants]'] = $FilterAvailableTenants }
        }

        #Shared Parameters
        if ($TenantDomainPrefix) { $UriParameters['filter[tenantDomainPrefix]'] = $TenantDomainPrefix }

        #EndRegion  [ Parameter Translation ]

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

        return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

    }

    end {}

}
