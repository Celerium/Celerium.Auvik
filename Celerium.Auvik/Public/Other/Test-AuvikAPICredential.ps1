function Test-AuvikAPICredential {
<#
    .SYNOPSIS
        Verify that your credentials are correct before making a call to an endpoint

    .DESCRIPTION
        The Get-AuvikCredential cmdlet Verifies that your
        credentials are correct before making a call to an endpoint

    .EXAMPLE
        Get-AuvikCredential

        Gets general information about multiple multi-clients and
        clients associated with your Auvik user account

    .EXAMPLE
        Get-AuvikCredential

        Verify that your credentials are correct
        before making a call to an endpoint

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Other/Get-AuvikCredential.html
#>

    [CmdletBinding()]
    Param ()

    begin {}

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = "/authentication/verify"

        $return = Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -ErrorVariable restError

        if ( [string]::IsNullOrEmpty($return) -and [bool]$restError -eq $false ) {
            $true
        }
        else{ $false }

    }

    end {}

}
