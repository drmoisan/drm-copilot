<#
.SYNOPSIS
    Release receipt leg of the Claude preimplementation gate (issue #1231, Leg 3).

.DESCRIPTION
    Dot-sourced, guarded, by enforce-orchestration-preimplementation-gate.ps1. The gate calls
    Get-OrchestrationReleaseReceiptResult in its single-feature branch after the parallel records
    leg and before the release-commit allowance leg (issue #1201), and inserts its DenySuffix in the
    final deny immediately before the #1201 suffix. The leg lets the pr-author agent write its
    integrity receipt artifacts/pr_body_<N>.receipt.json beneath a worktree that has no
    orchestration checkpoint, when the destination repository commits
    .claude/release-commit-allowance.json and the HEAD branch matches one of its allowances.

    Evaluation order (the first decline or failure decides):
      1 a blank FilePath, or one not matching (^|/)artifacts/pr_body_<digits>.receipt.json,
        declines with an empty suffix;
      2 R comes from Get-OrchestrationGateBookkeepingWorktreeRoot over the gate's checkpoint read
        path; no root declines;
      3 an absolute path whose remainder beneath R (Get-HookTargetWorktreeRelativePath) is not
        exactly artifacts/pr_body_<digits>.receipt.json, or a relative path that is not exactly
        that, declines;
      4 an absent allowance file declines with an empty suffix and no further I/O;
      5 RELEASE_RECEIPT_CONFIG_INVALID - a read failure, a parse failure, or a directory entry;
      6 RELEASE_RECEIPT_CHECKPOINT_PRESENT - an orchestration checkpoint exists beneath R
        (Test-OrchestrationDocsEstateCheckpointPresent);
      7 RELEASE_RECEIPT_BRANCH_NOT_MATCHED - the HEAD branch of R (Get-EpicScopeWorktreeHeadBranch)
        is detached, unreadable, or matches no allowance pattern.
    No diff check runs here; Legs 1 and 2 enforce the diff. A failure adds the suffix
    ' Release receipt leg not applied: <CODE>: <detail>'.

.NOTES
    PowerShell 7+. Claude only; mirrored byte-identically under
    extensions/drm-copilot/resources/claude-customizations/. Never throws: an unexpected error
    declines with an empty DenySuffix and a Write-Debug record carrying PREIMPL_RELEASE_RECEIPT_LEG_ERROR.
    Call-time dependencies loaded by the gate: Get-OrchestrationGateReleaseAllowanceConfigText and
    Test-OrchestrationGateReleaseAllowancePathIsContainer (release sibling), ConvertFrom-ReleaseAllowanceConfig
    and Test-ReleaseAllowanceBranchMatch (hook-release-allowance-context.ps1),
    Get-OrchestrationGateBookkeepingWorktreeRoot (bookkeeping sibling), $script:CheckpointPaths
    (gate file), Test-OrchestrationDocsEstateCheckpointPresent (docs sibling),
    Get-HookTargetWorktreeRelativePath (HookTargetWorktree.psm1), and Get-EpicScopeWorktreeHeadBranch
    (EpicScopeResolution.psm1). Script-scope names use the prefix ReleasePullRequest. This hook file
    starts no interpreter process. A policy-level control, not a security control.
#>

try { . (Join-Path $PSScriptRoot 'hook-release-pull-request-context.ps1') } catch { Add-HookDependencyFailure -Name 'hook-release-pull-request-context.ps1' -ErrorRecord $_ }

$script:ReleasePullRequestReceiptPathPattern = '(^|/)artifacts/pr_body_[0-9]+\.receipt\.json$'
$script:ReleasePullRequestReceiptExactPattern = '^artifacts/pr_body_[0-9]+\.receipt\.json$'

function Get-OrchestrationReleaseReceiptNotAppliedResult {
    <#
    .SYNOPSIS
        Return a declined Leg 3 result whose DenySuffix names the code and the detail.
    .PARAMETER Code
        The RELEASE_RECEIPT_* code.
    .PARAMETER Detail
        The detail of the failure.
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)][string] $Code, [Parameter(Mandatory)][string] $Detail)

    return [pscustomobject]@{ Allowed = $false; DenySuffix = " Release receipt leg not applied: ${Code}: $Detail" }
}

function Get-OrchestrationReleaseReceiptResult {
    <#
    .SYNOPSIS
        Decide whether a Write that the gate would deny is a checkpoint-free release receipt Write.
    .DESCRIPTION
        Applies steps 1 to 7 of the file header in order. Returns Allowed and DenySuffix.
    .PARAMETER FilePath
        The Write or Edit file path; empty for a command or a delegation.
    .PARAMETER CheckpointPath
        The Path of the gate's checkpoint read, or empty when the checkpoint text was injected.
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()][AllowEmptyString()][string] $FilePath,
        [AllowNull()][AllowEmptyString()][string] $CheckpointPath
    )

    $declined = [pscustomobject]@{ Allowed = $false; DenySuffix = '' }
    try {
        if ([string]::IsNullOrWhiteSpace($FilePath)) { return $declined }
        $normalized = $FilePath -replace '\\', '/'
        if ($normalized -cnotmatch $script:ReleasePullRequestReceiptPathPattern) { return $declined }
        $root = Get-OrchestrationGateBookkeepingWorktreeRoot -CheckpointPath $CheckpointPath -CheckpointSuffix ([string]@($script:CheckpointPaths)[0])
        if ($null -eq $root) { return $declined }
        $relative = if ($normalized -match '^([A-Za-z]:/|/)') { [string](Get-HookTargetWorktreeRelativePath -Path $normalized -WorktreeRoot $root) } else { $normalized }
        if ($relative -cnotmatch $script:ReleasePullRequestReceiptExactPattern) { return $declined }

        $state = Get-ReleasePullRequestConfigState -WorktreeRoot $root -ConfigReader { param([string] $WorktreeRoot) Get-OrchestrationGateReleaseAllowanceConfigText -WorktreeRoot $WorktreeRoot } -ContainerProbe { param([string] $WorktreeRoot, [string] $RelativePath) Test-OrchestrationGateReleaseAllowancePathIsContainer -WorktreeRoot $WorktreeRoot -RelativePath $RelativePath }
        if ($state.State -ceq 'Absent') { return $declined }
        if ($state.State -cne 'Valid') { return (Get-OrchestrationReleaseReceiptNotAppliedResult 'RELEASE_RECEIPT_CONFIG_INVALID' ([string]$state.Detail)) }
        if (Test-OrchestrationDocsEstateCheckpointPresent -WorktreeRoot $root) {
            return (Get-OrchestrationReleaseReceiptNotAppliedResult 'RELEASE_RECEIPT_CHECKPOINT_PRESENT' 'an orchestration checkpoint exists beneath the worktree, so its readiness governs')
        }
        $branch = [string](Get-EpicScopeWorktreeHeadBranch -WorktreeRoot $root)
        if ([string]::IsNullOrEmpty($branch)) { return (Get-OrchestrationReleaseReceiptNotAppliedResult 'RELEASE_RECEIPT_BRANCH_NOT_MATCHED' 'HEAD is detached or unreadable') }
        $matched = @(@($state.Allowances) | Where-Object { $allowance = $_; @(@($allowance.BranchPatterns) | Where-Object { Test-ReleaseAllowanceBranchMatch -Branch $branch -Pattern $_ }).Count -gt 0 })
        if ($matched.Count -eq 0) { return (Get-OrchestrationReleaseReceiptNotAppliedResult 'RELEASE_RECEIPT_BRANCH_NOT_MATCHED' "branch '$branch' matches no allowance") }
        return [pscustomobject]@{ Allowed = $true; DenySuffix = '' }
    } catch {
        Write-Debug "PREIMPL_RELEASE_RECEIPT_LEG_ERROR: $($_.Exception.Message)"
        return $declined
    }
}
