---
external help file: Celerium.Auvik-help.xml
grand_parent: internal
Module Name: Celerium.Auvik
online version: https://celerium.github.io/Celerium.Auvik/site/internal/Export-AuvikModuleSetting.html
parent: GET
schema: 2.0.0
title: Export-AuvikModuleSetting
---

# Export-AuvikModuleSetting

## SYNOPSIS
Exports the Auvik BaseURI, API, & JSON configuration information to file.

## SYNTAX

```powershell
Export-AuvikModuleSetting [-AuvikConfPath <String>] [-AuvikConfFile <String>] [<CommonParameters>]
```

## DESCRIPTION
The Export-AuvikModuleSetting cmdlet exports the Auvik BaseURI, API, & JSON configuration information to file.

Making use of PowerShell's System.Security.SecureString type, exporting module settings encrypts your API key in a format
that can only be unencrypted with the your Windows account as this encryption is tied to your user principal.
This means that you cannot copy your configuration file to another computer or user account and expect it to work.

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
Export-AuvikModuleSetting -AuvikConfPath C:\Celerium.Auvik -AuvikConfFile MyConfig.psd1
```

Validates that the BaseURI, API, and JSON depth are set then exports their values
to the current user's Auvik configuration file located at:
    C:\Celerium.Auvik\MyConfig.psd1

## PARAMETERS

### -AuvikConfPath
Define the location to store the Auvik configuration file.

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

### -AuvikConfFile
Define the name of the Auvik configuration file.

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

[https://celerium.github.io/Celerium.Auvik/site/Internal/Export-AuvikModuleSetting.html](https://celerium.github.io/Celerium.Auvik/site/Internal/Export-AuvikModuleSetting.html)

