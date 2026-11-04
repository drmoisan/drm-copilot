<#
.SYNOPSIS
    Coverage ledger rules for the documentation library: the disposition companion table and the
    ledger findings against a snapshot view.

.DESCRIPTION
    Get-DocsLedgerEntryCompanionFinding reports the companion rules of one entry
    (DOCS_LEDGER_BINDING_REQUIRED, DOCS_LEDGER_RATIONALE_REQUIRED, DOCS_LEDGER_OWNER_REQUIRED,
    DOCS_LEDGER_TARGET_REQUIRED). Get-DocsLedgerFinding reports completeness, duplicates, orphans,
    kind and analysis-method differences, the snapshot reference and the precision-limit
    accounting (DOCS_LEDGER_LIMIT_UNRECORDED, DOCS_LEDGER_LIMIT_MISMATCH,
    DOCS_LEDGER_LIMIT_RESOLVED). Both emit their findings through Get-DocsOrderedFinding.
    Identifier and path comparisons are ordinal and case-sensitive; every sort is ordinal. The
    rules are split from DocsLedger.psm1 under the file-size guidance; the shapes they read are
    built there.

    Every function is pure: no filesystem, clock, process, environment or module-scope mutable
    state.

.NOTES
    Issue #1023. Requires PowerShell 7.4 or later. No external module dependencies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsJson.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsFinding.psm1') -ErrorAction Stop
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'DocsSurface.psm1') -ErrorAction Stop

$script:DocsLedgerRulesMarkerKey = 'docs.precision-limit'
$script:DocsLedgerRulesOrderedFindingLimit = 10000

function Get-DocsLedgerRulesMember {
    <#
    .SYNOPSIS
        Returns a table member, or $null when the key is absent (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [AllowNull()] [object] $Table,
        [Parameter(Mandatory = $true)] [string] $Name
    )

    if ($Table -is [System.Collections.IDictionary] -and $Table.Contains($Name)) { return $Table[$Name] }
    return $null
}

function Get-DocsLedgerRulesOrderedFinding {
    <#
    .SYNOPSIS
        Orders findings through Get-DocsOrderedFinding without truncating a practical set (private helper).
    .DESCRIPTION
        Exit codes and validation results are computed from the unbounded set, so the limit is the
        count itself (clamped to the Get-DocsOrderedFinding range).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param([AllowNull()] [AllowEmptyCollection()] [object[]] $Finding)

    $items = @($Finding | Where-Object { $null -ne $_ })
    $limit = [math]::Min($script:DocsLedgerRulesOrderedFindingLimit, [math]::Max(1, $items.Count))
    return Get-DocsOrderedFinding -Finding $items -Limit $limit
}

function New-DocsLedgerRulesFinding {
    <#
    .SYNOPSIS
        Builds one finding for this module; related ids and paths outside their grammar are dropped (private helper).
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)] [string] $Code,
        [Parameter(Mandatory = $true)] [string] $Severity,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Pointer,
        [Parameter(Mandatory = $true)] [string] $Message,
        [Parameter(Mandatory = $true)] [string] $NextAction,
        [AllowNull()] [string] $ArtifactPath,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $RelatedId,
        [AllowNull()] [AllowEmptyCollection()] [string[]] $RelatedPath
    )

    $ids = [string[]]@($RelatedId | Where-Object { $null -ne $_ -and $_ -cmatch '^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$(?![\s\S])' })
    $paths = [string[]]@($RelatedPath | Where-Object { $null -ne $_ -and (Test-DocsRelativePath -Path $_) })
    return New-DocsFinding -Code $Code -Severity $Severity -Pointer $Pointer -Message $Message -NextAction $NextAction -ArtifactPath $ArtifactPath -RelatedId $ids -RelatedPath $paths
}

function Test-DocsLedgerRulesMarker {
    <#
    .SYNOPSIS
        Returns $true when the record's extensions contain the docs.precision-limit key (private helper).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] [object] $Record)

    $extensions = Get-DocsLedgerRulesMember -Table $Record -Name 'extensions'
    return ($extensions -is [System.Collections.IDictionary]) -and $extensions.Contains($script:DocsLedgerRulesMarkerKey)
}

function Get-DocsLedgerEntryCompanionFinding {
    <#
    .SYNOPSIS
        Returns the disposition companion findings of one entry at Pointer.
    .DESCRIPTION
        documented without a binding is DOCS_LEDGER_BINDING_REQUIRED; excluded without a
        rationale is DOCS_LEDGER_RATIONALE_REQUIRED; deferred without an owner or a target is
        DOCS_LEDGER_OWNER_REQUIRED or DOCS_LEDGER_TARGET_REQUIRED. Each message names the element id.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Entry,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $Pointer,
        [AllowNull()] [string] $ArtifactPath
    )

    $findings = [System.Collections.Generic.List[object]]::new()
    $id = [string] (Get-DocsLedgerRulesMember -Table $Entry -Name 'element_id')
    $disposition = [string] (Get-DocsLedgerRulesMember -Table $Entry -Name 'disposition')
    $bindings = @(Get-DocsLedgerRulesMember -Table $Entry -Name 'page_bindings')
    $blank = @{
        rationale = [string]::IsNullOrWhiteSpace([string] (Get-DocsLedgerRulesMember -Table $Entry -Name 'rationale'))
        owner     = [string]::IsNullOrWhiteSpace([string] (Get-DocsLedgerRulesMember -Table $Entry -Name 'owner'))
        target    = [string]::IsNullOrWhiteSpace([string] (Get-DocsLedgerRulesMember -Table $Entry -Name 'target'))
    }
    if ($disposition -ceq 'documented' -and $bindings.Count -eq 0) {
        $findings.Add((New-DocsLedgerRulesFinding -Code 'DOCS_LEDGER_BINDING_REQUIRED' -Severity 'error' -Pointer "$Pointer/page_bindings" -ArtifactPath $ArtifactPath -RelatedId @($id) -Message "The documented entry for $id has no page binding." -NextAction 'Bind the element to at least one page, or change its disposition.'))
    }
    if ($disposition -ceq 'excluded' -and $blank.rationale) {
        $findings.Add((New-DocsLedgerRulesFinding -Code 'DOCS_LEDGER_RATIONALE_REQUIRED' -Severity 'error' -Pointer "$Pointer/rationale" -ArtifactPath $ArtifactPath -RelatedId @($id) -Message "The excluded entry for $id has no rationale." -NextAction 'Record why the element is excluded from documentation.'))
    }
    if ($disposition -ceq 'deferred') {
        if ($blank.owner) { $findings.Add((New-DocsLedgerRulesFinding -Code 'DOCS_LEDGER_OWNER_REQUIRED' -Severity 'error' -Pointer "$Pointer/owner" -ArtifactPath $ArtifactPath -RelatedId @($id) -Message "The deferred entry for $id has no owner." -NextAction 'Record the owner responsible for documenting the element.')) }
        if ($blank.target) { $findings.Add((New-DocsLedgerRulesFinding -Code 'DOCS_LEDGER_TARGET_REQUIRED' -Severity 'error' -Pointer "$Pointer/target" -ArtifactPath $ArtifactPath -RelatedId @($id) -Message "The deferred entry for $id has no target." -NextAction 'Record when or where the element will be documented.')) }
    }
    return Get-DocsLedgerRulesOrderedFinding -Finding $findings.ToArray()
}

function Get-DocsLedgerLimitMismatchFinding {
    <#
    .SYNOPSIS
        Returns the DOCS_LEDGER_LIMIT_MISMATCH findings of one marked entry against its limit record (private helper).
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Entry,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Limit,
        [Parameter(Mandatory = $true)] [string] $Pointer,
        [AllowNull()] [string] $ArtifactPath
    )

    $findings = [System.Collections.Generic.List[object]]::new()
    $id = [string] $Limit['ElementId']
    $related = @($id, [string] $Limit['DiagnosticId'])
    $next = 'Record the precision limit with update-ledger -Operation set-disposition -Limit <diagnostic id> -Disposition deferred.'
    if ([string] (Get-DocsLedgerRulesMember -Table $Entry -Name 'disposition') -cne 'deferred') {
        $findings.Add((New-DocsLedgerRulesFinding -Code 'DOCS_LEDGER_LIMIT_MISMATCH' -Severity 'error' -Pointer "$Pointer/disposition" -ArtifactPath $ArtifactPath -RelatedId $related -Message "The precision-limit entry for $id is not deferred." -NextAction $next))
    }
    if ([string] (Get-DocsLedgerRulesMember -Table $Entry -Name 'analysis_method') -cne 'scanner') {
        $findings.Add((New-DocsLedgerRulesFinding -Code 'DOCS_LEDGER_LIMIT_MISMATCH' -Severity 'error' -Pointer "$Pointer/analysis_method" -ArtifactPath $ArtifactPath -RelatedId $related -Message "The precision-limit entry for $id does not record analysis_method scanner." -NextAction $next))
    }
    $marker = Get-DocsLedgerRulesMember -Table (Get-DocsLedgerRulesMember -Table $Entry -Name 'extensions') -Name $script:DocsLedgerRulesMarkerKey
    $expected = @{ analyzer_id = [string] $Limit['AnalyzerId']; code = [string] $Limit['Code']; diagnostic_id = [string] $Limit['DiagnosticId'] }
    foreach ($field in 'analyzer_id', 'code', 'diagnostic_id') {
        if ([string] (Get-DocsLedgerRulesMember -Table $marker -Name $field) -cne $expected[$field]) {
            $findings.Add((New-DocsLedgerRulesFinding -Code 'DOCS_LEDGER_LIMIT_MISMATCH' -Severity 'error' -Pointer (Get-DocsChildPointer -Pointer (Get-DocsChildPointer -Pointer "$Pointer/extensions" -Part $script:DocsLedgerRulesMarkerKey) -Part $field) -ArtifactPath $ArtifactPath -RelatedId $related -Message "The precision-limit marker of the entry for $id differs from the snapshot diagnostic in $field." -NextAction $next))
        }
    }
    return , $findings.ToArray()
}

function Get-DocsLedgerFinding {
    <#
    .SYNOPSIS
        Returns the ordered ledger findings of a ledger against a snapshot view.
    .DESCRIPTION
        Reports the companion rules, DOCS_LEDGER_DUPLICATE_ENTRY, DOCS_LEDGER_ORPHAN_ENTRY,
        DOCS_LEDGER_KIND_MISMATCH, DOCS_LEDGER_ANALYSIS_METHOD_CHANGED (warning),
        DOCS_LEDGER_MISSING_DISPOSITION, DOCS_LEDGER_LIMIT_UNRECORDED, DOCS_LEDGER_LIMIT_MISMATCH,
        DOCS_LEDGER_LIMIT_RESOLVED (warning) and DOCS_LEDGER_SNAPSHOT_REF (warning). An element is
        covered by an entry without the marker; a precision limit is recorded by any entry with its
        id and consistent only with a marked deferred scanner entry. SnapshotView is the result of
        ConvertTo-DocsSnapshotView.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $Ledger,
        [Parameter(Mandatory = $true)] [System.Collections.IDictionary] $SnapshotView,
        [AllowNull()] [string] $ArtifactPath
    )

    $findings = [System.Collections.Generic.List[object]]::new()
    $elements = $SnapshotView['Element']
    $limits = $SnapshotView['PrecisionLimit']
    $entries = @(Get-DocsLedgerRulesMember -Table $Ledger -Name 'entries')
    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    $covered = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    for ($index = 0; $index -lt $entries.Count; $index++) {
        $entry = $entries[$index]
        if ($entry -isnot [System.Collections.IDictionary]) { continue }
        $pointer = "/entries/$index"
        $id = [string] (Get-DocsLedgerRulesMember -Table $entry -Name 'element_id')
        $companion = Get-DocsLedgerEntryCompanionFinding -Entry $entry -Pointer $pointer -ArtifactPath $ArtifactPath
        foreach ($finding in $companion) { $findings.Add($finding) }
        if (-not $seen.Add($id)) {
            $findings.Add((New-DocsLedgerRulesFinding -Code 'DOCS_LEDGER_DUPLICATE_ENTRY' -Severity 'error' -Pointer "$pointer/element_id" -ArtifactPath $ArtifactPath -RelatedId @($id) -Message "The ledger holds more than one entry for $id." -NextAction 'Keep exactly one entry per element id.'))
        }
        if (Test-DocsLedgerRulesMarker -Record $entry) {
            if ($limits.ContainsKey($id)) {
                $mismatch = Get-DocsLedgerLimitMismatchFinding -Entry $entry -Limit $limits[$id] -Pointer $pointer -ArtifactPath $ArtifactPath
                foreach ($finding in $mismatch) { $findings.Add($finding) }
            } else {
                $findings.Add((New-DocsLedgerRulesFinding -Code 'DOCS_LEDGER_LIMIT_RESOLVED' -Severity 'warning' -Pointer $pointer -ArtifactPath $ArtifactPath -RelatedId @($id) -Message "The precision-limit entry for $id names a diagnostic that is absent from the snapshot." -NextAction 'Remove the entry with update-ledger -Operation remove-entry -Limit <diagnostic id>; the replacement element, if any, needs its own disposition.'))
            }
            continue
        }
        [void]$covered.Add($id)
        if ($elements.ContainsKey($id)) {
            $element = $elements[$id]
            if ([string] (Get-DocsLedgerRulesMember -Table $entry -Name 'kind') -cne [string] $element['kind']) {
                $findings.Add((New-DocsLedgerRulesFinding -Code 'DOCS_LEDGER_KIND_MISMATCH' -Severity 'error' -Pointer "$pointer/kind" -ArtifactPath $ArtifactPath -RelatedId @($id) -RelatedPath @([string] $element['path']) -Message "The entry for $id records kind $($entry['kind']) but the element kind is $($element['kind'])." -NextAction 'Replace the entry with update-ledger -Operation set-disposition so the kind is copied from the current element.'))
            }
            if ([string] (Get-DocsLedgerRulesMember -Table $entry -Name 'analysis_method') -cne [string] $element['analysis_method']) {
                $findings.Add((New-DocsLedgerRulesFinding -Code 'DOCS_LEDGER_ANALYSIS_METHOD_CHANGED' -Severity 'warning' -Pointer "$pointer/analysis_method" -ArtifactPath $ArtifactPath -RelatedId @($id) -RelatedPath @([string] $element['path']) -Message "The entry for $id records analysis_method $($entry['analysis_method']) but the element was analyzed by $($element['analysis_method'])." -NextAction 'Run update-ledger -Operation sync-refs to refresh the analysis method.'))
            }
        } elseif ($limits.ContainsKey($id)) {
            $findings.Add((New-DocsLedgerRulesFinding -Code 'DOCS_LEDGER_LIMIT_MISMATCH' -Severity 'error' -Pointer "$pointer/extensions" -ArtifactPath $ArtifactPath -RelatedId @($id, [string] $limits[$id]['DiagnosticId']) -Message "The entry for the precision-limit id $id lacks the docs.precision-limit marker." -NextAction 'Record the precision limit with update-ledger -Operation set-disposition -Limit <diagnostic id> -Disposition deferred.'))
        } else {
            $findings.Add((New-DocsLedgerRulesFinding -Code 'DOCS_LEDGER_ORPHAN_ENTRY' -Severity 'error' -Pointer "$pointer/element_id" -ArtifactPath $ArtifactPath -RelatedId @($id) -Message "The entry for $id names no current element or precision limit." -NextAction 'Remove the entry with update-ledger -Operation remove-entry, or regenerate the snapshot.'))
        }
    }

    [string[]] $elementIds = @($elements.Keys | ForEach-Object { [string] $_ })
    [Array]::Sort($elementIds, [System.StringComparer]::Ordinal)
    foreach ($id in $elementIds) {
        if ($covered.Contains($id)) { continue }
        $element = $elements[$id]
        $findings.Add((New-DocsLedgerRulesFinding -Code 'DOCS_LEDGER_MISSING_DISPOSITION' -Severity 'error' -Pointer '/entries' -ArtifactPath $ArtifactPath -RelatedId @($id) -RelatedPath @([string] $element['path']) -Message "The $($element['kind']) '$($element['declaration'])' ($id) has no ledger entry." -NextAction 'Record a disposition with update-ledger -Operation set-disposition -Element <id>.'))
    }
    [string[]] $limitIds = @($limits.Keys | ForEach-Object { [string] $_ })
    [Array]::Sort($limitIds, [System.StringComparer]::Ordinal)
    foreach ($id in $limitIds) {
        if ($seen.Contains($id)) { continue }
        $limit = $limits[$id]
        $findings.Add((New-DocsLedgerRulesFinding -Code 'DOCS_LEDGER_LIMIT_UNRECORDED' -Severity 'error' -Pointer '/entries' -ArtifactPath $ArtifactPath -RelatedId @($id, [string] $limit['DiagnosticId']) -RelatedPath @([string] $limit['Path']) -Message "The analyzer $($limit['AnalyzerId']) reported the precision limit $($limit['Code']) in $($limit['Path']) (diagnostic $($limit['DiagnosticId'])), and the ledger has no entry for $id." -NextAction 'Record the precision limit with update-ledger -Operation set-disposition -Limit <diagnostic id> -Disposition deferred -Owner <id> -Target <text>.'))
    }

    $reference = Get-DocsLedgerRulesMember -Table (Get-DocsLedgerRulesMember -Table $Ledger -Name 'snapshot_ref') -Name 'sha256'
    if ([string] $reference -cne [string] $SnapshotView['Sha256']) {
        $findings.Add((New-DocsLedgerRulesFinding -Code 'DOCS_LEDGER_SNAPSHOT_REF' -Severity 'warning' -Pointer '/snapshot_ref/sha256' -ArtifactPath $ArtifactPath -Message 'The ledger snapshot_ref digest differs from the current snapshot bytes.' -NextAction 'Run update-ledger -Operation sync-refs after regenerating the snapshot.'))
    }
    return Get-DocsLedgerRulesOrderedFinding -Finding $findings.ToArray()
}

Export-ModuleMember -Function `
    Get-DocsLedgerEntryCompanionFinding, `
    Get-DocsLedgerFinding
