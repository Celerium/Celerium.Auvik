---
document type: cmdlet
external help file: Celerium.Auvik-Help.xml
grand_parent: SaaSManagement
HelpUri: https://celerium.github.io/Celerium.Auvik/site/SaaSManagement/Get-AuvikASMLicense.html
Locale: en-US
Module Name: Celerium.Auvik
parent: GET
PlatyPS schema version: 2024-05-01
title: Get-AuvikASMLicense
---

# Get-AuvikASMLicense

## SYNOPSIS

Read Multiple ASM Licenses' Info

## SYNTAX

### __AllParameterSets

```
Get-AuvikASMLicense [-FilterClientId] <string> [-FilterApplicationId] <string>
 [[-FilterEmail] <string>] [[-FilterLicenseType] <string>] [[-FilterLastLoginBefore] <datetime>]
 [[-FilterUnderutilizedOnly] <bool>] [[-PageFirst] <long>] [[-PageAfter] <string>]
 [[-PageLast] <long>] [[-PageBefore] <string>] [-AllResults]
```

## ALIASES

This cmdlet has the following aliases,
  - None

## DESCRIPTION

The Get-AuvikASMLicense cmdlet invokes the GET method of the /asm/license/info endpoint (Read Multiple ASM Licenses' Info)

Use the Read Multiple ASM Licenses' Info endpoint to retrieve information about an application licenses discovered within an ASM client deployment.
This data includes the license type and associated user email assigned to each license, alongside other key metadata such as last login time.
To access this data, a SaaS Ops integration with the desired application must be configured.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-AuvikASMLicense -FilterClientId 'Example' -FilterApplicationId 'Example'
```

Returns the result of the /asm/license/info endpoint

### EXAMPLE 2

```powershell
Get-AuvikASMLicense -FilterClientId 'Example' -FilterApplicationId 'Example' -PageFirst 10
```

Returns the result of the /asm/license/info endpoint limited to the defined number of items

### EXAMPLE 3

```powershell
Get-AuvikASMLicense -FilterClientId 'Example' -FilterApplicationId 'Example' -AllResults
```

Returns every item from the /asm/license/info endpoint by following the pagination links

## PARAMETERS

### -AllResults

Returns all items from the endpoint by following the pagination links

When using this parameter there is no need to use the PageFirst, PageAfter, PageLast, or PageBefore parameters

Highly recommended to only use with filters to reduce API errors & timeouts

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

### -FilterApplicationId

Unique identifier of the application.

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

### -FilterClientId

Filter by client ID.

```yaml
Type: System.String
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

### -FilterEmail

Filter results by a specific license email.

```yaml
Type: System.String
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

### -FilterLastLoginBefore

Returns only users whose last login was before the given date or have no last login time.

Accepts a date & time which is sent to the API in UTC

```yaml
Type: System.DateTime
DefaultValue: ''
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

### -FilterLicenseType

Filter results by license type.

```yaml
Type: System.String
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

### -FilterUnderutilizedOnly

If included, filters to users flagged as underutilized.

```yaml
Type: System.Boolean
DefaultValue: False
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

### -PageAfter

Cursor after which elements will be returned as a page.
The page size is provided by page[first].

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 7
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -PageBefore

Cursor before which elements will be returned as a page.
The page size is provided by page[last].

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 9
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -PageFirst

For paginated responses, the first N elements will be returned.
Used in combination with page[after].

Default value: 100

```yaml
Type: System.Int64
DefaultValue: 0
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 6
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -PageLast

For paginated responses, the last N services will be returned.
Used in combination with page[before].

Default value: 100

```yaml
Type: System.Int64
DefaultValue: 0
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 8
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

Endpoint : GET /asm/license/info
The Auvik API user needs the role permissions that are required by the endpoint


## RELATED LINKS

- [](https://celerium.github.io/Celerium.Auvik/site/SaaSManagement/Get-AuvikASMLicense.html)
