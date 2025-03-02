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

    .PARAMETER EncryptedStandardAPIKeyPath
        Path to the AES standard encrypted API key file

    .PARAMETER EncryptedStandardAESKeyPath
        Path to the AES key file

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

    [cmdletbinding(DefaultParameterSetName = 'PlainText')]
    [alias('Set-AuvikAPIKey')]
    Param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'PlainText')]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'SecureString')]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'AESEncrypted')]
        [ValidateNotNullOrEmpty()]
        [string]$Username,

        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = 'PlainText')]
        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = 'SecureString')]
        [ValidateNotNullOrEmpty()]
        [securestring]$ApiKeySecureString,

        [Parameter(Mandatory = $false, ParameterSetName = 'AESEncrypted')]
        [ValidateScript({
            if (Test-Path $_) { $true }
            else { throw "The file provided does not exist - [  $_  ]" }
        })]
        [string]$EncryptedStandardAPIKeyPath,

        [Parameter(Mandatory = $true, ParameterSetName = 'AESEncrypted')]
        [ValidateScript({
            if (Test-Path $_) { $true }
            else { throw "The file provided does not exist - [  $_  ]" }
        })]
        [string]$EncryptedStandardAESKeyPath
    )

    begin {}

    process {

        Set-Variable -Name "AuvikUserName" -Value $Username -Option ReadOnly -Scope global -Force

        switch ($PSCmdlet.ParameterSetName) {

            'PlainText' {

                if ($ApiKey) {
                    $SecureString = ConvertTo-SecureString $ApiKey -AsPlainText -Force

                    Set-Variable -Name "AuvikApiKey" -Value $SecureString -Option ReadOnly -Scope global -Force
                }
                else {
                    Write-Output "Please enter your API key:"
                    $SecureString = Read-Host -AsSecureString

                    Set-Variable -Name "AuvikApiKey" -Value $SecureString -Option ReadOnly -Scope global -Force
                }

            }

            'SecureString' { Set-Variable -Name "AuvikApiKey" -Value $ApiKeySecureString -Option ReadOnly -Scope global -Force }

            'AESEncrypted' {

                $SecureString =  Get-Content $EncryptedStandardAPIKeyPath | ConvertTo-SecureString -Key $(Get-Content $EncryptedStandardAESKeyPath )

                Set-Variable -Name "AuvikApiKey" -Value $SecureString -Option ReadOnly -Scope global -Force

            }

        }

    }

    end {}
}
