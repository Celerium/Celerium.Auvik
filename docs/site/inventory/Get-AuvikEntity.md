---
external help file: Celerium.Auvik-help.xml
grand_parent: inventory
Module Name: Celerium.Auvik
online version: https://celerium.github.io/Celerium.Auvik/site/inventory/Get-AuvikEntity.html
parent: GET
schema: 2.0.0
title: Get-AuvikEntity
---

# Get-AuvikEntity

## SYNOPSIS
Get Auvik Notes and audit trails associated with the entities

## SYNTAX

### IndexByMultiEntityNotes (Default)
```powershell
Get-AuvikEntity [-Tenants <String[]>] [-FilterEntityId <String>] [-FilterEntityType <String>]
 [-FilterEntityName <String>] [-FilterLastModifiedBy <String>] [-FilterModifiedAfter <DateTime>]
 [-PageFirst <Int64>] [-PageAfter <String>] [-PageLast <Int64>] [-PageBefore <String>] [-AllResults]
 [<CommonParameters>]
```

### IndexBySingleEntityAudits
```powershell
Get-AuvikEntity -ID <String> [-Audits] [<CommonParameters>]
```

### IndexBySingleEntityNotes
```powershell
Get-AuvikEntity -ID <String> [-Notes] [<CommonParameters>]
```

### IndexByMultiEntityAudits
```powershell
Get-AuvikEntity [-Tenants <String[]>] [-FilterUser <String>] [-FilterCategory <String>]
 [-FilterStatus <String>] [-PageFirst <Int64>] [-PageAfter <String>] [-PageLast <Int64>] [-PageBefore <String>]
 [-AllResults] [<CommonParameters>]
```

## DESCRIPTION
The Get-AuvikEntity cmdlet allows you to view Notes and audit trails associated
with the entities (devices, networks, and interfaces) that have been discovered
by Auvik.

Use the \[ -Audits & -Notes  \] parameters when wanting to target
specific information.

See Get-Help Get-AuvikEntity -Full for more information on associated parameters

## EXAMPLES

### EXAMPLE 1
```powershell
Get-AuvikEntity
```

Gets general information about the first 100 Notes
Auvik has discovered

### EXAMPLE 2
```powershell
Get-AuvikEntity -ID 123456789 -Audits
```

Gets general information for the defined audit
Auvik has discovered

### EXAMPLE 3
```powershell
Get-AuvikEntity -ID 123456789 -Notes
```

Gets general information for the defined note
Auvik has discovered

### EXAMPLE 4
```powershell
Get-AuvikEntity -PageFirst 1000 -AllResults
```

Gets general information for all note entities found by Auvik.

## PARAMETERS

### -ID
ID of entity note\audit

```yaml
Type: String
Parameter Sets: IndexBySingleEntityAudits, IndexBySingleEntityNotes
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
Parameter Sets: IndexByMultiEntityNotes, IndexByMultiEntityAudits
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterEntityId
Filter by the entity's ID

```yaml
Type: String
Parameter Sets: IndexByMultiEntityNotes
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterUser
Filter by user name associated to the audit

```yaml
Type: String
Parameter Sets: IndexByMultiEntityAudits
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterCategory
Filter by the audit's category

Allowed values:
    "unknown", "tunnel", "terminal", "remoteBrowser"

```yaml
Type: String
Parameter Sets: IndexByMultiEntityAudits
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterEntityType
Filter by the entity's type

Allowed values:
    "root", "device", "network", "interface"

```yaml
Type: String
Parameter Sets: IndexByMultiEntityNotes
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterEntityName
Filter by the entity's name

```yaml
Type: String
Parameter Sets: IndexByMultiEntityNotes
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterLastModifiedBy
Filter by the user the note was last modified by

```yaml
Type: String
Parameter Sets: IndexByMultiEntityNotes
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterStatus
Filter by the audit's status

Allowed values:
    "unknown", "initiated", "created", "closed", "failed"

```yaml
Type: String
Parameter Sets: IndexByMultiEntityAudits
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
Parameter Sets: IndexByMultiEntityNotes
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Audits
Target the audit endpoint

/Inventory/entity/audit & /Inventory/entity/audit/{id}

```yaml
Type: SwitchParameter
Parameter Sets: IndexBySingleEntityAudits
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Notes
Target the note endpoint

/Inventory/entity/note & /Inventory/entity/note/{id}

```yaml
Type: SwitchParameter
Parameter Sets: IndexBySingleEntityNotes
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
Parameter Sets: IndexByMultiEntityNotes, IndexByMultiEntityAudits
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
Parameter Sets: IndexByMultiEntityNotes, IndexByMultiEntityAudits
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
Parameter Sets: IndexByMultiEntityNotes, IndexByMultiEntityAudits
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
Parameter Sets: IndexByMultiEntityNotes, IndexByMultiEntityAudits
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
Parameter Sets: IndexByMultiEntityNotes, IndexByMultiEntityAudits
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

[https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikEntity.html](https://celerium.github.io/Celerium.Auvik/site/Inventory/Get-AuvikEntity.html)

