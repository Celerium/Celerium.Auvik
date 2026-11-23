<h1 align="center">
  <br>
  <a href="http://Celerium.org"><img src="https://raw.githubusercontent.com/Celerium/Celerium.Auvik/main/.github/images/Celerium_PoSHGallery_Celerium.Auvik.png" alt="_CeleriumDemo" width="200"></a>
  <br>
  Celerium.Auvik_Examples
  <br>
</h1>

---

## Examples

- :book: Project documentation can be found on [Github Pages](https://celerium.github.io/Celerium.Auvik/)
- :book: Auvik's REST API documentation on their management portal [here](https://auvikapi.us1.my.auvik.com/docs).

:warning: Please note that the following examples are provided **"AS IS"** and only serve as a proof of concept to show possible uses of the [Celerium.Auvik](https://github.com/Celerium/Celerium.Auvik) PowerShell wrapper.

The examples work the same in Windows PowerShell 5.1 and PowerShell 7+ on Windows, Linux, and macOS.

| Example | What it shows | Functions used |
|---------|---------------|----------------|
| [Connect-AuvikExample.ps1](Connect-AuvikExample.ps1) | Configure the module with credentials (parameters, environment variables, or prompts), pick the data center or a custom base URI, verify the connection, & optionally save the settings | `Add-AuvikBaseURI`, `Add-AuvikAPIKey`, `Get-AuvikAuthenticationVerify`, `Export-AuvikModuleSetting` |
| [Get-DeviceInventoryExample.ps1](Get-DeviceInventoryExample.ps1) | Find a tenant by its display name & export all of its devices (with optional filters) to a CSV file | `Get-AuvikTenant`, `Get-AuvikTenantDetail`, `Get-AuvikDeviceInfo -AllResults` |
| [Get-AlertReportExample.ps1](Get-AlertReportExample.ps1) | Summarize the recent alerts of a tenant by severity & status & optionally export them (read-only) | `Get-AuvikAlertHistory -AllResults` |
| [Get-DeviceStatisticsExample.ps1](Get-DeviceStatisticsExample.ps1) | Summarize a device statistic (CPU utilization per hour for the last 24 hours by default) per device & optionally export every data point | `Get-AuvikDeviceStatistics -AllResults` |
| [Get-DeviceLifecycleExample.ps1](Get-DeviceLifecycleExample.ps1) | Combine the lifecycle & warranty information of the devices of a tenant into one report that flags expired & soon to expire warranties | `Get-AuvikDeviceLifecycle -AllResults`, `Get-AuvikDeviceWarranty -AllResults` |

### Before you run an example

1. Install the module with `Install-Module -Name Celerium.Auvik`. The examples import the module by name. To use a local copy of the repository, import it first (the examples then use the loaded module):

   ```powershell
   Import-Module -Name ./Celerium.Auvik/Celerium.Auvik.psd1 -Force
   ```

2. Configure the credentials. Either run `Connect-AuvikExample.ps1`, set the `AUVIK_USERNAME`, `AUVIK_API_KEY`, & (optionally) `AUVIK_BASE_URI` environment variables before the module is imported, or load previously saved settings with `Import-AuvikModuleSetting`.

   ```powershell
   ./examples/Connect-AuvikExample.ps1 -Username 'user@example.com' -DataCenter us1
   ```

3. Run an example for **one tenant**. All examples use the `-Tenants` parameter so a single tenant is queried, which is the recommended way to stay within Auvik's rate limit of 2500 requests per 5 minutes.

   ```powershell
   ./examples/Get-DeviceInventoryExample.ps1 -TenantName 'Contoso' -OutputPath ./Contoso-Devices.csv
   ./examples/Get-AlertReportExample.ps1 -TenantName 'Contoso' -Days 30
   ./examples/Get-DeviceStatisticsExample.ps1 -TenantName 'Contoso' -StatId memoryUtilization -Hours 12
   ./examples/Get-DeviceLifecycleExample.ps1 -TenantName 'Contoso' -OutputPath ./Contoso-Lifecycle.csv
   ```

### Common parameters

- `-TenantName` - The display name of the tenant (client) as it is shown in Auvik. It has to match exactly one tenant.
- `-TenantId` - The tenant ID. Skips the tenant lookup and takes priority over `-TenantName`.
- `-TenantDomainPrefix` - The domain prefix of the main Auvik account, which Auvik requires to read the tenant details. By default the first multi-client tenant returned by `Get-AuvikTenant` is used.
- `-OutputPath` - The CSV file to write (the inventory example defaults to `AuvikDeviceInventory.csv` in the current directory, the others only export when the parameter is used).

Use `Get-Help ./examples/<script>.ps1 -Full` to see every parameter of an example.

### Legacy examples

:warning: [Legacy/Get-AlertReportExample.ps1](Legacy/Get-AlertReportExample.ps1) is marked **LEGACY - WRITES DATA**. With `-Dismiss` it dismisses alerts in Auvik (`Send-AuvikAlertDismiss`). It is kept for reference only; review it and run it with `-WhatIf` first.

:information_source: Examples never write credentials in plain text. Never put an API key in a script or commit one to a repository.

---

## Buy me a coffee

Whether you use this project, have learned something from it, or just like it, please consider supporting it by buying me a coffee, so I can dedicate more time on open-source projects like this :)

<a href="https://www.buymeacoffee.com/Celerium" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/guidelines/download-assets-sm-2.svg" alt="Buy Me A Coffee" style="width:150px;height:50px;"></a>

---
