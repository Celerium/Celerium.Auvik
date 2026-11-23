#Requires -Version 5.1

<#
.SYNOPSIS
    Connects the Celerium.Auvik module to the Auvik API & verifies the connection

.DESCRIPTION
    The Connect-AuvikExample.ps1 script shows the different ways of configuring the Celerium.Auvik module:

        1. Credentials from parameters, environment variables, or interactive prompts
        2. The Auvik data center (region) or a custom base URI
        3. Verifying the credentials with Get-AuvikAuthenticationVerify
        4. Optionally saving the settings with Export-AuvikModuleSetting

    The API username is the email address of an Auvik user & the API key is generated in the Auvik portal.
    Credentials are looked up in the following order:

        - The -Username & -ApiKeySecureString parameters
        - The AUVIK_USERNAME & AUVIK_API_KEY environment variables
        - An interactive prompt (the API key is entered as a secure string)

    The AUVIK_BASE_URI, AUVIK_USERNAME, & AUVIK_API_KEY environment variables are also read by the module
    when it is imported & take priority over saved settings, so no script is needed when they are set.

    This example only makes a single read-only request to the /authentication/verify endpoint
    It works on Windows PowerShell 5.1 & PowerShell 7+ on Windows, Linux, & macOS

.PARAMETER Username
    The email address of the Auvik user that owns the API key

    Default value: the AUVIK_USERNAME environment variable, otherwise a prompt

.PARAMETER ApiKeySecureString
    The Auvik API key as a SecureString

    Default value: the AUVIK_API_KEY environment variable, otherwise a prompt

.PARAMETER DataCenter
    The Auvik data center the account lives in (the region part of the URL used to sign in to Auvik)

    Allowed values:
        'au1', 'ca1', 'eu', 'eu1', 'eu2', 'us', 'us1', 'us2', 'us3', 'us4', 'us5', 'us6'

    A 308 (Permanent Redirect) response from the API means that the wrong data center is used

.PARAMETER BaseUri
    A custom base URI such as an API gateway or proxy

    Ignored when the DataCenter parameter is used
    Default value: the AUVIK_BASE_URI environment variable, otherwise the module default (us1)

.PARAMETER SaveSettings
    Saves the settings with Export-AuvikModuleSetting after the credentials are verified

    The API key is stored as an encrypted string (Windows DPAPI) that can only be read by the same user
    on the same computer. On Linux & macOS the key is only obfuscated, so a secret store is recommended instead

    Supports -WhatIf

.EXAMPLE
    ./Connect-AuvikExample.ps1 -Username 'user@example.com' -DataCenter us2

    Prompts for the API key, connects to the US2 data center, & verifies the credentials

.EXAMPLE
    $env:AUVIK_USERNAME = 'user@example.com'
    $env:AUVIK_API_KEY  = Read-Host 'Auvik API key'
    ./Connect-AuvikExample.ps1 -DataCenter eu1

    Uses the credentials from the environment variables & connects to the EU1 data center

.EXAMPLE
    ./Connect-AuvikExample.ps1 -Username 'user@example.com' -SaveSettings -WhatIf

    Shows what would be exported without writing the settings file

.NOTES
    Never store an API key in a script or commit it to a repository

.LINK
    https://celerium.github.io/Celerium.Auvik/

.LINK
    https://support.auvik.com/hc/en-us/articles/360031007111-Auvik-API-Integration-Guide
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $false)]
    [string]$Username = $env:AUVIK_USERNAME,

    [Parameter(Mandatory = $false)]
    [securestring]$ApiKeySecureString,

    [Parameter(Mandatory = $false)]
    [ValidateSet('au1', 'ca1', 'eu', 'eu1', 'eu2', 'us', 'us1', 'us2', 'us3', 'us4', 'us5', 'us6')]
    [string]$DataCenter,

    [Parameter(Mandatory = $false)]
    [string]$BaseUri = $env:AUVIK_BASE_URI,

    [Parameter(Mandatory = $false)]
    [switch]$SaveSettings
)

# Import the module by name. To use a local copy of the repository instead run something like:
# Import-Module -Name 'C:\Path\To\Celerium.Auvik\Celerium.Auvik\Celerium.Auvik.psd1' -Force
if (-not (Get-Module -Name Celerium.Auvik)) { Import-Module -Name Celerium.Auvik -ErrorAction Stop }

# Base URI (data center)
if ($DataCenter) { Add-AuvikBaseURI -DataCenter $DataCenter }
elseif ($BaseUri) { Add-AuvikBaseURI -BaseUri $BaseUri }
else { Add-AuvikBaseURI }

# Credentials
if (-not $Username) { $Username = Read-Host -Prompt 'Auvik API username (email address)' }

if ($ApiKeySecureString) { Add-AuvikAPIKey -Username $Username -ApiKeySecureString $ApiKeySecureString }
elseif ($env:AUVIK_API_KEY) { Add-AuvikAPIKey -Username $Username -ApiKey $env:AUVIK_API_KEY }
else { Add-AuvikAPIKey -Username $Username -ApiKeySecureString (Read-Host -Prompt 'Auvik API key' -AsSecureString) }

# Get-AuvikAuthenticationVerify returns $true when the credentials are valid & $false when they are not
$Verified = Get-AuvikAuthenticationVerify

if (-not $Verified) {
    throw "The Auvik credentials for [ $Username ] could not be verified against [ $(Get-AuvikBaseURI) ]. Check the username, the API key, & that the correct data center is used."
}

if ($SaveSettings) { Export-AuvikModuleSetting -WhatIf:$WhatIfPreference }

[PSCustomObject]@{
    Username        = $Username
    BaseUri         = Get-AuvikBaseURI
    Verified        = $Verified
    SettingsSaved   = [bool]($SaveSettings -and -not $WhatIfPreference)
}
