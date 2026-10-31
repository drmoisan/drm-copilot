<#
.SYNOPSIS
    Epic-scope command and path legs of the Codex preimplementation gate (issue #707).

.DESCRIPTION
    Dot-sourced by enforce-orchestration-preimplementation-gate.ps1. The Codex counterpart
    of the issue #663 Claude sibling, holding three groups of functions:

    - The two per-mode read seams of issue #554 (Get-EpicCheckpointContent and
      Get-ParallelCheckpointContent), relocated verbatim from the gate file so the gate
      stays inside the 500-line cap. Their names and behaviour are unchanged, so tests
      that mock or shadow them by name are unaffected.
    - The target-resolution building blocks of issue #1010, byte-identical to the Claude
      sibling: the worktree-list wrapper Get-OrchestrationGateWorktreeList (the only
      listing seam), the recording invoker Invoke-OrchestrationGateWorktreeList, and the
      command-operand parser Get-OrchestrationGateCommandOperandPath, plus the reason-code
      pair restated from WorktreeResolution.psm1. They feed Resolve-OrchestrationGateTarget
      and Read-OrchestrationGateCheckpoint, which read the single-feature checkpoint through
      the Get-CheckpointContent seam (mandatory absolute Path, moved here from the gate)
      beneath the worktree the file path, apply_patch markers, or command operands name.
    - The epic-scope decision for the command, apply_patch, and path legs. A call is epic
      scope when the effective worktree's HEAD (the -C selector worktree when present,
      otherwise the session root) equals the integration_branch of
      artifacts/orchestration/epic-orchestrator-state.json. In epic scope the call is
      decided by the command-leg readiness predicate, and under issue #663 decision D2 an
      implementation-classified operand is allowed only while a merge is in progress in
      that worktree. Outside epic scope the decision function returns $null and the gate's
      single-feature path runs unchanged.

.NOTES
    PowerShell 7+. Functions only: no StrictMode and no preference assignment, because a
    dot-sourced file changes its caller's scope. Call-time dependencies:
    Split-OrchestrationCommandLine and ConvertTo-OrchestrationCommandToken (helpers file),
    Get-OrchestrationDelegationCheckpointPath (modes file), and the gate's allow and block
    decision constructors Get-OrchestrationPreimplementationGateAllowDecision and
    Get-OrchestrationPreimplementationGateBlockDecision. The resolver and its seams come
    from the resolution sibling dot-sourced below. The per-segment target resolver comes
    from the targets file dot-sourced below (issue #738), which calls
    Read-CommandLineSegment, Get-CommandLineGlobalOption, and Get-CommandLineInvocation,
    loaded by the gate's dot-source of hook-command-invocation.ps1. Resolve-HookTargetWorktree
    and ConvertFrom-HookTargetWorktreePorcelain come from the guarded dot-source of the
    resolver twin hook-target-worktree.ps1 (issue #1009).
    Mirrored byte-identically under extensions/drm-copilot/resources/codex-and-agents-customizations/.
    AUTHORITY: PowerShell-authoritative. The epic readiness predicate has no reference implementation in another language, and this hook starts no interpreter process (issue #707, D15).
#>

. (Join-Path $PSScriptRoot 'enforce-orchestration-preimplementation-gate-epic-resolution.ps1')
. (Join-Path $PSScriptRoot 'enforce-orchestration-preimplementation-gate-targets.ps1')
try { . (Join-Path $PSScriptRoot 'hook-target-worktree.ps1') } catch { Add-HookDependencyFailure -Name 'hook-target-worktree.ps1' -ErrorRecord $_ }

# The target-resolution reason codes (issue #1010). Their source is
# Get-WorktreeResolutionAmbiguityReasonCode and Get-WorktreeResolutionNoTargetReasonCode
# in .claude/lib/worktree-resolution/WorktreeResolution.psm1; Codex hooks cannot import
# .claude/lib, so the two literals are restated once here and pinned equal by a test.
$script:OrchestrationGateAmbiguousReasonCode = 'TARGET_WORKTREE_AMBIGUOUS'
$script:OrchestrationGateNotDerivableReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'

# An epic manifest lives under the epics tree; the pattern is tested after backslash
# normalisation so either separator spelling is accepted.
$script:EpicScopeManifestPattern = '(^|/)docs/features/epics/'

# The two per-mode read seams (issue #554). Each takes its path from the fixed mode
# table and never from a delegation's own text; an absent file returns an empty
# string, which the readiness predicate then treats as a deny.
function Get-EpicCheckpointContent {
    [CmdletBinding()]
    [OutputType([string])]
    param()

    $path = Get-OrchestrationDelegationCheckpointPath -Mode 'epic'
    if (-not (Test-Path -LiteralPath $path)) {
        return ''
    }
    return Get-Content -Raw -LiteralPath $path
}

function Get-ParallelCheckpointContent {
    [CmdletBinding()]
    [OutputType([string])]
    param()

    $path = Get-OrchestrationDelegationCheckpointPath -Mode 'parallel'
    if (-not (Test-Path -LiteralPath $path)) {
        return ''
    }
    return Get-Content -Raw -LiteralPath $path
}

# The single-feature read seam (issue #1010, moved from the gate file). It takes the
# absolute path composed beneath the resolved worktree root, so no read binds to the
# calling process's directory; an absent file returns an empty string.
function Get-CheckpointContent {
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][ValidatePattern('^([A-Za-z]:[\\/]|/)')][string] $Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return ''
    }
    return Get-Content -Raw -LiteralPath $Path
}

function Get-OrchestrationGateWorktreeList {
    <#
    .SYNOPSIS
        Returns the porcelain worktree listing for the session root (issue #1010 seam).
    .DESCRIPTION
        Runs the listing exactly as the default WorktreeListInvoker of
        Resolve-HookTargetWorktree does and returns an empty string on a non-zero exit. It
        is the only test seam for the listing.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][string] $SessionRoot)

    $porcelain = & git -C $SessionRoot worktree list --porcelain 2>$null
    if ($LASTEXITCODE -ne 0) { return '' }
    return ($porcelain -join "`n")
}

function Invoke-OrchestrationGateWorktreeList {
    <#
    .SYNOPSIS
        Recording WorktreeListInvoker: returns the listing and records a listing failure.
    .DESCRIPTION
        Sets $script:OrchestrationGateWorktreeListFailed when the wrapper throws (and then
        rethrows) or when its text holds no worktree entry, so the gate denies instead of
        accepting the resolver's session-root fallback (issue #1010, spec E1).
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][string] $SessionRoot)

    try {
        $text = [string](Get-OrchestrationGateWorktreeList -SessionRoot $SessionRoot)
    } catch {
        $script:OrchestrationGateWorktreeListFailed = $true
        throw
    }
    if (@(ConvertFrom-HookTargetWorktreePorcelain -Text $text).Count -eq 0) {
        $script:OrchestrationGateWorktreeListFailed = $true
    }
    return $text
}

function Get-OrchestrationGateCommandOperandPath {
    <#
    .SYNOPSIS
        Returns the worktree-selecting paths of every git add and git commit invocation.
    .DESCRIPTION
        Scans every Structural match of git add and git commit (every command segment and
        wrapper payload). Each -C value in any git global-option position and each absolute
        operand is returned, distinct and in first-seen order. Relative operands, a -C on a
        git segment invoking neither add nor commit, and Indeterminate matches are ignored.
        For a match whose record is not argument-injected, a subcommand-aware walk (issue
        #1010, F2) also reads the tokens after the subcommand with a per-subcommand option
        model, compared case-sensitively: a value option consumes the next token unless its
        value is inline (--name=value) or attached (-mvalue); a standalone flag consumes
        itself; '--' makes every later token an operand; a redirection and its target are
        skipped; any other dash token, such as the cluster -am, stops the walk. Its literal
        absolute tokens are returned, and a token the walk reads as an option value is not
        returned as an operand.
    .PARAMETER Command
        The full command line.
    .OUTPUTS
        System.String[]
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param([Parameter(Mandatory)][AllowEmptyString()][string] $Command)

    $valueOptions = @{
        commit = @('-m', '--message', '-F', '--file', '--author', '--date', '-C', '--reuse-message', '-c', '--reedit-message', '-t', '--template', '--fixup', '--squash', '--trailer', '--pathspec-from-file')
        add    = @('--pathspec-from-file', '--chmod')
    }
    $flagOptions = @{
        commit = @('-a', '--all', '--amend', '--no-edit', '--no-verify', '-n', '-s', '--signoff', '-q', '--quiet', '-v', '--verbose', '--allow-empty', '-o', '--only', '-i', '--include', '--pathspec-file-nul')
        add    = @('-A', '--all', '-u', '--update', '-f', '--force', '-N', '--intent-to-add', '-n', '--dry-run', '-v', '--verbose', '--pathspec-file-nul')
    }
    $absolutePattern = '^([A-Za-z]:[\\/]|/)'
    $paths = [System.Collections.Generic.List[string]]::new()
    foreach ($subcommand in @('add', 'commit')) {
        foreach ($match in @(Get-CommandLineInvocation -CommandText $Command -CommandWord 'git' -SubcommandPath @($subcommand))) {
            if ($match.Status -ne 'Structural') { continue }
            $walked = [System.Collections.Generic.List[string]]::new()
            $optionValues = [System.Collections.Generic.List[string]]::new()
            $tokens = if ($match.Segment.ArgumentInjected) { [string[]]@() } else { [string[]]@($match.Segment.Tokens) }
            $afterSeparator = $false
            for ($index = [int]$match.OperandIndex; $index -lt $tokens.Count; $index++) {
                $token = $tokens[$index]
                if (-not $afterSeparator -and $token -match '^(<|>|\d*>|&>)') {
                    if ($token -match '^(\d*[<>]{1,2}&?|&>{1,2})$') { $index++ }
                    continue
                }
                if ($afterSeparator -or -not $token.StartsWith('-')) { $walked.Add($token); continue }
                if ($token -ceq '--') { $afterSeparator = $true; continue }
                $name = if ($token.IndexOf('=') -gt 0) { $token.Substring(0, $token.IndexOf('=')) } else { $token }
                if ($valueOptions[$subcommand] -ccontains $name) {
                    if ($name -ceq $token -and $index + 1 -lt $tokens.Count) { $index++; $optionValues.Add($tokens[$index]) }
                    continue
                }
                if ($token -match '^-[^-].' -and $valueOptions[$subcommand] -ccontains $token.Substring(0, 2)) { continue }
                if ($flagOptions[$subcommand] -ccontains $token) { continue }
                break
            }
            $candidates = @(@($match.GlobalOptions) | Where-Object { $_.Name -ceq '-C' -and $_.Value } | ForEach-Object { [string]$_.Value })
            $candidates += @(@($match.Operands) | Where-Object { $_ -match $absolutePattern -and $optionValues -cnotcontains $_ })
            $candidates += @($walked | Where-Object { $_ -match $absolutePattern -and (Test-CommandLineTokenLiteral -Token $_) })
            foreach ($candidate in $candidates) {
                if ($paths -notcontains $candidate) { $paths.Add($candidate) }
            }
        }
    }
    return [string[]]$paths.ToArray()
}

function Resolve-OrchestrationGateTarget {
    <#
    .SYNOPSIS
        Resolves the worktree whose checkpoint governs a single-feature path or command leg (issue #1010).
    .DESCRIPTION
        Calls Resolve-HookTargetWorktree with the recording invoker: a file path is passed as
        -FilePath, the marker paths of an apply_patch body as -FilePath (markers in two
        worktrees resolve as ambiguous), and any other command's
        Get-OrchestrationGateCommandOperandPath result as -CommandOperandPath. A failed or
        empty listing gives NoTarget instead of the session-root fallback; Ambiguous gives
        Ambiguous; a null root gives NoTarget; otherwise SessionRoot or OtherWorktree.
    .OUTPUTS
        System.Management.Automation.PSCustomObject with Status, WorktreeRoot, ReasonCode, and Detail.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()][AllowEmptyString()][string] $FilePath = '',
        [AllowNull()][AllowEmptyString()][string] $Command = ''
    )

    $sessionRoot = (Get-Location).Path
    $script:OrchestrationGateWorktreeListFailed = $false
    $invoker = { param($SessionRoot) Invoke-OrchestrationGateWorktreeList -SessionRoot $SessionRoot }
    $markerPaths = if ($FilePath) { @() } else { @(Get-OrchestrationPatchMarkerPath -PatchText ([string]$Command)) }
    $resolved = if ($FilePath) {
        Resolve-HookTargetWorktree -SessionRoot $sessionRoot -FilePath @($FilePath) -WorktreeListInvoker $invoker
    } elseif ($markerPaths.Count -gt 0) {
        Resolve-HookTargetWorktree -SessionRoot $sessionRoot -FilePath $markerPaths -WorktreeListInvoker $invoker
    } else {
        Resolve-HookTargetWorktree -SessionRoot $sessionRoot -CommandOperandPath @(Get-OrchestrationGateCommandOperandPath -Command ([string]$Command)) -WorktreeListInvoker $invoker
    }
    $detail = "resolver source $($resolved.Source): $($resolved.Detail)"
    if ($script:OrchestrationGateWorktreeListFailed) {
        return [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null; ReasonCode = $script:OrchestrationGateNotDerivableReasonCode; Detail = "the worktree listing failed or named no worktree; $detail" }
    }
    if ($resolved.Ambiguous) {
        return [pscustomobject]@{ Status = 'Ambiguous'; WorktreeRoot = $null; ReasonCode = $script:OrchestrationGateAmbiguousReasonCode; Detail = $detail }
    }
    if ([string]::IsNullOrEmpty([string]$resolved.WorktreeRoot)) {
        return [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null; ReasonCode = $script:OrchestrationGateNotDerivableReasonCode; Detail = $detail }
    }
    $isSession = [string]::Equals([string]$resolved.WorktreeRoot, (ConvertTo-HookTargetWorktreeNormalizedPath -Path $sessionRoot), [System.StringComparison]::OrdinalIgnoreCase)
    $status = if ($isSession) { 'SessionRoot' } else { 'OtherWorktree' }
    return [pscustomobject]@{ Status = $status; WorktreeRoot = [string]$resolved.WorktreeRoot; ReasonCode = $null; Detail = $detail }
}

function Read-OrchestrationGateCheckpoint {
    <#
    .SYNOPSIS
        Reads the checkpoint beneath the resolved target worktree, or returns the deny reason.
    .DESCRIPTION
        Resolved is $false, with DenyReason set, when the target is NoTarget or Ambiguous.
        Otherwise Raw holds the checkpoint text (empty when absent) and Path its absolute
        path, composed beneath the resolved root with a forward slash.
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][string] $Mode,
        [AllowNull()][AllowEmptyString()][string] $FilePath = '',
        [AllowNull()][AllowEmptyString()][string] $Command = ''
    )

    $target = Resolve-OrchestrationGateTarget -FilePath $FilePath -Command $Command
    if ($target.Status -eq 'NoTarget' -or $target.Status -eq 'Ambiguous') {
        return [pscustomobject]@{
            Resolved   = $false
            Raw        = ''
            Path       = $null
            DenyReason = ("PREIMPLEMENTATION_GATE_BLOCKED: $($target.ReasonCode): the target worktree of this $Mode call " +
                "could not be resolved: $($target.Detail). Implementation operations require an identifiable target " +
                'worktree whose checkpoint is ready.')
        }
    }

    $path = ([string]$target.WorktreeRoot).TrimEnd('/') + '/artifacts/orchestration/orchestrator-state.json'
    return [pscustomobject]@{
        Resolved   = $true
        Raw        = [string](Get-CheckpointContent -Path $path)
        Path       = $path
        DenyReason = $null
    }
}

function Get-OrchestrationEpicScopeSelector {
    <#
    .SYNOPSIS
        Returns the value of a leading `git -C <value>` selector, or $null.
    .DESCRIPTION
        Pure. Reads only the first segment of the command line, split and tokenized with
        the helpers-file parser so quoting is handled exactly as the staging exemption
        handles it. An unbalanced command line has no decidable selector and returns $null.
    .PARAMETER Command
        The full command line.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][AllowEmptyString()][string] $Command)

    $split = Split-OrchestrationCommandLine -CommandText $Command
    if (-not $split.Balanced -or @($split.Segments).Count -eq 0) {
        return $null
    }
    $token = @(ConvertTo-OrchestrationCommandToken -Segment ([string]@($split.Segments)[0]).Trim())
    if ($token.Count -ge 3 -and $token[0] -ceq 'git' -and $token[1] -ceq '-C' -and $token[2]) {
        return $token[2]
    }
    return $null
}

function Get-EpicCommandLegReadinessFailure {
    <#
    .SYNOPSIS
        Name the first failed conjunct of the epic command-leg readiness shape, or ''.
    .DESCRIPTION
        Conjuncts, in order: checkpoint-absent; route_id; epic_feature_folder (empty);
        epic_manifest_path (empty, or not under docs/features/epics/ after backslash
        normalisation); integration_branch (empty); features (absent or empty);
        merge-in-progress (no merge in progress in the effective worktree, D2). Returns
        the empty string when every conjunct holds, as the issue #663 predicate does.
    .PARAMETER Checkpoint
        The parsed epic checkpoint object, or $null.
    .PARAMETER MergeInProgress
        Whether MERGE_HEAD exists in the effective worktree's git directory.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [object] $Checkpoint,

        [Parameter(Mandatory = $true)]
        [bool] $MergeInProgress
    )

    if ($null -eq $Checkpoint) {
        return 'checkpoint-absent'
    }
    if ([string](Get-EpicScopePropertyValue -InputObject $Checkpoint -Name 'route_id') -cne $script:EpicScopeRouteId) {
        return 'route_id'
    }
    if ([string]::IsNullOrWhiteSpace([string](Get-EpicScopePropertyValue -InputObject $Checkpoint -Name 'epic_feature_folder'))) {
        return 'epic_feature_folder'
    }
    $manifestPath = ([string](Get-EpicScopePropertyValue -InputObject $Checkpoint -Name 'epic_manifest_path')) -replace '\\', '/'
    if ([string]::IsNullOrWhiteSpace($manifestPath) -or $manifestPath -notmatch $script:EpicScopeManifestPattern) {
        return 'epic_manifest_path'
    }
    if ([string]::IsNullOrWhiteSpace([string](Get-EpicScopePropertyValue -InputObject $Checkpoint -Name 'integration_branch'))) {
        return 'integration_branch'
    }
    # An empty features array unrolls to $null through the property read.
    $features = Get-EpicScopePropertyValue -InputObject $Checkpoint -Name 'features'
    if ($null -eq $features -or @($features).Count -eq 0) {
        return 'features'
    }
    if (-not $MergeInProgress) {
        return 'merge-in-progress'
    }
    return ''
}

function Get-OrchestrationEpicScopeDecision {
    <#
    .SYNOPSIS
        Returns the epic-scope decision for an implementation-classified command or path, or $null.
    .DESCRIPTION
        Resolves the target of every command segment, apply_patch file marker, and path
        (issue #738), then the epic scope of the session root and of each target. A command
        whose text is an apply_patch body is decided as a path leg over its marker paths.
        When neither is epic scope, returns $null so the caller's single-feature path runs
        unchanged. In epic scope, denies an unresolvable, ambiguous, or out-of-scope target,
        and otherwise evaluates the epic command-leg readiness predicate against every
        target: the first failure denies (the session-root wording is unchanged), and no
        failure allows.
    .PARAMETER Command
        The command line of a command or apply_patch leg; empty for a path leg.
    .PARAMETER FilePath
        The file path of a path leg; empty for a command leg.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary, or $null outside epic scope.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [AllowNull()][AllowEmptyString()][string] $Command = '',
        [AllowNull()][AllowEmptyString()][string] $FilePath = ''
    )

    # A call carrying neither a command nor a path has no leg to decide.
    if (-not $Command -and -not $FilePath) {
        return $null
    }
    $epicScopeSessionRoot = (Get-Location).Path
    $legCommand = [string]$Command
    $legPaths = @($FilePath)
    $markerPaths = @(Get-OrchestrationPatchMarkerPath -PatchText $legCommand)
    if ($markerPaths.Count -gt 0) {
        $legCommand = ''
        $legPaths = $markerPaths
    }
    $targetResult = Get-OrchestrationCommandTarget -Command $legCommand -FilePath $legPaths -SessionRoot $epicScopeSessionRoot
    $scopeResolver = {
        param([string] $Selector)
        Resolve-EpicScopeCheckpoint -SessionRoot $epicScopeSessionRoot -WorktreeSelector $Selector
    }
    $verdict = Resolve-OrchestrationEpicTargetVerdict -SessionRoot $epicScopeSessionRoot -TargetResult $targetResult -ScopeResolver $scopeResolver
    $outcome = Resolve-OrchestrationEpicTargetOutcome -Verdict $verdict -ReadinessFailure {
        param($Scope)
        Get-EpicCommandLegReadinessFailure -Checkpoint $Scope.Checkpoint -MergeInProgress $Scope.MergeInProgress
    }
    if ($outcome.Outcome -eq 'none') {
        return $null
    }
    if ($outcome.Outcome -eq 'deny') {
        return Get-OrchestrationPreimplementationGateBlockDecision -Reason $outcome.Reason
    }
    return Get-OrchestrationPreimplementationGateAllowDecision
}
