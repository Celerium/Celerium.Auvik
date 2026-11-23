---
document type: cmdlet
external help file: Celerium.Auvik-Help.xml
grand_parent: Billing
HelpUri: https://celerium.github.io/Celerium.Auvik/site/Billing/Get-AuvikBillingUsageClient.html
Locale: en-US
Module Name: Celerium.Auvik
parent: GET
PlatyPS schema version: 2024-05-01
title: Get-AuvikBillingUsageClient
---

# Get-AuvikBillingUsageClient

## SYNOPSIS

Read Client Usage

## SYNTAX

### __AllParameterSets

```
Get-AuvikBillingUsageClient [-FilterFromDate] <datetime> [-FilterThruDate] <datetime>
 [[-Tenants] <string[]>]
```

## ALIASES

This cmdlet has the following aliases,
  - Get-AuvikBilling

## DESCRIPTION

The Get-AuvikBillingUsageClient cmdlet invokes the GET method of the /billing/usage/client endpoint (Read Client Usage)

Use the Read Client Usage API to pull a summary of a client's (and client's children if a multi-client) usage for a given time range.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-AuvikBillingUsageClient -FilterFromDate '2025-01-01T00:00:00Z' -FilterThruDate '2025-01-01T00:00:00Z'
```

Returns the result of the /billing/usage/client endpoint

### EXAMPLE 2

```powershell
Get-AuvikBillingUsageClient -FilterFromDate '2025-01-01T00:00:00Z' -FilterThruDate '2025-01-01T00:00:00Z' -Tenants '1234567890'
```

Returns the result of the /billing/usage/client endpoint limited to the defined tenant

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
  Position: 0
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
  Position: 1
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Tenants

Comma delimited list of tenant IDs to request info from.

Accepts multiple values which are sent to the API as a comma delimited list

```yaml
Type: System.String[]
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

### System.Management.Automation.PSCustomObject

{{ Fill in the Description }}

## NOTES

Endpoint : GET /billing/usage/client
The Auvik API user needs the role permissions that are required by the endpoint


## RELATED LINKS

- [](https://celerium.github.io/Celerium.Auvik/site/Billing/Get-AuvikBillingUsageClient.html)
