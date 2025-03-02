---
external help file: Celerium.Auvik-help.xml
grand_parent: Inventory
Module Name: Celerium.Auvik
online version: https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikConfiguration.html
parent: GET
schema: 2.0.0
title: Get-AuvikConfiguration
---

# Get-AuvikConfiguration

## SYNOPSIS
Get Auvik history of device configurations

## SYNTAX

### IndexByMultiConfig (Default)
```powershell
Get-AuvikConfiguration [-Tenants <String[]>] [-FilterDeviceId <String>] [-FilterBackupTimeAfter <DateTime>]
 [-FilterBackupTimeBefore <DateTime>] [-FilterIsRunning] [-PageFirst <Int64>] [-PageAfter <String>]
 [-PageLast <Int64>] [-PageBefore <String>] [-AllResults] [<CommonParameters>]
```

### IndexBySingleConfig
```powershell
Get-AuvikConfiguration -ID <String> [<CommonParameters>]
```

## DESCRIPTION
The Get-AuvikConfiguration cmdlet allows you to view a history of
device configurations and other related information discovered by Auvik

## EXAMPLES

### EXAMPLE 1
```powershell
Get-AuvikConfiguration
```

Gets general information about the first 100 configurations
Auvik has discovered

### EXAMPLE 2
```powershell
Get-AuvikConfiguration -ID 123456789
```

Gets general information for the defined configuration
Auvik has discovered

### EXAMPLE 3
```powershell
Get-AuvikConfiguration -PageFirst 1000 -AllResults
```

Gets general information for all configurations found by Auvik

## PARAMETERS

### -ID
ID of entity note\audit

```yaml
Type: String
Parameter Sets: IndexBySingleConfig
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
Parameter Sets: IndexByMultiConfig
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterDeviceId
Filter by device ID

```yaml
Type: String
Parameter Sets: IndexByMultiConfig
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterBackupTimeAfter
Filter by date and time, filtering out configurations backed up before value

```yaml
Type: DateTime
Parameter Sets: IndexByMultiConfig
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterBackupTimeBefore
Filter by date and time, filtering out configurations backed up after value

```yaml
Type: DateTime
Parameter Sets: IndexByMultiConfig
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterIsRunning
Filter for configurations that are currently running, or filter
for all configurations which are not currently running

As of 2023-10, this does not appear to function correctly on this endpoint

```yaml
Type: SwitchParameter
Parameter Sets: IndexByMultiConfig
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageFirst
For paginated responses, the first N elements will be returned
Used in combination with page\[after\]

Default Value: 100

```yaml
Type: Int64
Parameter Sets: IndexByMultiConfig
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
Parameter Sets: IndexByMultiConfig
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
Parameter Sets: IndexByMultiConfig
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
Parameter Sets: IndexByMultiConfig
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
Parameter Sets: IndexByMultiConfig
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

[https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikConfiguration.html](https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikConfiguration.html)

