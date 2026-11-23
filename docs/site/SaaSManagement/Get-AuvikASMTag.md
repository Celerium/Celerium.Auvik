---
document type: cmdlet
external help file: Celerium.Auvik-Help.xml
grand_parent: SaaSManagement
HelpUri: https://celerium.github.io/Celerium.Auvik/site/SaaSManagement/Get-AuvikASMTag.html
Locale: en-US
Module Name: Celerium.Auvik
parent: GET
PlatyPS schema version: 2024-05-01
title: Get-AuvikASMTag
---

# Get-AuvikASMTag

## SYNOPSIS

Read Multiple ASM Tags' Info

## SYNTAX

### __AllParameterSets

```
Get-AuvikASMTag [-FilterClientId] <string> [[-FilterApplicationId] <string>] [[-PageFirst] <long>]
 [[-PageAfter] <string>] [[-PageLast] <long>] [[-PageBefore] <string>] [-AllResults]
```

## ALIASES

This cmdlet has the following aliases,
  - None

## DESCRIPTION

The Get-AuvikASMTag cmdlet invokes the GET method of the /asm/tag/info endpoint (Read Multiple ASM Tags' Info)

Use the Read Multiple ASM Tags' Info API to retrieve information about tags configured within an ASM client.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-AuvikASMTag -FilterClientId 'Example'
```

Returns the result of the /asm/tag/info endpoint

### EXAMPLE 2

```powershell
Get-AuvikASMTag -FilterClientId 'Example' -PageFirst 10
```

Returns the result of the /asm/tag/info endpoint limited to the defined number of items

### EXAMPLE 3

```powershell
Get-AuvikASMTag -FilterClientId 'Example' -AllResults
```

Returns every item from the /asm/tag/info endpoint by following the pagination links

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

Filter by application ID.

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
  Position: 3
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
  Position: 5
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
  Position: 2
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
  Position: 4
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

Endpoint : GET /asm/tag/info
The Auvik API user needs the role permissions that are required by the endpoint


## RELATED LINKS

- [](https://celerium.github.io/Celerium.Auvik/site/SaaSManagement/Get-AuvikASMTag.html)
