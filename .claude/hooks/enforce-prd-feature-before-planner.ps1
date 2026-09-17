<#
.SYNOPSIS
    Pre-tool-use hook that blocks atomic-planner delegations when the target
    feature folder does not yet contain the prd-feature outputs its persisted
    work mode requires.

.DESCRIPTION
    Invoked by the Claude Code PreToolUse hook on the Agent (Task) tool. Reads
    the tool payload through the shared hook-payload reader (stdin first, with
    environment-variable fallback) and takes the tool arguments from the
    envelope's nested tool_input object. Activates only when subagent_type is
    'atomic-planner'.

    Feature folder resolution order:
      1. Scan the prompt text for any path matching
         docs/features/active/<token>, accepting both forward-slash and
         backslash separators. Truncate every match to two segments past the
         docs/features/active/ prefix -- that is, to exactly four path segments:
         docs, features, active, and the feature-folder name. Truncation is
         depth-insensitive, so the feature folder itself, a spec.md path, a
         research/ artifact path, and an evidence/ artifact path all resolve to
         the same folder. A match that truncates to fewer than four segments is
         rejected. Candidates are deduplicated preserving first-occurrence
         order.
      2. Select among the distinct candidates: one candidate is used directly;
         otherwise the candidate equal to the checkpoint's feature-folder field
         is preferred, because the checkpoint is the orchestrator's own record of
         which feature is in flight; otherwise the earliest-occurring candidate
         in the prompt wins, because the orchestrator names the active feature
         folder before citing artifacts inside it.
      3. If no candidate was found in the prompt, read the feature-folder field
         from artifacts/orchestration/orchestrator-state.json.
      4. If neither yields a folder, block with a reason instructing the caller
         to reference a feature folder explicitly.

    Known limitation: resolution stops at the feature-folder segment, so it does
    not descend into a version folder (v1/, v2/). No versioned folder exists
    under docs/features/active/ today, and issue.md sits at the feature root in
    every case, so the limitation is inert; it is recorded here rather than coded
    around.

    Once the folder is resolved, the hook reads the persisted work-mode marker
    (`- Work Mode: minor-audit|full-feature|full-bug|full`) from that folder's
    issue.md, per the mode contract in
    .claude/skills/feature-promotion-lifecycle/SKILL.md, and derives the
    required prerequisite set:
      - full-feature -> spec.md and user-story.md are both required.
      - full-bug     -> spec.md only is required.
      - minor-audit  -> neither is required; issue.md carries the acceptance
                        criteria for this mode.
      - marker absent, unreadable, or unrecognized -> deny on a distinct
        decision path that names the resolved folder and the issue.md path it
        probed and states adding or correcting the marker as the remedy. That
        path does not run the required-file probe and names neither prerequisite
        document, because when the mode is unknown no prerequisite set is
        knowable: a set containing user-story.md cannot be satisfied by full-bug
        or minor-audit work without violating the lifecycle contract, and the
        empty set would fail open. The delegation is still denied, so the gate
        remains fail-closed. The legacy `full` marker normalizes to
        full-feature's requirement set.

    If any required file is missing, the script emits a PreToolUse JSON
    response with hookSpecificOutput.permissionDecision='deny' and a reason
    naming the missing file(s) and instructing the orchestrator to invoke
    prd-feature first. Allowed delegations emit
    hookSpecificOutput.permissionDecision='allow'.

    Filesystem reads and orchestrator-state lookups go through wrapper functions
    so tests can inject fakes without touching disk.

.NOTES
    Compatible with PowerShell 7+. Read-only validation gate.
#>
[CmdletBinding()]
param()


Import-Module (Join-Path $PSScriptRoot '../lib/hook-payload/HookPayload.psm1') -Force
. (Join-Path $PSScriptRoot 'enforce-prd-feature-before-planner-helpers.ps1')
function Get-PrdFeatureFileExistence {
    <#
    .SYNOPSIS
        Wrapper around Test-Path for sibling-file existence checks. Tests mock this.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [string] $Path
    )

    return [bool](Test-Path -LiteralPath $Path -PathType Leaf)
}

function Get-PrdFeatureIssueContent {
    <#
    .SYNOPSIS
        Wrapper around Get-Content for a feature folder's issue.md. Tests mock
        this directly to inject work-mode marker content without touching disk.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string] $FeatureFolder
    )

    $issuePath = "$FeatureFolder/issue.md"
    if (-not (Test-Path -LiteralPath $issuePath -PathType Leaf)) {
        return $null
    }

    try {
        return Get-Content -LiteralPath $issuePath -Raw -ErrorAction Stop
    }
    catch {
        return $null
    }
}

function Resolve-PrdFeatureWorkMode {
    <#
    .SYNOPSIS
        Parses the persisted `- Work Mode: ...` marker out of issue.md content
        and returns the canonical mode, or $null when the marker is absent,
        unreadable, or unrecognized.
    .DESCRIPTION
        Recognizes minor-audit, full-feature, full-bug, and the legacy full
        marker (normalized to full-feature), mirroring the regex convention
        used by scripts/dev_tools/prompt_mode_contract.py so both runtimes
        agree on what counts as a valid marker line.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()]
        [string] $IssueContent
    )

    if ([string]::IsNullOrWhiteSpace($IssueContent)) {
        return $null
    }

    $match = [regex]::Match($IssueContent, '(?im)^-\s*Work Mode:\s*(minor-audit|full-feature|full-bug|full)\s*$')
    if (-not $match.Success) {
        return $null
    }

    $rawMode = $match.Groups[1].Value
    if ($rawMode -eq 'full') {
        return 'full-feature'
    }
    return $rawMode
}

function Get-PrdFeatureRequiredFile {
    <#
    .SYNOPSIS
        Maps a resolved work mode to the set of prd-feature output files the
        target folder must contain before an atomic-planner delegation is
        allowed.
    .DESCRIPTION
        full-feature requires spec.md and user-story.md; full-bug requires
        spec.md only; minor-audit requires neither.

        The default arm returns spec.md alone. It is not reached from the
        decision path for an undeterminable mode, which denies on its own branch
        without probing at all; the arm exists so a direct caller passing a $null
        or unrecognized mode never receives a permissive empty set, and it must
        not name user-story.md, because that document is required to be ABSENT
        for full-bug and minor-audit work.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [AllowNull()]
        [string] $WorkMode
    )

    # Route on the canonical mode; anything outside the three known values
    # (including $null) falls through to the fail-closed default case.
    switch ($WorkMode) {
        'full-feature' { return [string[]]@('spec.md', 'user-story.md') }
        'full-bug' { return [string[]]@('spec.md') }
        'minor-audit' { return [string[]]@() }
        default { return [string[]]@('spec.md') }
    }
}

function Get-PrdFeatureCheckpointFolder {
    <#
    .SYNOPSIS
        Returns the feature-folder field from the orchestrator checkpoint, or
        $null when the file or field is absent.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [string] $CheckpointPath = 'artifacts/orchestration/orchestrator-state.json'
    )

    if (-not (Test-Path -LiteralPath $CheckpointPath -PathType Leaf)) {
        return $null
    }

    try {
        $raw = Get-Content -LiteralPath $CheckpointPath -Raw -ErrorAction Stop
        $obj = $raw | ConvertFrom-Json -ErrorAction Stop
    }
    catch {
        return $null
    }

    if ($obj.PSObject.Properties.Name -contains 'feature-folder' -and $obj.'feature-folder') {
        return [string]$obj.'feature-folder'
    }
    return $null
}

function Get-PrdFeatureMissingFile {
    <#
    .SYNOPSIS
        Returns the subset of $RequiredFile that is missing from the target
        folder.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)]
        [string] $FeatureFolder,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]] $RequiredFile
    )

    [System.Collections.Generic.List[string]] $missing = [System.Collections.Generic.List[string]]::new()
    foreach ($name in $RequiredFile) {
        $candidate = "$FeatureFolder/$name"
        if (-not (Get-PrdFeatureFileExistence -Path $candidate)) {
            $missing.Add($name)
        }
    }
    return [string[]] $missing.ToArray()
}

function Invoke-PrdFeatureBeforePlannerDecision {
    <#
    .SYNOPSIS
        Parses the envelope's nested tool_input and returns an allow-or-block decision.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [string] $ToolInputRaw
    )

    $envelope = Resolve-ClaudeHookToolInput -Raw $ToolInputRaw
    if (-not $envelope.IsValid) {
        return [ordered]@{
            hookSpecificOutput = [ordered]@{
                hookEventName            = 'PreToolUse'
                permissionDecision       = 'deny'
                permissionDecisionReason = 'PRD_FEATURE_BLOCKED: payload anomaly - ' +
                (Get-ClaudeHookPayloadAnomalyReason -Anomaly $envelope.Anomaly) +
                '. The gate fails closed on an envelope it cannot read.'
            }
        }
    }

    $subagent = Get-ClaudeHookToolInputString -ToolInput $envelope.Value -Name 'subagent_type'
    if (-not $subagent -or $subagent -ne 'atomic-planner') {
        return [ordered]@{ hookSpecificOutput = [ordered]@{ hookEventName = 'PreToolUse'; permissionDecision = 'allow' } }
    }

    $prompt = Get-ClaudeHookToolInputString -ToolInput $envelope.Value -Name 'prompt'
    $folder = Find-PrdFeatureFolderFromPrompt -Prompt $prompt
    if (-not $folder) {
        $folder = Get-PrdFeatureCheckpointFolder
    }

    if (-not $folder) {
        return [ordered]@{
            hookSpecificOutput = [ordered]@{
                hookEventName            = 'PreToolUse'
                permissionDecision       = 'deny'
                permissionDecisionReason = "PRD_FEATURE_BLOCKED: atomic-planner delegation must reference a feature folder (either in the prompt or via orchestrator-state.json) so spec.md and user-story.md prerequisites can be verified."
            }
        }
    }

    $folderNormalized = ($folder -replace '\\', '/').TrimEnd('/')

    # Derive the prerequisite set from the persisted work-mode marker rather
    # than a fixed spec.md/user-story.md pair. A marker that cannot be read or
    # recognized must fail closed, not fail open: it denies on its own branch
    # below, naming no prerequisite set and probing for no required file.
    $issueContent = Get-PrdFeatureIssueContent -FeatureFolder $folderNormalized
    $workMode = Resolve-PrdFeatureWorkMode -IssueContent $issueContent

    # An indeterminate mode is its own decision path, and it deliberately does NOT
    # run the required-file probe. When the mode is unknown no prerequisite set is
    # knowable, so any set the gate named would be wrong for at least one mode:
    # a set containing user-story.md is unsatisfiable for full-bug and minor-audit
    # without violating the lifecycle contract, and the empty set fails open. The
    # only remedy true in all three modes is repairing the marker, so that is what
    # the reason states. This still DENIES, so the gate remains fail-closed.
    if (-not $workMode) {
        return [ordered]@{
            hookSpecificOutput = [ordered]@{
                hookEventName            = 'PreToolUse'
                permissionDecision       = 'deny'
                permissionDecisionReason = "PRD_FEATURE_BLOCKED: resolved feature folder '$folderNormalized', " +
                "but its work mode could not be determined from '$folderNormalized/issue.md' " +
                '(the ''- Work Mode:'' marker is absent, unreadable, or unrecognized). ' +
                'Confirm that is the intended feature folder, then add or correct the ' +
                '''- Work Mode:'' marker in that file so the prerequisite set can be derived.'
            }
        }
    }

    # Force array wrapping: PowerShell unravels a zero-element array return down
    # the pipeline to $null, which would otherwise fail the Mandatory
    # -RequiredFile parameter on Get-PrdFeatureMissingFile for minor-audit mode.
    $required = @(Get-PrdFeatureRequiredFile -WorkMode $workMode)

    $missing = Get-PrdFeatureMissingFile -FeatureFolder $folderNormalized -RequiredFile $required
    if ($missing.Count -eq 0) {
        return [ordered]@{ hookSpecificOutput = [ordered]@{ hookEventName = 'PreToolUse'; permissionDecision = 'allow' } }
    }

    # Lead with the resolved folder, not with the remedy: a reader who sees a
    # folder they did not intend diagnoses a path problem immediately instead of
    # re-running a step that has already completed correctly.
    $list = ($missing -join ', ')
    $reason = "PRD_FEATURE_BLOCKED: resolved feature folder '$folderNormalized' is missing: " +
    "$list (work mode: $workMode). Confirm that is the intended feature folder, then " +
    'invoke the prd-feature subagent to produce the missing output(s).'

    return [ordered]@{
        hookSpecificOutput = [ordered]@{
            hookEventName            = 'PreToolUse'
            permissionDecision       = 'deny'
            permissionDecisionReason = $reason
        }
    }
}

# Guard allows dot-sourcing in tests without executing the entrypoint.
if ($MyInvocation.InvocationName -eq '.') {
    return
}

$decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw (Read-ClaudeHookRawPayload)

$decision | ConvertTo-Json -Compress -Depth 5 | Write-Output

exit 0
