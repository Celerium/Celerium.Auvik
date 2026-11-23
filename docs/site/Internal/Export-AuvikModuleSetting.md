---
document type: cmdlet
external help file: Celerium.Auvik-Help.xml
grand_parent: Internal
HelpUri: https://celerium.github.io/Celerium.Auvik/site/Internal/Export-AuvikModuleSetting.html
Locale: en-US
Module Name: Celerium.Auvik
parent: PUT
PlatyPS schema version: 2024-05-01
title: Export-AuvikModuleSetting
---

# Export-AuvikModuleSetting

## SYNOPSIS

Exports the Auvik BaseURI, API, & JSON configuration information to file

## SYNTAX

### Set (Default)

```
Export-AuvikModuleSetting [-AuvikConfigPath <string>] [-AuvikConfigFile <string>] [-WhatIf]
 [-Confirm]
```

## ALIASES

This cmdlet has the following aliases,
  - None

## DESCRIPTION

The Export-AuvikModuleSetting cmdlet exports the Auvik BaseURI, API, & JSON configuration information to file

Making use of PowerShell's System.Security.SecureString type, exporting module settings encrypts your API key in a format
that can only be unencrypted with the your Windows account as this encryption is tied to your user principal
This means that you cannot copy your configuration file to another computer or user account and expect it to work

## EXAMPLES

### EXAMPLE 1

```powershell
Export-AuvikModuleSetting
```

Validates that the BaseURI, API, and JSON depth are set then exports their values
to the current user's Auvik configuration file located at:
    $env:USERPROFILE\Celerium.Auvik\config.psd1

### EXAMPLE 2

```powershell
Export-AuvikModuleSetting -AuvikConfigPath C:\Celerium.Auvik -AuvikConfigFile MyConfig.psd1
```

Validates that the BaseURI, API, and JSON depth are set then exports their values
to the current user's Auvik configuration file located at:
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
- Name: Set
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
    Windows: $env:USERPROFILE\Celerium.Auvik
    Linux & macOS: $HOME/.Celerium.Auvik

```yaml
Type: System.String
DefaultValue: $(Join-Path -Path $HOME -ChildPath $(if ($IsWindows -or $PSEdition -eq 'Desktop') { 'Celerium.Auvik' } else { '.Celerium.Auvik' }) )
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Set
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

- [](https://celerium.github.io/Celerium.Auvik/site/Internal/Export-AuvikModuleSetting.html)
