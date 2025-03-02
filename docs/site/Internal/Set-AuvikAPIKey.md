---
external help file: Celerium.Auvik-help.xml
grand_parent: Internal
Module Name: Celerium.Auvik
online version: https://celerium.github.io/Celerium.Auvik/site/Internal/Set-AuvikAPIKey.html
parent: POST
schema: 2.0.0
title: Set-AuvikAPIKey
---

# Set-AuvikAPIKey

## SYNOPSIS
Sets the API username and API key used to authenticate API calls

## SYNTAX

## DESCRIPTION
The Add-AuvikAPIKey cmdlet sets the API username and API key used to
authenticate all API calls made to Auvik

The Auvik API username & API keys are generated via the Auvik portal at Admin \> Integrations

## EXAMPLES

### EXAMPLE 1
```powershell
Add-AuvikAPIKey -Username 'Celerium@Celerium.org'
```

The Auvik API will use the string entered into the \[ -Username \] parameter as the
username & will then prompt to enter in the secret key

### EXAMPLE 2
```
'Celerium@Celerium.org' | Add-AuvikAPIKey
```

The Auvik API will use the string entered as the secret key & will prompt to enter in the public key

### EXAMPLE 3
```powershell
Add-AuvikAPIKey -EncryptedStandardAPIKeyFilePath 'C:\path\to\encrypted\key.txt' -EncryptedStandardAESKeyPath 'C:\path\to\decipher\key.txt'
```

Decrypts the AES API key and stores it in the global variable

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
N\A

## RELATED LINKS

[https://celerium.github.io/Celerium.Auvik/site/Internal/Add-AuvikAPIKey.html](https://celerium.github.io/Celerium.Auvik/site/Internal/Add-AuvikAPIKey.html)

