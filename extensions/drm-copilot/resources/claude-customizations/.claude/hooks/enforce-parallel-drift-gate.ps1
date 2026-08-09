<#
.SYNOPSIS
    Pre-tool-use hook that is the Layer 1 per-call deterrent for the parallel drift gate.

.DESCRIPTION
    Invoked by the Claude Code PreToolUse hook on the "Agent" matcher. Activates only when
    CLAUDE_TOOL_INPUT.subagent_type == "feature-review" and the prompt carries the
    parallel-mode kickoff marker defined in the "Parallel-Mode Kickoff Parameter" section
    of .claude/skills/parallel-orchestrate/SKILL.md, matched byte-for-byte (ordinal).

    Decision procedure: resolve the target item's feature folder from the prompt by scanning
    for a docs/features/active/<token> path, the shape the parallel kickoff contract emits
    for exactly this purpose (adapted from enforce-epic-wave-barrier.ps1's
    Find-EpicWaveBarrierFeatureFolderFromPrompt: longest match wins, a .md-suffixed match
    uses its parent directory); read the parallel checkpoint and locate the items[] record
    whose feature_folder basename matches; derive which item keys have an unresolved latest
    drift event; deny with PARALLEL_DRIFT_GATE_BLOCKED when the resolved item is one of them
    and its synthetic Blocking finding file has not been written. Allowed: a
    non-feature-review target, a prompt without the marker, a resolved latest event, and an
    unresolved event whose finding file exists, so the R1-R5 remediation review is never
    deadlocked. A missing or unreadable checkpoint, or an unresolvable target item, denies
    (fail-closed).

    PRESENCE GATING ONLY: checkpoint-state reads plus exactly one finding-file existence
    check through the finding-presence seam. No git command, no diff computation, and no
    path-glob matching; all path-matching semantics stay in the single Python
    implementation, scripts/dev_tools/parallel_drift_detection.py.

    Resolution semantics are owned by Python, not reimplemented here. That module's
    unresolved_drift_item_keys derives resolution from two disjuncts: (a) the recorded
    radius widened to cover every escaped path, evaluated with F1's is_path_subsumed glob
    semantics; or (b) the radius was re-recorded from a later observed diff (source ==
    'observed' and computed_at strictly greater than the event's at). This hook implements
    only the narrower check Layer 1 needs -- latest-event selection plus disjunct (b), which
    is ordinal string comparison and needs no glob matcher. Omitting disjunct (a) can only
    report unresolved where Python reports resolved, the fail-closed direction, and the
    finding-file allowance keeps that from deadlocking review. The cross-runtime seam test in
    tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 runs both runtimes over
    one shared checkpoint-state table and fails when they diverge. Layer 2, the retrospective
    backstop, is the PARALLEL_DRIFT_GATE_VIOLATION invariant in
    scripts/dev_tools/_parallel_orchestrator_state_drift.py.

.NOTES
    PowerShell 7+, no module dependencies. Both read boundaries -- the checkpoint read and the
    finding-file existence check -- are injectable wrapper functions, so tests mock them
    without writing temporary files.
#>
[CmdletBinding()]
param()

$script:ParallelCheckpointPath = 'artifacts/orchestration/parallel-orchestrator-state.json'
$script:ParallelModeMarker = 'Parallel mode: true'
$script:ReviewSubagentType = 'feature-review'
$script:ActiveFeatureRoot = 'docs/features/active'
$script:FindingFilePrefix = 'remediation-inputs.'
$script:FindingFileSuffix = '.md'
$script:ObservedRadiusSource = 'observed'

function Get-ParallelDriftGateCheckpointContent {
    <#
    .SYNOPSIS
        Read the raw JSON text of the parallel checkpoint, or $null when the file is absent.
        Tests mock this function (checkpoint-read seam).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    if (-not (Test-Path -LiteralPath $script:ParallelCheckpointPath -PathType Leaf)) {
        return $null
    }
    return (Get-Content -LiteralPath $script:ParallelCheckpointPath -Raw)
}

function Test-ParallelDriftFindingPresent {
    <#
    .SYNOPSIS
        Report whether the item's synthetic Blocking finding file exists. Tests mock this
        function (finding-presence seam).
    .DESCRIPTION
        The parallel-orchestrator writes the finding as remediation-inputs.<timestamp>.md in
        the child's own active feature folder (flat form), reached through the item's recorded
        worktree_path, which is optional in the schema and may be null: absence reports $false
        so the caller fails closed. Names are compared with ordinal prefix and suffix tests, so
        no glob matcher is involved.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()][AllowEmptyString()][string] $WorktreePath,
        [AllowNull()][AllowEmptyString()][string] $FeatureFolder
    )

    if ([string]::IsNullOrWhiteSpace($WorktreePath) -or [string]::IsNullOrWhiteSpace($FeatureFolder)) {
        return $false
    }
    $folder = Join-Path -Path $WorktreePath -ChildPath $script:ActiveFeatureRoot -AdditionalChildPath $FeatureFolder
    if (-not (Test-Path -LiteralPath $folder -PathType Container)) {
        return $false
    }

    # Report on the first remediation-inputs.<timestamp>.md entry; the timestamp varies per
    # cycle, so the name is matched by ordinal prefix and suffix rather than a pattern.
    foreach ($entry in @(Get-ChildItem -LiteralPath $folder -File)) {
        $name = [string]$entry.Name
        if ($name.StartsWith($script:FindingFilePrefix, [System.StringComparison]::Ordinal) -and
            $name.EndsWith($script:FindingFileSuffix, [System.StringComparison]::Ordinal)) {
            return $true
        }
    }
    return $false
}

function Find-ParallelDriftGateFeatureFolderFromPrompt {
    <#
    .SYNOPSIS
        Scan a delegation prompt for docs/features/active/<...> path tokens and return the
        longest unique match's basename, or $null when none is found.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][AllowEmptyString()][string] $Prompt)

    if (-not $Prompt) {
        return $null
    }
    $matchList = [regex]::Matches($Prompt, 'docs[\\/]+features[\\/]+active[\\/]+[^\s"''`]+')
    if ($matchList.Count -eq 0) {
        return $null
    }

    # Collect distinct normalized tokens so the longest, most specific one can be selected.
    $unique = @{}
    foreach ($found in $matchList) {
        $unique[($found.Value -replace '\\', '/').TrimEnd('/')] = $true
    }

    $best = @(@($unique.Keys) | Sort-Object -Property Length -Descending)[0]
    if ($best -match '\.md$') {
        $best = $best -replace '/[^/]+\.md$', ''
    }
    return ($best -split '/')[-1]
}

function Test-ParallelDriftGateItemKey {
    <#
    .SYNOPSIS
        Report whether a checkpoint value is a positive, non-boolean integer issue_num,
        mirroring is_positive_integer in scripts/dev_tools/_parallel_state_common.py.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] $Value)

    # A boolean in a numeric slot is malformed data, not a value to coerce.
    if ($Value -is [bool] -or -not ($Value -is [int] -or $Value -is [long])) {
        return $false
    }
    return ([long]$Value -gt 0)
}

function Test-ParallelDriftGateText {
    <#
    .SYNOPSIS
        Report whether a checkpoint value is a string carrying a non-space character,
        mirroring is_non_empty_string in scripts/dev_tools/_parallel_state_common.py.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] $Value)

    return ($Value -is [string]) -and (-not [string]::IsNullOrWhiteSpace([string]$Value))
}

function Test-ParallelDriftGateEventRecord {
    <#
    .SYNOPSIS
        Report whether one drift_events[] entry is well formed in the three fields this
        derivation reads.
    .DESCRIPTION
        item_key must resolve as an issue_num and at must be non-empty. escaped_paths must be a
        non-empty list of non-empty strings: F3 invariant 18 rejects a zero-escape event.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()] $Record)

    if ($null -eq $Record -or
        -not (Test-ParallelDriftGateItemKey -Value $Record.item_key) -or
        -not (Test-ParallelDriftGateText -Value $Record.at) -or
        $Record.escaped_paths -isnot [System.Collections.IList]) {
        return $false
    }
    $escaped = @($Record.escaped_paths)
    if ($escaped.Count -eq 0) {
        return $false
    }

    # One blank or non-string entry fails the whole list, matching is_string_list.
    foreach ($path in $escaped) {
        if (-not (Test-ParallelDriftGateText -Value $path)) {
            return $false
        }
    }
    return $true
}

function Get-ParallelDriftGateLatestEventMap {
    <#
    .SYNOPSIS
        Reduce drift_events[] to the latest event timestamp of each item key, returning an
        OrderedDictionary with Malformed (bool) and LatestAt (item key to at).
    .DESCRIPTION
        Latest means the greatest at, ordinally compared so the ranking matches Python's
        string ordering, with ties broken by append order so the later-appended record wins.
        One malformed entry anywhere makes the whole log unreadable, matching
        has_unresolved_drift's malformed-log verdict. A $null checkpoint is unreadable too.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([AllowNull()] $Checkpoint)

    $latestAt = @{}
    if ($null -eq $Checkpoint) {
        return [ordered]@{ Malformed = $true; LatestAt = $latestAt }
    }

    # An absent drift_events key is the pre-drift checkpoint shape: no events, no drift. A
    # present but non-list value cannot be reduced, so it fails closed.
    if (@($Checkpoint.PSObject.Properties.Name) -notcontains 'drift_events') {
        return [ordered]@{ Malformed = $false; LatestAt = $latestAt }
    }
    if ($Checkpoint.drift_events -isnot [System.Collections.IList]) {
        return [ordered]@{ Malformed = $true; LatestAt = $latestAt }
    }

    # Walk the append-ordered log once so each item's latest event is resolved in a single
    # pass; a malformed entry aborts the whole derivation. Replacing the record on a comparison
    # of zero is what makes append order the tie-break, matching Python's (at, index) rank.
    foreach ($record in @($Checkpoint.drift_events)) {
        if (-not (Test-ParallelDriftGateEventRecord -Record $record)) {
            return [ordered]@{ Malformed = $true; LatestAt = @{} }
        }
        $key = [long]$record.item_key
        $atText = [string]$record.at
        $comparison = 1
        if ($latestAt.ContainsKey($key)) {
            $comparison = [string]::CompareOrdinal($atText, [string]$latestAt[$key])
        }
        if ($comparison -ge 0) {
            $latestAt[$key] = $atText
        }
    }
    return [ordered]@{ Malformed = $false; LatestAt = $latestAt }
}

function Get-ParallelDriftGateItemRadiusMap {
    <#
    .SYNOPSIS
        Index the readable blast_radius blocks of items[] by item key.
    .DESCRIPTION
        An item with an unreadable issue_num or a non-object blast_radius is skipped rather
        than rejected: the caller treats absence as unresolved (fail closed), and shape
        reporting belongs to the checkpoint validator.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([AllowNull()] $Checkpoint)

    $radii = @{}
    if ($null -eq $Checkpoint -or (@($Checkpoint.PSObject.Properties.Name) -notcontains 'items')) {
        return $radii
    }

    # Collect only the item records whose key and radius are both readable.
    foreach ($item in @($Checkpoint.items)) {
        if ($null -eq $item -or -not (Test-ParallelDriftGateItemKey -Value $item.issue_num)) {
            continue
        }
        if ($item.blast_radius -is [System.Management.Automation.PSCustomObject]) {
            $radii[[long]$item.issue_num] = $item.blast_radius
        }
    }
    return $radii
}

function Test-ParallelDriftGateEventResolved {
    <#
    .SYNOPSIS
        Apply the re-recorded-radius resolution disjunct to one item's latest drift event.
    .DESCRIPTION
        The narrowed Layer 1 check described in the script header: only the disjunct that
        needs no glob matcher is evaluated, a radius re-recorded from a diff taken after the
        event (source == 'observed' and computed_at strictly greater than the event's at).
        Comparisons are ordinal and case-sensitive so the verdict matches Python's. A missing
        or unreadable radius is unresolved (fail closed).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()] $Radius,
        [Parameter(Mandatory)][AllowEmptyString()][string] $At
    )

    if ($null -eq $Radius -or (([string]$Radius.source) -cne $script:ObservedRadiusSource)) {
        return $false
    }
    if (-not (Test-ParallelDriftGateText -Value $Radius.computed_at)) {
        return $false
    }
    return ([string]::CompareOrdinal([string]$Radius.computed_at, $At) -gt 0)
}

function Get-ParallelDriftGateUnresolvedState {
    <#
    .SYNOPSIS
        Derive the item keys whose latest drift event is still unresolved, returning an
        OrderedDictionary with Malformed (bool) and UnresolvedItemKeys (long[], ascending).
    .DESCRIPTION
        The PowerShell counterpart of unresolved_drift_item_keys in
        scripts/dev_tools/parallel_drift_detection.py, narrowed as the script header records.
        Malformed reports the case the Python derivation reports by raising, which
        has_unresolved_drift treats as unresolved.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([AllowNull()] $Checkpoint)

    $latestState = Get-ParallelDriftGateLatestEventMap -Checkpoint $Checkpoint
    if ($latestState.Malformed) {
        return [ordered]@{ Malformed = $true; UnresolvedItemKeys = [long[]]@() }
    }

    # Keep the drifted items the resolution disjunct does not clear, sorted so the result is
    # deterministic and directly comparable with the Python derivation.
    $radii = Get-ParallelDriftGateItemRadiusMap -Checkpoint $Checkpoint
    $unresolved = [System.Collections.Generic.List[long]]::new()
    foreach ($itemKey in @($latestState.LatestAt.Keys)) {
        $radius = if ($radii.ContainsKey($itemKey)) { $radii[$itemKey] } else { $null }
        if (-not (Test-ParallelDriftGateEventResolved -Radius $radius -At ([string]$latestState.LatestAt[$itemKey]))) {
            $unresolved.Add([long]$itemKey)
        }
    }
    return [ordered]@{
        Malformed          = $false
        UnresolvedItemKeys = [long[]]@($unresolved | Sort-Object)
    }
}

function Find-ParallelDriftGateItemRecord {
    <#
    .SYNOPSIS
        Locate the items[] record whose feature_folder basename equals the target basename
        resolved from the prompt, or $null when none does.
    #>
    [CmdletBinding()]
    param(
        [AllowNull()] $Checkpoint,
        [AllowNull()][string] $FeatureFolder
    )

    if ($null -eq $Checkpoint -or [string]::IsNullOrWhiteSpace($FeatureFolder)) {
        return $null
    }
    if (@($Checkpoint.PSObject.Properties.Name) -notcontains 'items') {
        return $null
    }

    # feature_folder may be recorded as a bare basename or as a full repo-relative path, so
    # compare on the trailing segment of the normalized value.
    foreach ($item in @($Checkpoint.items)) {
        if ($null -eq $item -or -not (Test-ParallelDriftGateText -Value $item.feature_folder)) {
            continue
        }
        $normalized = (([string]$item.feature_folder) -replace '\\', '/').TrimEnd('/')
        if ((($normalized -split '/')[-1]) -ceq $FeatureFolder) {
            return $item
        }
    }
    return $null
}

function Get-ParallelDriftGateAllowDecision {
    <#
    .SYNOPSIS
        Build the PreToolUse allow decision payload.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param()

    return [ordered]@{
        hookSpecificOutput = [ordered]@{
            hookEventName      = 'PreToolUse'
            permissionDecision = 'allow'
        }
    }
}

function Get-ParallelDriftGateBlockDecision {
    <#
    .SYNOPSIS
        Build the PreToolUse deny decision payload carrying the PARALLEL_DRIFT_GATE_BLOCKED
        reason surfaced to the caller.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([Parameter(Mandatory)][string] $Reason)

    return [ordered]@{
        hookSpecificOutput = [ordered]@{
            hookEventName            = 'PreToolUse'
            permissionDecision       = 'deny'
            permissionDecisionReason = $Reason
        }
    }
}

function Invoke-ParallelDriftGateDecision {
    <#
    .SYNOPSIS
        Parse the raw CLAUDE_TOOL_INPUT JSON payload and return an allow-or-block decision.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param([string] $ToolInputRaw)

    if (-not $ToolInputRaw) {
        return Get-ParallelDriftGateAllowDecision
    }
    try {
        $toolInput = $ToolInputRaw | ConvertFrom-Json -ErrorAction Stop
    } catch {
        throw "enforce-parallel-drift-gate hook received malformed JSON in CLAUDE_TOOL_INPUT: $_"
    }

    # Two cheap disqualifiers first: this gate governs only feature-review delegations, and
    # only under the parallel-mode marker, matched byte-for-byte with an ordinal Contains
    # rather than a wildcard or a culture-sensitive comparison.
    if (([string]$toolInput.subagent_type) -cne $script:ReviewSubagentType) {
        return Get-ParallelDriftGateAllowDecision
    }
    $prompt = [string]$toolInput.prompt
    if (-not $prompt -or -not $prompt.Contains($script:ParallelModeMarker, [System.StringComparison]::Ordinal)) {
        return Get-ParallelDriftGateAllowDecision
    }

    $featureFolder = Find-ParallelDriftGateFeatureFolderFromPrompt -Prompt $prompt
    if (-not $featureFolder) {
        return Get-ParallelDriftGateBlockDecision -Reason 'PARALLEL_DRIFT_GATE_BLOCKED: a parallel-mode feature-review delegation must reference the target item feature folder in the prompt so its drift state can be verified.'
    }

    $checkpointRaw = Get-ParallelDriftGateCheckpointContent
    $checkpoint = $null
    if (-not [string]::IsNullOrWhiteSpace($checkpointRaw)) {
        try {
            $checkpoint = $checkpointRaw | ConvertFrom-Json -ErrorAction Stop
        } catch {
            $checkpoint = $null
        }
    }
    if ($null -eq $checkpoint) {
        return Get-ParallelDriftGateBlockDecision -Reason "PARALLEL_DRIFT_GATE_BLOCKED: the parallel checkpoint '$script:ParallelCheckpointPath' is missing or unreadable, so the drift state of '$featureFolder' cannot be verified."
    }

    $item = Find-ParallelDriftGateItemRecord -Checkpoint $checkpoint -FeatureFolder $featureFolder
    if ($null -eq $item -or -not (Test-ParallelDriftGateItemKey -Value $item.issue_num)) {
        return Get-ParallelDriftGateBlockDecision -Reason "PARALLEL_DRIFT_GATE_BLOCKED: no parallel checkpoint items[] record with a readable issue_num resolves to '$featureFolder', so its drift state cannot be verified."
    }

    # A resolved or never-drifted item is allowed outright. An unresolved item is allowed only
    # once its synthetic Blocking finding exists, so the remediation review that resolves the
    # drift is never deadlocked by this gate.
    $itemKey = [long]$item.issue_num
    $driftState = Get-ParallelDriftGateUnresolvedState -Checkpoint $checkpoint
    if (-not $driftState.Malformed -and ($driftState.UnresolvedItemKeys -notcontains $itemKey)) {
        return Get-ParallelDriftGateAllowDecision
    }
    if (Test-ParallelDriftFindingPresent -WorktreePath ([string]$item.worktree_path) -FeatureFolder $featureFolder) {
        return Get-ParallelDriftGateAllowDecision
    }

    return Get-ParallelDriftGateBlockDecision -Reason "PARALLEL_DRIFT_GATE_BLOCKED: item $itemKey ('$featureFolder') has an unresolved radius drift event and no $script:FindingFilePrefix<timestamp>$script:FindingFileSuffix finding recorded in its feature folder. The synthetic Blocking finding must be written before review proceeds, or the drift event log was unreadable."
}

# Guard allows dot-sourcing in tests without executing the entrypoint.
if ($MyInvocation.InvocationName -eq '.') {
    return
}

try {
    $decision = Invoke-ParallelDriftGateDecision -ToolInputRaw $env:CLAUDE_TOOL_INPUT
} catch {
    Write-Error $_
    exit 1
}

$decision | ConvertTo-Json -Compress -Depth 5 | Write-Output

exit 0
