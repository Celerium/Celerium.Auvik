---
document type: cmdlet
external help file: Celerium.Auvik-Help.xml
grand_parent: Internal
HelpUri: https://celerium.github.io/Celerium.Auvik/site/Internal/Get-AuvikAPIKey.html
Locale: en-US
Module Name: Celerium.Auvik
parent: GET
PlatyPS schema version: 2024-05-01
title: Get-AuvikAPIKey
---

# Get-AuvikAPIKey

## SYNOPSIS

Gets the Auvik API username & API key global variables

## SYNTAX

### Index (Default)

```
Get-AuvikAPIKey [-AsPlainText]
```

## ALIASES

This cmdlet has the following aliases,
  - None

## DESCRIPTION

The Get-AuvikAPIKey cmdlet gets the Auvik API username & API key
global variables and returns them as an object

## EXAMPLES

### EXAMPLE 1

```powershell
Get-AuvikAPIKey
```

Gets the Auvik API username & API key global variables and returns them as an object
with the secret key as a SecureString

### EXAMPLE 2

```powershell
Get-AuvikAPIKey -AsPlainText
```

Gets the Auvik API username & API key global variables and returns them as an object
with the secret key as plain text

## PARAMETERS

### -AsPlainText

Decrypt and return the API key in plain text

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

N\A


## RELATED LINKS

- [](https://celerium.github.io/Celerium.Auvik/site/Internal/Get-AuvikAPIKey.html)
