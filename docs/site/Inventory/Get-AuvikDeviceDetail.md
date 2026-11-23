---
document type: cmdlet
external help file: Celerium.Auvik-Help.xml
grand_parent: Inventory
HelpUri: https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikDeviceDetail.html
Locale: en-US
Module Name: Celerium.Auvik
parent: GET
PlatyPS schema version: 2024-05-01
title: Get-AuvikDeviceDetail
---

# Get-AuvikDeviceDetail

## SYNOPSIS

Read Multiple Devices' Details / Read a Single Device's Details

## SYNTAX

### List (Default)

```
Get-AuvikDeviceDetail [-FilterManageStatus <bool>] [-FilterDiscoverySNMP <string>]
 [-FilterDiscoveryWMI <string>] [-FilterDiscoveryLogin <string>] [-FilterDiscoveryVMware <string>]
 [-FilterTrafficInsightsStatus <string>] [-Tenants <string[]>] [-PageFirst <long>]
 [-PageAfter <string>] [-PageLast <long>] [-PageBefore <string>] [-AllResults]
```

### ById

```
Get-AuvikDeviceDetail [-Id] <string>
```

## ALIASES

This cmdlet has the following aliases,
  - None

## DESCRIPTION

Parameter set [ List ] - The Get-AuvikDeviceDetail cmdlet invokes the GET method of the /inventory/device/detail endpoint (Read Multiple Devices' Details)

Use the Read Multiple Devices' Details API to pull extra collected information about the various devices Auvik has discovered not already included in the Device Info API.
You'll need the client IDs for the clients you want to run the multiple read against.

Parameter set [ ById ] - The Get-AuvikDeviceDetail cmdlet invokes the GET method of the /inventory/device/detail/{id} endpoint (Read a Single Device's Details)

Use the Read Single Device's Details API to pull extra collected information about a specific device Auvik has discovered not already included in the Device Info API.
You'll need the device ID for the specific device.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-AuvikDeviceDetail
```

Returns the result of the /inventory/device/detail endpoint

### EXAMPLE 2

```powershell
Get-AuvikDeviceDetail -Tenants '1234567890' -PageFirst 10
```

Returns the result of the /inventory/device/detail endpoint limited to the defined tenant

### EXAMPLE 3

```powershell
Get-AuvikDeviceDetail -AllResults
```

Returns every item from the /inventory/device/detail endpoint by following the pagination links

### EXAMPLE 4

```powershell
Get-AuvikDeviceDetail -Id '1234567890'
```

Returns the result of the /inventory/device/detail/{id} endpoint

## PARAMETERS

### -AllResults

Returns all items from the endpoint by following the pagination links

When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters

Highly recommended to only use with filters to reduce API errors & timeouts

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: List
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -FilterDiscoveryLogin

Filter by the device's Login discovery status.

Allowed values:
'disabled', 'determining', 'notSupported', 'notAuthorized', 'authorizing', 'authorized', 'privileged'

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: List
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -FilterDiscoverySNMP

Filter by the device's SNMP discovery status.

Allowed values:
'disabled', 'determining', 'notSupported', 'notAuthorized', 'authorizing', 'authorized', 'privileged'

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: List
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -FilterDiscoveryVMware

Filter by the device's VMware discovery status.

Allowed values:
'disabled', 'determining', 'notSupported', 'notAuthorized', 'authorizing', 'authorized', 'privileged'

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: List
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -FilterDiscoveryWMI

Filter by the device's WMI discovery status.

Allowed values:
'disabled', 'determining', 'notSupported', 'notAuthorized', 'authorizing', 'authorized', 'privileged'

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: List
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -FilterManageStatus

Filter by managed status

```yaml
Type: System.Boolean
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: List
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -FilterTrafficInsightsStatus

Filter by the device's TrafficInsights status.

Allowed values:
'notDetected', 'detected', 'notApproved', 'approved', 'linking', 'linkingFailed', 'forwarding'

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: List
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Id

ID of device

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ById
  Position: 0
  IsRequired: true
  ValueFromPipeline: true
  ValueFromPipelineByPropertyName: true
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -PageAfter

Cursor after which elements will be returned as a page.
The page size is provided by page[first].

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: List
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -PageBefore

Cursor before which elements will be returned as a page.
The page size is provided by page[last].

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: List
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -PageFirst

For paginated responses, the first N elements will be returned.
Used in combination with page[after].

Default value: 100

```yaml
Type: System.Int64
DefaultValue: 0
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: List
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -PageLast

For paginated responses, the last N services will be returned.
Used in combination with page[before].

Default value: 100

```yaml
Type: System.Int64
DefaultValue: 0
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: List
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Tenants

Comma delimited list of tenant IDs to request info from.

Accepts multiple values which are sent to the API as a comma delimited list

```yaml
Type: System.String[]
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: List
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

{{ Fill in the Description }}

## OUTPUTS

### System.Management.Automation.PSCustomObject

{{ Fill in the Description }}

## NOTES

Endpoint : GET /inventory/device/detail
Endpoint : GET /inventory/device/detail/{id}
The Auvik API user needs the role permissions that are required by the endpoint


## RELATED LINKS

- [](https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikDeviceDetail.html)
