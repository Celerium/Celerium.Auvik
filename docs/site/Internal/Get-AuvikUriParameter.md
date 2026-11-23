---
document type: cmdlet
external help file: Celerium.Auvik-Help.xml
grand_parent: Internal
HelpUri: https://celerium.github.io/Celerium.Auvik/site/Internal/Get-AuvikUriParameter.html
Locale: en-US
Module Name: Celerium.Auvik
parent: GET
PlatyPS schema version: 2024-05-01
title: Get-AuvikUriParameter
---

# Get-AuvikUriParameter

## SYNOPSIS

Translates the bound parameters of a function to API query parameters

## SYNTAX

### __AllParameterSets

```
Get-AuvikUriParameter [-BoundParameter] <IDictionary> [-NameMap] <IDictionary>
```

## ALIASES

This cmdlet has the following aliases,
  - None

## DESCRIPTION

The Get-AuvikUriParameter cmdlet translates the bound parameters of a public function
into the query parameters (uri filters) used by the Auvik API

Only the parameters that were bound & are defined in the NameMap are returned.
This
allows a PowerShell friendly parameter name such as [ FilterDeviceType ] to be
translated to the name the API expects such as [ filter[deviceType] ]

This is an internal helper function that is used by the public functions

## EXAMPLES

### EXAMPLE 1

```powershell
Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap @{ FilterDeviceType = 'filter[deviceType]' }
```

Returns a hashtable such as @{ 'filter[deviceType]' = 'router' } when the FilterDeviceType
parameter was used by the calling function

## PARAMETERS

### -BoundParameter

The $PSBoundParameters of the calling function

```yaml
Type: System.Collections.IDictionary
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -NameMap

Hashtable that maps a PowerShell parameter name to an API query parameter name

Example:
    @{ FilterDeviceType = 'filter[deviceType]'; Tenants = 'tenants' }

```yaml
Type: System.Collections.IDictionary
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 1
  IsRequired: true
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

## OUTPUTS

### System.Collections.Hashtable

{{ Fill in the Description }}

## NOTES

N\A


## RELATED LINKS

- [](https://celerium.github.io/Celerium.Auvik/site/Internal/Get-AuvikUriParameter.html)
