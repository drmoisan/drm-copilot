<#
.SYNOPSIS
    Parallel records delegation leg of the model-routing gate (issue #1182).

.DESCRIPTION
    Dot-sourced by enforce-model-routing-receipt.ps1. Invoke-ModelRoutingReceiptDecision calls
    Get-ModelRoutingParallelRecordsDecision only for an Agent(pr-author) delegation whose resolved
    worktree holds no per-feature checkpoint, after the cleanup leg and before the docs-estate leg.
    The leg lets the parallel-orchestrator delegate the Run Closing records pull request from the
    coordinator root, which by design holds only the parallel checkpoint (issue #673 hygiene). The
    pr-author routing receipt is read from model_routing_receipts of that parallel checkpoint, as the
    epic receipt is read from the epic checkpoint (issue #663).

    Conditions, in order:
      P1 Label - the prompt has exactly one line '^branch:[ \t]*(\S+)[ \t]*$', its value is a plan
                 branch parallel/<slug>-plan (Get-ParallelRecordsSlug), and
                 Find-WorktreeResolutionBranchSignal returns the same value. Failure declines with
                 an empty suffix, so every other prompt keeps today's deny text, before any seam
                 call.
      P2 Root  - the resolved worktree root is non-blank. Failure declines with an empty suffix.
      P3       - Get-ParallelRecordsCheckpointDecision on the parallel checkpoint text beneath the
                 root (Get-WorktreeRunCheckpointText at Get-WorktreeRunCheckpointPath -Kind
                 parallel). Allowed allows; otherwise the suffix is
                 ' Parallel records leg not applied: <SubCode>: <Detail>'.

    The leg checks that the recorded receipt is internally consistent; it cannot read the model the
    delegation actually uses, because the Agent tool input exposes no model field.

.NOTES
    PowerShell 7+. Claude only; mirrored byte-identically under
    extensions/drm-copilot/resources/claude-customizations/. A policy-level control, not a security
    control: a writer in the same session can forge the parallel checkpoint and its receipt
    (same-session forgery). Never throws. Call-time dependencies loaded by the gate:
    Get-ParallelRecordsSlug and Get-ParallelRecordsCheckpointDecision
    (hook-parallel-records-context.ps1), Find-WorktreeResolutionBranchSignal
    (WorktreeTargetResolution.psm1), and Get-WorktreeRunCheckpointText and
    Get-WorktreeRunCheckpointPath (WorktreeRunResolution.psm1).
#>

$script:ModelRoutingParallelBranchLinePattern = '(?m)^branch:[ \t]*(\S+)[ \t]*$'

function Get-ModelRoutingParallelRecordsDecision {
    <#
    .SYNOPSIS
        Decide whether a checkpoint-free Agent(pr-author) delegation is the Run Closing records
        delegation of a closed parallel run.
    .DESCRIPTION
        Applies P1 to P3 of the file header in order. Never throws: any error answers Allowed
        $false with an empty DenySuffix.
    .PARAMETER PromptText
        The delegation prompt.
    .PARAMETER WorktreeRoot
        The worktree root that the gate's identity resolution returned.
    .OUTPUTS
        System.Management.Automation.PSCustomObject with Allowed and DenySuffix.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()][AllowEmptyString()][string] $PromptText,
        [AllowNull()][AllowEmptyString()][string] $WorktreeRoot
    )

    $denied = [pscustomobject]@{ Allowed = $false; DenySuffix = '' }
    try {
        $labels = [regex]::Matches([string]$PromptText, $script:ModelRoutingParallelBranchLinePattern)
        if ($labels.Count -ne 1) {
            return $denied
        }
        $branch = $labels[0].Groups[1].Value
        $slug = Get-ParallelRecordsSlug -BranchName $branch
        if ($null -eq $slug -or (Find-WorktreeResolutionBranchSignal -Text $PromptText) -cne $branch) {
            return $denied
        }
        if ([string]::IsNullOrWhiteSpace($WorktreeRoot)) {
            return $denied
        }
        $text = Get-WorktreeRunCheckpointText -Path (Get-WorktreeRunCheckpointPath -Kind parallel -WorktreeRoot $WorktreeRoot)
        $decision = Get-ParallelRecordsCheckpointDecision -CheckpointText $text -Slug $slug
        if ($decision.Allowed) {
            return [pscustomobject]@{ Allowed = $true; DenySuffix = '' }
        }
        $detail = [string]$decision.Detail
        if ($decision.SubCode -ceq 'PARALLEL_RECORDS_RECEIPT_MISSING') {
            $detail += ' Remedy: record a pr-author entry in model_routing_receipts of the parallel checkpoint before delegating.'
        }
        return [pscustomobject]@{ Allowed = $false; DenySuffix = " Parallel records leg not applied: $($decision.SubCode): $detail" }
    }
    catch {
        Write-Debug "MODEL_ROUTING_PARALLEL_LEG_ERROR: $($_.Exception.Message)"
        return $denied
    }
}
