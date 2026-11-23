function Get-AuvikAuthenticationVerify {
<#
    .SYNOPSIS
        Verify Credentials

    .DESCRIPTION
        The Get-AuvikAuthenticationVerify cmdlet invokes the GET method of the /authentication/verify endpoint (Verify Credentials)

        Use the Verify Credentials API to verify your credentials are correct before making a call to an endpoint.

    .EXAMPLE
        Get-AuvikAuthenticationVerify

        Returns the result of the /authentication/verify endpoint

    .INPUTS
        None

    .OUTPUTS
        System.Boolean

    .NOTES
        Endpoint : GET /authentication/verify
        The Auvik API user needs the role permissions that are required by the endpoint

        This function returns $true when the credentials are valid & $false when they are not

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Other/Get-AuvikAuthenticationVerify.html
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

        $ResourceUri = '/authentication/verify'
        $NameMap = @{}

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        try {
            $null = Invoke-AuvikRequest @InvokeParams -ErrorAction Stop -WarningAction SilentlyContinue
            return $true
        }
        catch { return $false }

    }

    end {}

}

Set-Alias -Name 'Test-AuvikAPICredential' -Value 'Get-AuvikAuthenticationVerify'
