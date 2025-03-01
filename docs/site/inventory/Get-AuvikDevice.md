---
external help file: Celerium.Auvik-help.xml
grand_parent: inventory
Module Name: Celerium.Auvik
online version: https://celerium.github.io/Celerium.Auvik/site/inventory/Get-AuvikDevice.html
parent: GET
schema: 2.0.0
title: Get-AuvikDevice
---

# Get-AuvikDevice

## SYNOPSIS
Get Auvik devices and other related information

## SYNTAX

### IndexByMultiDeviceInfo (Default)
```powershell
Get-AuvikDevice [-Tenants <String[]>] [-FilterNetworks <String>] [-FilterDeviceType <String>]
 [-FilterMakeModel <String>] [-FilterVendorName <String>] [-FilterOnlineStatus <String>]
 [-FilterModifiedAfter <DateTime>] [-FilterNotSeenSince <DateTime>] [-FilterStateKnown] [-Include <String>]
 [-FieldsDeviceDetail <String>] [-AgentInfo] [-PageFirst <Int64>] [-PageAfter <String>] [-PageLast <Int64>]
 [-PageBefore <String>] [-AllResults] [<CommonParameters>]
```

### IndexBySingleDeviceExtDetail
```powershell
Get-AuvikDevice -ID <String> [-AgentExtended] [<CommonParameters>]
```

### IndexBySingleDeviceDetail
```powershell
Get-AuvikDevice -ID <String> [-AgentDetail] [<CommonParameters>]
```

### IndexBySingleDeviceInfo
```powershell
Get-AuvikDevice -ID <String> [-Include <String>] [-FieldsDeviceDetail <String>] [-AgentInfo]
 [<CommonParameters>]
```

### IndexByMultiDeviceExtDetail
```powershell
Get-AuvikDevice [-Tenants <String[]>] -FilterDeviceType <String> [-FilterModifiedAfter <DateTime>]
 [-FilterNotSeenSince <DateTime>] [-FilterStateKnown] [-AgentExtended] [-PageFirst <Int64>]
 [-PageAfter <String>] [-PageLast <Int64>] [-PageBefore <String>] [-AllResults] [<CommonParameters>]
```

### IndexByMultiDeviceDetail
```powershell
Get-AuvikDevice [-Tenants <String[]>] [-FilterManageStatus] [-FilterDiscoverySNMP <String>]
 [-FilterDiscoveryWMI <String>] [-FilterDiscoveryLogin <String>] [-FilterDiscoveryVMware <String>]
 [-FilterTrafficInsightsStatus <String>] [-AgentDetail] [-PageFirst <Int64>] [-PageAfter <String>]
 [-PageLast <Int64>] [-PageBefore <String>] [-AllResults] [<CommonParameters>]
```

## DESCRIPTION
The Get-AuvikDevice cmdlet allows you to view an inventory of
devices and other related information discovered by Auvik.

Use the \[ -AgentDetail, -AgentExtended, & -AgentInfo  \] parameters
when wanting to target specific information.

See Get-Help Get-AuvikDevice -Full for more information on associated parameters

This function combines 6 endpoints together within the Device API.

Read Multiple Devices' Info:
    Gets detail about multiple devices discovered on your client's network.
Read a Single Device's Info:
    Gets detail about a specific device discovered on your client's network.

Read Multiple Devices' Details:
    Gets details about multiple devices not already Included in the Device Info API.
Read a Single Device's Details:
    Gets details about a specific device not already Included in the Device Info API.

Read Multiple Device's Extended Details:
    Gets extended information about multiple devices not already Included in the Device Info API.
Read a Single Device's Extended Details:
    Gets extended information about a specific device not already Included in the Device Info API.

## EXAMPLES

### EXAMPLE 1
```powershell
Get-AuvikDevice
```

Gets general information about the first 100 devices
Auvik has discovered

### EXAMPLE 2
```powershell
Get-AuvikDevice -ID 123456789 -AgentInfo
```

Gets general information for the defined device
Auvik has discovered

### EXAMPLE 3
```powershell
Get-AuvikDevice -AgentDetail
```

Gets detailed information about the first 100 devices
Auvik has discovered

### EXAMPLE 4
```powershell
Get-AuvikDevice -ID 123456789 -AgentDetail
```

Gets AgentDetail information for the defined device
Auvik has discovered

### EXAMPLE 5
```powershell
Get-AuvikDevice -AgentExtended
```

Gets extended detail information about the first 100 devices
Auvik has discovered

### EXAMPLE 6
```powershell
Get-AuvikDevice -ID 123456789 -AgentExtended
```

Gets extended detail information for the defined device
Auvik has discovered

### EXAMPLE 7
```powershell
Get-AuvikDevice -PageFirst 1000 -AllResults
```

Gets general information for all devices found by Auvik.

## PARAMETERS

### -ID
ID of device

```yaml
Type: String
Parameter Sets: IndexBySingleDeviceExtDetail, IndexBySingleDeviceDetail, IndexBySingleDeviceInfo
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
Parameter Sets: IndexByMultiDeviceInfo, IndexByMultiDeviceExtDetail, IndexByMultiDeviceDetail
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterNetworks
Filter by IDs of networks this device is on

```yaml
Type: String
Parameter Sets: IndexByMultiDeviceInfo
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterManageStatus
Filter by managed status

```yaml
Type: SwitchParameter
Parameter Sets: IndexByMultiDeviceDetail
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterDiscoverySNMP
Filter by the device's SNMP discovery status

Allowed values:
    "disabled", "determining", "notSupported", "notAuthorized", "authorizing", "authorized", "privileged"

```yaml
Type: String
Parameter Sets: IndexByMultiDeviceDetail
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterDiscoveryWMI
Filter by the device's WMI discovery status

Allowed values:
    "disabled", "determining", "notSupported", "notAuthorized", "authorizing", "authorized", "privileged"

```yaml
Type: String
Parameter Sets: IndexByMultiDeviceDetail
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterDiscoveryLogin
Filter by the device's Login discovery status

Allowed values:
    "disabled", "determining", "notSupported", "notAuthorized", "authorizing", "authorized", "privileged"

```yaml
Type: String
Parameter Sets: IndexByMultiDeviceDetail
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterDiscoveryVMware
Filter by the device's VMware discovery status

Allowed values:
    "disabled", "determining", "notSupported", "notAuthorized", "authorizing", "authorized", "privileged"

```yaml
Type: String
Parameter Sets: IndexByMultiDeviceDetail
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterTrafficInsightsStatus
Filter by the device's VMware discovery status

Allowed values:
    "notDetected", "detected", "notApproved", "approved", "linking", "linkingFailed", "forwarding"

```yaml
Type: String
Parameter Sets: IndexByMultiDeviceDetail
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
    "accessPoint", "airConditioner", "alarm", "audioVisual", "backhaul", "backupDevice",
    "bridge", "buildingManagement", "camera", "chassis", "controller", "copier", "firewall",
    "handheld", "hub", "hypervisor", "internetOfThings", "ipmi", "ipPhone", "l3Switch",
    "lightingDevice", "loadBalancer", "modem", "module", "multimedia", "packetProcessor",
    "pdu", "phone", "printer", "router", "securityAppliance", "server", "stack", "storage",
    "switch", "tablet", "telecommunications", "thinAccessPoint", "thinClient", "timeClock",
    "unknown", "ups", "utm", "virtualAppliance", "virtualMachine", "voipSwitch", "workstation"

```yaml
Type: String
Parameter Sets: IndexByMultiDeviceInfo
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: IndexByMultiDeviceExtDetail
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterMakeModel
Filter by the device's make and model

```yaml
Type: String
Parameter Sets: IndexByMultiDeviceInfo
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
Parameter Sets: IndexByMultiDeviceInfo
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterOnlineStatus
Filter by the device's online status

Allowed values:
"online", "offline", "unreachable", "testing", "unknown", "dormant", "notPresent", "lowerLayerDown"

```yaml
Type: String
Parameter Sets: IndexByMultiDeviceInfo
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterModifiedAfter
Filter by date and time, only returning entities modified after provided value

```yaml
Type: DateTime
Parameter Sets: IndexByMultiDeviceInfo, IndexByMultiDeviceExtDetail
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterNotSeenSince
Filter by the last seen online time, returning entities not seen online after the provided value

```yaml
Type: DateTime
Parameter Sets: IndexByMultiDeviceInfo, IndexByMultiDeviceExtDetail
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterStateKnown
Filter by devices with recently updated data, for more consistent results.

```yaml
Type: SwitchParameter
Parameter Sets: IndexByMultiDeviceInfo, IndexByMultiDeviceExtDetail
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Include
Use to Include the full resource objects of the list device relationships

Example: Include=deviceDetail

```yaml
Type: String
Parameter Sets: IndexByMultiDeviceInfo, IndexBySingleDeviceInfo
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FieldsDeviceDetail
Use to limit the attributes that will be returned in the Included detail object to
only what is specified by this query parameter

Requires Include=deviceDetail

```yaml
Type: String
Parameter Sets: IndexByMultiDeviceInfo, IndexBySingleDeviceInfo
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AgentDetail
Target the detail agents endpoint

/Inventory/device/detail & /Inventory/device/detail/{id}

```yaml
Type: SwitchParameter
Parameter Sets: IndexBySingleDeviceDetail, IndexByMultiDeviceDetail
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -AgentExtended
Target the extended agents endpoint

/Inventory/device/detail/extended & /Inventory/device/detail/extended/{id}

```yaml
Type: SwitchParameter
Parameter Sets: IndexBySingleDeviceExtDetail, IndexByMultiDeviceExtDetail
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -AgentInfo
Target the info agent endpoint

Only needed when limiting general search by id, to give the parameter
set a unique value.

/Inventory/device/info & /Inventory/device/info

```yaml
Type: SwitchParameter
Parameter Sets: IndexByMultiDeviceInfo, IndexBySingleDeviceInfo
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageFirst
For paginated responses, the first N elements will be returned
Used in combination with page\[after\]

Default Value: 100

```yaml
Type: Int64
Parameter Sets: IndexByMultiDeviceInfo, IndexByMultiDeviceExtDetail, IndexByMultiDeviceDetail
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
Parameter Sets: IndexByMultiDeviceInfo, IndexByMultiDeviceExtDetail, IndexByMultiDeviceDetail
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
Parameter Sets: IndexByMultiDeviceInfo, IndexByMultiDeviceExtDetail, IndexByMultiDeviceDetail
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
Parameter Sets: IndexByMultiDeviceInfo, IndexByMultiDeviceExtDetail, IndexByMultiDeviceDetail
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
Parameter Sets: IndexByMultiDeviceInfo, IndexByMultiDeviceExtDetail, IndexByMultiDeviceDetail
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

[https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikDevice.html](https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikDevice.html)

