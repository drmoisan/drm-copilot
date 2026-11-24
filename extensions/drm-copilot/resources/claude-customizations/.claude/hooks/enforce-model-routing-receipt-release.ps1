<#
.SYNOPSIS
    Release delegation leg of the model-routing gate (issue #1231, Leg 2).

.DESCRIPTION
    Dot-sourced, guarded, by enforce-model-routing-receipt.ps1. Invoke-ModelRoutingReceiptDecision
    calls Get-ModelRoutingReleaseDecision only for an Agent(pr-author) delegation whose resolved
    worktree holds no checkpoint, after the parallel records and docs-estate legs have declined.
    The leg lets a checkpoint-free release run delegate the pull request when the destination
    repository commits .claude/release-commit-allowance.json beneath the resolved root R.

    Evaluation order (the first failure decides):
      1 R blank or the allowance file absent: not allowed, empty suffix, no git call;
      2 RELEASE_DELEGATION_CONFIG_INVALID     - read failure, parse failure, or directory entry;
      3 RELEASE_DELEGATION_LABEL_INVALID      - Get-DocsEstateDelegationLabel returns $null (the
                                                prompt lacks exactly one branch: and one base: line);
      4 RELEASE_DELEGATION_BRANCH_NOT_MATCHED - the branch label matches no branch pattern;
      5 RELEASE_DELEGATION_DIFF_UNREADABLE    - refs/remotes/origin/<base> or HEAD does not resolve
                                                (Get-ModelRoutingDocsEstateCommit), or the bounded
                                                diff fails or returns output not ending in NUL;
      6 RELEASE_DELEGATION_DIFF_EMPTY         - the diff lists no path;
      7 RELEASE_DELEGATION_PATH_NOT_ALLOWED   - no single matching allowance lists every path.
    The remote-head comparison is not repeated here; Leg 1 enforces it at gh pr create. A failure
    adds the suffix ' Release delegation leg not applied: <CODE>: <detail>'.

.NOTES
    PowerShell 7+. Claude only; mirrored byte-identically under
    extensions/drm-copilot/resources/claude-customizations/. Never throws: an unexpected error
    declines with an empty DenySuffix and a Write-Debug record carrying MODEL_ROUTING_RELEASE_LEG_ERROR.
    Every git call runs through the bounded Invoke-DocsOnlyGitExe (hook-docs-only-diff.ps1).
    Call-time dependencies loaded by the gate: Get-DocsEstateDelegationLabel
    (hook-docs-estate-context.ps1), Get-ModelRoutingDocsEstateCommit
    (enforce-model-routing-receipt-docs.ps1), Invoke-DocsOnlyGitExe and ConvertFrom-DocsOnlyNameList
    (hook-docs-only-diff.ps1). This hook file starts no interpreter process. A policy-level control,
    not a security control.
#>

try { . (Join-Path $PSScriptRoot 'enforce-orchestration-preimplementation-gate-release.ps1') } catch { Add-HookDependencyFailure -Name 'enforce-orchestration-preimplementation-gate-release.ps1' -ErrorRecord $_ }
try { . (Join-Path $PSScriptRoot 'hook-release-pull-request-context.ps1') } catch { Add-HookDependencyFailure -Name 'hook-release-pull-request-context.ps1' -ErrorRecord $_ }

function Get-ModelRoutingReleaseNotAppliedResult {
    <#
    .SYNOPSIS
        Return a declined Leg 2 result whose DenySuffix names the code and the detail.
    .PARAMETER Code
        The RELEASE_DELEGATION_* code.
    .PARAMETER Detail
        The detail of the failure.
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)][string] $Code, [Parameter(Mandatory)][string] $Detail)

    return [pscustomobject]@{ Allowed = $false; DenySuffix = " Release delegation leg not applied: ${Code}: $Detail" }
}

function Get-ModelRoutingReleaseDecision {
    <#
    .SYNOPSIS
        Decide whether a checkpoint-free Agent(pr-author) delegation is a release delegation.
    .DESCRIPTION
        Applies steps 1 to 7 of the file header in order. Returns Allowed and DenySuffix.
    .PARAMETER PromptText
        The delegation prompt.
    .PARAMETER WorktreeRoot
        The worktree root R that the gate's identity resolution returned.
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [AllowNull()][AllowEmptyString()][string] $PromptText,
        [AllowNull()][AllowEmptyString()][string] $WorktreeRoot
    )

    $declined = [pscustomobject]@{ Allowed = $false; DenySuffix = '' }
    try {
        $state = Get-ReleasePullRequestConfigState -WorktreeRoot $WorktreeRoot -ConfigReader { param([string] $Root) Get-OrchestrationGateReleaseAllowanceConfigText -WorktreeRoot $Root } -ContainerProbe { param([string] $Root, [string] $RelativePath) Test-OrchestrationGateReleaseAllowancePathIsContainer -WorktreeRoot $Root -RelativePath $RelativePath }
        if ($state.State -ceq 'Absent') { return $declined }
        if ($state.State -cne 'Valid') { return (Get-ModelRoutingReleaseNotAppliedResult 'RELEASE_DELEGATION_CONFIG_INVALID' ([string]$state.Detail)) }
        $labels = Get-DocsEstateDelegationLabel -PromptText $PromptText
        if ($null -eq $labels) {
            return (Get-ModelRoutingReleaseNotAppliedResult 'RELEASE_DELEGATION_LABEL_INVALID' "the prompt must carry exactly one 'branch: <name>' line and exactly one 'base: <branch>' line, each without '..'.")
        }
        $allowances = @($state.Allowances)
        $branch = [string]$labels.Branch
        $matched = @($allowances | Where-Object { $allowance = $_; @(@($allowance.BranchPatterns) | Where-Object { Test-ReleaseAllowanceBranchMatch -Branch $branch -Pattern $_ }).Count -gt 0 })
        if ($matched.Count -eq 0) { return (Get-ModelRoutingReleaseNotAppliedResult 'RELEASE_DELEGATION_BRANCH_NOT_MATCHED' "branch '$branch' matches no allowance.") }
        $unreadable = Get-ModelRoutingReleaseNotAppliedResult 'RELEASE_DELEGATION_DIFF_UNREADABLE' "the diff against refs/remotes/origin/$($labels.Base) could not be read; run git fetch origin $($labels.Base), then retry."
        $baseCommit = Get-ModelRoutingDocsEstateCommit -WorktreeRoot $WorktreeRoot -Ref ('refs/remotes/origin/' + $labels.Base)
        $headCommit = Get-ModelRoutingDocsEstateCommit -WorktreeRoot $WorktreeRoot -Ref 'HEAD'
        if ($null -eq $baseCommit -or $null -eq $headCommit) { return $unreadable }
        $diff = Invoke-DocsOnlyGitExe -WorktreeRoot $WorktreeRoot -GitArgs @('diff', '--name-only', '-z', '--no-renames', '--no-color', '--no-ext-diff', '--no-relative', ($baseCommit + '...HEAD'))
        $text = if ($null -ne $diff) { [string]$diff.Output } else { '' }
        if ($null -eq $diff -or $diff.ExitCode -ne 0 -or ($text.Length -gt 0 -and -not $text.EndsWith([char]0))) { return $unreadable }
        $paths = [string[]]@(ConvertFrom-DocsOnlyNameList -Text $text)
        if ($paths.Count -eq 0) { return (Get-ModelRoutingReleaseNotAppliedResult 'RELEASE_DELEGATION_DIFF_EMPTY' "the diff against refs/remotes/origin/$($labels.Base) lists no path.") }
        $decision = Get-ReleasePullRequestPathDecision -Allowances $allowances -Branch $branch -Path $paths
        if (-not $decision.Allowed) { return (Get-ModelRoutingReleaseNotAppliedResult 'RELEASE_DELEGATION_PATH_NOT_ALLOWED' "$($decision.Detail).") }
        return [pscustomobject]@{ Allowed = $true; DenySuffix = '' }
    } catch {
        Write-Debug "MODEL_ROUTING_RELEASE_LEG_ERROR: $($_.Exception.Message)"
        return $declined
    }
}
