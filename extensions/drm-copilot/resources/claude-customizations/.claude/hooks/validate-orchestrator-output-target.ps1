<#
.SYNOPSIS
    Item-checkpoint target-worktree resolution for validate-orchestrator-output.ps1 (issue #1145).

.DESCRIPTION
    Dot-sourced by validate-orchestrator-output.ps1. A coordinator-launched orchestrator works in an
    item worktree while the hook process runs in the session root, so the orchestrator-state
    checkpoint is resolved from the delegation prompt in the subagent transcript rather than from
    the hook's working directory.

    Resolution order for orchestrator-state: Resolve-SubagentStopTargetWorktree reads the delegation
    prompt identity (branch: label, canonical issue line). A prompt that places the run in one
    worktree decides its root. A prompt identity that names no registered worktree (NoTarget) or more
    than one (Ambiguous) leaves the target unresolved, so no checkpoint is read. With no identity
    (no transcript, no identity line, or a resolver failure) the session worktree is validated as
    before, and the fallback note says so.

.NOTES
    PowerShell 7+. Dot-sources and imports nothing and holds no script-scope state. Calls
    Test-OrchestratorOutputCheckpointLeafShape (validate-orchestrator-output-resolution.ps1),
    Resolve-SubagentStopTargetWorktree (subagentstop-target-worktree.ps1), and
    Resolve-WorktreeOperandTarget (WorktreeRunResolution.psm1), which the main hook loads.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
#>

function Resolve-OrchestratorOutputItemTarget {
    <#
    .SYNOPSIS
        Resolves the item worktree of an orchestrator-state stop from the delegation prompt.
    .DESCRIPTION
        Returns $null when the artifact type is not orchestrator-state, the assistant text is blank,
        or the -CheckpointPath leaf is rejected, so the existing empty-output and leaf-shape blocks
        apply and nothing is resolved. Otherwise returns an object with Status, WorktreeRoot,
        ReasonCode, Detail, FallbackNote, and FallbackApplied ($false). Status is Resolved when the
        delegation prompt places the run in one worktree, NoTarget for TARGET_WORKTREE_NOT_DERIVABLE,
        Ambiguous for TARGET_WORKTREE_AMBIGUOUS, and Fallback when the session root applies.
        FallbackNote carries the resolver-failure detail of a Fallback, or an empty string.
    .PARAMETER ArtifactType
        The hook's artifact type.
    .PARAMETER Envelope
        The parsed SubagentStop envelope, or $null.
    .PARAMETER AgentOutput
        The assistant text of the stop.
    .PARAMETER CheckpointPath
        The bound repository-relative checkpoint leaf.
    .PARAMETER SessionRoot
        The hook's session root.
    .PARAMETER ReadTranscriptHead
        Optional transcript reader seam, forwarded only when supplied.
    .PARAMETER WorktreeListInvoker
        Optional worktree list seam, forwarded only when supplied.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $ArtifactType,
        [AllowNull()] [object] $Envelope,
        [AllowNull()] [AllowEmptyString()] [string] $AgentOutput,
        [Parameter(Mandatory = $true)] [AllowEmptyString()] [string] $CheckpointPath,
        [Parameter(Mandatory = $true)] [string] $SessionRoot,
        [scriptblock] $ReadTranscriptHead,
        [scriptblock] $WorktreeListInvoker
    )

    if ($ArtifactType -cne 'orchestrator-state' -or [string]::IsNullOrWhiteSpace($AgentOutput)) { return $null }
    if (-not (Test-OrchestratorOutputCheckpointLeafShape -CheckpointPath $CheckpointPath).Ok) { return $null }

    $targetArguments = @{ Envelope = $Envelope; SessionRoot = $SessionRoot }
    if ($null -ne $ReadTranscriptHead) { $targetArguments['ReadTranscriptHead'] = $ReadTranscriptHead }
    if ($null -ne $WorktreeListInvoker) { $targetArguments['WorktreeListInvoker'] = $WorktreeListInvoker }
    $target = Resolve-SubagentStopTargetWorktree @targetArguments

    $detail = [string]$target.Detail
    $status = 'Fallback'
    if ($target.ReasonCode -ceq 'TARGET_WORKTREE_AMBIGUOUS') { $status = 'Ambiguous' }
    elseif ($target.ReasonCode -ceq 'TARGET_WORKTREE_NOT_DERIVABLE') { $status = 'NoTarget' }
    elseif ($target.Source -ceq 'DelegationPrompt' -and -not [string]::IsNullOrWhiteSpace([string]$target.WorktreeRoot)) { $status = 'Resolved' }
    $failureNote = if ($status -eq 'Fallback' -and $detail.StartsWith('target worktree resolution failed', [System.StringComparison]::Ordinal)) { $detail } else { '' }
    return [pscustomobject]@{
        Status          = $status
        WorktreeRoot    = $(if ($status -eq 'Resolved') { [string]$target.WorktreeRoot } else { $null })
        ReasonCode      = $target.ReasonCode
        Detail          = $detail
        FallbackNote    = $failureNote
        FallbackApplied = $false
    }
}

function Resolve-OrchestratorOutputItemOperandTarget {
    <#
    .SYNOPSIS
        Maps an item target to the operand-target shape that Resolve-OrchestratorOutputCheckpointPath reads.
    .DESCRIPTION
        Resolved returns the item root with Status OtherWorktree (SessionRoot when it is the session
        root). NoTarget and Ambiguous return an unresolved target with the reason code and detail, so
        the caller blocks and reads nothing. Fallback calls Resolve-WorktreeOperandTarget with an
        empty path and the session root, as the hook did before issue #1145, and sets
        FallbackApplied on the item target.
    .PARAMETER ItemTarget
        The Resolve-OrchestratorOutputItemTarget result.
    .PARAMETER SessionRoot
        The hook's session root.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)] [object] $ItemTarget,
        [Parameter(Mandatory = $true)] [string] $SessionRoot
    )

    $status = [string]$ItemTarget.Status
    if ($status -eq 'Resolved') {
        $root = ([string]$ItemTarget.WorktreeRoot -replace '\\', '/').TrimEnd('/')
        $session = ($SessionRoot -replace '\\', '/').TrimEnd('/')
        $kind = if ([string]::Equals($root, $session, [System.StringComparison]::OrdinalIgnoreCase)) { 'SessionRoot' } else { 'OtherWorktree' }
        return [pscustomobject]@{ Status = $kind; WorktreeRoot = $root; ReasonCode = $null; Detail = "the delegation prompt places the run in the worktree '$root'" }
    }
    if ($status -in @('NoTarget', 'Ambiguous')) {
        $detail = 'the delegation prompt identity does not place the run in one worktree, so no checkpoint is read: ' + [string]$ItemTarget.Detail
        return [pscustomobject]@{ Status = $status; WorktreeRoot = $null; ReasonCode = $ItemTarget.ReasonCode; Detail = $detail }
    }
    $ItemTarget.FallbackApplied = $true
    return (Resolve-WorktreeOperandTarget -Path '' -SessionRoot $SessionRoot)
}

function Get-OrchestratorOutputFallbackNote {
    <#
    .SYNOPSIS
        Returns the session-worktree fallback note, or an empty string.
    .DESCRIPTION
        Empty unless the item target's FallbackApplied is set. Otherwise the text starts with the
        token ORCHESTRATOR_CHECKPOINT_FALLBACK: and states that no target worktree is identifiable
        from the delegation prompt and that the session worktree checkpoint is validated, followed
        by the resolver-failure detail when one was recorded.
    .PARAMETER ItemTarget
        The Resolve-OrchestratorOutputItemTarget result, or $null.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowNull()] [object] $ItemTarget)

    if ($null -eq $ItemTarget -or -not $ItemTarget.FallbackApplied) { return '' }
    $note = 'ORCHESTRATOR_CHECKPOINT_FALLBACK: no target worktree is identifiable from the delegation prompt (no branch: label or canonical issue line); the checkpoint of the session worktree is validated.'
    if (-not [string]::IsNullOrWhiteSpace([string]$ItemTarget.FallbackNote)) { $note = $note + ' Detail: ' + [string]$ItemTarget.FallbackNote + '.' }
    return $note
}

function Write-OrchestratorOutputAllowNote {
    <#
    .SYNOPSIS
        Writes the Note of an allow result to the error stream when it is non-empty.
    .DESCRIPTION
        The hook exits 0 after this call, so the note is informational. A result without a
        non-empty Note writes nothing.
    .PARAMETER Result
        The Invoke-OrchestratorOutputValidation result.
    .PARAMETER Writer
        The text writer; defaults to [Console]::Error.
    #>
    [CmdletBinding()]
    param(
        [AllowNull()] [object] $Result,
        [System.IO.TextWriter] $Writer = [Console]::Error
    )

    if ($Result -isnot [System.Collections.IDictionary] -or -not $Result.Contains('Note')) { return }
    $note = [string]$Result['Note']
    if ([string]::IsNullOrWhiteSpace($note)) { return }
    $Writer.WriteLine($note)
}
