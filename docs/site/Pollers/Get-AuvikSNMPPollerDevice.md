---
document type: cmdlet
external help file: Celerium.Auvik-Help.xml
grand_parent: Pollers
HelpUri: https://celerium.github.io/Celerium.Auvik/site/Pollers/Get-AuvikSNMPPollerDevice.html
Locale: en-US
Module Name: Celerium.Auvik
parent: GET
PlatyPS schema version: 2024-05-01
title: Get-AuvikSNMPPollerDevice
---

# Get-AuvikSNMPPollerDevice

## SYNOPSIS

Read SNMP Poller Setting's Devices

## SYNTAX

### __AllParameterSets

```
Get-AuvikSNMPPollerDevice [-SnmpPollerSettingId] <string> -Tenants <string[]>
 [-FilterOnlineStatus <string>] [-FilterModifiedAfter <datetime>] [-FilterNotSeenSince <datetime>]
 [-FilterDeviceType <string>] [-FilterMakeModel <string>] [-FilterVendorName <string>]
 [-PageFirst <long>] [-PageAfter <string>] [-PageLast <long>] [-PageBefore <string>] [-AllResults]
```

## ALIASES

This cmdlet has the following aliases,
  - None

## DESCRIPTION

The Get-AuvikSNMPPollerDevice cmdlet invokes the GET method of the /settings/snmppoller/{snmpPollerSettingId}/devices endpoint (Read SNMP Poller Setting's Devices)

Use Read SNMP Poller Setting's Devices API to pull the list of devices that apply to a specific SNMP Poller Setting Id.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-AuvikSNMPPollerDevice -SnmpPollerSettingId '1234567890' -Tenants '1234567890'
```

Returns the result of the /settings/snmppoller/{snmpPollerSettingId}/devices endpoint

### EXAMPLE 2

```powershell
Get-AuvikSNMPPollerDevice -SnmpPollerSettingId '1234567890' -Tenants '1234567890' -PageFirst 10
```

Returns the result of the /settings/snmppoller/{snmpPollerSettingId}/devices endpoint limited to the defined number of items

### EXAMPLE 3

```powershell
Get-AuvikSNMPPollerDevice -SnmpPollerSettingId '1234567890' -Tenants '1234567890' -AllResults
```

Returns every item from the /settings/snmppoller/{snmpPollerSettingId}/devices endpoint by following the pagination links

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

### -FilterMakeModel

Filter by the device's make and model.

```yaml
Type: System.String
DefaultValue: ''
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

### -FilterModifiedAfter

Filter by date and time, only returning entities modified after provided value.

Accepts a date & time which is sent to the API in UTC

```yaml
Type: System.DateTime
DefaultValue: ''
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

### -FilterNotSeenSince

Filter by the last seen online time, returning entities not seen online after the provided value.

Accepts a date & time which is sent to the API in UTC

```yaml
Type: System.DateTime
DefaultValue: ''
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

### -FilterOnlineStatus

Filter by the device's online status.

Allowed values:
'online', 'offline', 'unreachable', 'testing', 'unknown', 'dormant', 'notPresent', 'lowerLayerDown'

```yaml
Type: System.String
DefaultValue: ''
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

### -FilterVendorName

Filter by the device's vendor/manufacturer.

```yaml
Type: System.String
DefaultValue: ''
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

### -SnmpPollerSettingId

ID of the SNMP Poller Setting that the devices apply to

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases:
- Id
ParameterSets:
- Name: (All)
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
- Name: (All)
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

Endpoint : GET /settings/snmppoller/{snmpPollerSettingId}/devices
The Auvik API user needs the role permissions that are required by the endpoint


## RELATED LINKS

- [](https://celerium.github.io/Celerium.Auvik/site/Pollers/Get-AuvikSNMPPollerDevice.html)
