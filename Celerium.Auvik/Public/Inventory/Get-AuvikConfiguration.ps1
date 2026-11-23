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
