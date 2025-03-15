function Get-AuvikBaseURI {
<#
    .SYNOPSIS
        Shows the Auvik base URI global variable

    .DESCRIPTION
        The Get-AuvikBaseURI cmdlet shows the Auvik base URI global variable value

    .EXAMPLE
        Get-AuvikBaseURI

        Shows the Auvik base URI global variable value

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Internal/Get-AuvikBaseURI.html
#>

    [cmdletbinding(DefaultParameterSetName = 'Index')]
    Param ()

    begin {}

    process {

        switch ([bool]$AuvikModuleBaseURI) {
            $true   { $AuvikModuleBaseURI }
            $false  { Write-Warning "The Auvik base URI is not set. Run Add-AuvikBaseURI to set the base URI." }
        }

    }

    end {}

}