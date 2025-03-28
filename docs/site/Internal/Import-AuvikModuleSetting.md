---
external help file: Celerium.Auvik-help.xml
grand_parent: Internal
Module Name: Celerium.Auvik
online version: https://celerium.github.io/Celerium.Auvik/site/Internal/Import-AuvikModuleSetting.html
parent: GET
schema: 2.0.0
title: Import-AuvikModuleSetting
---

# Import-AuvikModuleSetting

## SYNOPSIS
Imports the Auvik BaseURI, API, & JSON configuration information to the current session

## SYNTAX

```powershell
Import-AuvikModuleSetting [-AuvikConfigPath <String>] [-AuvikConfigFile <String>] [<CommonParameters>]
```

## DESCRIPTION
The Import-AuvikModuleSetting cmdlet imports the Auvik BaseURI, API, & JSON configuration
information stored in the Auvik configuration file to the users current session

By default the configuration file is stored in the following location:
    $env:USERPROFILE\Celerium.Auvik

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

### -AuvikConfigPath
Define the location to store the Auvik configuration file

By default the configuration file is stored in the following location:
    $env:USERPROFILE\Celerium.Auvik

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: $(Join-Path -Path $home -ChildPath $(if ($IsWindows -or $PSEdition -eq 'Desktop') {"Celerium.Auvik"}else{".Celerium.Auvik"}) )
Accept pipeline input: False
Accept wildcard characters: False
```

### -AuvikConfigFile
Define the name of the Auvik configuration file

By default the configuration file is named:
    config.psd1

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Config.psd1
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
N\A

## RELATED LINKS

[https://celerium.github.io/Celerium.Auvik/site/Internal/Import-AuvikModuleSetting.html](https://celerium.github.io/Celerium.Auvik/site/Internal/Import-AuvikModuleSetting.html)

