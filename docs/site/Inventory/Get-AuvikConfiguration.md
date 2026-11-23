---
document type: cmdlet
external help file: Celerium.Auvik-Help.xml
grand_parent: Inventory
HelpUri: https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikConfiguration.html
Locale: en-US
Module Name: Celerium.Auvik
parent: GET
PlatyPS schema version: 2024-05-01
title: Get-AuvikConfiguration
---

# Get-AuvikConfiguration

## SYNOPSIS

Read Multiple Device Configurations / Read a Single Device Configuration

## SYNTAX

### List (Default)

```
Get-AuvikConfiguration [-FilterDeviceId <string>] [-FilterBackupTimeAfter <datetime>]
 [-FilterBackupTimeBefore <datetime>] [-FilterIsRunning <bool>] [-Tenants <string[]>]
 [-PageFirst <long>] [-PageAfter <string>] [-PageLast <long>] [-PageBefore <string>] [-AllResults]
```

### ById

```
Get-AuvikConfiguration [-Id] <string>
```

## ALIASES

This cmdlet has the following aliases,
  - None

## DESCRIPTION

Parameter set [ List ] - The Get-AuvikConfiguration cmdlet invokes the GET method of the /inventory/configuration endpoint (Read Multiple Device Configurations)

Use the Read Multiple Device Configuration API to pull all device configurations.
You'll need the client IDs for the clients you want to run the multiple read against.

Parameter set [ ById ] - The Get-AuvikConfiguration cmdlet invokes the GET method of the /inventory/configuration/{id} endpoint (Read a Single Device Configuration)

Use the Read Single Device Configuration API to pull a single device configuration.
You'll need the client IDs for the clients you want to run the multiple read against.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-AuvikConfiguration
```

Returns the result of the /inventory/configuration endpoint

### EXAMPLE 2

```powershell
Get-AuvikConfiguration -Tenants '1234567890' -PageFirst 10
```

Returns the result of the /inventory/configuration endpoint limited to the defined tenant

### EXAMPLE 3

```powershell
Get-AuvikConfiguration -AllResults
```

Returns every item from the /inventory/configuration endpoint by following the pagination links

### EXAMPLE 4

```powershell
Get-AuvikConfiguration -Id '1234567890'
```

Returns the result of the /inventory/configuration/{id} endpoint

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

### -FilterBackupTimeAfter

Filter by date and time, filtering out configurations backed up before value.

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

### -FilterBackupTimeBefore

Filter by date and time, filtering out configurations backed up after value.

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

### -FilterDeviceId

Filter by device ID

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

### -FilterIsRunning

Filter for configurations that are currently running, or filter for all configurations which are not currently running.

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

ID of configuration

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

Endpoint : GET /inventory/configuration
Endpoint : GET /inventory/configuration/{id}
The Auvik API user needs the role permissions that are required by the endpoint


## RELATED LINKS

- [](https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikConfiguration.html)
