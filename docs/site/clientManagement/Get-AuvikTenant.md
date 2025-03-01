---
external help file: Celerium.Auvik-help.xml
grand_parent: clientManagement
Module Name: Celerium.Auvik
online version: https://celerium.github.io/Celerium.Auvik/site/clientManagement/Get-AuvikTenant.html
parent: GET
schema: 2.0.0
title: Get-AuvikTenant
---

# Get-AuvikTenant

## SYNOPSIS
Get Auvik tenant information

## SYNTAX

### IndexMultiTenant (Default)
```powershell
Get-AuvikTenant [<CommonParameters>]
```

### IndexSingleTenantDetails
```powershell
Get-AuvikTenant -TenantDomainPrefix <String> -ID <String> [<CommonParameters>]
```

### IndexMultiTenantDetails
```powershell
Get-AuvikTenant -TenantDomainPrefix <String> [-FilterAvailableTenants] [<CommonParameters>]
```

## DESCRIPTION
The Get-AuvikTenant cmdlet get Auvik general or detailed
tenant information associated to your Auvik user account

## EXAMPLES

### EXAMPLE 1
```powershell
Get-AuvikTenant
```

Gets general information about multiple multi-clients and
clients associated with your Auvik user account

### EXAMPLE 2
```powershell
Get-AuvikTenant -TenantDomainPrefix CeleriumMSP
```

Gets detailed information about multiple multi-clients and
clients associated with your main Auvik account

### EXAMPLE 3
```powershell
Get-AuvikTenant -TenantDomainPrefix CeleriumMSP -ID 123456789
```

Gets detailed information about a single tenant from
your main Auvik account

## PARAMETERS

### -TenantDomainPrefix
Domain prefix of your main Auvik account (tenant)

```yaml
Type: String
Parameter Sets: IndexSingleTenantDetails, IndexMultiTenantDetails
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterAvailableTenants
Filter whether or not a tenant is available,
i.e.
data can be gotten from them via the API

```yaml
Type: SwitchParameter
Parameter Sets: IndexMultiTenantDetails
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ID
ID of tenant

```yaml
Type: String
Parameter Sets: IndexSingleTenantDetails
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

[https://celerium.github.io/Celerium.Auvik/site/ClientManagement/Get-AuvikTenant.html](https://celerium.github.io/Celerium.Auvik/site/ClientManagement/Get-AuvikTenant.html)

