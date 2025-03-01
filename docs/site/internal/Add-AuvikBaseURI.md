---
external help file: Celerium.Auvik-help.xml
grand_parent: internal
Module Name: Celerium.Auvik
online version: https://celerium.github.io/Celerium.Auvik/site/internal/Add-AuvikBaseURI.html
parent: POST
schema: 2.0.0
title: Add-AuvikBaseURI
---

# Add-AuvikBaseURI

## SYNOPSIS
Sets the base URI for the Auvik API connection.

## SYNTAX

```powershell
Add-AuvikBaseURI [[-BaseUri] <String>] [[-DataCenter] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Add-AuvikBaseURI cmdlet sets the base URI which is later used
to construct the full URI for all API calls.

## EXAMPLES

### EXAMPLE 1
```powershell
Add-AuvikBaseURI
```

The base URI will use https://auvikapi.us1.my.auvik.com/v1 which is Auvik's default URI.

### EXAMPLE 2
```powershell
Add-AuvikBaseURI -DataCenter US
```

The base URI will use https://auvikapi.us1.my.auvik.com/v1 which is Auvik's US URI.

### EXAMPLE 3
```powershell
Add-AuvikBaseURI -BaseUri http://myapi.gateway.celerium.org
```

A custom API gateway of http://myapi.gateway.celerium.org will be used for all API calls to Auvik's API.

## PARAMETERS

### -BaseUri
Define the base URI for the Auvik API connection using Auvik's URI or a custom URI.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Https://auvikapi.us1.my.auvik.com/v1
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -DataCenter
Auvik's URI connection point that can be one of the predefined data centers.

https://support.auvik.com/hc/en-us/articles/360033412992

Accepted Values:
'au1', 'ca1', 'eu', 'eu1', 'eu2', 'us', 'us1', 'us2', 'us3', 'us4', 'us5', 'us6'

Example:
    us3 = https://auvikapi.us3.my.auvik.com/v1

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
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

[https://celerium.github.io/Celerium.Auvik/site/Internal/Add-AuvikBaseURI.html](https://celerium.github.io/Celerium.Auvik/site/Internal/Add-AuvikBaseURI.html)

