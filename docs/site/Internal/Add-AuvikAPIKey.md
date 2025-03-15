---
external help file: Celerium.Auvik-help.xml
grand_parent: Internal
Module Name: Celerium.Auvik
online version: https://celerium.github.io/Celerium.Auvik/site/Internal/Add-AuvikAPIKey.html
parent: POST
schema: 2.0.0
title: Add-AuvikAPIKey
---

# Add-AuvikAPIKey

## SYNOPSIS
Sets the API username and API key used to authenticate API calls

## SYNTAX

### AsPlainText (Default)
```powershell
Add-AuvikAPIKey -Username <String> [-ApiKey <String>] [<CommonParameters>]
```

### SecureString
```powershell
Add-AuvikAPIKey -Username <String> [-ApiKeySecureString <SecureString>] [<CommonParameters>]
```

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

### -Username
Defines your API username

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ApiKey
Plain text API key

If not defined the cmdlet will prompt you to enter the API key which
will be stored as a SecureString

```yaml
Type: String
Parameter Sets: AsPlainText
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ApiKeySecureString
Input a SecureString object containing the API key

```yaml
Type: SecureString
Parameter Sets: SecureString
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
N\A

## RELATED LINKS

[https://celerium.github.io/Celerium.Auvik/site/Internal/Add-AuvikAPIKey.html](https://celerium.github.io/Celerium.Auvik/site/Internal/Add-AuvikAPIKey.html)

