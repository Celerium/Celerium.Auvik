---
external help file: Celerium.Auvik-help.xml
grand_parent: inventory
Module Name: Celerium.Auvik
online version: https://celerium.github.io/Celerium.Auvik/site/inventory/Get-AuvikDeviceLifecycle.html
parent: GET
schema: 2.0.0
title: Get-AuvikDeviceLifecycle
---

# Get-AuvikDeviceLifecycle

## SYNOPSIS
Get Auvik devices and other related information

## SYNTAX

### IndexByMultiDevice (Default)
```powershell
Get-AuvikDeviceLifecycle [-Tenants <String[]>] [-FilterSalesAvailability <String>]
 [-FilterSoftwareMaintenanceStatus <String>] [-FilterSecuritySoftwareMaintenanceStatus <String>]
 [-FilterLastSupportStatus <String>] [-PageFirst <Int64>] [-PageAfter <String>] [-PageLast <Int64>]
 [-PageBefore <String>] [-AllResults] [<CommonParameters>]
```

### IndexBySingleDevice
```powershell
Get-AuvikDeviceLifecycle -ID <String> [<CommonParameters>]
```

## DESCRIPTION
The Get-AuvikDeviceLifecycle cmdlet allows you to view an inventory of
devices and other related information discovered by Auvik.

## EXAMPLES

### EXAMPLE 1
```powershell
Get-AuvikDeviceLifecycle
```

Gets general lifecycle information about the first 100 devices
Auvik has discovered

### EXAMPLE 2
```powershell
Get-AuvikDeviceLifecycle -ID 123456789
```

Gets general lifecycle information for the defined device
Auvik has discovered

### EXAMPLE 3
```powershell
Get-AuvikDeviceLifecycle -PageFirst 1000 -AllResults
```

Gets general lifecycle information for all devices found by Auvik.

## PARAMETERS

### -ID
ID of device

```yaml
Type: String
Parameter Sets: IndexBySingleDevice
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
Parameter Sets: IndexByMultiDevice
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterSalesAvailability
Filter by sales availability

Allowed values:
    "covered", "available", "expired", "securityOnly", "unpublished", "empty"

```yaml
Type: String
Parameter Sets: IndexByMultiDevice
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterSoftwareMaintenanceStatus
Filter by software maintenance status

Allowed values:
    "covered", "available", "expired", "securityOnly", "unpublished", "empty"

```yaml
Type: String
Parameter Sets: IndexByMultiDevice
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterSecuritySoftwareMaintenanceStatus
Filter by security software maintenance status

Allowed values:
    "covered", "available", "expired", "securityOnly", "unpublished", "empty"

```yaml
Type: String
Parameter Sets: IndexByMultiDevice
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterLastSupportStatus
Filter by last support status

Allowed values:
    "covered", "available", "expired", "securityOnly", "unpublished", "empty"

```yaml
Type: String
Parameter Sets: IndexByMultiDevice
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
Parameter Sets: IndexByMultiDevice
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
Parameter Sets: IndexByMultiDevice
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
Parameter Sets: IndexByMultiDevice
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
Parameter Sets: IndexByMultiDevice
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
Parameter Sets: IndexByMultiDevice
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

[https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikDeviceLifecycle.html](https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikDeviceLifecycle.html)

