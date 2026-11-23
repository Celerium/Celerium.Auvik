#Region '.\Private\ApiCalls\ConvertTo-AuvikQueryString.ps1' -1

function ConvertTo-AuvikQueryString {
<#
    .SYNOPSIS
        Converts uri filter parameters

    .DESCRIPTION
        The ConvertTo-AuvikQueryString cmdlet converts & formats uri filter parameters
        from a function which are later used to make the full resource uri for
        an API call

        This is an internal helper function that ties in directly with the
        Invoke-AuvikRequest function & any public functions that define parameters

        The following values are converted to the format the Auvik API expects:
            - Arrays are sent as a comma delimited list
            - Booleans are sent as true or false
            - Dates are sent in UTC as YYYY-MM-DDTHH:MM:SS.sssZ (fromDate & thruDate as YYYY-MM-DD)

    .PARAMETER UriFilter
        Hashtable of values to combine a functions parameters with
        the ResourceUri parameter

        This allows for the full uri query to occur

    .PARAMETER ResourceUri
        Defines the short resource uri (url) to use when creating the API call

    .EXAMPLE
        ConvertTo-AuvikQueryString -UriFilter $UriFilter -ResourceUri '/inventory/device/info'

        Example:
            $UriFilter = @{ 'filter[deviceType]' = 'router'; 'page[first]' = 10 }

            https://auvikapi.us1.my.auvik.com/v1/inventory/device/info?filter%5bdeviceType%5d=router&page%5bfirst%5d=10

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Internal/ConvertTo-AuvikQueryString.html
#>

    [CmdletBinding(DefaultParameterSetName = 'Convert')]
    param (
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [hashtable]$UriFilter,

        [Parameter(Mandatory = $true)]
        [string]$ResourceUri
    )

    begin {

        # Load Web assembly when needed as PowerShell Core has the assembly preloaded
        if ( -not ('System.Web.HttpUtility' -as [type]) ) {
            Add-Type -AssemblyName System.Web
        }

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        if (-not $AuvikModuleBaseURI) {
            throw 'The Auvik base URI is not set. Run Add-AuvikBaseURI to set the base URI.'
        }

        $QueryString = [System.Web.HttpUtility]::ParseQueryString([string]::Empty)

        if ($UriFilter) {

            foreach ($Key in $UriFilter.GetEnumerator()) {

                if ($null -eq $Key.Value) { continue }

                if ($Key.Value -is [array]) {

                    Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - [ $($Key.Key) ] is an array parameter"
                    $QueryString.Add($Key.Key, (@($Key.Value) -join ','))

                }
                elseif ($Key.Value -is [datetime]) {

                    Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - [ $($Key.Key) ] is a dateTime parameter"

                    if ($Key.Key -like '*fromDate*' -or $Key.Key -like '*thruDate*') {
                        $UniversalTime = $Key.Value.ToUniversalTime().ToString('yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture)
                    }
                    else {
                        $UniversalTime = $Key.Value.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ', [System.Globalization.CultureInfo]::InvariantCulture)
                    }

                    Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Converting [ $($Key.Value) ] to [ $UniversalTime ]"
                    $QueryString.Add($Key.Key, $UniversalTime)

                }
                elseif ($Key.Value -is [bool]) { $QueryString.Add($Key.Key, $Key.Value.ToString().ToLowerInvariant()) }
                else { $QueryString.Add($Key.Key, [string]$Key.Value) }

            }

        }

        # Build the request and load it with the query string
        $UriRequest        = [System.UriBuilder]($AuvikModuleBaseURI + $ResourceUri)
        $UriRequest.Query  = $QueryString.ToString()

        return $UriRequest

    }

    end {}

}
#EndRegion '.\Private\ApiCalls\ConvertTo-AuvikQueryString.ps1' 116
#Region '.\Private\ApiCalls\Get-AuvikUriParameter.ps1' -1

function Get-AuvikUriParameter {
<#
    .SYNOPSIS
        Translates the bound parameters of a function to API query parameters

    .DESCRIPTION
        The Get-AuvikUriParameter cmdlet translates the bound parameters of a public function
        into the query parameters (uri filters) used by the Auvik API

        Only the parameters that were bound & are defined in the NameMap are returned. This
        allows a PowerShell friendly parameter name such as [ FilterDeviceType ] to be
        translated to the name the API expects such as [ filter[deviceType] ]

        This is an internal helper function that is used by the public functions

    .PARAMETER BoundParameter
        The $PSBoundParameters of the calling function

    .PARAMETER NameMap
        Hashtable that maps a PowerShell parameter name to an API query parameter name

        Example:
            @{ FilterDeviceType = 'filter[deviceType]'; Tenants = 'tenants' }

    .EXAMPLE
        Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap @{ FilterDeviceType = 'filter[deviceType]' }

        Returns a hashtable such as @{ 'filter[deviceType]' = 'router' } when the FilterDeviceType
        parameter was used by the calling function

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Internal/Get-AuvikUriParameter.html
#>

    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$BoundParameter,

        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$NameMap
    )

    begin {}

    process {

        $UriParameters = @{}

        foreach ($Name in $NameMap.Keys) {

            if ($BoundParameter.Keys -contains $Name) {
                $UriParameters[$NameMap[$Name]] = $BoundParameter[$Name]
            }

        }

        return $UriParameters

    }

    end {}

}
#EndRegion '.\Private\ApiCalls\Get-AuvikUriParameter.ps1' 69
#Region '.\Private\ApiCalls\Invoke-AuvikRequest.ps1' -1

function Invoke-AuvikRequest {
<#
    .SYNOPSIS
        Makes an API request

    .DESCRIPTION
        The Invoke-AuvikRequest cmdlet invokes an API request to the Auvik API

        This is an internal function that is used by all public functions

        As of 2025 the Auvik v1 API supports GET requests & a single POST request (dismissing an alert)

        Requests that are rate limited (429) or fail with a temporary server error (500, 502, 503, 504)
        are retried with an exponential back off

    .PARAMETER Method
        Defines the type of API method to use

        Allowed values:
        'GET', 'POST'

    .PARAMETER ResourceUri
        Defines the resource uri (url) to use when creating the API call

    .PARAMETER UriFilter
        Used with the internal function [ ConvertTo-AuvikQueryString ] to combine
        a functions parameters with the ResourceUri parameter

        This allows for the full uri query to occur

        The full resource path is made with the following data
        $AuvikModuleBaseURI + $ResourceUri + ConvertTo-AuvikQueryString

    .PARAMETER Data
        Place holder parameter to use when other methods are supported
        by the Auvik v1 API

    .PARAMETER AllResults
        Returns all items from an endpoint by following the pagination links

        When using this parameter there is no need to use either the PageFirst, PageAfter,
        PageLast, or PageBefore parameters

    .PARAMETER MaxRetry
        The number of times a rate limited or temporarily failed request is retried

        Only GET requests are retried, write requests are never retried

        Default value: 3

    .PARAMETER RetryDelaySeconds
        The number of seconds to wait before the first retry. The wait doubles with each retry

        Default value: 2

    .EXAMPLE
        Invoke-AuvikRequest -Method GET -ResourceUri '/inventory/device/info' -UriFilter $UriFilter

        Invoke a rest method against the defined resource using any of the provided parameters

        Example:
            Name                           Value
            ----                           -----
            Method                         GET
            Uri                            https://auvikapi.us1.my.auvik.com/v1/inventory/device/info?page%5bfirst%5d=10
            Headers                        {Authorization = Basic 123456789}
            Body

    .NOTES
        The [ Invoke_AuvikRequest_Parameters ] style variables of earlier versions are now named
        [ InvokeAuvikRequestParameters ] & [ InvokeAuvikRequestParametersQuery ]. The Authorization header
        stored in them is always masked

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Internal/Invoke-AuvikRequest.html

#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateSet('GET', 'POST')]
        [string]$Method = 'GET',

        [Parameter(Mandatory = $true)]
        [string]$ResourceUri,

        [Parameter(Mandatory = $false)]
        [hashtable]$UriFilter = $null,

        [Parameter(Mandatory = $false)]
        [hashtable]$Data = $null,

        [Parameter(Mandatory = $false)]
        [switch]$AllResults,

        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 10)]
        [int]$MaxRetry = 3,

        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 300)]
        [int]$RetryDelaySeconds = 2
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = ($FunctionName -replace '-', '') + 'ParametersQuery'

        $RetryStatusCodes   = 429, 500, 502, 503, 504

        function ConvertFrom-AuvikWebResponse {
            # The body is decoded as UTF-8 because Windows PowerShell decodes a response without a charset as ISO-8859-1
            param ($WebResponse)

            $Stream = $WebResponse.RawContentStream
            if ($null -eq $Stream) { return $null }

            $Content = [System.Text.Encoding]::UTF8.GetString($Stream.ToArray()).TrimStart([char]0xFEFF)
            if (-not $Content.Trim()) { return $null }

            $ContentType = "$($WebResponse.Headers['Content-Type'])"
            if ($ContentType -match 'json' -or $Content.TrimStart() -match '^[\{\[]') { return ($Content | ConvertFrom-Json) }

            return $Content
        }

        # Only read requests are retried, a write request could otherwise be applied twice
        if ($Method -ne 'GET') { $MaxRetry = 0 }

        # Windows PowerShell does not always negotiate TLS 1.2 by default
        if ($PSEdition -eq 'Desktop') {
            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        }

    }

    process {

        $QueryString = ConvertTo-AuvikQueryString -UriFilter $UriFilter -ResourceUri $ResourceUri

        Set-Variable -Name $QueryParameterName -Value $QueryString -Scope Global -Force

        if ($null -eq $Data) { $Body = $null }
        else { $Body = @{ 'data' = $Data } | ConvertTo-Json -Depth $AuvikJSONConversionDepth }

        try {

            $ApiToken = Get-AuvikAPIKey -AsPlainText
            if (-not $ApiToken) { throw 'The Auvik API username & key are not set. Run Add-AuvikAPIKey to set them.' }

            $ApiTokenBase64 = [Convert]::ToBase64String( [Text.Encoding]::ASCII.GetBytes( ('{0}:{1}' -f $ApiToken.UserName, $ApiToken.ApiKey) ) )

            $Parameters = [ordered]@{
                'Method'    = $Method
                'Uri'       = $QueryString.Uri
                'Headers'   = @{ 'Authorization' = 'Basic {0}' -f $ApiTokenBase64 }
                'Body'      = $Body
            }

            if ($Method -ne 'GET') { $Parameters['ContentType'] = 'application/vnd.api+json; charset=utf-8' }

            # The variable is made available for troubleshooting, the secret is never stored in it
            $DebugParameters = [ordered]@{}
            foreach ($Key in $Parameters.Keys) { $DebugParameters[$Key] = $Parameters[$Key] }
            $DebugParameters['Headers'] = @{ 'Authorization' = 'Basic *******' }
            Set-Variable -Name $ParameterName -Value $DebugParameters -Scope Global -Force

            $PageNumber         = 1
            $AllResponseData    = [System.Collections.Generic.List[object]]::new()
            $AllIncludedData    = [System.Collections.Generic.List[object]]::new()

            if ($AllResults) { Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Gathering all items from [ $($Parameters.Uri.LocalPath) ]" }
            else { Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Gathering items from [ $($Parameters.Uri.LocalPath) ]" }

            do {

                $Attempt = 0
                $RedirectCount = 0

                do {

                    $Retry = $false
                    $Location = $null

                    try {

                        $WebResponse = Invoke-WebRequest @Parameters -MaximumRedirection 0 -UseBasicParsing -ErrorAction Stop

                        # Windows PowerShell returns a redirect (308) as a response instead of an error
                        if ([int]$WebResponse.StatusCode -in 301, 302, 307, 308) {
                            $Location = "$($WebResponse.Headers['Location'])"
                            if (-not $Location) { throw "The Auvik API returned a [ $([int]$WebResponse.StatusCode) ] redirect without a location" }
                        }
                        else { $CurrentPage = ConvertFrom-AuvikWebResponse -WebResponse $WebResponse }

                    }
                    catch {

                        $StatusCode = if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { 0 }

                        if ($StatusCode -in 301, 302, 307, 308) {

                            $ResponseHeaders = $_.Exception.Response.Headers
                            $Location = if ($ResponseHeaders -is [System.Net.WebHeaderCollection]) { $ResponseHeaders['Location'] } else { "$($ResponseHeaders.Location)" }
                            if (-not $Location) { throw }

                        }
                        elseif ($StatusCode -in $RetryStatusCodes -and $Attempt -lt $MaxRetry) {

                            $Attempt++
                            $Delay = $RetryDelaySeconds * [math]::Pow(2, $Attempt - 1)
                            Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - [ $StatusCode ] returned, retry [ $Attempt of $MaxRetry ] in [ $Delay ] seconds"
                            if ($Delay -gt 0) { Start-Sleep -Seconds $Delay }
                            $Retry = $true

                        }
                        else { throw }

                    }

                    # A request sent to the wrong region is redirected (308). The redirect is handled here because
                    # the Authorization header is removed when a redirect is followed automatically
                    if ($Location) {

                        # Credentials are only ever sent to Auvik
                        if ($Location -notmatch '^https://[A-Za-z0-9.-]+\.my\.auvik\.com(/|$)' -or $RedirectCount -ge 3) { throw "The Auvik API redirected the request to an unexpected location [ $Location ]" }

                        $RedirectCount++
                        $NewUri = [uri]$Location
                        $Parameters['Uri'] = $NewUri

                        $NewBaseUri = "$($NewUri.Scheme)://$($NewUri.Host)/v1"
                        if ($AuvikModuleBaseURI -ne $NewBaseUri) {
                            Write-Warning "The Auvik account is in a different region. The base URI is changed to [ $NewBaseUri ]. Use Add-AuvikBaseURI -DataCenter & Export-AuvikModuleSetting to make this permanent"
                            Add-AuvikBaseURI -BaseUri $NewBaseUri
                        }

                        $Retry = $true

                    }

                } while ($Retry)

                if (-not $AllResults) { $ApiResponse = $CurrentPage; break }

                Write-Verbose "[ $PageNumber ] page(s) gathered"

                foreach ($Item in @($CurrentPage.data)) { if ($null -ne $Item) { $AllResponseData.Add($Item) } }
                foreach ($Item in @($CurrentPage.included)) { if ($null -ne $Item) { $AllIncludedData.Add($Item) } }

                $NextUri = $CurrentPage.links.next
                if ($NextUri -and $NextUri -ne $Parameters['Uri'].ToString()) { $Parameters['Uri'] = [uri]$NextUri }
                else { $NextUri = $null }

                $PageNumber++

            } while ($NextUri)

        }
        catch {

            $ExceptionError = $_.Exception.Message
            $StatusCode     = if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { 0 }

            # The Auvik API returns the details of an error as json
            $ErrorBody   = $_.ErrorDetails.Message
            $ErrorDetail = $null
            if ($ErrorBody) {
                try { $ErrorDetail = ($ErrorBody | ConvertFrom-Json -ErrorAction Stop).errors | ForEach-Object { $_.detail, $_.title | Where-Object { $_ } | Select-Object -First 1 } }
                catch { $ErrorDetail = $ErrorBody }
            }

            Write-Warning "The [ $ParameterName & $QueryParameterName ] global variables can provide extra details"

            switch -Wildcard ("$StatusCode $ExceptionError") {
                '308 *'     { Write-Error "$FunctionName : Permanent Redirect, check assigned region" }
                '*308*'     { Write-Error "$FunctionName : Permanent Redirect, check assigned region" }
                '401 *'     { Write-Error "$FunctionName : Not authorized, check the API username & key - $ErrorDetail" }
                '403 *'     { Write-Error "$FunctionName : Forbidden, check the API user permissions or rate limit - $ErrorDetail" }
                '404 *'     { Write-Error "$FunctionName : Uri not found - [ $ResourceUri ] $ErrorDetail" }
                '429 *'     { Write-Error "$FunctionName : API rate limited" }
                '504 *'     { Write-Error "$FunctionName : Gateway Timeout" }
                default     { if ($ErrorDetail) { Write-Error "$FunctionName : $ExceptionError - $ErrorDetail" } else { Write-Error $_ } }
            }

            return

        }

        if ($AllResults) {

            #Making output consistent
            if ($AllResponseData.Count -eq 0) { $ApiResponse = $null }
            else {

                $ApiResponse = [PSCustomObject]@{
                    data    = $AllResponseData
                    links   = $null
                    meta    = $null
                }

                if ($AllIncludedData.Count -gt 0) { $ApiResponse | Add-Member -NotePropertyName included -NotePropertyValue $AllIncludedData }

            }

        }

        return $ApiResponse

    }

    end {}

}
#EndRegion '.\Private\ApiCalls\Invoke-AuvikRequest.ps1' 318
#Region '.\Private\ApiKeys\Add-AuvikAPIKey.ps1' -1

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
#EndRegion '.\Private\ApiKeys\Add-AuvikAPIKey.ps1' 101
#Region '.\Private\ApiKeys\Get-AuvikAPIKey.ps1' -1

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
#EndRegion '.\Private\ApiKeys\Get-AuvikAPIKey.ps1' 80
#Region '.\Private\ApiKeys\Remove-AuvikAPIKey.ps1' -1

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
#EndRegion '.\Private\ApiKeys\Remove-AuvikAPIKey.ps1' 51
#Region '.\Private\BaseUri\Add-AuvikBaseURI.ps1' -1

function Add-AuvikBaseURI {
<#
    .SYNOPSIS
        Sets the base URI for the Auvik API connection

    .DESCRIPTION
        The Add-AuvikBaseURI cmdlet sets the base URI which is later used
        to construct the full URI for all API calls

    .PARAMETER BaseUri
        Define the base URI for the Auvik API connection using Auvik's URI or a custom URI

        An Auvik host such as us2.my.auvik.com or auvikapi.us2.my.auvik.com is converted to
        https://auvikapi.us2.my.auvik.com/v1 & a URI without a scheme uses https

    .PARAMETER DataCenter
        Auvik's URI connection point that can be one of the predefined data centers

        https://support.auvik.com/hc/en-us/articles/360033412992

        Accepted Values:
        'au1', 'ca1', 'eu', 'eu1', 'eu2', 'us', 'us1', 'us2', 'us3', 'us4', 'us5', 'us6'

        Example:
            us3 = https://auvikapi.us3.my.auvik.com/v1

    .EXAMPLE
        Add-AuvikBaseURI

        The base URI will use https://auvikapi.us1.my.auvik.com/v1 which is Auvik's default URI

    .EXAMPLE
        Add-AuvikBaseURI -DataCenter US

        The base URI will use https://auvikapi.us1.my.auvik.com/v1 which is Auvik's US URI

    .EXAMPLE
        Add-AuvikBaseURI -BaseUri us2.my.auvik.com

        The base URI will use https://auvikapi.us2.my.auvik.com/v1

    .EXAMPLE
        Add-AuvikBaseURI -BaseUri http://myapi.gateway.celerium.org

        A custom API gateway of http://myapi.gateway.celerium.org will be used for all API calls to Auvik's API

    .NOTES
        N/A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Internal/Add-AuvikBaseURI.html
#>

    [CmdletBinding(DefaultParameterSetName = 'Set')]
    param (
        [Parameter(Mandatory = $false , ValueFromPipeline = $true)]
        [string]$BaseUri = 'https://auvikapi.us1.my.auvik.com/v1',

        [Parameter(Mandatory = $false)]
        [ValidateSet( 'au1', 'ca1', 'eu', 'eu1', 'eu2', 'us', 'us1', 'us2', 'us3', 'us4', 'us5', 'us6' )]
        [string]$DataCenter
    )

    begin {}

    process {

        $BaseUri = $BaseUri.Trim().TrimEnd('/')

        # An Auvik host without a scheme or the API prefix (such as us2.my.auvik.com) is converted to the API base URI
        if ($BaseUri -match '^(?:https?://)?(?:auvikapi\.)?(?<Region>[A-Za-z]+\d*)\.my\.auvik\.com(?:/v1)?$') {
            $BaseUri = "https://auvikapi.$($Matches['Region'].ToLowerInvariant()).my.auvik.com/v1"
        }
        elseif ($BaseUri -notmatch '^[A-Za-z][A-Za-z0-9+.-]*://') {
            $BaseUri = "https://$BaseUri"
        }

        if ($DataCenter) {

            # The generic regions are aliases of the first data center in the region
            $Region = switch ($DataCenter) {
                'us'    { 'us1' }
                'eu'    { 'eu1' }
                default { $DataCenter.ToLowerInvariant() }
            }

            $BaseUri = "https://auvikapi.$Region.my.auvik.com/v1"

        }

        Set-Variable -Name 'AuvikModuleBaseURI' -Value $BaseUri -Option ReadOnly -Scope Global -Force

    }

    end {}

}

Set-Alias -Name 'Set-AuvikBaseURI' -Value 'Add-AuvikBaseURI'
#EndRegion '.\Private\BaseUri\Add-AuvikBaseURI.ps1' 100
#Region '.\Private\BaseUri\Get-AuvikBaseURI.ps1' -1

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

    [cmdletbinding(DefaultParameterSetName = 'Destroy', SupportsShouldProcess, ConfirmImpact = 'None')]
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
        Exports the Auvik BaseURI, API, & JSON configuration information to file

    .DESCRIPTION
        The Export-AuvikModuleSetting cmdlet exports the Auvik BaseURI, API, & JSON configuration information to file

        Making use of PowerShell's System.Security.SecureString type, exporting module settings encrypts your API key in a format
        that can only be unencrypted with the your Windows account as this encryption is tied to your user principal
        This means that you cannot copy your configuration file to another computer or user account and expect it to work

    .PARAMETER AuvikConfigPath
        Define the location to store the Auvik configuration file

        By default the configuration file is stored in the following location:
            Windows: $env:USERPROFILE\Celerium.Auvik
            Linux & macOS: $HOME/.Celerium.Auvik

    .PARAMETER AuvikConfigFile
        Define the name of the Auvik configuration file

        By default the configuration file is named:
            config.psd1

    .EXAMPLE
        Export-AuvikModuleSetting

        Validates that the BaseURI, API, and JSON depth are set then exports their values
        to the current user's Auvik configuration file located at:
            $env:USERPROFILE\Celerium.Auvik\config.psd1

    .EXAMPLE
        Export-AuvikModuleSetting -AuvikConfigPath C:\Celerium.Auvik -AuvikConfigFile MyConfig.psd1

        Validates that the BaseURI, API, and JSON depth are set then exports their values
        to the current user's Auvik configuration file located at:
            C:\Celerium.Auvik\MyConfig.psd1

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Internal/Export-AuvikModuleSetting.html
#>

    [CmdletBinding(DefaultParameterSetName = 'Set', SupportsShouldProcess)]
    param (
        [Parameter(ParameterSetName = 'Set')]
        [string]$AuvikConfigPath = $(Join-Path -Path $HOME -ChildPath $(if ($IsWindows -or $PSEdition -eq 'Desktop') { 'Celerium.Auvik' } else { '.Celerium.Auvik' }) ),

        [Parameter(ParameterSetName = 'Set')]
        [string]$AuvikConfigFile = 'config.psd1'
    )

    begin {}

    process {

        Write-Warning 'Secrets are stored using Windows Data Protection API (DPAPI)'
        Write-Warning 'DPAPI provides user context encryption in Windows but NOT in other operating systems like Linux or UNIX. It is recommended to use a more secure & cross-platform storage method'

        $AuvikConfig = Join-Path -Path $AuvikConfigPath -ChildPath $AuvikConfigFile

        # Confirm variables exist and are not null before exporting
        if ($AuvikModuleBaseURI -and $AuvikModuleUserName -and $AuvikModuleApiKey -and $AuvikJSONConversionDepth) {

            $SecureString = $AuvikModuleApiKey | ConvertFrom-SecureString

            if ($PSCmdlet.ShouldProcess($AuvikConfig, 'Export the Auvik module settings')) {

                if ($IsWindows -or $PSEdition -eq 'Desktop') {
                    New-Item -Path $AuvikConfigPath -ItemType Directory -Force | ForEach-Object { $_.Attributes = $_.Attributes -bor 'Hidden' }
                }
                else {
                    New-Item -Path $AuvikConfigPath -ItemType Directory -Force > $null
                }

                $ConfigContent = @"
@{
    AuvikModuleBaseURI          = '$AuvikModuleBaseURI'
    AuvikModuleUserName         = '$AuvikModuleUserName'
    AuvikModuleApiKey           = '$SecureString'
    AuvikJSONConversionDepth    = '$AuvikJSONConversionDepth'
}
"@
                Set-Content -Path $AuvikConfig -Value $ConfigContent -Force -Encoding UTF8

            }

        }
        else {
            Write-Error "Failed to export Auvik Module settings to [ $AuvikConfig ]. The base URI, API username, API key, & JSON depth must be set"
        }

    }

    end {}

}
#EndRegion '.\Private\ModuleSettings\Export-AuvikModuleSetting.ps1' 101
#Region '.\Private\ModuleSettings\Get-AuvikModuleSetting.ps1' -1

function Get-AuvikModuleSetting {
<#
    .SYNOPSIS
        Gets the saved Auvik configuration settings

    .DESCRIPTION
        The Get-AuvikModuleSetting cmdlet gets the saved Auvik configuration settings
        from the local system

        By default the configuration file is stored in the following location:
            $env:USERPROFILE\Celerium.Auvik

    .PARAMETER AuvikConfigPath
        Define the location to store the Auvik configuration file

        By default the configuration file is stored in the following location:
            $env:USERPROFILE\Celerium.Auvik

    .PARAMETER AuvikConfigFile
        Define the name of the Auvik configuration file

        By default the configuration file is named:
            config.psd1

    .PARAMETER OpenConfigFile
        Opens the Auvik configuration file

    .EXAMPLE
        Get-AuvikModuleSetting

        Gets the contents of the configuration file that was created with the
        Export-AuvikModuleSetting

        The default location of the Auvik configuration file is:
            $env:USERPROFILE\Celerium.Auvik\config.psd1

    .EXAMPLE
        Get-AuvikModuleSetting -AuvikConfigPath C:\Celerium.Auvik -AuvikConfigFile MyConfig.psd1 -OpenConfigFile

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
        [string]$AuvikConfigPath = $(Join-Path -Path $home -ChildPath $(if ($IsWindows -or $PSEdition -eq 'Desktop') {"Celerium.Auvik"}else{".Celerium.Auvik"}) ),

        [Parameter(Mandatory = $false, ParameterSetName = 'Index')]
        [String]$AuvikConfigFile = 'config.psd1',

        [Parameter(Mandatory = $false, ParameterSetName = 'show')]
        [Switch]$OpenConfigFile
    )

    begin {
        $AuvikConfig = Join-Path -Path $AuvikConfigPath -ChildPath $AuvikConfigFile
    }

    process {

        if ( Test-Path -Path $AuvikConfig ) {

            if($OpenConfigFile) {
                Invoke-Item -Path $AuvikConfig
            }
            else{
                Import-LocalizedData -BaseDirectory $AuvikConfigPath -FileName $AuvikConfigFile
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
        Imports the Auvik BaseURI, API, & JSON configuration information to the current session

    .DESCRIPTION
        The Import-AuvikModuleSetting cmdlet imports the Auvik BaseURI, API, & JSON configuration
        information stored in the Auvik configuration file to the users current session

        By default the configuration file is stored in the following location:
            Windows: $env:USERPROFILE\Celerium.Auvik
            Linux & macOS: $HOME/.Celerium.Auvik

        The following environment variables take priority over the configuration file which allows
        automation such as GitHub workflows to configure the module without a configuration file:
            AUVIK_BASE_URI  - The base URI of the API, such as https://auvikapi.us1.my.auvik.com/v1
            AUVIK_USERNAME  - The API username
            AUVIK_API_KEY   - The API key

    .PARAMETER AuvikConfigPath
        Define the location to store the Auvik configuration file

        By default the configuration file is stored in the following location:
            Windows: $env:USERPROFILE\Celerium.Auvik
            Linux & macOS: $HOME/.Celerium.Auvik

    .PARAMETER AuvikConfigFile
        Define the name of the Auvik configuration file

        By default the configuration file is named:
            config.psd1

    .EXAMPLE
        Import-AuvikModuleSetting

        Validates that the configuration file created with the Export-AuvikModuleSetting cmdlet exists
        then imports the stored data into the current users session

        The default location of the Auvik configuration file is:
            $env:USERPROFILE\Celerium.Auvik\config.psd1

    .EXAMPLE
        Import-AuvikModuleSetting -AuvikConfigPath C:\Celerium.Auvik -AuvikConfigFile MyConfig.psd1

        Validates that the configuration file created with the Export-AuvikModuleSetting cmdlet exists
        then imports the stored data into the current users session

        The location of the Auvik configuration file in this example is:
            C:\Celerium.Auvik\MyConfig.psd1

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Internal/Import-AuvikModuleSetting.html
#>

    [CmdletBinding(DefaultParameterSetName = 'Set')]
    param (
        [Parameter(ParameterSetName = 'Set')]
        [string]$AuvikConfigPath = $(Join-Path -Path $HOME -ChildPath $(if ($IsWindows -or $PSEdition -eq 'Desktop') { 'Celerium.Auvik' } else { '.Celerium.Auvik' }) ),

        [Parameter(ParameterSetName = 'Set')]
        [string]$AuvikConfigFile = 'config.psd1'
    )

    begin {
        $AuvikConfig = Join-Path -Path $AuvikConfigPath -ChildPath $AuvikConfigFile
    }

    process {

        $ConfigLoaded = $false

        if ( Test-Path -Path $AuvikConfig ) {

            try {

                $TempConfig = Import-LocalizedData -BaseDirectory $AuvikConfigPath -FileName $AuvikConfigFile

                # Send to function to strip potentially superfluous slash (/)
                Add-AuvikBaseURI -BaseUri $TempConfig.AuvikModuleBaseURI

                $SecureKey = ConvertTo-SecureString -String $TempConfig.AuvikModuleApiKey

                Set-Variable -Name 'AuvikModuleUserName' -Value $TempConfig.AuvikModuleUserName -Option ReadOnly -Scope Global -Force
                Set-Variable -Name 'AuvikModuleApiKey' -Value $SecureKey -Option ReadOnly -Scope Global -Force
                Set-Variable -Name 'AuvikJSONConversionDepth' -Value ([int]$TempConfig.AuvikJSONConversionDepth) -Scope Global -Force

                Write-Verbose "Celerium.Auvik Module configuration loaded successfully from [ $AuvikConfig ]"
                $ConfigLoaded = $true

            }
            catch {
                Write-Warning "The Celerium.Auvik configuration file [ $AuvikConfig ] could not be loaded. $($_.Exception.Message)"
            }
            finally { Remove-Variable -Name 'TempConfig' -ErrorAction SilentlyContinue }

        }

        if (-not $ConfigLoaded) {

            Write-Verbose "No configuration file found at [ $AuvikConfig ] run Add-AuvikApiKey to get started."

            Add-AuvikBaseURI
            Set-Variable -Name 'AuvikJSONConversionDepth' -Value 100 -Scope Global -Force

        }

        # Environment variables take priority over the configuration file
        if ($env:AUVIK_BASE_URI) { Add-AuvikBaseURI -BaseUri $env:AUVIK_BASE_URI }

        if ($env:AUVIK_USERNAME -and $env:AUVIK_API_KEY) {
            Add-AuvikAPIKey -Username $env:AUVIK_USERNAME -ApiKey $env:AUVIK_API_KEY
            Write-Verbose 'Celerium.Auvik Module API credentials loaded from the AUVIK_USERNAME & AUVIK_API_KEY environment variables'
        }

    }

    end {}

}
#EndRegion '.\Private\ModuleSettings\Import-AuvikModuleSetting.ps1' 123
#Region '.\Private\ModuleSettings\Initialize-AuvikModuleSetting.ps1' -1

function Initialize-AuvikModuleSetting {
<#
    .SYNOPSIS
        Loads the Auvik module settings when the module is imported

    .DESCRIPTION
        The Initialize-AuvikModuleSetting cmdlet loads either the baseline settings or the saved
        configuration (and the AUVIK_* environment variables) by calling Import-AuvikModuleSetting

        This function is called automatically when the module is imported

    .EXAMPLE
        Initialize-AuvikModuleSetting

        Loads the saved Auvik settings into the current session

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Internal/Initialize-AuvikModuleSetting.html
#>

    [CmdletBinding()]
    param ()

    begin {}

    process {
        Import-AuvikModuleSetting -Verbose:$false
    }

    end {}

}

#Used to auto load either baseline settings or saved configurations when the module is imported
Initialize-AuvikModuleSetting
#EndRegion '.\Private\ModuleSettings\Initialize-AuvikModuleSetting.ps1' 39
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

    .PARAMETER AuvikConfigPath
        Define the location of the Auvik configuration folder

        By default the configuration folder is located at:
            $env:USERPROFILE\Celerium.Auvik

    .PARAMETER AndVariables
        Define if sensitive Auvik variables should be removed as well

        By default the variables are not removed

    .EXAMPLE
        Remove-AuvikModuleSetting

        Checks to see if the default configuration folder exists and removes it if it does

        The default location of the Auvik configuration folder is:
            $env:USERPROFILE\Celerium.Auvik

    .EXAMPLE
        Remove-AuvikModuleSetting -AuvikConfigPath C:\Celerium.Auvik -AndVariables

        Checks to see if the defined configuration folder exists and removes it if it does
        If sensitive Auvik variables exist then they are removed as well

        The location of the Auvik configuration folder in this example is:
            C:\Celerium.Auvik

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Internal/Remove-AuvikModuleSetting.html
#>

    [CmdletBinding(DefaultParameterSetName = 'Destroy', SupportsShouldProcess, ConfirmImpact = 'None')]
    Param (
        [Parameter(ParameterSetName = 'Destroy')]
        [string]$AuvikConfigPath = $(Join-Path -Path $home -ChildPath $(if ($IsWindows -or $PSEdition -eq 'Desktop') {"Celerium.Auvik"}else{".Celerium.Auvik"}) ),

        [Parameter(ParameterSetName = 'Destroy')]
        [switch]$AndVariables
    )

    begin {}

    process {

        if (Test-Path $AuvikConfigPath) {

            Remove-Item -Path $AuvikConfigPath -Recurse -Force -WhatIf:$WhatIfPreference

            If ($AndVariables) {
                Remove-AuvikApiKey
                Remove-AuvikBaseURI
            }

            if (!(Test-Path $AuvikConfigPath)) {
                Write-Output "The Celerium.Auvik configuration folder has been removed successfully from [ $AuvikConfigPath ]"
            }
            else {
                Write-Error "The Celerium.Auvik configuration folder could not be removed from [ $AuvikConfigPath ]"
            }

        }
        else {
            Write-Warning "No configuration folder found at [ $AuvikConfigPath ]"
        }

    }

    end {}

}
#EndRegion '.\Private\ModuleSettings\Remove-AuvikModuleSetting.ps1' 87
#Region '.\Public\Alert\Get-AuvikAlertHistory.ps1' -1

function Get-AuvikAlertHistory {
<#
    .SYNOPSIS
        Read Multiple Alerts' Info / Read a Single Alert's Info

    .DESCRIPTION
        Parameter set [ List ] - The Get-AuvikAlertHistory cmdlet invokes the GET method of the /alert/history/info endpoint (Read Multiple Alerts' Info)

        Use the Read Multiple Alerts' Info API to pull the collected information about the various alerts that Auvik has triggered.

        Parameter set [ ById ] - The Get-AuvikAlertHistory cmdlet invokes the GET method of the /alert/history/info/{id} endpoint (Read a Single Alert's Info)

        Use the Read Single Alert's Info API to pull the collected information about a specific alert that Auvik has triggered.

    .PARAMETER Id
        ID of alert

    .PARAMETER FilterAlertDefinitionId
        Filter by alert definition ID.

    .PARAMETER FilterAlertSpecificationId
        Filter by alert specification ID. Use 'alertDefinitionId' instead

    .PARAMETER FilterSeverity
        Filter by alert severity.

        Allowed values:
        'unknown', 'emergency', 'critical', 'warning', 'info'

    .PARAMETER FilterStatus
        Filter by the status of the alert.

        Allowed values:
        'created', 'resolved', 'paused', 'unpaused'

    .PARAMETER FilterEntityId
        Filter by the related entity ID.

    .PARAMETER FilterDismissed
        Filter by the dismissed status.

    .PARAMETER FilterDispatched
        Filter by dispatched status.

    .PARAMETER FilterDetectedTimeAfter
        Filter by the time which is greater than the given timestamp.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterDetectedTimeBefore
        Filter by the time which is less than or equal to the given timestamp.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from.

        Accepts multiple values which are sent to the API as a comma delimited list

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned. Used in combination with page[after].

        Default value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page. The page size is provided by page[first].

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned. Used in combination with page[before].

        Default value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page. The page size is provided by page[last].

    .PARAMETER AllResults
        Returns all items from the endpoint by following the pagination links

        When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters

        Highly recommended to only use with filters to reduce API errors & timeouts

    .EXAMPLE
        Get-AuvikAlertHistory

        Returns the result of the /alert/history/info endpoint

    .EXAMPLE
        Get-AuvikAlertHistory -Tenants '1234567890' -PageFirst 10

        Returns the result of the /alert/history/info endpoint limited to the defined tenant

    .EXAMPLE
        Get-AuvikAlertHistory -AllResults

        Returns every item from the /alert/history/info endpoint by following the pagination links

    .EXAMPLE
        Get-AuvikAlertHistory -Id '1234567890'

        Returns the result of the /alert/history/info/{id} endpoint

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /alert/history/info
        Endpoint : GET /alert/history/info/{id}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Alert/Get-AuvikAlertHistory.html
#>

    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById')]
        [ValidateNotNullOrEmpty()]
        [string]$Id,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterAlertDefinitionId,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterAlertSpecificationId,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('unknown', 'emergency', 'critical', 'warning', 'info')]
        [string]$FilterSeverity,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('created', 'resolved', 'paused', 'unpaused')]
        [string]$FilterStatus,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterEntityId,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [bool]$FilterDismissed,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [bool]$FilterDispatched,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [datetime]$FilterDetectedTimeAfter,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [datetime]$FilterDetectedTimeBefore,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        switch ($PSCmdlet.ParameterSetName) {
            'ById' {
                $ResourceUri = "/alert/history/info/$([System.Uri]::EscapeDataString($Id))"
                $NameMap = @{}
            }
            'List' {
                $ResourceUri = '/alert/history/info'
                $NameMap = @{
                    FilterAlertDefinitionId    = 'filter[alertDefinitionId]'
                    FilterAlertSpecificationId = 'filter[alertSpecificationId]'
                    FilterSeverity             = 'filter[severity]'
                    FilterStatus               = 'filter[status]'
                    FilterEntityId             = 'filter[entityId]'
                    FilterDismissed            = 'filter[dismissed]'
                    FilterDispatched           = 'filter[dispatched]'
                    FilterDetectedTimeAfter    = 'filter[detectedTimeAfter]'
                    FilterDetectedTimeBefore   = 'filter[detectedTimeBefore]'
                    Tenants                    = 'tenants'
                    PageFirst                  = 'page[first]'
                    PageAfter                  = 'page[after]'
                    PageLast                   = 'page[last]'
                    PageBefore                 = 'page[before]'
                }
            }
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
            AllResults  = $AllResults
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}

Set-Alias -Name 'Get-AuvikAlert' -Value 'Get-AuvikAlertHistory'
#EndRegion '.\Public\Alert\Get-AuvikAlertHistory.ps1' 241
#Region '.\Public\Alert\Send-AuvikAlertDismiss.ps1' -1

function Send-AuvikAlertDismiss {
<#
    .SYNOPSIS
        Dismiss an alert

    .DESCRIPTION
        The Send-AuvikAlertDismiss cmdlet invokes the POST method of the /alert/dismiss/{id} endpoint (Dismiss an alert)

        Use the Dismiss Alert API to dismiss a specific alert that Auvik has triggered

        This is a write function. It changes data in Auvik. Use -WhatIf to see the request without sending it

    .PARAMETER Id
        ID of alert

    .EXAMPLE
        Send-AuvikAlertDismiss -Id '1234567890' -WhatIf

        Shows the POST request to the /alert/dismiss/{id} endpoint without sending it

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : POST /alert/dismiss/{id}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Alert/Send-AuvikAlertDismiss.html
#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Id
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = "/alert/dismiss/$([System.Uri]::EscapeDataString($Id))"
        $NameMap = @{}

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        $InvokeParams = @{
            Method      = 'POST'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        if ($PSCmdlet.ShouldProcess($ResourceUri, "$($MyInvocation.MyCommand.Name) (POST)")) {
            return Invoke-AuvikRequest @InvokeParams
        }

    }

    end {}

}

Set-Alias -Name 'Clear-AuvikAlert' -Value 'Send-AuvikAlertDismiss'
#EndRegion '.\Public\Alert\Send-AuvikAlertDismiss.ps1' 79
#Region '.\Public\Billing\Get-AuvikBillingUsageClient.ps1' -1

function Get-AuvikBillingUsageClient {
<#
    .SYNOPSIS
        Read Client Usage

    .DESCRIPTION
        The Get-AuvikBillingUsageClient cmdlet invokes the GET method of the /billing/usage/client endpoint (Read Client Usage)

        Use the Read Client Usage API to pull a summary of a client's (and client's children if a multi-client) usage for a given time range.

    .PARAMETER FilterFromDate
        Date from which you want to query

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterThruDate
        Date to which you want to query

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from.

        Accepts multiple values which are sent to the API as a comma delimited list

    .EXAMPLE
        Get-AuvikBillingUsageClient -FilterFromDate '2025-01-01T00:00:00Z' -FilterThruDate '2025-01-01T00:00:00Z'

        Returns the result of the /billing/usage/client endpoint

    .EXAMPLE
        Get-AuvikBillingUsageClient -FilterFromDate '2025-01-01T00:00:00Z' -FilterThruDate '2025-01-01T00:00:00Z' -Tenants '1234567890'

        Returns the result of the /billing/usage/client endpoint limited to the defined tenant

    .INPUTS
        None

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /billing/usage/client
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Billing/Get-AuvikBillingUsageClient.html
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [datetime]$FilterFromDate,

        [Parameter(Mandatory = $true)]
        [datetime]$FilterThruDate,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = '/billing/usage/client'
        $NameMap = @{
            FilterFromDate = 'filter[fromDate]'
            FilterThruDate = 'filter[thruDate]'
            Tenants        = 'tenants'
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}

Set-Alias -Name 'Get-AuvikBilling' -Value 'Get-AuvikBillingUsageClient'
#EndRegion '.\Public\Billing\Get-AuvikBillingUsageClient.ps1' 102
#Region '.\Public\Billing\Get-AuvikBillingUsageDevice.ps1' -1

function Get-AuvikBillingUsageDevice {
<#
    .SYNOPSIS
        Read Device Usage

    .DESCRIPTION
        The Get-AuvikBillingUsageDevice cmdlet invokes the GET method of the /billing/usage/device/{id} endpoint (Read Device Usage)

        Use the Read Device Usage API to pull a summary of a client's (and client's children if a multi-client) usage for a given time range.

    .PARAMETER Id
        ID of device

    .PARAMETER FilterFromDate
        Date from which you want to query

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterThruDate
        Date to which you want to query

        Accepts a date & time which is sent to the API in UTC

    .EXAMPLE
        Get-AuvikBillingUsageDevice -Id '1234567890' -FilterFromDate '2025-01-01T00:00:00Z' -FilterThruDate '2025-01-01T00:00:00Z'

        Returns the result of the /billing/usage/device/{id} endpoint

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /billing/usage/device/{id}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Billing/Get-AuvikBillingUsageDevice.html
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Id,

        [Parameter(Mandatory = $true)]
        [datetime]$FilterFromDate,

        [Parameter(Mandatory = $true)]
        [datetime]$FilterThruDate
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = "/billing/usage/device/$([System.Uri]::EscapeDataString($Id))"
        $NameMap = @{
            FilterFromDate = 'filter[fromDate]'
            FilterThruDate = 'filter[thruDate]'
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}
#EndRegion '.\Public\Billing\Get-AuvikBillingUsageDevice.ps1' 92
#Region '.\Public\ClientManagement\Get-AuvikTenant.ps1' -1

function Get-AuvikTenant {
<#
    .SYNOPSIS
        Read Multiple Tenants

    .DESCRIPTION
        The Get-AuvikTenant cmdlet invokes the GET method of the /tenants endpoint (Read Multiple Tenants)

        Use the Read Multiple Tenants API to pull access detail about multiple multi-clients and clients associated with your Auvik user account.

    .EXAMPLE
        Get-AuvikTenant

        Returns the result of the /tenants endpoint

    .INPUTS
        None

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /tenants
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/ClientManagement/Get-AuvikTenant.html
#>

    [CmdletBinding()]
    param (

    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = '/tenants'
        $NameMap = @{}

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}
#EndRegion '.\Public\ClientManagement\Get-AuvikTenant.ps1' 68
#Region '.\Public\ClientManagement\Get-AuvikTenantDetail.ps1' -1

function Get-AuvikTenantDetail {
<#
    .SYNOPSIS
        Read Multiple Tenants Detail / Read Single Tenant Detail

    .DESCRIPTION
        Parameter set [ List ] - The Get-AuvikTenantDetail cmdlet invokes the GET method of the /tenants/detail endpoint (Read Multiple Tenants Detail)

        Use the Read Multiple Tenants API to pull details for multiple multi-clients and clients associated with your main Auvik account.

        Parameter set [ ById ] - The Get-AuvikTenantDetail cmdlet invokes the GET method of the /tenants/detail/{id} endpoint (Read Single Tenant Detail)

        Use the Read a Single Tenant API to pull detail about a specific multi-client and client associated with your main Auvik account. You'll need the tenant ID for the specific multi-client or client you want detail for.

    .PARAMETER Id
        ID of tenant

    .PARAMETER TenantDomainPrefix
        Domain prefix of your main Auvik account (tenant).

    .PARAMETER FilterAvailableTenants
        Filter whether or not a tenant is available, i.e. data can be gotten from them via the API.

    .EXAMPLE
        Get-AuvikTenantDetail -TenantDomainPrefix 'celerium'

        Returns the result of the /tenants/detail endpoint

    .EXAMPLE
        Get-AuvikTenantDetail -Id '1234567890' -TenantDomainPrefix 'celerium'

        Returns the result of the /tenants/detail/{id} endpoint

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /tenants/detail
        Endpoint : GET /tenants/detail/{id}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/ClientManagement/Get-AuvikTenantDetail.html
#>

    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById')]
        [ValidateNotNullOrEmpty()]
        [string]$Id,

        [Parameter(Mandatory = $true, ParameterSetName = 'ById')]
        [Parameter(Mandatory = $true, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$TenantDomainPrefix,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [bool]$FilterAvailableTenants
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        switch ($PSCmdlet.ParameterSetName) {
            'ById' {
                $ResourceUri = "/tenants/detail/$([System.Uri]::EscapeDataString($Id))"
                $NameMap = @{
                    TenantDomainPrefix = 'tenantDomainPrefix'
                }
            }
            'List' {
                $ResourceUri = '/tenants/detail'
                $NameMap = @{
                    TenantDomainPrefix     = 'tenantDomainPrefix'
                    FilterAvailableTenants = 'filter[availableTenants]'
                }
            }
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}
#EndRegion '.\Public\ClientManagement\Get-AuvikTenantDetail.ps1' 110
#Region '.\Public\Inventory\Get-AuvikComponentInfo.ps1' -1

function Get-AuvikComponentInfo {
<#
    .SYNOPSIS
        Read Multiple Components' Info / Read a Single Component's Info

    .DESCRIPTION
        Parameter set [ List ] - The Get-AuvikComponentInfo cmdlet invokes the GET method of the /inventory/component/info endpoint (Read Multiple Components' Info)

        Use the Read Multiple Components' Info API to pull collected information about various device components Auvik has discovered. You'll need the client IDs for the clients you want to run the multiple read against.

        Parameter set [ ById ] - The Get-AuvikComponentInfo cmdlet invokes the GET method of the /inventory/component/info/{id} endpoint (Read a Single Component's Info)

        Use the Read Single Component's Info API to pull collected information about a specific device component Auvik has discovered. You'll need the component ID you want audit detail for.

    .PARAMETER Id
        ID of component

    .PARAMETER FilterModifiedAfter
        Filter by date and time, only returning entities modified after provided value.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterDeviceId
        Filter by the component's parent device's ID.

    .PARAMETER FilterDeviceName
        Filter by the component's parent device's name.

    .PARAMETER FilterCurrentStatus
        Filter by the component's current status.

        Allowed values:
        'ok', 'degraded', 'failed'

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from.

        Accepts multiple values which are sent to the API as a comma delimited list

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned. Used in combination with page[after].

        Default value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page. The page size is provided by page[first].

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned. Used in combination with page[before].

        Default value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page. The page size is provided by page[last].

    .PARAMETER AllResults
        Returns all items from the endpoint by following the pagination links

        When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters

        Highly recommended to only use with filters to reduce API errors & timeouts

    .EXAMPLE
        Get-AuvikComponentInfo

        Returns the result of the /inventory/component/info endpoint

    .EXAMPLE
        Get-AuvikComponentInfo -Tenants '1234567890' -PageFirst 10

        Returns the result of the /inventory/component/info endpoint limited to the defined tenant

    .EXAMPLE
        Get-AuvikComponentInfo -AllResults

        Returns every item from the /inventory/component/info endpoint by following the pagination links

    .EXAMPLE
        Get-AuvikComponentInfo -Id '1234567890'

        Returns the result of the /inventory/component/info/{id} endpoint

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /inventory/component/info
        Endpoint : GET /inventory/component/info/{id}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikComponentInfo.html
#>

    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById')]
        [ValidateNotNullOrEmpty()]
        [string]$Id,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [datetime]$FilterModifiedAfter,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterDeviceId,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterDeviceName,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('ok', 'degraded', 'failed')]
        [string]$FilterCurrentStatus,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        switch ($PSCmdlet.ParameterSetName) {
            'ById' {
                $ResourceUri = "/inventory/component/info/$([System.Uri]::EscapeDataString($Id))"
                $NameMap = @{}
            }
            'List' {
                $ResourceUri = '/inventory/component/info'
                $NameMap = @{
                    FilterModifiedAfter = 'filter[modifiedAfter]'
                    FilterDeviceId      = 'filter[deviceId]'
                    FilterDeviceName    = 'filter[deviceName]'
                    FilterCurrentStatus = 'filter[currentStatus]'
                    Tenants             = 'tenants'
                    PageFirst           = 'page[first]'
                    PageAfter           = 'page[after]'
                    PageLast            = 'page[last]'
                    PageBefore          = 'page[before]'
                }
            }
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
            AllResults  = $AllResults
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}

Set-Alias -Name 'Get-AuvikComponent' -Value 'Get-AuvikComponentInfo'
#EndRegion '.\Public\Inventory\Get-AuvikComponentInfo.ps1' 198
#Region '.\Public\Inventory\Get-AuvikConfiguration.ps1' -1

function Get-AuvikConfiguration {
<#
    .SYNOPSIS
        Read Multiple Device Configurations / Read a Single Device Configuration

    .DESCRIPTION
        Parameter set [ List ] - The Get-AuvikConfiguration cmdlet invokes the GET method of the /inventory/configuration endpoint (Read Multiple Device Configurations)

        Use the Read Multiple Device Configuration API to pull all device configurations. You'll need the client IDs for the clients you want to run the multiple read against.

        Parameter set [ ById ] - The Get-AuvikConfiguration cmdlet invokes the GET method of the /inventory/configuration/{id} endpoint (Read a Single Device Configuration)

        Use the Read Single Device Configuration API to pull a single device configuration. You'll need the client IDs for the clients you want to run the multiple read against.

    .PARAMETER Id
        ID of configuration

    .PARAMETER FilterDeviceId
        Filter by device ID

    .PARAMETER FilterBackupTimeAfter
        Filter by date and time, filtering out configurations backed up before value.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterBackupTimeBefore
        Filter by date and time, filtering out configurations backed up after value.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterIsRunning
        Filter for configurations that are currently running, or filter for all configurations which are not currently running.

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from.

        Accepts multiple values which are sent to the API as a comma delimited list

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned. Used in combination with page[after].

        Default value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page. The page size is provided by page[first].

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned. Used in combination with page[before].

        Default value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page. The page size is provided by page[last].

    .PARAMETER AllResults
        Returns all items from the endpoint by following the pagination links

        When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters

        Highly recommended to only use with filters to reduce API errors & timeouts

    .EXAMPLE
        Get-AuvikConfiguration

        Returns the result of the /inventory/configuration endpoint

    .EXAMPLE
        Get-AuvikConfiguration -Tenants '1234567890' -PageFirst 10

        Returns the result of the /inventory/configuration endpoint limited to the defined tenant

    .EXAMPLE
        Get-AuvikConfiguration -AllResults

        Returns every item from the /inventory/configuration endpoint by following the pagination links

    .EXAMPLE
        Get-AuvikConfiguration -Id '1234567890'

        Returns the result of the /inventory/configuration/{id} endpoint

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /inventory/configuration
        Endpoint : GET /inventory/configuration/{id}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikConfiguration.html
#>

    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById')]
        [ValidateNotNullOrEmpty()]
        [string]$Id,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterDeviceId,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [datetime]$FilterBackupTimeAfter,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [datetime]$FilterBackupTimeBefore,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [bool]$FilterIsRunning,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        switch ($PSCmdlet.ParameterSetName) {
            'ById' {
                $ResourceUri = "/inventory/configuration/$([System.Uri]::EscapeDataString($Id))"
                $NameMap = @{}
            }
            'List' {
                $ResourceUri = '/inventory/configuration'
                $NameMap = @{
                    FilterDeviceId         = 'filter[deviceId]'
                    FilterBackupTimeAfter  = 'filter[backupTimeAfter]'
                    FilterBackupTimeBefore = 'filter[backupTimeBefore]'
                    FilterIsRunning        = 'filter[isRunning]'
                    Tenants                = 'tenants'
                    PageFirst              = 'page[first]'
                    PageAfter              = 'page[after]'
                    PageLast               = 'page[last]'
                    PageBefore             = 'page[before]'
                }
            }
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
            AllResults  = $AllResults
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}
#EndRegion '.\Public\Inventory\Get-AuvikConfiguration.ps1' 192
#Region '.\Public\Inventory\Get-AuvikDeviceDetail.ps1' -1

function Get-AuvikDeviceDetail {
<#
    .SYNOPSIS
        Read Multiple Devices' Details / Read a Single Device's Details

    .DESCRIPTION
        Parameter set [ List ] - The Get-AuvikDeviceDetail cmdlet invokes the GET method of the /inventory/device/detail endpoint (Read Multiple Devices' Details)

        Use the Read Multiple Devices' Details API to pull extra collected information about the various devices Auvik has discovered not already included in the Device Info API. You'll need the client IDs for the clients you want to run the multiple read against.

        Parameter set [ ById ] - The Get-AuvikDeviceDetail cmdlet invokes the GET method of the /inventory/device/detail/{id} endpoint (Read a Single Device's Details)

        Use the Read Single Device's Details API to pull extra collected information about a specific device Auvik has discovered not already included in the Device Info API. You'll need the device ID for the specific device.

    .PARAMETER Id
        ID of device

    .PARAMETER FilterManageStatus
        Filter by managed status

    .PARAMETER FilterDiscoverySNMP
        Filter by the device's SNMP discovery status.

        Allowed values:
        'disabled', 'determining', 'notSupported', 'notAuthorized', 'authorizing', 'authorized', 'privileged'

    .PARAMETER FilterDiscoveryWMI
        Filter by the device's WMI discovery status.

        Allowed values:
        'disabled', 'determining', 'notSupported', 'notAuthorized', 'authorizing', 'authorized', 'privileged'

    .PARAMETER FilterDiscoveryLogin
        Filter by the device's Login discovery status.

        Allowed values:
        'disabled', 'determining', 'notSupported', 'notAuthorized', 'authorizing', 'authorized', 'privileged'

    .PARAMETER FilterDiscoveryVMware
        Filter by the device's VMware discovery status.

        Allowed values:
        'disabled', 'determining', 'notSupported', 'notAuthorized', 'authorizing', 'authorized', 'privileged'

    .PARAMETER FilterTrafficInsightsStatus
        Filter by the device's TrafficInsights status.

        Allowed values:
        'notDetected', 'detected', 'notApproved', 'approved', 'linking', 'linkingFailed', 'forwarding'

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from.

        Accepts multiple values which are sent to the API as a comma delimited list

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned. Used in combination with page[after].

        Default value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page. The page size is provided by page[first].

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned. Used in combination with page[before].

        Default value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page. The page size is provided by page[last].

    .PARAMETER AllResults
        Returns all items from the endpoint by following the pagination links

        When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters

        Highly recommended to only use with filters to reduce API errors & timeouts

    .EXAMPLE
        Get-AuvikDeviceDetail

        Returns the result of the /inventory/device/detail endpoint

    .EXAMPLE
        Get-AuvikDeviceDetail -Tenants '1234567890' -PageFirst 10

        Returns the result of the /inventory/device/detail endpoint limited to the defined tenant

    .EXAMPLE
        Get-AuvikDeviceDetail -AllResults

        Returns every item from the /inventory/device/detail endpoint by following the pagination links

    .EXAMPLE
        Get-AuvikDeviceDetail -Id '1234567890'

        Returns the result of the /inventory/device/detail/{id} endpoint

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /inventory/device/detail
        Endpoint : GET /inventory/device/detail/{id}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikDeviceDetail.html
#>

    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById')]
        [ValidateNotNullOrEmpty()]
        [string]$Id,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [bool]$FilterManageStatus,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('disabled', 'determining', 'notSupported', 'notAuthorized', 'authorizing', 'authorized', 'privileged')]
        [string]$FilterDiscoverySNMP,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('disabled', 'determining', 'notSupported', 'notAuthorized', 'authorizing', 'authorized', 'privileged')]
        [string]$FilterDiscoveryWMI,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('disabled', 'determining', 'notSupported', 'notAuthorized', 'authorizing', 'authorized', 'privileged')]
        [string]$FilterDiscoveryLogin,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('disabled', 'determining', 'notSupported', 'notAuthorized', 'authorizing', 'authorized', 'privileged')]
        [string]$FilterDiscoveryVMware,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('notDetected', 'detected', 'notApproved', 'approved', 'linking', 'linkingFailed', 'forwarding')]
        [string]$FilterTrafficInsightsStatus,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        switch ($PSCmdlet.ParameterSetName) {
            'ById' {
                $ResourceUri = "/inventory/device/detail/$([System.Uri]::EscapeDataString($Id))"
                $NameMap = @{}
            }
            'List' {
                $ResourceUri = '/inventory/device/detail'
                $NameMap = @{
                    FilterManageStatus          = 'filter[manageStatus]'
                    FilterDiscoverySNMP         = 'filter[discoverySNMP]'
                    FilterDiscoveryWMI          = 'filter[discoveryWMI]'
                    FilterDiscoveryLogin        = 'filter[discoveryLogin]'
                    FilterDiscoveryVMware       = 'filter[discoveryVMware]'
                    FilterTrafficInsightsStatus = 'filter[trafficInsightsStatus]'
                    Tenants                     = 'tenants'
                    PageFirst                   = 'page[first]'
                    PageAfter                   = 'page[after]'
                    PageLast                    = 'page[last]'
                    PageBefore                  = 'page[before]'
                }
            }
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
            AllResults  = $AllResults
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}
#EndRegion '.\Public\Inventory\Get-AuvikDeviceDetail.ps1' 226
#Region '.\Public\Inventory\Get-AuvikDeviceDetailExtended.ps1' -1

function Get-AuvikDeviceDetailExtended {
<#
    .SYNOPSIS
        Read Multiple Devices' Extended Details / Read a Single Device's Extended Details

    .DESCRIPTION
        Parameter set [ List ] - The Get-AuvikDeviceDetailExtended cmdlet invokes the GET method of the /inventory/device/detail/extended endpoint (Read Multiple Devices' Extended Details)

        Use the Read Multiple Devices' Extended Details API to get many devices' extended details. Many device types have information collected and tracked by Auvik that are unique to that device type. Use this endpoint to access such information for a given device. You'll need the client IDs for the clients you want to run the multiple read against.

        Parameter set [ ById ] - The Get-AuvikDeviceDetailExtended cmdlet invokes the GET method of the /inventory/device/detail/extended/{id} endpoint (Read a Single Device's Extended Details)

        Use the Read Single Device's Extended Details API to get a device's extended details. Many device types have information collected and tracked by Auvik that are unique to that device type. Use this endpoint to access such information for a given device.

    .PARAMETER Id
        ID of device

    .PARAMETER FilterDeviceType
        Filter by device type.

        Allowed values:
        'unknown', 'switch', 'l3Switch', 'router', 'accessPoint', 'firewall', 'workstation', 'server', 'storage', 'printer', 'copier', 'hypervisor', 'multimedia', 'phone', 'tablet', 'handheld', 'virtualAppliance', 'bridge', 'controller', 'hub', 'modem', 'ups', 'module', 'loadBalancer', 'camera', 'telecommunications', 'packetProcessor', 'chassis', 'airConditioner', 'virtualMachine', 'pdu', 'ipPhone', 'backhaul', 'internetOfThings', 'voipSwitch', 'stack', 'backupDevice', 'timeClock', 'lightingDevice', 'audioVisual', 'securityAppliance', 'utm', 'alarm', 'buildingManagement', 'ipmi', 'thinAccessPoint', 'thinClient', 'subnet'

    .PARAMETER FilterModifiedAfter
        Filter by date and time, only returning entities modified after provided value.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterNotSeenSince
        Filter by the last seen online time, returning entities not seen online after the provided value.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterStateKnown
        Filter by devices with recently updated data, for more consistent results.

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from.

        Accepts multiple values which are sent to the API as a comma delimited list

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned. Used in combination with page[after].

        Default value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page. The page size is provided by page[first].

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned. Used in combination with page[before].

        Default value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page. The page size is provided by page[last].

    .PARAMETER AllResults
        Returns all items from the endpoint by following the pagination links

        When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters

        Highly recommended to only use with filters to reduce API errors & timeouts

    .EXAMPLE
        Get-AuvikDeviceDetailExtended -FilterDeviceType 'unknown'

        Returns the result of the /inventory/device/detail/extended endpoint

    .EXAMPLE
        Get-AuvikDeviceDetailExtended -FilterDeviceType 'unknown' -Tenants '1234567890' -PageFirst 10

        Returns the result of the /inventory/device/detail/extended endpoint limited to the defined tenant

    .EXAMPLE
        Get-AuvikDeviceDetailExtended -FilterDeviceType 'unknown' -AllResults

        Returns every item from the /inventory/device/detail/extended endpoint by following the pagination links

    .EXAMPLE
        Get-AuvikDeviceDetailExtended -Id '1234567890'

        Returns the result of the /inventory/device/detail/extended/{id} endpoint

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /inventory/device/detail/extended
        Endpoint : GET /inventory/device/detail/extended/{id}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikDeviceDetailExtended.html
#>

    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById')]
        [ValidateNotNullOrEmpty()]
        [string]$Id,

        [Parameter(Mandatory = $true, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('unknown', 'switch', 'l3Switch', 'router', 'accessPoint', 'firewall', 'workstation', 'server', 'storage', 'printer', 'copier', 'hypervisor', 'multimedia', 'phone', 'tablet', 'handheld', 'virtualAppliance', 'bridge', 'controller', 'hub', 'modem', 'ups', 'module', 'loadBalancer', 'camera', 'telecommunications', 'packetProcessor', 'chassis', 'airConditioner', 'virtualMachine', 'pdu', 'ipPhone', 'backhaul', 'internetOfThings', 'voipSwitch', 'stack', 'backupDevice', 'timeClock', 'lightingDevice', 'audioVisual', 'securityAppliance', 'utm', 'alarm', 'buildingManagement', 'ipmi', 'thinAccessPoint', 'thinClient', 'subnet')]
        [string]$FilterDeviceType,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [datetime]$FilterModifiedAfter,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [datetime]$FilterNotSeenSince,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [bool]$FilterStateKnown,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        switch ($PSCmdlet.ParameterSetName) {
            'ById' {
                $ResourceUri = "/inventory/device/detail/extended/$([System.Uri]::EscapeDataString($Id))"
                $NameMap = @{}
            }
            'List' {
                $ResourceUri = '/inventory/device/detail/extended'
                $NameMap = @{
                    FilterDeviceType    = 'filter[deviceType]'
                    FilterModifiedAfter = 'filter[modifiedAfter]'
                    FilterNotSeenSince  = 'filter[notSeenSince]'
                    FilterStateKnown    = 'filter[stateKnown]'
                    Tenants             = 'tenants'
                    PageFirst           = 'page[first]'
                    PageAfter           = 'page[after]'
                    PageLast            = 'page[last]'
                    PageBefore          = 'page[before]'
                }
            }
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
            AllResults  = $AllResults
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}
#EndRegion '.\Public\Inventory\Get-AuvikDeviceDetailExtended.ps1' 196
#Region '.\Public\Inventory\Get-AuvikDeviceInfo.ps1' -1

function Get-AuvikDeviceInfo {
<#
    .SYNOPSIS
        Read Multiple Devices' Info / Read a Single Device's Info

    .DESCRIPTION
        Parameter set [ List ] - The Get-AuvikDeviceInfo cmdlet invokes the GET method of the /inventory/device/info endpoint (Read Multiple Devices' Info)

        Use the Read Multiple Devices' Info API to pull the collected information about the various devices Auvik has discovered. You'll need the client IDs for the clients you want to run the multiple read against.

        Parameter set [ ById ] - The Get-AuvikDeviceInfo cmdlet invokes the GET method of the /inventory/device/info/{id} endpoint (Read a Single Device's Info)

        Use the Read Single Device's Info API to pull the collected information about a specific device Auvik has discovered. You'll need the device ID for the specific device.

    .PARAMETER Id
        ID of device

    .PARAMETER Include
        Use to include the full resource objects of the list device relationships.

        Allowed values:
        'deviceDetail'

    .PARAMETER FieldsDeviceDetail
        Use to limit the attributes that will be returned in the included detail object to only what is specified by this query parameter. Requires include=deviceDetail

        Allowed values:
        'discoveryStatus', 'components', 'connectedDevices', 'configurations', 'manageStatus', 'interfaces'

    .PARAMETER FilterNetworks
        Filter by IDs of networks this device is on.

    .PARAMETER FilterDeviceType
        Filter by device type.

        Allowed values:
        'unknown', 'switch', 'l3Switch', 'router', 'accessPoint', 'firewall', 'workstation', 'server', 'storage', 'printer', 'copier', 'hypervisor', 'multimedia', 'phone', 'tablet', 'handheld', 'virtualAppliance', 'bridge', 'controller', 'hub', 'modem', 'ups', 'module', 'loadBalancer', 'camera', 'telecommunications', 'packetProcessor', 'chassis', 'airConditioner', 'virtualMachine', 'pdu', 'ipPhone', 'backhaul', 'internetOfThings', 'voipSwitch', 'stack', 'backupDevice', 'timeClock', 'lightingDevice', 'audioVisual', 'securityAppliance', 'utm', 'alarm', 'buildingManagement', 'ipmi', 'thinAccessPoint', 'thinClient', 'subnet'

    .PARAMETER FilterMakeModel
        Filter by the device's make and model.

    .PARAMETER FilterVendorName
        Filter by the device's vendor/manufacturer.

    .PARAMETER FilterOnlineStatus
        Filter by the device's online status.

        Allowed values:
        'online', 'offline', 'unreachable', 'testing', 'unknown', 'dormant', 'notPresent', 'lowerLayerDown'

    .PARAMETER FilterModifiedAfter
        Filter by date and time, only returning entities modified after provided value.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterNotSeenSince
        Filter by the last seen online time, returning entities not seen online after the provided value.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterStateKnown
        Filter by devices with recently updated data, for more consistent results.

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from.

        Accepts multiple values which are sent to the API as a comma delimited list

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned. Used in combination with page[after].

        Default value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page. The page size is provided by page[first].

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned. Used in combination with page[before].

        Default value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page. The page size is provided by page[last].

    .PARAMETER AllResults
        Returns all items from the endpoint by following the pagination links

        When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters

        Highly recommended to only use with filters to reduce API errors & timeouts

    .EXAMPLE
        Get-AuvikDeviceInfo

        Returns the result of the /inventory/device/info endpoint

    .EXAMPLE
        Get-AuvikDeviceInfo -Tenants '1234567890' -PageFirst 10

        Returns the result of the /inventory/device/info endpoint limited to the defined tenant

    .EXAMPLE
        Get-AuvikDeviceInfo -AllResults

        Returns every item from the /inventory/device/info endpoint by following the pagination links

    .EXAMPLE
        Get-AuvikDeviceInfo -Id '1234567890'

        Returns the result of the /inventory/device/info/{id} endpoint

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /inventory/device/info
        Endpoint : GET /inventory/device/info/{id}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikDeviceInfo.html
#>

    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById')]
        [ValidateNotNullOrEmpty()]
        [string]$Id,

        [Parameter(Mandatory = $false, ParameterSetName = 'ById')]
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('deviceDetail')]
        [string]$Include,

        [Parameter(Mandatory = $false, ParameterSetName = 'ById')]
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('discoveryStatus', 'components', 'connectedDevices', 'configurations', 'manageStatus', 'interfaces')]
        [string]$FieldsDeviceDetail,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterNetworks,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('unknown', 'switch', 'l3Switch', 'router', 'accessPoint', 'firewall', 'workstation', 'server', 'storage', 'printer', 'copier', 'hypervisor', 'multimedia', 'phone', 'tablet', 'handheld', 'virtualAppliance', 'bridge', 'controller', 'hub', 'modem', 'ups', 'module', 'loadBalancer', 'camera', 'telecommunications', 'packetProcessor', 'chassis', 'airConditioner', 'virtualMachine', 'pdu', 'ipPhone', 'backhaul', 'internetOfThings', 'voipSwitch', 'stack', 'backupDevice', 'timeClock', 'lightingDevice', 'audioVisual', 'securityAppliance', 'utm', 'alarm', 'buildingManagement', 'ipmi', 'thinAccessPoint', 'thinClient', 'subnet')]
        [string]$FilterDeviceType,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterMakeModel,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterVendorName,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('online', 'offline', 'unreachable', 'testing', 'unknown', 'dormant', 'notPresent', 'lowerLayerDown')]
        [string]$FilterOnlineStatus,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [datetime]$FilterModifiedAfter,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [datetime]$FilterNotSeenSince,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [bool]$FilterStateKnown,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        switch ($PSCmdlet.ParameterSetName) {
            'ById' {
                $ResourceUri = "/inventory/device/info/$([System.Uri]::EscapeDataString($Id))"
                $NameMap = @{
                    Include            = 'include'
                    FieldsDeviceDetail = 'fields[deviceDetail]'
                }
            }
            'List' {
                $ResourceUri = '/inventory/device/info'
                $NameMap = @{
                    FilterNetworks      = 'filter[networks]'
                    FilterDeviceType    = 'filter[deviceType]'
                    FilterMakeModel     = 'filter[makeModel]'
                    FilterVendorName    = 'filter[vendorName]'
                    FilterOnlineStatus  = 'filter[onlineStatus]'
                    FilterModifiedAfter = 'filter[modifiedAfter]'
                    FilterNotSeenSince  = 'filter[notSeenSince]'
                    FilterStateKnown    = 'filter[stateKnown]'
                    Tenants             = 'tenants'
                    PageFirst           = 'page[first]'
                    PageAfter           = 'page[after]'
                    PageLast            = 'page[last]'
                    PageBefore          = 'page[before]'
                    Include             = 'include'
                    FieldsDeviceDetail  = 'fields[deviceDetail]'
                }
            }
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
            AllResults  = $AllResults
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}

Set-Alias -Name 'Get-AuvikDevice' -Value 'Get-AuvikDeviceInfo'
#EndRegion '.\Public\Inventory\Get-AuvikDeviceInfo.ps1' 263
#Region '.\Public\Inventory\Get-AuvikDeviceLifecycle.ps1' -1

function Get-AuvikDeviceLifecycle {
<#
    .SYNOPSIS
        Read Multiple Devices' Lifecycle Info / Read a Single Device's Lifecycle Info

    .DESCRIPTION
        Parameter set [ List ] - The Get-AuvikDeviceLifecycle cmdlet invokes the GET method of the /inventory/device/lifecycle endpoint (Read Multiple Devices' Lifecycle Info)

        Use the Read Multiple Devices' Lifecycle API to pull the collected lifecycle information about the various devices Auvik has discovered. You'll need the client IDs for the clients you want to run the multiple read against.

        Parameter set [ ById ] - The Get-AuvikDeviceLifecycle cmdlet invokes the GET method of the /inventory/device/lifecycle/{id} endpoint (Read a Single Device's Lifecycle Info)

        Use the Read Single Device's Lifecycle Info API to pull the collected information about a specific device Auvik has discovered. You'll need the device ID for the specific device.

    .PARAMETER Id
        ID of device

    .PARAMETER FilterSalesAvailability
        Filter by sales availability.

        Allowed values:
        'covered', 'available', 'expired', 'securityOnly', 'unpublished', 'empty'

    .PARAMETER FilterSoftwareMaintenanceStatus
        Filter by software maintenance status.

        Allowed values:
        'covered', 'available', 'expired', 'securityOnly', 'unpublished', 'empty'

    .PARAMETER FilterSecuritySoftwareMaintenanceStatus
        Filter by security software maintenance status.

        Allowed values:
        'covered', 'available', 'expired', 'securityOnly', 'unpublished', 'empty'

    .PARAMETER FilterLastSupportStatus
        Filter by last support status.

        Allowed values:
        'covered', 'available', 'expired', 'securityOnly', 'unpublished', 'empty'

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from.

        Accepts multiple values which are sent to the API as a comma delimited list

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned. Used in combination with page[after].

        Default value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page. The page size is provided by page[first].

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned. Used in combination with page[before].

        Default value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page. The page size is provided by page[last].

    .PARAMETER AllResults
        Returns all items from the endpoint by following the pagination links

        When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters

        Highly recommended to only use with filters to reduce API errors & timeouts

    .EXAMPLE
        Get-AuvikDeviceLifecycle

        Returns the result of the /inventory/device/lifecycle endpoint

    .EXAMPLE
        Get-AuvikDeviceLifecycle -Tenants '1234567890' -PageFirst 10

        Returns the result of the /inventory/device/lifecycle endpoint limited to the defined tenant

    .EXAMPLE
        Get-AuvikDeviceLifecycle -AllResults

        Returns every item from the /inventory/device/lifecycle endpoint by following the pagination links

    .EXAMPLE
        Get-AuvikDeviceLifecycle -Id '1234567890'

        Returns the result of the /inventory/device/lifecycle/{id} endpoint

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /inventory/device/lifecycle
        Endpoint : GET /inventory/device/lifecycle/{id}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikDeviceLifecycle.html
#>

    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById')]
        [ValidateNotNullOrEmpty()]
        [string]$Id,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('covered', 'available', 'expired', 'securityOnly', 'unpublished', 'empty')]
        [string]$FilterSalesAvailability,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('covered', 'available', 'expired', 'securityOnly', 'unpublished', 'empty')]
        [string]$FilterSoftwareMaintenanceStatus,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('covered', 'available', 'expired', 'securityOnly', 'unpublished', 'empty')]
        [string]$FilterSecuritySoftwareMaintenanceStatus,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('covered', 'available', 'expired', 'securityOnly', 'unpublished', 'empty')]
        [string]$FilterLastSupportStatus,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        switch ($PSCmdlet.ParameterSetName) {
            'ById' {
                $ResourceUri = "/inventory/device/lifecycle/$([System.Uri]::EscapeDataString($Id))"
                $NameMap = @{}
            }
            'List' {
                $ResourceUri = '/inventory/device/lifecycle'
                $NameMap = @{
                    FilterSalesAvailability                 = 'filter[salesAvailability]'
                    FilterSoftwareMaintenanceStatus         = 'filter[softwareMaintenanceStatus]'
                    FilterSecuritySoftwareMaintenanceStatus = 'filter[securitySoftwareMaintenanceStatus]'
                    FilterLastSupportStatus                 = 'filter[lastSupportStatus]'
                    Tenants                                 = 'tenants'
                    PageFirst                               = 'page[first]'
                    PageAfter                               = 'page[after]'
                    PageLast                                = 'page[last]'
                    PageBefore                              = 'page[before]'
                }
            }
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
            AllResults  = $AllResults
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}
#EndRegion '.\Public\Inventory\Get-AuvikDeviceLifecycle.ps1' 207
#Region '.\Public\Inventory\Get-AuvikDeviceWarranty.ps1' -1

function Get-AuvikDeviceWarranty {
<#
    .SYNOPSIS
        Read Multiple Devices' Warranty Info / Read a Single Device's Warranty Info

    .DESCRIPTION
        Parameter set [ List ] - The Get-AuvikDeviceWarranty cmdlet invokes the GET method of the /inventory/device/warranty endpoint (Read Multiple Devices' Warranty Info)

        Use the Read Multiple Devices' Warranty API to pull the collected warranty information about the various devices Auvik has discovered. You'll need the client IDs for the clients you want to run the multiple read against.

        Parameter set [ ById ] - The Get-AuvikDeviceWarranty cmdlet invokes the GET method of the /inventory/device/warranty/{id} endpoint (Read a Single Device's Warranty Info)

        Use the Read Single Device's Warranty Info API to pull the collected information about a specific device Auvik has discovered. You'll need the device ID for the specific device.

    .PARAMETER Id
        ID of device

    .PARAMETER FilterCoveredUnderWarranty
        Filter by warranty coverage status.

    .PARAMETER FilterCoveredUnderService
        Filter by service coverage status.

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from.

        Accepts multiple values which are sent to the API as a comma delimited list

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned. Used in combination with page[after].

        Default value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page. The page size is provided by page[first].

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned. Used in combination with page[before].

        Default value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page. The page size is provided by page[last].

    .PARAMETER AllResults
        Returns all items from the endpoint by following the pagination links

        When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters

        Highly recommended to only use with filters to reduce API errors & timeouts

    .EXAMPLE
        Get-AuvikDeviceWarranty

        Returns the result of the /inventory/device/warranty endpoint

    .EXAMPLE
        Get-AuvikDeviceWarranty -Tenants '1234567890' -PageFirst 10

        Returns the result of the /inventory/device/warranty endpoint limited to the defined tenant

    .EXAMPLE
        Get-AuvikDeviceWarranty -AllResults

        Returns every item from the /inventory/device/warranty endpoint by following the pagination links

    .EXAMPLE
        Get-AuvikDeviceWarranty -Id '1234567890'

        Returns the result of the /inventory/device/warranty/{id} endpoint

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /inventory/device/warranty
        Endpoint : GET /inventory/device/warranty/{id}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikDeviceWarranty.html
#>

    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById')]
        [ValidateNotNullOrEmpty()]
        [string]$Id,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [bool]$FilterCoveredUnderWarranty,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [bool]$FilterCoveredUnderService,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        switch ($PSCmdlet.ParameterSetName) {
            'ById' {
                $ResourceUri = "/inventory/device/warranty/$([System.Uri]::EscapeDataString($Id))"
                $NameMap = @{}
            }
            'List' {
                $ResourceUri = '/inventory/device/warranty'
                $NameMap = @{
                    FilterCoveredUnderWarranty = 'filter[coveredUnderWarranty]'
                    FilterCoveredUnderService  = 'filter[coveredUnderService]'
                    Tenants                    = 'tenants'
                    PageFirst                  = 'page[first]'
                    PageAfter                  = 'page[after]'
                    PageLast                   = 'page[last]'
                    PageBefore                 = 'page[before]'
                }
            }
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
            AllResults  = $AllResults
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}
#EndRegion '.\Public\Inventory\Get-AuvikDeviceWarranty.ps1' 173
#Region '.\Public\Inventory\Get-AuvikEntityAudit.ps1' -1

function Get-AuvikEntityAudit {
<#
    .SYNOPSIS
        Read Multiple Entity Audits / Read a Single Entity Audit

    .DESCRIPTION
        Parameter set [ List ] - The Get-AuvikEntityAudit cmdlet invokes the GET method of the /inventory/entity/audit endpoint (Read Multiple Entity Audits)

        Use the Read Multiple Entity Audits API pull information about multiple entity audits for you clients. You'll need the client IDs for the clients you want to run the multiple read against.

        Parameter set [ ById ] - The Get-AuvikEntityAudit cmdlet invokes the GET method of the /inventory/entity/audit/{id} endpoint (Read a Single Entity Audit)

        Use the Single Multiple Entity Audit API pull information about a single entity audit. You'll need the audit entry ID for the specific audit.

    .PARAMETER Id
        ID of entity audit

    .PARAMETER FilterUser
        Filter by user name associated to the audit.

    .PARAMETER FilterCategory
        Filter by the audit's category.

        Allowed values:
        'unknown', 'tunnel', 'terminal', 'remoteBrowser'

    .PARAMETER FilterStatus
        Filter by the audit's status.

        Allowed values:
        'unknown', 'initiated', 'created', 'closed', 'failed'

    .PARAMETER FilterModifiedAfter
        Filter by date and time, only returning entities modified after provided value.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from.

        Accepts multiple values which are sent to the API as a comma delimited list

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned. Used in combination with page[after].

        Default value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page. The page size is provided by page[first].

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned. Used in combination with page[before].

        Default value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page. The page size is provided by page[last].

    .PARAMETER AllResults
        Returns all items from the endpoint by following the pagination links

        When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters

        Highly recommended to only use with filters to reduce API errors & timeouts

    .EXAMPLE
        Get-AuvikEntityAudit

        Returns the result of the /inventory/entity/audit endpoint

    .EXAMPLE
        Get-AuvikEntityAudit -Tenants '1234567890' -PageFirst 10

        Returns the result of the /inventory/entity/audit endpoint limited to the defined tenant

    .EXAMPLE
        Get-AuvikEntityAudit -AllResults

        Returns every item from the /inventory/entity/audit endpoint by following the pagination links

    .EXAMPLE
        Get-AuvikEntityAudit -Id '1234567890'

        Returns the result of the /inventory/entity/audit/{id} endpoint

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /inventory/entity/audit
        Endpoint : GET /inventory/entity/audit/{id}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikEntityAudit.html
#>

    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById')]
        [ValidateNotNullOrEmpty()]
        [string]$Id,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterUser,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('unknown', 'tunnel', 'terminal', 'remoteBrowser')]
        [string]$FilterCategory,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('unknown', 'initiated', 'created', 'closed', 'failed')]
        [string]$FilterStatus,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [datetime]$FilterModifiedAfter,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        switch ($PSCmdlet.ParameterSetName) {
            'ById' {
                $ResourceUri = "/inventory/entity/audit/$([System.Uri]::EscapeDataString($Id))"
                $NameMap = @{}
            }
            'List' {
                $ResourceUri = '/inventory/entity/audit'
                $NameMap = @{
                    FilterUser          = 'filter[user]'
                    FilterCategory      = 'filter[category]'
                    FilterStatus        = 'filter[status]'
                    FilterModifiedAfter = 'filter[modifiedAfter]'
                    Tenants             = 'tenants'
                    PageFirst           = 'page[first]'
                    PageAfter           = 'page[after]'
                    PageLast            = 'page[last]'
                    PageBefore          = 'page[before]'
                }
            }
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
            AllResults  = $AllResults
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}
#EndRegion '.\Public\Inventory\Get-AuvikEntityAudit.ps1' 200
#Region '.\Public\Inventory\Get-AuvikEntityNote.ps1' -1

function Get-AuvikEntityNote {
<#
    .SYNOPSIS
        Read Multiple Entity Notes / Read a Single Entity Note

    .DESCRIPTION
        Parameter set [ List ] - The Get-AuvikEntityNote cmdlet invokes the GET method of the /inventory/entity/note endpoint (Read Multiple Entity Notes)

        Use the Read Multiple Entity Notes API pull information about multiple entity notes. You'll need the client IDs for the clients you want to run the multiple read against.

        Parameter set [ ById ] - The Get-AuvikEntityNote cmdlet invokes the GET method of the /inventory/entity/note/{id} endpoint (Read a Single Entity Note)

        Use the Read Single Entity Note API to pull the information about a specific entity note. You'll need the entity note ID for the specific entity note.

    .PARAMETER Id
        ID of entity note

    .PARAMETER FilterEntityId
        Filter by the entity's ID.

    .PARAMETER FilterEntityType
        Filter by the entity's type.

        Allowed values:
        'root', 'device', 'network', 'interface'

    .PARAMETER FilterEntityName
        Filter by the entity's name.

    .PARAMETER FilterLastModifiedBy
        Filter by the user the note was last modified by.

    .PARAMETER FilterModifiedAfter
        Filter by date and time, only returning entities modified after provided value.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from.

        Accepts multiple values which are sent to the API as a comma delimited list

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned. Used in combination with page[after].

        Default value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page. The page size is provided by page[first].

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned. Used in combination with page[before].

        Default value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page. The page size is provided by page[last].

    .PARAMETER AllResults
        Returns all items from the endpoint by following the pagination links

        When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters

        Highly recommended to only use with filters to reduce API errors & timeouts

    .EXAMPLE
        Get-AuvikEntityNote

        Returns the result of the /inventory/entity/note endpoint

    .EXAMPLE
        Get-AuvikEntityNote -Tenants '1234567890' -PageFirst 10

        Returns the result of the /inventory/entity/note endpoint limited to the defined tenant

    .EXAMPLE
        Get-AuvikEntityNote -AllResults

        Returns every item from the /inventory/entity/note endpoint by following the pagination links

    .EXAMPLE
        Get-AuvikEntityNote -Id '1234567890'

        Returns the result of the /inventory/entity/note/{id} endpoint

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /inventory/entity/note
        Endpoint : GET /inventory/entity/note/{id}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikEntityNote.html
#>

    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById')]
        [ValidateNotNullOrEmpty()]
        [string]$Id,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterEntityId,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('root', 'device', 'network', 'interface')]
        [string]$FilterEntityType,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterEntityName,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterLastModifiedBy,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [datetime]$FilterModifiedAfter,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        switch ($PSCmdlet.ParameterSetName) {
            'ById' {
                $ResourceUri = "/inventory/entity/note/$([System.Uri]::EscapeDataString($Id))"
                $NameMap = @{}
            }
            'List' {
                $ResourceUri = '/inventory/entity/note'
                $NameMap = @{
                    FilterEntityId       = 'filter[entityId]'
                    FilterEntityType     = 'filter[entityType]'
                    FilterEntityName     = 'filter[entityName]'
                    FilterLastModifiedBy = 'filter[lastModifiedBy]'
                    FilterModifiedAfter  = 'filter[modifiedAfter]'
                    Tenants              = 'tenants'
                    PageFirst            = 'page[first]'
                    PageAfter            = 'page[after]'
                    PageLast             = 'page[last]'
                    PageBefore           = 'page[before]'
                }
            }
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
            AllResults  = $AllResults
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}

Set-Alias -Name 'Get-AuvikEntity' -Value 'Get-AuvikEntityNote'
#EndRegion '.\Public\Inventory\Get-AuvikEntityNote.ps1' 206
#Region '.\Public\Inventory\Get-AuvikInterfaceInfo.ps1' -1

function Get-AuvikInterfaceInfo {
<#
    .SYNOPSIS
        Read Multiple Interfaces Info / Read a Single Interfaces Info

    .DESCRIPTION
        Parameter set [ List ] - The Get-AuvikInterfaceInfo cmdlet invokes the GET method of the /inventory/interface/info endpoint (Read Multiple Interfaces Info)

        Use the Read Multiple Interfaces Info API to pull the collected information about the various device interfaces Auvik has discovered. You'll need the client IDs for the clients you want to run the multiple read against.

        Parameter set [ ById ] - The Get-AuvikInterfaceInfo cmdlet invokes the GET method of the /inventory/interface/info/{id} endpoint (Read a Single Interfaces Info)

        Use the Read Single Interface Info API to pull the collected information about a specific device interface Auvik has discovered. You'll need the interface ID for the specific interface.

    .PARAMETER Id
        ID of interface

    .PARAMETER FilterInterfaceType
        Filter by interface type.

        Allowed values:
        'ethernet', 'wifi', 'bluetooth', 'cdma', 'coax', 'cpu', 'distributedVirtualSwitch', 'firewire', 'gsm', 'ieee8023AdLag', 'inferredWired', 'inferredWireless', 'interface', 'linkAggregation', 'loopback', 'modem', 'wimax', 'optical', 'other', 'parallel', 'ppp', 'radiomac', 'rs232', 'tunnel', 'unknown', 'usb', 'virtualBridge', 'virtualNic', 'virtualSwitch', 'vlan'

    .PARAMETER FilterParentDevice
        Filter by the entity's parent device ID.

    .PARAMETER FilterAdminStatus
        Filter by the interface's admin status.

    .PARAMETER FilterOperationalStatus
        Filter by the interface's operational status.

        Allowed values:
        'online', 'offline', 'unreachable', 'testing', 'unknown', 'dormant', 'notPresent', 'lowerLayerDown'

    .PARAMETER FilterModifiedAfter
        Filter by date and time, only returning entities modified after provided value.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from.

        Accepts multiple values which are sent to the API as a comma delimited list

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned. Used in combination with page[after].

        Default value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page. The page size is provided by page[first].

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned. Used in combination with page[before].

        Default value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page. The page size is provided by page[last].

    .PARAMETER AllResults
        Returns all items from the endpoint by following the pagination links

        When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters

        Highly recommended to only use with filters to reduce API errors & timeouts

    .EXAMPLE
        Get-AuvikInterfaceInfo

        Returns the result of the /inventory/interface/info endpoint

    .EXAMPLE
        Get-AuvikInterfaceInfo -Tenants '1234567890' -PageFirst 10

        Returns the result of the /inventory/interface/info endpoint limited to the defined tenant

    .EXAMPLE
        Get-AuvikInterfaceInfo -AllResults

        Returns every item from the /inventory/interface/info endpoint by following the pagination links

    .EXAMPLE
        Get-AuvikInterfaceInfo -Id '1234567890'

        Returns the result of the /inventory/interface/info/{id} endpoint

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /inventory/interface/info
        Endpoint : GET /inventory/interface/info/{id}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikInterfaceInfo.html
#>

    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById')]
        [ValidateNotNullOrEmpty()]
        [string]$Id,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('ethernet', 'wifi', 'bluetooth', 'cdma', 'coax', 'cpu', 'distributedVirtualSwitch', 'firewire', 'gsm', 'ieee8023AdLag', 'inferredWired', 'inferredWireless', 'interface', 'linkAggregation', 'loopback', 'modem', 'wimax', 'optical', 'other', 'parallel', 'ppp', 'radiomac', 'rs232', 'tunnel', 'unknown', 'usb', 'virtualBridge', 'virtualNic', 'virtualSwitch', 'vlan')]
        [string]$FilterInterfaceType,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterParentDevice,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [bool]$FilterAdminStatus,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('online', 'offline', 'unreachable', 'testing', 'unknown', 'dormant', 'notPresent', 'lowerLayerDown')]
        [string]$FilterOperationalStatus,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [datetime]$FilterModifiedAfter,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        switch ($PSCmdlet.ParameterSetName) {
            'ById' {
                $ResourceUri = "/inventory/interface/info/$([System.Uri]::EscapeDataString($Id))"
                $NameMap = @{}
            }
            'List' {
                $ResourceUri = '/inventory/interface/info'
                $NameMap = @{
                    FilterInterfaceType     = 'filter[interfaceType]'
                    FilterParentDevice      = 'filter[parentDevice]'
                    FilterAdminStatus       = 'filter[adminStatus]'
                    FilterOperationalStatus = 'filter[operationalStatus]'
                    FilterModifiedAfter     = 'filter[modifiedAfter]'
                    Tenants                 = 'tenants'
                    PageFirst               = 'page[first]'
                    PageAfter               = 'page[after]'
                    PageLast                = 'page[last]'
                    PageBefore              = 'page[before]'
                }
            }
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
            AllResults  = $AllResults
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}

Set-Alias -Name 'Get-AuvikInterface' -Value 'Get-AuvikInterfaceInfo'
#EndRegion '.\Public\Inventory\Get-AuvikInterfaceInfo.ps1' 209
#Region '.\Public\Inventory\Get-AuvikNetworkDetail.ps1' -1

function Get-AuvikNetworkDetail {
<#
    .SYNOPSIS
        Read Multiple Networks' Details / Read a Single Network's Details

    .DESCRIPTION
        Parameter set [ List ] - The Get-AuvikNetworkDetail cmdlet invokes the GET method of the /inventory/network/detail endpoint (Read Multiple Networks' Details)

        Use the Read Multiple Networks' Details API to pull extra collected information about the various networks Auvik has discovered not already included in the Network Info API. You'll need the client IDs for the clients you want to run the multiple read against.

        Parameter set [ ById ] - The Get-AuvikNetworkDetail cmdlet invokes the GET method of the /inventory/network/detail/{id} endpoint (Read a Single Network's Details)

        Use the Read Single Networks's Details API to pull extra collected information about a specific network Auvik has discovered not already included in the network Info API. You'll need the network ID for the specific network.

    .PARAMETER Id
        ID of network

    .PARAMETER FilterNetworkType
        Filter by network type.

        Allowed values:
        'routed', 'vlan', 'wifi', 'loopback', 'network', 'layer2', 'internet'

    .PARAMETER FilterScanStatus
        Filter by the network's scan status.

        Allowed values:
        'true', 'false', 'notAllowed', 'unknown'

    .PARAMETER FilterDevices
        Filter by IDs of devices on this network. Filter by multiple values by providing a comma delimited list.

        Accepts multiple values which are sent to the API as a comma delimited list

    .PARAMETER FilterModifiedAfter
        Filter by date and time, only returning entities modified after provided value.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterScope
        Filter by the network's scope

        Allowed values:
        'private', 'public'

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from.

        Accepts multiple values which are sent to the API as a comma delimited list

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned. Used in combination with page[after].

        Default value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page. The page size is provided by page[first].

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned. Used in combination with page[before].

        Default value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page. The page size is provided by page[last].

    .PARAMETER AllResults
        Returns all items from the endpoint by following the pagination links

        When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters

        Highly recommended to only use with filters to reduce API errors & timeouts

    .EXAMPLE
        Get-AuvikNetworkDetail

        Returns the result of the /inventory/network/detail endpoint

    .EXAMPLE
        Get-AuvikNetworkDetail -Tenants '1234567890' -PageFirst 10

        Returns the result of the /inventory/network/detail endpoint limited to the defined tenant

    .EXAMPLE
        Get-AuvikNetworkDetail -AllResults

        Returns every item from the /inventory/network/detail endpoint by following the pagination links

    .EXAMPLE
        Get-AuvikNetworkDetail -Id '1234567890'

        Returns the result of the /inventory/network/detail/{id} endpoint

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /inventory/network/detail
        Endpoint : GET /inventory/network/detail/{id}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikNetworkDetail.html
#>

    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById')]
        [ValidateNotNullOrEmpty()]
        [string]$Id,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('routed', 'vlan', 'wifi', 'loopback', 'network', 'layer2', 'internet')]
        [string]$FilterNetworkType,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('true', 'false', 'notAllowed', 'unknown')]
        [string]$FilterScanStatus,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string[]]$FilterDevices,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [datetime]$FilterModifiedAfter,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('private', 'public')]
        [string]$FilterScope,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        switch ($PSCmdlet.ParameterSetName) {
            'ById' {
                $ResourceUri = "/inventory/network/detail/$([System.Uri]::EscapeDataString($Id))"
                $NameMap = @{}
            }
            'List' {
                $ResourceUri = '/inventory/network/detail'
                $NameMap = @{
                    FilterNetworkType   = 'filter[networkType]'
                    FilterScanStatus    = 'filter[scanStatus]'
                    FilterDevices       = 'filter[devices]'
                    FilterModifiedAfter = 'filter[modifiedAfter]'
                    FilterScope         = 'filter[scope]'
                    Tenants             = 'tenants'
                    PageFirst           = 'page[first]'
                    PageAfter           = 'page[after]'
                    PageLast            = 'page[last]'
                    PageBefore          = 'page[before]'
                }
            }
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
            AllResults  = $AllResults
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}
#EndRegion '.\Public\Inventory\Get-AuvikNetworkDetail.ps1' 214
#Region '.\Public\Inventory\Get-AuvikNetworkInfo.ps1' -1

function Get-AuvikNetworkInfo {
<#
    .SYNOPSIS
        Read Multiple Networks' Info / Read a Single Network's Info

    .DESCRIPTION
        Parameter set [ List ] - The Get-AuvikNetworkInfo cmdlet invokes the GET method of the /inventory/network/info endpoint (Read Multiple Networks' Info)

        Use the Read Multiple Networks' Info API to pull the collected information about the various networks Auvik has discovered. You'll need the client IDs for the clients you want to run the multiple read against.

        Parameter set [ ById ] - The Get-AuvikNetworkInfo cmdlet invokes the GET method of the /inventory/network/info/{id} endpoint (Read a Single Network's Info)

        Use the Read Single Network's Info API to pull the collected information about a specific network Auvik has discovered. You'll need the network ID for the specific network.

    .PARAMETER Id
        ID of network

    .PARAMETER Include
        Use to include the full resource objects of any of the network's relationships.

        Allowed values:
        'networkDetail'

    .PARAMETER FieldsNetworkDetail
        Use to limit the attributes that will be returned in the included detail object to only what is specified by this query parameter. Requires include=networkDetail

        Allowed values:
        'scope', 'primaryCollector', 'secondaryCollectors', 'collectorSelection', 'excludedIpAddresses'

    .PARAMETER FilterNetworkType
        Filter by network type.

        Allowed values:
        'routed', 'vlan', 'wifi', 'loopback', 'network', 'layer2', 'internet'

    .PARAMETER FilterScanStatus
        Filter by the network's scan status.

        Allowed values:
        'true', 'false', 'notAllowed', 'unknown'

    .PARAMETER FilterDevices
        Filter by IDs of devices on this network. Filter by multiple values by providing a comma delimited list.

        Accepts multiple values which are sent to the API as a comma delimited list

    .PARAMETER FilterModifiedAfter
        Filter by date and time, only returning entities modified after provided value.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from.

        Accepts multiple values which are sent to the API as a comma delimited list

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned. Used in combination with page[after].

        Default value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page. The page size is provided by page[first].

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned. Used in combination with page[before].

        Default value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page. The page size is provided by page[last].

    .PARAMETER AllResults
        Returns all items from the endpoint by following the pagination links

        When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters

        Highly recommended to only use with filters to reduce API errors & timeouts

    .EXAMPLE
        Get-AuvikNetworkInfo

        Returns the result of the /inventory/network/info endpoint

    .EXAMPLE
        Get-AuvikNetworkInfo -Tenants '1234567890' -PageFirst 10

        Returns the result of the /inventory/network/info endpoint limited to the defined tenant

    .EXAMPLE
        Get-AuvikNetworkInfo -AllResults

        Returns every item from the /inventory/network/info endpoint by following the pagination links

    .EXAMPLE
        Get-AuvikNetworkInfo -Id '1234567890'

        Returns the result of the /inventory/network/info/{id} endpoint

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /inventory/network/info
        Endpoint : GET /inventory/network/info/{id}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikNetworkInfo.html
#>

    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById')]
        [ValidateNotNullOrEmpty()]
        [string]$Id,

        [Parameter(Mandatory = $false, ParameterSetName = 'ById')]
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('networkDetail')]
        [string]$Include,

        [Parameter(Mandatory = $false, ParameterSetName = 'ById')]
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('scope', 'primaryCollector', 'secondaryCollectors', 'collectorSelection', 'excludedIpAddresses')]
        [string]$FieldsNetworkDetail,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('routed', 'vlan', 'wifi', 'loopback', 'network', 'layer2', 'internet')]
        [string]$FilterNetworkType,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('true', 'false', 'notAllowed', 'unknown')]
        [string]$FilterScanStatus,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string[]]$FilterDevices,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [datetime]$FilterModifiedAfter,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        switch ($PSCmdlet.ParameterSetName) {
            'ById' {
                $ResourceUri = "/inventory/network/info/$([System.Uri]::EscapeDataString($Id))"
                $NameMap = @{
                    Include             = 'include'
                    FieldsNetworkDetail = 'fields[networkDetail]'
                }
            }
            'List' {
                $ResourceUri = '/inventory/network/info'
                $NameMap = @{
                    FilterNetworkType   = 'filter[networkType]'
                    FilterScanStatus    = 'filter[scanStatus]'
                    FilterDevices       = 'filter[devices]'
                    FilterModifiedAfter = 'filter[modifiedAfter]'
                    Tenants             = 'tenants'
                    PageFirst           = 'page[first]'
                    PageAfter           = 'page[after]'
                    PageLast            = 'page[last]'
                    PageBefore          = 'page[before]'
                    Include             = 'include'
                    FieldsNetworkDetail = 'fields[networkDetail]'
                }
            }
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
            AllResults  = $AllResults
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}

Set-Alias -Name 'Get-AuvikNetwork' -Value 'Get-AuvikNetworkInfo'
#EndRegion '.\Public\Inventory\Get-AuvikNetworkInfo.ps1' 233
#Region '.\Public\Other\Get-AuvikAuthenticationVerify.ps1' -1

function Get-AuvikAuthenticationVerify {
<#
    .SYNOPSIS
        Verify Credentials

    .DESCRIPTION
        The Get-AuvikAuthenticationVerify cmdlet invokes the GET method of the /authentication/verify endpoint (Verify Credentials)

        Use the Verify Credentials API to verify your credentials are correct before making a call to an endpoint.

    .EXAMPLE
        Get-AuvikAuthenticationVerify

        Returns the result of the /authentication/verify endpoint

    .INPUTS
        None

    .OUTPUTS
        System.Boolean

    .NOTES
        Endpoint : GET /authentication/verify
        The Auvik API user needs the role permissions that are required by the endpoint

        This function returns $true when the credentials are valid & $false when they are not

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Other/Get-AuvikAuthenticationVerify.html
#>

    [CmdletBinding()]
    param (

    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = '/authentication/verify'
        $NameMap = @{}

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        try {
            $null = Invoke-AuvikRequest @InvokeParams -ErrorAction Stop -WarningAction SilentlyContinue
            return $true
        }
        catch { return $false }

    }

    end {}

}

Set-Alias -Name 'Test-AuvikAPICredential' -Value 'Get-AuvikAuthenticationVerify'
#EndRegion '.\Public\Other\Get-AuvikAuthenticationVerify.ps1' 76
#Region '.\Public\Pollers\Get-AuvikSNMPPollerDevice.ps1' -1

function Get-AuvikSNMPPollerDevice {
<#
    .SYNOPSIS
        Read SNMP Poller Setting's Devices

    .DESCRIPTION
        The Get-AuvikSNMPPollerDevice cmdlet invokes the GET method of the /settings/snmppoller/{snmpPollerSettingId}/devices endpoint (Read SNMP Poller Setting's Devices)

        Use Read SNMP Poller Setting's Devices API to pull the list of devices that apply to a specific SNMP Poller Setting Id.

    .PARAMETER SnmpPollerSettingId
        ID of the SNMP Poller Setting that the devices apply to

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from.

        Accepts multiple values which are sent to the API as a comma delimited list

    .PARAMETER FilterOnlineStatus
        Filter by the device's online status.

        Allowed values:
        'online', 'offline', 'unreachable', 'testing', 'unknown', 'dormant', 'notPresent', 'lowerLayerDown'

    .PARAMETER FilterModifiedAfter
        Filter by date and time, only returning entities modified after provided value.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterNotSeenSince
        Filter by the last seen online time, returning entities not seen online after the provided value.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterDeviceType
        Filter by device type.

        Allowed values:
        'unknown', 'switch', 'l3Switch', 'router', 'accessPoint', 'firewall', 'workstation', 'server', 'storage', 'printer', 'copier', 'hypervisor', 'multimedia', 'phone', 'tablet', 'handheld', 'virtualAppliance', 'bridge', 'controller', 'hub', 'modem', 'ups', 'module', 'loadBalancer', 'camera', 'telecommunications', 'packetProcessor', 'chassis', 'airConditioner', 'virtualMachine', 'pdu', 'ipPhone', 'backhaul', 'internetOfThings', 'voipSwitch', 'stack', 'backupDevice', 'timeClock', 'lightingDevice', 'audioVisual', 'securityAppliance', 'utm', 'alarm', 'buildingManagement', 'ipmi', 'thinAccessPoint', 'thinClient', 'subnet'

    .PARAMETER FilterMakeModel
        Filter by the device's make and model.

    .PARAMETER FilterVendorName
        Filter by the device's vendor/manufacturer.

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned. Used in combination with page[after].

        Default value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page. The page size is provided by page[first].

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned. Used in combination with page[before].

        Default value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page. The page size is provided by page[last].

    .PARAMETER AllResults
        Returns all items from the endpoint by following the pagination links

        When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters

        Highly recommended to only use with filters to reduce API errors & timeouts

    .EXAMPLE
        Get-AuvikSNMPPollerDevice -SnmpPollerSettingId '1234567890' -Tenants '1234567890'

        Returns the result of the /settings/snmppoller/{snmpPollerSettingId}/devices endpoint

    .EXAMPLE
        Get-AuvikSNMPPollerDevice -SnmpPollerSettingId '1234567890' -Tenants '1234567890' -PageFirst 10

        Returns the result of the /settings/snmppoller/{snmpPollerSettingId}/devices endpoint limited to the defined number of items

    .EXAMPLE
        Get-AuvikSNMPPollerDevice -SnmpPollerSettingId '1234567890' -Tenants '1234567890' -AllResults

        Returns every item from the /settings/snmppoller/{snmpPollerSettingId}/devices endpoint by following the pagination links

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /settings/snmppoller/{snmpPollerSettingId}/devices
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Pollers/Get-AuvikSNMPPollerDevice.html
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [ValidateNotNullOrEmpty()]
        [string]$SnmpPollerSettingId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('online', 'offline', 'unreachable', 'testing', 'unknown', 'dormant', 'notPresent', 'lowerLayerDown')]
        [string]$FilterOnlineStatus,

        [Parameter(Mandatory = $false)]
        [datetime]$FilterModifiedAfter,

        [Parameter(Mandatory = $false)]
        [datetime]$FilterNotSeenSince,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('unknown', 'switch', 'l3Switch', 'router', 'accessPoint', 'firewall', 'workstation', 'server', 'storage', 'printer', 'copier', 'hypervisor', 'multimedia', 'phone', 'tablet', 'handheld', 'virtualAppliance', 'bridge', 'controller', 'hub', 'modem', 'ups', 'module', 'loadBalancer', 'camera', 'telecommunications', 'packetProcessor', 'chassis', 'airConditioner', 'virtualMachine', 'pdu', 'ipPhone', 'backhaul', 'internetOfThings', 'voipSwitch', 'stack', 'backupDevice', 'timeClock', 'lightingDevice', 'audioVisual', 'securityAppliance', 'utm', 'alarm', 'buildingManagement', 'ipmi', 'thinAccessPoint', 'thinClient', 'subnet')]
        [string]$FilterDeviceType,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterMakeModel,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterVendorName,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter(Mandatory = $false)]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = "/settings/snmppoller/$([System.Uri]::EscapeDataString($SnmpPollerSettingId))/devices"
        $NameMap = @{
            Tenants             = 'tenants'
            FilterOnlineStatus  = 'filter[onlineStatus]'
            FilterModifiedAfter = 'filter[modifiedAfter]'
            FilterNotSeenSince  = 'filter[notSeenSince]'
            FilterDeviceType    = 'filter[deviceType]'
            FilterMakeModel     = 'filter[makeModel]'
            FilterVendorName    = 'filter[vendorName]'
            PageFirst           = 'page[first]'
            PageAfter           = 'page[after]'
            PageLast            = 'page[last]'
            PageBefore          = 'page[before]'
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
            AllResults  = $AllResults
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}
#EndRegion '.\Public\Pollers\Get-AuvikSNMPPollerDevice.ps1' 200
#Region '.\Public\Pollers\Get-AuvikSNMPPollerHistoryInt.ps1' -1

function Get-AuvikSNMPPollerHistoryInt {
<#
    .SYNOPSIS
        Read Numeric SNMP Poller Setting's History

    .DESCRIPTION
        The Get-AuvikSNMPPollerHistoryInt cmdlet invokes the GET method of the /stat/snmppoller/int endpoint (Read Numeric SNMP Poller Setting's History)

        Use the Read SNMP Poller Setting's History API to fetch the list of historical vaules for a SNMP Poller Setting.

    .PARAMETER FilterFromTime
        Timestamp from which you want to query

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterInterval
        Statistics reporting interval

        Allowed values:
        'minute', 'hour', 'day'

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from.

        Accepts multiple values which are sent to the API as a comma delimited list

    .PARAMETER FilterThruTime
        Timestamp to which you want to query (defaults to current time)

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterDeviceId
        Filter by device ID

    .PARAMETER FilterSnmpPollerSettingId
        Comma delimited list of SNMP poller setting IDs to request info from. Note this is internal snmpPollerSettingId. The user can get the list of IDs for a specific poller using the GET /settings/snmppoller endpoint.

        Accepts multiple values which are sent to the API as a comma delimited list

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned. Used in combination with page[after].

        Default value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page. The page size is provided by page[first].

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned. Used in combination with page[before].

        Default value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page. The page size is provided by page[last].

    .PARAMETER AllResults
        Returns all items from the endpoint by following the pagination links

        When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters

        Highly recommended to only use with filters to reduce API errors & timeouts

    .EXAMPLE
        Get-AuvikSNMPPollerHistoryInt -FilterFromTime '2025-01-01T00:00:00Z' -FilterInterval 'minute' -Tenants '1234567890'

        Returns the result of the /stat/snmppoller/int endpoint

    .EXAMPLE
        Get-AuvikSNMPPollerHistoryInt -FilterFromTime '2025-01-01T00:00:00Z' -FilterInterval 'minute' -Tenants '1234567890' -PageFirst 10

        Returns the result of the /stat/snmppoller/int endpoint limited to the defined number of items

    .EXAMPLE
        Get-AuvikSNMPPollerHistoryInt -FilterFromTime '2025-01-01T00:00:00Z' -FilterInterval 'minute' -Tenants '1234567890' -AllResults

        Returns every item from the /stat/snmppoller/int endpoint by following the pagination links

    .INPUTS
        None

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /stat/snmppoller/int
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Pollers/Get-AuvikSNMPPollerHistoryInt.html
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [datetime]$FilterFromTime,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('minute', 'hour', 'day')]
        [string]$FilterInterval,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter(Mandatory = $false)]
        [datetime]$FilterThruTime,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterDeviceId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string[]]$FilterSnmpPollerSettingId,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter(Mandatory = $false)]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = '/stat/snmppoller/int'
        $NameMap = @{
            FilterFromTime            = 'filter[fromTime]'
            FilterThruTime            = 'filter[thruTime]'
            FilterInterval            = 'filter[interval]'
            Tenants                   = 'tenants'
            FilterDeviceId            = 'filter[deviceId]'
            FilterSnmpPollerSettingId = 'filter[snmpPollerSettingId]'
            PageFirst                 = 'page[first]'
            PageAfter                 = 'page[after]'
            PageLast                  = 'page[last]'
            PageBefore                = 'page[before]'
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        # The API requires filter[thruTime] even though the spec defines it as optional (it defaults to the current time)
        if ($UriParameters.ContainsKey('filter[fromTime]') -and -not $UriParameters.ContainsKey('filter[thruTime]')) { $UriParameters['filter[thruTime]'] = [datetime]::UtcNow }

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
            AllResults  = $AllResults
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}
#EndRegion '.\Public\Pollers\Get-AuvikSNMPPollerHistoryInt.ps1' 185
#Region '.\Public\Pollers\Get-AuvikSNMPPollerHistoryString.ps1' -1

function Get-AuvikSNMPPollerHistoryString {
<#
    .SYNOPSIS
        Read String SNMP Poller Setting's History

    .DESCRIPTION
        The Get-AuvikSNMPPollerHistoryString cmdlet invokes the GET method of the /stat/snmppoller/string endpoint (Read String SNMP Poller Setting's History)

        Use the Read SNMP Poller Setting's History API to fetch the list of historical vaules for a SNMP Poller Setting.

    .PARAMETER FilterFromTime
        Timestamp from which you want to query

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from.

        Accepts multiple values which are sent to the API as a comma delimited list

    .PARAMETER FilterThruTime
        Timestamp to which you want to query (defaults to current time)

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterCompact
        Whether to show compact view of the results or not. Compact view only shows changes in value. If compact view is false, dateTime range can be a maximum of 24h

    .PARAMETER FilterDeviceId
        Filter by device ID

    .PARAMETER FilterSnmpPollerSettingId
        Comma delimited list of SNMP poller setting IDs to request info from. Note this is internal snmpPollerSettingId. The user can get the list of IDs for a specific poller using the GET /settings/snmppoller endpoint.

        Accepts multiple values which are sent to the API as a comma delimited list

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned. Used in combination with page[after].

        Default value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page. The page size is provided by page[first].

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned. Used in combination with page[before].

        Default value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page. The page size is provided by page[last].

    .PARAMETER AllResults
        Returns all items from the endpoint by following the pagination links

        When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters

        Highly recommended to only use with filters to reduce API errors & timeouts

    .EXAMPLE
        Get-AuvikSNMPPollerHistoryString -FilterFromTime '2025-01-01T00:00:00Z' -Tenants '1234567890'

        Returns the result of the /stat/snmppoller/string endpoint

    .EXAMPLE
        Get-AuvikSNMPPollerHistoryString -FilterFromTime '2025-01-01T00:00:00Z' -Tenants '1234567890' -PageFirst 10

        Returns the result of the /stat/snmppoller/string endpoint limited to the defined number of items

    .EXAMPLE
        Get-AuvikSNMPPollerHistoryString -FilterFromTime '2025-01-01T00:00:00Z' -Tenants '1234567890' -AllResults

        Returns every item from the /stat/snmppoller/string endpoint by following the pagination links

    .INPUTS
        None

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /stat/snmppoller/string
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Pollers/Get-AuvikSNMPPollerHistoryString.html
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [datetime]$FilterFromTime,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter(Mandatory = $false)]
        [datetime]$FilterThruTime,

        [Parameter(Mandatory = $false)]
        [bool]$FilterCompact,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterDeviceId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string[]]$FilterSnmpPollerSettingId,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter(Mandatory = $false)]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = '/stat/snmppoller/string'
        $NameMap = @{
            FilterFromTime            = 'filter[fromTime]'
            FilterThruTime            = 'filter[thruTime]'
            FilterCompact             = 'filter[compact]'
            Tenants                   = 'tenants'
            FilterDeviceId            = 'filter[deviceId]'
            FilterSnmpPollerSettingId = 'filter[snmpPollerSettingId]'
            PageFirst                 = 'page[first]'
            PageAfter                 = 'page[after]'
            PageLast                  = 'page[last]'
            PageBefore                = 'page[before]'
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        # The API requires filter[thruTime] even though the spec defines it as optional (it defaults to the current time)
        if ($UriParameters.ContainsKey('filter[fromTime]') -and -not $UriParameters.ContainsKey('filter[thruTime]')) { $UriParameters['filter[thruTime]'] = [datetime]::UtcNow }

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
            AllResults  = $AllResults
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}

Set-Alias -Name 'Get-AuvikSNMPPollerHistory' -Value 'Get-AuvikSNMPPollerHistoryString'
#EndRegion '.\Public\Pollers\Get-AuvikSNMPPollerHistoryString.ps1' 182
#Region '.\Public\Pollers\Get-AuvikSNMPPollerSetting.ps1' -1

function Get-AuvikSNMPPollerSetting {
<#
    .SYNOPSIS
        Read Multiple SNMP Poller Settings / Read Single SNMP Poller Setting

    .DESCRIPTION
        Parameter set [ List ] - The Get-AuvikSNMPPollerSetting cmdlet invokes the GET method of the /settings/snmppoller endpoint (Read Multiple SNMP Poller Settings)

        Use the Read Multiple SNMP Poller Settings API to pull the list of SNMP Poller Settings configured in Auvik.

        Parameter set [ ById ] - The Get-AuvikSNMPPollerSetting cmdlet invokes the GET method of the /settings/snmppoller/{snmpPollerSettingId} endpoint (Read Single SNMP Poller Setting)

        Use the Read Single SNMP Poller Setting API to pull details of a specific SNMP Poller Setting configured in Auvik.

    .PARAMETER SnmpPollerSettingId
        ID of the SNMP Poller Setting to retrieve

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from.

        Accepts multiple values which are sent to the API as a comma delimited list

    .PARAMETER FilterDeviceId
        Filter by device ID

    .PARAMETER FilterUseAs
        Filter by oid type

        Allowed values:
        'serialNo', 'poller'

    .PARAMETER FilterType
        Filter by type

        Allowed values:
        'string', 'numeric'

    .PARAMETER FilterDeviceType
        Filter by device type.

        Allowed values:
        'unknown', 'switch', 'l3Switch', 'router', 'accessPoint', 'firewall', 'workstation', 'server', 'storage', 'printer', 'copier', 'hypervisor', 'multimedia', 'phone', 'tablet', 'handheld', 'virtualAppliance', 'bridge', 'controller', 'hub', 'modem', 'ups', 'module', 'loadBalancer', 'camera', 'telecommunications', 'packetProcessor', 'chassis', 'airConditioner', 'virtualMachine', 'pdu', 'ipPhone', 'backhaul', 'internetOfThings', 'voipSwitch', 'stack', 'backupDevice', 'timeClock', 'lightingDevice', 'audioVisual', 'securityAppliance', 'utm', 'alarm', 'buildingManagement', 'ipmi', 'thinAccessPoint', 'thinClient', 'subnet'

    .PARAMETER FilterMakeModel
        Filter by the device's make and model.

    .PARAMETER FilterVendorName
        Filter by the device's vendor/manufacturer.

    .PARAMETER FilterOid
        Filter by OID

    .PARAMETER FilterName
        Filter by the name of the SNMP poller setting

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned. Used in combination with page[after].

        Default value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page. The page size is provided by page[first].

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned. Used in combination with page[before].

        Default value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page. The page size is provided by page[last].

    .PARAMETER AllResults
        Returns all items from the endpoint by following the pagination links

        When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters

        Highly recommended to only use with filters to reduce API errors & timeouts

    .EXAMPLE
        Get-AuvikSNMPPollerSetting -Tenants '1234567890'

        Returns the result of the /settings/snmppoller endpoint

    .EXAMPLE
        Get-AuvikSNMPPollerSetting -Tenants '1234567890' -PageFirst 10

        Returns the result of the /settings/snmppoller endpoint limited to the defined number of items

    .EXAMPLE
        Get-AuvikSNMPPollerSetting -Tenants '1234567890' -AllResults

        Returns every item from the /settings/snmppoller endpoint by following the pagination links

    .EXAMPLE
        Get-AuvikSNMPPollerSetting -SnmpPollerSettingId '1234567890'

        Returns the result of the /settings/snmppoller/{snmpPollerSettingId} endpoint

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /settings/snmppoller
        Endpoint : GET /settings/snmppoller/{snmpPollerSettingId}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Pollers/Get-AuvikSNMPPollerSetting.html
#>

    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById')]
        [Alias('Id')]
        [ValidateNotNullOrEmpty()]
        [string]$SnmpPollerSettingId,

        [Parameter(Mandatory = $true, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterDeviceId,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('serialNo', 'poller')]
        [string]$FilterUseAs,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('string', 'numeric')]
        [string]$FilterType,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('unknown', 'switch', 'l3Switch', 'router', 'accessPoint', 'firewall', 'workstation', 'server', 'storage', 'printer', 'copier', 'hypervisor', 'multimedia', 'phone', 'tablet', 'handheld', 'virtualAppliance', 'bridge', 'controller', 'hub', 'modem', 'ups', 'module', 'loadBalancer', 'camera', 'telecommunications', 'packetProcessor', 'chassis', 'airConditioner', 'virtualMachine', 'pdu', 'ipPhone', 'backhaul', 'internetOfThings', 'voipSwitch', 'stack', 'backupDevice', 'timeClock', 'lightingDevice', 'audioVisual', 'securityAppliance', 'utm', 'alarm', 'buildingManagement', 'ipmi', 'thinAccessPoint', 'thinClient', 'subnet')]
        [string]$FilterDeviceType,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterMakeModel,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterVendorName,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterOid,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$FilterName,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        switch ($PSCmdlet.ParameterSetName) {
            'ById' {
                $ResourceUri = "/settings/snmppoller/$([System.Uri]::EscapeDataString($SnmpPollerSettingId))"
                $NameMap = @{}
            }
            'List' {
                $ResourceUri = '/settings/snmppoller'
                $NameMap = @{
                    Tenants          = 'tenants'
                    FilterDeviceId   = 'filter[deviceId]'
                    FilterUseAs      = 'filter[useAs]'
                    FilterType       = 'filter[type]'
                    FilterDeviceType = 'filter[deviceType]'
                    FilterMakeModel  = 'filter[makeModel]'
                    FilterVendorName = 'filter[vendorName]'
                    FilterOid        = 'filter[oid]'
                    FilterName       = 'filter[name]'
                    PageFirst        = 'page[first]'
                    PageAfter        = 'page[after]'
                    PageLast         = 'page[last]'
                    PageBefore       = 'page[before]'
                }
            }
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
            AllResults  = $AllResults
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}
#EndRegion '.\Public\Pollers\Get-AuvikSNMPPollerSetting.ps1' 236
#Region '.\Public\SaaSManagement\Get-AuvikASMApplication.ps1' -1

function Get-AuvikASMApplication {
<#
    .SYNOPSIS
        Read Multiple ASM Applications' Info

    .DESCRIPTION
        The Get-AuvikASMApplication cmdlet invokes the GET method of the /asm/app/info endpoint (Read Multiple ASM Applications' Info)

        Use the Read Multiple ASM Applications' Info to retrieve the information related to the SaaS applications discovered within an ASM client deployment. This data includes the number of users of an application as well as key metadata such as whether the application is approved or unapproved.

    .PARAMETER FilterClientId
        Filter by client ID.

    .PARAMETER FilterDateAddedBefore
        Return applications added before this date.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterDateAddedAfter
        Return applications added after this date.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterQueryDate
        Return associated breaches added after this date.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterUserLastUsedAfter
        Return associated users added after this date.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterUserLastUsedBefore
        Return associated users before this date.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER Include
        Use to include extended details of the application or of its related objects.

        Allowed values:
        'all', 'breaches', 'users', 'contracts', 'publisher', 'accessData'

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned. Used in combination with page[after].

        Default value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page. The page size is provided by page[first].

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned. Used in combination with page[before].

        Default value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page. The page size is provided by page[last].

    .PARAMETER AllResults
        Returns all items from the endpoint by following the pagination links

        When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters

        Highly recommended to only use with filters to reduce API errors & timeouts

    .EXAMPLE
        Get-AuvikASMApplication -FilterClientId 'Example'

        Returns the result of the /asm/app/info endpoint

    .EXAMPLE
        Get-AuvikASMApplication -FilterClientId 'Example' -PageFirst 10

        Returns the result of the /asm/app/info endpoint limited to the defined number of items

    .EXAMPLE
        Get-AuvikASMApplication -FilterClientId 'Example' -AllResults

        Returns every item from the /asm/app/info endpoint by following the pagination links

    .INPUTS
        None

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /asm/app/info
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/SaaSManagement/Get-AuvikASMApplication.html
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterClientId,

        [Parameter(Mandatory = $false)]
        [datetime]$FilterDateAddedBefore,

        [Parameter(Mandatory = $false)]
        [datetime]$FilterDateAddedAfter,

        [Parameter(Mandatory = $false)]
        [datetime]$FilterQueryDate,

        [Parameter(Mandatory = $false)]
        [datetime]$FilterUserLastUsedAfter,

        [Parameter(Mandatory = $false)]
        [datetime]$FilterUserLastUsedBefore,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('all', 'breaches', 'users', 'contracts', 'publisher', 'accessData')]
        [string]$Include,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter(Mandatory = $false)]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = '/asm/app/info'
        $NameMap = @{
            FilterClientId           = 'filter[clientId]'
            FilterDateAddedBefore    = 'filter[dateAddedBefore]'
            FilterDateAddedAfter     = 'filter[dateAddedAfter]'
            FilterQueryDate          = 'filter[queryDate]'
            FilterUserLastUsedAfter  = 'filter[user_lastUsedAfter]'
            FilterUserLastUsedBefore = 'filter[user_lastUsedBefore]'
            Include                  = 'include'
            PageFirst                = 'page[first]'
            PageAfter                = 'page[after]'
            PageLast                 = 'page[last]'
            PageBefore               = 'page[before]'
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
            AllResults  = $AllResults
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}
#EndRegion '.\Public\SaaSManagement\Get-AuvikASMApplication.ps1' 189
#Region '.\Public\SaaSManagement\Get-AuvikASMClient.ps1' -1

function Get-AuvikASMClient {
<#
    .SYNOPSIS
        Read Multiple ASM Clients' Info

    .DESCRIPTION
        The Get-AuvikASMClient cmdlet invokes the GET method of the /asm/client/info endpoint (Read Multiple ASM Clients' Info)

        The Read Multiple ASM Clients' Info API returns relevant meta data about clients that exist within the Auvik SaaS Management product. The response includes the number of total users as well as clientIDs which may be used to filter other relevant API calls.

    .PARAMETER Include
        Use to include extended details of the client.

        Allowed values:
        'totals'

    .PARAMETER FilterQueryDate
        Only count breaches added after this date. Only useful when include=totals is set.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned. Used in combination with page[after].

        Default value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page. The page size is provided by page[first].

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned. Used in combination with page[before].

        Default value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page. The page size is provided by page[last].

    .PARAMETER AllResults
        Returns all items from the endpoint by following the pagination links

        When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters

        Highly recommended to only use with filters to reduce API errors & timeouts

    .EXAMPLE
        Get-AuvikASMClient

        Returns the result of the /asm/client/info endpoint

    .EXAMPLE
        Get-AuvikASMClient -PageFirst 10

        Returns the result of the /asm/client/info endpoint limited to the defined number of items

    .EXAMPLE
        Get-AuvikASMClient -AllResults

        Returns every item from the /asm/client/info endpoint by following the pagination links

    .INPUTS
        None

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /asm/client/info
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/SaaSManagement/Get-AuvikASMClient.html
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('totals')]
        [string]$Include,

        [Parameter(Mandatory = $false)]
        [datetime]$FilterQueryDate,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter(Mandatory = $false)]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = '/asm/client/info'
        $NameMap = @{
            Include         = 'include'
            FilterQueryDate = 'filter[queryDate]'
            PageFirst       = 'page[first]'
            PageAfter       = 'page[after]'
            PageLast        = 'page[last]'
            PageBefore      = 'page[before]'
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
            AllResults  = $AllResults
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}
#EndRegion '.\Public\SaaSManagement\Get-AuvikASMClient.ps1' 145
#Region '.\Public\SaaSManagement\Get-AuvikASMLicense.ps1' -1

function Get-AuvikASMLicense {
<#
    .SYNOPSIS
        Read Multiple ASM Licenses' Info

    .DESCRIPTION
        The Get-AuvikASMLicense cmdlet invokes the GET method of the /asm/license/info endpoint (Read Multiple ASM Licenses' Info)

        Use the Read Multiple ASM Licenses' Info endpoint to retrieve information about an application licenses discovered within an ASM client deployment. This data includes the license type and associated user email assigned to each license, alongside other key metadata such as last login time. To access this data, a SaaS Ops integration with the desired application must be configured.

    .PARAMETER FilterClientId
        Filter by client ID.

    .PARAMETER FilterApplicationId
        Unique identifier of the application.

    .PARAMETER FilterEmail
        Filter results by a specific license email.

    .PARAMETER FilterLicenseType
        Filter results by license type.

    .PARAMETER FilterLastLoginBefore
        Returns only users whose last login was before the given date or have no last login time.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterUnderutilizedOnly
        If included, filters to users flagged as underutilized.

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned. Used in combination with page[after].

        Default value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page. The page size is provided by page[first].

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned. Used in combination with page[before].

        Default value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page. The page size is provided by page[last].

    .PARAMETER AllResults
        Returns all items from the endpoint by following the pagination links

        When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters

        Highly recommended to only use with filters to reduce API errors & timeouts

    .EXAMPLE
        Get-AuvikASMLicense -FilterClientId 'Example' -FilterApplicationId 'Example'

        Returns the result of the /asm/license/info endpoint

    .EXAMPLE
        Get-AuvikASMLicense -FilterClientId 'Example' -FilterApplicationId 'Example' -PageFirst 10

        Returns the result of the /asm/license/info endpoint limited to the defined number of items

    .EXAMPLE
        Get-AuvikASMLicense -FilterClientId 'Example' -FilterApplicationId 'Example' -AllResults

        Returns every item from the /asm/license/info endpoint by following the pagination links

    .INPUTS
        None

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /asm/license/info
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/SaaSManagement/Get-AuvikASMLicense.html
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterClientId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterApplicationId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterEmail,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterLicenseType,

        [Parameter(Mandatory = $false)]
        [datetime]$FilterLastLoginBefore,

        [Parameter(Mandatory = $false)]
        [bool]$FilterUnderutilizedOnly,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter(Mandatory = $false)]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = '/asm/license/info'
        $NameMap = @{
            FilterClientId          = 'filter[clientId]'
            FilterApplicationId     = 'filter[applicationId]'
            FilterEmail             = 'filter[email]'
            FilterLicenseType       = 'filter[licenseType]'
            FilterLastLoginBefore   = 'filter[lastLoginBefore]'
            FilterUnderutilizedOnly = 'filter[underutilizedOnly]'
            PageFirst               = 'page[first]'
            PageAfter               = 'page[after]'
            PageLast                = 'page[last]'
            PageBefore              = 'page[before]'
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
            AllResults  = $AllResults
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}
#EndRegion '.\Public\SaaSManagement\Get-AuvikASMLicense.ps1' 172
#Region '.\Public\SaaSManagement\Get-AuvikASMSecurityLog.ps1' -1

function Get-AuvikASMSecurityLog {
<#
    .SYNOPSIS
        Read Multiple ASM Security Logs' Info

    .DESCRIPTION
        The Get-AuvikASMSecurityLog cmdlet invokes the GET method of the /asm/securityLog/info endpoint (Read Multiple ASM Security Logs' Info)

        Use the Read Multiple ASM Security Logs' Info API to retrieve in depth information about the security logs within an Auvik SaaS Management client. Security logs include specific SaaS events, such as logins or downloads with timestamps for each event.

    .PARAMETER FilterClientId
        Filter by client ID.

    .PARAMETER Include
        Use to include extended details of the security log or of its related objects.

        Allowed values:
        'users', 'applications'

    .PARAMETER FilterQueryDate
        Only return security logs added after this date.

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned. Used in combination with page[after].

        Default value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page. The page size is provided by page[first].

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned. Used in combination with page[before].

        Default value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page. The page size is provided by page[last].

    .PARAMETER AllResults
        Returns all items from the endpoint by following the pagination links

        When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters

        Highly recommended to only use with filters to reduce API errors & timeouts

    .EXAMPLE
        Get-AuvikASMSecurityLog -FilterClientId 'Example'

        Returns the result of the /asm/securityLog/info endpoint

    .EXAMPLE
        Get-AuvikASMSecurityLog -FilterClientId 'Example' -PageFirst 10

        Returns the result of the /asm/securityLog/info endpoint limited to the defined number of items

    .EXAMPLE
        Get-AuvikASMSecurityLog -FilterClientId 'Example' -AllResults

        Returns every item from the /asm/securityLog/info endpoint by following the pagination links

    .INPUTS
        None

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /asm/securityLog/info
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/SaaSManagement/Get-AuvikASMSecurityLog.html
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterClientId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('users', 'applications')]
        [string]$Include,

        [Parameter(Mandatory = $false)]
        [datetime]$FilterQueryDate,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter(Mandatory = $false)]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = '/asm/securityLog/info'
        $NameMap = @{
            FilterClientId  = 'filter[clientId]'
            Include         = 'include'
            FilterQueryDate = 'filter[queryDate]'
            PageFirst       = 'page[first]'
            PageAfter       = 'page[after]'
            PageLast        = 'page[last]'
            PageBefore      = 'page[before]'
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
            AllResults  = $AllResults
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}
#EndRegion '.\Public\SaaSManagement\Get-AuvikASMSecurityLog.ps1' 153
#Region '.\Public\SaaSManagement\Get-AuvikASMTag.ps1' -1

function Get-AuvikASMTag {
<#
    .SYNOPSIS
        Read Multiple ASM Tags' Info

    .DESCRIPTION
        The Get-AuvikASMTag cmdlet invokes the GET method of the /asm/tag/info endpoint (Read Multiple ASM Tags' Info)

        Use the Read Multiple ASM Tags' Info API to retrieve information about tags configured within an ASM client.

    .PARAMETER FilterClientId
        Filter by client ID.

    .PARAMETER FilterApplicationId
        Filter by application ID.

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned. Used in combination with page[after].

        Default value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page. The page size is provided by page[first].

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned. Used in combination with page[before].

        Default value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page. The page size is provided by page[last].

    .PARAMETER AllResults
        Returns all items from the endpoint by following the pagination links

        When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters

        Highly recommended to only use with filters to reduce API errors & timeouts

    .EXAMPLE
        Get-AuvikASMTag -FilterClientId 'Example'

        Returns the result of the /asm/tag/info endpoint

    .EXAMPLE
        Get-AuvikASMTag -FilterClientId 'Example' -PageFirst 10

        Returns the result of the /asm/tag/info endpoint limited to the defined number of items

    .EXAMPLE
        Get-AuvikASMTag -FilterClientId 'Example' -AllResults

        Returns every item from the /asm/tag/info endpoint by following the pagination links

    .INPUTS
        None

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /asm/tag/info
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/SaaSManagement/Get-AuvikASMTag.html
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterClientId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterApplicationId,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter(Mandatory = $false)]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = '/asm/tag/info'
        $NameMap = @{
            FilterClientId      = 'filter[clientId]'
            FilterApplicationId = 'filter[applicationId]'
            PageFirst           = 'page[first]'
            PageAfter           = 'page[after]'
            PageLast            = 'page[last]'
            PageBefore          = 'page[before]'
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
            AllResults  = $AllResults
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}
#EndRegion '.\Public\SaaSManagement\Get-AuvikASMTag.ps1' 140
#Region '.\Public\SaaSManagement\Get-AuvikASMUser.ps1' -1

function Get-AuvikASMUser {
<#
    .SYNOPSIS
        Read Multiple ASM Users' Info

    .DESCRIPTION
        The Get-AuvikASMUser cmdlet invokes the GET method of the /asm/user/info endpoint (Read Multiple ASM Users' Info)

        Use the Read Multiple ASM Users' Info API to retrieve information about any monitored users that exist within a specific Auvik SaaS Management tenant. ASM user data includes core information about the SaaS applications a monitored user is using as well as which accounts a user is leveraging to log into those applications.

    .PARAMETER FilterClientId
        Filter by client ID.

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned. Used in combination with page[after].

        Default value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page. The page size is provided by page[first].

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned. Used in combination with page[before].

        Default value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page. The page size is provided by page[last].

    .PARAMETER AllResults
        Returns all items from the endpoint by following the pagination links

        When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters

        Highly recommended to only use with filters to reduce API errors & timeouts

    .EXAMPLE
        Get-AuvikASMUser -FilterClientId 'Example'

        Returns the result of the /asm/user/info endpoint

    .EXAMPLE
        Get-AuvikASMUser -FilterClientId 'Example' -PageFirst 10

        Returns the result of the /asm/user/info endpoint limited to the defined number of items

    .EXAMPLE
        Get-AuvikASMUser -FilterClientId 'Example' -AllResults

        Returns every item from the /asm/user/info endpoint by following the pagination links

    .INPUTS
        None

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /asm/user/info
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/SaaSManagement/Get-AuvikASMUser.html
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterClientId,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter(Mandatory = $false)]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = '/asm/user/info'
        $NameMap = @{
            FilterClientId = 'filter[clientId]'
            PageFirst      = 'page[first]'
            PageAfter      = 'page[after]'
            PageLast       = 'page[last]'
            PageBefore     = 'page[before]'
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
            AllResults  = $AllResults
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}
#EndRegion '.\Public\SaaSManagement\Get-AuvikASMUser.ps1' 132
#Region '.\Public\Statistics\Get-AuvikComponentStatistics.ps1' -1

function Get-AuvikComponentStatistics {
<#
    .SYNOPSIS
        Read Component Statistics

    .DESCRIPTION
        The Get-AuvikComponentStatistics cmdlet invokes the GET method of the /stat/component/{componentType}/{statId} endpoint (Read Component Statistics)

        Use the Read Component Statistics API to fetch detailed statistics of a client's (and client's children if a multi-client) components for a given time range.

    .PARAMETER ComponentType
        Component type of statistic to return

        Allowed values:
        'cpu', 'cpuCore', 'disk', 'fan', 'memory', 'powerSupply', 'systemBoard'

    .PARAMETER StatId
        ID of statistic to return

        Allowed values:
        'capacity', 'counters', 'idle', 'latency', 'power', 'queueLatency', 'rate', 'readiness', 'ready', 'speed', 'swap', 'swapRate', 'temperature', 'totalLatency', 'utilization'

    .PARAMETER FilterFromTime
        Timestamp from which you want to query

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterInterval
        Statistics reporting interval

        Allowed values:
        'minute', 'hour', 'day'

    .PARAMETER FilterThruTime
        Timestamp to which you want to query (defaults to current time)

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterComponentId
        Filter by component ID.

    .PARAMETER FilterParentDevice
        Filter by the entity's parent device ID.

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from.

        Accepts multiple values which are sent to the API as a comma delimited list

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned. Used in combination with page[after].

        Default value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page. The page size is provided by page[first].

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned. Used in combination with page[before].

        Default value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page. The page size is provided by page[last].

    .PARAMETER AllResults
        Returns all items from the endpoint by following the pagination links

        When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters

        Highly recommended to only use with filters to reduce API errors & timeouts

    .EXAMPLE
        Get-AuvikComponentStatistics -ComponentType 'cpu' -StatId 'capacity' -FilterFromTime '2025-01-01T00:00:00Z' -FilterInterval 'minute'

        Returns the result of the /stat/component/{componentType}/{statId} endpoint

    .EXAMPLE
        Get-AuvikComponentStatistics -ComponentType 'cpu' -StatId 'capacity' -FilterFromTime '2025-01-01T00:00:00Z' -FilterInterval 'minute' -Tenants '1234567890' -PageFirst 10

        Returns the result of the /stat/component/{componentType}/{statId} endpoint limited to the defined tenant

    .EXAMPLE
        Get-AuvikComponentStatistics -ComponentType 'cpu' -StatId 'capacity' -FilterFromTime '2025-01-01T00:00:00Z' -FilterInterval 'minute' -AllResults

        Returns every item from the /stat/component/{componentType}/{statId} endpoint by following the pagination links

    .INPUTS
        None

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /stat/component/{componentType}/{statId}
        The Auvik API user needs the role permissions that are required by the endpoint
        Not every StatId is valid for every ComponentType, the API returns a 400 error with the valid values when the combination is not valid

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Statistics/Get-AuvikComponentStatistics.html
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('cpu', 'cpuCore', 'disk', 'fan', 'memory', 'powerSupply', 'systemBoard')]
        [string]$ComponentType,

        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('capacity', 'counters', 'idle', 'latency', 'power', 'queueLatency', 'rate', 'readiness', 'ready', 'speed', 'swap', 'swapRate', 'temperature', 'totalLatency', 'utilization')]
        [string]$StatId,

        [Parameter(Mandatory = $true)]
        [datetime]$FilterFromTime,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('minute', 'hour', 'day')]
        [string]$FilterInterval,

        [Parameter(Mandatory = $false)]
        [datetime]$FilterThruTime,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterComponentId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterParentDevice,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter(Mandatory = $false)]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = "/stat/component/$([System.Uri]::EscapeDataString($ComponentType))/$([System.Uri]::EscapeDataString($StatId))"
        $NameMap = @{
            FilterFromTime     = 'filter[fromTime]'
            FilterThruTime     = 'filter[thruTime]'
            FilterInterval     = 'filter[interval]'
            FilterComponentId  = 'filter[componentId]'
            FilterParentDevice = 'filter[parentDevice]'
            Tenants            = 'tenants'
            PageFirst          = 'page[first]'
            PageAfter          = 'page[after]'
            PageLast           = 'page[last]'
            PageBefore         = 'page[before]'
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        # The API requires filter[thruTime] even though the spec defines it as optional (it defaults to the current time)
        if ($UriParameters.ContainsKey('filter[fromTime]') -and -not $UriParameters.ContainsKey('filter[thruTime]')) { $UriParameters['filter[thruTime]'] = [datetime]::UtcNow }

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
            AllResults  = $AllResults
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}
#EndRegion '.\Public\Statistics\Get-AuvikComponentStatistics.ps1' 206
#Region '.\Public\Statistics\Get-AuvikDeviceAvailabilityStatistics.ps1' -1

function Get-AuvikDeviceAvailabilityStatistics {
<#
    .SYNOPSIS
        Read Device Availability Statistics

    .DESCRIPTION
        The Get-AuvikDeviceAvailabilityStatistics cmdlet invokes the GET method of the /stat/deviceAvailability/{statId} endpoint (Read Device Availability Statistics)

        Use the Read Device Availability Statistics API to fetch detailed availability statistics of a client's (and client's children if a multi-client) devices for a given time range.

    .PARAMETER StatId
        ID of statistic to return

        Allowed values:
        'uptime', 'outage'

    .PARAMETER FilterFromTime
        Timestamp from which you want to query

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterInterval
        Statistics reporting interval

        Allowed values:
        'minute', 'hour', 'day'

    .PARAMETER FilterThruTime
        Timestamp to which you want to query (defaults to current time)

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterDeviceType
        Filter by device type.

        Allowed values:
        'unknown', 'switch', 'l3Switch', 'router', 'accessPoint', 'firewall', 'workstation', 'server', 'storage', 'printer', 'copier', 'hypervisor', 'multimedia', 'phone', 'tablet', 'handheld', 'virtualAppliance', 'bridge', 'controller', 'hub', 'modem', 'ups', 'module', 'loadBalancer', 'camera', 'telecommunications', 'packetProcessor', 'chassis', 'airConditioner', 'virtualMachine', 'pdu', 'ipPhone', 'backhaul', 'internetOfThings', 'voipSwitch', 'stack', 'backupDevice', 'timeClock', 'lightingDevice', 'audioVisual', 'securityAppliance', 'utm', 'alarm', 'buildingManagement', 'ipmi', 'thinAccessPoint', 'thinClient', 'subnet'

    .PARAMETER FilterDeviceId
        Filter by device ID

    .PARAMETER FilterOmitUndiscovered
        When true, omits availability data for time periods before the device was first discovered (See firstDiscoveredDateTime).

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from.

        Accepts multiple values which are sent to the API as a comma delimited list

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned. Used in combination with page[after].

        Default value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page. The page size is provided by page[first].

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned. Used in combination with page[before].

        Default value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page. The page size is provided by page[last].

    .PARAMETER AllResults
        Returns all items from the endpoint by following the pagination links

        When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters

        Highly recommended to only use with filters to reduce API errors & timeouts

    .EXAMPLE
        Get-AuvikDeviceAvailabilityStatistics -StatId 'uptime' -FilterFromTime '2025-01-01T00:00:00Z' -FilterInterval 'minute'

        Returns the result of the /stat/deviceAvailability/{statId} endpoint

    .EXAMPLE
        Get-AuvikDeviceAvailabilityStatistics -StatId 'uptime' -FilterFromTime '2025-01-01T00:00:00Z' -FilterInterval 'minute' -Tenants '1234567890' -PageFirst 10

        Returns the result of the /stat/deviceAvailability/{statId} endpoint limited to the defined tenant

    .EXAMPLE
        Get-AuvikDeviceAvailabilityStatistics -StatId 'uptime' -FilterFromTime '2025-01-01T00:00:00Z' -FilterInterval 'minute' -AllResults

        Returns every item from the /stat/deviceAvailability/{statId} endpoint by following the pagination links

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /stat/deviceAvailability/{statId}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Statistics/Get-AuvikDeviceAvailabilityStatistics.html
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('uptime', 'outage')]
        [string]$StatId,

        [Parameter(Mandatory = $true)]
        [datetime]$FilterFromTime,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('minute', 'hour', 'day')]
        [string]$FilterInterval,

        [Parameter(Mandatory = $false)]
        [datetime]$FilterThruTime,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('unknown', 'switch', 'l3Switch', 'router', 'accessPoint', 'firewall', 'workstation', 'server', 'storage', 'printer', 'copier', 'hypervisor', 'multimedia', 'phone', 'tablet', 'handheld', 'virtualAppliance', 'bridge', 'controller', 'hub', 'modem', 'ups', 'module', 'loadBalancer', 'camera', 'telecommunications', 'packetProcessor', 'chassis', 'airConditioner', 'virtualMachine', 'pdu', 'ipPhone', 'backhaul', 'internetOfThings', 'voipSwitch', 'stack', 'backupDevice', 'timeClock', 'lightingDevice', 'audioVisual', 'securityAppliance', 'utm', 'alarm', 'buildingManagement', 'ipmi', 'thinAccessPoint', 'thinClient', 'subnet')]
        [string]$FilterDeviceType,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterDeviceId,

        [Parameter(Mandatory = $false)]
        [bool]$FilterOmitUndiscovered,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter(Mandatory = $false)]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = "/stat/deviceAvailability/$([System.Uri]::EscapeDataString($StatId))"
        $NameMap = @{
            FilterFromTime         = 'filter[fromTime]'
            FilterThruTime         = 'filter[thruTime]'
            FilterInterval         = 'filter[interval]'
            FilterDeviceType       = 'filter[deviceType]'
            FilterDeviceId         = 'filter[deviceId]'
            FilterOmitUndiscovered = 'filter[omitUndiscovered]'
            Tenants                = 'tenants'
            PageFirst              = 'page[first]'
            PageAfter              = 'page[after]'
            PageLast               = 'page[last]'
            PageBefore             = 'page[before]'
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        # The API requires filter[thruTime] even though the spec defines it as optional (it defaults to the current time)
        if ($UriParameters.ContainsKey('filter[fromTime]') -and -not $UriParameters.ContainsKey('filter[thruTime]')) { $UriParameters['filter[thruTime]'] = [datetime]::UtcNow }

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
            AllResults  = $AllResults
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}
#EndRegion '.\Public\Statistics\Get-AuvikDeviceAvailabilityStatistics.ps1' 206
#Region '.\Public\Statistics\Get-AuvikDeviceStatistics.ps1' -1

function Get-AuvikDeviceStatistics {
<#
    .SYNOPSIS
        Read Device Statistics

    .DESCRIPTION
        The Get-AuvikDeviceStatistics cmdlet invokes the GET method of the /stat/device/{statId} endpoint (Read Device Statistics)

        Use the Read Device Statistics API to fetch detailed statistics of a client's (and client's children if a multi-client) devices for a given time range.

    .PARAMETER StatId
        ID of statistic to return

        Allowed values:
        'bandwidth', 'cpuUtilization', 'memoryUtilization', 'storageUtilization', 'packetUnicast', 'packetMulticast', 'packetBroadcast'

    .PARAMETER FilterFromTime
        Timestamp from which you want to query

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterInterval
        Statistics reporting interval

        Allowed values:
        'minute', 'hour', 'day'

    .PARAMETER FilterThruTime
        Timestamp to which you want to query (defaults to current time)

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterDeviceType
        Filter by device type.

        Allowed values:
        'unknown', 'switch', 'l3Switch', 'router', 'accessPoint', 'firewall', 'workstation', 'server', 'storage', 'printer', 'copier', 'hypervisor', 'multimedia', 'phone', 'tablet', 'handheld', 'virtualAppliance', 'bridge', 'controller', 'hub', 'modem', 'ups', 'module', 'loadBalancer', 'camera', 'telecommunications', 'packetProcessor', 'chassis', 'airConditioner', 'virtualMachine', 'pdu', 'ipPhone', 'backhaul', 'internetOfThings', 'voipSwitch', 'stack', 'backupDevice', 'timeClock', 'lightingDevice', 'audioVisual', 'securityAppliance', 'utm', 'alarm', 'buildingManagement', 'ipmi', 'thinAccessPoint', 'thinClient', 'subnet'

    .PARAMETER FilterDeviceId
        Filter by device ID

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from.

        Accepts multiple values which are sent to the API as a comma delimited list

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned. Used in combination with page[after].

        Default value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page. The page size is provided by page[first].

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned. Used in combination with page[before].

        Default value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page. The page size is provided by page[last].

    .PARAMETER AllResults
        Returns all items from the endpoint by following the pagination links

        When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters

        Highly recommended to only use with filters to reduce API errors & timeouts

    .EXAMPLE
        Get-AuvikDeviceStatistics -StatId 'bandwidth' -FilterFromTime '2025-01-01T00:00:00Z' -FilterInterval 'minute'

        Returns the result of the /stat/device/{statId} endpoint

    .EXAMPLE
        Get-AuvikDeviceStatistics -StatId 'bandwidth' -FilterFromTime '2025-01-01T00:00:00Z' -FilterInterval 'minute' -Tenants '1234567890' -PageFirst 10

        Returns the result of the /stat/device/{statId} endpoint limited to the defined tenant

    .EXAMPLE
        Get-AuvikDeviceStatistics -StatId 'bandwidth' -FilterFromTime '2025-01-01T00:00:00Z' -FilterInterval 'minute' -AllResults

        Returns every item from the /stat/device/{statId} endpoint by following the pagination links

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /stat/device/{statId}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Statistics/Get-AuvikDeviceStatistics.html
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('bandwidth', 'cpuUtilization', 'memoryUtilization', 'storageUtilization', 'packetUnicast', 'packetMulticast', 'packetBroadcast')]
        [string]$StatId,

        [Parameter(Mandatory = $true)]
        [datetime]$FilterFromTime,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('minute', 'hour', 'day')]
        [string]$FilterInterval,

        [Parameter(Mandatory = $false)]
        [datetime]$FilterThruTime,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('unknown', 'switch', 'l3Switch', 'router', 'accessPoint', 'firewall', 'workstation', 'server', 'storage', 'printer', 'copier', 'hypervisor', 'multimedia', 'phone', 'tablet', 'handheld', 'virtualAppliance', 'bridge', 'controller', 'hub', 'modem', 'ups', 'module', 'loadBalancer', 'camera', 'telecommunications', 'packetProcessor', 'chassis', 'airConditioner', 'virtualMachine', 'pdu', 'ipPhone', 'backhaul', 'internetOfThings', 'voipSwitch', 'stack', 'backupDevice', 'timeClock', 'lightingDevice', 'audioVisual', 'securityAppliance', 'utm', 'alarm', 'buildingManagement', 'ipmi', 'thinAccessPoint', 'thinClient', 'subnet')]
        [string]$FilterDeviceType,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterDeviceId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter(Mandatory = $false)]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = "/stat/device/$([System.Uri]::EscapeDataString($StatId))"
        $NameMap = @{
            FilterFromTime   = 'filter[fromTime]'
            FilterThruTime   = 'filter[thruTime]'
            FilterInterval   = 'filter[interval]'
            FilterDeviceType = 'filter[deviceType]'
            FilterDeviceId   = 'filter[deviceId]'
            Tenants          = 'tenants'
            PageFirst        = 'page[first]'
            PageAfter        = 'page[after]'
            PageLast         = 'page[last]'
            PageBefore       = 'page[before]'
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        # The API requires filter[thruTime] even though the spec defines it as optional (it defaults to the current time)
        if ($UriParameters.ContainsKey('filter[fromTime]') -and -not $UriParameters.ContainsKey('filter[thruTime]')) { $UriParameters['filter[thruTime]'] = [datetime]::UtcNow }

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
            AllResults  = $AllResults
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}
#EndRegion '.\Public\Statistics\Get-AuvikDeviceStatistics.ps1' 199
#Region '.\Public\Statistics\Get-AuvikInterfaceStatistics.ps1' -1

function Get-AuvikInterfaceStatistics {
<#
    .SYNOPSIS
        Read Interface Statistics

    .DESCRIPTION
        The Get-AuvikInterfaceStatistics cmdlet invokes the GET method of the /stat/interface/{statId} endpoint (Read Interface Statistics)

        Use the Read Interface Statistics API to fetch detailed statistics of a client's (and client's children if a multi-client) interfaces for a given time range.

    .PARAMETER StatId
        ID of statistic to return

        Allowed values:
        'bandwidth', 'utilization', 'packetLoss', 'packetDiscard', 'packetMulticast', 'packetUnicast', 'packetBroadcast'

    .PARAMETER FilterFromTime
        Timestamp from which you want to query

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterInterval
        Statistics reporting interval

        Allowed values:
        'minute', 'hour', 'day'

    .PARAMETER FilterThruTime
        Timestamp to which you want to query (defaults to current time)

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterInterfaceType
        Filter by interface type.

        Allowed values:
        'ethernet', 'wifi', 'bluetooth', 'cdma', 'coax', 'cpu', 'distributedVirtualSwitch', 'firewire', 'gsm', 'ieee8023AdLag', 'inferredWired', 'inferredWireless', 'interface', 'linkAggregation', 'loopback', 'modem', 'wimax', 'optical', 'other', 'parallel', 'ppp', 'radiomac', 'rs232', 'tunnel', 'unknown', 'usb', 'virtualBridge', 'virtualNic', 'virtualSwitch', 'vlan'

    .PARAMETER FilterInterfaceId
        Filter by interface ID.

    .PARAMETER FilterParentDevice
        Filter by the entity's parent device ID.

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from.

        Accepts multiple values which are sent to the API as a comma delimited list

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned. Used in combination with page[after].

        Default value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page. The page size is provided by page[first].

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned. Used in combination with page[before].

        Default value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page. The page size is provided by page[last].

    .PARAMETER AllResults
        Returns all items from the endpoint by following the pagination links

        When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters

        Highly recommended to only use with filters to reduce API errors & timeouts

    .EXAMPLE
        Get-AuvikInterfaceStatistics -StatId 'bandwidth' -FilterFromTime '2025-01-01T00:00:00Z' -FilterInterval 'minute'

        Returns the result of the /stat/interface/{statId} endpoint

    .EXAMPLE
        Get-AuvikInterfaceStatistics -StatId 'bandwidth' -FilterFromTime '2025-01-01T00:00:00Z' -FilterInterval 'minute' -Tenants '1234567890' -PageFirst 10

        Returns the result of the /stat/interface/{statId} endpoint limited to the defined tenant

    .EXAMPLE
        Get-AuvikInterfaceStatistics -StatId 'bandwidth' -FilterFromTime '2025-01-01T00:00:00Z' -FilterInterval 'minute' -AllResults

        Returns every item from the /stat/interface/{statId} endpoint by following the pagination links

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /stat/interface/{statId}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Statistics/Get-AuvikInterfaceStatistics.html
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('bandwidth', 'utilization', 'packetLoss', 'packetDiscard', 'packetMulticast', 'packetUnicast', 'packetBroadcast')]
        [string]$StatId,

        [Parameter(Mandatory = $true)]
        [datetime]$FilterFromTime,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('minute', 'hour', 'day')]
        [string]$FilterInterval,

        [Parameter(Mandatory = $false)]
        [datetime]$FilterThruTime,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('ethernet', 'wifi', 'bluetooth', 'cdma', 'coax', 'cpu', 'distributedVirtualSwitch', 'firewire', 'gsm', 'ieee8023AdLag', 'inferredWired', 'inferredWireless', 'interface', 'linkAggregation', 'loopback', 'modem', 'wimax', 'optical', 'other', 'parallel', 'ppp', 'radiomac', 'rs232', 'tunnel', 'unknown', 'usb', 'virtualBridge', 'virtualNic', 'virtualSwitch', 'vlan')]
        [string]$FilterInterfaceType,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterInterfaceId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterParentDevice,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter(Mandatory = $false)]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = "/stat/interface/$([System.Uri]::EscapeDataString($StatId))"
        $NameMap = @{
            FilterFromTime      = 'filter[fromTime]'
            FilterThruTime      = 'filter[thruTime]'
            FilterInterval      = 'filter[interval]'
            FilterInterfaceType = 'filter[interfaceType]'
            FilterInterfaceId   = 'filter[interfaceId]'
            FilterParentDevice  = 'filter[parentDevice]'
            Tenants             = 'tenants'
            PageFirst           = 'page[first]'
            PageAfter           = 'page[after]'
            PageLast            = 'page[last]'
            PageBefore          = 'page[before]'
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        # The API requires filter[thruTime] even though the spec defines it as optional (it defaults to the current time)
        if ($UriParameters.ContainsKey('filter[fromTime]') -and -not $UriParameters.ContainsKey('filter[thruTime]')) { $UriParameters['filter[thruTime]'] = [datetime]::UtcNow }

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
            AllResults  = $AllResults
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}
#EndRegion '.\Public\Statistics\Get-AuvikInterfaceStatistics.ps1' 207
#Region '.\Public\Statistics\Get-AuvikOIDStatistics.ps1' -1

function Get-AuvikOIDStatistics {
<#
    .SYNOPSIS
        Read OID Statistics

    .DESCRIPTION
        The Get-AuvikOIDStatistics cmdlet invokes the GET method of the /stat/oid/{statId} endpoint (Read OID Statistics)

        Use the Read OID Statistics API to fetch the last recorded value of a monitored device OID.

    .PARAMETER StatId
        ID of statistic to return

        Allowed values:
        'deviceMonitor'

    .PARAMETER FilterDeviceId
        Filter by device ID

    .PARAMETER FilterDeviceType
        Filter by device type.

        Allowed values:
        'unknown', 'switch', 'l3Switch', 'router', 'accessPoint', 'firewall', 'workstation', 'server', 'storage', 'printer', 'copier', 'hypervisor', 'multimedia', 'phone', 'tablet', 'handheld', 'virtualAppliance', 'bridge', 'controller', 'hub', 'modem', 'ups', 'module', 'loadBalancer', 'camera', 'telecommunications', 'packetProcessor', 'chassis', 'airConditioner', 'virtualMachine', 'pdu', 'ipPhone', 'backhaul', 'internetOfThings', 'voipSwitch', 'stack', 'backupDevice', 'timeClock', 'lightingDevice', 'audioVisual', 'securityAppliance', 'utm', 'alarm', 'buildingManagement', 'ipmi', 'thinAccessPoint', 'thinClient', 'subnet'

    .PARAMETER FilterOid
        Filter by OID

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from.

        Accepts multiple values which are sent to the API as a comma delimited list

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned. Used in combination with page[after].

        Default value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page. The page size is provided by page[first].

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned. Used in combination with page[before].

        Default value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page. The page size is provided by page[last].

    .PARAMETER AllResults
        Returns all items from the endpoint by following the pagination links

        When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters

        Highly recommended to only use with filters to reduce API errors & timeouts

    .EXAMPLE
        Get-AuvikOIDStatistics -StatId 'd'

        Returns the result of the /stat/oid/{statId} endpoint

    .EXAMPLE
        Get-AuvikOIDStatistics -StatId 'd' -Tenants '1234567890' -PageFirst 10

        Returns the result of the /stat/oid/{statId} endpoint limited to the defined tenant

    .EXAMPLE
        Get-AuvikOIDStatistics -StatId 'd' -AllResults

        Returns every item from the /stat/oid/{statId} endpoint by following the pagination links

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /stat/oid/{statId}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Statistics/Get-AuvikOIDStatistics.html
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('deviceMonitor')]
        [string]$StatId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterDeviceId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('unknown', 'switch', 'l3Switch', 'router', 'accessPoint', 'firewall', 'workstation', 'server', 'storage', 'printer', 'copier', 'hypervisor', 'multimedia', 'phone', 'tablet', 'handheld', 'virtualAppliance', 'bridge', 'controller', 'hub', 'modem', 'ups', 'module', 'loadBalancer', 'camera', 'telecommunications', 'packetProcessor', 'chassis', 'airConditioner', 'virtualMachine', 'pdu', 'ipPhone', 'backhaul', 'internetOfThings', 'voipSwitch', 'stack', 'backupDevice', 'timeClock', 'lightingDevice', 'audioVisual', 'securityAppliance', 'utm', 'alarm', 'buildingManagement', 'ipmi', 'thinAccessPoint', 'thinClient', 'subnet')]
        [string]$FilterDeviceType,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterOid,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter(Mandatory = $false)]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = "/stat/oid/$([System.Uri]::EscapeDataString($StatId))"
        $NameMap = @{
            FilterDeviceId   = 'filter[deviceId]'
            FilterDeviceType = 'filter[deviceType]'
            FilterOid        = 'filter[oid]'
            Tenants          = 'tenants'
            PageFirst        = 'page[first]'
            PageAfter        = 'page[after]'
            PageLast         = 'page[last]'
            PageBefore       = 'page[before]'
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
            AllResults  = $AllResults
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}
#EndRegion '.\Public\Statistics\Get-AuvikOIDStatistics.ps1' 174
#Region '.\Public\Statistics\Get-AuvikServiceStatistics.ps1' -1

function Get-AuvikServiceStatistics {
<#
    .SYNOPSIS
        Read Service Statistics

    .DESCRIPTION
        The Get-AuvikServiceStatistics cmdlet invokes the GET method of the /stat/service/{statId} endpoint (Read Service Statistics)

        Use the Read Service Statistics API to fetch detailed statistics of a client's (and client's children if a multi-client) services for a given time range.

    .PARAMETER StatId
        ID of statistic to return

        Allowed values:
        'pingTime', 'pingPacket'

    .PARAMETER FilterFromTime
        Timestamp from which you want to query

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterInterval
        Statistics reporting interval

        Allowed values:
        'minute', 'hour', 'day'

    .PARAMETER FilterThruTime
        Timestamp to which you want to query (defaults to current time)

        Accepts a date & time which is sent to the API in UTC

    .PARAMETER FilterServiceId
        Filter by service ID

    .PARAMETER Tenants
        Comma delimited list of tenant IDs to request info from.

        Accepts multiple values which are sent to the API as a comma delimited list

    .PARAMETER PageFirst
        For paginated responses, the first N elements will be returned. Used in combination with page[after].

        Default value: 100

    .PARAMETER PageAfter
        Cursor after which elements will be returned as a page. The page size is provided by page[first].

    .PARAMETER PageLast
        For paginated responses, the last N services will be returned. Used in combination with page[before].

        Default value: 100

    .PARAMETER PageBefore
        Cursor before which elements will be returned as a page. The page size is provided by page[last].

    .PARAMETER AllResults
        Returns all items from the endpoint by following the pagination links

        When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters

        Highly recommended to only use with filters to reduce API errors & timeouts

    .EXAMPLE
        Get-AuvikServiceStatistics -StatId 'pingTime' -FilterFromTime '2025-01-01T00:00:00Z' -FilterInterval 'minute'

        Returns the result of the /stat/service/{statId} endpoint

    .EXAMPLE
        Get-AuvikServiceStatistics -StatId 'pingTime' -FilterFromTime '2025-01-01T00:00:00Z' -FilterInterval 'minute' -Tenants '1234567890' -PageFirst 10

        Returns the result of the /stat/service/{statId} endpoint limited to the defined tenant

    .EXAMPLE
        Get-AuvikServiceStatistics -StatId 'pingTime' -FilterFromTime '2025-01-01T00:00:00Z' -FilterInterval 'minute' -AllResults

        Returns every item from the /stat/service/{statId} endpoint by following the pagination links

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : GET /stat/service/{statId}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Statistics/Get-AuvikServiceStatistics.html
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('pingTime', 'pingPacket')]
        [string]$StatId,

        [Parameter(Mandatory = $true)]
        [datetime]$FilterFromTime,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('minute', 'hour', 'day')]
        [string]$FilterInterval,

        [Parameter(Mandatory = $false)]
        [datetime]$FilterThruTime,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterServiceId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tenants,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageFirst,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageAfter,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int64]::MaxValue)]
        [int64]$PageLast,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PageBefore,

        [Parameter(Mandatory = $false)]
        [switch]$AllResults
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = "/stat/service/$([System.Uri]::EscapeDataString($StatId))"
        $NameMap = @{
            FilterFromTime  = 'filter[fromTime]'
            FilterThruTime  = 'filter[thruTime]'
            FilterInterval  = 'filter[interval]'
            FilterServiceId = 'filter[serviceId]'
            Tenants         = 'tenants'
            PageFirst       = 'page[first]'
            PageAfter       = 'page[after]'
            PageLast        = 'page[last]'
            PageBefore      = 'page[before]'
        }

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        # The API requires filter[thruTime] even though the spec defines it as optional (it defaults to the current time)
        if ($UriParameters.ContainsKey('filter[fromTime]') -and -not $UriParameters.ContainsKey('filter[thruTime]')) { $UriParameters['filter[thruTime]'] = [datetime]::UtcNow }

        $InvokeParams = @{
            Method      = 'GET'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
            AllResults  = $AllResults
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        return Invoke-AuvikRequest @InvokeParams

    }

    end {}

}
#EndRegion '.\Public\Statistics\Get-AuvikServiceStatistics.ps1' 187

