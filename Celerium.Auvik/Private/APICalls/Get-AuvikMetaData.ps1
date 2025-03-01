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