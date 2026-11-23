---
document type: module
Help Version: 1.0.0.0
HelpInfoUri: 
Locale: en-US
Module Guid: c12d0f6b-e5fa-476f-b3cc-88bac180a278
Module Name: Celerium.Auvik
PlatyPS schema version: 2024-05-01
title: Celerium.Auvik Module
parent: Home
---

# Celerium.Auvik Module

## Description

This module provides a PowerShell wrapper for the Auvik v1 REST API. Auvik APIs are great for pulling data for reporting purposes or for importing into an integration such as BrightGauge, IT Glue, or Passportal.

## Celerium.Auvik

### [Add-AuvikAPIKey](site/Internal/Add-AuvikAPIKey.md)

Sets the API username and API key used to authenticate API calls

### [Add-AuvikBaseURI](site/Internal/Add-AuvikBaseURI.md)

Sets the base URI for the Auvik API connection

### [ConvertTo-AuvikQueryString](site/Internal/ConvertTo-AuvikQueryString.md)

Converts uri filter parameters

### [Export-AuvikModuleSetting](site/Internal/Export-AuvikModuleSetting.md)

Exports the Auvik BaseURI, API, & JSON configuration information to file

### [Get-AuvikAlertHistory](site/Alert/Get-AuvikAlertHistory.md)

Read Multiple Alerts' Info / Read a Single Alert's Info

### [Get-AuvikAPIKey](site/Internal/Get-AuvikAPIKey.md)

Gets the Auvik API username & API key global variables

### [Get-AuvikASMApplication](site/SaaSManagement/Get-AuvikASMApplication.md)

Read Multiple ASM Applications' Info

### [Get-AuvikASMClient](site/SaaSManagement/Get-AuvikASMClient.md)

Read Multiple ASM Clients' Info

### [Get-AuvikASMLicense](site/SaaSManagement/Get-AuvikASMLicense.md)

Read Multiple ASM Licenses' Info

### [Get-AuvikASMSecurityLog](site/SaaSManagement/Get-AuvikASMSecurityLog.md)

Read Multiple ASM Security Logs' Info

### [Get-AuvikASMTag](site/SaaSManagement/Get-AuvikASMTag.md)

Read Multiple ASM Tags' Info

### [Get-AuvikASMUser](site/SaaSManagement/Get-AuvikASMUser.md)

Read Multiple ASM Users' Info

### [Get-AuvikAuthenticationVerify](site/Other/Get-AuvikAuthenticationVerify.md)

Verify Credentials

### [Get-AuvikBaseURI](site/Internal/Get-AuvikBaseURI.md)

Shows the Auvik base URI global variable

### [Get-AuvikBillingUsageClient](site/Billing/Get-AuvikBillingUsageClient.md)

Read Client Usage

### [Get-AuvikBillingUsageDevice](site/Billing/Get-AuvikBillingUsageDevice.md)

Read Device Usage

### [Get-AuvikComponentInfo](site/Inventory/Get-AuvikComponentInfo.md)

Read Multiple Components' Info / Read a Single Component's Info

### [Get-AuvikComponentStatistics](site/Statistics/Get-AuvikComponentStatistics.md)

Read Component Statistics

### [Get-AuvikConfiguration](site/Inventory/Get-AuvikConfiguration.md)

Read Multiple Device Configurations / Read a Single Device Configuration

### [Get-AuvikDeviceAvailabilityStatistics](site/Statistics/Get-AuvikDeviceAvailabilityStatistics.md)

Read Device Availability Statistics

### [Get-AuvikDeviceDetail](site/Inventory/Get-AuvikDeviceDetail.md)

Read Multiple Devices' Details / Read a Single Device's Details

### [Get-AuvikDeviceDetailExtended](site/Inventory/Get-AuvikDeviceDetailExtended.md)

Read Multiple Devices' Extended Details / Read a Single Device's Extended Details

### [Get-AuvikDeviceInfo](site/Inventory/Get-AuvikDeviceInfo.md)

Read Multiple Devices' Info / Read a Single Device's Info

### [Get-AuvikDeviceLifecycle](site/Inventory/Get-AuvikDeviceLifecycle.md)

Read Multiple Devices' Lifecycle Info / Read a Single Device's Lifecycle Info

### [Get-AuvikDeviceStatistics](site/Statistics/Get-AuvikDeviceStatistics.md)

Read Device Statistics

### [Get-AuvikDeviceWarranty](site/Inventory/Get-AuvikDeviceWarranty.md)

Read Multiple Devices' Warranty Info / Read a Single Device's Warranty Info

### [Get-AuvikEntityAudit](site/Inventory/Get-AuvikEntityAudit.md)

Read Multiple Entity Audits / Read a Single Entity Audit

### [Get-AuvikEntityNote](site/Inventory/Get-AuvikEntityNote.md)

Read Multiple Entity Notes / Read a Single Entity Note

### [Get-AuvikInterfaceInfo](site/Inventory/Get-AuvikInterfaceInfo.md)

Read Multiple Interfaces Info / Read a Single Interfaces Info

### [Get-AuvikInterfaceStatistics](site/Statistics/Get-AuvikInterfaceStatistics.md)

Read Interface Statistics

### [Get-AuvikModuleSetting](site/Internal/Get-AuvikModuleSetting.md)

Gets the saved Auvik configuration settings

### [Get-AuvikNetworkDetail](site/Inventory/Get-AuvikNetworkDetail.md)

Read Multiple Networks' Details / Read a Single Network's Details

### [Get-AuvikNetworkInfo](site/Inventory/Get-AuvikNetworkInfo.md)

Read Multiple Networks' Info / Read a Single Network's Info

### [Get-AuvikOIDStatistics](site/Statistics/Get-AuvikOIDStatistics.md)

Read OID Statistics

### [Get-AuvikServiceStatistics](site/Statistics/Get-AuvikServiceStatistics.md)

Read Service Statistics

### [Get-AuvikSNMPPollerDevice](site/Pollers/Get-AuvikSNMPPollerDevice.md)

Read SNMP Poller Setting's Devices

### [Get-AuvikSNMPPollerHistoryInt](site/Pollers/Get-AuvikSNMPPollerHistoryInt.md)

Read Numeric SNMP Poller Setting's History

### [Get-AuvikSNMPPollerHistoryString](site/Pollers/Get-AuvikSNMPPollerHistoryString.md)

Read String SNMP Poller Setting's History

### [Get-AuvikSNMPPollerSetting](site/Pollers/Get-AuvikSNMPPollerSetting.md)

Read Multiple SNMP Poller Settings / Read Single SNMP Poller Setting

### [Get-AuvikTenant](site/ClientManagement/Get-AuvikTenant.md)

Read Multiple Tenants

### [Get-AuvikTenantDetail](site/ClientManagement/Get-AuvikTenantDetail.md)

Read Multiple Tenants Detail / Read Single Tenant Detail

### [Get-AuvikUriParameter](site/Internal/Get-AuvikUriParameter.md)

Translates the bound parameters of a function to API query parameters

### [Import-AuvikModuleSetting](site/Internal/Import-AuvikModuleSetting.md)

Imports the Auvik BaseURI, API, & JSON configuration information to the current session

### [Initialize-AuvikModuleSetting](site/Internal/Initialize-AuvikModuleSetting.md)

Loads the Auvik module settings when the module is imported

### [Invoke-AuvikRequest](site/Internal/Invoke-AuvikRequest.md)

Makes an API request

### [Remove-AuvikAPIKey](site/Internal/Remove-AuvikAPIKey.md)

Removes the Auvik API username & API key global variables

### [Remove-AuvikBaseURI](site/Internal/Remove-AuvikBaseURI.md)

Removes the Auvik base URI global variable

### [Remove-AuvikModuleSetting](site/Internal/Remove-AuvikModuleSetting.md)

Removes the stored Auvik configuration folder

### [Send-AuvikAlertDismiss](site/Alert/Send-AuvikAlertDismiss.md)

Dismiss an alert
