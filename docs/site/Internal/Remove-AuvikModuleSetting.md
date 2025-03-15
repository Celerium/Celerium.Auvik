---
external help file: Celerium.Auvik-help.xml
grand_parent: Internal
Module Name: Celerium.Auvik
online version: https://celerium.github.io/Celerium.Auvik/site/Internal/Remove-AuvikModuleSetting.html
parent: DELETE
schema: 2.0.0
title: Remove-AuvikModuleSetting
---

# Remove-AuvikModuleSetting

## SYNOPSIS
Removes the stored Auvik configuration folder

## SYNTAX

```powershell
Remove-AuvikModuleSetting [-AuvikConfigPath <String>] [-AndVariables] [-WhatIf] [-Confirm] [<CommonParameters>]
```

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

### -AuvikConfigPath
Define the location of the Auvik configuration folder

By default the configuration folder is located at:
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

### -AndVariables
Define if sensitive Auvik variables should be removed as well

By default the variables are not removed

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
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

[https://celerium.github.io/Celerium.Auvik/site/Internal/Remove-AuvikModuleSetting.html](https://celerium.github.io/Celerium.Auvik/site/Internal/Remove-AuvikModuleSetting.html)

