---
document type: cmdlet
external help file: Celerium.Auvik-Help.xml
grand_parent: Internal
HelpUri: https://celerium.github.io/Celerium.Auvik/site/Internal/Import-AuvikModuleSetting.html
Locale: en-US
Module Name: Celerium.Auvik
parent: GET
PlatyPS schema version: 2024-05-01
title: Import-AuvikModuleSetting
---

# Import-AuvikModuleSetting

## SYNOPSIS

Imports the Auvik BaseURI, API, & JSON configuration information to the current session

## SYNTAX

### Set (Default)

```
Import-AuvikModuleSetting [-AuvikConfigPath <string>] [-AuvikConfigFile <string>]
```

## ALIASES

This cmdlet has the following aliases,
  - None

## DESCRIPTION

The Import-AuvikModuleSetting cmdlet imports the Auvik BaseURI, API, & JSON configuration
information stored in the Auvik configuration file to the users current session

By default the configuration file is stored in the following location:
    Windows: $env:USERPROFILE\Celerium.Auvik
    Linux & macOS: $HOME/.Celerium.Auvik

The following environment variables take priority over the configuration file which allows
automation such as GitHub workflows to configure the module without a configuration file:
    AUVIK_BASE_URI  - The base URI of the API, such as https://auvikapi.us1.my.auvik.com/v1
    AUVIK_USERNAME  - The API username
    AUVIK_API_KEY   - The API key

## EXAMPLES

### EXAMPLE 1

```powershell
Import-AuvikModuleSetting
```

Validates that the configuration file created with the Export-AuvikModuleSetting cmdlet exists
then imports the stored data into the current users session

The default location of the Auvik configuration file is:
    $env:USERPROFILE\Celerium.Auvik\config.psd1

### EXAMPLE 2

```powershell
Import-AuvikModuleSetting -AuvikConfigPath C:\Celerium.Auvik -AuvikConfigFile MyConfig.psd1
```

Validates that the configuration file created with the Export-AuvikModuleSetting cmdlet exists
then imports the stored data into the current users session

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

- [](https://celerium.github.io/Celerium.Auvik/site/Internal/Import-AuvikModuleSetting.html)
