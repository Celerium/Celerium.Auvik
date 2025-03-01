---
external help file: Celerium.Auvik-help.xml
grand_parent: alert
Module Name: Celerium.Auvik
online version: https://celerium.github.io/Celerium.Auvik/site/alert/Get-AuvikAlert.html
parent: GET
schema: 2.0.0
title: Get-AuvikAlert
---

# Get-AuvikAlert

## SYNOPSIS
Get Auvik alert events that have been triggered by your Auvik collector(s).

## SYNTAX

### IndexByMultiAlert (Default)
```powershell
Get-AuvikAlert [-Tenants <String[]>] [-FilterAlertDefinitionId <String>] [-FilterSeverity <String>]
 [-FilterStatus <String>] [-FilterEntityId <String>] [-FilterDismissed] [-FilterDispatched]
 [-FilterDetectedTimeAfter <DateTime>] [-FilterDetectedTimeBefore <DateTime>] [-PageFirst <Int64>]
 [-PageAfter <String>] [-PageLast <Int64>] [-PageBefore <String>] [-AllResults] [<CommonParameters>]
```

### IndexBySingleAlert
```powershell
Get-AuvikAlert -ID <String> [<CommonParameters>]
```

## DESCRIPTION
The Get-AuvikAlert cmdlet allows you to view the alert events
that has been triggered by your Auvik collector(s).

## EXAMPLES

### EXAMPLE 1
```powershell
Get-AuvikAlert
```

Gets general information about the first 100 alerts
Auvik has discovered

### EXAMPLE 2
```powershell
Get-AuvikAlert -ID 123456789
```

Gets general information for the defined alert
Auvik has discovered

### EXAMPLE 3
```powershell
Get-AuvikAlert -PageFirst 1000 -AllResults
```

Gets general information for all alerts found by Auvik.

## PARAMETERS

### -ID
ID of alert

```yaml
Type: String
Parameter Sets: IndexBySingleAlert
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Tenants
Comma delimited list of tenant IDs to request info from

```yaml
Type: String[]
Parameter Sets: IndexByMultiAlert
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterAlertDefinitionId
Filter by alert definition ID

```yaml
Type: String
Parameter Sets: IndexByMultiAlert
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterSeverity
Filter by alert severity

Allowed values:
    "unknown", "emergency", "critical", "warning", "info"

```yaml
Type: String
Parameter Sets: IndexByMultiAlert
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterStatus
Filter by the status of the alert

Allowed values:
    "created", "resolved", "paused", "unpaused"

```yaml
Type: String
Parameter Sets: IndexByMultiAlert
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterEntityId
Filter by the related entity ID

```yaml
Type: String
Parameter Sets: IndexByMultiAlert
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterDismissed
Filter by the dismissed status

As of 2023-10 this parameter does not appear to work

```yaml
Type: SwitchParameter
Parameter Sets: IndexByMultiAlert
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterDispatched
Filter by dispatched status

As of 2023-10 this parameter does not appear to work

```yaml
Type: SwitchParameter
Parameter Sets: IndexByMultiAlert
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterDetectedTimeAfter
Filter by the time which is greater than the given timestamp

```yaml
Type: DateTime
Parameter Sets: IndexByMultiAlert
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterDetectedTimeBefore
Filter by the time which is less than or equal to the given timestamp

```yaml
Type: DateTime
Parameter Sets: IndexByMultiAlert
Aliases:

Required: False
Position: Named
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
Parameter Sets: IndexByMultiAlert
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageAfter
Cursor after which elements will be returned as a page
The page size is provided by page\[first\]

```yaml
Type: String
Parameter Sets: IndexByMultiAlert
Aliases:

Required: False
Position: Named
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
Parameter Sets: IndexByMultiAlert
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageBefore
Cursor before which elements will be returned as a page
The page size is provided by page\[last\]

```yaml
Type: String
Parameter Sets: IndexByMultiAlert
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllResults
Returns all items from an endpoint

Highly recommended to only use with filters to reduce API errors\timeouts

```yaml
Type: SwitchParameter
Parameter Sets: IndexByMultiAlert
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

[https://celerium.github.io/Celerium.Auvik/site/Alert/Get-AuvikAlert.html](https://celerium.github.io/Celerium.Auvik/site/Alert/Get-AuvikAlert.html)

