function Get-AuvikTenant {
<#
    .SYNOPSIS
        Read Multiple Tenants

    .DESCRIPTION
        The Get-AuvikTenant cmdlet invokes the GET method of the /tenants endpoint (Read Multiple Tenants)

        Use the Read Multiple Tenants API to pull access detail about multiple multi-clients and clients associated with your Auvik user account.

    .EXAMPLE
        Get-AuvikTenant

        Returns the result of the /tenants endpoint

    .INPUTS
        None

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /tenants
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/ClientManagement/Get-AuvikTenant.html
#>

    [CmdletBinding()]
    param (

    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = '/tenants'
        $NameMap = @{}

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
