---
external help file: Celerium.Auvik-help.xml
grand_parent: SaaSManagement
Module Name: Celerium.Auvik
online version: https://celerium.github.io/Celerium.Auvik/site/SaaSManagement/Get-AuvikASMUser.html
parent: GET
schema: 2.0.0
title: Get-AuvikASMUser
---

# Get-AuvikASMUser

## SYNOPSIS
Get Auvik ASM user information

## SYNTAX

```powershell
Get-AuvikASMUser [[-FilterClientId] <String>] [[-PageFirst] <Int64>] [[-PageAfter] <String>]
 [[-PageLast] <Int64>] [[-PageBefore] <String>] [-AllResults] [<CommonParameters>]
```

## DESCRIPTION
The Get-AuvikASMUser cmdlet gets information about any monitored
users that exist within a specific Auvik SaaS Management tenant

## EXAMPLES

### EXAMPLE 1
```powershell
Get-AuvikASMUser
```

Get Auvik ASM user information

### EXAMPLE 2
```powershell
Get-AuvikASMUser -PageFirst 1000 -AllResults
```

Get Auvik ASM user information for all devices found by Auvik

## PARAMETERS

### -FilterClientId
Filter by client ID

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
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
Position: 2
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
Position: 3
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
Position: 4
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
Position: 5
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

[https://celerium.github.io/Celerium.Auvik/site/SaaSManagement/Get-AuvikASMUser.html](https://celerium.github.io/Celerium.Auvik/site/SaaSManagement/Get-AuvikASMUser.html)

