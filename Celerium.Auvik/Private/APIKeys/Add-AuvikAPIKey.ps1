function Add-AuvikAPIKey {
<#
    .SYNOPSIS
        Sets the API username and API key used to authenticate API calls

    .DESCRIPTION
        The Add-AuvikAPIKey cmdlet sets the API username and API key used to
        authenticate all API calls made to Auvik

        The Auvik API username & API keys are generated via the Auvik portal at Admin > Integrations

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
        username & will then prompt to enter in the secret key

    .EXAMPLE
        'Celerium@Celerium.org' | Add-AuvikAPIKey

        The Auvik API will use the string entered as the secret key & will prompt to enter in the public key

    .EXAMPLE
        Add-AuvikAPIKey -EncryptedStandardAPIKeyFilePath 'C:\path\to\encrypted\key.txt' -EncryptedStandardAESKeyPath 'C:\path\to\decipher\key.txt'

        Decrypts the AES API key and stores it in the global variable

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Internal/Add-AuvikAPIKey.html
#>

    [cmdletbinding(DefaultParameterSetName = 'AsPlainText')]
    [alias('Set-AuvikAPIKey')]
    Param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'AsPlainText')]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'SecureString')]
        [ValidateNotNullOrEmpty()]
        [string]$Username,

        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = 'AsPlainText')]
        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = 'SecureString')]
        [ValidateNotNullOrEmpty()]
        [securestring]$ApiKeySecureString
    )

    begin {}

    process {

        Set-Variable -Name "AuvikModuleUserName" -Value $Username -Option ReadOnly -Scope global -Force

        switch ($PSCmdlet.ParameterSetName) {

            'AsPlainText' {

                if ($ApiKey) {
                    $SecureString = ConvertTo-SecureString $ApiKey -AsPlainText -Force

                    Set-Variable -Name "AuvikModuleApiKey" -Value $SecureString -Option ReadOnly -Scope global -Force
                }
                else {
                    Write-Output "Please enter your API key:"
                    $SecureString = Read-Host -AsSecureString

                    Set-Variable -Name "AuvikModuleApiKey" -Value $SecureString -Option ReadOnly -Scope global -Force
                }

            }

            'SecureString' { Set-Variable -Name "AuvikModuleApiKey" -Value $ApiKeySecureString -Option ReadOnly -Scope global -Force }

        }

    }

    end {}
}
