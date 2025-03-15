function Remove-AuvikBaseURI {
<#
    .SYNOPSIS
        Removes the Auvik base URI global variable

    .DESCRIPTION
        The Remove-AuvikBaseURI cmdlet removes the Auvik base URI global variable

    .EXAMPLE
        Remove-AuvikBaseURI

        Removes the Auvik base URI global variable

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Internal/Remove-AuvikBaseURI.html
#>

    [cmdletbinding(DefaultParameterSetName = 'Destroy', SupportsShouldProcess, ConfirmImpact = 'None')]
    Param ()

    begin {}

    process {

        switch ([bool]$AuvikModuleBaseURI) {
            $true   {
                if ($PSCmdlet.ShouldProcess('AuvikModuleBaseURI')) {
                    Remove-Variable -Name "AuvikModuleBaseURI" -Scope global -Force
                }
            }
            $false  { Write-Warning "The Auvik base URI variable is not set. Nothing to remove" }
        }

    }

    end {}

}