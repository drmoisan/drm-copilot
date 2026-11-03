<#
.SYNOPSIS
    Cleanup exemption from the checkpoint preflight of enforce-pr-author-skill.ps1 (issue #1026).

.DESCRIPTION
    Dot-sourced by enforce-pr-author-skill.docs-only.ps1. Get-PrAuthorBypassReason calls
    Get-PrAuthorPreflightExemption, which has the parameters and the return shape of
    Get-PrAuthorDocsOnlyExemption, only in its non-epic branch and only after
    Invoke-OrchestratorStatePreflight reports errors. The wrapper evaluates the docs-only
    exemption first and returns its result unchanged when it is exempt, or when the matched
    gh pr create or gh pr edit segment names no consolidation branch: no token equals
    documentationandmemories or ends with '=documentationandmemories' or
    ':documentationandmemories' (ordinal). Inside that cleanup context the cleanup exemption is
    evaluated, and the first failed condition names the sub-code appended to the docs-only
    reason after '; cleanup exemption not applied: '.

      K1 CLEANUP_EXEMPTION_NOT_CREATE           - the command is a structural gh pr create.
      K2 CLEANUP_EXEMPTION_CHECKPOINT_PRESENT   - no checkpoint file exists at the resolved path.
      K3 CLEANUP_EXEMPTION_HEAD_UNRESOLVED      - exactly one --head token, its value ordinal-equal
                                                  to documentationandmemories, with no --head= form
                                                  and no single-dash token containing H.
      K4 CLEANUP_EXEMPTION_BASE_UNRESOLVED      - Get-PrAuthorDocsOnlyBaseName returns exactly main.
      K5 CLEANUP_EXEMPTION_MANIFEST_INVALID     - the session-root manifest read through
                                                  Get-CleanupWorktreeManifestContent passes
                                                  Test-CleanupManifestText with the
                                                  Get-CleanupWorktreeManifestUtcNow clock.
      K6 CLEANUP_EXEMPTION_DIFF_FAILED          - refs/remotes/origin/main resolves to a commit and
                                                  git diff <commit>...HEAD exits 0 with output that
                                                  ends with NUL when non-empty.
         CLEANUP_EXEMPTION_EMPTY_DIFF           - the diff lists at least one path.
         CLEANUP_EXEMPTION_NON_ALLOWLISTED_PATH - every path is under docs/ or .claude/agent-memory/
                                                  (Test-CleanupConsolidationRelativePath).

    The receipt checks run unchanged after the exemption. A pull request that names no
    consolidation branch receives the docs-only result unchanged, so its denial text is the
    text it is today.

.NOTES
    PowerShell 7+. Call-time dependencies from the docs-only sibling and the parsers the helpers
    load: Get-PrAuthorDocsOnlyExemption, Test-PrAuthorDocsOnlyCheckpointPresence,
    Get-PrAuthorDocsOnlyBaseName, Invoke-PrAuthorDocsOnlyGitExe, ConvertFrom-DocsOnlyNameList,
    Test-CommandLineInvocation, and Get-CommandLineStructuralMatch. git runs only through
    Invoke-PrAuthorDocsOnlyGitExe, and every git call is wrapped so a throwing seam denies.
    Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/.
#>
[CmdletBinding()]
param()
try { . (Join-Path $PSScriptRoot 'hook-cleanup-context.ps1') } catch { Add-HookDependencyFailure -Name 'hook-cleanup-context.ps1' -ErrorRecord $_ }
try { Import-Module (Join-Path $PSScriptRoot '../lib/cleanup-manifest/CleanupWorktreeManifest.psm1') -Force -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'CleanupWorktreeManifest.psm1' -ErrorRecord $_ }

function Get-PrAuthorCleanupSegmentToken {
    <#
    .SYNOPSIS
        Return the tokens of the matched gh pr create segment, else of gh pr edit, or an empty array.
    .OUTPUTS
        System.String[]
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param([Parameter(Mandatory)][AllowEmptyString()][string] $CommandText)

    foreach ($subcommand in @('create', 'edit')) {
        $match = Get-CommandLineStructuralMatch -CommandText $CommandText -CommandWord 'gh' -SubcommandPath @('pr', $subcommand)
        if ($null -ne $match) {
            return [string[]]@($match.Segment.Tokens | ForEach-Object { [string]$_ })
        }
    }
    return [string[]]@()
}

function Test-PrAuthorCleanupContextCommand {
    <#
    .SYNOPSIS
        Return $true when the matched gh pr segment names the consolidation branch.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)][AllowEmptyString()][string] $CommandText)

    $branch = $script:CleanupContextBranch
    foreach ($token in @(Get-PrAuthorCleanupSegmentToken -CommandText $CommandText)) {
        if ($token -ceq $branch -or $token.EndsWith("=$branch", [System.StringComparison]::Ordinal) -or $token.EndsWith(":$branch", [System.StringComparison]::Ordinal)) {
            return $true
        }
    }
    return $false
}

function Get-PrAuthorCleanupExemptionFailure {
    <#
    .SYNOPSIS
        Evaluate K1 to K6 of the file header and return the first failure text, or $null.
    .OUTPUTS
        System.String or $null
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][string] $CommandText,
        [AllowNull()][AllowEmptyString()][string] $WorktreeRoot,
        [AllowNull()][AllowEmptyString()][string] $CheckpointPath
    )

    $branch = $script:CleanupContextBranch
    if (-not (Test-CommandLineInvocation -CommandText $CommandText -CommandWord 'gh' -SubcommandPath @('pr', 'create'))) {
        return 'CLEANUP_EXEMPTION_NOT_CREATE: only gh pr create is eligible.'
    }
    if (Test-PrAuthorDocsOnlyCheckpointPresence -CheckpointPath $CheckpointPath) {
        return "CLEANUP_EXEMPTION_CHECKPOINT_PRESENT: a checkpoint file exists at '$CheckpointPath', so its preflight governs."
    }
    $tokens = @(Get-PrAuthorCleanupSegmentToken -CommandText $CommandText)
    $headIndex = @(for ($index = 0; $index -lt $tokens.Count; $index++) { if ($tokens[$index] -ceq '--head') { $index } })
    $headVariant = @($tokens | Where-Object { $_.StartsWith('--head=', [System.StringComparison]::Ordinal) -or ($_ -cmatch '^-[^-]' -and $_.Substring(1).Contains('H')) })
    if ($headIndex.Count -ne 1 -or $headVariant.Count -gt 0 -or $headIndex[0] + 1 -ge $tokens.Count -or $tokens[$headIndex[0] + 1] -cne $branch) {
        return "CLEANUP_EXEMPTION_HEAD_UNRESOLVED: pass exactly one explicit --head $branch; -H, --head=, and a repeated --head are not accepted."
    }
    if ((Get-PrAuthorDocsOnlyBaseName -CommandText $CommandText) -cne 'main') {
        return 'CLEANUP_EXEMPTION_BASE_UNRESOLVED: pass exactly one explicit --base main and no base or repository override.'
    }
    try {
        $manifestValid = Test-CleanupManifestText -Raw (Get-CleanupWorktreeManifestContent) -UtcNow (Get-CleanupWorktreeManifestUtcNow)
    }
    catch {
        $manifestValid = $false
    }
    if (-not $manifestValid) {
        return "CLEANUP_EXEMPTION_MANIFEST_INVALID: the session-root manifest $($script:CleanupContextManifestRelativePath) is absent, invalid, older than $($script:CleanupContextFreshnessHours) hours, in the future, or has no run_id."
    }

    try {
        $revParse = Invoke-PrAuthorDocsOnlyGitExe -WorktreeRoot $WorktreeRoot -GitArgs @('rev-parse', '--verify', '--quiet', 'refs/remotes/origin/main^{commit}')
    }
    catch {
        $revParse = $null
    }
    $commit = if ($null -ne $revParse) { ([string]$revParse.Output).Trim() } else { '' }
    if ($null -eq $revParse -or $revParse.ExitCode -ne 0 -or $commit -cnotmatch '^[0-9a-f]{40}([0-9a-f]{24})?$') {
        return 'CLEANUP_EXEMPTION_DIFF_FAILED: refs/remotes/origin/main does not resolve to a commit in the consolidation worktree.'
    }
    try {
        $diff = Invoke-PrAuthorDocsOnlyGitExe -WorktreeRoot $WorktreeRoot -GitArgs @('diff', '--name-only', '-z', '--no-renames', '--no-color', '--no-ext-diff', '--no-relative', ($commit + '...HEAD'))
    }
    catch {
        $diff = $null
    }
    $text = if ($null -ne $diff) { [string]$diff.Output } else { '' }
    if ($null -eq $diff -or $diff.ExitCode -ne 0 -or ($text.Length -gt 0 -and -not $text.EndsWith([char]0))) {
        return 'CLEANUP_EXEMPTION_DIFF_FAILED: git diff against origin/main could not be computed or did not return NUL-terminated output.'
    }
    $paths = @(ConvertFrom-DocsOnlyNameList -Text $text)
    if ($paths.Count -eq 0) {
        return 'CLEANUP_EXEMPTION_EMPTY_DIFF: the branch diff lists no path.'
    }
    foreach ($path in $paths) {
        if (-not (Test-CleanupConsolidationRelativePath -RelativePath $path)) {
            return "CLEANUP_EXEMPTION_NON_ALLOWLISTED_PATH: '$path' is outside docs/ and .claude/agent-memory/."
        }
    }
    return $null
}

function Get-PrAuthorPreflightExemption {
    <#
    .SYNOPSIS
        Decide whether a failed preflight is exempt as docs-only or as a cleanup consolidation PR.
    .DESCRIPTION
        Returns the docs-only result unchanged when it is exempt or when the command names no
        consolidation branch. Otherwise evaluates the cleanup exemption and, on failure, returns
        the docs-only reason followed by '; cleanup exemption not applied: ' and the sub-code.
    .PARAMETER CommandText
        The Bash command text under evaluation.
    .PARAMETER WorktreeRoot
        The resolved worktree root the diff is computed in.
    .PARAMETER CheckpointPath
        The resolved checkpoint path whose absence both exemptions require.
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

    $docsOnly = Get-PrAuthorDocsOnlyExemption -CommandText $CommandText -WorktreeRoot $WorktreeRoot -CheckpointPath $CheckpointPath
    if ($docsOnly.Exempt -or -not (Test-PrAuthorCleanupContextCommand -CommandText $CommandText)) {
        return $docsOnly
    }
    $failure = Get-PrAuthorCleanupExemptionFailure -CommandText $CommandText -WorktreeRoot $WorktreeRoot -CheckpointPath $CheckpointPath
    if ($null -eq $failure) {
        return [ordered]@{ Exempt = $true; Reason = $null }
    }
    return [ordered]@{ Exempt = $false; Reason = "$($docsOnly.Reason); cleanup exemption not applied: $failure" }
}
