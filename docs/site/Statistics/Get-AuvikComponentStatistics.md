---
external help file: Celerium.Auvik-help.xml
grand_parent: Statistics
Module Name: Celerium.Auvik
online version: https://celerium.github.io/Celerium.Auvik/site/Statistics/Get-AuvikComponentStatistics.html
parent: GET
schema: 2.0.0
title: Get-AuvikComponentStatistics
---

# Get-AuvikComponentStatistics

## SYNOPSIS
Provides historical statistics for components
such as CPUs, disks, fans and memory

## SYNTAX

```powershell
Get-AuvikComponentStatistics [-ComponentType] <String> [-StatId] <String> [[-Tenants] <String[]>]
 [-FilterFromTime] <DateTime> [[-FilterThruTime] <DateTime>] [-FilterInterval] <String>
 [[-FilterComponentId] <String>] [[-FilterParentDevice] <String>] [[-PageFirst] <Int64>]
 [[-PageAfter] <String>] [[-PageLast] <Int64>] [[-PageBefore] <String>] [-AllResults] [<CommonParameters>]
```

## DESCRIPTION
The Get-AuvikComponentStatistics cmdlet provides historical
statistics for components such as CPUs, disks, fans and memory

Make sure to read the documentation when defining ComponentType & StatId,
as only certain StatId's work with certain ComponentTypes

https://auvikapi.us1.my.auvik.com/docs#operation/readInterfaceStatistics

## EXAMPLES

### EXAMPLE 1
```powershell
Get-AuvikComponentStatistics -ComponentType cpu -StatId latency -FilterFromTime 2023-10-03 -FilterInterval day
```

Provides the first 100 historical statistics for CPU components

### EXAMPLE 2
```powershell
Get-AuvikComponentStatistics -ComponentType cpu -StatId latency -FilterFromTime 2023-10-03 -FilterInterval day -PageFirst 1000 -AllResults
```

Provides all historical statistics for CPU components

## PARAMETERS

### -ComponentType
Component type of statistic to return

Allowed values:
    "cpu", "cpuCore", "disk", "fan", "memory", "powerSupply", "systemBoard"

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

### -StatId
ID of statistic to return

Allowed values:
    "capacity", "counters", "idle", "latency", "power", "queueLatency",
    "rate", "readiness", "ready", "speed", "swap", "swapRate", "temperature",
    "totalLatency", "utilization"

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
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
Position: 3
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
Position: 4
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
Position: 5
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
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterComponentId
Filter by component ID

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

[https://celerium.github.io/Celerium.Auvik/site/Statistics/Get-AuvikComponentStatistics.html](https://celerium.github.io/Celerium.Auvik/site/Statistics/Get-AuvikComponentStatistics.html)

