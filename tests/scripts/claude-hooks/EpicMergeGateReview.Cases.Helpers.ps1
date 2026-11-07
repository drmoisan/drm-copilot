<#
.SYNOPSIS
    Shared case table of the merge-gate review guard (issue #1097).

.DESCRIPTION
    Dot-sourced by enforce-epic-merge-gate.ReviewGuard.Tests.ps1, enforce-epic-merge-gate.ReviewPaths.Tests.ps1,
    and the Codex suite enforce-epic-merge-gate-review.Tests.ps1, so both runtimes run the same rows
    through their own gate. Each row names a checkpoint override over a ready epic-child checkpoint
    bound to pull request 42, the gh result, the two git results, and the expected code or allow.

    This file holds data and in-memory fixtures only. It starts no process, reads no file, and writes
    no file. The backslash value is composed with [char]92, so the suites hold no backslash literal.
#>

function Get-EpicMergeGateReviewHead {
    <#
    .SYNOPSIS
        Return a fixture object id: the reviewed head or a later live head.
    .PARAMETER Kind
        Reviewed or Live.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][ValidateSet('Reviewed', 'Live')][string] $Kind)

    if ($Kind -ceq 'Reviewed') { return 'abcdef0123456789abcdef0123456789abcdef01' }
    return 'fedcba9876543210fedcba9876543210fedcba98'
}

function Get-EpicMergeGateReviewFolder {
    <#
    .SYNOPSIS
        Return the feature folder of the fixture checkpoint.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    return 'docs/features/active/item-42'
}

function Get-EpicMergeGateReviewListing {
    <#
    .SYNOPSIS
        Join paths into the NUL-terminated listing of git diff --name-only -z.
    .PARAMETER Path
        The listed paths.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][string[]] $Path)

    return (($Path | ForEach-Object { $_ + [char]0 }) -join '')
}

function ConvertTo-EpicMergeGateReviewCheckpointJson {
    <#
    .SYNOPSIS
        Return the ready epic-child checkpoint for pull request 42 as JSON text, with changes.
    .PARAMETER Override
        Top-level keys to set or replace.
    .PARAMETER Remove
        Top-level keys to drop.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([hashtable] $Override = @{}, [string[]] $Remove = @())

    $document = [ordered]@{
        epic_mode        = $true
        step9_status     = 'passed'
        pr_gate          = [ordered]@{ pr_number = 42 }
        'feature-folder' = (Get-EpicMergeGateReviewFolder)
        review_mode      = 'concurrent'
        remediation_loop = [ordered]@{ review_outcomes = @([ordered]@{ verdict = 'PASS'; head_sha = (Get-EpicMergeGateReviewHead -Kind Reviewed) }) }
    }
    foreach ($key in $Override.Keys) { $document[$key] = $Override[$key] }
    foreach ($key in $Remove) { $document.Remove($key) }
    return ($document | ConvertTo-Json -Depth 8 -Compress)
}

function Get-EpicMergeGateReviewOutcomeOverride {
    <#
    .SYNOPSIS
        Return a checkpoint override whose remediation_loop.review_outcomes is the given list.
    .PARAMETER Outcome
        The list entries; an empty list is allowed.
    .OUTPUTS
        System.Collections.Hashtable
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([Parameter(Mandatory)][AllowEmptyCollection()][object[]] $Outcome)

    return @{ remediation_loop = [ordered]@{ review_outcomes = @($Outcome) } }
}

function Get-EpicMergeGateReviewCaseRow {
    <#
    .SYNOPSIS
        Return the shared rows of the guard, in the order of the design table.
    .DESCRIPTION
        A row that sets GhResult drives Invoke-DocsOnlyGhExe; every other row sets LiveHead for the
        live-head seam. NoProcess states that the row must end before any process starts.
    .OUTPUTS
        System.Collections.Hashtable, one per row
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()

    $reviewed = Get-EpicMergeGateReviewHead -Kind Reviewed
    $live = Get-EpicMergeGateReviewHead -Kind Live
    $folder = Get-EpicMergeGateReviewFolder
    $pass = [ordered]@{ verdict = 'PASS'; head_sha = $reviewed }
    $inFolder = "$folder/evidence/review.md"
    $rows = @(
        @{ Name = 'key-absent'; Remove = @('review_mode'); Expected = 'allow'; NoProcess = $true }
        @{ Name = 'key-absent-bare-command'; Remove = @('review_mode'); Command = 'gh pr merge --merge'; Expected = 'allow'; NoProcess = $true }
        @{ Name = 'key-null'; Override = @{ review_mode = $null }; Expected = 'allow'; NoProcess = $true }
        @{ Name = 'key-sequential'; Override = @{ review_mode = 'sequential' }; Expected = 'allow'; NoProcess = $true }
        @{ Name = 'key-case-variant'; Override = @{ review_mode = 'Concurrent' }; Expected = 'allow'; NoProcess = $true }
        @{ Name = 'key-number'; Override = @{ review_mode = 1 }; Expected = 'allow'; NoProcess = $true }
        @{ Name = 'bare-command'; Command = 'gh pr merge --merge'; Expected = 'REVIEW_GATE_HEAD_UNRESOLVED'; NoProcess = $true }
        @{ Name = 'no-remediation-loop'; Remove = @('remediation_loop'); Expected = 'REVIEW_GATE_NOT_PASSED'; NoProcess = $true }
        @{ Name = 'empty-outcomes'; Override = (Get-EpicMergeGateReviewOutcomeOverride -Outcome @()); Expected = 'REVIEW_GATE_NOT_PASSED'; NoProcess = $true }
        @{ Name = 'last-remediation-after-earlier-pass'; Override = (Get-EpicMergeGateReviewOutcomeOverride -Outcome @($pass, [ordered]@{ verdict = 'REMEDIATION_REQUIRED'; head_sha = $reviewed })); Expected = 'REVIEW_GATE_NOT_PASSED'; NoProcess = $true }
        @{ Name = 'last-entry-not-object'; Override = (Get-EpicMergeGateReviewOutcomeOverride -Outcome @($pass, 'PASS')); Expected = 'REVIEW_GATE_NOT_PASSED'; NoProcess = $true }
        @{ Name = 'verdict-case-variant'; Override = (Get-EpicMergeGateReviewOutcomeOverride -Outcome @([ordered]@{ verdict = 'pass'; head_sha = $reviewed })); Expected = 'REVIEW_GATE_NOT_PASSED'; NoProcess = $true }
        @{ Name = 'head-absent'; Override = (Get-EpicMergeGateReviewOutcomeOverride -Outcome @([ordered]@{ verdict = 'PASS' })); Expected = 'REVIEW_GATE_NOT_PASSED'; NoProcess = $true }
        @{ Name = 'head-uppercase'; Override = (Get-EpicMergeGateReviewOutcomeOverride -Outcome @([ordered]@{ verdict = 'PASS'; head_sha = $reviewed.ToUpperInvariant() })); Expected = 'REVIEW_GATE_NOT_PASSED'; NoProcess = $true }
        @{ Name = 'head-short'; Override = (Get-EpicMergeGateReviewOutcomeOverride -Outcome @([ordered]@{ verdict = 'PASS'; head_sha = $reviewed.Substring(0, 12) })); Expected = 'REVIEW_GATE_NOT_PASSED'; NoProcess = $true }
        @{ Name = 'head-trailing-line-feed'; Override = (Get-EpicMergeGateReviewOutcomeOverride -Outcome @([ordered]@{ verdict = 'PASS'; head_sha = "$reviewed`n" })); Expected = 'REVIEW_GATE_NOT_PASSED'; NoProcess = $true }
        @{ Name = 'gh-failure'; GhResult = @{ ExitCode = 1; Output = '' }; Expected = 'REVIEW_GATE_HEAD_UNRESOLVED' }
        @{ Name = 'gh-malformed-head'; GhResult = @{ ExitCode = 0; Output = '{"headRefOid":"not-an-object-id"}' }; Expected = 'REVIEW_GATE_HEAD_UNRESOLVED' }
        @{ Name = 'gh-unparseable-output'; GhResult = @{ ExitCode = 0; Output = '{broken' }; Expected = 'REVIEW_GATE_HEAD_UNRESOLVED' }
        @{ Name = 'head-equal'; LiveHead = $reviewed; Expected = 'allow' }
        @{ Name = 'not-ancestor'; Ancestor = 1; Expected = 'REVIEW_GATE_HEAD_STALE' }
        @{ Name = 'ancestor-git-failure'; Ancestor = 128; Expected = 'REVIEW_GATE_HEAD_UNRESOLVED' }
        @{ Name = 'feature-folder-blank'; Override = @{ 'feature-folder' = ' ' }; Expected = 'REVIEW_GATE_HEAD_UNRESOLVED' }
        @{ Name = 'feature-folder-dot'; Override = @{ 'feature-folder' = '.' }; Expected = 'REVIEW_GATE_HEAD_UNRESOLVED' }
        @{ Name = 'feature-folder-dot-segment'; Override = @{ 'feature-folder' = 'docs/features/active/../..' }; Expected = 'REVIEW_GATE_HEAD_UNRESOLVED' }
        @{ Name = 'feature-folder-backslash'; Override = @{ 'feature-folder' = ('docs/features/active' + [char]92 + 'item-42') }; Expected = 'REVIEW_GATE_HEAD_UNRESOLVED' }
        @{ Name = 'feature-folder-trailing-slash'; Override = @{ 'feature-folder' = "$folder/" }; Expected = 'REVIEW_GATE_HEAD_UNRESOLVED' }
        @{ Name = 'diff-git-failure'; DiffExit = 128; Expected = 'REVIEW_GATE_HEAD_UNRESOLVED' }
        @{ Name = 'diff-not-nul-terminated'; Diff = $inFolder; Expected = 'REVIEW_GATE_HEAD_UNRESOLVED' }
        @{ Name = 'code-change-after-review'; Diff = (Get-EpicMergeGateReviewListing -Path 'src/app.ts'); Expected = 'REVIEW_GATE_HEAD_STALE'; ReasonNames = 'src/app.ts' }
        @{ Name = 'merge-of-origin-main'; Diff = (Get-EpicMergeGateReviewListing -Path '.github/workflows/ci.yml', 'package.json'); Expected = 'REVIEW_GATE_HEAD_STALE'; ReasonNames = '.github/workflows/ci.yml' }
        @{ Name = 'mixed-paths'; Diff = (Get-EpicMergeGateReviewListing -Path $inFolder, 'src/app.ts'); Expected = 'REVIEW_GATE_HEAD_STALE'; ReasonNames = 'src/app.ts' }
        @{ Name = 'sibling-folder-prefix'; Diff = (Get-EpicMergeGateReviewListing -Path "$folder-sibling/notes.md"); Expected = 'REVIEW_GATE_HEAD_STALE'; ReasonNames = "$folder-sibling/notes.md" }
        @{ Name = 'predecessor-feature-folder-only'; Diff = (Get-EpicMergeGateReviewListing -Path $inFolder); Expected = 'allow' }
        @{ Name = 'predecessor-empty-diff'; Expected = 'allow' }
        @{ Name = 'unbound-pr-number'; Command = 'gh pr merge 99 --merge'; Ancestor = 1; Expected = 'REVIEW_GATE_HEAD_STALE' }
    )
    foreach ($row in $rows) {
        $complete = @{ Command = 'gh pr merge 42 --merge'; Override = @{}; Remove = @(); LiveHead = $live; GhResult = $null; Ancestor = 0; DiffExit = 0; Diff = ''; NoProcess = $false; ReasonNames = '' }
        foreach ($key in $row.Keys) { $complete[$key] = $row[$key] }
        $complete
    }
}

function Register-EpicMergeGateReviewRowSeam {
    <#
    .SYNOPSIS
        Register the process seam mocks of one row, for the current test.
    .PARAMETER Row
        A row of Get-EpicMergeGateReviewCaseRow.
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][hashtable] $Row)

    $ghResult = $Row.GhResult
    $liveHead = $Row.LiveHead
    $ancestor = $Row.Ancestor
    $diffExit = $Row.DiffExit
    $diff = $Row.Diff
    if ($null -ne $ghResult) {
        Mock Invoke-DocsOnlyGhExe -MockWith ({ [pscustomobject]$ghResult }.GetNewClosure())
    } else {
        Mock Get-EpicMergeGateReviewLiveHeadSha -MockWith ({ $liveHead }.GetNewClosure())
    }
    Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -ceq 'merge-base' } -MockWith ({ [pscustomobject]@{ ExitCode = $ancestor; Output = '' } }.GetNewClosure())
    Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -ceq 'diff' } -MockWith ({ [pscustomobject]@{ ExitCode = $diffExit; Output = $diff } }.GetNewClosure())
}

function Assert-EpicMergeGateReviewRowProcessCount {
    <#
    .SYNOPSIS
        Assert that a row marked NoProcess started no process and read no live head.
    .PARAMETER Row
        A row of Get-EpicMergeGateReviewCaseRow.
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][hashtable] $Row)

    if (-not $Row.NoProcess) { return }
    Should -Invoke Get-EpicMergeGateReviewLiveHeadSha -Times 0 -Exactly
    Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
    Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
}
