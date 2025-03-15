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
        the ResourceUri parameter

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

[CmdletBinding(DefaultParameterSetName = 'Convert')]
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

        # Build the request and load it with the query string
        $UriRequest        = [System.UriBuilder]($AuvikModuleBaseURI + $ResourceUri)
        $UriRequest.Query  = $QueryString.ToString()

        return $UriRequest

    }

    end {}

}