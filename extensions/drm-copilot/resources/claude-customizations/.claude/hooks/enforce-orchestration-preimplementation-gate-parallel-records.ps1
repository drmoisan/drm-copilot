<#
.SYNOPSIS
    Parallel records allow leg of the Claude preimplementation gate (issue #1182).

.DESCRIPTION
    Dot-sourced by enforce-orchestration-preimplementation-gate.ps1. The gate calls
    Get-OrchestrationParallelRecordsResult only where it would otherwise return its final
    PREIMPLEMENTATION_GATE_BLOCKED deny, after the cleanup, bookkeeping, and docs-estate legs have
    declined, and appends the DenySuffix after the docs-estate suffix. The leg lets the pr-author
    agent write its integrity receipt artifacts/pr_body_<N>.receipt.json at the coordinator root of
    a closed parallel run during Run Closing. The body artifacts/pr_body_<N>.md is not an
    implementation path and never reaches this leg.

    Conditions, in order (every failure before Q5 declines with an empty DenySuffix):
      Q1 Shape - a Write payload (content present, old_string absent) whose path, with '\'
                 normalized to '/', is exactly artifacts/pr_body_<digits>.receipt.json
                 (case-sensitive), or an absolute path whose remainder beneath its enclosing
                 registered worktree root (Get-HookTargetWorktreeEnclosingRoot,
                 Get-HookTargetWorktreeRelativePath) is exactly that.
      Q2 Root  - R is the session root for a relative path and the enclosing registered root for
                 an absolute path.
      Q3       - no per-feature checkpoint beneath R: Get-WorktreeRunCheckpointText at
                 Get-WorktreeRunCheckpointPath -Kind item returns $null.
      Q4       - the HEAD branch of R (Get-EpicScopeWorktreeHeadBranch) is a plan branch
                 parallel/<slug>-plan (Get-ParallelRecordsSlug).
      Q5       - Get-ParallelRecordsCheckpointDecision on the parallel checkpoint text beneath R.
                 Allowed allows; otherwise the suffix is
                 ' Parallel records leg not applied: <SubCode>: <Detail>'.

.NOTES
    PowerShell 7+. Claude only; mirrored byte-identically under
    extensions/drm-copilot/resources/claude-customizations/. The Codex gate has no equivalent leg.
    A policy-level control, not a security control: a writer in the same session can forge the
    parallel checkpoint and its receipt (same-session forgery). Never throws. Call-time
    dependencies loaded by the gate: Get-ParallelRecordsSlug and
    Get-ParallelRecordsCheckpointDecision (hook-parallel-records-context.ps1);
    Get-OrchestrationCleanupListingRecord (cleanup sibling); ConvertTo-CleanupContextPath
    (hook-cleanup-context.ps1); $script:OrchestrationTargetNonLocalPattern (targets file);
    Get-HookTargetWorktreeEnclosingRoot and Get-HookTargetWorktreeRelativePath
    (HookTargetWorktree.psm1); Get-WorktreeRunCheckpointText and Get-WorktreeRunCheckpointPath
    (WorktreeRunResolution.psm1); and Get-EpicScopeWorktreeHeadBranch (EpicScopeResolution.psm1).
#>

try { Import-Module (Join-Path $PSScriptRoot '../lib/orchestrator-state/OrchestratorStateModelReceipts.psm1') -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'OrchestratorStateModelReceipts.psm1' -ErrorRecord $_ }

$script:OrchestrationParallelRecordsReceiptPattern = '^artifacts/pr_body_[0-9]+\.receipt\.json$'

function Get-OrchestrationParallelRecordsRoot {
    <#
    .SYNOPSIS
        Q1 and Q2: return the root R of a receipt Write path, or $null.
    .PARAMETER FilePath
        The Write file path.
    .PARAMETER SessionRoot
        The session root, which is R for a relative path.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][string] $FilePath, [Parameter(Mandatory)][string] $SessionRoot)

    $normalized = ConvertTo-CleanupContextPath -Path $FilePath
    if ($normalized -cmatch $script:OrchestrationParallelRecordsReceiptPattern) {
        return $SessionRoot
    }
    if ($normalized -notmatch '^([A-Za-z]:/|/(?!/))' -or $FilePath -match $script:OrchestrationTargetNonLocalPattern) {
        return $null
    }
    $roots = [string[]]@(@(Get-OrchestrationCleanupListingRecord -SessionRoot $SessionRoot) | ForEach-Object { [string]$_.Root })
    $enclosing = Get-HookTargetWorktreeEnclosingRoot -Path $normalized -Roots $roots
    if ($null -eq $enclosing -or [string](Get-HookTargetWorktreeRelativePath -Path $normalized -WorktreeRoot $enclosing) -cnotmatch $script:OrchestrationParallelRecordsReceiptPattern) {
        return $null
    }
    return [string]$enclosing
}

function Get-OrchestrationParallelRecordsResult {
    <#
    .SYNOPSIS
        Decide whether a Write that the gate would deny is the pr-author receipt Write of a closed
        parallel run at its coordinator root.
    .DESCRIPTION
        Applies Q1 to Q5 of the file header in order. Never throws: any error answers Allowed
        $false with an empty DenySuffix.
    .PARAMETER ToolInput
        The parsed tool input of the call.
    .PARAMETER FilePath
        The Write or Edit file path; empty for a command or a delegation.
    .OUTPUTS
        System.Management.Automation.PSCustomObject with Allowed and DenySuffix.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()][object] $ToolInput,
        [AllowNull()][AllowEmptyString()][string] $FilePath
    )

    $denied = [pscustomobject]@{ Allowed = $false; DenySuffix = '' }
    try {
        if ([string]::IsNullOrEmpty($FilePath) -or $null -eq $ToolInput) {
            return $denied
        }
        $names = @($ToolInput.PSObject.Properties.Name)
        if ($names -cnotcontains 'content' -or $names -ccontains 'old_string') {
            return $denied
        }
        $root = Get-OrchestrationParallelRecordsRoot -FilePath $FilePath -SessionRoot (Get-Location).Path
        if ([string]::IsNullOrWhiteSpace($root)) {
            return $denied
        }
        if ($null -ne (Get-WorktreeRunCheckpointText -Path (Get-WorktreeRunCheckpointPath -Kind item -WorktreeRoot $root))) {
            return $denied
        }
        $slug = Get-ParallelRecordsSlug -BranchName ([string](Get-EpicScopeWorktreeHeadBranch -WorktreeRoot $root))
        if ($null -eq $slug) {
            return $denied
        }
        $decision = Get-ParallelRecordsCheckpointDecision -CheckpointText (Get-WorktreeRunCheckpointText -Path (Get-WorktreeRunCheckpointPath -Kind parallel -WorktreeRoot $root)) -Slug $slug
        if ($decision.Allowed) {
            return [pscustomobject]@{ Allowed = $true; DenySuffix = '' }
        }
        return [pscustomobject]@{ Allowed = $false; DenySuffix = " Parallel records leg not applied: $($decision.SubCode): $($decision.Detail)" }
    }
    catch {
        Write-Debug "PREIMPL_PARALLEL_RECORDS_LEG_ERROR: $($_.Exception.Message)"
        return $denied
    }
}
