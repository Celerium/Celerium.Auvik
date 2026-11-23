---
document type: cmdlet
external help file: Celerium.Auvik-Help.xml
grand_parent: Pollers
HelpUri: https://celerium.github.io/Celerium.Auvik/site/Pollers/Get-AuvikSNMPPollerSetting.html
Locale: en-US
Module Name: Celerium.Auvik
parent: GET
PlatyPS schema version: 2024-05-01
title: Get-AuvikSNMPPollerSetting
---

# Get-AuvikSNMPPollerSetting

## SYNOPSIS

Read Multiple SNMP Poller Settings / Read Single SNMP Poller Setting

## SYNTAX

### List (Default)

```
Get-AuvikSNMPPollerSetting -Tenants <string[]> [-FilterDeviceId <string>] [-FilterUseAs <string>]
 [-FilterType <string>] [-FilterDeviceType <string>] [-FilterMakeModel <string>]
 [-FilterVendorName <string>] [-FilterOid <string>] [-FilterName <string>] [-PageFirst <long>]
 [-PageAfter <string>] [-PageLast <long>] [-PageBefore <string>] [-AllResults]
```

### ById

```
Get-AuvikSNMPPollerSetting [-SnmpPollerSettingId] <string>
```

## ALIASES

This cmdlet has the following aliases,
  - None

## DESCRIPTION

Parameter set [ List ] - The Get-AuvikSNMPPollerSetting cmdlet invokes the GET method of the /settings/snmppoller endpoint (Read Multiple SNMP Poller Settings)

Use the Read Multiple SNMP Poller Settings API to pull the list of SNMP Poller Settings configured in Auvik.

Parameter set [ ById ] - The Get-AuvikSNMPPollerSetting cmdlet invokes the GET method of the /settings/snmppoller/{snmpPollerSettingId} endpoint (Read Single SNMP Poller Setting)

Use the Read Single SNMP Poller Setting API to pull details of a specific SNMP Poller Setting configured in Auvik.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-AuvikSNMPPollerSetting -Tenants '1234567890'
```

Returns the result of the /settings/snmppoller endpoint

### EXAMPLE 2

```powershell
Get-AuvikSNMPPollerSetting -Tenants '1234567890' -PageFirst 10
```

Returns the result of the /settings/snmppoller endpoint limited to the defined number of items

### EXAMPLE 3

```powershell
Get-AuvikSNMPPollerSetting -Tenants '1234567890' -AllResults
```

Returns every item from the /settings/snmppoller endpoint by following the pagination links

### EXAMPLE 4

```powershell
Get-AuvikSNMPPollerSetting -SnmpPollerSettingId '1234567890'
```

Returns the result of the /settings/snmppoller/{snmpPollerSettingId} endpoint

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

### -FilterDeviceType

Filter by device type.

Allowed values:
'unknown', 'switch', 'l3Switch', 'router', 'accessPoint', 'firewall', 'workstation', 'server', 'storage', 'printer', 'copier', 'hypervisor', 'multimedia', 'phone', 'tablet', 'handheld', 'virtualAppliance', 'bridge', 'controller', 'hub', 'modem', 'ups', 'module', 'loadBalancer', 'camera', 'telecommunications', 'packetProcessor', 'chassis', 'airConditioner', 'virtualMachine', 'pdu', 'ipPhone', 'backhaul', 'internetOfThings', 'voipSwitch', 'stack', 'backupDevice', 'timeClock', 'lightingDevice', 'audioVisual', 'securityAppliance', 'utm', 'alarm', 'buildingManagement', 'ipmi', 'thinAccessPoint', 'thinClient', 'subnet'

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

### -FilterMakeModel

Filter by the device's make and model.

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

### -FilterName

Filter by the name of the SNMP poller setting

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

### -FilterOid

Filter by OID

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

### -FilterType

Filter by type

Allowed values:
'string', 'numeric'

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

### -FilterUseAs

Filter by oid type

Allowed values:
'serialNo', 'poller'

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

### -FilterVendorName

Filter by the device's vendor/manufacturer.

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

### -SnmpPollerSettingId

ID of the SNMP Poller Setting to retrieve

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases:
- Id
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

### System.String

{{ Fill in the Description }}

## OUTPUTS

### System.Management.Automation.PSCustomObject

{{ Fill in the Description }}

## NOTES

Endpoint : GET /settings/snmppoller
Endpoint : GET /settings/snmppoller/{snmpPollerSettingId}
The Auvik API user needs the role permissions that are required by the endpoint


## RELATED LINKS

- [](https://celerium.github.io/Celerium.Auvik/site/Pollers/Get-AuvikSNMPPollerSetting.html)
