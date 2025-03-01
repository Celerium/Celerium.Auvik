---
external help file: Celerium.Auvik-help.xml
grand_parent: internal
Module Name: Celerium.Auvik
online version: https://celerium.github.io/Celerium.Auvik/site/internal/Set-AuvikAPIKey.html
parent: POST
schema: 2.0.0
title: Set-AuvikAPIKey
---

# Set-AuvikAPIKey

## SYNOPSIS
Creates a AES encrypted API key and decipher key

## SYNTAX

## DESCRIPTION
The New-AuvikAESSecret cmdlet creates a AES encrypted API key and decipher key

This allows the key to be exported for use on other systems without
relying on Windows DPAPI

Do NOT share the decipher key with anyone as this will allow them to decrypt
the encrypted API key

## EXAMPLES

### EXAMPLE 1
```powershell
New-AuvikAESSecret
```

Prompts to enter in the API key which will be encrypted using a randomly generated 256-bit AES key

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
N/A

## RELATED LINKS

[https://celerium.github.io/Celerium.Auvik/site/Internal/New-AuvikAESSecret.html](https://celerium.github.io/Celerium.Auvik/site/Internal/New-AuvikAESSecret.html)

[https://github.com/Celerium/Celerium.Auvik](https://github.com/Celerium/Celerium.Auvik)

