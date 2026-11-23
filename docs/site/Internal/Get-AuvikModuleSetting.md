---
document type: cmdlet
external help file: Celerium.Auvik-Help.xml
grand_parent: Internal
HelpUri: https://celerium.github.io/Celerium.Auvik/site/Internal/Get-AuvikModuleSetting.html
Locale: en-US
Module Name: Celerium.Auvik
parent: GET
PlatyPS schema version: 2024-05-01
title: Get-AuvikModuleSetting
---

# Get-AuvikModuleSetting

## SYNOPSIS

Gets the saved Auvik configuration settings

## SYNTAX

### Index (Default)

```
Get-AuvikModuleSetting [-AuvikConfigPath <string>] [-AuvikConfigFile <string>]
```

### show

```
Get-AuvikModuleSetting [-OpenConfigFile]
```

## ALIASES

This cmdlet has the following aliases,
  - None

## DESCRIPTION

The Get-AuvikModuleSetting cmdlet gets the saved Auvik configuration settings
from the local system

By default the configuration file is stored in the following location:
    $env:USERPROFILE\Celerium.Auvik

## EXAMPLES

### EXAMPLE 1

```powershell
Get-AuvikModuleSetting
```

Gets the contents of the configuration file that was created with the
Export-AuvikModuleSetting

The default location of the Auvik configuration file is:
    $env:USERPROFILE\Celerium.Auvik\config.psd1

### EXAMPLE 2

```powershell
Get-AuvikModuleSetting -AuvikConfigPath C:\Celerium.Auvik -AuvikConfigFile MyConfig.psd1 -OpenConfigFile
```

Opens the configuration file from the defined location in the default editor

The location of the Auvik configuration file in this example is:
    C:\Celerium.Auvik\MyConfig.psd1

## PARAMETERS

### -AuvikConfigFile

Define the name of the Auvik configuration file

By default the configuration file is named:
    config.psd1

```yaml
Type: System.String
DefaultValue: config.psd1
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Index
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

Define the location to store the Auvik configuration file

By default the configuration file is stored in the following location:
    $env:USERPROFILE\Celerium.Auvik

```yaml
Type: System.String
DefaultValue: $(Join-Path -Path $home -ChildPath $(if ($IsWindows -or $PSEdition -eq 'Desktop') {"Celerium.Auvik"}else{".Celerium.Auvik"}) )
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Index
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -OpenConfigFile

Opens the Auvik configuration file

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: show
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

- [](https://celerium.github.io/Celerium.Auvik/site/Internal/Get-AuvikModuleSetting.html)
