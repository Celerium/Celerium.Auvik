---
external help file: Celerium.Auvik-help.xml
grand_parent: pollers
Module Name: Celerium.Auvik
online version: https://celerium.github.io/Celerium.Auvik/site/pollers/Get-AuvikSNMPPollerHistory.html
parent: GET
schema: 2.0.0
title: Get-AuvikSNMPPollerHistory
---

# Get-AuvikSNMPPollerHistory

## SYNOPSIS
Get Auvik historical values of SNMP Poller settings

## SYNTAX

### IndexByStringSNMP (Default)
```powershell
Get-AuvikSNMPPollerHistory -Tenants <String[]> -FilterFromTime <DateTime> [-FilterThruTime <DateTime>]
 [-FilterCompact] [-FilterDeviceId <String>] [-FilterSNMPPollerSettingId <String[]>] [-PageFirst <Int64>]
 [-PageAfter <String>] [-PageLast <Int64>] [-PageBefore <String>] [-AllResults] [<CommonParameters>]
```

### IndexByNumericSNMP
```powershell
Get-AuvikSNMPPollerHistory -Tenants <String[]> -FilterFromTime <DateTime> [-FilterThruTime <DateTime>]
 -FilterInterval <String> [-FilterDeviceId <String>] [-FilterSNMPPollerSettingId <String[]>]
 [-PageFirst <Int64>] [-PageAfter <String>] [-PageLast <Int64>] [-PageBefore <String>] [-AllResults]
 [<CommonParameters>]
```

## DESCRIPTION
The Get-AuvikSNMPPolllerHistory cmdlet allows you to view
historical values of SNMP Poller settings

There are two endpoints available in the SNMP Poller History API

Read String SNMP Poller Setting History:
    Provides historical values of String SNMP Poller Settings
Read Numeric SNMP Poller Setting History:
    Provides historical values of Numeric SNMP Poller Settings

## EXAMPLES

### EXAMPLE 1
```powershell
Get-AuvikSNMPPolllerHistory -FilterFromTime 2023-10-01 -Tenants 123456789
```

Gets general information about the first 100 historical SNMP
string poller settings

### EXAMPLE 2
```powershell
Get-AuvikSNMPPolllerHistory -FilterFromTime 2023-10-01 -Tenants 123456789 -FilterInterval day
```

Gets general information about the first 100 historical SNMP
numerical poller settings

### EXAMPLE 3
```powershell
Get-AuvikSNMPPolllerHistory -FilterFromTime 2023-10-01 -Tenants 123456789 -PageFirst 1000 -AllResults
```

Gets general information about all historical SNMP
string poller settings

## PARAMETERS

### -Tenants
Comma delimited list of tenant IDs to request info from

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterFromTime
Timestamp from which you want to query

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterThruTime
Timestamp to which you want to query (defaults to current time)

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterCompact
Whether to show compact view of the results or not

Compact view only shows changes in value
If compact view is false, dateTime range can be a maximum of 24h

```yaml
Type: SwitchParameter
Parameter Sets: IndexByStringSNMP
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterInterval
Statistics reporting interval

Allowed values:
    "minute", "hour", "day"

```yaml
Type: String
Parameter Sets: IndexByNumericSNMP
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterDeviceId
Filter by device ID

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterSNMPPollerSettingId
Comma delimited list of SNMP poller setting IDs to request info from

Note this is internal SNMPPollerSettingId
The user can get the list of IDs for a specific poller using the
GET /settings/snmppoller endpoint

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageFirst
For paginated responses, the first N elements will be returned
Used in combination with page\[after\]

Default Value: 100

```yaml
Type: Int64
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageAfter
Cursor after which elements will be returned as a page
The page size is provided by page\[first\]

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageLast
For paginated responses, the last N services will be returned
Used in combination with page\[before\]

Default Value: 100

```yaml
Type: Int64
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageBefore
Cursor before which elements will be returned as a page
The page size is provided by page\[last\]

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllResults
Returns all items from an endpoint

Highly recommended to only use with filters to reduce API errors\timeouts

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

[https://celerium.github.io/Celerium.Auvik/site/Pollers/Get-AuvikSNMPPolllerHistory.html](https://celerium.github.io/Celerium.Auvik/site/Pollers/Get-AuvikSNMPPolllerHistory.html)

