---
external help file: Celerium.Auvik-help.xml
grand_parent: Statistics
Module Name: Celerium.Auvik
online version: https://celerium.github.io/Celerium.Auvik/site/Statistics/Get-AuvikInterfaceStatistics.html
parent: GET
schema: 2.0.0
title: Get-AuvikInterfaceStatistics
---

# Get-AuvikInterfaceStatistics

## SYNOPSIS
Provides historical interface statistics such
as bandwidth and packet loss

## SYNTAX

```powershell
Get-AuvikInterfaceStatistics [-StatId] <String> [[-Tenants] <String[]>] [-FilterFromTime] <DateTime>
 [[-FilterThruTime] <DateTime>] [-FilterInterval] <String> [[-FilterInterfaceType] <String>]
 [[-FilterInterfaceId] <String>] [[-FilterParentDevice] <String>] [[-PageFirst] <Int64>]
 [[-PageAfter] <String>] [[-PageLast] <Int64>] [[-PageBefore] <String>] [-AllResults] [<CommonParameters>]
```

## DESCRIPTION
The Get-AuvikInterfaceStatistics cmdlet provides historical
interface statistics such as bandwidth and packet loss

## EXAMPLES

### EXAMPLE 1
```powershell
Get-AuvikInterfaceStatistics -StatId bandwidth -FilterFromTime 2023-10-03 -FilterInterval day
```

Provides the first 100 historical interface statistics such
as bandwidth and packet loss

### EXAMPLE 2
```powershell
Get-AuvikInterfaceStatistics -StatId bandwidth -FilterFromTime 2023-10-03 -FilterInterval day -PageFirst 1000 -AllResults
```

Provides all historical interface statistics such
as bandwidth and packet loss

## PARAMETERS

### -StatId
ID of statistic to return

Allowed values:
    "bandwidth", "utilization", "packetLoss", "packetDiscard", "packetMulticast", "packetUnicast", "packetBroadcast"

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

### -FilterFromTime
Timestamp from which you want to query

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterThruTime
Timestamp to which you want to query (defaults to current time)

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

### -FilterInterval
Statistics reporting interval

Allowed values:
    "minute", "hour", "day"

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterInterfaceType
Filter by interface type

Allowed values:
    "ethernet", "wifi", "bluetooth", "cdma", "coax", "cpu", "distributedVirtualSwitch",
    "firewire", "gsm", "ieee8023AdLag", "inferredWired", "inferredWireless", "interface",
    "linkAggregation", "loopback", "modem", "wimax", "optical", "other", "parallel", "ppp",
    "radiomac", "rs232", "tunnel", "unknown", "usb", "virtualBridge", "virtualNic",
    "virtualSwitch", "vlan"

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

### -FilterInterfaceId
Filter by interface ID

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

### -FilterParentDevice
Filter by the entity's parent device ID

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

[https://celerium.github.io/Celerium.Auvik/site/Statistics/Get-AuvikInterfaceStatistics.html](https://celerium.github.io/Celerium.Auvik/site/Statistics/Get-AuvikInterfaceStatistics.html)

