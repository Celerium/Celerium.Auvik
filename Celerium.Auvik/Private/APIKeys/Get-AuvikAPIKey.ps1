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

    [cmdletbinding(DefaultParameterSetName = 'Index')]
    Param (
        [Parameter(Mandatory = $false)]
        [Switch]$AsPlainText
    )

    begin {}

    process {

        try {

            if ($AuvikModuleApiKey) {

                if ($AsPlainText) {
                    $ApiKey = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($AuvikModuleApiKey)

                    [PSCustomObject]@{
                        UserName    = $AuvikModuleUserName
                        ApiKey      = ( [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ApiKey) ).ToString()
                    }
                }
                else {
                    [PSCustomObject]@{
                        UserName    = $AuvikModuleUserName
                        ApiKey      = $AuvikModuleApiKey
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
