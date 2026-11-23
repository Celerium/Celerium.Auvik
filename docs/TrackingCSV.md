---
title: Tracking CSV
parent: Home
nav_order: 2
---

# Tracking CSV

When updating the documentation for this project, the tracking CSV plays a huge part in organizing of the markdown documents. Any new functions or endpoints should be added to the tracking CSV when publishing an updated module or documentation version.

{: .warning }
I recommend downloading the CSV from the link provided rather then viewing the table below.

[Tracking CSV](https://github.com/Celerium/Celerium.Auvik/blob/main/docs/endpoints.csv)

---

## CSV markdown table

|Category|EndpointUri|Method|Function|Example|Complete|Notes|
|--------|-----------|------|--------|-------|--------|-----|
|Internal||GET|ConvertTo-AuvikQueryString|N/A|Yes||
|Internal||GET|Get-AuvikUriParameter|N/A|Yes||
|Internal||GET|Invoke-AuvikRequest|N/A|Yes||
|Internal||PUT|Add-AuvikAPIKey|N/A|Yes||
|Internal||GET|Get-AuvikAPIKey|N/A|Yes||
|Internal||DELETE|Remove-AuvikAPIKey|N/A|Yes||
|Internal||PUT|Add-AuvikBaseURI|N/A|Yes||
|Internal||GET|Get-AuvikBaseURI|N/A|Yes||
|Internal||DELETE|Remove-AuvikBaseURI|N/A|Yes||
|Internal||PUT|Export-AuvikModuleSetting|N/A|Yes||
|Internal||GET|Get-AuvikModuleSetting|N/A|Yes||
|Internal||GET|Import-AuvikModuleSetting|N/A|Yes||
|Internal||PUT|Initialize-AuvikModuleSetting|N/A|Yes||
|Internal||DELETE|Remove-AuvikModuleSetting|N/A|Yes||
|Other|/authentication/verify|GET|Get-AuvikAuthenticationVerify|Connect-AuvikExample.ps1|Yes||
|Inventory|/inventory/device/info|GET|Get-AuvikDeviceInfo|Get-DeviceInventoryExample.ps1|Yes|Parameter set List|
|Inventory|/inventory/device/info/{id}|GET|Get-AuvikDeviceInfo|Get-DeviceInventoryExample.ps1|Yes|Parameter set ById|
|Inventory|/inventory/device/detail|GET|Get-AuvikDeviceDetail||Yes|Parameter set List|
|Inventory|/inventory/device/detail/{id}|GET|Get-AuvikDeviceDetail||Yes|Parameter set ById|
|Inventory|/inventory/device/detail/extended|GET|Get-AuvikDeviceDetailExtended||Yes|Parameter set List|
|Inventory|/inventory/device/detail/extended/{id}|GET|Get-AuvikDeviceDetailExtended||Yes|Parameter set ById|
|Inventory|/inventory/device/warranty|GET|Get-AuvikDeviceWarranty|Get-DeviceLifecycleExample.ps1|Yes|Parameter set List|
|Inventory|/inventory/device/warranty/{id}|GET|Get-AuvikDeviceWarranty|Get-DeviceLifecycleExample.ps1|Yes|Parameter set ById|
|Inventory|/inventory/device/lifecycle|GET|Get-AuvikDeviceLifecycle|Get-DeviceLifecycleExample.ps1|Yes|Parameter set List|
|Inventory|/inventory/device/lifecycle/{id}|GET|Get-AuvikDeviceLifecycle|Get-DeviceLifecycleExample.ps1|Yes|Parameter set ById|
|Inventory|/inventory/configuration|GET|Get-AuvikConfiguration||Yes|Parameter set List|
|Inventory|/inventory/configuration/{id}|GET|Get-AuvikConfiguration||Yes|Parameter set ById|
|Inventory|/inventory/network/info|GET|Get-AuvikNetworkInfo||Yes|Parameter set List|
|Inventory|/inventory/network/info/{id}|GET|Get-AuvikNetworkInfo||Yes|Parameter set ById|
|Inventory|/inventory/network/detail|GET|Get-AuvikNetworkDetail||Yes|Parameter set List|
|Inventory|/inventory/network/detail/{id}|GET|Get-AuvikNetworkDetail||Yes|Parameter set ById|
|Inventory|/inventory/interface/info|GET|Get-AuvikInterfaceInfo||Yes|Parameter set List|
|Inventory|/inventory/interface/info/{id}|GET|Get-AuvikInterfaceInfo||Yes|Parameter set ById|
|Inventory|/inventory/component/info|GET|Get-AuvikComponentInfo||Yes|Parameter set List|
|Inventory|/inventory/component/info/{id}|GET|Get-AuvikComponentInfo||Yes|Parameter set ById|
|Inventory|/inventory/entity/note|GET|Get-AuvikEntityNote||Yes|Parameter set List|
|Inventory|/inventory/entity/note/{id}|GET|Get-AuvikEntityNote||Yes|Parameter set ById|
|Inventory|/inventory/entity/audit|GET|Get-AuvikEntityAudit||Yes|Parameter set List|
|Inventory|/inventory/entity/audit/{id}|GET|Get-AuvikEntityAudit||Yes|Parameter set ById|
|ClientManagement|/tenants|GET|Get-AuvikTenant|Get-DeviceInventoryExample.ps1|Yes||
|ClientManagement|/tenants/detail|GET|Get-AuvikTenantDetail|Get-DeviceInventoryExample.ps1|Yes|Parameter set List|
|ClientManagement|/tenants/detail/{id}|GET|Get-AuvikTenantDetail|Get-DeviceInventoryExample.ps1|Yes|Parameter set ById|
|Alert|/alert/history/info|GET|Get-AuvikAlertHistory|Get-AlertReportExample.ps1|Yes|Parameter set List|
|Alert|/alert/history/info/{id}|GET|Get-AuvikAlertHistory|Get-AlertReportExample.ps1|Yes|Parameter set ById|
|Alert|/alert/dismiss/{id}|POST|Send-AuvikAlertDismiss|Legacy/Get-AlertReportExample.ps1|Yes|Write|
|Billing|/billing/usage/client|GET|Get-AuvikBillingUsageClient||Yes||
|Billing|/billing/usage/device/{id}|GET|Get-AuvikBillingUsageDevice||Yes||
|Statistics|/stat/device/{statId}|GET|Get-AuvikDeviceStatistics|Get-DeviceStatisticsExample.ps1|Yes||
|Statistics|/stat/deviceAvailability/{statId}|GET|Get-AuvikDeviceAvailabilityStatistics||Yes||
|Statistics|/stat/service/{statId}|GET|Get-AuvikServiceStatistics||Yes||
|Statistics|/stat/interface/{statId}|GET|Get-AuvikInterfaceStatistics||Yes||
|Statistics|/stat/component/{componentType}/{statId}|GET|Get-AuvikComponentStatistics||Yes||
|Statistics|/stat/oid/{statId}|GET|Get-AuvikOIDStatistics||Yes||
|Pollers|/settings/snmppoller|GET|Get-AuvikSNMPPollerSetting||Yes|Parameter set List|
|Pollers|/settings/snmppoller/{snmpPollerSettingId}|GET|Get-AuvikSNMPPollerSetting||Yes|Parameter set ById|
|Pollers|/settings/snmppoller/{snmpPollerSettingId}/devices|GET|Get-AuvikSNMPPollerDevice||Yes||
|Pollers|/stat/snmppoller/string|GET|Get-AuvikSNMPPollerHistoryString||Yes||
|Pollers|/stat/snmppoller/int|GET|Get-AuvikSNMPPollerHistoryInt||Yes||
|SaaSManagement|/asm/app/info|GET|Get-AuvikASMApplication||Yes||
|SaaSManagement|/asm/client/info|GET|Get-AuvikASMClient||Yes||
|SaaSManagement|/asm/securityLog/info|GET|Get-AuvikASMSecurityLog||Yes||
|SaaSManagement|/asm/tag/info|GET|Get-AuvikASMTag||Yes||
|SaaSManagement|/asm/user/info|GET|Get-AuvikASMUser||Yes||
|SaaSManagement|/asm/license/info|GET|Get-AuvikASMLicense||Yes||
