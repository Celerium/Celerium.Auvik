---
external help file: Celerium.Auvik-help.xml
grand_parent: Inventory
Module Name: Celerium.Auvik
online version: https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikInterface.html
parent: GET
schema: 2.0.0
title: Get-AuvikInterface
---

# Get-AuvikInterface

## SYNOPSIS
Get Auvik interfaces and other related information

## SYNTAX

### IndexByMultiInterface (Default)
```powershell
Get-AuvikInterface [-Tenants <String[]>] [-FilterInterfaceType <String>] [-FilterParentDevice <String>]
 [-FilterAdminStatus] [-FilterOperationalStatus <String>] [-FilterModifiedAfter <DateTime>]
 [-PageFirst <Int64>] [-PageAfter <String>] [-PageLast <Int64>] [-PageBefore <String>] [-AllResults]
 [<CommonParameters>]
```

### IndexBySingleInterface
```powershell
Get-AuvikInterface -ID <String> [<CommonParameters>]
```

## DESCRIPTION
The Get-AuvikInterface cmdlet allows you to view an inventory of
interfaces and other related information discovered by Auvik

## EXAMPLES

### EXAMPLE 1
```powershell
Get-AuvikInterface
```

Gets general information about the first 100 interfaces
Auvik has discovered

### EXAMPLE 2
```powershell
Get-AuvikInterface -ID 123456789
```

Gets general information for the defined interface
Auvik has discovered

### EXAMPLE 3
```powershell
Get-AuvikInterface -PageFirst 1000 -AllResults
```

Gets general information for all interfaces found by Auvik

## PARAMETERS

### -ID
ID of interface

```yaml
Type: String
Parameter Sets: IndexBySingleInterface
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
Parameter Sets: IndexByMultiInterface
Aliases:

Required: False
Position: Named
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
Parameter Sets: IndexByMultiInterface
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterParentDevice
Filter by the entity's parent device ID

```yaml
Type: String
Parameter Sets: IndexByMultiInterface
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterAdminStatus
Filter by the interface's admin status

```yaml
Type: SwitchParameter
Parameter Sets: IndexByMultiInterface
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterOperationalStatus
Filter by the interface's operational status

Allowed values:
    "online", "offline", "unreachable", "testing", "unknown", "dormant", "notPresent", "lowerLayerDown"

```yaml
Type: String
Parameter Sets: IndexByMultiInterface
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
Parameter Sets: IndexByMultiInterface
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
Parameter Sets: IndexByMultiInterface
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
Parameter Sets: IndexByMultiInterface
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
Parameter Sets: IndexByMultiInterface
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
Parameter Sets: IndexByMultiInterface
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
Parameter Sets: IndexByMultiInterface
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

[https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikInterface.html](https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikInterface.html)

