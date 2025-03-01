#Region '.\Private\APICalls\ConvertTo-AuvikQueryString.ps1' -1

function ConvertTo-AuvikQueryString {
<#
    .SYNOPSIS
        Converts uri filter parameters

    .DESCRIPTION
        The ConvertTo-AuvikQueryString cmdlet converts & formats uri filter parameters
        from a function which are later used to make the full resource uri for
        an API call

        This is an internal helper function the ties in directly with the
        ConvertTo-AuvikQueryString & any public functions that define parameters

    .PARAMETER UriFilter
        Hashtable of values to combine a functions parameters with
        the ResourceUri parameter.

        This allows for the full uri query to occur

    .PARAMETER ResourceUri
        Defines the short resource uri (url) to use when creating the API call

    .EXAMPLE
        ConvertTo-AuvikQueryString -UriFilter $UriFilter -ResourceUri '/account'

        Example: (From public function)
            $UriFilter = @{}

            ForEach ( $Key in $PSBoundParameters.GetEnumerator() ) {
                if( $excludedParameters -contains $Key.Key ) {$null}
                else{ $UriFilter += @{ $Key.Key = $Key.Value } }
            }

            1x key = https://auvikapi.us1.my.auvik.com/v1/account?accountId=12345
            2x key = https://auvikapi.us1.my.auvik.com/v1/account?accountId=12345&Details=True

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Internal/ConvertTo-AuvikQueryString.html

#>

[CmdletBinding(DefaultParameterSetName = 'ConvertToQueryString')]
param(
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [hashtable]$UriFilter,

    [Parameter(Mandatory = $true)]
    [String]$ResourceUri
)

    begin {}

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $QueryString = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        if ($UriFilter) {

            ForEach ( $Key in $UriFilter.GetEnumerator() ) {

                if ( $Key.Value.GetType().IsArray ) {

                    Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - [ $($Key.Key) ] is an array parameter"

                    foreach ($Value in $Key.Value) {
                        $QueryString.Add($Key.Key, $Value)
                    }

                }
                elseif ( $Key.Value.GetType().FullName -eq 'System.DateTime' ) {

                    Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - [ $($Key.Key) ] is a dateTime parameter"

                    if ($Key.Key -like "*fromDate*" -or $Key.Key -like "*thruDate*" ) {
                        $universalTime = ($Key.Value).ToUniversalTime().ToString('yyyy-MM-dd')
                    }
                    else{
                        $universalTime = ($Key.Value).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
                    }

                    Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Converting [ $($Key.Value) ] to [ $universalTime ]"
                    $QueryString.Add($Key.Key, $universalTime)

                }
                else{ $QueryString.Add($Key.Key, $Key.Value) }

            }

        }

        # Build the request and load it with the query string.
        $UriRequest        = [System.UriBuilder]($AuvikModuleBaseURI + $ResourceUri)
        $UriRequest.Query  = $QueryString.ToString()

        return $UriRequest

    }

    end {}

}
#EndRegion '.\Private\APICalls\ConvertTo-AuvikQueryString.ps1' 107
#Region '.\Private\APICalls\Get-AuvikMetaData.ps1' -1

function Get-AuvikMetaData {
<#
    .SYNOPSIS
        Gets various Api metadata values

    .DESCRIPTION
        The Get-AuvikMetaData cmdlet gets various Api metadata values from an
        Invoke-WebRequest to assist in various troubleshooting scenarios such
        as rate-limiting.

    .PARAMETER BaseUri
        Define the base URI for the Auvik API connection using Auvik's URI or a custom URI.

        The default base URI is https://auvikapi.us1.my.auvik.com/v1

    .EXAMPLE
        Get-AuvikMetaData

        Gets various Api metadata values from an Invoke-WebRequest to assist
        in various troubleshooting scenarios such as rate-limiting.

        The default full base uri test path is:
            https://auvikapi.us1.my.auvik.com/v1

    .EXAMPLE
        Get-AuvikMetaData -BaseUri http://myapi.gateway.celerium.org

        Gets various Api metadata values from an Invoke-WebRequest to assist
        in various troubleshooting scenarios such as rate-limiting.

        The full base uri test path in this example is:
            http://myapi.gateway.celerium.org/device

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Internal/Get-AuvikMetaData.html
#>

    [CmdletBinding()]
    Param (
        [parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$BaseUri = $AuvikModuleBaseURI
    )

    begin { $ResourceUri = "/authentication/verify" }

    process {

        try {

            $ApiToken = Get-AuvikAPIKey -AsPlainText
            $ApiTokenBase64 = [Convert]::ToBase64String( [Text.Encoding]::ASCII.GetBytes( ("{0}:{1}" -f ($ApiToken).UserName,($ApiToken).APIKey) ) )

            $AuvikHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
            $AuvikHeaders.Add("Content-Type", 'application/json')
            $AuvikHeaders.Add('Authorization', 'Basic {0}'-f $ApiTokenBase64)

            $RestOutput = Invoke-WebRequest -Method Get -uri ($BaseUri + $ResourceUri) -headers $AuvikHeaders -ErrorAction Stop
        }
        catch {

            [PSCustomObject]@{
                Method              = $_.Exception.Response.Method
                StatusCode          = $_.Exception.Response.StatusCode.value__
                StatusDescription   = $_.Exception.Response.StatusDescription
                Message             = $_.Exception.Message
                URI                 = $($AuvikModuleBaseURI + $ResourceUri)
            }

        }
        finally {
            Remove-Variable -Name AuvikHeaders -Force
        }

        if ($RestOutput) {
            $Data = @{}
            $Data = $RestOutput

            [PSCustomObject]@{
                ResponseUri             = $Data.BaseResponse.ResponseUri.AbsoluteUri
                ResponsePort            = $Data.BaseResponse.ResponseUri.Port
                StatusCode              = $Data.StatusCode
                StatusDescription       = $Data.StatusDescription
                raw                     = $Data
            }
        }

    }

    end {}
}
#EndRegion '.\Private\APICalls\Get-AuvikMetaData.ps1' 94
#Region '.\Private\APICalls\Invoke-AuvikRequest.ps1' -1

function Invoke-AuvikRequest {
<#
    .SYNOPSIS
        Makes an API request

    .DESCRIPTION
        The Invoke-AuvikRequest cmdlet invokes an API request to Auvik API.

        This is an internal function that is used by all public functions

        As of 2023-08 the Auvik v1 API only supports GET requests

    .PARAMETER method
        Defines the type of API method to use

        Allowed values:
        'GET'

    .PARAMETER ResourceUri
        Defines the resource uri (url) to use when creating the API call

    .PARAMETER UriFilter
        Used with the internal function [ ConvertTo-AuvikQueryString ] to combine
        a functions parameters with the ResourceUri parameter.

        This allows for the full uri query to occur

        The full resource path is made with the following data
        $AuvikModuleBaseURI + $ResourceUri + ConvertTo-AuvikQueryString

    .PARAMETER data
        Place holder parameter to use when other methods are supported
        by the Auvik v1 API

    .PARAMETER AllResults
        Returns all items from an endpoint

        When using this parameter there is no need to use either the page or perPage
        parameters

    .EXAMPLE
        Invoke-AuvikRequest -Method GET -ResourceUri '/account' -UriFilter $UriFilter

        Invoke a rest method against the defined resource using any of the provided parameters

        Example:
            Name                           Value
            ----                           -----
            Method                         GET
            Uri                            https://auvikapi.us1.my.auvik.com/v1/account?accountId=12345&Details=True
            Headers                        {Authorization = Bearer 123456789}
            Body


    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Internal/Invoke-AuvikRequest.html

#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateSet('GET', 'POST')]
        [String]$Method = 'GET',

        [Parameter(Mandatory = $true)]
        [String]$ResourceUri,

        [Parameter(Mandatory = $false)]
        [Hashtable]$UriFilter = $null,

        [Parameter(Mandatory = $false)]
        [Hashtable]$Data = $null,

        [Parameter(Mandatory = $false)]
        [Switch]$AllResults

    )

    begin {

        # Load Web assembly when needed as PowerShell Core has the assembly preloaded
        if ( !("System.Web.HttpUtility" -as [Type]) ) {
            Add-Type -Assembly System.Web
        }

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = $functionName + '_Parameters'      -replace '-','_'
        $QueryParameterName = $functionName + '_ParametersQuery' -replace '-','_'

    }

    process {

        $QueryString = ConvertTo-AuvikQueryString -UriFilter $UriFilter -ResourceUri $ResourceUri

        Set-Variable -Name $QueryParameterName -Value $QueryString -Scope Global -Force

        if ($null -eq $Data) {
            $body = $null
        } else {
            $body = @{'data'= $Data} | ConvertTo-Json -Depth $AuvikJSONConversionDepth
        }

        try {
            $ApiToken = Get-AuvikAPIKey -AsPlainText
            $ApiTokenBase64 = [Convert]::ToBase64String( [Text.Encoding]::ASCII.GetBytes( ("{0}:{1}" -f ($ApiToken).UserName,($ApiToken).APIKey) ) )

            $Parameters = [ordered] @{
                "Method"    = $Method
                "Uri"       = $QueryString.Uri
                "Headers"   = @{ 'Authorization' = 'Basic {0}'-f $ApiTokenBase64 }
                "Body"      = $body
            }

                if ( $Method -ne 'GET' ) {
                    $Parameters['ContentType'] = 'application/vnd.api+json; charset=utf-8'
                }

            Set-Variable -Name $ParameterName -Value $Parameters -Scope Global -Force

            if ($AllResults) {

                Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Gathering all items from [ $( $Parameters.uri.LocalPath ) ] "

                $PageNumber = 1
                $AllResponseData = [System.Collections.Generic.List[object]]::new()

                do {

                    $CurrentPage = Invoke-RestMethod @Parameters -ErrorAction Stop

                    Write-Verbose "[ $PageNumber ] of [ $($CurrentPage.meta.totalPages) ] pages"

                        foreach ($item in $CurrentPage.data) {
                            $AllResponseData.add($item)
                        }

                    $Parameters.Remove('Uri') > $null
                    $Parameters.Add('Uri',$CurrentPage.links.next)

                    $PageNumber++

                } while ( $null -ne $CurrentPage.links.next <#-and $CurrentPage.meta.totalPages -ne 0#> )

            }
            else{
                Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Gathering items from [ $( $Parameters.uri.LocalPath ) ] "

                $ApiResponse = Invoke-RestMethod @Parameters -ErrorAction Stop
            }

        }
        catch {

            $exceptionError = $_.Exception.Message
            Write-Warning 'The [ Invoke_AuvikRequest_Parameters, Invoke_AuvikRequest_ParametersQuery, & CmdletName_Parameters ] variables can provide extra details'

            switch -Wildcard ($exceptionError) {
                '*308*' { Write-Error "Invoke-AuvikRequest : Permanent Redirect, check assigned region" }
                '*404*' { Write-Error "Invoke-AuvikRequest : Uri not found - [ $ResourceUri ]" }
                '*429*' { Write-Error 'Invoke-AuvikRequest : API rate limited' }
                '*504*' { Write-Error "Invoke-AuvikRequest : Gateway Timeout" }
                default { Write-Error $_ }
            }

        }
        finally {

            $Auth = $Invoke_AuvikRequest_Parameters['headers']['Authorization']
            $Invoke_AuvikRequest_Parameters['headers']['Authorization'] = $Auth.Substring( 0, [Math]::Min($Auth.Length, 9) ) + '*******'

        }


        if($AllResults) {

            #Making output consistent
            if( [string]::IsNullOrEmpty($AllResponseData.data) ) {
                $ApiResponse = $null
            }
            else{
                $ApiResponse = [PSCustomObject]@{
                    data    = $AllResponseData
                    links   = $null
                    meta    = $null
                }
            }

            return $ApiResponse

        }
        else{ return $ApiResponse }

    }

    end {}

}
#EndRegion '.\Private\APICalls\Invoke-AuvikRequest.ps1' 203
#Region '.\Private\APIKeys\Add-AuvikAPIKey.ps1' -1

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

        The Auvik API will use the string entered as the secret key & will prompt to enter in the public key.

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
#EndRegion '.\Private\APIKeys\Add-AuvikAPIKey.ps1' 125
#Region '.\Private\APIKeys\Get-AuvikAPIKey.ps1' -1

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
#EndRegion '.\Private\APIKeys\Get-AuvikAPIKey.ps1' 80
#Region '.\Private\APIKeys\New-AuvikAESSecret.ps1' -1

function New-AuvikAESSecret {
<#
    .SYNOPSIS
        Creates a AES encrypted API key and decipher key

    .DESCRIPTION
        The New-AuvikAESSecret cmdlet creates a AES encrypted API key and decipher key

        This allows the key to be exported for use on other systems without
        relying on Windows DPAPI

        Do NOT share the decipher key with anyone as this will allow them to decrypt
        the encrypted API key

    .PARAMETER KeyLength
        The length of the AES key to generate

        By default a 256-bit key (32) is generated

        Allowed values:
        16, 24, 32

    .PARAMETER Path
        The path to save the encrypted API key and decipher key

        By default keys are only stored in memory

    .EXAMPLE
        New-AuvikAESSecret

        Prompts to enter in the API key which will be encrypted using a randomly generated 256-bit AES key


    .NOTES
        N/A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Internal/New-AuvikAESSecret.html

    .LINK
        https://github.com/Celerium/Celerium.Auvik

#>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    [Alias('Set-AuvikAPIKey')]
    Param (
        [Parameter(Mandatory = $false)]
        [ValidateSet(16, 24, 32)]
        [int]$KeyLength = 32,

        [Parameter(Mandatory = $false)]
        [string]$Path = $(Get-Location).Path
    )

    begin {}

    process{

        $AESKey = Get-Random -Count $KeyLength -InputObject (0..255)

        Write-Output "Please enter your API key:"
        $SecureString = Read-Host -AsSecureString

        $EncryptedStandardString    = ConvertFrom-SecureString -SecureString $SecureString -Key $AESKey
        $AESSecuredKey              = $EncryptedStandardString | ConvertTo-SecureString -Key $AESKey

        if ($Path) {
            $AESKey                     | Out-File -FilePath $(Join-Path -Path $Path -ChildPath AESKey) -Encoding utf8
            $EncryptedStandardString    | Out-File -FilePath $(Join-Path -Path $Path -ChildPath EncryptedAPIKey) -Encoding utf8

            Write-Warning "Store the AES key in a secure location that only authorized personnel have access to!"

            Write-Output "Files saved to [ $Path ]"

        }
        else {
            [PSCustomObject]@{
                AESKey              = $AESKey
                AESStandardString   = $EncryptedStandardString
                AESSecureString     = $AESSecuredKey
            }
        }

    }

    end {}

}
#EndRegion '.\Private\APIKeys\New-AuvikAESSecret.ps1' 90
#Region '.\Private\APIKeys\Remove-AuvikAPIKey.ps1' -1

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
#EndRegion '.\Private\APIKeys\Remove-AuvikAPIKey.ps1' 51
#Region '.\Private\BaseUri\Add-AuvikBaseURI.ps1' -1

function Add-AuvikBaseURI {
<#
    .SYNOPSIS
        Sets the base URI for the Auvik API connection.

    .DESCRIPTION
        The Add-AuvikBaseURI cmdlet sets the base URI which is later used
        to construct the full URI for all API calls.

    .PARAMETER BaseUri
        Define the base URI for the Auvik API connection using Auvik's URI or a custom URI.

    .PARAMETER DataCenter
        Auvik's URI connection point that can be one of the predefined data centers.

        https://support.auvik.com/hc/en-us/articles/360033412992

        Accepted Values:
        'au1', 'ca1', 'eu', 'eu1', 'eu2', 'us', 'us1', 'us2', 'us3', 'us4', 'us5', 'us6'

        Example:
            us3 = https://auvikapi.us3.my.auvik.com/v1

    .EXAMPLE
        Add-AuvikBaseURI

        The base URI will use https://auvikapi.us1.my.auvik.com/v1 which is Auvik's default URI.

    .EXAMPLE
        Add-AuvikBaseURI -DataCenter US

        The base URI will use https://auvikapi.us1.my.auvik.com/v1 which is Auvik's US URI.

    .EXAMPLE
        Add-AuvikBaseURI -BaseUri http://myapi.gateway.celerium.org

        A custom API gateway of http://myapi.gateway.celerium.org will be used for all API calls to Auvik's API.

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Internal/Add-AuvikBaseURI.html
#>

    [cmdletbinding()]
    [alias('Set-AuvikBaseURI')]
    Param (
        [Parameter(Mandatory = $false , ValueFromPipeline = $true)]
        [string]$BaseUri = 'https://auvikapi.us1.my.auvik.com/v1',

        [Parameter(Mandatory = $false)]
        [ValidateSet( 'au1', 'ca1', 'eu', 'eu1', 'eu2', 'us', 'us1', 'us2', 'us3', 'us4', 'us5', 'us6' )]
        [String]$DataCenter
    )

    begin {}

    process {

        if ($BaseUri[$BaseUri.Length-1] -eq "/") {
            $BaseUri = $BaseUri.Substring(0,$BaseUri.Length-1)
        }

        if ($DataCenter) {
            $BaseUri = "https://auvikapi.$DataCenter.my.auvik.com/v1"
        }

        Set-Variable -Name "AuvikModuleBaseURI" -Value $BaseUri -Option ReadOnly -Scope global -Force

    }

    end {}

}
#EndRegion '.\Private\BaseUri\Add-AuvikBaseURI.ps1' 76
#Region '.\Private\BaseUri\Get-AuvikBaseURI.ps1' -1

function Get-AuvikBaseURI {
<#
    .SYNOPSIS
        Shows the Auvik base URI global variable.

    .DESCRIPTION
        The Get-AuvikBaseURI cmdlet shows the Auvik base URI global variable value.

    .EXAMPLE
        Get-AuvikBaseURI

        Shows the Auvik base URI global variable value.

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Internal/Get-AuvikBaseURI.html
#>

    [cmdletbinding()]
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
#EndRegion '.\Private\BaseUri\Get-AuvikBaseURI.ps1' 38
#Region '.\Private\BaseUri\Remove-AuvikBaseURI.ps1' -1

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

    [cmdletbinding(SupportsShouldProcess, ConfirmImpact = 'None')]
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
#EndRegion '.\Private\BaseUri\Remove-AuvikBaseURI.ps1' 42
#Region '.\Private\ModuleSettings\Export-AuvikModuleSetting.ps1' -1

function Export-AuvikModuleSetting {
<#
    .SYNOPSIS
        Exports the Auvik BaseURI, API, & JSON configuration information to file.

    .DESCRIPTION
        The Export-AuvikModuleSetting cmdlet exports the Auvik BaseURI, API, & JSON configuration information to file.

        Making use of PowerShell's System.Security.SecureString type, exporting module settings encrypts your API key in a format
        that can only be unencrypted with the your Windows account as this encryption is tied to your user principal.
        This means that you cannot copy your configuration file to another computer or user account and expect it to work.

    .PARAMETER AuvikConfPath
        Define the location to store the Auvik configuration file.

        By default the configuration file is stored in the following location:
            $env:USERPROFILE\Celerium.Auvik

    .PARAMETER AuvikConfFile
        Define the name of the Auvik configuration file.

        By default the configuration file is named:
            config.psd1

    .EXAMPLE
        Export-AuvikModuleSetting

        Validates that the BaseURI, API, and JSON depth are set then exports their values
        to the current user's Auvik configuration file located at:
            $env:USERPROFILE\Celerium.Auvik\config.psd1

    .EXAMPLE
        Export-AuvikModuleSetting -AuvikConfPath C:\Celerium.Auvik -AuvikConfFile MyConfig.psd1

        Validates that the BaseURI, API, and JSON depth are set then exports their values
        to the current user's Auvik configuration file located at:
            C:\Celerium.Auvik\MyConfig.psd1

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Internal/Export-AuvikModuleSetting.html
#>

    [CmdletBinding(DefaultParameterSetName = 'Set')]
    Param (
        [Parameter(ParameterSetName = 'Set')]
        [string]$AuvikConfPath = $(Join-Path -Path $home -ChildPath $(if ($IsWindows -or $PSEdition -eq 'Desktop') {"Celerium.Auvik"}else{".Celerium.Auvik"}) ),

        [Parameter(ParameterSetName = 'Set')]
        [string]$AuvikConfFile = 'config.psd1'
    )

    begin {}

    process {

        Write-Warning "Secrets are stored using Windows Data Protection API (DPAPI)"
        Write-Warning "DPAPI provides user context encryption in Windows but NOT in other operating systems like Linux or UNIX. It is recommended to use a more secure & cross-platform storage method"

        $AuvikConfig = Join-Path -Path $AuvikConfPath -ChildPath $AuvikConfFile

        # Confirm variables exist and are not null before exporting
        if ($AuvikModuleBaseURI -and $AuvikUserName -and $AuvikApiKey -and $AuvikJSONConversionDepth) {
            $secureString = $AuvikApiKey | ConvertFrom-SecureString

            if ($IsWindows -or $PSEdition -eq 'Desktop') {
                New-Item -Path $AuvikConfPath -ItemType Directory -Force | ForEach-Object { $_.Attributes = $_.Attributes -bor "Hidden" }
            }
            else{
                New-Item -Path $AuvikConfPath -ItemType Directory -Force
            }
@"
    @{
        AuvikModuleBaseURI = '$AuvikModuleBaseURI'
        AuvikUserName = '$AuvikUserName'
        AuvikApiKey = '$secureString'
        AuvikJSONConversionDepth = '$AuvikJSONConversionDepth'
    }
"@ | Out-File -FilePath $AuvikConfig -Force
        }
        else {
            Write-Error "Failed to export Auvik Module settings to [ $AuvikConfig ]"
            Write-Error $_
            exit 1
        }

    }

    end {}

}
#EndRegion '.\Private\ModuleSettings\Export-AuvikModuleSetting.ps1' 94
#Region '.\Private\ModuleSettings\Get-AuvikModuleSetting.ps1' -1

function Get-AuvikModuleSetting {
<#
    .SYNOPSIS
        Gets the saved Auvik configuration settings

    .DESCRIPTION
        The Get-AuvikModuleSetting cmdlet gets the saved Auvik configuration settings
        from the local system.

        By default the configuration file is stored in the following location:
            $env:USERPROFILE\Celerium.Auvik

    .PARAMETER AuvikConfPath
        Define the location to store the Auvik configuration file.

        By default the configuration file is stored in the following location:
            $env:USERPROFILE\Celerium.Auvik

    .PARAMETER AuvikConfFile
        Define the name of the Auvik configuration file.

        By default the configuration file is named:
            config.psd1

    .PARAMETER openConfFile
        Opens the Auvik configuration file

    .EXAMPLE
        Get-AuvikModuleSetting

        Gets the contents of the configuration file that was created with the
        Export-AuvikModuleSetting

        The default location of the Auvik configuration file is:
            $env:USERPROFILE\Celerium.Auvik\config.psd1

    .EXAMPLE
        Get-AuvikModuleSetting -AuvikConfPath C:\Celerium.Auvik -AuvikConfFile MyConfig.psd1 -openConfFile

        Opens the configuration file from the defined location in the default editor

        The location of the Auvik configuration file in this example is:
            C:\Celerium.Auvik\MyConfig.psd1

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Internal/Get-AuvikModuleSetting.html
#>

    [CmdletBinding(DefaultParameterSetName = 'Index')]
    Param (
        [Parameter(Mandatory = $false, ParameterSetName = 'Index')]
        [string]$AuvikConfPath = $(Join-Path -Path $home -ChildPath $(if ($IsWindows -or $PSEdition -eq 'Desktop') {"Celerium.Auvik"}else{".Celerium.Auvik"}) ),

        [Parameter(Mandatory = $false, ParameterSetName = 'Index')]
        [String]$AuvikConfFile = 'config.psd1',

        [Parameter(Mandatory = $false, ParameterSetName = 'show')]
        [Switch]$openConfFile
    )

    begin {
        $AuvikConfig = Join-Path -Path $AuvikConfPath -ChildPath $AuvikConfFile
    }

    process {

        if ( Test-Path -Path $AuvikConfig ) {

            if($openConfFile) {
                Invoke-Item -Path $AuvikConfig
            }
            else{
                Import-LocalizedData -BaseDirectory $AuvikConfPath -FileName $AuvikConfFile
            }

        }
        else{
            Write-Verbose "No configuration file found at [ $AuvikConfig ]"
        }

    }

    end {}

}
#EndRegion '.\Private\ModuleSettings\Get-AuvikModuleSetting.ps1' 89
#Region '.\Private\ModuleSettings\Import-AuvikModuleSetting.ps1' -1

function Import-AuvikModuleSetting {
<#
    .SYNOPSIS
        Imports the Auvik BaseURI, API, & JSON configuration information to the current session.

    .DESCRIPTION
        The Import-AuvikModuleSetting cmdlet imports the Auvik BaseURI, API, & JSON configuration
        information stored in the Auvik configuration file to the users current session.

        By default the configuration file is stored in the following location:
            $env:USERPROFILE\Celerium.Auvik

    .PARAMETER AuvikConfPath
        Define the location to store the Auvik configuration file.

        By default the configuration file is stored in the following location:
            $env:USERPROFILE\Celerium.Auvik

    .PARAMETER AuvikConfFile
        Define the name of the Auvik configuration file.

        By default the configuration file is named:
            config.psd1

    .EXAMPLE
        Import-AuvikModuleSetting

        Validates that the configuration file created with the Export-AuvikModuleSetting cmdlet exists
        then imports the stored data into the current users session.

        The default location of the Auvik configuration file is:
            $env:USERPROFILE\Celerium.Auvik\config.psd1

    .EXAMPLE
        Import-AuvikModuleSetting -AuvikConfPath C:\Celerium.Auvik -AuvikConfFile MyConfig.psd1

        Validates that the configuration file created with the Export-AuvikModuleSetting cmdlet exists
        then imports the stored data into the current users session.

        The location of the Auvik configuration file in this example is:
            C:\Celerium.Auvik\MyConfig.psd1

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Internal/Import-AuvikModuleSetting.html
#>

    [CmdletBinding(DefaultParameterSetName = 'Set')]
    Param (
        [Parameter(ParameterSetName = 'Set')]
        [string]$AuvikConfPath = $(Join-Path -Path $home -ChildPath $(if ($IsWindows -or $PSEdition -eq 'Desktop') {"Celerium.Auvik"}else{".Celerium.Auvik"}) ),

        [Parameter(ParameterSetName = 'Set')]
        [string]$AuvikConfFile = 'config.psd1'
    )

    begin {
        $AuvikConfig = Join-Path -Path $AuvikConfPath -ChildPath $AuvikConfFile
    }

    process {

        if ( Test-Path $AuvikConfig ) {
            $TempConfig = Import-LocalizedData -BaseDirectory $AuvikConfPath -FileName $AuvikConfFile

            # Send to function to strip potentially superfluous slash (/)
            Add-AuvikBaseURI $TempConfig.AuvikModuleBaseURI

            $TempConfig.AuvikApiKey = ConvertTo-SecureString $TempConfig.AuvikApiKey

            Set-Variable -Name "AuvikUserName" -Value $TempConfig.AuvikUserName -Option ReadOnly -Scope global -Force

            Set-Variable -Name "AuvikApiKey" -Value $TempConfig.AuvikApiKey -Option ReadOnly -Scope global -Force

            Set-Variable -Name "AuvikJSONConversionDepth" -Value $TempConfig.AuvikJSONConversionDepth -Scope global -Force

            Write-Verbose "Celerium.Auvik Module configuration loaded successfully from [ $AuvikConfig ]"

            # Clean things up
            Remove-Variable "TempConfig"
        }
        else {
            Write-Verbose "No configuration file found at [ $AuvikConfig ] run Add-AuvikAPIKey to get started."

            Add-AuvikBaseURI

            Set-Variable -Name "AuvikModuleBaseURI" -Value $(Get-AuvikBaseURI) -Option ReadOnly -Scope global -Force
            Set-Variable -Name "AuvikJSONConversionDepth" -Value 100 -Scope global -Force
        }

    }

    end {}

}
#EndRegion '.\Private\ModuleSettings\Import-AuvikModuleSetting.ps1' 98
#Region '.\Private\ModuleSettings\Initialize-AuvikModuleSetting.ps1' -1

#Used to auto load either baseline settings or saved configurations when the module is imported
Import-AuvikModuleSetting -Verbose:$false
#EndRegion '.\Private\ModuleSettings\Initialize-AuvikModuleSetting.ps1' 3
#Region '.\Private\ModuleSettings\Remove-AuvikModuleSetting.ps1' -1

function Remove-AuvikModuleSetting {
<#
    .SYNOPSIS
        Removes the stored Auvik configuration folder

    .DESCRIPTION
        The Remove-AuvikModuleSetting cmdlet removes the Auvik folder and its files
        This cmdlet also has the option to remove sensitive Auvik variables as well

        By default configuration files are stored in the following location and will be removed:
            $env:USERPROFILE\Celerium.Auvik

    .PARAMETER AuvikConfPath
        Define the location of the Auvik configuration folder

        By default the configuration folder is located at:
            $env:USERPROFILE\Celerium.Auvik

    .PARAMETER andVariables
        Define if sensitive Auvik variables should be removed as well

        By default the variables are not removed

    .EXAMPLE
        Remove-AuvikModuleSetting

        Checks to see if the default configuration folder exists and removes it if it does

        The default location of the Auvik configuration folder is:
            $env:USERPROFILE\Celerium.Auvik

    .EXAMPLE
        Remove-AuvikModuleSetting -AuvikConfPath C:\Celerium.Auvik -andVariables

        Checks to see if the defined configuration folder exists and removes it if it does
        If sensitive Auvik variables exist then they are removed as well

        The location of the Auvik configuration folder in this example is:
            C:\Celerium.Auvik

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Internal/Remove-AuvikModuleSetting.html
#>

    [CmdletBinding(DefaultParameterSetName = 'Destroy', SupportsShouldProcess)]
    Param (
        [Parameter(ParameterSetName = 'Destroy')]
        [string]$AuvikConfPath = $(Join-Path -Path $home -ChildPath $(if ($IsWindows -or $PSEdition -eq 'Desktop') {"Celerium.Auvik"}else{".Celerium.Auvik"}) ),

        [Parameter(ParameterSetName = 'Destroy')]
        [switch]$andVariables
    )

    begin {}

    process {

        if (Test-Path $AuvikConfPath) {

            Remove-Item -Path $AuvikConfPath -Recurse -Force -WhatIf:$WhatIfPreference

            If ($andVariables) {
                Remove-AuvikAPIKey
                Remove-AuvikBaseURI
            }

            if (!(Test-Path $AuvikConfPath)) {
                Write-Output "The Celerium.Auvik configuration folder has been removed successfully from [ $AuvikConfPath ]"
            }
            else {
                Write-Error "The Celerium.Auvik configuration folder could not be removed from [ $AuvikConfPath ]"
            }

        }
        else {
            Write-Warning "No configuration folder found at [ $AuvikConfPath ]"
        }

    }

    end {}

}
#EndRegion '.\Private\ModuleSettings\Remove-AuvikModuleSetting.ps1' 87
#Region '.\Public\Alert\Clear-AuvikAlert.ps1' -1

function Clear-AuvikAlert {
<#
    .SYNOPSIS
        Clear an Auvik alert

    .DESCRIPTION
        The Clear-AuvikAlert cmdlet allows you to dismiss an
        alert that Auvik has triggered.

    .PARAMETER ID
        ID of alert

    .EXAMPLE
        Clear-AuvikAlert -ID 123456789

        Clears the defined alert

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Alert/Clear-AuvikAlert.html
#>

    [CmdletBinding(DefaultParameterSetName = 'ClearByAlert', SupportsShouldProcess, ConfirmImpact = 'Low')]
    Param (
        [Parameter( Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'ClearByAlert' )]
        [ValidateNotNullOrEmpty()]
        [string]$ID
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = $functionName + '_Parameters'      -replace '-','_'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = "/alert/dismiss/$ID"

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false

        return Invoke-AuvikRequest -Method POST -ResourceUri $ResourceUri

    }

    end {}

}
#EndRegion '.\Public\Alert\Clear-AuvikAlert.ps1' 54
#Region '.\Public\Alert\Get-AuvikAlert.ps1' -1

function Get-AuvikAlert {
<#
    .SYNOPSIS
        Get Auvik alert events that have been triggered by your Auvik collector(s).

    .DESCRIPTION
        The Get-AuvikAlert cmdlet allows you to view the alert events
        that has been triggered by your Auvik collector(s).

    .PARAMETER ID
        ID of alert

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from

    .PARAMETER FilterAlertDefinitionId
        Filter by alert definition ID

    .PARAMETER FilterSeverity
        Filter by alert severity

        Allowed values:
            "unknown", "emergency", "critical", "warning", "info"

    .PARAMETER FilterStatus
        Filter by the status of the alert

        Allowed values:
            "created", "resolved", "paused", "unpaused"

    .PARAMETER FilterEntityId
        Filter by the related entity ID

    .PARAMETER FilterDismissed
        Filter by the dismissed status

        As of 2023-10 this parameter does not appear to work

    .PARAMETER FilterDispatched
        Filter by dispatched status

        As of 2023-10 this parameter does not appear to work

    .PARAMETER FilterDetectedTimeAfter
        Filter by the time which is greater than the given timestamp

    .PARAMETER FilterDetectedTimeBefore
        Filter by the time which is less than or equal to the given timestamp

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned
        Used in combination with page[after]

        Default Value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page
        The page size is provided by page[first]

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned
        Used in combination with page[before]

        Default Value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page
        The page size is provided by page[last]

    .PARAMETER AllResults
        Returns all items from an endpoint

        Highly recommended to only use with filters to reduce API errors\timeouts

    .EXAMPLE
        Get-AuvikAlert

        Gets general information about the first 100 alerts
        Auvik has discovered

    .EXAMPLE
        Get-AuvikAlert -ID 123456789

        Gets general information for the defined alert
        Auvik has discovered

    .EXAMPLE
        Get-AuvikAlert -PageFirst 1000 -AllResults

        Gets general information for all alerts found by Auvik.

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Alert/Get-AuvikAlert.html
#>

    [CmdletBinding(DefaultParameterSetName = 'IndexByMultiAlert' )]
    Param (
        [Parameter( Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'IndexBySingleAlert' )]
        [ValidateNotNullOrEmpty()]
        [string]$ID,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiAlert' )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiAlert' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterAlertDefinitionId,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiAlert' )]
        [ValidateSet( "unknown", "emergency", "critical", "warning", "info" )]
        [string]$FilterSeverity,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiAlert' )]
        [ValidateSet( "created", "resolved", "paused", "unpaused" )]
        [string]$FilterStatus,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiAlert' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterEntityId,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiAlert' )]
        [switch]$FilterDismissed,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiAlert' )]
        [switch]$FilterDispatched,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiAlert' )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterDetectedTimeAfter,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiAlert' )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterDetectedTimeBefore,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiAlert' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiAlert' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiAlert' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiAlert' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiAlert' )]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = $functionName + '_Parameters'      -replace '-','_'
        $QueryParameterName = $functionName + '_ParametersQuery' -replace '-','_'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        switch ( $($PSCmdlet.ParameterSetName) ) {
            'IndexByMultiAlert'  { $ResourceUri = "/alert/history/info" }
            'IndexBySingleAlert' { $ResourceUri = "/alert/history/info/$ID" }
        }

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -eq 'IndexByMultiAlert') {
            if ($Tenants)                   { $UriParameters['tenants']                     = $Tenants }
            if ($FilterAlertDefinitionId)   { $UriParameters['filter[alertDefinitionId]']   = $FilterAlertDefinitionId }
            if ($FilterSeverity)            { $UriParameters['filter[severity]']            = $FilterSeverity }
            if ($FilterStatus)              { $UriParameters['filter[status]']              = $FilterStatus }
            if ($FilterEntityId)            { $UriParameters['filter[entityId]']            = $FilterEntityId }
            if ($FilterDismissed)           { $UriParameters['filter[dismissed]']           = $FilterDismissed }
            if ($FilterDispatched)          { $UriParameters['filter[dispatched]']          = $FilterDispatched }
            if ($FilterDetectedTimeAfter)   { $UriParameters['filter[detectedTimeAfter]']   = $FilterDetectedTimeAfter }
            if ($FilterDetectedTimeBefore)  { $UriParameters['filter[detectedTimeBefore]']  = $FilterDetectedTimeBefore }
            if ($PageFirst)                 { $UriParameters['page[first]']                 = $PageFirst }
            if ($PageAfter)                 { $UriParameters['page[after]']                 = $PageAfter }
            if ($PageLast)                  { $UriParameters['page[last]']                  = $PageLast }
            if ($PageBefore)                { $UriParameters['page[before]']                = $PageBefore }
        }

        #EndRegion  [ Parameter Translation ]

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

        return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

    }

    end {}

}
#EndRegion '.\Public\Alert\Get-AuvikAlert.ps1' 208
#Region '.\Public\Billing\Get-AuvikBilling.ps1' -1

function Get-AuvikBilling {
<#
    .SYNOPSIS
        Get Auvik billing information

    .DESCRIPTION
        The Get-AuvikBilling cmdlet gets billing information
        to help calculate your invoices

        The dataTime value are converted to UTC, however for these endpoints
        you will only need to defined yyyy-MM-dd

    .PARAMETER FilterFromDate
        Date from which you want to query

        Example: filter[fromDate]=2019-06-01

    .PARAMETER FilterThruDate
        Date to which you want to query

        Example: filter[thruDate]=2019-06-30

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from.

        Example: Tenants=199762235015168516,199762235015168004

    .PARAMETER ID
        ID of device

    .EXAMPLE
        Get-AuvikBilling -FilterFromDate 2023-09-01 -FilterThruDate 2023-09-30

        Gets a summary of a client's (and client's children if a multi-client)
        usage for the given time range.

    .EXAMPLE
        Get-AuvikBilling -FilterFromDate 2023-09-01 -FilterThruDate 2023-09-30 -Tenants 12345,98765

        Gets a summary of the defined client's (and client's children if a multi-client)fromDate
        usage for the given time range.

    .EXAMPLE
        Get-AuvikBilling -FilterFromDate 2023-09-01 -FilterThruDate 2023-09-30 -ID 123456789

        Gets a summary of the define device id's usage for the given time range.

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Billing/Get-AuvikBilling.html
#>

    [CmdletBinding(DefaultParameterSetName = 'IndexByClient')]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterFromDate,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterThruDate,

        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = 'IndexByClient')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'IndexByDevice')]
        [ValidateNotNullOrEmpty()]
        [string]$ID
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = $functionName + '_Parameters'      -replace '-','_'
        $QueryParameterName = $functionName + '_ParametersQuery' -replace '-','_'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        switch ( $($PSCmdlet.ParameterSetName) ) {
            'IndexByClient' { $ResourceUri = "/billing/usage/client" }
            'IndexByDevice' { $ResourceUri = "/billing/usage/device/$ID" }
        }

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -like 'IndexBy*') {
            if ($Tenants) { $UriParameters['tenants']  = $Tenants }
        }

        #Shared Parameters
        if ($FilterFromDate)    { $UriParameters['filter[fromDate]']    = $FilterFromDate }
        if ($FilterThruDate)    { $UriParameters['filter[thruDate]']    = $FilterThruDate }

        #EndRegion  [ Parameter Translation ]

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

        return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

    }

    end {}

}
#EndRegion '.\Public\Billing\Get-AuvikBilling.ps1' 115
#Region '.\Public\ClientManagement\Get-AuvikTenant.ps1' -1

function Get-AuvikTenant {
<#
    .SYNOPSIS
        Get Auvik tenant information

    .DESCRIPTION
        The Get-AuvikTenant cmdlet get Auvik general or detailed
        tenant information associated to your Auvik user account

    .PARAMETER TenantDomainPrefix
        Domain prefix of your main Auvik account (tenant)

    .PARAMETER FilterAvailableTenants
        Filter whether or not a tenant is available,
        i.e. data can be gotten from them via the API

    .PARAMETER ID
        ID of tenant

    .EXAMPLE
        Get-AuvikTenant

        Gets general information about multiple multi-clients and
        clients associated with your Auvik user account

    .EXAMPLE
        Get-AuvikTenant -TenantDomainPrefix CeleriumMSP

        Gets detailed information about multiple multi-clients and
        clients associated with your main Auvik account

    .EXAMPLE
        Get-AuvikTenant -TenantDomainPrefix CeleriumMSP -ID 123456789

        Gets detailed information about a single tenant from
        your main Auvik account

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/ClientManagement/Get-AuvikTenant.html
#>

    [CmdletBinding(DefaultParameterSetName = 'IndexMultiTenant')]
    Param (
        [Parameter(Mandatory = $true, ParameterSetName = 'IndexMultiTenantDetails')]
        [Parameter(Mandatory = $true, ParameterSetName = 'IndexSingleTenantDetails')]
        [ValidateNotNullOrEmpty()]
        [string]$TenantDomainPrefix,

        [Parameter(Mandatory = $false, ParameterSetName = 'IndexMultiTenantDetails')]
        [switch]$FilterAvailableTenants,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'IndexSingleTenantDetails')]
        [ValidateNotNullOrEmpty()]
        [string]$ID
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = $functionName + '_Parameters'      -replace '-','_'
        $QueryParameterName = $functionName + '_ParametersQuery' -replace '-','_'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        switch ( $($PSCmdlet.ParameterSetName) ) {
            'IndexMultiTenant'          { $ResourceUri = "/tenants" }
            'IndexMultiTenantDetails'   { $ResourceUri = "/tenants/detail" }
            'IndexSingleTenantDetails'  { $ResourceUri = "/tenants/detail/$ID" }
        }

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -eq 'IndexMultiTenantDetails') {
            if ($FilterAvailableTenants) { $UriParameters['filter[availableTenants]'] = $FilterAvailableTenants }
        }

        #Shared Parameters
        if ($TenantDomainPrefix) { $UriParameters['filter[tenantDomainPrefix]'] = $TenantDomainPrefix }

        #EndRegion  [ Parameter Translation ]

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

        return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

    }

    end {}

}
#EndRegion '.\Public\ClientManagement\Get-AuvikTenant.ps1' 101
#Region '.\Public\Inventory\Get-AuvikComponent.ps1' -1

function Get-AuvikComponent {
<#
    .SYNOPSIS
        Get Auvik components and other related information

    .DESCRIPTION
        The Get-AuvikComponent cmdlet allows you to view an inventory of
        components and other related information discovered by Auvik.

    .PARAMETER ID
        ID of component

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from

    .PARAMETER FilterModifiedAfter
        Filter by date and time, only returning entities modified after provided value

    .PARAMETER FilterDeviceId
        Filter by the component's parent device's ID

    .PARAMETER FilterDeviceName
        Filter by the component's parent device's name

    .PARAMETER FilterCurrentStatus
        Filter by the component's current status

        Allowed values:
            "ok", "degraded", "failed"

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned
        Used in combination with page[after]

        Default Value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page
        The page size is provided by page[first]

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned
        Used in combination with page[before]

        Default Value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page
        The page size is provided by page[last]

    .PARAMETER AllResults
        Returns all items from an endpoint

        Highly recommended to only use with filters to reduce API errors\timeouts

    .EXAMPLE
        Get-AuvikComponent

        Gets general information about the first 100 components
        Auvik has discovered

    .EXAMPLE
        Get-AuvikComponent -ID 123456789

        Gets general information for the defined component
        Auvik has discovered

    .EXAMPLE
        Get-AuvikComponent -PageFirst 1000 -AllResults

        Gets general information for all components found by Auvik.

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikComponent.html
#>

    [CmdletBinding(DefaultParameterSetName = 'IndexByMultiComponent' )]
    Param (
        [Parameter( Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'IndexBySingleComponent' )]
        [ValidateNotNullOrEmpty()]
        [string]$ID,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiComponent' )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiComponent' )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterModifiedAfter,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiComponent' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterDeviceId,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiComponent' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterDeviceName,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiComponent' )]
        [ValidateSet( "ok", "degraded", "failed" )]
        [string]$FilterCurrentStatus,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiComponent' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiComponent' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiComponent' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiComponent' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiComponent' )]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = $functionName + '_Parameters'      -replace '-','_'
        $QueryParameterName = $functionName + '_ParametersQuery' -replace '-','_'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        switch ( $($PSCmdlet.ParameterSetName) ) {
            'IndexByMultiComponent'  { $ResourceUri = "/inventory/component/info" }
            'IndexBySingleComponent' { $ResourceUri = "/inventory/component/info/$ID" }
        }

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -eq 'IndexByMultiComponent') {
            if ($Tenants)               { $UriParameters['filter[tenantId]']        = $Tenants }
            if ($FilterModifiedAfter)   { $UriParameters['filter[modifiedAfter]']   = $FilterModifiedAfter }
            if ($FilterDeviceId)        { $UriParameters['filter[deviceId]']        = $FilterDeviceId }
            if ($FilterDeviceName)      { $UriParameters['filter[deviceName]']      = $FilterDeviceName }
            if ($FilterCurrentStatus)   { $UriParameters['filter[currentStatus]']   = $FilterCurrentStatus }
            if ($PageFirst)             { $UriParameters['page[first]']             = $PageFirst }
            if ($PageAfter)             { $UriParameters['page[after]']             = $PageAfter }
            if ($PageLast)              { $UriParameters['page[last]']              = $PageLast }
            if ($PageBefore)            { $UriParameters['page[before]']            = $PageBefore }
        }

        #EndRegion  [ Parameter Translation ]

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

        return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

    }

    end {}

}
#EndRegion '.\Public\Inventory\Get-AuvikComponent.ps1' 171
#Region '.\Public\Inventory\Get-AuvikConfiguration.ps1' -1

function Get-AuvikConfiguration {
<#
    .SYNOPSIS
        Get Auvik history of device configurations

    .DESCRIPTION
        The Get-AuvikConfiguration cmdlet allows you to view a history of
        device configurations and other related information discovered by Auvik.

    .PARAMETER ID
        ID of entity note\audit

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from

    .PARAMETER FilterDeviceId
        Filter by device ID

    .PARAMETER FilterBackupTimeAfter
        Filter by date and time, filtering out configurations backed up before value

    .PARAMETER FilterBackupTimeBefore
        Filter by date and time, filtering out configurations backed up after value.

    .PARAMETER FilterIsRunning
        Filter for configurations that are currently running, or filter
        for all configurations which are not currently running.

        As of 2023-10, this does not appear to function correctly on this endpoint

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned
        Used in combination with page[after]

        Default Value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page
        The page size is provided by page[first]

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned
        Used in combination with page[before]

        Default Value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page
        The page size is provided by page[last]

    .PARAMETER AllResults
        Returns all items from an endpoint

        Highly recommended to only use with filters to reduce API errors\timeouts

    .EXAMPLE
        Get-AuvikConfiguration

        Gets general information about the first 100 configurations
        Auvik has discovered

    .EXAMPLE
        Get-AuvikConfiguration -ID 123456789

        Gets general information for the defined configuration
        Auvik has discovered

    .EXAMPLE
        Get-AuvikConfiguration -PageFirst 1000 -AllResults

        Gets general information for all configurations found by Auvik.

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikConfiguration.html
#>

    [CmdletBinding(DefaultParameterSetName = 'IndexByMultiConfig' )]
    Param (
        [Parameter( Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'IndexBySingleConfig' )]
        [ValidateNotNullOrEmpty()]
        [string]$ID,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiConfig' )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiConfig' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterDeviceId,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiConfig' )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterBackupTimeAfter,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiConfig' )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterBackupTimeBefore,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiConfig' )]
        [switch]$FilterIsRunning,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiConfig' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiConfig' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiConfig' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiConfig' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiConfig' )]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = $functionName + '_Parameters'      -replace '-','_'
        $QueryParameterName = $functionName + '_ParametersQuery' -replace '-','_'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        switch ( $($PSCmdlet.ParameterSetName) ) {
            'IndexByMultiConfig'    { $ResourceUri = "/inventory/configuration" }
            'IndexBySingleConfig'   { $ResourceUri = "/inventory/configuration/$ID" }
        }

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -eq 'IndexByMultiConfig') {
            if ($Tenants)                   { $UriParameters['filter[tenant]']              = $Tenants }
            if ($FilterDeviceId)            { $UriParameters['filter[deviceId]']            = $FilterDeviceId }
            if ($FilterBackupTimeAfter)     { $UriParameters['filter[backupTimeAfter]']     = $FilterBackupTimeAfter }
            if ($FilterBackupTimeBefore)    { $UriParameters['filter[backupTimeBefore]']    = $FilterBackupTimeBefore }
            if ($FilterIsRunning)           { $UriParameters['filter[isRunning]']           = $FilterIsRunning }
            if ($PageFirst)                 { $UriParameters['page[first]']                 = $PageFirst }
            if ($PageAfter)                 { $UriParameters['page[after]']                 = $PageAfter }
            if ($PageLast)                  { $UriParameters['page[last]']                  = $PageLast }
            if ($PageBefore)                { $UriParameters['page[before]']                = $PageBefore }
        }

        #EndRegion  [ Parameter Translation ]

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

        return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

    }

    end {}

}
#EndRegion '.\Public\Inventory\Get-AuvikConfiguration.ps1' 170
#Region '.\Public\Inventory\Get-AuvikDevice.ps1' -1

function Get-AuvikDevice {
<#
    .SYNOPSIS
        Get Auvik devices and other related information

    .DESCRIPTION
        The Get-AuvikDevice cmdlet allows you to view an inventory of
        devices and other related information discovered by Auvik.

        Use the [ -AgentDetail, -AgentExtended, & -AgentInfo  ] parameters
        when wanting to target specific information.

        See Get-Help Get-AuvikDevice -Full for more information on associated parameters

        This function combines 6 endpoints together within the Device API.

        Read Multiple Devices' Info:
            Gets detail about multiple devices discovered on your client's network.
        Read a Single Device's Info:
            Gets detail about a specific device discovered on your client's network.

        Read Multiple Devices' Details:
            Gets details about multiple devices not already Included in the Device Info API.
        Read a Single Device's Details:
            Gets details about a specific device not already Included in the Device Info API.

        Read Multiple Device's Extended Details:
            Gets extended information about multiple devices not already Included in the Device Info API.
        Read a Single Device's Extended Details:
            Gets extended information about a specific device not already Included in the Device Info API.

    .PARAMETER ID
        ID of device

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from

    .PARAMETER FilterNetworks
        Filter by IDs of networks this device is on

    .PARAMETER FilterManageStatus
        Filter by managed status

    .PARAMETER FilterDiscoverySNMP
        Filter by the device's SNMP discovery status

        Allowed values:
            "disabled", "determining", "notSupported", "notAuthorized", "authorizing", "authorized", "privileged"

    .PARAMETER FilterDiscoveryWMI
        Filter by the device's WMI discovery status

        Allowed values:
            "disabled", "determining", "notSupported", "notAuthorized", "authorizing", "authorized", "privileged"

    .PARAMETER FilterDiscoveryLogin
        Filter by the device's Login discovery status

        Allowed values:
            "disabled", "determining", "notSupported", "notAuthorized", "authorizing", "authorized", "privileged"

    .PARAMETER FilterDiscoveryVMware
        Filter by the device's VMware discovery status

        Allowed values:
            "disabled", "determining", "notSupported", "notAuthorized", "authorizing", "authorized", "privileged"

    .PARAMETER FilterTrafficInsightsStatus
        Filter by the device's VMware discovery status

        Allowed values:
            "notDetected", "detected", "notApproved", "approved", "linking", "linkingFailed", "forwarding"

    .PARAMETER FilterDeviceType
        Filter by device type

        Allowed values:
            "accessPoint", "airConditioner", "alarm", "audioVisual", "backhaul", "backupDevice",
            "bridge", "buildingManagement", "camera", "chassis", "controller", "copier", "firewall",
            "handheld", "hub", "hypervisor", "internetOfThings", "ipmi", "ipPhone", "l3Switch",
            "lightingDevice", "loadBalancer", "modem", "module", "multimedia", "packetProcessor",
            "pdu", "phone", "printer", "router", "securityAppliance", "server", "stack", "storage",
            "switch", "tablet", "telecommunications", "thinAccessPoint", "thinClient", "timeClock",
            "unknown", "ups", "utm", "virtualAppliance", "virtualMachine", "voipSwitch", "workstation"

    .PARAMETER FilterMakeModel
        Filter by the device's make and model

    .PARAMETER FilterVendorName
        Filter by the device's vendor/manufacturer

    .PARAMETER FilterOnlineStatus
        Filter by the device's online status

        Allowed values:
        "online", "offline", "unreachable", "testing", "unknown", "dormant", "notPresent", "lowerLayerDown"

    .PARAMETER FilterModifiedAfter
        Filter by date and time, only returning entities modified after provided value

    .PARAMETER FilterNotSeenSince
        Filter by the last seen online time, returning entities not seen online after the provided value

    .PARAMETER FilterStateKnown
        Filter by devices with recently updated data, for more consistent results.

    .PARAMETER Include
        Use to Include the full resource objects of the list device relationships

        Example: Include=deviceDetail

    .PARAMETER FieldsDeviceDetail
        Use to limit the attributes that will be returned in the Included detail object to
        only what is specified by this query parameter

        Requires Include=deviceDetail

    .PARAMETER AgentDetail
        Target the detail agents endpoint

        /Inventory/device/detail & /Inventory/device/detail/{id}

    .PARAMETER AgentExtended
        Target the extended agents endpoint

        /Inventory/device/detail/extended & /Inventory/device/detail/extended/{id}

    .PARAMETER AgentInfo
        Target the info agent endpoint

        Only needed when limiting general search by id, to give the parameter
        set a unique value.

        /Inventory/device/info & /Inventory/device/info

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned
        Used in combination with page[after]

        Default Value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page
        The page size is provided by page[first]

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned
        Used in combination with page[before]

        Default Value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page
        The page size is provided by page[last]

    .PARAMETER AllResults
        Returns all items from an endpoint

        Highly recommended to only use with filters to reduce API errors\timeouts

    .EXAMPLE
        Get-AuvikDevice

        Gets general information about the first 100 devices
        Auvik has discovered

    .EXAMPLE
        Get-AuvikDevice -ID 123456789 -AgentInfo

        Gets general information for the defined device
        Auvik has discovered

    .EXAMPLE
        Get-AuvikDevice -AgentDetail

        Gets detailed information about the first 100 devices
        Auvik has discovered

    .EXAMPLE
        Get-AuvikDevice -ID 123456789 -AgentDetail

        Gets AgentDetail information for the defined device
        Auvik has discovered

    .EXAMPLE
        Get-AuvikDevice -AgentExtended

        Gets extended detail information about the first 100 devices
        Auvik has discovered

    .EXAMPLE
        Get-AuvikDevice -ID 123456789 -AgentExtended

        Gets extended detail information for the defined device
        Auvik has discovered

    .EXAMPLE
        Get-AuvikDevice -PageFirst 1000 -AllResults

        Gets general information for all devices found by Auvik.

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikDevice.html
#>

    [CmdletBinding(DefaultParameterSetName = 'IndexByMultiDeviceInfo' )]
    Param (
        [Parameter( Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'IndexBySingleDeviceInfo' )]
        [Parameter( Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'IndexBySingleDeviceDetail' )]
        [Parameter( Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'IndexBySingleDeviceExtDetail' )]
        [ValidateNotNullOrEmpty()]
        [string]$ID,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceDetail' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceExtDetail' )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterNetworks,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceDetail' )]
        [switch]$FilterManageStatus,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceDetail' )]
        [ValidateSet( "disabled", "determining", "notSupported", "notAuthorized", "authorizing", "authorized", "privileged" )]
        [string]$FilterDiscoverySNMP,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceDetail' )]
        [ValidateSet( "disabled", "determining", "notSupported", "notAuthorized", "authorizing", "authorized", "privileged" )]
        [string]$FilterDiscoveryWMI,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceDetail' )]
        [ValidateSet( "disabled", "determining", "notSupported", "notAuthorized", "authorizing", "authorized", "privileged" )]
        [string]$FilterDiscoveryLogin,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceDetail' )]
        [ValidateSet( "disabled", "determining", "notSupported", "notAuthorized", "authorizing", "authorized", "privileged" )]
        [string]$FilterDiscoveryVMware,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceDetail' )]
        [ValidateSet( "notDetected", "detected", "notApproved", "approved", "linking", "linkingFailed", "forwarding" )]
        [string]$FilterTrafficInsightsStatus,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [Parameter( Mandatory = $true , ParameterSetName = 'IndexByMultiDeviceExtDetail' )]
        [ValidateSet(   "accessPoint", "airConditioner", "alarm", "audioVisual", "backhaul", "backupDevice",
                        "bridge", "buildingManagement", "camera", "chassis", "controller", "copier", "firewall",
                        "handheld", "hub", "hypervisor", "internetOfThings", "ipmi", "ipPhone", "l3Switch",
                        "lightingDevice", "loadBalancer", "modem", "module", "multimedia", "packetProcessor",
                        "pdu", "phone", "printer", "router", "securityAppliance", "server", "stack", "storage",
                        "switch", "tablet", "telecommunications", "thinAccessPoint", "thinClient", "timeClock",
                        "unknown", "ups", "utm", "virtualAppliance", "virtualMachine", "voipSwitch", "workstation"
        )]
        [string]$FilterDeviceType,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterMakeModel,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterVendorName,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [ValidateSet( "online", "offline", "unreachable", "testing", "unknown", "dormant", "notPresent", "lowerLayerDown" )]
        [string]$FilterOnlineStatus,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceExtDetail' )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterModifiedAfter,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceExtDetail' )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterNotSeenSince,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceExtDetail' )]
        [switch]$FilterStateKnown,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexBySingleDeviceInfo' )]
        [ValidateNotNullOrEmpty()]
        [string]$Include,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexBySingleDeviceInfo' )]
        [ValidateSet( "discoveryStatus", "components", "connectedDevices", "configurations", "manageStatus", "interfaces" )]
        [string]$FieldsDeviceDetail,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceDetail' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexBySingleDeviceDetail' )]
        [switch]$AgentDetail,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceExtDetail' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexBySingleDeviceExtDetail' )]
        [switch]$AgentExtended,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexBySingleDeviceInfo' )]
        [switch]$AgentInfo,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceDetail' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceExtDetail' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceDetail' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceExtDetail' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceDetail' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceExtDetail' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceDetail' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceExtDetail' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceDetail' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDeviceExtDetail' )]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = $functionName + '_Parameters'      -replace '-','_'
        $QueryParameterName = $functionName + '_ParametersQuery' -replace '-','_'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        switch ( $($PSCmdlet.ParameterSetName) ) {
            'IndexByMultiDeviceInfo'        { $ResourceUri = "/inventory/device/info" }
            'IndexBySingleDeviceInfo'       { $ResourceUri = "/inventory/device/info/$ID" }

            'IndexByMultiDeviceDetail'      { $ResourceUri = "/inventory/device/detail" }
            'IndexBySingleDeviceDetail'     { $ResourceUri = "/inventory/device/detail/$ID" }

            'IndexByMultiDeviceExtDetail'   { $ResourceUri = "/inventory/device/detail/extended" }
            'IndexBySingleDeviceExtDetail'  { $ResourceUri = "/inventory/device/detail/extended/$ID" }
        }

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -eq 'IndexByMultiDeviceInfo') {
            if ($FilterMakeModel)       { $UriParameters['filter[makeModel]']       = $FilterMakeModel }
            if ($FilterNetworks)        { $UriParameters['filter[networks]']        = $FilterNetworks }
            if ($FilterOnlineStatus)    { $UriParameters['filter[onlineStatus]']    = $FilterOnlineStatus }
            if ($FilterVendorName)      { $UriParameters['filter[vendorName]']      = $FilterVendorName }
        }

        if ($PSCmdlet.ParameterSetName -eq 'IndexByMultiDeviceInfo' -or $PSCmdlet.ParameterSetName -eq 'IndexBySingleDeviceDetail') {
            if ($FieldsDeviceDetail)    { $UriParameters['fields[deviceDetail]']    = $FieldsDeviceDetail }
            if ($Include)               { $UriParameters['include']                 = $Include }
        }

        if ($PSCmdlet.ParameterSetName -eq 'IndexByMultiDeviceDetail') {
            if ($FilterDiscoveryLogin)  { $UriParameters['filter[discoveryLogin]']  = $FilterDiscoveryLogin }
            if ($FilterDiscoverySNMP)   { $UriParameters['filter[discoverySNMP]']   = $FilterDiscoverySNMP }
            if ($FilterDiscoveryVMware) { $UriParameters['filter[discoveryVMware]'] = $FilterDiscoveryVMware }
            if ($FilterDiscoveryWMI)    { $UriParameters['filter[discoveryWMI]']    = $FilterDiscoveryWMI }
            if ($FilterManageStatus)    { $UriParameters['filter[manageStatus]']    = $FilterManageStatus }
            if ($FilterTrafficInsightsStatus) { $UriParameters['filter[trafficInsightsStatus]'] = $FilterTrafficInsightsStatus }
        }

        if ($PSCmdlet.ParameterSetName -like 'IndexByMultiDevice*') {
            if ($FilterDeviceType)      { $UriParameters['filter[deviceType]']      = $FilterDeviceType }
            if ($FilterModifiedAfter)   { $UriParameters['filter[modifiedAfter]']   = $FilterModifiedAfter }
            if ($FilterNotSeenSince)    { $UriParameters['filter[notSeenSince]']    = $FilterNotSeenSince }
            if ($FilterStateKnown)      { $UriParameters['filter[stateKnown]']      = $FilterStateKnown }
            if ($Tenants)               { $UriParameters['tenants']                 = $Tenants }
            if ($PageFirst)             { $UriParameters['page[first]']             = $PageFirst }
            if ($PageAfter)             { $UriParameters['page[after]']             = $PageAfter }
            if ($PageLast)              { $UriParameters['page[last]']              = $PageLast }
            if ($PageBefore)            { $UriParameters['page[before]']            = $PageBefore }
        }

        #EndRegion  [ Parameter Translation ]

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

        return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

    }

    end {}

}
#EndRegion '.\Public\Inventory\Get-AuvikDevice.ps1' 412
#Region '.\Public\Inventory\Get-AuvikDeviceLifecycle.ps1' -1

function Get-AuvikDeviceLifecycle {
    <#
        .SYNOPSIS
            Get Auvik devices and other related information

        .DESCRIPTION
            The Get-AuvikDeviceLifecycle cmdlet allows you to view an inventory of
            devices and other related information discovered by Auvik.

        .PARAMETER ID
            ID of device

        .PARAMETER Tenants
            Comma delimited list of tenant IDs to request info from

        .PARAMETER FilterSalesAvailability
            Filter by sales availability

            Allowed values:
                "covered", "available", "expired", "securityOnly", "unpublished", "empty"

        .PARAMETER FilterSoftwareMaintenanceStatus
            Filter by software maintenance status

            Allowed values:
                "covered", "available", "expired", "securityOnly", "unpublished", "empty"

        .PARAMETER FilterSecuritySoftwareMaintenanceStatus
            Filter by security software maintenance status

            Allowed values:
                "covered", "available", "expired", "securityOnly", "unpublished", "empty"

        .PARAMETER FilterLastSupportStatus
            Filter by last support status

            Allowed values:
                "covered", "available", "expired", "securityOnly", "unpublished", "empty"

        .PARAMETER PageFirst
            For paginated responses, the first N elements will be returned
            Used in combination with page[after]

            Default Value: 100

        .PARAMETER PageAfter
            Cursor after which elements will be returned as a page
            The page size is provided by page[first]

        .PARAMETER PageLast
            For paginated responses, the last N services will be returned
            Used in combination with page[before]

            Default Value: 100

        .PARAMETER PageBefore
            Cursor before which elements will be returned as a page
            The page size is provided by page[last]

        .PARAMETER AllResults
            Returns all items from an endpoint

            Highly recommended to only use with filters to reduce API errors\timeouts

        .EXAMPLE
            Get-AuvikDeviceLifecycle

            Gets general lifecycle information about the first 100 devices
            Auvik has discovered

        .EXAMPLE
            Get-AuvikDeviceLifecycle -ID 123456789

            Gets general lifecycle information for the defined device
            Auvik has discovered


        .EXAMPLE
            Get-AuvikDeviceLifecycle -PageFirst 1000 -AllResults

            Gets general lifecycle information for all devices found by Auvik.

        .NOTES
        N\A

        .LINK
            https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikDeviceLifecycle.html
    #>

        [CmdletBinding(DefaultParameterSetName = 'IndexByMultiDevice' )]
        Param (
            [Parameter( Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'IndexBySingleDevice' )]
            [ValidateNotNullOrEmpty()]
            [string]$ID,

            [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDevice' )]
            [ValidateNotNullOrEmpty()]
            [string[]]$Tenants,

            [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDevice' )]
            [ValidateSet( "covered", "available", "expired", "securityOnly", "unpublished", "empty" )]
            [string]$FilterSalesAvailability,

            [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDevice' )]
            [ValidateSet( "covered", "available", "expired", "securityOnly", "unpublished", "empty" )]
            [string]$FilterSoftwareMaintenanceStatus,

            [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDevice' )]
            [ValidateSet( "covered", "available", "expired", "securityOnly", "unpublished", "empty" )]
            [string]$FilterSecuritySoftwareMaintenanceStatus,

            [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDevice' )]
            [ValidateSet( "covered", "available", "expired", "securityOnly", "unpublished", "empty" )]
            [string]$FilterLastSupportStatus,

            [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDevice' )]
            [ValidateRange(1, [int64]::MaxValue)]
            [int64]$PageFirst,

            [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDevice' )]
            [ValidateNotNullOrEmpty()]
            [string]$PageAfter,

            [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDevice' )]
            [ValidateRange(1, [int64]::MaxValue)]
            [int64]$PageLast,

            [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDevice' )]
            [ValidateNotNullOrEmpty()]
            [string]$PageBefore,

            [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDevice' )]
            [switch]$AllResults
        )

        begin {

            $FunctionName       = $MyInvocation.InvocationName
            $ParameterName      = $functionName + '_Parameters'      -replace '-','_'
            $QueryParameterName = $functionName + '_ParametersQuery' -replace '-','_'

        }

        process {

            Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

            switch ( $($PSCmdlet.ParameterSetName) ) {
                'IndexByMultiDevice'    { $ResourceUri = "/inventory/device/lifecycle" }
                'IndexBySingleDevice'   { $ResourceUri = "/inventory/device/lifecycle/$ID" }
            }

            $UriParameters = @{}

            #Region     [ Parameter Translation ]

            if ($PSCmdlet.ParameterSetName -eq 'IndexByMultiDevice') {
                if ($Tenants)                                   { $UriParameters['tenants']                                     = $Tenants }
                if ($FilterSalesAvailability)                   { $UriParameters['filter[salesAvailability]']                   = $FilterSalesAvailability }
                if ($FilterSoftwareMaintenanceStatus)           { $UriParameters['filter[softwareMaintenanceStatus]']           = $FilterSoftwareMaintenanceStatus }
                if ($FilterSecuritySoftwareMaintenanceStatus)   { $UriParameters['filter[securitySoftwareMaintenanceStatus]']   = $FilterSecuritySoftwareMaintenanceStatus }
                if ($FilterLastSupportStatus)                   { $UriParameters['filter[lastSupportStatus]']                   = $FilterLastSupportStatus }
                if ($PageFirst)                                 { $UriParameters['page[first]']                                 = $PageFirst }
                if ($PageAfter)                                 { $UriParameters['page[after]']                                 = $PageAfter }
                if ($PageLast)                                  { $UriParameters['page[last]']                                  = $PageLast }
                if ($PageBefore)                                { $UriParameters['page[before]']                                = $PageBefore }
            }

            #EndRegion  [ Parameter Translation ]

            Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
            Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

            return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

        }

        end {}

    }
#EndRegion '.\Public\Inventory\Get-AuvikDeviceLifecycle.ps1' 181
#Region '.\Public\Inventory\Get-AuvikDeviceWarranty.ps1' -1

function Get-AuvikDeviceWarranty {
    <#
        .SYNOPSIS
            Get Auvik devices and other related information

        .DESCRIPTION
            The Get-AuvikDeviceWarranty cmdlet allows you to view an inventory of
            devices and other related information discovered by Auvik.

        .PARAMETER ID
            ID of device

        .PARAMETER Tenants
            Comma delimited list of tenant IDs to request info from

        .PARAMETER FilterCoveredUnderWarranty
            Filter by warranty coverage status

        .PARAMETER FilterCoveredUnderService
            Filter by service coverage status

        .PARAMETER PageFirst
            For paginated responses, the first N elements will be returned
            Used in combination with page[after]

            Default Value: 100

        .PARAMETER PageAfter
            Cursor after which elements will be returned as a page
            The page size is provided by page[first]

        .PARAMETER PageLast
            For paginated responses, the last N services will be returned
            Used in combination with page[before]

            Default Value: 100

        .PARAMETER PageBefore
            Cursor before which elements will be returned as a page
            The page size is provided by page[last]

        .PARAMETER AllResults
            Returns all items from an endpoint

            Highly recommended to only use with filters to reduce API errors\timeouts

        .EXAMPLE
            Get-AuvikDeviceWarranty

            Gets general warranty information about the first 100 devices
            Auvik has discovered

        .EXAMPLE
            Get-AuvikDeviceWarranty -ID 123456789

            Gets general warranty information for the defined device
            Auvik has discovered


        .EXAMPLE
            Get-AuvikDeviceWarranty -PageFirst 1000 -AllResults

            Gets general warranty information for all devices found by Auvik.

        .NOTES
        N\A

        .LINK
            https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikDeviceWarranty.html
    #>

        [CmdletBinding(DefaultParameterSetName = 'IndexByMultiDevice' )]
        Param (
            [Parameter( Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'IndexBySingleDevice' )]
            [ValidateNotNullOrEmpty()]
            [string]$ID,

            [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDevice' )]
            [ValidateNotNullOrEmpty()]
            [string[]]$Tenants,

            [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDevice' )]
            [switch]$FilterCoveredUnderWarranty,

            [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDevice' )]
            [switch]$FilterCoveredUnderService,

            [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDevice' )]
            [ValidateRange(1, [int64]::MaxValue)]
            [int64]$PageFirst,

            [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDevice' )]
            [ValidateNotNullOrEmpty()]
            [string]$PageAfter,

            [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDevice' )]
            [ValidateRange(1, [int64]::MaxValue)]
            [int64]$PageLast,

            [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDevice' )]
            [ValidateNotNullOrEmpty()]
            [string]$PageBefore,

            [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiDevice' )]
            [switch]$AllResults
        )

        begin {

            $FunctionName       = $MyInvocation.InvocationName
            $ParameterName      = $functionName + '_Parameters'      -replace '-','_'
            $QueryParameterName = $functionName + '_ParametersQuery' -replace '-','_'

        }

        process {

            Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

            switch ( $($PSCmdlet.ParameterSetName) ) {
                'IndexByMultiDevice'    { $ResourceUri = "/inventory/device/warranty" }
                'IndexBySingleDevice'   { $ResourceUri = "/inventory/device/warranty/$ID" }
            }

            $UriParameters = @{}

            #Region     [ Parameter Translation ]

            if ($PSCmdlet.ParameterSetName -eq 'IndexByMultiDevice') {
                if ($Tenants)                       { $UriParameters['filter[tenantId]']                = $Tenants }
                if ($FilterCoveredUnderWarranty)    { $UriParameters['filter[coveredUnderWarranty]']    = $FilterCoveredUnderWarranty }
                if ($FilterCoveredUnderService)     { $UriParameters['filter[coveredUnderService]']     = $FilterCoveredUnderService }
                if ($PageFirst)                     { $UriParameters['page[first]']                     = $PageFirst }
                if ($PageAfter)                     { $UriParameters['page[after]']                     = $PageAfter }
                if ($PageLast)                      { $UriParameters['page[last]']                      = $PageLast }
                if ($PageBefore)                    { $UriParameters['page[before]']                    = $PageBefore }
            }

            #EndRegion  [ Parameter Translation ]

            Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
            Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

            return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

        }

        end {}

    }
#EndRegion '.\Public\Inventory\Get-AuvikDeviceWarranty.ps1' 151
#Region '.\Public\Inventory\Get-AuvikEntity.ps1' -1

function Get-AuvikEntity {
<#
    .SYNOPSIS
        Get Auvik Notes and audit trails associated with the entities

    .DESCRIPTION
        The Get-AuvikEntity cmdlet allows you to view Notes and audit trails associated
        with the entities (devices, networks, and interfaces) that have been discovered
        by Auvik.

        Use the [ -Audits & -Notes  ] parameters when wanting to target
        specific information.

        See Get-Help Get-AuvikEntity -Full for more information on associated parameters

    .PARAMETER ID
        ID of entity note\audit

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from

    .PARAMETER FilterEntityId
        Filter by the entity's ID

    .PARAMETER FilterUser
        Filter by user name associated to the audit

    .PARAMETER FilterCategory
        Filter by the audit's category

        Allowed values:
            "unknown", "tunnel", "terminal", "remoteBrowser"

    .PARAMETER FilterEntityType
        Filter by the entity's type

        Allowed values:
            "root", "device", "network", "interface"

    .PARAMETER FilterEntityName
        Filter by the entity's name

    .PARAMETER FilterLastModifiedBy
        Filter by the user the note was last modified by

    .PARAMETER FilterStatus
        Filter by the audit's status

        Allowed values:
            "unknown", "initiated", "created", "closed", "failed"

    .PARAMETER FilterModifiedAfter
        Filter by date and time, only returning entities modified after provided value

    .PARAMETER Audits
        Target the audit endpoint

        /Inventory/entity/audit & /Inventory/entity/audit/{id}

    .PARAMETER Notes
        Target the note endpoint

        /Inventory/entity/note & /Inventory/entity/note/{id}

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned
        Used in combination with page[after]

        Default Value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page
        The page size is provided by page[first]

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned
        Used in combination with page[before]

        Default Value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page
        The page size is provided by page[last]

    .PARAMETER AllResults
        Returns all items from an endpoint

        Highly recommended to only use with filters to reduce API errors\timeouts

    .EXAMPLE
        Get-AuvikEntity

        Gets general information about the first 100 Notes
        Auvik has discovered

    .EXAMPLE
        Get-AuvikEntity -ID 123456789 -Audits

        Gets general information for the defined audit
        Auvik has discovered

    .EXAMPLE
        Get-AuvikEntity -ID 123456789 -Notes

        Gets general information for the defined note
        Auvik has discovered

    .EXAMPLE
        Get-AuvikEntity -PageFirst 1000 -AllResults

        Gets general information for all note entities found by Auvik.

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikEntity.html
#>

    [CmdletBinding(DefaultParameterSetName = 'IndexByMultiEntityNotes' )]
    Param (
        [Parameter( Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'IndexBySingleEntityNotes' )]
        [Parameter( Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'IndexBySingleEntityAudits' )]
        [ValidateNotNullOrEmpty()]
        [string]$ID,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityNotes' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityAudits' )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityNotes' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterEntityId,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityAudits' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterUser,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityAudits' )]
        [ValidateSet( "unknown", "tunnel", "terminal", "remoteBrowser" )]
        [string]$FilterCategory,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityNotes' )]
        [ValidateSet( "root", "device", "network", "interface" )]
        [string]$FilterEntityType,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityNotes' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterEntityName,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityNotes' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterLastModifiedBy,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityAudits' )]
        [ValidateSet( "unknown", "initiated", "created", "closed", "failed" )]
        [string]$FilterStatus,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityNotes' )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterModifiedAfter,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexBySingleEntityAudits' )]
        [switch]$Audits,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexBySingleEntityNotes' )]
        [switch]$Notes,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityNotes' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityAudits' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityNotes' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityAudits' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityNotes' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityAudits' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityNotes' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityAudits' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityNotes' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiEntityAudits' )]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = $functionName + '_Parameters'      -replace '-','_'
        $QueryParameterName = $functionName + '_ParametersQuery' -replace '-','_'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        switch ( $($PSCmdlet.ParameterSetName) ) {
            'IndexByMultiEntityNotes'   { $ResourceUri = "/inventory/entity/note" }
            'IndexBySingleEntityNotes'  { $ResourceUri = "/inventory/entity/note/$ID" }

            'IndexByMultiEntityAudits'  { $ResourceUri = "/inventory/entity/audit" }
            'IndexBySingleEntityAudits' { $ResourceUri = "/inventory/entity/audit/$ID" }
        }

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -eq 'IndexByMultiEntityNotes') {
            if ($FilterEntityId)            { $UriParameters['filter[entityId]']             = $FilterEntityId }
            if ($FilterEntityType)          { $UriParameters['filter[entityType]']           = $FilterEntityType }
            if ($FilterEntityName)          { $UriParameters['filter[entityName]']           = $FilterEntityName }
            if ($FilterLastModifiedBy)      { $UriParameters['filter[lastModifiedBy]']       = $FilterLastModifiedBy }
        }

        if ($PSCmdlet.ParameterSetName -like 'IndexByMulti*') {
            if ($FilterModifiedAfter)       { $UriParameters['filter[modifiedAfter]']        = $FilterModifiedAfter }
            if ($Tenants)                   { $UriParameters['filter[tenantId]']             = $Tenants }
            if ($PageFirst)                 { $UriParameters['page[first]']                  = $PageFirst }
            if ($PageAfter)                 { $UriParameters['page[after]']                  = $PageAfter }
            if ($PageLast)                  { $UriParameters['page[last]']                   = $PageLast }
            if ($PageBefore)                { $UriParameters['page[before]']                 = $PageBefore }
        }

        if ($PSCmdlet.ParameterSetName -eq 'IndexByMultiEntityAudits') {
            if ($FilterUser)                { $UriParameters['filter[user]']                 = $FilterUser }
            if ($FilterCategory)            { $UriParameters['filter[category]']             = $FilterCategory }
            if ($FilterStatus)              { $UriParameters['filter[status]']               = $FilterStatus }
        }

        #EndRegion  [ Parameter Translation ]

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

        return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

    }

    end {}

}
#EndRegion '.\Public\Inventory\Get-AuvikEntity.ps1' 253
#Region '.\Public\Inventory\Get-AuvikInterface.ps1' -1

function Get-AuvikInterface {
<#
    .SYNOPSIS
        Get Auvik interfaces and other related information

    .DESCRIPTION
        The Get-AuvikInterface cmdlet allows you to view an inventory of
        interfaces and other related information discovered by Auvik.

    .PARAMETER ID
        ID of interface

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from

    .PARAMETER FilterInterfaceType
        Filter by interface type

        Allowed values:
            "ethernet", "wifi", "bluetooth", "cdma", "coax", "cpu", "distributedVirtualSwitch",
            "firewire", "gsm", "ieee8023AdLag", "inferredWired", "inferredWireless", "interface",
            "linkAggregation", "loopback", "modem", "wimax", "optical", "other", "parallel", "ppp",
            "radiomac", "rs232", "tunnel", "unknown", "usb", "virtualBridge", "virtualNic",
            "virtualSwitch", "vlan"

    .PARAMETER FilterParentDevice
        Filter by the entity's parent device ID

    .PARAMETER FilterAdminStatus
        Filter by the interface's admin status

    .PARAMETER FilterOperationalStatus
        Filter by the interface's operational status

        Allowed values:
            "online", "offline", "unreachable", "testing", "unknown", "dormant", "notPresent", "lowerLayerDown"

    .PARAMETER FilterModifiedAfter
        Filter by date and time, only returning entities modified after provided value

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned
        Used in combination with page[after]

        Default Value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page
        The page size is provided by page[first]

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned
        Used in combination with page[before]

        Default Value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page
        The page size is provided by page[last]

    .PARAMETER AllResults
        Returns all items from an endpoint

        Highly recommended to only use with filters to reduce API errors\timeouts

    .EXAMPLE
        Get-AuvikInterface

        Gets general information about the first 100 interfaces
        Auvik has discovered

    .EXAMPLE
        Get-AuvikInterface -ID 123456789

        Gets general information for the defined interface
        Auvik has discovered

    .EXAMPLE
        Get-AuvikInterface -PageFirst 1000 -AllResults

        Gets general information for all interfaces found by Auvik.

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikInterface.html
#>

    [CmdletBinding(DefaultParameterSetName = 'IndexByMultiInterface' )]
    Param (
        [Parameter( Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'IndexBySingleInterface' )]
        [ValidateNotNullOrEmpty()]
        [string]$ID,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiInterface' )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiInterface' )]
        [ValidateSet(   "ethernet", "wifi", "bluetooth", "cdma", "coax", "cpu", "distributedVirtualSwitch",
                        "firewire", "gsm", "ieee8023AdLag", "inferredWired", "inferredWireless", "interface",
                        "linkAggregation", "loopback", "modem", "wimax", "optical", "other", "parallel", "ppp",
                        "radiomac", "rs232", "tunnel", "unknown", "usb", "virtualBridge", "virtualNic",
                        "virtualSwitch", "vlan"
        )]
        [string]$FilterInterfaceType,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiInterface' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterParentDevice,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiInterface' )]
        [switch]$FilterAdminStatus,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiInterface' )]
        [ValidateSet( "online", "offline", "unreachable", "testing", "unknown", "dormant", "notPresent", "lowerLayerDown" )]
        [string]$FilterOperationalStatus,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiInterface' )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterModifiedAfter,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiInterface' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiInterface' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiInterface' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiInterface' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiInterface' )]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = $functionName + '_Parameters'      -replace '-','_'
        $QueryParameterName = $functionName + '_ParametersQuery' -replace '-','_'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        switch ( $($PSCmdlet.ParameterSetName) ) {
            'IndexByMultiInterface'  { $ResourceUri = "/inventory/interface/info" }
            'IndexBySingleInterface' { $ResourceUri = "/inventory/interface/info/$ID" }
        }

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -eq 'IndexByMultiInterface') {
            if ($Tenants)                   { $UriParameters['tenantId']                = $Tenants }
            if ($FilterInterfaceType)       { $UriParameters['filterInterfaceType']     = $FilterInterfaceType }
            if ($FilterParentDevice)        { $UriParameters['filterParentDevice']      = $FilterParentDevice }
            if ($FilterAdminStatus)         { $UriParameters['filterAdminStatus']       = $FilterAdminStatus }
            if ($FilterOperationalStatus)   { $UriParameters['filterOperationalStatus'] = $FilterOperationalStatus }
            if ($FilterModifiedAfter)       { $UriParameters['filterModifiedAfter']     = $FilterModifiedAfter }
            if ($PageFirst)                 { $UriParameters['page[first]']             = $PageFirst }
            if ($PageAfter)                 { $UriParameters['page[after]']             = $PageAfter }
            if ($PageLast)                  { $UriParameters['page[last]']              = $PageLast }
            if ($PageBefore)                { $UriParameters['page[before]']            = $PageBefore }
        }

        #EndRegion  [ Parameter Translation ]

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

        return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

    }

    end {}

}
#EndRegion '.\Public\Inventory\Get-AuvikInterface.ps1' 190
#Region '.\Public\Inventory\Get-AuvikNetwork.ps1' -1

function Get-AuvikNetwork {
<#
    .SYNOPSIS
        Get Auvik networks and other related information

    .DESCRIPTION
        The Get-AuvikNetwork cmdlet allows you to view an inventory of
        networks and other related information discovered by Auvik.

        Use the [ -NetworkDetails & -NetworkInfo  ] parameters when wanting to target
        specific information. See Get-Help Get-AuvikNetwork -Full for
        more information on associated parameters

    .PARAMETER ID
        ID of network

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from

    .PARAMETER FilterNetworkType
        Filter by network type

        Allowed values:
            "routed", "vlan", "wifi", "loopback", "network", "layer2", "internet"

    .PARAMETER FilterScanStatus
        Filter by the network's scan status

        Allowed values:
            "true", "false", "notAllowed", "unknown"

    .PARAMETER FilterDevices
        Filter by IDs of devices on this network

        Filter by multiple values by providing a comma delimited list

    .PARAMETER FilterModifiedAfter
        Filter by date and time, only returning entities modified after provided value

    .PARAMETER FilterScope
        Filter by the network's scope

        Allowed values:
            "private", "public"

    .PARAMETER Include
        Use to Include the full resource objects of the list device relationships

        Example: Include=deviceDetail

    .PARAMETER FieldsNetworkDetail
        Use to limit the attributes that will be returned in the Included detail
        object to only what is specified by this query parameter.

        Allowed values:
            "scope", "primaryCollector", "secondaryCollectors", "collectorSelection", "excludedIpAddresses"

        Requires Include=networkDetail

    .PARAMETER NetworkDetails
        Target the network details endpoint

        /Inventory/network/info & /Inventory/network/info/{id}

    .PARAMETER NetworkInfo
        Target the network info endpoint

        /Inventory/network/detail & /Inventory/network/detail/{id}

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned
        Used in combination with page[after]

        Default Value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page
        The page size is provided by page[first]

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned
        Used in combination with page[before]

        Default Value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page
        The page size is provided by page[last]

    .PARAMETER AllResults
        Returns all items from an endpoint

        Highly recommended to only use with filters to reduce API errors\timeouts

    .EXAMPLE
        Get-AuvikNetwork

        Gets general information about the first 100 networks
        Auvik has discovered

    .EXAMPLE
        Get-AuvikNetwork -ID 123456789 -NetworkInfo

        Gets general information for the defined network
        Auvik has discovered

    .EXAMPLE
        Get-AuvikNetwork -NetworkDetails

        Gets detailed information about the first 100 networks
        Auvik has discovered

    .EXAMPLE
        Get-AuvikNetwork -ID 123456789 -NetworkDetails

        Gets network details information for the defined network
        Auvik has discovered

    .EXAMPLE
        Get-AuvikNetwork -PageFirst 1000 -AllResults

        Gets network info information for all networks found by Auvik

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikNetwork.html
#>

    [CmdletBinding(DefaultParameterSetName = 'IndexByMultiNetworkInfo' )]
    Param (
        [Parameter( Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'IndexBySingleNetworkInfo' )]
        [Parameter( Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'IndexBySingleNetworkDetail' )]
        [ValidateNotNullOrEmpty()]
        [string]$ID,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkDetail' )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkDetail' )]
        [ValidateSet( "routed", "vlan", "wifi", "loopback", "network", "layer2", "internet" )]
        [string]$FilterNetworkType,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkDetail' )]
        [ValidateSet( "true", "false", "notAllowed", "unknown" )]
        [string]$FilterScanStatus,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkDetail' )]
        [ValidateNotNullOrEmpty()]
        [string[]]$FilterDevices,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkDetail' )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterModifiedAfter,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkDetail' )]
        [ValidateSet( "private", "public" )]
        [string]$FilterScope,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexBySingleNetworkInfo' )]
        [ValidateNotNullOrEmpty()]
        [string]$Include,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexBySingleNetworkInfo' )]
        [ValidateSet( "scope", "primaryCollector", "secondaryCollectors", "collectorSelection", "excludedIpAddresses" )]
        [string[]]$FieldsNetworkDetail,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexBySingleNetworkDetail' )]
        [switch]$NetworkDetails,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexBySingleNetworkInfo' )]
        [switch]$NetworkInfo,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkDetail' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkDetail' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkDetail' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkDetail' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkInfo' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiNetworkDetail' )]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = $functionName + '_Parameters'      -replace '-','_'
        $QueryParameterName = $functionName + '_ParametersQuery' -replace '-','_'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        switch ( $($PSCmdlet.ParameterSetName) ) {
            'IndexByMultiNetworkInfo'       { $ResourceUri = "/inventory/network/info" }
            'IndexBySingleNetworkInfo'      { $ResourceUri = "/inventory/network/info/$ID" }

            'IndexByMultiNetworkDetail'     { $ResourceUri = "/inventory/network/detail" }
            'IndexBySingleNetworkDetail'    { $ResourceUri = "/inventory/network/detail/$ID" }
        }

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -eq 'IndexByMultiNetworkInfo' -or $PSCmdlet.ParameterSetName -eq 'IndexBySingleNetworkInfo') {
            if ($FieldsNetworkDetail)   { $UriParameters['fields[networkDetail]']   = $FieldsNetworkDetail }
            if ($Include)               { $UriParameters['include']                 = $Include }
        }

        if ($PSCmdlet.ParameterSetName -eq 'IndexByMultiNetworkInfo') {
            if ($FilterScope)            { $UriParameters['filter[scope]']          = $FilterScope }
        }

        if ($PSCmdlet.ParameterSetName -eq 'IndexByMultiNetworkInfo' -or $PSCmdlet.ParameterSetName -eq 'IndexByMultiNetworkDetail') {
            if ($Tenants)               { $UriParameters['tenants']                 = $Tenants }
            if ($FilterNetworkType)     { $UriParameters['filter[networkType]']     = $FilterNetworkType }
            if ($FilterScanStatus)      { $UriParameters['filter[scanStatus]']      = $FilterScanStatus }
            if ($FilterDevices)         { $UriParameters['filter[devices]']         = $FilterDevices }
            if ($FilterModifiedAfter)   { $UriParameters['filter[modifiedAfter]']   = $FilterModifiedAfter }
            if ($PageFirst)             { $UriParameters['page[first]']             = $PageFirst }
            if ($PageAfter)             { $UriParameters['page[after]']             = $PageAfter }
            if ($PageLast)              { $UriParameters['page[last]']              = $PageLast }
            if ($PageBefore)            { $UriParameters['page[before]']            = $PageBefore }
        }

        #EndRegion  [ Parameter Translation ]

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

        return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

    }

    end {}

}
#EndRegion '.\Public\Inventory\Get-AuvikNetwork.ps1' 265
#Region '.\Public\Other\Test-AuvikAPICredential.ps1' -1

function Test-AuvikAPICredential {
<#
    .SYNOPSIS
        Verify that your credentials are correct before making a call to an endpoint

    .DESCRIPTION
        The Get-AuvikCredential cmdlet Verifies that your
        credentials are correct before making a call to an endpoint

    .EXAMPLE
        Get-AuvikCredential

        Gets general information about multiple multi-clients and
        clients associated with your Auvik user account

    .EXAMPLE
        Get-AuvikCredential

        Verify that your credentials are correct
        before making a call to an endpoint

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Other/Get-AuvikCredential.html
#>

    [CmdletBinding()]
    Param ()

    begin {}

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = "/authentication/verify"

        $return = Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -ErrorVariable restError

        if ( [string]::IsNullOrEmpty($return) -and [bool]$restError -eq $false ) {
            $true
        }
        else{ $false }

    }

    end {}

}
#EndRegion '.\Public\Other\Test-AuvikAPICredential.ps1' 52
#Region '.\Public\Pollers\Get-AuvikSNMPPollerDevice.ps1' -1

function Get-AuvikSNMPPollerDevice {
<#
    .SYNOPSIS
        Provides Details about all the devices associated to a
        specific SNMP Poller Setting.

    .DESCRIPTION
        The Get-AuvikSNMPPollerDevice cmdlet provides Details about all
        the devices associated to a specific SNMP Poller Setting.

    .PARAMETER SNMPPollerSettingId
        ID of the SNMP Poller Setting that the devices apply to

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from

    .PARAMETER FilterOnlineStatus
        Filter by the device's online status

        Allowed values:
            "online", "offline", "unreachable", "testing", "unknown", "dormant", "notPresent", "lowerLayerDown"

    .PARAMETER FilterModifiedAfter
        Filter by date and time, only returning entities modified after provided value

    .PARAMETER FilterNotSeenSince
        Filter by the last seen online time, returning entities not
        seen online after the provided value.

    .PARAMETER FilterDeviceType
        Filter by device type

        Allowed values:
            "unknown", "switch", "l3Switch", "router", "accessPoint", "firewall", "workstation",
            "server", "storage", "printer", "copier", "hypervisor", "multimedia", "phone", "tablet",
            "handheld", "virtualAppliance", "bridge", "controller", "hub", "modem", "ups", "module",
            "loadBalancer", "camera", "telecommunications", "packetProcessor", "chassis", "airConditioner",
            "virtualMachine", "pdu", "ipPhone", "backhaul", "internetOfThings", "voipSwitch", "stack",
            "backupDevice", "timeClock", "lightingDevice", "audioVisual", "securityAppliance", "utm",
            "alarm", "buildingManagement", "ipmi", "thinAccessPoint", "thinClient"

    .PARAMETER FilterMakeModel
        Filter by the device's make and model

    .PARAMETER FilterVendorName
        Filter by the device's vendor/manufacturer

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned
        Used in combination with page[after]

        Default Value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page
        The page size is provided by page[first]

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned
        Used in combination with page[before]

        Default Value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page
        The page size is provided by page[last]

    .PARAMETER AllResults
        Returns all items from an endpoint

        Highly recommended to only use with filters to reduce API errors\timeouts

    .EXAMPLE
        Get-AuvikSNMPPollerDevice -SNMPPollerSettingId MTk5NTAyNzg2ODc3 -Tenants 123456789

        Provides Details about the first 100 devices associated to the defined
        SNMP Poller id


    .EXAMPLE
        Get-AuvikSNMPPollerDevice -SNMPPollerSettingId MTk5NTAyNzg2ODc3 -Tenants 123456789 -PageFirst 1000 -AllResults

        Provides Details about all the devices associated to the defined
        SNMP Poller id

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Pollers/Get-AuvikSNMPPollerDevice.html
#>

    [CmdletBinding(DefaultParameterSetName = 'Index' )]
    Param (
        [Parameter( Mandatory = $true, ValueFromPipeline = $true )]
        [ValidateNotNullOrEmpty()]
        [string]$SNMPPollerSettingId,

        [Parameter( Mandatory = $true )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter( Mandatory = $false )]
        [ValidateSet( "online", "offline", "unreachable", "testing", "unknown", "dormant", "notPresent", "lowerLayerDown" )]
        [string]$FilterOnlineStatus,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterModifiedAfter,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterNotSeenSince,

        [Parameter( Mandatory = $false )]
        [ValidateSet(   "unknown", "switch", "l3Switch", "router", "accessPoint", "firewall", "workstation",
                        "server", "storage", "printer", "copier", "hypervisor", "multimedia", "phone", "tablet",
                        "handheld", "virtualAppliance", "bridge", "controller", "hub", "modem", "ups", "module",
                        "loadBalancer", "camera", "telecommunications", "packetProcessor", "chassis", "airConditioner",
                        "virtualMachine", "pdu", "ipPhone", "backhaul", "internetOfThings", "voipSwitch", "stack",
                        "backupDevice", "timeClock", "lightingDevice", "audioVisual", "securityAppliance", "utm",
                        "alarm", "buildingManagement", "ipmi", "thinAccessPoint", "thinClient"
        )]
        [string]$FilterDeviceType,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterMakeModel,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterVendorName,

        [Parameter( Mandatory = $false )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter( Mandatory = $false )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter( Mandatory = $false )]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = $functionName + '_Parameters'      -replace '-','_'
        $QueryParameterName = $functionName + '_ParametersQuery' -replace '-','_'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = "/settings/snmppoller/$SNMPPollerSettingId/devices"

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -eq 'Index') {
            if ($Tenants)               { $UriParameters['tenantId']                = $Tenants }
            if ($FilterOnlineStatus)    { $UriParameters['filter[onlineStatus]']    = $FilterOnlineStatus }
            if ($FilterModifiedAfter)   { $UriParameters['filter[modifiedAfter]']   = $FilterModifiedAfter }
            if ($FilterNotSeenSince)    { $UriParameters['filter[notSeenSince]']    = $FilterNotSeenSince }
            if ($FilterDeviceType)      { $UriParameters['filter[deviceType]']      = $FilterDeviceType }
            if ($FilterMakeModel)       { $UriParameters['filter[makeModel]']       = $FilterMakeModel }
            if ($FilterVendorName)      { $UriParameters['filter[vendorName]']      = $FilterVendorName }
            if ($PageFirst)             { $UriParameters['page[first]']             = $PageFirst }
            if ($PageAfter)             { $UriParameters['page[after]']             = $PageAfter }
            if ($PageLast)              { $UriParameters['page[last]']              = $PageLast }
            if ($PageBefore)            { $UriParameters['page[before]']            = $PageBefore }
        }

        #EndRegion  [ Parameter Translation ]

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

        return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

    }

    end {}

}
#EndRegion '.\Public\Pollers\Get-AuvikSNMPPollerDevice.ps1' 198
#Region '.\Public\Pollers\Get-AuvikSNMPPollerHistory.ps1' -1

function Get-AuvikSNMPPollerHistory {
<#
    .SYNOPSIS
        Get Auvik historical values of SNMP Poller settings

    .DESCRIPTION
        The Get-AuvikSNMPPollerHistory cmdlet allows you to view
        historical values of SNMP Poller settings

        There are two endpoints available in the SNMP Poller History API

        Read String SNMP Poller Setting History:
            Provides historical values of String SNMP Poller Settings
        Read Numeric SNMP Poller Setting History:
            Provides historical values of Numeric SNMP Poller Settings

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from

    .PARAMETER FilterFromTime
        Timestamp from which you want to query

    .PARAMETER FilterThruTime
        Timestamp to which you want to query (defaults to current time)

    .PARAMETER FilterCompact
        Whether to show compact view of the results or not

        Compact view only shows changes in value
        If compact view is false, dateTime range can be a maximum of 24h

    .PARAMETER FilterInterval
        Statistics reporting interval

        Allowed values:
            "minute", "hour", "day"

    .PARAMETER FilterDeviceId
        Filter by device ID

    .PARAMETER FilterSNMPPollerSettingId
        Comma delimited list of SNMP poller setting IDs to request info from

        Note this is internal SNMPPollerSettingId
        The user can get the list of IDs for a specific poller using the
        GET /settings/snmppoller endpoint

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned
        Used in combination with page[after]

        Default Value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page
        The page size is provided by page[first]

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned
        Used in combination with page[before]

        Default Value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page
        The page size is provided by page[last]

    .PARAMETER AllResults
        Returns all items from an endpoint

        Highly recommended to only use with filters to reduce API errors\timeouts

    .EXAMPLE
        Get-AuvikSNMPPollerHistory -FilterFromTime 2023-10-01 -Tenants 123456789

        Gets general information about the first 100 historical SNMP
        string poller settings

    .EXAMPLE
        Get-AuvikSNMPPollerHistory -FilterFromTime 2023-10-01 -Tenants 123456789 -FilterInterval day

        Gets general information about the first 100 historical SNMP
        numerical poller settings

    .EXAMPLE
        Get-AuvikSNMPPollerHistory -FilterFromTime 2023-10-01 -Tenants 123456789 -PageFirst 1000 -AllResults

        Gets general information about all historical SNMP
        string poller settings

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Pollers/Get-AuvikSNMPPollerHistory.html
#>

    [CmdletBinding(DefaultParameterSetName = 'IndexByStringSNMP' )]
    Param (
        [Parameter( Mandatory = $true, ParameterSetName = 'IndexByStringSNMP' )]
        [Parameter( Mandatory = $true, ParameterSetName = 'IndexByNumericSNMP' )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter( Mandatory = $true, ParameterSetName = 'IndexByStringSNMP' )]
        [Parameter( Mandatory = $true, ParameterSetName = 'IndexByNumericSNMP' )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterFromTime,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByStringSNMP' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByNumericSNMP' )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterThruTime,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByStringSNMP' )]
        [switch]$FilterCompact,

        [Parameter( Mandatory = $true, ParameterSetName = 'IndexByNumericSNMP' )]
        [ValidateSet( "minute", "hour", "day")]
        [string]$FilterInterval,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByStringSNMP' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByNumericSNMP' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterDeviceId,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByStringSNMP' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByNumericSNMP' )]
        [ValidateNotNullOrEmpty()]
        [string[]]$FilterSNMPPollerSettingId,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByStringSNMP' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByNumericSNMP' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByStringSNMP' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByNumericSNMP' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByStringSNMP' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByNumericSNMP' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByStringSNMP' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByNumericSNMP' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByStringSNMP' )]
        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByNumericSNMP' )]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = $functionName + '_Parameters'      -replace '-','_'
        $QueryParameterName = $functionName + '_ParametersQuery' -replace '-','_'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        switch ( $($PSCmdlet.ParameterSetName) ) {
            'IndexByStringSNMP'     { $ResourceUri = "/stat/snmppoller/string" }
            'IndexByNumericSNMP'    { $ResourceUri = "/stat/snmppoller/int" }
        }

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -eq 'IndexByStringSNMP') {
            if ($FilterCompact)             { $UriParameters['filter[compact]']              = $FilterCompact }
        }

        if ($PSCmdlet.ParameterSetName -eq 'IndexByNumericSNMP') {
            if ($FilterInterval)            { $UriParameters['filter[interval]']            = $FilterInterval }
        }

        if ($PSCmdlet.ParameterSetName -like 'Index*') {
            if ($tenants)                   { $UriParameters['filter[tenants]']             = $Tenants }
            if ($FilterFromTime)            { $UriParameters['filter[fromTime]']            = $FilterFromTime }
            if ($FilterThruTime)            { $UriParameters['filter[thruTime]']            = $FilterThruTime }
            if ($FilterDeviceId)            { $UriParameters['filter[deviceId]']            = $FilterDeviceId }
            if ($FilterSNMPPollerSettingId) { $UriParameters['filter[snmpPollerSettingId]'] = $FilterSNMPPollerSettingId }
            if ($PageFirst)                 { $UriParameters['page[first]']                 = $PageFirst }
            if ($PageAfter)                 { $UriParameters['page[after]']                 = $PageAfter }
            if ($PageLast)                  { $UriParameters['page[last]']                  = $PageLast }
            if ($PageBefore)                { $UriParameters['page[before]']                = $PageBefore }
        }

        #EndRegion     [ Parameter Translation ]

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

        return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

    }

    end {}

}
#EndRegion '.\Public\Pollers\Get-AuvikSNMPPollerHistory.ps1' 210
#Region '.\Public\Pollers\Get-AuvikSNMPPollerSetting.ps1' -1

function Get-AuvikSNMPPollerSetting {
<#
    .SYNOPSIS
        Provides Details about one or more SNMP Poller Settings.

    .DESCRIPTION
        The Get-AuvikSNMPPollerSetting cmdlet provides Details about
        one or more SNMP Poller Settings.

    .PARAMETER SNMPPollerSettingId
        ID of the SNMP Poller Setting to retrieve

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from

    .PARAMETER FilterDeviceId
        Filter by device ID

    .PARAMETER FilterUseAs
        Filter by oid type

        Allowed values:
            "serialNo", "poller"

    .PARAMETER FilterType
        Filter by type

        Allowed values:
            "string", "numeric"

    .PARAMETER FilterDeviceType
        Filter by device type

        Allowed values:
            "unknown", "switch", "l3Switch", "router", "accessPoint", "firewall", "workstation",
            "server", "storage", "printer", "copier", "hypervisor", "multimedia", "phone", "tablet",
            "handheld", "virtualAppliance", "bridge", "controller", "hub", "modem", "ups", "module",
            "loadBalancer", "camera", "telecommunications", "packetProcessor", "chassis", "airConditioner",
            "virtualMachine", "pdu", "ipPhone", "backhaul", "internetOfThings", "voipSwitch", "stack",
            "backupDevice", "timeClock", "lightingDevice", "audioVisual", "securityAppliance", "utm",
            "alarm", "buildingManagement", "ipmi", "thinAccessPoint", "thinClient"

    .PARAMETER FilterMakeModel
        Filter by the device's make and model

    .PARAMETER FilterVendorName
        Filter by the device's vendor/manufacturer

    .PARAMETER FilterOID
        Filter by OID

    .PARAMETER FilterName
        Filter by the name of the SNMP poller setting

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned
        Used in combination with page[after]

        Default Value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page
        The page size is provided by page[first]

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned
        Used in combination with page[before]

        Default Value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page
        The page size is provided by page[last]

    .PARAMETER AllResults
        Returns all items from an endpoint

        Highly recommended to only use with filters to reduce API errors\timeouts

    .EXAMPLE
        Get-AuvikSNMPPollerSetting -Tenants 123456789

        Provides Details about the first 100 SNMP Poller Settings
        associated to the defined tenant

    .EXAMPLE
        Get-AuvikSNMPPollerSetting -Tenants 123456789 -PageFirst 1000 -AllResults

        Provides Details about all the SNMP Poller Settings
        associated to the defined tenant

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Pollers/Get-AuvikSNMPPollerSetting.html
#>

    [CmdletBinding(DefaultParameterSetName = 'IndexByMultiSNMP' )]
    Param (
        [Parameter( Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'IndexBySingleSNMP' )]
        [ValidateNotNullOrEmpty()]
        [string]$SNMPPollerSettingId,

        [Parameter( Mandatory = $true, ParameterSetName = 'IndexByMultiSNMP' )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiSNMP' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterDeviceId,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiSNMP' )]
        [ValidateSet( "serialNo", "poller")]
        [string]$FilterUseAs,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiSNMP' )]
        [ValidateSet( "string", "numeric")]
        [string]$FilterType,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiSNMP' )]
        [ValidateSet(   "unknown", "switch", "l3Switch", "router", "accessPoint", "firewall", "workstation",
                        "server", "storage", "printer", "copier", "hypervisor", "multimedia", "phone", "tablet",
                        "handheld", "virtualAppliance", "bridge", "controller", "hub", "modem", "ups", "module",
                        "loadBalancer", "camera", "telecommunications", "packetProcessor", "chassis", "airConditioner",
                        "virtualMachine", "pdu", "ipPhone", "backhaul", "internetOfThings", "voipSwitch", "stack",
                        "backupDevice", "timeClock", "lightingDevice", "audioVisual", "securityAppliance", "utm",
                        "alarm", "buildingManagement", "ipmi", "thinAccessPoint", "thinClient"
        )]
        [string]$FilterDeviceType,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiSNMP' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterMakeModel,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiSNMP' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterVendorName,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiSNMP' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterOID,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiSNMP' )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterName,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiSNMP' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiSNMP' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiSNMP' )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiSNMP' )]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter( Mandatory = $false, ParameterSetName = 'IndexByMultiSNMP' )]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = $functionName + '_Parameters'      -replace '-','_'
        $QueryParameterName = $functionName + '_ParametersQuery' -replace '-','_'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        switch ( $($PSCmdlet.ParameterSetName) ) {
            'IndexByMultiSNMP'   { $ResourceUri = "/settings/snmppoller" }
            'IndexBySingleSNMP'  { $ResourceUri = "/settings/snmppoller/$SNMPPollerSettingId" }
        }

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -eq 'IndexByMultiSNMP') {
            if ($Tenants)           { $UriParameters['tenantId']            = $Tenants }
            if ($FilterDeviceId)    { $UriParameters['filter[deviceId]']    = $FilterDeviceId }
            if ($FilterUseAs)       { $UriParameters['filter[useAs]']       = $FilterUseAs }
            if ($FilterType)        { $UriParameters['filter[type]']        = $FilterType }
            if ($FilterDeviceType)  { $UriParameters['filter[deviceType]']  = $FilterDeviceType }
            if ($FilterMakeModel)   { $UriParameters['filter[makeModel]']   = $FilterMakeModel }
            if ($FilterVendorName)  { $UriParameters['filter[vendorName]']  = $FilterVendorName }
            if ($FilterOID)         { $UriParameters['filter[oid]']         = $FilterOID }
            if ($FilterName)        { $UriParameters['filter[name]']        = $FilterName }
            if ($PageFirst)         { $UriParameters['page[first]']         = $PageFirst }
            if ($PageAfter)         { $UriParameters['page[after]']         = $PageAfter }
            if ($PageLast)          { $UriParameters['page[last]']          = $PageLast }
            if ($PageBefore)        { $UriParameters['page[before]']        = $PageBefore }
        }

        #EndRegion  [ Parameter Translation ]

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

        return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

    }

    end {}

}
#EndRegion '.\Public\Pollers\Get-AuvikSNMPPollerSetting.ps1' 217
#Region '.\Public\SaaSManagement\Get-AuvikASMApplication.ps1' -1

function Get-AuvikASMApplication {
    <#
        .SYNOPSIS
            Get Auvik ASM application information

        .DESCRIPTION
            The Get-AuvikASMApplication cmdlet gets multiple ASM applications' info
            to retrieve the information related to the SaaS applications discovered
            within an ASM client deployment

        .PARAMETER FilterClientId
            Filter by client ID

        .PARAMETER FilterDateAddedBefore
            Return applications added before this date

        .PARAMETER FilterDateAddedAfter
            Return applications added after this date

        .PARAMETER FilterQueryDate
            Return associated breaches added after this date

        .PARAMETER FilterUserLastUsedAfter
            Return associated users added after this date

        .PARAMETER FilterUserLastUsedBefore
            Return associated users before this date

        .PARAMETER Include
            Use to include extended details of the application or of its related objects

            Allowed values:
                "all" "breaches" "users" "contracts" "publisher" "accessData"

        .PARAMETER PageFirst
            For paginated responses, the first N elements will be returned
            Used in combination with page[after]

            Default Value: 100

        .PARAMETER PageAfter
            Cursor after which elements will be returned as a page
            The page size is provided by page[first]

        .PARAMETER PageLast
            For paginated responses, the last N services will be returned
            Used in combination with page[before]

            Default Value: 100

        .PARAMETER PageBefore
            Cursor before which elements will be returned as a page
            The page size is provided by page[last]

        .PARAMETER AllResults
            Returns all items from an endpoint

            Highly recommended to only use with filters to reduce API errors\timeouts

        .EXAMPLE
            Get-AuvikASMApplication

            Get Auvik ASM application information

        .EXAMPLE
            Get-AuvikASMApplication -PageFirst 1000 -AllResults

            Get Auvik ASM application information for all devices found by Auvik

        .NOTES
        N\A

        .LINK
            https://celerium.github.io/Celerium.Auvik/site/SaaSManagement/Get-AuvikASMApplication.html
    #>

        [CmdletBinding(DefaultParameterSetName = 'Index')]
        Param (
            [Parameter( Mandatory = $false, ValueFromPipeline = $true)]
            [ValidateNotNullOrEmpty()]
            [string]$FilterClientId,

            [Parameter( Mandatory = $false)]
            [ValidateNotNullOrEmpty()]
            [DateTime]$FilterDateAddedBefore,

            [Parameter( Mandatory = $false)]
            [DateTime]$FilterDateAddedAfter,

            [Parameter( Mandatory = $false)]
            [DateTime]$FilterQueryDate,

            [Parameter( Mandatory = $false)]
            [DateTime]$FilterUserLastUsedAfter,

            [Parameter( Mandatory = $false)]
            [DateTime]$FilterUserLastUsedBefore,

            [Parameter( Mandatory = $false)]
            [ValidateSet( "all", "breaches", "users", "contracts", "publisher", "accessData" )]
            [string[]]$Include,

            [Parameter( Mandatory = $false)]
            [ValidateRange(1, [int64]::MaxValue)]
            [int64]$PageFirst,

            [Parameter( Mandatory = $false)]
            [ValidateNotNullOrEmpty()]
            [string]$PageAfter,

            [Parameter( Mandatory = $false)]
            [ValidateRange(1, [int64]::MaxValue)]
            [int64]$PageLast,

            [Parameter( Mandatory = $false)]
            [ValidateNotNullOrEmpty()]
            [string]$PageBefore,

            [Parameter( Mandatory = $false)]
            [switch]$AllResults
        )

        begin {

            $FunctionName       = $MyInvocation.InvocationName
            $ParameterName      = $functionName + '_Parameters'      -replace '-','_'
            $QueryParameterName = $functionName + '_ParametersQuery' -replace '-','_'

        }

        process {

            Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

            $ResourceUri = "/asm/app/info"

            $UriParameters = @{}

            #Region     [ Parameter Translation ]

            if ($PSCmdlet.ParameterSetName -eq 'Index') {
                if ($FilterClientId)            { $UriParameters['filter[clientId]']             = $FilterClientId }
                if ($FilterDateAddedBefore)     { $UriParameters['filter[dateAddedBefore]']       = $FilterDateAddedBefore }
                if ($FilterDateAddedAfter)      { $UriParameters['filter[dateAddedAfter]']       = $FilterDateAddedAfter }
                if ($FilterQueryDate)           { $UriParameters['filter[queryDate]']            = $FilterQueryDate }
                if ($FilterUserLastUsedAfter)   { $UriParameters['filter[user_lastUsedAfter]']   = $FilterUserLastUsedAfter }
                if ($FilterUserLastUsedBefore)  { $UriParameters['filter[user_lastUsedBefore]']  = $FilterUserLastUsedBefore }
                if ($Include)                   { $UriParameters['include']                      = $Include }
                if ($PageFirst)                 { $UriParameters['page[first]']                  = $PageFirst }
                if ($PageAfter)                 { $UriParameters['page[after]']                  = $PageAfter }
                if ($PageLast)                  { $UriParameters['page[last]']                   = $PageLast }
                if ($PageBefore)                { $UriParameters['page[before]']                 = $PageBefore }
            }

            #EndRegion  [ Parameter Translation ]

            Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
            Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

            return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

        }

        end {}

    }
#EndRegion '.\Public\SaaSManagement\Get-AuvikASMApplication.ps1' 167
#Region '.\Public\SaaSManagement\Get-AuvikASMClient.ps1' -1

function Get-AuvikASMClient {
    <#
        .SYNOPSIS
            Get Auvik ASM meta client information

        .DESCRIPTION
            The Get-AuvikASMClient cmdlet gets multiple ASM meta clients' info
            to retrieve the information related to the SaaS meta clients discovered
            within an ASM client deployment

        .PARAMETER Include
            Use to include extended details of the client

            Allowed values:
                "totals"

        .PARAMETER FilterQueryDate
            Only count breaches added after this date. Only useful when include=totals is set

        .PARAMETER PageFirst
            For paginated responses, the first N elements will be returned
            Used in combination with page[after]

            Default Value: 100

        .PARAMETER PageAfter
            Cursor after which elements will be returned as a page
            The page size is provided by page[first]

        .PARAMETER PageLast
            For paginated responses, the last N services will be returned
            Used in combination with page[before]

            Default Value: 100

        .PARAMETER PageBefore
            Cursor before which elements will be returned as a page
            The page size is provided by page[last]

        .PARAMETER AllResults
            Returns all items from an endpoint

            Highly recommended to only use with filters to reduce API errors\timeouts

        .EXAMPLE
            Get-AuvikASMClient

            Get Auvik ASM meta client information

        .EXAMPLE
            Get-AuvikASMClient -PageFirst 1000 -AllResults

            Get Auvik ASM meta client information for all devices found by Auvik

        .NOTES
        N\A

        .LINK
            https://celerium.github.io/Celerium.Auvik/site/SaaSManagement/Get-AuvikASMClient.html
    #>

        [CmdletBinding(DefaultParameterSetName = 'Index')]
        Param (
            [Parameter( Mandatory = $false)]
            [ValidateSet( "totals" )]
            [string]$Include,

            [Parameter( Mandatory = $false)]
            [DateTime]$FilterQueryDate,

            [Parameter( Mandatory = $false)]
            [ValidateRange(1, [int64]::MaxValue)]
            [int64]$PageFirst,

            [Parameter( Mandatory = $false)]
            [ValidateNotNullOrEmpty()]
            [string]$PageAfter,

            [Parameter( Mandatory = $false)]
            [ValidateRange(1, [int64]::MaxValue)]
            [int64]$PageLast,

            [Parameter( Mandatory = $false)]
            [ValidateNotNullOrEmpty()]
            [string]$PageBefore,

            [Parameter( Mandatory = $false)]
            [switch]$AllResults
        )

        begin {

            $FunctionName       = $MyInvocation.InvocationName
            $ParameterName      = $functionName + '_Parameters'      -replace '-','_'
            $QueryParameterName = $functionName + '_ParametersQuery' -replace '-','_'

        }

        process {

            Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

            $ResourceUri = "/asm/client/info"

            $UriParameters = @{}

            #Region     [ Parameter Translation ]

            if ($PSCmdlet.ParameterSetName -eq 'Index') {
                if ($Include)           { $UriParameters['include']             = $Include }
                if ($FilterQueryDate)   { $UriParameters['filter[queryDate]']   = $FilterQueryDate }
                if ($PageFirst)         { $UriParameters['page[first]']         = $PageFirst }
                if ($PageAfter)         { $UriParameters['page[after]']         = $PageAfter }
                if ($PageLast)          { $UriParameters['page[last]']          = $PageLast }
                if ($PageBefore)        { $UriParameters['page[before]']        = $PageBefore }
            }

            #EndRegion  [ Parameter Translation ]

            Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
            Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

            return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

        }

        end {}

    }
#EndRegion '.\Public\SaaSManagement\Get-AuvikASMClient.ps1' 130
#Region '.\Public\SaaSManagement\Get-AuvikASMSecurityLog.ps1' -1

function Get-AuvikASMSecurityLog {
    <#
        .SYNOPSIS
            Get Auvik ASM security log information

        .DESCRIPTION
            The Get-AuvikASMSecurityLog cmdlet gets multiple ASM security logs' info
            to retrieve the information related to the SaaS applications discovered
            within an ASM client deployment

        .PARAMETER FilterClientId
            Filter by client ID

        .PARAMETER Include
            Use to include extended details of the security log or of its related objects.

            Allowed values:
                "users" "applications"

        .PARAMETER FilterQueryDate
            Return associated breaches added after this date

        .PARAMETER PageFirst
            For paginated responses, the first N elements will be returned
            Used in combination with page[after]

            Default Value: 100

        .PARAMETER PageAfter
            Cursor after which elements will be returned as a page
            The page size is provided by page[first]

        .PARAMETER PageLast
            For paginated responses, the last N services will be returned
            Used in combination with page[before]

            Default Value: 100

        .PARAMETER PageBefore
            Cursor before which elements will be returned as a page
            The page size is provided by page[last]

        .PARAMETER AllResults
            Returns all items from an endpoint

            Highly recommended to only use with filters to reduce API errors\timeouts

        .EXAMPLE
            Get-AuvikASMSecurityLog

            Get Auvik ASM security log information

        .EXAMPLE
            Get-AuvikASMSecurityLog -PageFirst 1000 -AllResults

            Get Auvik ASM security log information for all devices found by Auvik

        .NOTES
        N\A

        .LINK
            https://celerium.github.io/Celerium.Auvik/site/SaaSManagement/Get-AuvikASMSecurityLog.html
    #>

        [CmdletBinding(DefaultParameterSetName = 'Index')]
        Param (
            [Parameter( Mandatory = $false, ValueFromPipeline = $true)]
            [ValidateNotNullOrEmpty()]
            [string]$FilterClientId,

            [Parameter( Mandatory = $false)]
            [ValidateSet( "users", "applications" )]
            [string[]]$Include,

            [Parameter( Mandatory = $false)]
            [DateTime]$FilterQueryDate,

            [Parameter( Mandatory = $false)]
            [ValidateRange(1, [int64]::MaxValue)]
            [int64]$PageFirst,

            [Parameter( Mandatory = $false)]
            [ValidateNotNullOrEmpty()]
            [string]$PageAfter,

            [Parameter( Mandatory = $false)]
            [ValidateRange(1, [int64]::MaxValue)]
            [int64]$PageLast,

            [Parameter( Mandatory = $false)]
            [ValidateNotNullOrEmpty()]
            [string]$PageBefore,

            [Parameter( Mandatory = $false)]
            [switch]$AllResults
        )

        begin {

            $FunctionName       = $MyInvocation.InvocationName
            $ParameterName      = $functionName + '_Parameters'      -replace '-','_'
            $QueryParameterName = $functionName + '_ParametersQuery' -replace '-','_'

        }

        process {

            Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

            $ResourceUri = "/asm/securityLog/info"

            $UriParameters = @{}

            #Region     [ Parameter Translation ]

            if ($PSCmdlet.ParameterSetName -eq 'Index') {
                if ($FilterClientId)    { $UriParameters['filter[clientId]']    = $FilterClientId }
                if ($Include)           { $UriParameters['include']             = $Include }
                if ($FilterQueryDate)   { $UriParameters['filter[queryDate]']   = $FilterQueryDate }
                if ($PageFirst)         { $UriParameters['page[first]']         = $PageFirst }
                if ($PageAfter)         { $UriParameters['page[after]']         = $PageAfter }
                if ($PageLast)          { $UriParameters['page[last]']          = $PageLast }
                if ($PageBefore)        { $UriParameters['page[before]']        = $PageBefore }
            }

            #EndRegion  [ Parameter Translation ]

            Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
            Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

            return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

        }

        end {}

    }
#EndRegion '.\Public\SaaSManagement\Get-AuvikASMSecurityLog.ps1' 138
#Region '.\Public\SaaSManagement\Get-AuvikASMTag.ps1' -1

function Get-AuvikASMTag {
    <#
        .SYNOPSIS
            Get Auvik ASM tag information

        .DESCRIPTION
            The Get-AuvikASMTag cmdlet gets multiple ASM applications' info
            to retrieve the information related to the SaaS applications discovered
            within an ASM client deployment

        .PARAMETER FilterClientId
            Filter by client ID

        .PARAMETER FilterApplicationId
            Filter by application ID

        .PARAMETER PageFirst
            For paginated responses, the first N elements will be returned
            Used in combination with page[after]

            Default Value: 100

        .PARAMETER PageAfter
            Cursor after which elements will be returned as a page
            The page size is provided by page[first]

        .PARAMETER PageLast
            For paginated responses, the last N services will be returned
            Used in combination with page[before]

            Default Value: 100

        .PARAMETER PageBefore
            Cursor before which elements will be returned as a page
            The page size is provided by page[last]

        .PARAMETER AllResults
            Returns all items from an endpoint

            Highly recommended to only use with filters to reduce API errors\timeouts

        .EXAMPLE
            Get-AuvikASMTag

            Get Auvik ASM tag information

        .EXAMPLE
            Get-AuvikASMTag -PageFirst 1000 -AllResults

            Get Auvik ASM tag information for all devices found by Auvik

        .NOTES
        N\A

        .LINK
            https://celerium.github.io/Celerium.Auvik/site/SaaSManagement/Get-AuvikASMTag.html
    #>

        [CmdletBinding(DefaultParameterSetName = 'Index')]
        Param (
            [Parameter( Mandatory = $false, ValueFromPipeline = $true)]
            [ValidateNotNullOrEmpty()]
            [string]$FilterClientId,

            [Parameter( Mandatory = $false, ValueFromPipeline = $true)]
            [ValidateNotNullOrEmpty()]
            [string]$FilterApplicationId,

            [Parameter( Mandatory = $false)]
            [ValidateRange(1, [int64]::MaxValue)]
            [int64]$PageFirst,

            [Parameter( Mandatory = $false)]
            [ValidateNotNullOrEmpty()]
            [string]$PageAfter,

            [Parameter( Mandatory = $false)]
            [ValidateRange(1, [int64]::MaxValue)]
            [int64]$PageLast,

            [Parameter( Mandatory = $false)]
            [ValidateNotNullOrEmpty()]
            [string]$PageBefore,

            [Parameter( Mandatory = $false)]
            [switch]$AllResults
        )

        begin {

            $FunctionName       = $MyInvocation.InvocationName
            $ParameterName      = $functionName + '_Parameters'      -replace '-','_'
            $QueryParameterName = $functionName + '_ParametersQuery' -replace '-','_'

        }

        process {

            Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

            $ResourceUri = "/asm/tag/info"

            $UriParameters = @{}

            #Region     [ Parameter Translation ]

            if ($PSCmdlet.ParameterSetName -eq 'Index') {
                if ($FilterClientId)        { $UriParameters['filter[clientId]']        = $FilterClientId }
                if ($FilterApplicationId)   { $UriParameters['filter[applicationId]']   = $FilterApplicationId }
                if ($PageFirst)             { $UriParameters['page[first]']             = $PageFirst }
                if ($PageAfter)             { $UriParameters['page[after]']             = $PageAfter }
                if ($PageLast)              { $UriParameters['page[last]']              = $PageLast }
                if ($PageBefore)            { $UriParameters['page[before]']            = $PageBefore }
            }

            #EndRegion  [ Parameter Translation ]

            Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
            Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

            return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

        }

        end {}

    }
#EndRegion '.\Public\SaaSManagement\Get-AuvikASMTag.ps1' 128
#Region '.\Public\SaaSManagement\Get-AuvikASMUser.ps1' -1

function Get-AuvikASMUser {
    <#
        .SYNOPSIS
            Get Auvik ASM user information

        .DESCRIPTION
            The Get-AuvikASMUser cmdlet gets information about any monitored
            users that exist within a specific Auvik SaaS Management tenant

        .PARAMETER FilterClientId
            Filter by client ID

        .PARAMETER PageFirst
            For paginated responses, the first N elements will be returned
            Used in combination with page[after]

            Default Value: 100

        .PARAMETER PageAfter
            Cursor after which elements will be returned as a page
            The page size is provided by page[first]

        .PARAMETER PageLast
            For paginated responses, the last N services will be returned
            Used in combination with page[before]

            Default Value: 100

        .PARAMETER PageBefore
            Cursor before which elements will be returned as a page
            The page size is provided by page[last]

        .PARAMETER AllResults
            Returns all items from an endpoint

            Highly recommended to only use with filters to reduce API errors\timeouts

        .EXAMPLE
            Get-AuvikASMUser

            Get Auvik ASM user information

        .EXAMPLE
            Get-AuvikASMUser -PageFirst 1000 -AllResults

            Get Auvik ASM user information for all devices found by Auvik

        .NOTES
        N\A

        .LINK
            https://celerium.github.io/Celerium.Auvik/site/SaaSManagement/Get-AuvikASMUser.html
    #>

        [CmdletBinding(DefaultParameterSetName = 'Index')]
        Param (
            [Parameter( Mandatory = $false, ValueFromPipeline = $true)]
            [ValidateNotNullOrEmpty()]
            [string]$FilterClientId,

            [Parameter( Mandatory = $false)]
            [ValidateRange(1, [int64]::MaxValue)]
            [int64]$PageFirst,

            [Parameter( Mandatory = $false)]
            [ValidateNotNullOrEmpty()]
            [string]$PageAfter,

            [Parameter( Mandatory = $false)]
            [ValidateRange(1, [int64]::MaxValue)]
            [int64]$PageLast,

            [Parameter( Mandatory = $false)]
            [ValidateNotNullOrEmpty()]
            [string]$PageBefore,

            [Parameter( Mandatory = $false)]
            [switch]$AllResults
        )

        begin {

            $FunctionName       = $MyInvocation.InvocationName
            $ParameterName      = $functionName + '_Parameters'      -replace '-','_'
            $QueryParameterName = $functionName + '_ParametersQuery' -replace '-','_'

        }

        process {

            Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

            $ResourceUri = "/asm/user/info"

            $UriParameters = @{}

            #Region     [ Parameter Translation ]

            if ($PSCmdlet.ParameterSetName -eq 'Index') {
                if ($FilterClientId)    { $UriParameters['filter[clientId]']    = $FilterClientId }
                if ($PageFirst)         { $UriParameters['page[first]']         = $PageFirst }
                if ($PageAfter)         { $UriParameters['page[after]']         = $PageAfter }
                if ($PageLast)          { $UriParameters['page[last]']          = $PageLast }
                if ($PageBefore)        { $UriParameters['page[before]']        = $PageBefore }
            }

            #EndRegion  [ Parameter Translation ]

            Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
            Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

            return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

        }

        end {}

    }
#EndRegion '.\Public\SaaSManagement\Get-AuvikASMUser.ps1' 119
#Region '.\Public\Statistics\Get-AuvikComponentStatistics.ps1' -1

function Get-AuvikComponentStatistics {
<#
    .SYNOPSIS
        Provides historical statistics for components
        such as CPUs, disks, fans and memory

    .DESCRIPTION
        The Get-AuvikComponentStatistics cmdlet provides historical
        statistics for components such as CPUs, disks, fans and memory

        Make sure to read the documentation when defining ComponentType & StatId,
        as only certain StatId's work with certain ComponentTypes

        https://auvikapi.us1.my.auvik.com/docs#operation/readInterfaceStatistics

    .PARAMETER ComponentType
        Component type of statistic to return

        Allowed values:
            "cpu", "cpuCore", "disk", "fan", "memory", "powerSupply", "systemBoard"

    .PARAMETER StatId
        ID of statistic to return

        Allowed values:
            "capacity", "counters", "idle", "latency", "power", "queueLatency",
            "rate", "readiness", "ready", "speed", "swap", "swapRate", "temperature",
            "totalLatency", "utilization"

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from

    .PARAMETER FilterFromTime
        Timestamp from which you want to query

    .PARAMETER FilterThruTime
        Timestamp to which you want to query (defaults to current time)

    .PARAMETER FilterInterval
        Statistics reporting interval

        Allowed values:
            "minute", "hour", "day"

    .PARAMETER FilterComponentId
        Filter by component ID

    .PARAMETER FilterParentDevice
        Filter by the entity's parent device ID

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned
        Used in combination with page[after]

        Default Value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page
        The page size is provided by page[first]

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned
        Used in combination with page[before]

        Default Value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page
        The page size is provided by page[last]

    .PARAMETER AllResults
        Returns all items from an endpoint

        Highly recommended to only use with filters to reduce API errors\timeouts

    .EXAMPLE
        Get-AuvikComponentStatistics -ComponentType cpu -StatId latency -FilterFromTime 2023-10-03 -FilterInterval day

        Provides the first 100 historical statistics for CPU components

    .EXAMPLE
        Get-AuvikComponentStatistics -ComponentType cpu -StatId latency -FilterFromTime 2023-10-03 -FilterInterval day -PageFirst 1000 -AllResults

        Provides all historical statistics for CPU components

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Statistics/Get-AuvikComponentStatistics.html
#>

    [CmdletBinding(DefaultParameterSetName = 'Index')]
    Param (
        [Parameter( Mandatory = $true )]
        [ValidateSet( "cpu", "cpuCore", "disk", "fan", "memory", "powerSupply", "systemBoard" )]
        [string]$ComponentType,

        [Parameter( Mandatory = $true )]
        [ValidateSet(   "capacity", "counters", "idle", "latency", "power", "queueLatency",
                        "rate", "readiness", "ready", "speed", "swap", "swapRate", "temperature",
                        "totalLatency", "utilization"
        )]
        [string]$StatId,

        [Parameter( Mandatory = $false, ValueFromPipeline = $true )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter( Mandatory = $true )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterFromTime,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterThruTime,

        [Parameter( Mandatory = $true )]
        [ValidateSet( "minute", "hour", "day" )]
        [string]$FilterInterval,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterComponentId,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterParentDevice,

        [Parameter( Mandatory = $false )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter( Mandatory = $false )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter( Mandatory = $false )]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = $functionName + '_Parameters'      -replace '-','_'
        $QueryParameterName = $functionName + '_ParametersQuery' -replace '-','_'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = "/stat/component/$ComponentType/$StatId"

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -eq 'Index') {
            if ($Tenants)               { $UriParameters['tenants']                 = $Tenants }
            if ($FilterFromTime)        { $UriParameters['filter[fromTime]']        = $FilterFromTime }
            if ($FilterThruTime)        { $UriParameters['filter[thruTime]']        = $FilterThruTime }
            if ($FilterInterval)        { $UriParameters['filter[interval]']        = $FilterInterval }
            if ($FilterComponentId)     { $UriParameters['filter[componentId]']     = $FilterComponentId }
            if ($FilterParentDevice)    { $UriParameters['filter[parentDevice]']    = $FilterParentDevice }
            if ($PageFirst)             { $UriParameters['page[first]']             = $PageFirst }
            if ($PageAfter)             { $UriParameters['page[after]']             = $PageAfter }
            if ($PageLast)              { $UriParameters['page[last]']              = $PageLast }
            if ($PageBefore)            { $UriParameters['page[before]']            = $PageBefore }
        }

        #EndRegion  [ Parameter Translation ]

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

        return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

    }

    end {}

}
#EndRegion '.\Public\Statistics\Get-AuvikComponentStatistics.ps1' 193
#Region '.\Public\Statistics\Get-AuvikDeviceAvailabilityStatistics.ps1' -1

function Get-AuvikDeviceAvailabilityStatistics {
<#
    .SYNOPSIS
        Provides historical device uptime and outage statistics

    .DESCRIPTION
        The Get-AuvikDeviceAvailabilityStatistics cmdlet provides
        historical device uptime and outage statistics

    .PARAMETER StatId
        ID of statistic to return

        Allowed values:
            "uptime", "outage"

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from

    .PARAMETER FilterFromTime
        Timestamp from which you want to query

    .PARAMETER FilterThruTime
        Timestamp to which you want to query (defaults to current time)

    .PARAMETER FilterInterval
        Statistics reporting interval

        Allowed values:
            "minute", "hour", "day"

    .PARAMETER FilterDeviceType
        Filter by device type

        Allowed values:
            "unknown", "switch", "l3Switch", "router", "accessPoint", "firewall",
            "workstation", "server", "storage", "printer", "copier", "hypervisor",
            "multimedia", "phone", "tablet", "handheld", "virtualAppliance", "bridge",
            "controller", "hub", "modem", "ups", "module", "loadBalancer", "camera",
            "telecommunications", "packetProcessor", "chassis", "airConditioner",
            "virtualMachine", "pdu", "ipPhone", "backhaul", "internetOfThings",
            "voipSwitch", "stack", "backupDevice", "timeClock", "lightingDevice",
            "audioVisual", "securityAppliance", "utm", "alarm", "buildingManagement",
            "ipmi", "thinAccessPoint", "thinClient"

    .PARAMETER FilterDeviceId
        Filter by device ID

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned
        Used in combination with page[after]

        Default Value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page
        The page size is provided by page[first]

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned
        Used in combination with page[before]

        Default Value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page
        The page size is provided by page[last]

    .PARAMETER AllResults
        Returns all items from an endpoint

        Highly recommended to only use with filters to reduce API errors\timeouts

    .EXAMPLE
        Get-AuvikDeviceAvailabilityStatistics -StatId uptime -FilterFromTime 2023-10-03 -FilterInterval day

        Provides the first 100 historical device uptime and outage statistics

    .EXAMPLE
        Get-AuvikDeviceAvailabilityStatistics -StatId uptime -FilterFromTime 2023-10-03 -FilterInterval day -PageFirst 1000 -AllResults

        Provides all historical device uptime and outage statistics

    .NOTES
        N\A


    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Statistics/Get-AuvikDeviceAvailabilityStatistics.html
#>

    [CmdletBinding(DefaultParameterSetName = 'Index' )]
    Param (
        [Parameter( Mandatory = $true )]
        [ValidateSet( "uptime", "outage" )]
        [string]$StatId,

        [Parameter( Mandatory = $false, ValueFromPipeline = $true )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter( Mandatory = $true )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterFromTime,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterThruTime,

        [Parameter( Mandatory = $true )]
        [ValidateSet( "minute", "hour", "day" )]
        [string]$FilterInterval,

        [Parameter( Mandatory = $false )]
        [ValidateSet(   "unknown", "switch", "l3Switch", "router", "accessPoint", "firewall",
                        "workstation", "server", "storage", "printer", "copier", "hypervisor",
                        "multimedia", "phone", "tablet", "handheld", "virtualAppliance", "bridge",
                        "controller", "hub", "modem", "ups", "module", "loadBalancer", "camera",
                        "telecommunications", "packetProcessor", "chassis", "airConditioner",
                        "virtualMachine", "pdu", "ipPhone", "backhaul", "internetOfThings",
                        "voipSwitch", "stack", "backupDevice", "timeClock", "lightingDevice",
                        "audioVisual", "securityAppliance", "utm", "alarm", "buildingManagement",
                        "ipmi", "thinAccessPoint", "thinClient"
        )]
        [string]$FilterDeviceType,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterDeviceId,

        [Parameter( Mandatory = $false )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter( Mandatory = $false )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter( Mandatory = $false )]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = $functionName + '_Parameters'      -replace '-','_'
        $QueryParameterName = $functionName + '_ParametersQuery' -replace '-','_'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = "/stat/deviceAvailability/$StatId"

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -eq 'Index') {
            if ($Tenants)           { $UriParameters['tenants']             = $Tenants }
            if ($FilterFromTime)    { $UriParameters['filter[fromTime]']    = $FilterFromTime }
            if ($FilterThruTime)    { $UriParameters['filter[thruTime]']    = $FilterThruTime }
            if ($FilterDeviceType)  { $UriParameters['filter[deviceType]']  = $FilterDeviceType }
            if ($FilterDeviceId)    { $UriParameters['filter[deviceId]']    = $FilterDeviceId }
            if ($PageFirst)         { $UriParameters['page[first]']         = $PageFirst }
            if ($PageAfter)         { $UriParameters['page[after]']         = $PageAfter }
            if ($PageLast)          { $UriParameters['page[last]']          = $PageLast }
            if ($PageBefore)        { $UriParameters['page[before]']        = $PageBefore }
        }

        #EndRegion  [ Parameter Translation ]

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

        return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

    }

    end {}

}
#EndRegion '.\Public\Statistics\Get-AuvikDeviceAvailabilityStatistics.ps1' 192
#Region '.\Public\Statistics\Get-AuvikDeviceStatistics.ps1' -1

function Get-AuvikDeviceStatistics {
<#
    .SYNOPSIS
        Provides historical device statistics such as
        bandwidth, CPU utilization and memory utilization

    .DESCRIPTION
        The Get-AuvikDeviceStatistics cmdlet  provides historical device statistics such as
        bandwidth, CPU utilization and memory utilization

    .PARAMETER StatId
        ID of statistic to return

        Allowed values:
            "bandwidth", "cpuUtilization", "memoryUtilization", "storageUtilization", "packetUnicast", "packetMulticast", "packetBroadcast"

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from

    .PARAMETER FilterFromTime
        Timestamp from which you want to query

    .PARAMETER FilterThruTime
        Timestamp to which you want to query (defaults to current time)

    .PARAMETER FilterInterval
        Statistics reporting interval

        Allowed values:
            "minute", "hour", "day"

    .PARAMETER FilterDeviceType
        Filter by device type

        Allowed values:
            "unknown", "switch", "l3Switch", "router", "accessPoint", "firewall",
            "workstation", "server", "storage", "printer", "copier", "hypervisor",
            "multimedia", "phone", "tablet", "handheld", "virtualAppliance", "bridge",
            "controller", "hub", "modem", "ups", "module", "loadBalancer", "camera",
            "telecommunications", "packetProcessor", "chassis", "airConditioner",
            "virtualMachine", "pdu", "ipPhone", "backhaul", "internetOfThings",
            "voipSwitch", "stack", "backupDevice", "timeClock", "lightingDevice",
            "audioVisual", "securityAppliance", "utm", "alarm", "buildingManagement",
            "ipmi", "thinAccessPoint", "thinClient"

    .PARAMETER FilterDeviceId
        Filter by device ID

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned
        Used in combination with page[after]

        Default Value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page
        The page size is provided by page[first]

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned
        Used in combination with page[before]

        Default Value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page
        The page size is provided by page[last]

    .PARAMETER AllResults
        Returns all items from an endpoint

        Highly recommended to only use with filters to reduce API errors\timeouts

    .EXAMPLE
        Get-AuvikDeviceStatistics -StatId bandwidth -FilterFromTime 2023-10-03 -FilterInterval day

        Provides the first 100 historical device statistics from the
        defined date at the defined interval

    .EXAMPLE
        Get-AuvikDeviceStatistics -StatId bandwidth -FilterFromTime 2023-10-03 -FilterInterval day -PageFirst 1000 -AllResults

        Provides all historical device statistics from the
        defined date at the defined interval

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Statistics/Get-AuvikDeviceStatistics.html
#>

    [CmdletBinding(DefaultParameterSetName = 'Index' )]
    Param (
        [Parameter( Mandatory = $true )]
        [ValidateSet( "bandwidth", "cpuUtilization", "memoryUtilization", "storageUtilization", "packetUnicast", "packetMulticast", "packetBroadcast" )]
        [string]$StatId,

        [Parameter( Mandatory = $false, ValueFromPipeline = $true )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter( Mandatory = $true )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterFromTime,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterThruTime,

        [Parameter( Mandatory = $true )]
        [ValidateSet( "minute", "hour", "day" )]
        [string]$FilterInterval,

        [Parameter( Mandatory = $false )]
        [ValidateSet(   "unknown", "switch", "l3Switch", "router", "accessPoint", "firewall",
                        "workstation", "server", "storage", "printer", "copier", "hypervisor",
                        "multimedia", "phone", "tablet", "handheld", "virtualAppliance", "bridge",
                        "controller", "hub", "modem", "ups", "module", "loadBalancer", "camera",
                        "telecommunications", "packetProcessor", "chassis", "airConditioner",
                        "virtualMachine", "pdu", "ipPhone", "backhaul", "internetOfThings",
                        "voipSwitch", "stack", "backupDevice", "timeClock", "lightingDevice",
                        "audioVisual", "securityAppliance", "utm", "alarm", "buildingManagement",
                        "ipmi", "thinAccessPoint", "thinClient"
        )]
        [string]$FilterDeviceType,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterDeviceId,

        [Parameter( Mandatory = $false )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter( Mandatory = $false )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter( Mandatory = $false )]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = $functionName + '_Parameters'      -replace '-','_'
        $QueryParameterName = $functionName + '_ParametersQuery' -replace '-','_'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = "/stat/device/$StatId"

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -eq 'Index') {
            if ($Tenants)           { $UriParameters['tenants']             = $Tenants }
            if ($FilterFromTime)    { $UriParameters['filter[fromTime]']    = $FilterFromTime }
            if ($FilterThruTime)    { $UriParameters['filter[thruTime]']    = $FilterThruTime }
            if ($FilterInterval)    { $UriParameters['filter[interval]']    = $FilterInterval }
            if ($FilterDeviceType)  { $UriParameters['filter[deviceType]']  = $FilterDeviceType }
            if ($FilterDeviceId)    { $UriParameters['filter[deviceId]']    = $FilterDeviceId }
            if ($PageFirst)         { $UriParameters['page[first]']         = $PageFirst }
            if ($PageAfter)         { $UriParameters['page[after]']         = $PageAfter }
            if ($PageLast)          { $UriParameters['page[last]']          = $PageLast }
            if ($PageBefore)        { $UriParameters['page[before]']        = $PageBefore }
        }

        #EndRegion  [ Parameter Translation ]

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

        return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

    }

    end {}

}
#EndRegion '.\Public\Statistics\Get-AuvikDeviceStatistics.ps1' 195
#Region '.\Public\Statistics\Get-AuvikInterfaceStatistics.ps1' -1

function Get-AuvikInterfaceStatistics {
<#
    .SYNOPSIS
        Provides historical interface statistics such
        as bandwidth and packet loss

    .DESCRIPTION
        The Get-AuvikInterfaceStatistics cmdlet provides historical
        interface statistics such as bandwidth and packet loss

    .PARAMETER StatId
        ID of statistic to return

        Allowed values:
            "bandwidth", "utilization", "packetLoss", "packetDiscard", "packetMulticast", "packetUnicast", "packetBroadcast"

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from

    .PARAMETER FilterFromTime
        Timestamp from which you want to query

    .PARAMETER FilterThruTime
        Timestamp to which you want to query (defaults to current time)

    .PARAMETER FilterInterval
        Statistics reporting interval

        Allowed values:
            "minute", "hour", "day"

    .PARAMETER FilterInterfaceType
        Filter by interface type

        Allowed values:
            "ethernet", "wifi", "bluetooth", "cdma", "coax", "cpu", "distributedVirtualSwitch",
            "firewire", "gsm", "ieee8023AdLag", "inferredWired", "inferredWireless", "interface",
            "linkAggregation", "loopback", "modem", "wimax", "optical", "other", "parallel", "ppp",
            "radiomac", "rs232", "tunnel", "unknown", "usb", "virtualBridge", "virtualNic",
            "virtualSwitch", "vlan"

    .PARAMETER FilterInterfaceId
        Filter by interface ID

    .PARAMETER FilterParentDevice
        Filter by the entity's parent device ID

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned
        Used in combination with page[after]

        Default Value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page
        The page size is provided by page[first]

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned
        Used in combination with page[before]

        Default Value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page
        The page size is provided by page[last]

    .PARAMETER AllResults
        Returns all items from an endpoint

        Highly recommended to only use with filters to reduce API errors\timeouts

    .EXAMPLE
        Get-AuvikInterfaceStatistics -StatId bandwidth -FilterFromTime 2023-10-03 -FilterInterval day

        Provides the first 100 historical interface statistics such
        as bandwidth and packet loss

    .EXAMPLE
        Get-AuvikInterfaceStatistics -StatId bandwidth -FilterFromTime 2023-10-03 -FilterInterval day -PageFirst 1000 -AllResults

        Provides all historical interface statistics such
        as bandwidth and packet loss

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Statistics/Get-AuvikInterfaceStatistics.html
#>

    [CmdletBinding(DefaultParameterSetName = 'Index' )]
    Param (
        [Parameter( Mandatory = $true )]
        [ValidateSet( "bandwidth", "utilization", "packetLoss", "packetDiscard", "packetMulticast", "packetUnicast", "packetBroadcast" )]
        [string]$StatId,

        [Parameter( Mandatory = $false, ValueFromPipeline = $true )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter( Mandatory = $true )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterFromTime,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterThruTime,

        [Parameter( Mandatory = $true )]
        [ValidateSet( "minute", "hour", "day" )]
        [string]$FilterInterval,

        [Parameter( Mandatory = $false )]
        [ValidateSet(   "ethernet", "wifi", "bluetooth", "cdma", "coax", "cpu", "distributedVirtualSwitch",
                        "firewire", "gsm", "ieee8023AdLag", "inferredWired", "inferredWireless", "interface",
                        "linkAggregation", "loopback", "modem", "wimax", "optical", "other", "parallel", "ppp",
                        "radiomac", "rs232", "tunnel", "unknown", "usb", "virtualBridge", "virtualNic",
                        "virtualSwitch", "vlan"
        )]
        [string]$FilterInterfaceType,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterInterfaceId,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterParentDevice,

        [Parameter( Mandatory = $false )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter( Mandatory = $false )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter( Mandatory = $false )]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = $functionName + '_Parameters'      -replace '-','_'
        $QueryParameterName = $functionName + '_ParametersQuery' -replace '-','_'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = "/stat/interface/$StatId"

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -eq 'Index') {
            if ($Tenants)               { $UriParameters['tenants']                 = $Tenants }
            if ($FilterFromTime)        { $UriParameters['filter[fromTime]']        = $FilterFromTime }
            if ($FilterThruTime)        { $UriParameters['filter[thruTime]']        = $FilterThruTime }
            if ($FilterInterval)        { $UriParameters['filter[interval]']        = $FilterInterval }
            if ($FilterInterfaceType)   { $UriParameters['filter[interfaceType]']   = $FilterInterfaceType }
            if ($FilterInterfaceId)     { $UriParameters['filter[interfaceType]']   = $FilterInterfaceType }
            if ($FilterParentDevice)    { $UriParameters['filter[parentDevice]']    = $FilterParentDevice }
            if ($PageFirst)             { $UriParameters['page[first]']             = $PageFirst }
            if ($PageAfter)             { $UriParameters['page[after]']             = $PageAfter }
            if ($PageLast)              { $UriParameters['page[last]']              = $PageLast }
            if ($PageBefore)            { $UriParameters['page[before]']            = $PageBefore }
        }

        #EndRegion  [ Parameter Translation ]

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

        return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

    }

    end {}

}
#EndRegion '.\Public\Statistics\Get-AuvikInterfaceStatistics.ps1' 195
#Region '.\Public\Statistics\Get-AuvikOIDStatistics.ps1' -1

function Get-AuvikOIDStatistics {
<#
    .SYNOPSIS
        Provides the current value for numeric SNMP Pollers

    .DESCRIPTION
        The Get-AuvikOIDStatistics cmdlet provides the current
        value for numeric SNMP Pollers

    .PARAMETER StatId
        ID of statistic to return

        Example: "deviceMonitor"

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from

    .PARAMETER FilterDeviceId
        Filter by device ID

    .PARAMETER FilterDeviceType
        Filter by device type

        Allowed values:
            "unknown", "switch", "l3Switch", "router", "accessPoint", "firewall",
            "workstation", "server", "storage", "printer", "copier", "hypervisor",
            "multimedia", "phone", "tablet", "handheld", "virtualAppliance", "bridge",
            "controller", "hub", "modem", "ups", "module", "loadBalancer", "camera",
            "telecommunications", "packetProcessor", "chassis", "airConditioner",
            "virtualMachine", "pdu", "ipPhone", "backhaul", "internetOfThings",
            "voipSwitch", "stack", "backupDevice", "timeClock", "lightingDevice",
            "audioVisual", "securityAppliance", "utm", "alarm", "buildingManagement",
            "ipmi", "thinAccessPoint", "thinClient"

    .PARAMETER FilterOID
        Filter by OID

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned
        Used in combination with page[after]

        Default Value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page
        The page size is provided by page[first]

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned
        Used in combination with page[before]

        Default Value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page
        The page size is provided by page[last]

    .PARAMETER AllResults
        Returns all items from an endpoint

        Highly recommended to only use with filters to reduce API errors\timeouts

    .EXAMPLE
        Get-AuvikOIDStatistics -StatId deviceMonitor

        Provides the first 100 values for numeric SNMP Pollers

    .EXAMPLE
        Get-AuvikOIDStatistics -StatId deviceMonitor -PageFirst 1000 -AllResults

        Provides all values for numeric SNMP Pollers

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Statistics/Get-AuvikOIDStatistics.html
#>

    [CmdletBinding(DefaultParameterSetName = 'Index' )]
    Param (
        [Parameter( Mandatory = $true )]
        [ValidateNotNullOrEmpty()]
        [string]$StatId,

        [Parameter( Mandatory = $false, ValueFromPipeline = $true )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterDeviceId,

        [Parameter( Mandatory = $false )]
        [ValidateSet(   "unknown", "switch", "l3Switch", "router", "accessPoint", "firewall",
                        "workstation", "server", "storage", "printer", "copier", "hypervisor",
                        "multimedia", "phone", "tablet", "handheld", "virtualAppliance", "bridge",
                        "controller", "hub", "modem", "ups", "module", "loadBalancer", "camera",
                        "telecommunications", "packetProcessor", "chassis", "airConditioner",
                        "virtualMachine", "pdu", "ipPhone", "backhaul", "internetOfThings",
                        "voipSwitch", "stack", "backupDevice", "timeClock", "lightingDevice",
                        "audioVisual", "securityAppliance", "utm", "alarm", "buildingManagement",
                        "ipmi", "thinAccessPoint", "thinClient"
        )]
        [string]$FilterDeviceType,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterOID,

        [Parameter( Mandatory = $false )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter( Mandatory = $false )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter( Mandatory = $false )]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = $functionName + '_Parameters'      -replace '-','_'
        $QueryParameterName = $functionName + '_ParametersQuery' -replace '-','_'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = "/stat/oid/$StatId"

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -eq 'Index') {
            if ($Tenants)           { $UriParameters['tenants']             = $Tenants }
            if ($FilterDeviceId)    { $UriParameters['filter[deviceId]']    = $FilterDeviceId }
            if ($FilterDeviceType)  { $UriParameters['filter[deviceType]']  = $FilterDeviceType }
            if ($FilterOID)         { $UriParameters['filter[oid]']         = $FilterOID}
            if ($PageFirst)         { $UriParameters['page[first]']         = $PageFirst }
            if ($PageAfter)         { $UriParameters['page[after]']         = $PageAfter }
            if ($PageLast)          { $UriParameters['page[last]']          = $PageLast }
            if ($PageBefore)        { $UriParameters['page[before]']        = $PageBefore }
        }

        #EndRegion  [ Parameter Translation ]

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

        return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

    }

    end {}

}
#EndRegion '.\Public\Statistics\Get-AuvikOIDStatistics.ps1' 172
#Region '.\Public\Statistics\Get-AuvikServiceStatistics.ps1' -1

function Get-AuvikServiceStatistics {
<#
    .SYNOPSIS
        Provides historical cloud ping check statistics

    .DESCRIPTION
        The Get-AuvikServiceStatistics cmdlet provides historical
        cloud ping check statistics

    .PARAMETER statId
        ID of statistic to return

        Allowed values:
            "pingTime", "pingPacket"

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from

    .PARAMETER FilterFromTime
        Timestamp from which you want to query

    .PARAMETER FilterThruTime
        Timestamp to which you want to query (defaults to current time)

    .PARAMETER FilterInterval
        Statistics reporting interval

        Allowed values:
            "minute", "hour", "day"

    .PARAMETER FilterServiceId
        Filter by service ID

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned
        Used in combination with page[after]

        Default Value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page
        The page size is provided by page[first]

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned
        Used in combination with page[before]

        Default Value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page
        The page size is provided by page[last]

    .PARAMETER AllResults
        Returns all items from an endpoint

        Highly recommended to only use with filters to reduce API errors\timeouts

    .EXAMPLE
        Get-AuvikServiceStatistics -StatId pingTime -FilterFromTime 2023-10-03 -FilterInterval day

        Provides the first 100 historical cloud ping check statistics

    .EXAMPLE
        Get-AuvikServiceStatistics -StatId pingTime -FilterFromTime 2023-10-03 -FilterInterval day -PageFirst 1000 -AllResults

        Provides all historical cloud ping check statistics

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Statistics/Get-AuvikServiceStatistics.html
#>

    [CmdletBinding(DefaultParameterSetName = 'Index' )]
    Param (
        [Parameter( Mandatory = $true )]
        [ValidateSet( "pingTime", "pingPacket" )]
        [string]$StatId,

        [Parameter( Mandatory = $false, ValueFromPipeline = $true )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter( Mandatory = $true )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterFromTime,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [DateTime]$FilterThruTime,

        [Parameter( Mandatory = $true )]
        [ValidateSet( "minute", "hour", "day" )]
        [string]$FilterInterval,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [string]$FilterServiceId,

        [Parameter( Mandatory = $false )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter( Mandatory = $false )]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter( Mandatory = $false )]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter( Mandatory = $false )]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = $functionName + '_Parameters'      -replace '-','_'
        $QueryParameterName = $functionName + '_ParametersQuery' -replace '-','_'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = "/stat/service/$StatId"

        $UriParameters = @{}

        #Region     [ Parameter Translation ]

        if ($PSCmdlet.ParameterSetName -eq 'Index') {
            if ($Tenants)           { $UriParameters['tenants']             = $Tenants }
            if ($FilterFromTime)    { $UriParameters['filter[fromTime]']    = $FilterFromTime }
            if ($FilterThruTime)    { $UriParameters['filter[thruTime]']    = $FilterThruTime }
            if ($FilterInterval)    { $UriParameters['filter[interval]']    = $FilterInterval }
            if ($FilterServiceId)   { $UriParameters['filter[serviceId]']   = $FilterServiceId }
            if ($PageFirst)         { $UriParameters['page[first]']         = $PageFirst }
            if ($PageAfter)         { $UriParameters['page[after]']         = $PageAfter }
            if ($PageLast)          { $UriParameters['page[last]']          = $PageLast }
            if ($PageBefore)        { $UriParameters['page[before]']        = $PageBefore }
        }

        #EndRegion  [ Parameter Translation ]

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false

        return Invoke-AuvikRequest -Method GET -ResourceUri $ResourceUri -UriFilter $UriParameters -AllResults:$AllResults

    }

    end {}

}
#EndRegion '.\Public\Statistics\Get-AuvikServiceStatistics.ps1' 164
