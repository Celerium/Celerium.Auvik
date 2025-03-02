---
external help file: Celerium.Auvik-help.xml
grand_parent: Pollers
Module Name: Celerium.Auvik
online version: https://celerium.github.io/Celerium.Auvik/site/Pollers/Get-AuvikSNMPPollerDevice.html
parent: GET
schema: 2.0.0
title: Get-AuvikSNMPPollerDevice
---

# Get-AuvikSNMPPollerDevice

## SYNOPSIS
Provides Details about all the devices associated to a
specific SNMP Poller Setting

## SYNTAX

```powershell
Get-AuvikSNMPPollerDevice [-SNMPPollerSettingId] <String> [-Tenants] <String[]>
 [[-FilterOnlineStatus] <String>] [[-FilterModifiedAfter] <DateTime>] [[-FilterNotSeenSince] <DateTime>]
 [[-FilterDeviceType] <String>] [[-FilterMakeModel] <String>] [[-FilterVendorName] <String>]
 [[-PageFirst] <Int64>] [[-PageAfter] <String>] [[-PageLast] <Int64>] [[-PageBefore] <String>] [-AllResults]
 [<CommonParameters>]
```

## DESCRIPTION
The Get-AuvikSNMPPollerDevice cmdlet provides Details about all
the devices associated to a specific SNMP Poller Setting

## EXAMPLES

### EXAMPLE 1
```powershell
Get-AuvikSNMPPollerDevice -SNMPPollerSettingId MTk5NTAyNzg2ODc3 -Tenants 123456789
```

Provides Details about the first 100 devices associated to the defined
SNMP Poller id

### EXAMPLE 2
```powershell
Get-AuvikSNMPPollerDevice -SNMPPollerSettingId MTk5NTAyNzg2ODc3 -Tenants 123456789 -PageFirst 1000 -AllResults
```

Provides Details about all the devices associated to the defined
SNMP Poller id

## PARAMETERS

### -SNMPPollerSettingId
ID of the SNMP Poller Setting that the devices apply to

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Tenants
Comma delimited list of tenant IDs to request info from

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterOnlineStatus
Filter by the device's online status

Allowed values:
    "online", "offline", "unreachable", "testing", "unknown", "dormant", "notPresent", "lowerLayerDown"

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterModifiedAfter
Filter by date and time, only returning entities modified after provided value

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterNotSeenSince
Filter by the last seen online time, returning entities not
seen online after the provided value

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterDeviceType
Filter by device type

Allowed values:
    "unknown", "switch", "l3Switch", "router", "accessPoint", "firewall", "workstation",
    "server", "storage", "printer", "copier", "hypervisor", "multimedia", "phone", "tablet",
    "handheld", "virtualAppliance", "bridge", "controller", "hub", "modem", "ups", "module",
    "loadBalancer", "camera", "telecommunications", "packetProcessor", "chassis", "airConditioner",
    "virtualMachine", "pdu", "ipPhone", "backhaul", "internetOfThings", "voipSwitch", "stack",
    "backupDevice", "timeClock", "lightingDevice", "audioVisual", "securityAppliance", "utm",
    "alarm", "buildingManagement", "ipmi", "thinAccessPoint", "thinClient"

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterMakeModel
Filter by the device's make and model

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterVendorName
Filter by the device's vendor/manufacturer

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageFirst
For paginated responses, the first N elements will be returned
Used in combination with page\[after\]

Default Value: 100

```yaml
Type: Int64
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageAfter
Cursor after which elements will be returned as a page
The page size is provided by page\[first\]

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageLast
For paginated responses, the last N services will be returned
Used in combination with page\[before\]

Default Value: 100

```yaml
Type: Int64
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageBefore
Cursor before which elements will be returned as a page
The page size is provided by page\[last\]

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 12
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllResults
Returns all items from an endpoint

Highly recommended to only use with filters to reduce API errors\timeouts

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
N\A

## RELATED LINKS

[https://celerium.github.io/Celerium.Auvik/site/Pollers/Get-AuvikSNMPPollerDevice.html](https://celerium.github.io/Celerium.Auvik/site/Pollers/Get-AuvikSNMPPollerDevice.html)

