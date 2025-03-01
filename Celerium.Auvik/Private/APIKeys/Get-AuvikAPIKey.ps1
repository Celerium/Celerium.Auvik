function Get-AuvikAPIKey {
<#
    .SYNOPSIS
        Gets the Auvik API username & API key global variables

    .DESCRIPTION
        The Get-AuvikAPIKey cmdlet gets the Auvik API username & API key
        global variables and returns them as an object

    .PARAMETER AsPlainText
        Decrypt and return the API key in plain text

    .EXAMPLE
        Get-AuvikAPIKey

        Gets the Auvik API username & API key global variables and returns them as an object
        with the secret key as a SecureString

    .EXAMPLE
        Get-AuvikAPIKey -AsPlainText

        Gets the Auvik API username & API key global variables and returns them as an object
        with the secret key as plain text

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Internal/Get-AuvikAPIKey.html
#>

    [cmdletbinding()]
    Param (
        [Parameter(Mandatory = $false)]
        [Switch]$AsPlainText
    )

    begin {}

    process {

        try {

            if ($AuvikApiKey) {

                if ($AsPlainText) {
                    $ApiKey = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($AuvikApiKey)

                    [PSCustomObject]@{
                        UserName    = $AuvikUserName
                        APIKey      = ( [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($ApiKey) ).ToString()
                    }
                }
                else {
                    [PSCustomObject]@{
                        UserName    = $AuvikUserName
                        APIKey      = $AuvikApiKey
                    }
                }

            }
            else { Write-Warning "The Auvik API [ API ] key is not set. Run Add-AuvikAPIKey to set the API key." }

        }
        catch {
            Write-Error $_
        }
        finally {
            if ($ApiKey) {
                [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ApiKey)
            }
        }


    }

    end {}

}
