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
