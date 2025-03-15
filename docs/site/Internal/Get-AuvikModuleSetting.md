---
external help file: Celerium.Auvik-help.xml
grand_parent: Internal
Module Name: Celerium.Auvik
online version: https://celerium.github.io/Celerium.Auvik/site/Internal/Get-AuvikModuleSetting.html
parent: GET
schema: 2.0.0
title: Get-AuvikModuleSetting
---

# Get-AuvikModuleSetting

## SYNOPSIS
Gets the saved Auvik configuration settings

## SYNTAX

### Index (Default)
```powershell
Get-AuvikModuleSetting [-AuvikConfigPath <String>] [-AuvikConfigFile <String>] [<CommonParameters>]
```

### show
```powershell
Get-AuvikModuleSetting [-OpenConfigFile] [<CommonParameters>]
```

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

### -AuvikConfigPath
Define the location to store the Auvik configuration file

By default the configuration file is stored in the following location:
    $env:USERPROFILE\Celerium.Auvik

```yaml
Type: String
Parameter Sets: Index
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
Parameter Sets: Index
Aliases:

Required: False
Position: Named
Default value: Config.psd1
Accept pipeline input: False
Accept wildcard characters: False
```

### -OpenConfigFile
Opens the Auvik configuration file

```yaml
Type: SwitchParameter
Parameter Sets: show
Aliases:

Required: False
Position: Named
Default value: False
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

[https://celerium.github.io/Celerium.Auvik/site/Internal/Get-AuvikModuleSetting.html](https://celerium.github.io/Celerium.Auvik/site/Internal/Get-AuvikModuleSetting.html)

