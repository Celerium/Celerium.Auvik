function Add-AuvikAPIKey {
<#
    .SYNOPSIS
        Sets the API username and API key used to authenticate API calls

    .DESCRIPTION
        The Add-AuvikAPIKey cmdlet sets the API username and API key used to
        authenticate all API calls made to Auvik

        The Auvik API username & API keys are generated via the Auvik portal at Admin > Integrations

        The Auvik API uses basic authentication where the username is the email address of the
        Auvik user & the password is the API key

    .PARAMETER Username
        Defines your API username

    .PARAMETER ApiKey
        Plain text API key

        If not defined the cmdlet will prompt you to enter the API key which
        will be stored as a SecureString

    .PARAMETER ApiKeySecureString
        Input a SecureString object containing the API key

    .EXAMPLE
        Add-AuvikAPIKey -Username 'Celerium@Celerium.org'

        The Auvik API will use the string entered into the [ -Username ] parameter as the
        username & will then prompt to enter in the API key

    .EXAMPLE
        Add-AuvikAPIKey -Username 'Celerium@Celerium.org' -ApiKey '12345'

        The Auvik API will use the strings entered into the [ -Username ] & [ -ApiKey ] parameters
        to authenticate

    .EXAMPLE
        Add-AuvikAPIKey -Username 'Celerium@Celerium.org' -ApiKeySecureString (Read-Host -AsSecureString)

        The Auvik API will use the string entered into the [ -Username ] parameter as the
        username & the SecureString as the API key

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Internal/Add-AuvikAPIKey.html
#>

    [CmdletBinding(DefaultParameterSetName = 'AsPlainText')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'AsPlainText')]
        [Parameter(Mandatory = $true, ParameterSetName = 'SecureString')]
        [ValidateNotNullOrEmpty()]
        [string]$Username,

        [Parameter(Mandatory = $false, ParameterSetName = 'AsPlainText')]
        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [Parameter(Mandatory = $false, ParameterSetName = 'SecureString')]
        [ValidateNotNullOrEmpty()]
        [securestring]$ApiKeySecureString
    )

    begin {}

    process {

        Set-Variable -Name 'AuvikModuleUserName' -Value $Username -Option ReadOnly -Scope Global -Force

        switch ($PSCmdlet.ParameterSetName) {

            'AsPlainText' {

                if ($ApiKey) {
                    $SecureString = ConvertTo-SecureString -String $ApiKey -AsPlainText -Force
                }
                else {
                    Write-Output 'Please enter your API key:'
                    $SecureString = Read-Host -AsSecureString
                }

                Set-Variable -Name 'AuvikModuleApiKey' -Value $SecureString -Option ReadOnly -Scope Global -Force

            }

            'SecureString' { Set-Variable -Name 'AuvikModuleApiKey' -Value $ApiKeySecureString -Option ReadOnly -Scope Global -Force }

        }

    }

    end {}

}

Set-Alias -Name 'Set-AuvikAPIKey' -Value 'Add-AuvikAPIKey'
