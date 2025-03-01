---
external help file: Celerium.Auvik-help.xml
grand_parent: inventory
Module Name: Celerium.Auvik
online version: https://celerium.github.io/Celerium.Auvik/site/inventory/Get-AuvikComponent.html
parent: GET
schema: 2.0.0
title: Get-AuvikComponent
---

# Get-AuvikComponent

## SYNOPSIS
Get Auvik components and other related information

## SYNTAX

### IndexByMultiComponent (Default)
```powershell
Get-AuvikComponent [-Tenants <String[]>] [-FilterModifiedAfter <DateTime>] [-FilterDeviceId <String>]
 [-FilterDeviceName <String>] [-FilterCurrentStatus <String>] [-PageFirst <Int64>] [-PageAfter <String>]
 [-PageLast <Int64>] [-PageBefore <String>] [-AllResults] [<CommonParameters>]
```

### IndexBySingleComponent
```powershell
Get-AuvikComponent -ID <String> [<CommonParameters>]
```

## DESCRIPTION
The Get-AuvikComponent cmdlet allows you to view an inventory of
components and other related information discovered by Auvik.

## EXAMPLES

### EXAMPLE 1
```powershell
Get-AuvikComponent
```

Gets general information about the first 100 components
Auvik has discovered

### EXAMPLE 2
```powershell
Get-AuvikComponent -ID 123456789
```

Gets general information for the defined component
Auvik has discovered

### EXAMPLE 3
```powershell
Get-AuvikComponent -PageFirst 1000 -AllResults
```

Gets general information for all components found by Auvik.

## PARAMETERS

### -ID
ID of component

```yaml
Type: String
Parameter Sets: IndexBySingleComponent
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
Parameter Sets: IndexByMultiComponent
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterModifiedAfter
Filter by date and time, only returning entities modified after provided value

```yaml
Type: DateTime
Parameter Sets: IndexByMultiComponent
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterDeviceId
Filter by the component's parent device's ID

```yaml
Type: String
Parameter Sets: IndexByMultiComponent
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterDeviceName
Filter by the component's parent device's name

```yaml
Type: String
Parameter Sets: IndexByMultiComponent
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterCurrentStatus
Filter by the component's current status

Allowed values:
    "ok", "degraded", "failed"

```yaml
Type: String
Parameter Sets: IndexByMultiComponent
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
Parameter Sets: IndexByMultiComponent
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
Parameter Sets: IndexByMultiComponent
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
Parameter Sets: IndexByMultiComponent
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
Parameter Sets: IndexByMultiComponent
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
Parameter Sets: IndexByMultiComponent
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

[https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikComponent.html](https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikComponent.html)

