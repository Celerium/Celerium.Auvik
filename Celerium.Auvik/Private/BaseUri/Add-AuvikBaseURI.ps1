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