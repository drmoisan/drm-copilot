<#
.SYNOPSIS
    Release exemption from the checkpoint preflight of enforce-pr-author-skill.ps1 (issue #1231, Leg 1).

.DESCRIPTION
    Dot-sourced, guarded, by enforce-pr-author-skill.cleanup.ps1. Get-PrAuthorPreflightExemption
    calls Get-PrAuthorReleaseExemption only when the docs-only and cleanup result is not exempt,
    which happens only in the non-epic branch of Get-PrAuthorBypassReason and only after
    Invoke-OrchestratorStatePreflight reports errors. The exemption lets a checkpoint-free
    gh pr create of a release branch continue to the receipt checks when the destination
    repository commits .claude/release-commit-allowance.json beneath the artifact root R.

    Evaluation order (the first failure decides; the reason is '<CODE>: <detail>'):
       1 R blank or the allowance file absent: not exempt, reason $null, no git call;
       2 RELEASE_EXEMPTION_CONFIG_INVALID       - read failure, parse failure, or directory entry;
       3 RELEASE_EXEMPTION_NOT_CREATE           - not a structural gh pr create (gh pr edit too);
       4 RELEASE_EXEMPTION_CHECKPOINT_PRESENT   - Test-PrAuthorDocsOnlyCheckpointPresence is true;
       5 RELEASE_EXEMPTION_HEAD_UNRESOLVED      - not exactly one --head token, a --head= token, a
                                                  single-dash token containing H, a missing value, or
                                                  a value outside ^[A-Za-z0-9][A-Za-z0-9._/-]*$ or
                                                  containing '..';
       6 RELEASE_EXEMPTION_BASE_UNRESOLVED      - Get-PrAuthorDocsOnlyBaseName returns $null (also
                                                  -R, --repo, --repo=, and GH_REPO=);
       7 RELEASE_EXEMPTION_BRANCH_NOT_MATCHED   - the --head value matches no branch pattern;
       8 RELEASE_EXEMPTION_REMOTE_HEAD_MISMATCH - refs/remotes/origin/<head> does not resolve or
                                                  differs from HEAD (Get-PrAuthorReleasePublishedHead);
       9 RELEASE_EXEMPTION_DIFF_FAILED          - refs/remotes/origin/<base> does not resolve, or the
                                                  diff fails or returns output not ending in NUL;
      10 RELEASE_EXEMPTION_EMPTY_DIFF           - the diff lists no path;
      11 RELEASE_EXEMPTION_PATH_NOT_ALLOWED     - no single matching allowance lists every path.
    No git call runs before step 8. The diff argument list equals the cleanup leg's:
    diff --name-only -z --no-renames --no-color --no-ext-diff --no-relative <commit>...HEAD.

.NOTES
    PowerShell 7+. Claude only; mirrored byte-identically under
    extensions/drm-copilot/resources/claude-customizations/. Never throws: an unexpected error
    declines with a $null reason and a Write-Debug record carrying PR_AUTHOR_RELEASE_LEG_ERROR.
    Call-time dependencies from the siblings the pr-author gate loads:
    Test-CommandLineInvocation, Test-PrAuthorDocsOnlyCheckpointPresence,
    Get-PrAuthorDocsOnlyBaseName, Invoke-PrAuthorDocsOnlyGitExe, ConvertFrom-DocsOnlyNameList, and
    Get-PrAuthorCleanupSegmentToken. git runs only through Invoke-PrAuthorDocsOnlyGitExe. This hook
    file starts no interpreter process. A policy-level control, not a security control: the legs
    compare local tracking refs and never fetch.
#>

try { . (Join-Path $PSScriptRoot 'enforce-orchestration-preimplementation-gate-release.ps1') } catch { Add-HookDependencyFailure -Name 'enforce-orchestration-preimplementation-gate-release.ps1' -ErrorRecord $_ }
try { . (Join-Path $PSScriptRoot 'hook-release-pull-request-context.ps1') } catch { Add-HookDependencyFailure -Name 'hook-release-pull-request-context.ps1' -ErrorRecord $_ }

$script:ReleasePullRequestBranchRule = '^[A-Za-z0-9][A-Za-z0-9._/-]*$'
$script:ReleasePullRequestCommitRule = '^[0-9a-f]{40}([0-9a-f]{24})?$'

function Get-PrAuthorReleasePublishedHead {
    <#
    .SYNOPSIS
        Resolve refs/remotes/origin/<branch> and HEAD of a worktree (test seam).
    .DESCRIPTION
        Runs git rev-parse --verify --quiet <ref>^{commit} through Invoke-PrAuthorDocsOnlyGitExe for
        refs/remotes/origin/<Branch> and for HEAD. Each value is the printed commit, or an empty
        string when the call throws, exits non-zero, or prints a value that is not a 40- or
        64-digit lowercase hex commit. Never throws. Tests mock this function.
    .PARAMETER WorktreeRoot
        The artifact root R.
    .PARAMETER Branch
        The --head branch.
    .OUTPUTS
        System.Management.Automation.PSCustomObject with Remote and Head.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param([AllowNull()][AllowEmptyString()][string] $WorktreeRoot, [Parameter(Mandatory)][string] $Branch)

    $resolved = foreach ($ref in @("refs/remotes/origin/$Branch", 'HEAD')) {
        try {
            $result = Invoke-PrAuthorDocsOnlyGitExe -WorktreeRoot $WorktreeRoot -GitArgs @('rev-parse', '--verify', '--quiet', ($ref + '^{commit}'))
        } catch {
            $result = $null
        }
        $value = if ($null -ne $result -and $result.ExitCode -eq 0) { ([string]$result.Output).Trim() } else { '' }
        if ($value -cmatch $script:ReleasePullRequestCommitRule) { $value } else { '' }
    }
    return [pscustomobject]@{ Remote = [string]$resolved[0]; Head = [string]$resolved[1] }
}

function Get-PrAuthorReleaseHeadName {
    <#
    .SYNOPSIS
        Return the single explicit --head value of the matched gh pr create segment, or $null.
    .PARAMETER CommandText
        The Bash command text.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][AllowEmptyString()][string] $CommandText)

    $tokens = [string[]]@(Get-PrAuthorCleanupSegmentToken -CommandText $CommandText)
    $headIndex = @(for ($index = 0; $index -lt $tokens.Count; $index++) { if ($tokens[$index] -ceq '--head') { $index } })
    $variant = @($tokens | Where-Object { $_.StartsWith('--head=', [System.StringComparison]::Ordinal) -or ($_ -cmatch '^-[^-]' -and $_.Substring(1).Contains('H')) })
    if ($headIndex.Count -ne 1 -or $variant.Count -gt 0 -or $headIndex[0] + 1 -ge $tokens.Count) { return $null }
    $value = $tokens[$headIndex[0] + 1]
    if ($value -cnotmatch $script:ReleasePullRequestBranchRule -or $value.Contains('..')) { return $null }
    return $value
}

function Get-PrAuthorReleaseExemption {
    <#
    .SYNOPSIS
        Decide whether a failed preflight is exempt as a release pull request (issue #1231).
    .DESCRIPTION
        Applies steps 1 to 11 of the file header in order.
    .PARAMETER CommandText
        The Bash command text under evaluation.
    .PARAMETER WorktreeRoot
        The artifact root R the allowance file and the diff are read in.
    .PARAMETER CheckpointPath
        The resolved checkpoint path whose absence the exemption requires.
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary with Exempt and Reason.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory)][string] $CommandText,
        [AllowNull()][AllowEmptyString()][string] $WorktreeRoot,
        [AllowNull()][AllowEmptyString()][string] $CheckpointPath
    )

    try {
        $state = Get-ReleasePullRequestConfigState -WorktreeRoot $WorktreeRoot -ConfigReader { param([string] $Root) Get-OrchestrationGateReleaseAllowanceConfigText -WorktreeRoot $Root } -ContainerProbe { param([string] $Root, [string] $RelativePath) Test-OrchestrationGateReleaseAllowancePathIsContainer -WorktreeRoot $Root -RelativePath $RelativePath }
        if ($state.State -ceq 'Absent') { return [ordered]@{ Exempt = $false; Reason = $null } }
        if ($state.State -cne 'Valid') { return [ordered]@{ Exempt = $false; Reason = "RELEASE_EXEMPTION_CONFIG_INVALID: $($state.Detail)" } }
        if (-not (Test-CommandLineInvocation -CommandText $CommandText -CommandWord 'gh' -SubcommandPath @('pr', 'create'))) {
            return [ordered]@{ Exempt = $false; Reason = 'RELEASE_EXEMPTION_NOT_CREATE: only gh pr create is eligible.' }
        }
        if (Test-PrAuthorDocsOnlyCheckpointPresence -CheckpointPath $CheckpointPath) {
            return [ordered]@{ Exempt = $false; Reason = "RELEASE_EXEMPTION_CHECKPOINT_PRESENT: a checkpoint file exists at '$CheckpointPath', so its preflight governs." }
        }
        $head = Get-PrAuthorReleaseHeadName -CommandText $CommandText
        if ($null -eq $head) {
            return [ordered]@{ Exempt = $false; Reason = 'RELEASE_EXEMPTION_HEAD_UNRESOLVED: pass exactly one explicit --head <branch>; -H, --head=, owner:branch, and a repeated --head are not accepted.' }
        }
        $base = Get-PrAuthorDocsOnlyBaseName -CommandText $CommandText
        if ($null -eq $base) {
            return [ordered]@{ Exempt = $false; Reason = 'RELEASE_EXEMPTION_BASE_UNRESOLVED: pass exactly one explicit --base <branch> and no base or repository override.' }
        }
        $allowances = @($state.Allowances)
        $matched = @($allowances | Where-Object { $allowance = $_; @(@($allowance.BranchPatterns) | Where-Object { Test-ReleaseAllowanceBranchMatch -Branch $head -Pattern $_ }).Count -gt 0 })
        if ($matched.Count -eq 0) {
            return [ordered]@{ Exempt = $false; Reason = "RELEASE_EXEMPTION_BRANCH_NOT_MATCHED: branch '$head' matches no allowance." }
        }

        $published = Get-PrAuthorReleasePublishedHead -WorktreeRoot $WorktreeRoot -Branch $head
        if ($null -eq $published -or [string]::IsNullOrEmpty([string]$published.Remote) -or [string]::IsNullOrEmpty([string]$published.Head) -or [string]$published.Remote -cne [string]$published.Head) {
            return [ordered]@{ Exempt = $false; Reason = "RELEASE_EXEMPTION_REMOTE_HEAD_MISMATCH: refs/remotes/origin/$head does not resolve or differs from HEAD; push the branch immediately before gh pr create." }
        }
        $diffFailed = [ordered]@{ Exempt = $false; Reason = "RELEASE_EXEMPTION_DIFF_FAILED: git diff against origin/$base could not be computed or did not return NUL-terminated output." }
        $revParse = Invoke-PrAuthorDocsOnlyGitExe -WorktreeRoot $WorktreeRoot -GitArgs @('rev-parse', '--verify', '--quiet', ('refs/remotes/origin/' + $base + '^{commit}'))
        $commit = if ($null -ne $revParse) { ([string]$revParse.Output).Trim() } else { '' }
        if ($null -eq $revParse -or $revParse.ExitCode -ne 0 -or $commit -cnotmatch $script:ReleasePullRequestCommitRule) { return $diffFailed }
        $diff = Invoke-PrAuthorDocsOnlyGitExe -WorktreeRoot $WorktreeRoot -GitArgs @('diff', '--name-only', '-z', '--no-renames', '--no-color', '--no-ext-diff', '--no-relative', ($commit + '...HEAD'))
        $text = if ($null -ne $diff) { [string]$diff.Output } else { '' }
        if ($null -eq $diff -or $diff.ExitCode -ne 0 -or ($text.Length -gt 0 -and -not $text.EndsWith([char]0))) { return $diffFailed }
        $paths = [string[]]@(ConvertFrom-DocsOnlyNameList -Text $text)
        if ($paths.Count -eq 0) {
            return [ordered]@{ Exempt = $false; Reason = "RELEASE_EXEMPTION_EMPTY_DIFF: the diff against origin/$base lists no path." }
        }
        $decision = Get-ReleasePullRequestPathDecision -Allowances $allowances -Branch $head -Path $paths
        if (-not $decision.Allowed) {
            return [ordered]@{ Exempt = $false; Reason = "RELEASE_EXEMPTION_PATH_NOT_ALLOWED: $($decision.Detail)." }
        }
        return [ordered]@{ Exempt = $true; Reason = $null }
    } catch {
        Write-Debug "PR_AUTHOR_RELEASE_LEG_ERROR: $($_.Exception.Message)"
        return [ordered]@{ Exempt = $false; Reason = $null }
    }
}
