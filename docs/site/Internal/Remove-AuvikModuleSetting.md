---
document type: cmdlet
external help file: Celerium.Auvik-Help.xml
grand_parent: Internal
HelpUri: https://celerium.github.io/Celerium.Auvik/site/Internal/Remove-AuvikModuleSetting.html
Locale: en-US
Module Name: Celerium.Auvik
parent: DELETE
PlatyPS schema version: 2024-05-01
title: Remove-AuvikModuleSetting
---

# Remove-AuvikModuleSetting

## SYNOPSIS

Removes the stored Auvik configuration folder

## SYNTAX

### Destroy (Default)

```
Remove-AuvikModuleSetting [-AuvikConfigPath <string>] [-AndVariables] [-WhatIf] [-Confirm]
```

## ALIASES

This cmdlet has the following aliases,
  - None

## DESCRIPTION

The Remove-AuvikModuleSetting cmdlet removes the Auvik folder and its files
This cmdlet also has the option to remove sensitive Auvik variables as well

By default configuration files are stored in the following location and will be removed:
    $env:USERPROFILE\Celerium.Auvik

## EXAMPLES

### EXAMPLE 1

```powershell
Remove-AuvikModuleSetting
```

Checks to see if the default configuration folder exists and removes it if it does

The default location of the Auvik configuration folder is:
    $env:USERPROFILE\Celerium.Auvik

### EXAMPLE 2

```powershell
Remove-AuvikModuleSetting -AuvikConfigPath C:\Celerium.Auvik -AndVariables
```

Checks to see if the defined configuration folder exists and removes it if it does
If sensitive Auvik variables exist then they are removed as well

The location of the Auvik configuration folder in this example is:
    C:\Celerium.Auvik

## PARAMETERS

### -AndVariables

Define if sensitive Auvik variables should be removed as well

By default the variables are not removed

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Destroy
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -AuvikConfigPath

Define the location of the Auvik configuration folder

By default the configuration folder is located at:
    $env:USERPROFILE\Celerium.Auvik

```yaml
Type: System.String
DefaultValue: $(Join-Path -Path $home -ChildPath $(if ($IsWindows -or $PSEdition -eq 'Desktop') {"Celerium.Auvik"}else{".Celerium.Auvik"}) )
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Destroy
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: ''
SupportsWildcards: false
Aliases:
- cf
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

### -WhatIf

Runs the command in a mode that only reports what would happen without performing the actions.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: ''
SupportsWildcards: false
Aliases:
- wi
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

- [](https://celerium.github.io/Celerium.Auvik/site/Internal/Remove-AuvikModuleSetting.html)
