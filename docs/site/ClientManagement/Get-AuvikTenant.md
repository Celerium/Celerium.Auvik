---
document type: cmdlet
external help file: Celerium.Auvik-Help.xml
grand_parent: ClientManagement
HelpUri: https://celerium.github.io/Celerium.Auvik/site/ClientManagement/Get-AuvikTenant.html
Locale: en-US
Module Name: Celerium.Auvik
parent: GET
PlatyPS schema version: 2024-05-01
title: Get-AuvikTenant
---

# Get-AuvikTenant

## SYNOPSIS

Read Multiple Tenants

## SYNTAX

### __AllParameterSets

```
Get-AuvikTenant
```

## ALIASES

This cmdlet has the following aliases,
  - None

## DESCRIPTION

The Get-AuvikTenant cmdlet invokes the GET method of the /tenants endpoint (Read Multiple Tenants)

Use the Read Multiple Tenants API to pull access detail about multiple multi-clients and clients associated with your Auvik user account.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-AuvikTenant
```

Returns the result of the /tenants endpoint

## PARAMETERS

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

Endpoint : GET /tenants
The Auvik API user needs the role permissions that are required by the endpoint


## RELATED LINKS

- [](https://celerium.github.io/Celerium.Auvik/site/ClientManagement/Get-AuvikTenant.html)
