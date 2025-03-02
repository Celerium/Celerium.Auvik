---
external help file: Celerium.Auvik-help.xml
grand_parent: Pollers
Module Name: Celerium.Auvik
online version: https://celerium.github.io/Celerium.Auvik/site/Pollers/Get-AuvikSNMPPollerSetting.html
parent: GET
schema: 2.0.0
title: Get-AuvikSNMPPollerSetting
---

# Get-AuvikSNMPPollerSetting

## SYNOPSIS
Provides Details about one or more SNMP Poller Settings

## SYNTAX

### IndexByMultiSNMP (Default)
```powershell
Get-AuvikSNMPPollerSetting -Tenants <String[]> [-FilterDeviceId <String>] [-FilterUseAs <String>]
 [-FilterType <String>] [-FilterDeviceType <String>] [-FilterMakeModel <String>] [-FilterVendorName <String>]
 [-FilterOID <String>] [-FilterName <String>] [-PageFirst <Int64>] [-PageAfter <String>] [-PageLast <Int64>]
 [-PageBefore <String>] [-AllResults] [<CommonParameters>]
```

### IndexBySingleSNMP
```powershell
Get-AuvikSNMPPollerSetting -SNMPPollerSettingId <String> [<CommonParameters>]
```

## DESCRIPTION
The Get-AuvikSNMPPollerSetting cmdlet provides Details about
one or more SNMP Poller Settings

## EXAMPLES

### EXAMPLE 1
```powershell
Get-AuvikSNMPPollerSetting -Tenants 123456789
```

Provides Details about the first 100 SNMP Poller Settings
associated to the defined tenant

### EXAMPLE 2
```powershell
Get-AuvikSNMPPollerSetting -Tenants 123456789 -PageFirst 1000 -AllResults
```

Provides Details about all the SNMP Poller Settings
associated to the defined tenant

## PARAMETERS

### -SNMPPollerSettingId
ID of the SNMP Poller Setting to retrieve

```yaml
Type: String
Parameter Sets: IndexBySingleSNMP
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Tenants
Comma delimited list of tenant IDs to request info from

```yaml
Type: String[]
Parameter Sets: IndexByMultiSNMP
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
Parameter Sets: IndexByMultiSNMP
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterUseAs
Filter by oid type

Allowed values:
    "serialNo", "poller"

```yaml
Type: String
Parameter Sets: IndexByMultiSNMP
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterType
Filter by type

Allowed values:
    "string", "numeric"

```yaml
Type: String
Parameter Sets: IndexByMultiSNMP
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterDeviceType
Filter by device type

Allowed values:
    "unknown", "switch", "l3Switch", "router", "accessPoint", "firewall", "workstation",
    "server", "storage", "printer", "copier", "hypervisor", "multimedia", "phone", "tablet",
    "handheld", "virtualAppliance", "bridge", "controller", "hub", "modem", "ups", "module",
    "loadBalancer", "camera", "telecommunications", "packetProcessor", "chassis", "airConditioner",
    "virtualMachine", "pdu", "ipPhone", "backhaul", "internetOfThings", "voipSwitch", "stack",
    "backupDevice", "timeClock", "lightingDevice", "audioVisual", "securityAppliance", "utm",
    "alarm", "buildingManagement", "ipmi", "thinAccessPoint", "thinClient"

```yaml
Type: String
Parameter Sets: IndexByMultiSNMP
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterMakeModel
Filter by the device's make and model

```yaml
Type: String
Parameter Sets: IndexByMultiSNMP
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterVendorName
Filter by the device's vendor/manufacturer

```yaml
Type: String
Parameter Sets: IndexByMultiSNMP
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterOID
Filter by OID

```yaml
Type: String
Parameter Sets: IndexByMultiSNMP
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterName
Filter by the name of the SNMP poller setting

```yaml
Type: String
Parameter Sets: IndexByMultiSNMP
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
Parameter Sets: IndexByMultiSNMP
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
Parameter Sets: IndexByMultiSNMP
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
Parameter Sets: IndexByMultiSNMP
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
Parameter Sets: IndexByMultiSNMP
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
Parameter Sets: IndexByMultiSNMP
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

[https://celerium.github.io/Celerium.Auvik/site/Pollers/Get-AuvikSNMPPollerSetting.html](https://celerium.github.io/Celerium.Auvik/site/Pollers/Get-AuvikSNMPPollerSetting.html)

