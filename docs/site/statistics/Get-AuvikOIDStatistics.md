---
external help file: Celerium.Auvik-help.xml
grand_parent: statistics
Module Name: Celerium.Auvik
online version: https://celerium.github.io/Celerium.Auvik/site/statistics/Get-AuvikOIDStatistics.html
parent: GET
schema: 2.0.0
title: Get-AuvikOIDStatistics
---

# Get-AuvikOIDStatistics

## SYNOPSIS
Provides the current value for numeric SNMP Pollers

## SYNTAX

```powershell
Get-AuvikOIDStatistics [-StatId] <String> [[-Tenants] <String[]>] [[-FilterDeviceId] <String>]
 [[-FilterDeviceType] <String>] [[-FilterOID] <String>] [[-PageFirst] <Int64>] [[-PageAfter] <String>]
 [[-PageLast] <Int64>] [[-PageBefore] <String>] [-AllResults] [<CommonParameters>]
```

## DESCRIPTION
The Get-AuvikOIDStatistics cmdlet provides the current
value for numeric SNMP Pollers

## EXAMPLES

### EXAMPLE 1
```powershell
Get-AuvikOIDStatistics -StatId deviceMonitor
```

Provides the first 100 values for numeric SNMP Pollers

### EXAMPLE 2
```powershell
Get-AuvikOIDStatistics -StatId deviceMonitor -PageFirst 1000 -AllResults
```

Provides all values for numeric SNMP Pollers

## PARAMETERS

### -StatId
ID of statistic to return

Example: "deviceMonitor"

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tenants
Comma delimited list of tenant IDs to request info from

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -FilterDeviceId
Filter by device ID

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

### -FilterDeviceType
Filter by device type

Allowed values:
    "unknown", "switch", "l3Switch", "router", "accessPoint", "firewall",
    "workstation", "server", "storage", "printer", "copier", "hypervisor",
    "multimedia", "phone", "tablet", "handheld", "virtualAppliance", "bridge",
    "controller", "hub", "modem", "ups", "module", "loadBalancer", "camera",
    "telecommunications", "packetProcessor", "chassis", "airConditioner",
    "virtualMachine", "pdu", "ipPhone", "backhaul", "internetOfThings",
    "voipSwitch", "stack", "backupDevice", "timeClock", "lightingDevice",
    "audioVisual", "securityAppliance", "utm", "alarm", "buildingManagement",
    "ipmi", "thinAccessPoint", "thinClient"

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterOID
Filter by OID

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
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
Position: 6
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
Position: 7
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
Position: 8
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
Position: 9
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

[https://celerium.github.io/Celerium.Auvik/site/Statistics/Get-AuvikOIDStatistics.html](https://celerium.github.io/Celerium.Auvik/site/Statistics/Get-AuvikOIDStatistics.html)

