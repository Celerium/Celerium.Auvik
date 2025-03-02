---
external help file: Celerium.Auvik-help.xml
grand_parent: Internal
Module Name: Celerium.Auvik
online version: https://celerium.github.io/Celerium.Auvik/site/Internal/Invoke-AuvikRequest.html
parent: GET
schema: 2.0.0
title: Invoke-AuvikRequest
---

# Invoke-AuvikRequest

## SYNOPSIS
Makes an API request

## SYNTAX

```powershell
Invoke-AuvikRequest [[-Method] <String>] [-ResourceUri] <String> [[-UriFilter] <Hashtable>]
 [[-Data] <Hashtable>] [-AllResults] [<CommonParameters>]
```

## DESCRIPTION
The Invoke-AuvikRequest cmdlet invokes an API request to Auvik API

This is an internal function that is used by all public functions

As of 2023-08 the Auvik v1 API only supports GET requests

## EXAMPLES

### EXAMPLE 1
```powershell
Invoke-AuvikRequest -Method GET -ResourceUri '/account' -UriFilter $UriFilter
```

Invoke a rest method against the defined resource using any of the provided parameters

Example:
    Name                           Value
    ----                           -----
    Method                         GET
    Uri                            https://auvikapi.us1.my.auvik.com/v1/account?accountId=12345&Details=True
    Headers                        {Authorization = Bearer 123456789}
    Body

## PARAMETERS

### -Method
Defines the type of API method to use

Allowed values:
'GET'

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: GET
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResourceUri
Defines the resource uri (url) to use when creating the API call

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UriFilter
Used with the internal function \[ ConvertTo-AuvikQueryString \] to combine
a functions parameters with the ResourceUri parameter

This allows for the full uri query to occur

The full resource path is made with the following data
$AuvikModuleBaseURI + $ResourceUri + ConvertTo-AuvikQueryString

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Data
Place holder parameter to use when other methods are supported
by the Auvik v1 API

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllResults
Returns all items from an endpoint

When using this parameter there is no need to use either the page or perPage
parameters

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
N\A

## RELATED LINKS

[https://celerium.github.io/Celerium.Auvik/site/Internal/Invoke-AuvikRequest.html](https://celerium.github.io/Celerium.Auvik/site/Internal/Invoke-AuvikRequest.html)

