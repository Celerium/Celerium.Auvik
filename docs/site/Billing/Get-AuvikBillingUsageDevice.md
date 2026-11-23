---
document type: cmdlet
external help file: Celerium.Auvik-Help.xml
grand_parent: Billing
HelpUri: https://celerium.github.io/Celerium.Auvik/site/Billing/Get-AuvikBillingUsageDevice.html
Locale: en-US
Module Name: Celerium.Auvik
parent: GET
PlatyPS schema version: 2024-05-01
title: Get-AuvikBillingUsageDevice
---

# Get-AuvikBillingUsageDevice

## SYNOPSIS

Read Device Usage

## SYNTAX

### __AllParameterSets

```
Get-AuvikBillingUsageDevice [-Id] <string> -FilterFromDate <datetime> -FilterThruDate <datetime>
```

## ALIASES

This cmdlet has the following aliases,
  - None

## DESCRIPTION

The Get-AuvikBillingUsageDevice cmdlet invokes the GET method of the /billing/usage/device/{id} endpoint (Read Device Usage)

Use the Read Device Usage API to pull a summary of a client's (and client's children if a multi-client) usage for a given time range.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-AuvikBillingUsageDevice -Id '1234567890' -FilterFromDate '2025-01-01T00:00:00Z' -FilterThruDate '2025-01-01T00:00:00Z'
```

Returns the result of the /billing/usage/device/{id} endpoint

## PARAMETERS

### -FilterFromDate

Date from which you want to query

Accepts a date & time which is sent to the API in UTC

```yaml
Type: System.DateTime
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -FilterThruDate

Date to which you want to query

Accepts a date & time which is sent to the API in UTC

```yaml
Type: System.DateTime
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Id

ID of device

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: true
  ValueFromPipeline: true
  ValueFromPipelineByPropertyName: true
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

### System.Management.Automation.PSCustomObject

{{ Fill in the Description }}

## NOTES

Endpoint : GET /billing/usage/device/{id}
The Auvik API user needs the role permissions that are required by the endpoint


## RELATED LINKS

- [](https://celerium.github.io/Celerium.Auvik/site/Billing/Get-AuvikBillingUsageDevice.html)
