---
document type: cmdlet
external help file: Celerium.Auvik-Help.xml
grand_parent: Internal
HelpUri: https://celerium.github.io/Celerium.Auvik/site/Internal/Add-AuvikAPIKey.html
Locale: en-US
Module Name: Celerium.Auvik
parent: PUT
PlatyPS schema version: 2024-05-01
title: Add-AuvikAPIKey
---

# Add-AuvikAPIKey

## SYNOPSIS

Sets the API username and API key used to authenticate API calls

## SYNTAX

### AsPlainText (Default)

```
Add-AuvikAPIKey -Username <string> [-ApiKey <string>]
```

### SecureString

```
Add-AuvikAPIKey -Username <string> [-ApiKeySecureString <securestring>]
```

## ALIASES

This cmdlet has the following aliases,
  - Set-AuvikAPIKey

## DESCRIPTION

The Add-AuvikAPIKey cmdlet sets the API username and API key used to
authenticate all API calls made to Auvik

The Auvik API username & API keys are generated via the Auvik portal at Admin > Integrations

The Auvik API uses basic authentication where the username is the email address of the
Auvik user & the password is the API key

## EXAMPLES

### EXAMPLE 1

```powershell
Add-AuvikAPIKey -Username 'Celerium@Celerium.org'
```

The Auvik API will use the string entered into the [ -Username ] parameter as the
username & will then prompt to enter in the API key

### EXAMPLE 2

```powershell
Add-AuvikAPIKey -Username 'Celerium@Celerium.org' -ApiKey '12345'
```

The Auvik API will use the strings entered into the [ -Username ] & [ -ApiKey ] parameters
to authenticate

### EXAMPLE 3

```powershell
Add-AuvikAPIKey -Username 'Celerium@Celerium.org' -ApiKeySecureString (Read-Host -AsSecureString)
```

The Auvik API will use the string entered into the [ -Username ] parameter as the
username & the SecureString as the API key

## PARAMETERS

### -ApiKey

Plain text API key

If not defined the cmdlet will prompt you to enter the API key which
will be stored as a SecureString

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: AsPlainText
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ApiKeySecureString

Input a SecureString object containing the API key

```yaml
Type: System.Security.SecureString
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: SecureString
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Username

Defines your API username

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: SecureString
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: AsPlainText
  Position: Named
  IsRequired: true
  ValueFromPipeline: true
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

### System.String

{{ Fill in the Description }}

## OUTPUTS

## NOTES

N\A


## RELATED LINKS

- [](https://celerium.github.io/Celerium.Auvik/site/Internal/Add-AuvikAPIKey.html)
