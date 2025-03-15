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

    [cmdletbinding(DefaultParameterSetName = 'Destroy', SupportsShouldProcess, ConfirmImpact = 'None')]
    Param ()

    begin {}

    process {

        switch ([bool]$AuvikModuleUserName) {
            $true   {
                if ($PSCmdlet.ShouldProcess('AuvikModuleUserName')) {
                    Remove-Variable -Name "AuvikModuleUserName" -Scope global -Force
                }
            }
            $false  { Write-Warning "The Auvik API [ username ] is not set. Nothing to remove" }
        }

        switch ([bool]$AuvikModuleApiKey) {
            $true   {
                if ($PSCmdlet.ShouldProcess('AuvikModuleApiKey')) {
                    Remove-Variable -Name "AuvikModuleApiKey" -Scope global -Force
                }
            }
            $false  { Write-Warning "The Auvik API [ API ] key is not set. Nothing to remove" }
        }

    }

    end {}

}