---
external help file: Celerium.Auvik-help.xml
grand_parent: internal
Module Name: Celerium.Auvik
online version: https://celerium.github.io/Celerium.Auvik/site/internal/Get-AuvikMetaData.html
parent: GET
schema: 2.0.0
title: Get-AuvikMetaData
---

# Get-AuvikMetaData

## SYNOPSIS
Gets various Api metadata values

## SYNTAX

```powershell
Get-AuvikMetaData [[-BaseUri] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-AuvikMetaData cmdlet gets various Api metadata values from an
Invoke-WebRequest to assist in various troubleshooting scenarios such
as rate-limiting.

## EXAMPLES

### EXAMPLE 1
```powershell
Get-AuvikMetaData
```

Gets various Api metadata values from an Invoke-WebRequest to assist
in various troubleshooting scenarios such as rate-limiting.

The default full base uri test path is:
    https://auvikapi.us1.my.auvik.com/v1

### EXAMPLE 2
```powershell
Get-AuvikMetaData -BaseUri http://myapi.gateway.celerium.org
```

Gets various Api metadata values from an Invoke-WebRequest to assist
in various troubleshooting scenarios such as rate-limiting.

The full base uri test path in this example is:
    http://myapi.gateway.celerium.org/device

## PARAMETERS

### -BaseUri
Define the base URI for the Auvik API connection using Auvik's URI or a custom URI.

The default base URI is https://auvikapi.us1.my.auvik.com/v1

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $AuvikModuleBaseURI
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

[https://celerium.github.io/Celerium.Auvik/site/Internal/Get-AuvikMetaData.html](https://celerium.github.io/Celerium.Auvik/site/Internal/Get-AuvikMetaData.html)

