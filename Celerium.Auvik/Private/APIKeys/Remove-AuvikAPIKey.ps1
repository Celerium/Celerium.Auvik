function Remove-AuvikAPIKey {
<#
    .SYNOPSIS
        Removes the Auvik API username & API key global variables

    .DESCRIPTION
        The Remove-AuvikAPIKey cmdlet removes the Auvik API username & API key global variables

    .EXAMPLE
        Remove-AuvikAPIKey

        Removes the Auvik API username & API key global variables

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Internal/Remove-AuvikAPIKey.html
#>

    [cmdletbinding(SupportsShouldProcess, ConfirmImpact = 'None')]
    Param ()

    begin {}

    process {

        switch ([bool]$AuvikUserName) {
            $true   {
                if ($PSCmdlet.ShouldProcess('AuvikUserName')) {
                    Remove-Variable -Name "AuvikUserName" -Scope global -Force
                }
            }
            $false  { Write-Warning "The Auvik API [ username ] is not set. Nothing to remove" }
        }

        switch ([bool]$AuvikApiKey) {
            $true   {
                if ($PSCmdlet.ShouldProcess('AuvikApiKey')) {
                    Remove-Variable -Name "AuvikApiKey" -Scope global -Force
                }
            }
            $false  { Write-Warning "The Auvik API [ API ] key is not set. Nothing to remove" }
        }

    }

    end {}

}