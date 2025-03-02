---
external help file: Celerium.Auvik-help.xml
grand_parent: Inventory
Module Name: Celerium.Auvik
online version: https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikNetwork.html
parent: GET
schema: 2.0.0
title: Get-AuvikNetwork
---

# Get-AuvikNetwork

## SYNOPSIS
Get Auvik networks and other related information

## SYNTAX

### IndexByMultiNetworkInfo (Default)
```powershell
Get-AuvikNetwork [-Tenants <String[]>] [-FilterNetworkType <String>] [-FilterScanStatus <String>]
 [-FilterDevices <String[]>] [-FilterModifiedAfter <DateTime>] [-Include <String>]
 [-FieldsNetworkDetail <String[]>] [-PageFirst <Int64>] [-PageAfter <String>] [-PageLast <Int64>]
 [-PageBefore <String>] [-AllResults] [<CommonParameters>]
```

### IndexBySingleNetworkDetail
```powershell
Get-AuvikNetwork -ID <String> [-NetworkDetails] [<CommonParameters>]
```

### IndexBySingleNetworkInfo
```powershell
Get-AuvikNetwork -ID <String> [-Include <String>] [-FieldsNetworkDetail <String[]>] [-NetworkInfo]
 [<CommonParameters>]
```

### IndexByMultiNetworkDetail
```powershell
Get-AuvikNetwork [-Tenants <String[]>] [-FilterNetworkType <String>] [-FilterScanStatus <String>]
 [-FilterDevices <String[]>] [-FilterModifiedAfter <DateTime>] [-FilterScope <String>] [-PageFirst <Int64>]
 [-PageAfter <String>] [-PageLast <Int64>] [-PageBefore <String>] [-AllResults] [<CommonParameters>]
```

## DESCRIPTION
The Get-AuvikNetwork cmdlet allows you to view an inventory of
networks and other related information discovered by Auvik

Use the \[ -NetworkDetails & -NetworkInfo  \] parameters when wanting to target
specific information.
See Get-Help Get-AuvikNetwork -Full for
more information on associated parameters

## EXAMPLES

### EXAMPLE 1
```powershell
Get-AuvikNetwork
```

Gets general information about the first 100 networks
Auvik has discovered

### EXAMPLE 2
```powershell
Get-AuvikNetwork -ID 123456789 -NetworkInfo
```

Gets general information for the defined network
Auvik has discovered

### EXAMPLE 3
```powershell
Get-AuvikNetwork -NetworkDetails
```

Gets detailed information about the first 100 networks
Auvik has discovered

### EXAMPLE 4
```powershell
Get-AuvikNetwork -ID 123456789 -NetworkDetails
```

Gets network details information for the defined network
Auvik has discovered

### EXAMPLE 5
```powershell
Get-AuvikNetwork -PageFirst 1000 -AllResults
```

Gets network info information for all networks found by Auvik

## PARAMETERS

### -ID
ID of network

```yaml
Type: String
Parameter Sets: IndexBySingleNetworkDetail, IndexBySingleNetworkInfo
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
Parameter Sets: IndexByMultiNetworkInfo, IndexByMultiNetworkDetail
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterNetworkType
Filter by network type

Allowed values:
    "routed", "vlan", "wifi", "loopback", "network", "layer2", "internet"

```yaml
Type: String
Parameter Sets: IndexByMultiNetworkInfo, IndexByMultiNetworkDetail
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterScanStatus
Filter by the network's scan status

Allowed values:
    "true", "false", "notAllowed", "unknown"

```yaml
Type: String
Parameter Sets: IndexByMultiNetworkInfo, IndexByMultiNetworkDetail
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterDevices
Filter by IDs of devices on this network

Filter by multiple values by providing a comma delimited list

```yaml
Type: String[]
Parameter Sets: IndexByMultiNetworkInfo, IndexByMultiNetworkDetail
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
Parameter Sets: IndexByMultiNetworkInfo, IndexByMultiNetworkDetail
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterScope
Filter by the network's scope

Allowed values:
    "private", "public"

```yaml
Type: String
Parameter Sets: IndexByMultiNetworkDetail
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Include
Use to Include the full resource objects of the list device relationships

Example: Include=deviceDetail

```yaml
Type: String
Parameter Sets: IndexByMultiNetworkInfo, IndexBySingleNetworkInfo
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FieldsNetworkDetail
Use to limit the attributes that will be returned in the Included detail
object to only what is specified by this query parameter

Allowed values:
    "scope", "primaryCollector", "secondaryCollectors", "collectorSelection", "excludedIpAddresses"

Requires Include=networkDetail

```yaml
Type: String[]
Parameter Sets: IndexByMultiNetworkInfo, IndexBySingleNetworkInfo
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NetworkDetails
Target the network details endpoint

/Inventory/network/info & /Inventory/network/info/{id}

```yaml
Type: SwitchParameter
Parameter Sets: IndexBySingleNetworkDetail
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -NetworkInfo
Target the network info endpoint

/Inventory/network/detail & /Inventory/network/detail/{id}

```yaml
Type: SwitchParameter
Parameter Sets: IndexBySingleNetworkInfo
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
Parameter Sets: IndexByMultiNetworkInfo, IndexByMultiNetworkDetail
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
Parameter Sets: IndexByMultiNetworkInfo, IndexByMultiNetworkDetail
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
Parameter Sets: IndexByMultiNetworkInfo, IndexByMultiNetworkDetail
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
Parameter Sets: IndexByMultiNetworkInfo, IndexByMultiNetworkDetail
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
Parameter Sets: IndexByMultiNetworkInfo, IndexByMultiNetworkDetail
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

[https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikNetwork.html](https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikNetwork.html)

