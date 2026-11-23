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
