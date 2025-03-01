---
external help file: Celerium.Auvik-help.xml
grand_parent: internal
Module Name: Celerium.Auvik
online version: https://celerium.github.io/Celerium.Auvik/site/internal/ConvertTo-AuvikQueryString.html
parent: PUT
schema: 2.0.0
title: ConvertTo-AuvikQueryString
---

# ConvertTo-AuvikQueryString

## SYNOPSIS
Converts uri filter parameters

## SYNTAX

```powershell
ConvertTo-AuvikQueryString [[-UriFilter] <Hashtable>] [-ResourceUri] <String> [<CommonParameters>]
```

## DESCRIPTION
The ConvertTo-AuvikQueryString cmdlet converts & formats uri filter parameters
from a function which are later used to make the full resource uri for
an API call

This is an internal helper function the ties in directly with the
ConvertTo-AuvikQueryString & any public functions that define parameters

## EXAMPLES

### EXAMPLE 1
```powershell
ConvertTo-AuvikQueryString -UriFilter $UriFilter -ResourceUri '/account'
```

Example: (From public function)
    $UriFilter = @{}

    ForEach ( $Key in $PSBoundParameters.GetEnumerator() ) {
        if( $excludedParameters -contains $Key.Key ) {$null}
        else{ $UriFilter += @{ $Key.Key = $Key.Value } }
    }

    1x key = https://auvikapi.us1.my.auvik.com/v1/account?accountId=12345
    2x key = https://auvikapi.us1.my.auvik.com/v1/account?accountId=12345&Details=True

## PARAMETERS

### -UriFilter
Hashtable of values to combine a functions parameters with
the ResourceUri parameter.

This allows for the full uri query to occur

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ResourceUri
Defines the short resource uri (url) to use when creating the API call

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
N\A

## RELATED LINKS

[https://celerium.github.io/Celerium.Auvik/site/Internal/ConvertTo-AuvikQueryString.html](https://celerium.github.io/Celerium.Auvik/site/Internal/ConvertTo-AuvikQueryString.html)

