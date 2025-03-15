function Invoke-AuvikRequest {
<#
    .SYNOPSIS
        Makes an API request

    .DESCRIPTION
        The Invoke-AuvikRequest cmdlet invokes an API request to Auvik API

        This is an internal function that is used by all public functions

        As of 2023-08 the Auvik v1 API only supports GET requests

    .PARAMETER Method
        Defines the type of API method to use

        Allowed values:
        'GET'

    .PARAMETER ResourceUri
        Defines the resource uri (url) to use when creating the API call

    .PARAMETER UriFilter
        Used with the internal function [ ConvertTo-AuvikQueryString ] to combine
        a functions parameters with the ResourceUri parameter

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