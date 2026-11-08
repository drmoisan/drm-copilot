<#
.SYNOPSIS
    Pure comparison of the surface inventory, coverage ledger and evidence pins between a base
    revision and the working tree, and the surface-delta findings.

.DESCRIPTION
    Every function takes ordinal hashtables produced by ConvertFrom-DocsJsonText (or $null) and
    is pure: no filesystem, clock, process, environment or module-scope mutable state.

    Compare-DocsSurfaceSnapshot returns [ordered]@{ added; changed; removed }, each an ordinally
    sorted string array of element_id. An element is added when its identifier is in the head
    snapshot only, removed when it is in the base snapshot only, and changed when both hold it
    with a different source_sha256. Differences in line_range or analysis_method alone are not
    changes. A $null base snapshot is empty, so every head element is added.

    Get-DocsLedgerChange returns @{ LedgerChanged; PinChanged } for one element: the canonical
    JSON of its ledger entry (absent to present counts) and, separately, the canonical JSON of
    the set of evidence pins that carry its element_id.

    Get-DocsSurfaceDeltaFinding returns @{ Findings; Delta } with findings built by
    New-DocsFinding and ordered by Get-DocsOrderedFinding. The codes are a contract for later
    children: DOCS_SURFACE_UNLEDGERED_ADDITION, DOCS_SURFACE_UNLEDGERED_CHANGE,
    DOCS_SURFACE_REMOVED_ENTRY_RETAINED (warning), DOCS_SURFACE_SNAPSHOT_MISSING,
    DOCS_SURFACE_SNAPSHOT_STALE and DOCS_SURFACE_BASE_UNRESOLVED; every other code is an error.

.NOTES
    Issue #1034. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsJson.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsFinding.psm1') -ErrorAction Stop

function Get-DocsSurfaceDeltaList {
    <#
    .SYNOPSIS
        Returns the dictionary items of a named array member, or an empty array (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [AllowNull()] [object] $Container,
        [Parameter(Mandatory = $true)] [string] $Name
    )

    if ($Container -isnot [System.Collections.IDictionary] -or -not $Container.Contains($Name) -or $null -eq $Container[$Name]) { return , [object[]]@() }
    return , [object[]]@(@($Container[$Name]) | Where-Object { $_ -is [System.Collections.IDictionary] })
}

function Get-DocsSurfaceDeltaElementMap {
    <#
    .SYNOPSIS
        Returns an ordinal map of element_id to element for a snapshot, empty for $null (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseLiteralInitializerForHashtable', '', Justification = 'Element identifiers are case-sensitive; an ordinal-comparer hashtable is required.')]
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([AllowNull()] [object] $Snapshot)

    $map = [hashtable]::new([System.StringComparer]::Ordinal)
    foreach ($element in (Get-DocsSurfaceDeltaList -Container $Snapshot -Name 'elements')) {
        $id = [string] $element['element_id']
        if (-not [string]::IsNullOrEmpty($id)) { $map[$id] = $element }
    }
    return $map
}

function ConvertTo-DocsSurfaceDeltaSorted {
    <#
    .SYNOPSIS
        Returns a string collection as an ordinally sorted array (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string[]], [object[]])]
    param([AllowNull()] [AllowEmptyCollection()] [object[]] $Value)

    [string[]] $sorted = @(@($Value) | Where-Object { $null -ne $_ } | ForEach-Object { [string] $_ })
    [Array]::Sort($sorted, [System.StringComparer]::Ordinal)
    return , $sorted
}

function Compare-DocsSurfaceSnapshot {
    <#
    .SYNOPSIS
        Compares two surface inventory snapshots by element_id and source_sha256.
    .PARAMETER BaseSnapshot
        The snapshot at the base revision, or $null when it is absent there.
    .PARAMETER HeadSnapshot
        The snapshot in the working tree.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary with added, changed and removed.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [AllowNull()] [System.Collections.IDictionary] $BaseSnapshot,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $HeadSnapshot
    )

    $base = Get-DocsSurfaceDeltaElementMap -Snapshot $BaseSnapshot
    $head = Get-DocsSurfaceDeltaElementMap -Snapshot $HeadSnapshot
    $added = [System.Collections.Generic.List[string]]::new()
    $changed = [System.Collections.Generic.List[string]]::new()
    $removed = [System.Collections.Generic.List[string]]::new()
    foreach ($id in $head.Keys) {
        if (-not $base.ContainsKey($id)) { $added.Add($id); continue }
        if (-not [string]::Equals([string] $base[$id]['source_sha256'], [string] $head[$id]['source_sha256'], [System.StringComparison]::Ordinal)) { $changed.Add($id) }
    }
    foreach ($id in $base.Keys) { if (-not $head.ContainsKey($id)) { $removed.Add($id) } }
    return [ordered]@{
        added   = (ConvertTo-DocsSurfaceDeltaSorted -Value $added.ToArray())
        changed = (ConvertTo-DocsSurfaceDeltaSorted -Value $changed.ToArray())
        removed = (ConvertTo-DocsSurfaceDeltaSorted -Value $removed.ToArray())
    }
}

function Get-DocsSurfaceDeltaEntryText {
    <#
    .SYNOPSIS
        Returns the canonical JSON of the ledger entry of an element, or $null when absent (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()] [object] $Ledger,
        [Parameter(Mandatory = $true)] [string] $ElementId
    )

    foreach ($entry in (Get-DocsSurfaceDeltaList -Container $Ledger -Name 'entries')) {
        if ([string]::Equals([string] $entry['element_id'], $ElementId, [System.StringComparison]::Ordinal)) { return ConvertTo-DocsCanonicalJson -Value $entry }
    }
    return $null
}

function Get-DocsSurfaceDeltaPinText {
    <#
    .SYNOPSIS
        Returns the sorted canonical JSON lines of the pins that carry an element_id (private helper).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()] [object] $Pins,
        [Parameter(Mandatory = $true)] [string] $ElementId
    )

    $lines = [System.Collections.Generic.List[string]]::new()
    foreach ($pin in (Get-DocsSurfaceDeltaList -Container $Pins -Name 'pins')) {
        if ([string]::Equals([string] $pin['element_id'], $ElementId, [System.StringComparison]::Ordinal)) { $lines.Add((ConvertTo-DocsCanonicalJson -Value $pin)) }
    }
    return ((ConvertTo-DocsSurfaceDeltaSorted -Value $lines.ToArray()) -join "`n")
}

function Get-DocsLedgerChange {
    <#
    .SYNOPSIS
        Reports whether the ledger entry, and separately the evidence pins, of an element differ.
    .PARAMETER BaseLedger
        The coverage ledger at the base revision, or $null.
    .PARAMETER HeadLedger
        The coverage ledger in the working tree, or $null.
    .PARAMETER BasePins
        The evidence pin collection at the base revision, or $null.
    .PARAMETER HeadPins
        The evidence pin collection in the working tree, or $null.
    .PARAMETER ElementId
        The element identifier.
    .OUTPUTS
        System.Collections.Hashtable with LedgerChanged and PinChanged.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [AllowNull()] [System.Collections.IDictionary] $BaseLedger,
        [AllowNull()] [System.Collections.IDictionary] $HeadLedger,
        [AllowNull()] [System.Collections.IDictionary] $BasePins,
        [AllowNull()] [System.Collections.IDictionary] $HeadPins,
        [Parameter(Mandatory = $true)] [string] $ElementId
    )

    $baseEntry = Get-DocsSurfaceDeltaEntryText -Ledger $BaseLedger -ElementId $ElementId
    $headEntry = Get-DocsSurfaceDeltaEntryText -Ledger $HeadLedger -ElementId $ElementId
    $basePin = Get-DocsSurfaceDeltaPinText -Pins $BasePins -ElementId $ElementId
    $headPin = Get-DocsSurfaceDeltaPinText -Pins $HeadPins -ElementId $ElementId
    return @{
        LedgerChanged = -not [string]::Equals($baseEntry, $headEntry, [System.StringComparison]::Ordinal)
        PinChanged    = -not [string]::Equals($basePin, $headPin, [System.StringComparison]::Ordinal)
    }
}

function New-DocsSurfaceDeltaElementFinding {
    <#
    .SYNOPSIS
        Builds one element finding naming the element_id, kind and path (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory = $true)] [string] $Code,
        [Parameter(Mandatory = $true)] [string] $Severity,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Element,
        [Parameter(Mandatory = $true)] [string] $Condition,
        [Parameter(Mandatory = $true)] [string] $NextAction,
        [AllowNull()] [string] $ArtifactPath
    )

    $id = [string] $Element['element_id']
    $kind = [string] $Element['kind']
    $path = [string] $Element['path']
    $relatedPath = [string[]]@(if (-not [string]::IsNullOrEmpty($path)) { $path })
    return New-DocsFinding -Code $Code -Severity $Severity -Message "The $kind element $id at $path $Condition." -NextAction $NextAction -ArtifactPath $ArtifactPath -RelatedId @($id) -RelatedPath $relatedPath
}

function Get-DocsSurfaceDeltaFinding {
    <#
    .SYNOPSIS
        Returns @{ Findings; Delta } for a surface comparison and its preconditions.
    .DESCRIPTION
        BaseResolved $false returns one DOCS_SURFACE_BASE_UNRESOLVED finding naming BaseRef. A
        $null HeadSnapshot returns one DOCS_SURFACE_SNAPSHOT_MISSING finding at SnapshotPath.
        Otherwise each StaleInputPath yields DOCS_SURFACE_SNAPSHOT_STALE, each added element with
        no ledger change DOCS_SURFACE_UNLEDGERED_ADDITION, each changed element with no ledger and
        no pin change DOCS_SURFACE_UNLEDGERED_CHANGE, and each removed element whose unchanged
        entry is still in the head ledger DOCS_SURFACE_REMOVED_ENTRY_RETAINED (warning). Delta is
        the Compare-DocsSurfaceSnapshot result, or $null when no comparison ran.
    .PARAMETER BaseRef
        The base ref as given, for the unresolved-base message.
    .PARAMETER BaseResolved
        Whether the base ref resolved to a commit.
    .PARAMETER SnapshotPath
        The repository-relative snapshot path, for the missing and stale findings.
    .PARAMETER StaleInputPath
        Head snapshot inputs whose working-tree digest differs from the recorded digest.
    .OUTPUTS
        System.Collections.Hashtable
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [AllowNull()] [System.Collections.IDictionary] $BaseSnapshot,
        [AllowNull()] [System.Collections.IDictionary] $HeadSnapshot,
        [AllowNull()] [System.Collections.IDictionary] $BaseLedger,
        [AllowNull()] [System.Collections.IDictionary] $HeadLedger,
        [AllowNull()] [System.Collections.IDictionary] $BasePins,
        [AllowNull()] [System.Collections.IDictionary] $HeadPins,
        [AllowNull()] [string] $BaseRef,
        [bool] $BaseResolved = $true,
        [AllowNull()] [string] $SnapshotPath,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $StaleInputPath
    )

    if (-not $BaseResolved) {
        $finding = New-DocsFinding -Code 'DOCS_SURFACE_BASE_UNRESOLVED' -Severity 'error' -Message "The base ref '$BaseRef' does not resolve to a commit." -NextAction 'Pass -Base with a branch, tag or full revision present in the repository history (fetch it first in a shallow checkout).'
        return @{ Findings = (Get-DocsOrderedFinding -Finding @($finding)); Delta = $null }
    }
    if ($null -eq $HeadSnapshot) {
        $finding = New-DocsFinding -Code 'DOCS_SURFACE_SNAPSHOT_MISSING' -Severity 'error' -Message "No surface inventory snapshot exists at $SnapshotPath." -NextAction 'Run Invoke-DocsCommand.ps1 -Command inventory -Write before surface-delta.' -ArtifactPath $SnapshotPath
        return @{ Findings = (Get-DocsOrderedFinding -Finding @($finding)); Delta = $null }
    }

    $findings = [System.Collections.Generic.List[object]]::new()
    foreach ($path in (ConvertTo-DocsSurfaceDeltaSorted -Value $StaleInputPath)) {
        $findings.Add((New-DocsFinding -Code 'DOCS_SURFACE_SNAPSHOT_STALE' -Severity 'error' -Message "The snapshot input $path changed after the snapshot was written." -NextAction 'Run Invoke-DocsCommand.ps1 -Command inventory -Write to regenerate the snapshot.' -ArtifactPath $SnapshotPath -RelatedPath @($path)))
    }
    $delta = Compare-DocsSurfaceSnapshot -BaseSnapshot $BaseSnapshot -HeadSnapshot $HeadSnapshot
    $head = Get-DocsSurfaceDeltaElementMap -Snapshot $HeadSnapshot
    $base = Get-DocsSurfaceDeltaElementMap -Snapshot $BaseSnapshot
    $ledgerAction = 'Record the element in the coverage ledger with Invoke-DocsCommand.ps1 -Command update-ledger -Write.'
    foreach ($id in $delta['added']) {
        $change = Get-DocsLedgerChange -BaseLedger $BaseLedger -HeadLedger $HeadLedger -BasePins $BasePins -HeadPins $HeadPins -ElementId $id
        if (-not $change.LedgerChanged) { $findings.Add((New-DocsSurfaceDeltaElementFinding -Code 'DOCS_SURFACE_UNLEDGERED_ADDITION' -Severity 'error' -Element $head[$id] -Condition 'was added with no coverage ledger change' -NextAction $ledgerAction -ArtifactPath $SnapshotPath)) }
    }
    foreach ($id in $delta['changed']) {
        $change = Get-DocsLedgerChange -BaseLedger $BaseLedger -HeadLedger $HeadLedger -BasePins $BasePins -HeadPins $HeadPins -ElementId $id
        if (-not $change.LedgerChanged -and -not $change.PinChanged) { $findings.Add((New-DocsSurfaceDeltaElementFinding -Code 'DOCS_SURFACE_UNLEDGERED_CHANGE' -Severity 'error' -Element $head[$id] -Condition 'changed with no coverage ledger or evidence pin change' -NextAction $ledgerAction -ArtifactPath $SnapshotPath)) }
    }
    foreach ($id in $delta['removed']) {
        $change = Get-DocsLedgerChange -BaseLedger $BaseLedger -HeadLedger $HeadLedger -BasePins $BasePins -HeadPins $HeadPins -ElementId $id
        if (-not $change.LedgerChanged -and $null -ne (Get-DocsSurfaceDeltaEntryText -Ledger $HeadLedger -ElementId $id)) { $findings.Add((New-DocsSurfaceDeltaElementFinding -Code 'DOCS_SURFACE_REMOVED_ENTRY_RETAINED' -Severity 'warning' -Element $base[$id] -Condition 'was removed but its unchanged coverage ledger entry remains' -NextAction 'Remove or update the ledger entry with Invoke-DocsCommand.ps1 -Command update-ledger -Write.' -ArtifactPath $SnapshotPath)) }
    }
    return @{ Findings = (Get-DocsOrderedFinding -Finding $findings.ToArray()); Delta = $delta }
}

Export-ModuleMember -Function `
    Compare-DocsSurfaceSnapshot, `
    Get-DocsLedgerChange, `
    Get-DocsSurfaceDeltaFinding
