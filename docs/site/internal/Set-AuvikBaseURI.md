---
external help file: Celerium.Auvik-help.xml
grand_parent: Internal
Module Name: Celerium.Auvik
online version: https://celerium.github.io/Celerium.Auvik/site/Internal/Set-AuvikBaseURI.html
parent: POST
schema: 2.0.0
title: Set-AuvikBaseURI
---

# Set-AuvikBaseURI

## SYNOPSIS
Sets the base URI for the Auvik API connection

## SYNTAX

## DESCRIPTION
The Add-AuvikBaseURI cmdlet sets the base URI which is later used
to construct the full URI for all API calls

## EXAMPLES

### EXAMPLE 1
```powershell
Add-AuvikBaseURI
```

The base URI will use https://auvikapi.us1.my.auvik.com/v1 which is Auvik's default URI

### EXAMPLE 2
```powershell
Add-AuvikBaseURI -DataCenter US
```

The base URI will use https://auvikapi.us1.my.auvik.com/v1 which is Auvik's US URI

### EXAMPLE 3
```powershell
Add-AuvikBaseURI -BaseUri http://myapi.gateway.celerium.org
```

A custom API gateway of http://myapi.gateway.celerium.org will be used for all API calls to Auvik's API

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
N\A

## RELATED LINKS

[https://celerium.github.io/Celerium.Auvik/site/Internal/Add-AuvikBaseURI.html](https://celerium.github.io/Celerium.Auvik/site/Internal/Add-AuvikBaseURI.html)

