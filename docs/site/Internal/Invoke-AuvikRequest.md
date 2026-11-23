---
document type: cmdlet
external help file: Celerium.Auvik-Help.xml
grand_parent: Internal
HelpUri: https://celerium.github.io/Celerium.Auvik/site/Internal/Invoke-AuvikRequest.html
Locale: en-US
Module Name: Celerium.Auvik
parent: GET
PlatyPS schema version: 2024-05-01
title: Invoke-AuvikRequest
---

# Invoke-AuvikRequest

## SYNOPSIS

Makes an API request

## SYNTAX

### __AllParameterSets

```
Invoke-AuvikRequest [[-Method] <string>] [-ResourceUri] <string> [[-UriFilter] <hashtable>]
 [[-Data] <hashtable>] [[-MaxRetry] <int>] [[-RetryDelaySeconds] <int>] [-AllResults]
```

## ALIASES

This cmdlet has the following aliases,
  - None

## DESCRIPTION

The Invoke-AuvikRequest cmdlet invokes an API request to the Auvik API

This is an internal function that is used by all public functions

As of 2025 the Auvik v1 API supports GET requests & a single POST request (dismissing an alert)

Requests that are rate limited (429) or fail with a temporary server error (500, 502, 503, 504)
are retried with an exponential back off

## EXAMPLES

### EXAMPLE 1

```powershell
Invoke-AuvikRequest -Method GET -ResourceUri '/inventory/device/info' -UriFilter $UriFilter
```

Invoke a rest method against the defined resource using any of the provided parameters

Example:
    Name                           Value
    ----                           -----
    Method                         GET
    Uri                            https://auvikapi.us1.my.auvik.com/v1/inventory/device/info?page%5bfirst%5d=10
    Headers                        {Authorization = Basic 123456789}
    Body

## PARAMETERS

### -AllResults

Returns all items from an endpoint by following the pagination links

When using this parameter there is no need to use either the PageFirst, PageAfter,
PageLast, or PageBefore parameters

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Data

Place holder parameter to use when other methods are supported
by the Auvik v1 API

```yaml
Type: System.Collections.Hashtable
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 3
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -MaxRetry

The number of times a rate limited or temporarily failed request is retried

Only GET requests are retried, write requests are never retried

Default value: 3

```yaml
Type: System.Int32
DefaultValue: 3
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 4
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Method

Defines the type of API method to use

Allowed values:
'GET', 'POST'

```yaml
Type: System.String
DefaultValue: GET
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ResourceUri

Defines the resource uri (url) to use when creating the API call

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

### -RetryDelaySeconds

The number of seconds to wait before the first retry.
The wait doubles with each retry

Default value: 2

```yaml
Type: System.Int32
DefaultValue: 2
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 5
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -UriFilter

Used with the internal function [ ConvertTo-AuvikQueryString ] to combine
a functions parameters with the ResourceUri parameter

This allows for the full uri query to occur

The full resource path is made with the following data
$AuvikModuleBaseURI + $ResourceUri + ConvertTo-AuvikQueryString

```yaml
Type: System.Collections.Hashtable
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 2
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

## OUTPUTS

## NOTES

The [ Invoke_AuvikRequest_Parameters ] style variables of earlier versions are now named
[ InvokeAuvikRequestParameters ] & [ InvokeAuvikRequestParametersQuery ].
The Authorization header
stored in them is always masked


## RELATED LINKS

- [](https://celerium.github.io/Celerium.Auvik/site/Internal/Invoke-AuvikRequest.html)
