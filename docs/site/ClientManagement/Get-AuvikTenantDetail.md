---
document type: cmdlet
external help file: Celerium.Auvik-Help.xml
grand_parent: ClientManagement
HelpUri: https://celerium.github.io/Celerium.Auvik/site/ClientManagement/Get-AuvikTenantDetail.html
Locale: en-US
Module Name: Celerium.Auvik
parent: GET
PlatyPS schema version: 2024-05-01
title: Get-AuvikTenantDetail
---

# Get-AuvikTenantDetail

## SYNOPSIS

Read Multiple Tenants Detail / Read Single Tenant Detail

## SYNTAX

### List (Default)

```
Get-AuvikTenantDetail -TenantDomainPrefix <string> [-FilterAvailableTenants <bool>]
```

### ById

```
Get-AuvikTenantDetail [-Id] <string> -TenantDomainPrefix <string>
```

## ALIASES

This cmdlet has the following aliases,
  - None

## DESCRIPTION

Parameter set [ List ] - The Get-AuvikTenantDetail cmdlet invokes the GET method of the /tenants/detail endpoint (Read Multiple Tenants Detail)

Use the Read Multiple Tenants API to pull details for multiple multi-clients and clients associated with your main Auvik account.

Parameter set [ ById ] - The Get-AuvikTenantDetail cmdlet invokes the GET method of the /tenants/detail/{id} endpoint (Read Single Tenant Detail)

Use the Read a Single Tenant API to pull detail about a specific multi-client and client associated with your main Auvik account.
You'll need the tenant ID for the specific multi-client or client you want detail for.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-AuvikTenantDetail -TenantDomainPrefix 'celerium'
```

Returns the result of the /tenants/detail endpoint

### EXAMPLE 2

```powershell
Get-AuvikTenantDetail -Id '1234567890' -TenantDomainPrefix 'celerium'
```

Returns the result of the /tenants/detail/{id} endpoint

## PARAMETERS

### -FilterAvailableTenants

Filter whether or not a tenant is available, i.e.
data can be gotten from them via the API.

```yaml
Type: System.Boolean
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: List
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Id

ID of tenant

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ById
  Position: 0
  IsRequired: true
  ValueFromPipeline: true
  ValueFromPipelineByPropertyName: true
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -TenantDomainPrefix

Domain prefix of your main Auvik account (tenant).

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: List
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ById
  Position: Named
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

### System.String

{{ Fill in the Description }}

## OUTPUTS

### System.Management.Automation.PSCustomObject

{{ Fill in the Description }}

## NOTES

Endpoint : GET /tenants/detail
Endpoint : GET /tenants/detail/{id}
The Auvik API user needs the role permissions that are required by the endpoint


## RELATED LINKS

- [](https://celerium.github.io/Celerium.Auvik/site/ClientManagement/Get-AuvikTenantDetail.html)
