#Requires -Version 5.1

<#
.SYNOPSIS
    Creates a combined device lifecycle & warranty report for one Auvik tenant

.DESCRIPTION
    The Get-DeviceLifecycleExample.ps1 script is a read-only example that:

        1. Finds the tenant by its display name (or uses the tenant ID that is provided)
        2. Gets the lifecycle information of the devices with Get-AuvikDeviceLifecycle -AllResults
        3. Gets the warranty information of the devices with Get-AuvikDeviceWarranty -AllResults
        4. Combines both by device ID into one report & flags warranties that are expired or expire soon
        5. Optionally exports the report to a CSV file

    Requests are limited to one tenant with the -Tenants parameter which is the Auvik best practice. The Auvik API
    allows 2500 requests per 5 minutes

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

.PARAMETER LastSupportStatus
    Only include devices with this last support status in the lifecycle data

    Allowed values:
        'covered', 'available', 'expired', 'securityOnly', 'unpublished', 'empty'

.PARAMETER ExpiringWithinDays
    Warranties that expire within this number of days are flagged as expiring soon

    Default value: 90

.PARAMETER OutputPath
    Exports the report to this CSV file. No file is written when the parameter is not used

.EXAMPLE
    ./Get-DeviceLifecycleExample.ps1 -TenantName 'Contoso'

    Returns the combined lifecycle & warranty report of the Contoso tenant

.EXAMPLE
    ./Get-DeviceLifecycleExample.ps1 -TenantName 'Contoso' -ExpiringWithinDays 180 -OutputPath ./Lifecycle.csv

    Flags warranties that expire within 180 days & exports the report to a CSV file

.NOTES
    Only read requests are made
    Lifecycle & warranty data is only available for supported devices

.LINK
    https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikDeviceLifecycle.html

.LINK
    https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikDeviceWarranty.html
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
    [ValidateSet('covered', 'available', 'expired', 'securityOnly', 'unpublished', 'empty')]
    [string]$LastSupportStatus,

    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 3650)]
    [int]$ExpiringWithinDays = 90,

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

# Get the lifecycle & warranty data of the tenant
$LifecycleParams = @{
    Tenants     = $TenantId
    AllResults  = $true
}

if ($LastSupportStatus) { $LifecycleParams['FilterLastSupportStatus'] = $LastSupportStatus }

$LifecycleResponse  = Get-AuvikDeviceLifecycle @LifecycleParams -ErrorAction Stop
$WarrantyResponse   = Get-AuvikDeviceWarranty -Tenants $TenantId -AllResults -ErrorAction Stop

# The lifecycle & warranty resources share the ID of their device
$Lifecycle = @{}
foreach ($Item in @($LifecycleResponse.data)) { if ($null -ne $Item) { $Lifecycle[[string]$Item.id] = $Item } }

$Warranty = @{}
foreach ($Item in @($WarrantyResponse.data)) { if ($null -ne $Item) { $Warranty[[string]$Item.id] = $Item } }

$DeviceIds = @($Lifecycle.Keys) + @($Warranty.Keys | Where-Object { -not $Lifecycle.ContainsKey($_) })

$Today = (Get-Date).Date

$Report = foreach ($DeviceId in $DeviceIds) {

    $LifecycleItem  = $Lifecycle[$DeviceId]
    $WarrantyItem   = $Warranty[$DeviceId]

    $DeviceName = $LifecycleItem.attributes.deviceName
    if (-not $DeviceName) { $DeviceName = $WarrantyItem.attributes.deviceName }

    # The warranty expiration date is not guaranteed to be a date
    $ExpirationDate = $null
    $ParsedDate     = [datetime]::MinValue
    $RawDate        = $WarrantyItem.attributes.warrantyExpirationDate

    if ($RawDate -is [datetime]) { $ExpirationDate = $RawDate.ToUniversalTime() }
    elseif ($RawDate -and [datetime]::TryParse([string]$RawDate, [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::AdjustToUniversal -bor [Globalization.DateTimeStyles]::AssumeUniversal, [ref]$ParsedDate)) {
        $ExpirationDate = $ParsedDate
    }

    $WarrantyFlag = 'Unknown'
    if ($ExpirationDate) {
        if ($ExpirationDate.Date -lt $Today) { $WarrantyFlag = 'Expired' }
        elseif ($ExpirationDate.Date -le $Today.AddDays($ExpiringWithinDays)) { $WarrantyFlag = 'ExpiringSoon' }
        else { $WarrantyFlag = 'OK' }
    }

    [PSCustomObject]@{
        TenantName                          = $ResolvedTenantName
        DeviceId                            = $DeviceId
        DeviceName                          = $DeviceName
        SalesAvailability                   = $LifecycleItem.attributes.salesAvailability
        SoftwareMaintenanceStatus           = $LifecycleItem.attributes.softwareMaintenanceStatus
        SecuritySoftwareMaintenanceStatus   = $LifecycleItem.attributes.securitySoftwareMaintenanceStatus
        LastSupportStatus                   = $LifecycleItem.attributes.lastSupportStatus
        WarrantyCoverageStatus              = $WarrantyItem.attributes.warrantyCoverageStatus
        WarrantyExpirationDate              = if ($ExpirationDate) { $ExpirationDate.ToString('yyyy-MM-dd') } else { $RawDate }
        WarrantyFlag                        = $WarrantyFlag
        ServiceCoverageStatus               = $WarrantyItem.attributes.serviceCoverageStatus
        ContractRenewalAvailability         = $WarrantyItem.attributes.contractRenewalAvailability
        RecommendedSoftwareVersion          = $WarrantyItem.attributes.recommendedSoftwareVersion
    }

}

$Report = @($Report | Sort-Object -Property DeviceName)

if ($Report.Count -eq 0) {
    Write-Warning "No lifecycle or warranty data was returned for tenant [ $ResolvedTenantName ]."
    return
}

if ($OutputPath) {
    $Report | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
    Write-Verbose "Exported [ $($Report.Count) ] devices to [ $OutputPath ]"
}

$Report
