---
title: Tracking CSV
parent: Home
nav_order: 2
---

# Tracking CSV

When updating the documentation for this project, the tracking CSV plays a huge part in organizing of the markdown documents. Any new functions or endpoints should be added to the tracking CSV when publishing an updated module or documentation version.

{: .warning }
I recommend downloading the CSV from the link provided rather then viewing the table below.

[Tracking CSV](https://github.com/Celerium/Celerium.Auvik/blob/main/docs/Endpoints.csv)

---

## CSV markdown table

| Category         | EndpointUri                                        | Method                     | Function                              | Complete                  | Notes                 |
|------------------|----------------------------------------------------|----------------------------|---------------------------------------|---------------------------|-----------------------|
| alert            | /alert/dismiss/{id}                                | POST                       | Clear-AuvikAlert                      | YES                       |                       |
| alert            | /alert/history/info                                | GET                        | Get-AuvikAlert                        | YES                       |                       |
| alert            | /alert/history/info/{id}                           | GET                        | Get-AuvikAlert                        | YES                       |                       |
| billing          | /billing/usage/client                              | GET                        | Get-AuvikBilling                      | YES                       |                       |
| billing          | /billing/usage/device/{id}                         | GET                        | Get-AuvikBilling                      | YES                       |                       |
| clientManagement | /tenants                                           | GET                        | Get-AuvikTenant                       | YES                       |                       |
| clientManagement | /tenants/detail                                    | GET                        | Get-AuvikTenant                       | YES                       |                       |
| clientManagement | /tenants/detail/{id}                               | GET                        | Get-AuvikTenant                       | YES                       |                       |
| internal         | POST                                               | Add-AuvikAPIKey            | YES                                   |                           |                       |
| internal         | POST                                               | Add-AuvikBaseURI           | YES                                   |                           |                       |
| internal         | PUT                                                | ConvertTo-AuvikQueryString | YES                                   |                           |                       |
| internal         | GET                                                | Export-AuvikModuleSetting  | YES                                   |                           |                       |
| internal         | GET                                                | Get-AuvikAPIKey            | YES                                   |                           |                       |
| internal         | GET                                                | Get-AuvikBaseURI           | YES                                   |                           |                       |
| internal         | GET                                                | Get-AuvikMetaData          | YES                                   |                           |                       |
| internal         | GET                                                | Get-AuvikModuleSetting     | YES                                   |                           |                       |
| internal         | GET                                                | Import-AuvikModuleSetting  | YES                                   |                           |                       |
| internal         | GET                                                | Invoke-AuvikRequest        | YES                                   |                           |                       |
| internal         | DELETE                                             | Remove-AuvikAPIKey         | YES                                   |                           |                       |
| internal         | DELETE                                             | Remove-AuvikBaseURI        | YES                                   |                           |                       |
| internal         | DELETE                                             | Remove-AuvikModuleSetting  | YES                                   |                           |                       |
| internal         | POST                                               | Set-AuvikAPIKey            | YES                                   | Alias of Add-AuvikAPIKey  |                       |
| internal         | POST                                               | Set-AuvikBaseURI           | YES                                   | Alias of Add-AuvikBaseUri |                       |
| internal         | POST                                               | New-AuvikAESSecret         | YES                                   |                           |                       |
| internal         | GET                                                | Test-AuvikAPICredential    | YES                                   |                           |                       |
| inventory        | /inventory/component/info                          | GET                        | Get-AuvikComponent                    | YES                       |                       |
| inventory        | /inventory/component/info/{id}                     | GET                        | Get-AuvikComponent                    | YES                       |                       |
| inventory        | /inventory/configuration                           | GET                        | Get-AuvikConfiguration                | YES                       |                       |
| inventory        | /inventory/configuration/{id}                      | GET                        | Get-AuvikConfiguration                | YES                       |                       |
| inventory        | /inventory/device/detail                           | GET                        | Get-AuvikDevice                       | YES                       |                       |
| inventory        | /inventory/device/detail/{id}                      | GET                        | Get-AuvikDevice                       | YES                       |                       |
| inventory        | /inventory/device/detail/extended                  | GET                        | Get-AuvikDevice                       | YES                       |                       |
| inventory        | /inventory/device/detail/extended/{id}             | GET                        | Get-AuvikDevice                       | YES                       |                       |
| inventory        | /inventory/device/info                             | GET                        | Get-AuvikDevice                       | YES                       |                       |
| inventory        | /inventory/device/info/{id}                        | GET                        | Get-AuvikDevice                       | YES                       |                       |
| inventory        | /inventory/device/lifecycle                        | GET                        | Get-AuvikDeviceLifecycle              | YES                       |                       |
| inventory        | /inventory/device/lifecycle/{id}                   | GET                        | Get-AuvikDeviceLifecycle              | YES                       |                       |
| inventory        | /inventory/device/warranty                         | GET                        | Get-AuvikDeviceWarranty               | YES                       |                       |
| inventory        | /inventory/device/warranty/{id}                    | GET                        | Get-AuvikDeviceWarranty               | YES                       |                       |
| inventory        | /inventory/entity/audit                            | GET                        | Get-AuvikEntity                       | YES                       |                       |
| inventory        | /inventory/entity/audit/{id}                       | GET                        | Get-AuvikEntity                       | YES                       |                       |
| inventory        | /inventory/entity/note                             | GET                        | Get-AuvikEntity                       | YES                       |                       |
| inventory        | /inventory/entity/note/{id}                        | GET                        | Get-AuvikEntity                       | YES                       |                       |
| inventory        | /inventory/interface/info                          | GET                        | Get-AuvikInterface                    | YES                       |                       |
| inventory        | /inventory/interface/info/{id}                     | GET                        | Get-AuvikInterface                    | YES                       |                       |
| inventory        | /inventory/network/detail                          | GET                        | Get-AuvikNetwork                      | YES                       |                       |
| inventory        | /inventory/network/detail/{id}                     | GET                        | Get-AuvikNetwork                      | YES                       |                       |
| inventory        | /inventory/network/info                            | GET                        | Get-AuvikNetwork                      | YES                       |                       |
| inventory        | /inventory/network/info/{id}                       | GET                        | Get-AuvikNetwork                      | YES                       |                       |
| other            | /authentication/verify                             | GET                        | Get-AuvikCredential                   | YES                       |                       |
| pollers          | /settings/snmppoller/{snmpPollerSettingId}/devices | GET                        | Get-AuvikSNMPPollerDevice             | YES                       |                       |
| pollers          | /settings/snmppoller                               | GET                        | Get-AuvikSNMPPollerSetting            | YES                       |                       |
| pollers          | /settings/snmppoller/{snmpPollerSettingId}         | GET                        | Get-AuvikSNMPPollerSetting            | YES                       |                       |
| pollers          | /stat/snmppoller/int                               | GET                        | Get-AuvikSNMPPollerHistory            | YES                       |                       |
| pollers          | /stat/snmppoller/string                            | GET                        | Get-AuvikSNMPPollerHistory            | YES                       |                       |
| statistics       | /stat/component/{componentType}/{statId}           | GET                        | Get-AuvikComponentStatistics          | YES                       |                       |
| statistics       | /stat/deviceAvailability/{statId}                  | GET                        | Get-AuvikDeviceAvailabilityStatistics | YES                       |                       |
| statistics       | /stat/device/{statId}                              | GET                        | Get-AuvikDeviceStatistics             | YES                       |                       |
| statistics       | /stat/interface/{statId}                           | GET                        | Get-AuvikInterfaceStatistics          | YES                       |                       |
| statistics       | /stat/oid/{statId}                                 | GET                        | Get-AuvikOIDStatistics                | YES                       |                       |
| statistics       | /stat/service/{statId}                             | GET                        | Get-AuvikServiceStatistics            | YES                       |                       |
| asm              | /asm/app/info                                      | GET                        | Get-AuvikASMApplication               | YES                       | Cannot fully validate |
| asm              | /asm/client/info                                   | GET                        | Get-AuvikASMClient                    | YES                       | Cannot fully validate |
| asm              | /asm/securityLog/info                              | GET                        | Get-AuvikASMSecurityLog               | YES                       | Cannot fully validate |
| asm              | /asm/tag/info                                      | GET                        | Get-AuvikASMTag                       | YES                       | Cannot fully validate |
| asm              | /asm/user/info                                     | GET                        | Get-AuvikASMUser                      | YES                       | Cannot fully validate |
