<#
.SYNOPSIS
    Epic-scope legs, checkpoint read seams, and target resolution of the preimplementation gate.

.DESCRIPTION
    Dot-sourced by enforce-orchestration-preimplementation-gate.ps1. Holds five groups of
    functions:

    - The import guards for the worktree-resolution modules (issue #690). A failed import
      is recorded in $script:HookDependencyFailures, and the gate's call to
      Get-HookDependencyFailureDecision turns that record into a deny, so a
      missing module cannot make the gate exit non-zero and fail open.
    - The three checkpoint read seams, Get-CheckpointContent, Get-EpicCheckpointContent,
      and Get-ParallelCheckpointContent. Each takes a mandatory absolute path, so no
      read binds to the calling process's directory. Get-CheckpointContent and
      Get-OrchestrationModeDenyReason were relocated here from the gate file by issue #690
      to keep the gate inside the 500-line cap.
    - The target-resolution building blocks of issue #1010: the worktree-list wrapper
      Get-OrchestrationGateWorktreeList (the only listing seam), the recording invoker
      Invoke-OrchestrationGateWorktreeList, which records a failed or empty listing in
      $script:OrchestrationGateWorktreeListFailed, and the command-operand parser
      Get-OrchestrationGateCommandOperandPath for git add and git commit.
    - The target resolution of issue #690. Resolve-OrchestrationGateTarget selects the
      worktree whose checkpoint governs the call from portable identity only: the
      integration_branch: value for an epic delegation, the parallel_slug: value for a
      parallel delegation, and the canonical issue-number line and branch: label for a
      single-feature delegation. The path and command legs resolve through
      Resolve-HookTargetWorktree (issue #1010) from the file_path or from every git add
      and git commit selector and absolute operand. Read-OrchestrationGateCheckpoint reads
      the checkpoint beneath the resolved root, or returns the deny for an unresolved
      target.
    - The epic-scope decision for the command and path legs (issue #663). A staging
      command or a Write/Edit call is epic scope when the effective worktree's HEAD equals
      the integration branch of the epic checkpoint that Resolve-EpicScopeCheckpoint
      locates. Outside epic scope the decision function returns $null and the gate's
      single-feature path runs.

.NOTES
    PowerShell 7+. Depends on functions the gate defines or dot-sources before any call:
    Get-OrchestrationDelegationCheckpointPath (modes file), the gate's allow and block
    decision constructors, and Read-CommandLineSegment, Get-CommandLineGlobalOption, and
    Get-CommandLineInvocation (loaded by the gate's dot-source of
    hook-command-invocation.ps1), which the targets file this file dot-sources (issue #738)
    and Get-OrchestrationGateCommandOperandPath call. Imports
    WorktreeResolution.psm1 (the reason-code accessors), then WorktreeItemResolution.psm1
    and WorktreeRunResolution.psm1 before EpicScopeResolution.psm1, so the nested import
    inside EpicScopeResolution reuses the same module instance, and HookTargetWorktree.psm1
    (Resolve-HookTargetWorktree, issue #1009) last. Mirrored byte-identically under
    extensions/drm-copilot/resources/claude-customizations/.
#>

try { Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/WorktreeResolution.psm1') -Force -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'WorktreeResolution.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/WorktreeItemResolution.psm1') -Force -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'WorktreeItemResolution.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/WorktreeRunResolution.psm1') -Force -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'WorktreeRunResolution.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/EpicScopeResolution.psm1') -Force -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'EpicScopeResolution.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/EpicScopeReadiness.psm1') -Force -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'EpicScopeReadiness.psm1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/HookTargetWorktree.psm1') -Force -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'HookTargetWorktree.psm1' -ErrorRecord $_ }
# Per-segment target resolution for the epic-scope decision (issue #738).
. (Join-Path $PSScriptRoot 'enforce-orchestration-preimplementation-gate-targets.ps1')

# The three checkpoint read seams. Each takes the absolute path composed beneath a
# resolved worktree root; an absent file returns an empty string, which the readiness
# predicate then treats as a deny.
function Get-CheckpointContent {
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][ValidatePattern('^([A-Za-z]:[\\/]|/)')][string] $Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return ''
    }
    return Get-Content -Raw -LiteralPath $Path
}

function Get-EpicCheckpointContent {
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][ValidatePattern('^([A-Za-z]:[\\/]|/)')][string] $Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return ''
    }
    return Get-Content -Raw -LiteralPath $Path
}

function Get-ParallelCheckpointContent {
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][ValidatePattern('^([A-Za-z]:[\\/]|/)')][string] $Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return ''
    }
    return Get-Content -Raw -LiteralPath $Path
}

# Builds a mode-specific deny reason naming the checkpoint actually consulted and the
# predicate that failed, behind the unchanged PREIMPLEMENTATION_GATE_BLOCKED prefix
# that downstream reason-matching reads. A resolved absolute path is named when known.
function Get-OrchestrationModeDenyReason {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][string] $Mode,
        [Parameter(Mandatory)][string] $Failure,
        [AllowNull()][AllowEmptyString()][string] $CheckpointPath = ''
    )

    $path = if ($CheckpointPath) { $CheckpointPath } else { Get-OrchestrationDelegationCheckpointPath -Mode $Mode }
    return ("PREIMPLEMENTATION_GATE_BLOCKED: this $Mode-mode delegation was evaluated against " +
        "$path, and the failed readiness predicate is '$Failure'. Implementation operations " +
        'require that checkpoint to satisfy every readiness predicate before implementation begins.')
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
        Resolves the worktree whose checkpoint governs a gated call (issue #690 seam).
    .DESCRIPTION
        An epic delegation is keyed on integration_branch: (with epic_feature_folder: as a
        cross-check), a parallel delegation on parallel_slug:, and a single-feature
        delegation on its canonical issue-number line and branch: label. The path and
        command legs use Resolve-HookTargetWorktree (issue #1010): a path leg passes its
        file_path, a command leg the Get-OrchestrationGateCommandOperandPath result, and the
        recording invoker supplies the worktree listing. A failed or empty listing denies as
        not derivable instead of falling back to the session root; an ambiguous result
        denies as ambiguous; a null root denies as not derivable.
    .OUTPUTS
        System.Management.Automation.PSCustomObject (the worktree-resolution target result).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][string] $Mode,
        [AllowNull()][AllowEmptyString()][string] $Prompt = '',
        [AllowNull()][AllowEmptyString()][string] $FilePath = '',
        [AllowNull()][AllowEmptyString()][string] $Command = ''
    )

    $sessionRoot = (Get-Location).Path
    if ($Mode -eq 'epic' -or $Mode -eq 'parallel') {
        $signal = Find-WorktreeRunIdentitySignal -Text $Prompt
        if ($Mode -eq 'epic') {
            return Resolve-WorktreeEpicTarget -IntegrationBranch $signal.IntegrationBranch -EpicSlug $signal.EpicSlug -SessionRoot $sessionRoot
        }
        return Resolve-WorktreeParallelTarget -ParallelSlug $signal.ParallelSlug -SessionRoot $sessionRoot
    }
    if (-not $FilePath -and -not $Command) {
        return Resolve-WorktreeItemTarget -Text $Prompt -SessionRoot $sessionRoot
    }
    $script:OrchestrationGateWorktreeListFailed = $false
    $invoker = { param($SessionRoot) Invoke-OrchestrationGateWorktreeList -SessionRoot $SessionRoot }
    $resolved = if ($FilePath) {
        Resolve-HookTargetWorktree -SessionRoot $sessionRoot -FilePath @($FilePath) -WorktreeListInvoker $invoker
    } else {
        Resolve-HookTargetWorktree -SessionRoot $sessionRoot -CommandOperandPath @(Get-OrchestrationGateCommandOperandPath -Command $Command) -WorktreeListInvoker $invoker
    }
    $detail = "resolver source $($resolved.Source): $($resolved.Detail)"
    if ($script:OrchestrationGateWorktreeListFailed) {
        return [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null; ReasonCode = (Get-WorktreeResolutionNoTargetReasonCode); Detail = "the worktree listing failed or named no worktree; $detail" }
    }
    if ($resolved.Ambiguous) {
        return [pscustomobject]@{ Status = 'Ambiguous'; WorktreeRoot = $null; ReasonCode = (Get-WorktreeResolutionAmbiguityReasonCode); Detail = $detail }
    }
    if ([string]::IsNullOrEmpty([string]$resolved.WorktreeRoot)) {
        return [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null; ReasonCode = (Get-WorktreeResolutionNoTargetReasonCode); Detail = $detail }
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
        path. Only Status, WorktreeRoot, ReasonCode, and Detail are read from the target.
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][string] $Mode,
        [AllowNull()][AllowEmptyString()][string] $Prompt = '',
        [AllowNull()][AllowEmptyString()][string] $FilePath = '',
        [AllowNull()][AllowEmptyString()][string] $Command = ''
    )

    $target = Resolve-OrchestrationGateTarget -Mode $Mode -Prompt $Prompt -FilePath $FilePath -Command $Command
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

    $kind = if ($Mode -eq 'epic' -or $Mode -eq 'parallel') { $Mode } else { 'item' }
    $path = Get-WorktreeRunCheckpointPath -Kind $kind -WorktreeRoot $target.WorktreeRoot
    $raw = switch ($kind) {
        'epic' { Get-EpicCheckpointContent -Path $path }
        'parallel' { Get-ParallelCheckpointContent -Path $path }
        default { Get-CheckpointContent -Path $path }
    }
    return [pscustomobject]@{
        Resolved   = $true
        Raw        = [string]$raw
        Path       = $path
        DenyReason = $null
    }
}

function Get-OrchestrationEpicScopeDecision {
    <#
    .SYNOPSIS
        Returns the epic-scope decision for an implementation-classified command or path, or $null.
    .DESCRIPTION
        Resolves the target of every command segment and path (issue #738) with
        Get-OrchestrationCommandTarget, then the epic scope of the session root and of each
        target with worktree-HEAD matching. When neither is epic scope, returns $null so the
        caller's single-feature path runs unchanged. In epic scope, denies an unresolvable,
        ambiguous, or out-of-scope target, and otherwise evaluates the epic command-leg
        readiness predicate against every target: the first failure denies (the session-root
        wording is unchanged), and no failure allows.
    .PARAMETER Command
        The Bash command line; empty for a path leg.
    .PARAMETER FilePath
        The Write/Edit file path; empty for a command leg.
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
    $epicScopeText = [string]$Command
    $targetResult = Get-OrchestrationCommandTarget -Command $epicScopeText -FilePath @($FilePath) -SessionRoot $epicScopeSessionRoot
    $scopeResolver = {
        param([string] $Selector)
        Resolve-EpicScopeCheckpoint -Text $epicScopeText -SessionRoot $epicScopeSessionRoot -WorktreeSelector $Selector -MatchWorktreeHead
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
