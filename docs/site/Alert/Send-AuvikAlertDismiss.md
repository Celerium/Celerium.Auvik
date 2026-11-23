---
document type: cmdlet
external help file: Celerium.Auvik-Help.xml
grand_parent: Alert
HelpUri: https://celerium.github.io/Celerium.Auvik/site/Alert/Send-AuvikAlertDismiss.html
Locale: en-US
Module Name: Celerium.Auvik
parent: POST
PlatyPS schema version: 2024-05-01
title: Send-AuvikAlertDismiss
---

# Send-AuvikAlertDismiss

## SYNOPSIS

Dismiss an alert

## SYNTAX

### __AllParameterSets

```
Send-AuvikAlertDismiss [-Id] <string> [-WhatIf] [-Confirm]
```

## ALIASES

This cmdlet has the following aliases,
  - Clear-AuvikAlert

## DESCRIPTION

The Send-AuvikAlertDismiss cmdlet invokes the POST method of the /alert/dismiss/{id} endpoint (Dismiss an alert)

Use the Dismiss Alert API to dismiss a specific alert that Auvik has triggered

This is a write function.
It changes data in Auvik.
Use -WhatIf to see the request without sending it

## EXAMPLES

### EXAMPLE 1

```powershell
Send-AuvikAlertDismiss -Id '1234567890' -WhatIf
```

Shows the POST request to the /alert/dismiss/{id} endpoint without sending it

## PARAMETERS

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: ''
SupportsWildcards: false
Aliases:
- cf
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Id

ID of alert

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: true
  ValueFromPipeline: true
  ValueFromPipelineByPropertyName: true
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -WhatIf

Runs the command in a mode that only reports what would happen without performing the actions.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: ''
SupportsWildcards: false
Aliases:
- wi
ParameterSets:
- Name: (All)
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

### System.String

{{ Fill in the Description }}

## OUTPUTS

### System.Management.Automation.PSCustomObject

{{ Fill in the Description }}

## NOTES

Endpoint : POST /alert/dismiss/{id}
The Auvik API user needs the role permissions that are required by the endpoint


## RELATED LINKS

- [](https://celerium.github.io/Celerium.Auvik/site/Alert/Send-AuvikAlertDismiss.html)
