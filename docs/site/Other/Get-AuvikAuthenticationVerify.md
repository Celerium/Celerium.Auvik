---
document type: cmdlet
external help file: Celerium.Auvik-Help.xml
grand_parent: Other
HelpUri: https://celerium.github.io/Celerium.Auvik/site/Other/Get-AuvikAuthenticationVerify.html
Locale: en-US
Module Name: Celerium.Auvik
parent: GET
PlatyPS schema version: 2024-05-01
title: Get-AuvikAuthenticationVerify
---

# Get-AuvikAuthenticationVerify

## SYNOPSIS

Verify Credentials

## SYNTAX

### __AllParameterSets

```
Get-AuvikAuthenticationVerify
```

## ALIASES

This cmdlet has the following aliases,
  - Test-AuvikAPICredential

## DESCRIPTION

The Get-AuvikAuthenticationVerify cmdlet invokes the GET method of the /authentication/verify endpoint (Verify Credentials)

Use the Verify Credentials API to verify your credentials are correct before making a call to an endpoint.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-AuvikAuthenticationVerify
```

Returns the result of the /authentication/verify endpoint

## PARAMETERS

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Boolean

{{ Fill in the Description }}

## NOTES

Endpoint : GET /authentication/verify
The Auvik API user needs the role permissions that are required by the endpoint

This function returns $true when the credentials are valid & $false when they are not


## RELATED LINKS

- [](https://celerium.github.io/Celerium.Auvik/site/Other/Get-AuvikAuthenticationVerify.html)
