---
document type: cmdlet
external help file: Celerium.Auvik-Help.xml
grand_parent: Internal
HelpUri: https://celerium.github.io/Celerium.Auvik/site/Internal/Initialize-AuvikModuleSetting.html
Locale: en-US
Module Name: Celerium.Auvik
parent: PUT
PlatyPS schema version: 2024-05-01
title: Initialize-AuvikModuleSetting
---

# Initialize-AuvikModuleSetting

## SYNOPSIS

Loads the Auvik module settings when the module is imported

## SYNTAX

### __AllParameterSets

```
Initialize-AuvikModuleSetting
```

## ALIASES

This cmdlet has the following aliases,
  - None

## DESCRIPTION

The Initialize-AuvikModuleSetting cmdlet loads either the baseline settings or the saved
configuration (and the AUVIK_* environment variables) by calling Import-AuvikModuleSetting

This function is called automatically when the module is imported

## EXAMPLES

### EXAMPLE 1

```powershell
Initialize-AuvikModuleSetting
```

Loads the saved Auvik settings into the current session

## PARAMETERS

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

- [](https://celerium.github.io/Celerium.Auvik/site/Internal/Initialize-AuvikModuleSetting.html)
