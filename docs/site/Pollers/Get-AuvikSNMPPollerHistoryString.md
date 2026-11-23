---
document type: cmdlet
external help file: Celerium.Auvik-Help.xml
grand_parent: Pollers
HelpUri: https://celerium.github.io/Celerium.Auvik/site/Pollers/Get-AuvikSNMPPollerHistoryString.html
Locale: en-US
Module Name: Celerium.Auvik
parent: GET
PlatyPS schema version: 2024-05-01
title: Get-AuvikSNMPPollerHistoryString
---

# Get-AuvikSNMPPollerHistoryString

## SYNOPSIS

Read String SNMP Poller Setting's History

## SYNTAX

### __AllParameterSets

```
Get-AuvikSNMPPollerHistoryString [-FilterFromTime] <datetime> [-Tenants] <string[]>
 [[-FilterThruTime] <datetime>] [[-FilterCompact] <bool>] [[-FilterDeviceId] <string>]
 [[-FilterSnmpPollerSettingId] <string[]>] [[-PageFirst] <long>] [[-PageAfter] <string>]
 [[-PageLast] <long>] [[-PageBefore] <string>] [-AllResults]
```

## ALIASES

This cmdlet has the following aliases,
  - Get-AuvikSNMPPollerHistory

## DESCRIPTION

The Get-AuvikSNMPPollerHistoryString cmdlet invokes the GET method of the /stat/snmppoller/string endpoint (Read String SNMP Poller Setting's History)

Use the Read SNMP Poller Setting's History API to fetch the list of historical vaules for a SNMP Poller Setting.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-AuvikSNMPPollerHistoryString -FilterFromTime '2025-01-01T00:00:00Z' -Tenants '1234567890'
```

Returns the result of the /stat/snmppoller/string endpoint

### EXAMPLE 2

```powershell
Get-AuvikSNMPPollerHistoryString -FilterFromTime '2025-01-01T00:00:00Z' -Tenants '1234567890' -PageFirst 10
```

Returns the result of the /stat/snmppoller/string endpoint limited to the defined number of items

### EXAMPLE 3

```powershell
Get-AuvikSNMPPollerHistoryString -FilterFromTime '2025-01-01T00:00:00Z' -Tenants '1234567890' -AllResults
```

Returns every item from the /stat/snmppoller/string endpoint by following the pagination links

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
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -FilterCompact

Whether to show compact view of the results or not.
Compact view only shows changes in value.
If compact view is false, dateTime range can be a maximum of 24h

```yaml
Type: System.Boolean
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 3
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
- Name: (All)
  Position: 4
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -FilterFromTime

Timestamp from which you want to query

Accepts a date & time which is sent to the API in UTC

```yaml
Type: System.DateTime
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -FilterSnmpPollerSettingId

Comma delimited list of SNMP poller setting IDs to request info from.
Note this is internal snmpPollerSettingId.
The user can get the list of IDs for a specific poller using the GET /settings/snmppoller endpoint.

Accepts multiple values which are sent to the API as a comma delimited list

```yaml
Type: System.String[]
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 5
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -FilterThruTime

Timestamp to which you want to query (defaults to current time)

Accepts a date & time which is sent to the API in UTC

```yaml
Type: System.DateTime
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 2
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
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
- Name: (All)
  Position: 7
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
- Name: (All)
  Position: 9
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
- Name: (All)
  Position: 6
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
- Name: (All)
  Position: 8
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
- Name: (All)
  Position: 1
  IsRequired: true
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

## OUTPUTS

### System.Management.Automation.PSCustomObject

{{ Fill in the Description }}

## NOTES

Endpoint : GET /stat/snmppoller/string
The Auvik API user needs the role permissions that are required by the endpoint


## RELATED LINKS

- [](https://celerium.github.io/Celerium.Auvik/site/Pollers/Get-AuvikSNMPPollerHistoryString.html)
