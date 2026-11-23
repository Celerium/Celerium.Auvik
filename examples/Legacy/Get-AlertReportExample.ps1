#Requires -Version 5.1

<#
    ###########################################################################################################
    LEGACY - WRITES DATA

    This example can DISMISS ALERTS in Auvik (Send-AuvikAlertDismiss, POST /alert/dismiss/{id}) when the
    -Dismiss switch is used. It is kept for reference only. Review it, run it with -WhatIf first, and only use
    it against an account where changing data is allowed. The read-only version is ..\Get-AlertReportExample.ps1
    ###########################################################################################################
#>

<#
.SYNOPSIS
    Summarizes the recent alerts of one Auvik tenant by severity

.DESCRIPTION
    The Get-AlertReportExample.ps1 script is read-only by default. It:

        1. Finds the tenant by its display name (or uses the tenant ID that is provided)
        2. Gets the alert history of that single tenant with Get-AuvikAlertHistory -AllResults using filters
        3. Summarizes the alerts by severity & status
        4. Optionally exports the alert details to a CSV file

    WRITE ACTION (disabled by default):
    The -Dismiss switch dismisses every alert that matches the filters with Send-AuvikAlertDismiss. This changes data in Auvik
    The action is guarded:

        - Nothing is dismissed unless -Dismiss is used
        - -WhatIf shows which alerts would be dismissed without sending any request
        - Without -Confirm:$false each dismissal asks for confirmation

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

.PARAMETER Days
    Only include alerts that were detected in the last number of days

    Default value: 7

.PARAMETER Severity
    Only include alerts with this severity

    Allowed values:
        'unknown', 'emergency', 'critical', 'warning', 'info'

.PARAMETER Status
    Only include alerts with this status

    Allowed values:
        'created', 'resolved', 'paused', 'unpaused'

.PARAMETER IncludeDismissed
    Also include alerts that are already dismissed. By default only alerts that are not dismissed are included

.PARAMETER OutputPath
    Exports the alert details to this CSV file. No file is written when the parameter is not used

.PARAMETER Dismiss
    WRITE ACTION. Dismisses the alerts that match the filters with Send-AuvikAlertDismiss

    Use together with -WhatIf first to review the alerts that would be dismissed

.EXAMPLE
    ./Get-AlertReportExample.ps1 -TenantName 'Contoso'

    Summarizes the alerts of the last 7 days of the Contoso tenant by severity

.EXAMPLE
    ./Get-AlertReportExample.ps1 -TenantName 'Contoso' -Days 30 -Severity critical -OutputPath ./CriticalAlerts.csv

    Summarizes the critical alerts of the last 30 days & exports the details to a CSV file

.EXAMPLE
    ./Get-AlertReportExample.ps1 -TenantName 'Contoso' -Severity info -Status resolved -Dismiss -WhatIf

    Shows which resolved informational alerts would be dismissed without dismissing anything

.NOTES
    Only read requests are made unless the -Dismiss switch is used

.LINK
    https://celerium.github.io/Celerium.Auvik/site/Alert/Get-AuvikAlertHistory.html

.LINK
    https://celerium.github.io/Celerium.Auvik/site/Alert/Send-AuvikAlertDismiss.html
#>

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param (
    [Parameter(Mandatory = $false)]
    [string]$TenantName,

    [Parameter(Mandatory = $false)]
    [string]$TenantId,

    [Parameter(Mandatory = $false)]
    [string]$TenantDomainPrefix,

    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 365)]
    [int]$Days = 7,

    [Parameter(Mandatory = $false)]
    [ValidateSet('unknown', 'emergency', 'critical', 'warning', 'info')]
    [string]$Severity,

    [Parameter(Mandatory = $false)]
    [ValidateSet('created', 'resolved', 'paused', 'unpaused')]
    [string]$Status,

    [Parameter(Mandatory = $false)]
    [switch]$IncludeDismissed,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath,

    [Parameter(Mandatory = $false)]
    [switch]$Dismiss
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

# Get the alerts of the tenant
$AlertParams = @{
    Tenants                 = $TenantId
    FilterDetectedTimeAfter = (Get-Date).AddDays(-$Days)
    AllResults              = $true
}

if (-not $IncludeDismissed) { $AlertParams['FilterDismissed'] = $false }
if ($Severity)              { $AlertParams['FilterSeverity']  = $Severity }
if ($Status)                { $AlertParams['FilterStatus']    = $Status }

$AlertResponse = Get-AuvikAlertHistory @AlertParams -ErrorAction Stop

$Alerts = foreach ($Alert in @($AlertResponse.data)) {

    if ($null -eq $Alert) { continue }

    [PSCustomObject]@{
        TenantName      = $ResolvedTenantName
        AlertId         = $Alert.id
        Name            = $Alert.attributes.name
        Severity        = $Alert.attributes.severity
        Status          = $Alert.attributes.status
        DetectedOn      = $Alert.attributes.detectedOn
        Dismissed       = $Alert.attributes.dismissed
        Dispatched      = $Alert.attributes.dispatched
        Description     = $Alert.attributes.description
    }

}

$Alerts = @($Alerts)

if ($Alerts.Count -eq 0) {
    Write-Warning "No alerts were found for tenant [ $ResolvedTenantName ] in the last [ $Days ] days with the provided filters."
    return
}

if ($OutputPath) {
    $Alerts | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8 -WhatIf:$false
    Write-Verbose "Exported [ $($Alerts.Count) ] alerts to [ $OutputPath ]"
}

# Summarize by severity, the most severe first
$SeverityOrder = 'emergency', 'critical', 'warning', 'info', 'unknown'

$Alerts |
    Group-Object -Property Severity |
    Sort-Object -Property @{ Expression = { $Index = [array]::IndexOf($SeverityOrder, $_.Name); if ($Index -lt 0) { $SeverityOrder.Count } else { $Index } } } |
    ForEach-Object {
        [PSCustomObject]@{
            TenantName  = $ResolvedTenantName
            Severity    = $_.Name
            Count       = $_.Count
            Created     = @($_.Group | Where-Object { $_.Status -eq 'created' }).Count
            Resolved    = @($_.Group | Where-Object { $_.Status -eq 'resolved' }).Count
            Other       = @($_.Group | Where-Object { $_.Status -notin 'created', 'resolved' }).Count
        }
    }

# WRITE ACTION - only runs when -Dismiss is used. Combine with -WhatIf to preview the alerts that would be dismissed
if ($Dismiss) {

    foreach ($Alert in $Alerts) {

        if ($PSCmdlet.ShouldProcess("Alert [ $($Alert.AlertId) ] $($Alert.Name) ($($Alert.Severity))", 'Dismiss')) {
            $null = Send-AuvikAlertDismiss -Id $Alert.AlertId -Confirm:$false -ErrorAction Stop
        }

    }

}
