---
external help file: Celerium.Auvik-help.xml
grand_parent: Alert
Module Name: Celerium.Auvik
online version: https://celerium.github.io/Celerium.Auvik/site/Alert/Clear-AuvikAlert.html
parent: POST
schema: 2.0.0
title: Clear-AuvikAlert
---

# Clear-AuvikAlert

## SYNOPSIS
Clear an Auvik alert

## SYNTAX

```powershell
Clear-AuvikAlert [-ID] <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Clear-AuvikAlert cmdlet allows you to dismiss an
alert that Auvik has triggered

## EXAMPLES

### EXAMPLE 1
```powershell
Clear-AuvikAlert -ID 123456789
```

Clears the defined alert

## PARAMETERS

### -ID
ID of alert

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
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

[https://celerium.github.io/Celerium.Auvik/site/Alert/Clear-AuvikAlert.html](https://celerium.github.io/Celerium.Auvik/site/Alert/Clear-AuvikAlert.html)

