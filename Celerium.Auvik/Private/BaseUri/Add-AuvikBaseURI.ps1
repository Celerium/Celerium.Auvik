function Add-AuvikBaseURI {
<#
    .SYNOPSIS
        Sets the base URI for the Auvik API connection

    .DESCRIPTION
        The Add-AuvikBaseURI cmdlet sets the base URI which is later used
        to construct the full URI for all API calls

    .PARAMETER BaseUri
        Define the base URI for the Auvik API connection using Auvik's URI or a custom URI

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
        Add-AuvikBaseURI -BaseUri http://myapi.gateway.celerium.org

        A custom API gateway of http://myapi.gateway.celerium.org will be used for all API calls to Auvik's API

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