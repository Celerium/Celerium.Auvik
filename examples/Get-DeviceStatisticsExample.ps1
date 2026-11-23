#Requires -Version 5.1

<#
.SYNOPSIS
    Summarizes a device statistic (such as CPU utilization) of one Auvik tenant for a time window

.DESCRIPTION
    The Get-DeviceStatisticsExample.ps1 script is a read-only example that:

        1. Finds the tenant by its display name (or uses the tenant ID that is provided)
        2. Gets a device statistic with Get-AuvikDeviceStatistics for a time window (by default CPU utilization per hour for the last 24 hours)
        3. Flattens the statistics into one row per device, statistic, & timestamp
        4. Returns the average, minimum, & maximum value per device
        5. Optionally exports every data point to a CSV file

    Requests are limited to one tenant with the -Tenants parameter which is the Auvik best practice. Use the
    DeviceType or DeviceId parameters to reduce the amount of data. The Auvik API allows 2500 requests per 5 minutes

    The module must already be configured with credentials. Run Connect-AuvikExample.ps1 first, set the
    AUVIK_USERNAME & AUVIK_API_KEY environment variables, or run Import-AuvikModuleSetting

    It works on Windows PowerShell 5.1 & PowerShell 7+ on Windows, Linux, & macOS

.PARAMETER TenantName
    The display name of the Auvik tenant (client) to report on

    The name is compared without case sensitivity & must match exactly one tenant

.PARAMETER TenantId
    The ID of the Auvik tenant. When used the tenants do not need to be looked up & TenantName is ignored

.PARAMETER TenantDomainPrefix
    The domain prefix of the main Auvik account which is required to read the tenant details

    Default value: the first multi-client tenant returned by Get-AuvikTenant, otherwise the first tenant

.PARAMETER StatId
    The device statistic to get

    Default value: cpuUtilization

    Allowed values:
        'bandwidth', 'cpuUtilization', 'memoryUtilization', 'storageUtilization', 'packetUnicast', 'packetMulticast', 'packetBroadcast'

.PARAMETER Hours
    The size of the window in hours that ends now

    Default value: 24

.PARAMETER Interval
    The interval between the data points

    Default value: hour

    Allowed values:
        'minute', 'hour', 'day'

.PARAMETER DeviceType
    Only get statistics of devices of this type, such as switch, router, or firewall

    The allowed values are validated by Get-AuvikDeviceStatistics

.PARAMETER DeviceId
    Only get statistics of the device with this ID

.PARAMETER OutputPath
    Exports every data point to this CSV file. No file is written when the parameter is not used

.EXAMPLE
    ./Get-DeviceStatisticsExample.ps1 -TenantName 'Contoso'

    Summarizes the hourly CPU utilization of the devices of the Contoso tenant for the last 24 hours

.EXAMPLE
    ./Get-DeviceStatisticsExample.ps1 -TenantName 'Contoso' -StatId memoryUtilization -Hours 48 -DeviceType server -OutputPath ./ServerMemory.csv

    Summarizes the hourly memory utilization of the servers for the last 48 hours & exports every data point

.NOTES
    Only read requests are made

.LINK
    https://celerium.github.io/Celerium.Auvik/site/Statistics/Get-AuvikDeviceStatistics.html
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$TenantName,

    [Parameter(Mandatory = $false)]
    [string]$TenantId,

    [Parameter(Mandatory = $false)]
    [string]$TenantDomainPrefix,

    [Parameter(Mandatory = $false)]
    [ValidateSet('bandwidth', 'cpuUtilization', 'memoryUtilization', 'storageUtilization', 'packetUnicast', 'packetMulticast', 'packetBroadcast')]
    [string]$StatId = 'cpuUtilization',

    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 720)]
    [int]$Hours = 24,

    [Parameter(Mandatory = $false)]
    [ValidateSet('minute', 'hour', 'day')]
    [string]$Interval = 'hour',

    [Parameter(Mandatory = $false)]
    [string]$DeviceType,

    [Parameter(Mandatory = $false)]
    [string]$DeviceId,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath
)

# Import the module by name. To use a local copy of the repository instead run something like:
# Import-Module -Name 'C:\Path\To\Celerium.Auvik\Celerium.Auvik\Celerium.Auvik.psd1' -Force
if (-not (Get-Module -Name Celerium.Auvik)) { Import-Module -Name Celerium.Auvik -ErrorAction Stop }

if (-not (Get-AuvikAPIKey -WarningAction SilentlyContinue)) {
    throw 'The module is not configured. Run Connect-AuvikExample.ps1, set the AUVIK_USERNAME & AUVIK_API_KEY environment variables, or run Import-AuvikModuleSetting.'
}

# Find the tenant
$ResolvedTenantName = $TenantName

if (-not $TenantId) {

    if (-not $TenantDomainPrefix) {

        $TenantList = Get-AuvikTenant -ErrorAction Stop
        $MainTenant = @($TenantList.data) | Where-Object { $_.attributes.tenantType -eq 'multiClient' } | Select-Object -First 1
        if (-not $MainTenant) { $MainTenant = @($TenantList.data) | Select-Object -First 1 }
        if (-not $MainTenant) { throw 'Get-AuvikTenant did not return any tenants.' }

        $TenantDomainPrefix = $MainTenant.attributes.domainPrefix

    }

    $TenantDetail = Get-AuvikTenantDetail -TenantDomainPrefix $TenantDomainPrefix -FilterAvailableTenants $true -ErrorAction Stop
    $AvailableTenants = @($TenantDetail.data)

    if (-not $TenantName) {
        throw "Specify -TenantName or -TenantId. Available tenants: $(($AvailableTenants.attributes.displayName | Sort-Object) -join ', ')"
    }

    $MatchedTenants = @($AvailableTenants | Where-Object { $_.attributes.displayName -eq $TenantName })

    if ($MatchedTenants.Count -ne 1) {
        throw "Expected exactly one tenant named [ $TenantName ] but found [ $($MatchedTenants.Count) ]. Available tenants: $(($AvailableTenants.attributes.displayName | Sort-Object) -join ', ')"
    }

    $TenantId           = $MatchedTenants[0].id
    $ResolvedTenantName = $MatchedTenants[0].attributes.displayName

}

# Get the statistics of the tenant for the window
$StatParams = @{
    StatId          = $StatId
    FilterFromTime  = (Get-Date).AddHours(-$Hours)
    FilterThruTime  = Get-Date
    FilterInterval  = $Interval
    Tenants         = $TenantId
    AllResults      = $true
}

if ($DeviceType)    { $StatParams['FilterDeviceType'] = $DeviceType }
if ($DeviceId)      { $StatParams['FilterDeviceId']   = $DeviceId }

$StatResponse = Get-AuvikDeviceStatistics @StatParams -ErrorAction Stop

# One row per device, statistic, timestamp, & value column
$DataPoints = foreach ($Resource in @($StatResponse.data)) {

    if ($null -eq $Resource) { continue }

    $Device = $Resource.relationships.device.data

    foreach ($Stat in @($Resource.attributes.stats)) {

        $Legend = @($Stat.legend)
        $Unit   = @($Stat.unit)

        foreach ($Row in @($Stat.data)) {

            $Columns = @($Row)

            # The timestamp is either an extra first column or the first column that the legend describes
            $TimeInLegend   = ($Legend.Count -gt 0) -and ([string]$Legend[0] -match '^(time|timestamp|date)')
            $Timestamp      = $null
            $FirstValue     = 0
            if ($TimeInLegend -or $Columns.Count -gt $Legend.Count) { $Timestamp = $Columns[0]; $FirstValue = 1 }

            if ($Timestamp -is [datetime]) { $Timestamp = $Timestamp.ToUniversalTime().ToString('o') }
            elseif ($Timestamp -is [ValueType] -and [double]$Timestamp -gt 100000000000) {
                $Timestamp = [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$Timestamp).UtcDateTime.ToString('o')
            }

            for ($Index = $FirstValue; $Index -lt $Columns.Count; $Index++) {

                if ($TimeInLegend) { $LegendIndex = $Index } else { $LegendIndex = $Index - $FirstValue }

                [PSCustomObject]@{
                    TenantName  = $ResolvedTenantName
                    DeviceId    = $Device.id
                    DeviceName  = $Device.deviceName
                    DeviceType  = $Device.deviceType
                    StatId      = $StatId
                    StatName    = $Stat.name
                    StatIndex   = $Stat.index
                    Timestamp   = $Timestamp
                    Legend      = if ($LegendIndex -lt $Legend.Count) { $Legend[$LegendIndex] } else { "Column$LegendIndex" }
                    Unit        = if ($LegendIndex -lt $Unit.Count) { $Unit[$LegendIndex] } else { $null }
                    Value       = $Columns[$Index]
                }

            }

        }

    }

}

$DataPoints = @($DataPoints)

if ($DataPoints.Count -eq 0) {
    Write-Warning "No [ $StatId ] statistics were returned for tenant [ $ResolvedTenantName ] in the last [ $Hours ] hours."
    return
}

if ($OutputPath) {
    $DataPoints | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
    Write-Verbose "Exported [ $($DataPoints.Count) ] data points to [ $OutputPath ]"
}

# Summarize per device, statistic, & value column
$DataPoints |
    Where-Object { $null -ne $_.Value } |
    Group-Object -Property DeviceId, StatName, StatIndex, Legend |
    ForEach-Object {

        $Measure = $_.Group | Measure-Object -Property Value -Average -Minimum -Maximum

        [PSCustomObject]@{
            TenantName  = $ResolvedTenantName
            DeviceName  = $_.Group[0].DeviceName
            DeviceType  = $_.Group[0].DeviceType
            StatName    = $_.Group[0].StatName
            Legend      = $_.Group[0].Legend
            Unit        = $_.Group[0].Unit
            Samples     = $Measure.Count
            Average     = [math]::Round($Measure.Average, 2)
            Minimum     = $Measure.Minimum
            Maximum     = $Measure.Maximum
        }

    }
