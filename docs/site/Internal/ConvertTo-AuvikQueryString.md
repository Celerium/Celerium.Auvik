---
document type: cmdlet
external help file: Celerium.Auvik-Help.xml
grand_parent: Internal
HelpUri: https://celerium.github.io/Celerium.Auvik/site/Internal/ConvertTo-AuvikQueryString.html
Locale: en-US
Module Name: Celerium.Auvik
parent: GET
PlatyPS schema version: 2024-05-01
title: ConvertTo-AuvikQueryString
---

# ConvertTo-AuvikQueryString

## SYNOPSIS

Converts uri filter parameters

## SYNTAX

### Convert (Default)

```
ConvertTo-AuvikQueryString [[-UriFilter] <hashtable>] [-ResourceUri] <string>
```

## ALIASES

This cmdlet has the following aliases,
  - None

## DESCRIPTION

The ConvertTo-AuvikQueryString cmdlet converts & formats uri filter parameters
from a function which are later used to make the full resource uri for
an API call

This is an internal helper function that ties in directly with the
Invoke-AuvikRequest function & any public functions that define parameters

The following values are converted to the format the Auvik API expects:
    - Arrays are sent as a comma delimited list
    - Booleans are sent as true or false
    - Dates are sent in UTC as YYYY-MM-DDTHH:MM:SS.sssZ (fromDate & thruDate as YYYY-MM-DD)

## EXAMPLES

### EXAMPLE 1

```powershell
ConvertTo-AuvikQueryString -UriFilter $UriFilter -ResourceUri '/inventory/device/info'
```

Example:
    $UriFilter = @{ 'filter[deviceType]' = 'router'; 'page[first]' = 10 }

    https://auvikapi.us1.my.auvik.com/v1/inventory/device/info?filter%5bdeviceType%5d=router&page%5bfirst%5d=10

## PARAMETERS

### -ResourceUri

Defines the short resource uri (url) to use when creating the API call

```yaml
Type: System.String
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

### -UriFilter

Hashtable of values to combine a functions parameters with
the ResourceUri parameter

This allows for the full uri query to occur

```yaml
Type: System.Collections.Hashtable
DefaultValue: ''
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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Collections.Hashtable

{{ Fill in the Description }}

## OUTPUTS

## NOTES

N\A


## RELATED LINKS

- [](https://celerium.github.io/Celerium.Auvik/site/Internal/ConvertTo-AuvikQueryString.html)
