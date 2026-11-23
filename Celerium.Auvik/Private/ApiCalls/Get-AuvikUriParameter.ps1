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
