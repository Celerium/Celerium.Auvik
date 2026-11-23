---
document type: cmdlet
external help file: Celerium.Auvik-Help.xml
grand_parent: Internal
HelpUri: https://celerium.github.io/Celerium.Auvik/site/Internal/Add-AuvikBaseURI.html
Locale: en-US
Module Name: Celerium.Auvik
parent: PUT
PlatyPS schema version: 2024-05-01
title: Add-AuvikBaseURI
---

# Add-AuvikBaseURI

## SYNOPSIS

Sets the base URI for the Auvik API connection

## SYNTAX

### Set (Default)

```
Add-AuvikBaseURI [[-BaseUri] <string>] [[-DataCenter] <string>]
```

## ALIASES

This cmdlet has the following aliases,
  - Set-AuvikBaseURI

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
Add-AuvikBaseURI -BaseUri us2.my.auvik.com
```

The base URI will use https://auvikapi.us2.my.auvik.com/v1

### EXAMPLE 4

```powershell
Add-AuvikBaseURI -BaseUri http://myapi.gateway.celerium.org
```

A custom API gateway of http://myapi.gateway.celerium.org will be used for all API calls to Auvik's API

## PARAMETERS

### -BaseUri

Define the base URI for the Auvik API connection using Auvik's URI or a custom URI

An Auvik host such as us2.my.auvik.com or auvikapi.us2.my.auvik.com is converted to
https://auvikapi.us2.my.auvik.com/v1 & a URI without a scheme uses https

```yaml
Type: System.String
DefaultValue: https://auvikapi.us1.my.auvik.com/v1
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: false
  ValueFromPipeline: true
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -DataCenter

Auvik's URI connection point that can be one of the predefined data centers

https://support.auvik.com/hc/en-us/articles/360033412992

Accepted Values:
'au1', 'ca1', 'eu', 'eu1', 'eu2', 'us', 'us1', 'us2', 'us3', 'us4', 'us5', 'us6'

Example:
    us3 = https://auvikapi.us3.my.auvik.com/v1

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 1
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

{{ Fill in the Description }}

## OUTPUTS

## NOTES

N/A


## RELATED LINKS

- [](https://celerium.github.io/Celerium.Auvik/site/Internal/Add-AuvikBaseURI.html)
