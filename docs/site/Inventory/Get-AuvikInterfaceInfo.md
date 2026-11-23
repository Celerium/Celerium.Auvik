---
document type: cmdlet
external help file: Celerium.Auvik-Help.xml
grand_parent: Inventory
HelpUri: https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikInterfaceInfo.html
Locale: en-US
Module Name: Celerium.Auvik
parent: GET
PlatyPS schema version: 2024-05-01
title: Get-AuvikInterfaceInfo
---

# Get-AuvikInterfaceInfo

## SYNOPSIS

Read Multiple Interfaces Info / Read a Single Interfaces Info

## SYNTAX

### List (Default)

```
Get-AuvikInterfaceInfo [-FilterInterfaceType <string>] [-FilterParentDevice <string>]
 [-FilterAdminStatus <bool>] [-FilterOperationalStatus <string>] [-FilterModifiedAfter <datetime>]
 [-Tenants <string[]>] [-PageFirst <long>] [-PageAfter <string>] [-PageLast <long>]
 [-PageBefore <string>] [-AllResults]
```

### ById

```
Get-AuvikInterfaceInfo [-Id] <string>
```

## ALIASES

This cmdlet has the following aliases,
  - Get-AuvikInterface

## DESCRIPTION

Parameter set [ List ] - The Get-AuvikInterfaceInfo cmdlet invokes the GET method of the /inventory/interface/info endpoint (Read Multiple Interfaces Info)

Use the Read Multiple Interfaces Info API to pull the collected information about the various device interfaces Auvik has discovered.
You'll need the client IDs for the clients you want to run the multiple read against.

Parameter set [ ById ] - The Get-AuvikInterfaceInfo cmdlet invokes the GET method of the /inventory/interface/info/{id} endpoint (Read a Single Interfaces Info)

Use the Read Single Interface Info API to pull the collected information about a specific device interface Auvik has discovered.
You'll need the interface ID for the specific interface.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-AuvikInterfaceInfo
```

Returns the result of the /inventory/interface/info endpoint

### EXAMPLE 2

```powershell
Get-AuvikInterfaceInfo -Tenants '1234567890' -PageFirst 10
```

Returns the result of the /inventory/interface/info endpoint limited to the defined tenant

### EXAMPLE 3

```powershell
Get-AuvikInterfaceInfo -AllResults
```

Returns every item from the /inventory/interface/info endpoint by following the pagination links

### EXAMPLE 4

```powershell
Get-AuvikInterfaceInfo -Id '1234567890'
```

Returns the result of the /inventory/interface/info/{id} endpoint

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

### -FilterAdminStatus

Filter by the interface's admin status.

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

### -FilterInterfaceType

Filter by interface type.

Allowed values:
'ethernet', 'wifi', 'bluetooth', 'cdma', 'coax', 'cpu', 'distributedVirtualSwitch', 'firewire', 'gsm', 'ieee8023AdLag', 'inferredWired', 'inferredWireless', 'interface', 'linkAggregation', 'loopback', 'modem', 'wimax', 'optical', 'other', 'parallel', 'ppp', 'radiomac', 'rs232', 'tunnel', 'unknown', 'usb', 'virtualBridge', 'virtualNic', 'virtualSwitch', 'vlan'

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

### -FilterModifiedAfter

Filter by date and time, only returning entities modified after provided value.

Accepts a date & time which is sent to the API in UTC

```yaml
Type: System.DateTime
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

### -FilterOperationalStatus

Filter by the interface's operational status.

Allowed values:
'online', 'offline', 'unreachable', 'testing', 'unknown', 'dormant', 'notPresent', 'lowerLayerDown'

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

### -FilterParentDevice

Filter by the entity's parent device ID.

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

ID of interface

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

Endpoint : GET /inventory/interface/info
Endpoint : GET /inventory/interface/info/{id}
The Auvik API user needs the role permissions that are required by the endpoint


## RELATED LINKS

- [](https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikInterfaceInfo.html)
