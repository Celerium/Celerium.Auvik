---
document type: cmdlet
external help file: Celerium.Auvik-Help.xml
grand_parent: Inventory
HelpUri: https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikDeviceWarranty.html
Locale: en-US
Module Name: Celerium.Auvik
parent: GET
PlatyPS schema version: 2024-05-01
title: Get-AuvikDeviceWarranty
---

# Get-AuvikDeviceWarranty

## SYNOPSIS

Read Multiple Devices' Warranty Info / Read a Single Device's Warranty Info

## SYNTAX

### List (Default)

```
Get-AuvikDeviceWarranty [-FilterCoveredUnderWarranty <bool>] [-FilterCoveredUnderService <bool>]
 [-Tenants <string[]>] [-PageFirst <long>] [-PageAfter <string>] [-PageLast <long>]
 [-PageBefore <string>] [-AllResults]
```

### ById

```
Get-AuvikDeviceWarranty [-Id] <string>
```

## ALIASES

This cmdlet has the following aliases,
  - None

## DESCRIPTION

Parameter set [ List ] - The Get-AuvikDeviceWarranty cmdlet invokes the GET method of the /inventory/device/warranty endpoint (Read Multiple Devices' Warranty Info)

Use the Read Multiple Devices' Warranty API to pull the collected warranty information about the various devices Auvik has discovered.
You'll need the client IDs for the clients you want to run the multiple read against.

Parameter set [ ById ] - The Get-AuvikDeviceWarranty cmdlet invokes the GET method of the /inventory/device/warranty/{id} endpoint (Read a Single Device's Warranty Info)

Use the Read Single Device's Warranty Info API to pull the collected information about a specific device Auvik has discovered.
You'll need the device ID for the specific device.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-AuvikDeviceWarranty
```

Returns the result of the /inventory/device/warranty endpoint

### EXAMPLE 2

```powershell
Get-AuvikDeviceWarranty -Tenants '1234567890' -PageFirst 10
```

Returns the result of the /inventory/device/warranty endpoint limited to the defined tenant

### EXAMPLE 3

```powershell
Get-AuvikDeviceWarranty -AllResults
```

Returns every item from the /inventory/device/warranty endpoint by following the pagination links

### EXAMPLE 4

```powershell
Get-AuvikDeviceWarranty -Id '1234567890'
```

Returns the result of the /inventory/device/warranty/{id} endpoint

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

### -FilterCoveredUnderService

Filter by service coverage status.

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

### -FilterCoveredUnderWarranty

Filter by warranty coverage status.

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

Endpoint : GET /inventory/device/warranty
Endpoint : GET /inventory/device/warranty/{id}
The Auvik API user needs the role permissions that are required by the endpoint


## RELATED LINKS

- [](https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikDeviceWarranty.html)
