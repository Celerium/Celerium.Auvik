---
external help file: Celerium.Auvik-help.xml
grand_parent: billing
Module Name: Celerium.Auvik
online version: https://celerium.github.io/Celerium.Auvik/site/billing/Get-AuvikBilling.html
parent: GET
schema: 2.0.0
title: Get-AuvikBilling
---

# Get-AuvikBilling

## SYNOPSIS
Get Auvik billing information

## SYNTAX

### IndexByClient (Default)
```powershell
Get-AuvikBilling -FilterFromDate <DateTime> -FilterThruDate <DateTime> [-Tenants <String[]>]
 [<CommonParameters>]
```

### IndexByDevice
```powershell
Get-AuvikBilling -FilterFromDate <DateTime> -FilterThruDate <DateTime> -ID <String> [<CommonParameters>]
```

## DESCRIPTION
The Get-AuvikBilling cmdlet gets billing information
to help calculate your invoices

The dataTime value are converted to UTC, however for these endpoints
you will only need to defined yyyy-MM-dd

## EXAMPLES

### EXAMPLE 1
```powershell
Get-AuvikBilling -FilterFromDate 2023-09-01 -FilterThruDate 2023-09-30
```

Gets a summary of a client's (and client's children if a multi-client)
usage for the given time range.

### EXAMPLE 2
```powershell
Get-AuvikBilling -FilterFromDate 2023-09-01 -FilterThruDate 2023-09-30 -Tenants 12345,98765
```

Gets a summary of the defined client's (and client's children if a multi-client)fromDate
usage for the given time range.

### EXAMPLE 3
```powershell
Get-AuvikBilling -FilterFromDate 2023-09-01 -FilterThruDate 2023-09-30 -ID 123456789
```

Gets a summary of the define device id's usage for the given time range.

## PARAMETERS

### -FilterFromDate
Date from which you want to query

Example: filter\[fromDate\]=2019-06-01

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterThruDate
Date to which you want to query

Example: filter\[thruDate\]=2019-06-30

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tenants
Comma delimited list of tenant IDs to request info from.

Example: Tenants=199762235015168516,199762235015168004

```yaml
Type: String[]
Parameter Sets: IndexByClient
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ID
ID of device

```yaml
Type: String
Parameter Sets: IndexByDevice
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
N\A

## RELATED LINKS

[https://celerium.github.io/Celerium.Auvik/site/Billing/Get-AuvikBilling.html](https://celerium.github.io/Celerium.Auvik/site/Billing/Get-AuvikBilling.html)

