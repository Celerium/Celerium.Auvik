#Requires -Version 5.1

<#
.SYNOPSIS
    Exports the device inventory of one Auvik tenant to a CSV file

.DESCRIPTION
    The Get-DeviceInventoryExample.ps1 script is a read-only example that:

        1. Gets the tenants of the Auvik account with Get-AuvikTenant
        2. Gets the tenant details (display names) with Get-AuvikTenantDetail
        3. Finds the tenant by its display name (or uses the tenant ID that is provided)
        4. Gets every device of that single tenant with Get-AuvikDeviceInfo -AllResults, using optional filters
        5. Exports the devices to a CSV file with Export-Csv

    Requests are always limited to one tenant with the -Tenants parameter which is the Auvik best practice. The Auvik API
    allows 2500 requests per 5 minutes, so use filters instead of gathering everything when possible

    The module must already be configured with credentials. Run Connect-AuvikExample.ps1 first, set the
    AUVIK_USERNAME & AUVIK_API_KEY environment variables, or run Import-AuvikModuleSetting

    It works on Windows PowerShell 5.1 & PowerShell 7+ on Windows, Linux, & macOS

.PARAMETER TenantName
    The display name of the Auvik tenant (client) to export devices from

    The name is compared without case sensitivity & must match exactly one tenant

.PARAMETER TenantId
    The ID of the Auvik tenant. When used the tenants do not need to be looked up & TenantName is ignored

.PARAMETER TenantDomainPrefix
    The domain prefix of the main Auvik account which is required to read the tenant details

    Default value: the first multi-client tenant returned by Get-AuvikTenant, otherwise the first tenant

.PARAMETER DeviceType
    Only export devices of this type, such as switch, router, firewall, or server

    The allowed values are validated by Get-AuvikDeviceInfo

.PARAMETER OnlineStatus
    Only export devices with this online status

    Allowed values:
        'online', 'offline', 'unreachable', 'testing', 'unknown', 'dormant', 'notPresent', 'lowerLayerDown'

.PARAMETER VendorName
    Only export devices from this vendor

.PARAMETER NotSeenSinceDays
    Only export devices that have not been seen online for this many days

.PARAMETER OutputPath
    The path of the CSV file

    Default value: AuvikDeviceInventory.csv in the current directory

.PARAMETER PassThru
    Also returns the exported devices to the pipeline

.EXAMPLE
    ./Get-DeviceInventoryExample.ps1 -TenantName 'Contoso'

    Exports every device of the Contoso tenant to AuvikDeviceInventory.csv in the current directory

.EXAMPLE
    ./Get-DeviceInventoryExample.ps1 -TenantName 'Contoso' -DeviceType switch -OnlineStatus offline -OutputPath ./OfflineSwitches.csv

    Exports the offline switches of the Contoso tenant

.EXAMPLE
    ./Get-DeviceInventoryExample.ps1 -TenantId '1234567890' -NotSeenSinceDays 30 -PassThru | Format-Table DeviceName, LastSeenTime

    Exports devices that have not been seen for 30 days & shows them in the console

.NOTES
    Only read requests are made

.LINK
    https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikDeviceInfo.html
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
    [string]$DeviceType,

    [Parameter(Mandatory = $false)]
    [ValidateSet('online', 'offline', 'unreachable', 'testing', 'unknown', 'dormant', 'notPresent', 'lowerLayerDown')]
    [string]$OnlineStatus,

    [Parameter(Mandatory = $false)]
    [string]$VendorName,

    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 3650)]
    [int]$NotSeenSinceDays,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = (Join-Path -Path (Get-Location).Path -ChildPath 'AuvikDeviceInventory.csv'),

    [Parameter(Mandatory = $false)]
    [switch]$PassThru
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

# Get the devices of the tenant
$DeviceParams = @{
    Tenants     = $TenantId
    AllResults  = $true
}

if ($DeviceType)        { $DeviceParams['FilterDeviceType']     = $DeviceType }
if ($OnlineStatus)      { $DeviceParams['FilterOnlineStatus']   = $OnlineStatus }
if ($VendorName)        { $DeviceParams['FilterVendorName']     = $VendorName }
if ($NotSeenSinceDays)  { $DeviceParams['FilterNotSeenSince']   = (Get-Date).AddDays(-$NotSeenSinceDays) }

$DeviceResponse = Get-AuvikDeviceInfo @DeviceParams -ErrorAction Stop

$Devices = foreach ($Device in @($DeviceResponse.data)) {

    if ($null -eq $Device) { continue }

    [PSCustomObject]@{
        TenantId        = $TenantId
        TenantName      = $ResolvedTenantName
        DeviceId        = $Device.id
        DeviceName      = $Device.attributes.deviceName
        DeviceType      = $Device.attributes.deviceType
        MakeModel       = $Device.attributes.makeModel
        VendorName      = $Device.attributes.vendorName
        SerialNumber    = $Device.attributes.serialNumber
        IpAddresses     = @($Device.attributes.ipAddresses) -join ';'
        SoftwareVersion = $Device.attributes.softwareVersion
        FirmwareVersion = $Device.attributes.firmwareVersion
        OnlineStatus    = $Device.attributes.onlineStatus
        LastSeenTime    = $Device.attributes.lastSeenTime
        LastModified    = $Device.attributes.lastModified
        Description     = $Device.attributes.description
    }

}

$Devices = @($Devices)

if ($Devices.Count -eq 0) {
    Write-Warning "No devices were returned for tenant [ $ResolvedTenantName ] with the provided filters. No file was written."
    return
}

$Devices | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8

Write-Verbose "Exported [ $($Devices.Count) ] devices to [ $OutputPath ]"

if ($PassThru) { $Devices }
else {
    [PSCustomObject]@{
        TenantName      = $ResolvedTenantName
        TenantId        = $TenantId
        DeviceCount     = $Devices.Count
        OutputPath      = $OutputPath
    }
}
