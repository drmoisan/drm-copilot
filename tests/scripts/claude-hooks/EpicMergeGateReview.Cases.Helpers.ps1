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
    .PARAMETER CiHeadSha
        The head_sha of the green ci_gate, which equals the row's live head (issue #1130).
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([hashtable] $Override = @{}, [string[]] $Remove = @(), [string] $CiHeadSha = (Get-EpicMergeGateReviewHead -Kind Reviewed))

    $document = [ordered]@{
        epic_mode        = $true
        step9_status     = 'passed'
        pr_gate          = [ordered]@{ pr_number = 42 }
        ci_gate          = [ordered]@{ conclusion = 'success'; head_sha = $CiHeadSha }
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

function Get-EpicMergeGateReviewConfirmationQuery {
    <#
    .SYNOPSIS
        Return the merge-confirmation query of step 3 of the parallel skill's merge section, for
        pull request 42.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    return 'gh api graphql -f query=''query($owner:String!,$name:String!,$number:Int!){repository(owner:$owner,name:$name){pullRequest(number:$number){state mergedAt isInMergeQueue mergeCommit{oid} autoMergeRequest{enabledAt}}}}'' -F owner=''{owner}'' -F name=''{repo}'' -F number=42 --jq .data.repository.pullRequest'
}

function Get-EpicMergeGateReviewDeniedForm {
    <#
    .SYNOPSIS
        Return the merge forms the shape rule denies under the key, as Name and Command rows.
    .DESCRIPTION
        One row per denied form of the plan's decisions section, on pull request 42 with second
        number 41. Each backslash is composed with [char]92.
    .OUTPUTS
        System.Collections.Hashtable, one per form
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()

    $backslash = [string][char]92
    $forms = [ordered]@{
        'wrapper-if-then'                = 'if gh pr checks 42; then gh pr merge 42 --merge; fi'
        'wrapper-while'                  = 'while ! gh pr merge 42 --merge; do sleep 1; done'
        'wrapper-for'                    = 'for n in 42; do gh pr merge 42 --merge; done'
        'wrapper-case'                   = 'case 42 in 42) gh pr merge 42 --merge ;; esac'
        'wrapper-exec'                   = 'exec gh pr merge 42 --merge'
        'wrapper-bang'                   = '! gh pr merge 42 --merge'
        'wrapper-time'                   = 'time gh pr merge 42 --merge'
        'wrapper-env'                    = 'env GH_REPO=o/r gh pr merge 42 --merge'
        'wrapper-command'                = 'command gh pr merge 42 --merge'
        'wrapper-builtin'                = 'builtin command gh pr merge 42 --merge'
        'wrapper-subshell'               = '(gh pr merge 42 --merge)'
        'wrapper-brace-group'            = '{ gh pr merge 42 --merge; }'
        'wrapper-dollar-substitution'    = 'echo $(gh pr merge 42 --merge)'
        'wrapper-backtick-substitution'  = 'echo `gh pr merge 42 --merge`'
        'wrapper-eval'                   = 'eval "gh pr merge 42 --merge"'
        'wrapper-sh-c'                   = 'sh -c "gh pr merge 42 --merge"'
        'wrapper-bash-c'                 = 'bash -c "gh pr merge 42 --merge"'
        'wrapper-pwsh-c'                 = 'pwsh -c "gh pr merge 42 --merge"'
        'wrapper-xargs'                  = 'echo 42 | xargs gh pr merge --merge'
        'wrapper-leading-backslash'      = ($backslash + 'gh pr merge 42 --merge')
        'wrapper-cd-prefix'              = 'cd repo && gh pr merge 42 --merge'
        'split-backslash-word'           = ('gh pr mer' + $backslash + 'ge 42 --merge')
        'split-variable-subcommand'      = 'gh pr $SUB 42 --merge'
        'split-substituted-subcommand'   = 'gh pr $(echo merge) 42 --merge'
        'api-rest-merge'                 = 'gh api -X PUT repos/o/r/pulls/42/merge'
        'api-rest-merge-variable-number' = 'gh api -X PUT repos/o/r/pulls/$PR/merge'
        'api-curl-rest-merge'            = 'curl -X PUT https://api.github.com/repos/o/r/pulls/42/merge'
        'api-graphql-merge'              = 'gh api graphql -f query=''mutation { mergePullRequest(input: {pullRequestId: "x"}) { clientMutationId } }'''
        'api-graphql-auto-merge'         = 'gh api graphql -f query=''mutation { enablePullRequestAutoMerge(input: {pullRequestId: "x"}) { clientMutationId } }'''
        'api-graphql-enqueue'            = 'gh api graphql -f query=''mutation { enqueuePullRequest(input: {pullRequestId: "x"}) { clientMutationId } }'''
        'api-graphql-other-mutation'     = 'gh api graphql -f query=''mutation { addStar(input: {starrableId: "x"}) { clientMutationId } }'''
        'api-graphql-query-file'         = 'gh api graphql -F query=@merge.graphql'
        'api-graphql-query-variable'     = 'gh api graphql -f query="$QUERY"'
        'api-graphql-input-file'         = 'gh api graphql --input body.json'
        'flag-auto'                      = 'gh pr merge 42 --merge --auto'
        'flag-admin'                     = 'gh pr merge 42 --merge --admin'
        'flag-repo-short'                = 'gh pr merge 42 --merge -R o/r'
        'flag-repo-long'                 = 'gh pr merge 42 --merge --repo o/r'
        'chain-semicolon'                = 'gh pr merge 42 --merge; gh pr merge 41 --merge'
        'chain-and'                      = 'gh pr merge 42 --merge && gh pr merge 41 --merge'
        'chain-or'                       = 'gh pr merge 42 --merge || gh pr merge 41 --merge'
        'chain-pipe'                     = 'gh pr merge 42 --merge | cat'
        'chain-background'               = 'gh pr merge 42 --merge & gh pr merge 41 --merge'
        'chain-newline'                  = "gh pr merge 42 --merge`ngh pr merge 41 --merge"
        'chain-second-bare'              = 'gh pr merge 42 --merge; gh pr merge --merge'
        'chain-push-then-merge'          = 'git push && gh pr merge 42 --merge'
        'selector-branch'                = 'gh pr merge feature/item-42 --merge'
        'selector-url'                   = 'gh pr merge https://github.com/o/r/pull/42 --merge'
        'prose-over-match'               = 'git commit -m "document the pr merge step"'
        'prose-in-merge-body'            = 'gh pr merge 42 --merge --body "follows the pr merge step"'
        'overmatch-trailing-line-feed'   = "gh pr merge 42 --merge`n"
        'overmatch-trailing-semicolon'   = 'gh pr merge 42 --merge;'
        'overmatch-prose-pr-paren'       = 'git commit -m "see pr (#12)"'
        'overmatch-prose-pr-variable'    = 'echo pr $HOME'
    }
    foreach ($name in $forms.Keys) { @{ Name = $name; Command = $forms[$name] } }
}

function Get-EpicMergeGateReviewShapeRow {
    <#
    .SYNOPSIS
        Return the rows of the shape rule: each form of the plan's decisions section.
    .DESCRIPTION
        A denied form expands to three rows: the key with a passing review, pending- with the key
        and no review, and nokey- without the key. The first two expect REVIEW_GATE_HEAD_UNRESOLVED
        and the third an allow, all before any process.
    .OUTPUTS
        System.Collections.Hashtable, one per row
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()

    $reviewed = Get-EpicMergeGateReviewHead -Kind Reviewed
    $backslash = [string][char]92
    $query = Get-EpicMergeGateReviewConfirmationQuery
    $unresolved = 'REVIEW_GATE_HEAD_UNRESOLVED'
    foreach ($form in @(Get-EpicMergeGateReviewDeniedForm)) {
        @{ Name = $form.Name; Command = $form.Command; Expected = $unresolved; NoProcess = $true }
        @{ Name = "pending-$($form.Name)"; Command = $form.Command; Remove = @('remediation_loop'); Expected = $unresolved; NoProcess = $true }
        @{ Name = "nokey-$($form.Name)"; Command = $form.Command; Remove = @('review_mode', 'remediation_loop'); Expected = 'allow'; NoProcess = $true }
    }

    $notPassed = @{
        'quoted-token-review-pending'      = '"gh" pr merge 42 --merge'
        'quoted-word-review-pending'       = 'gh "pr" merge 42 --merge'
        'line-continuation-review-pending' = ('gh pr merge 42 ' + $backslash + "`n" + '--merge')
    }
    foreach ($name in $notPassed.Keys) {
        @{ Name = $name; Command = $notPassed[$name]; Remove = @('remediation_loop'); Expected = 'REVIEW_GATE_NOT_PASSED'; NoProcess = $true }
    }

    $allowed = @{
        'allow-pr-view'                      = 'gh pr view 42 --json state'
        'allow-pr-view-merge-fields'         = 'gh pr view 42 --json mergeable,mergeStateStatus,mergedAt'
        'allow-pr-checks'                    = 'gh pr checks 42'
        'allow-pr-create'                    = 'gh pr create --title "Add gate" --body "Text"'
        'allow-pr-create-merge-title'        = 'gh pr create --title "Merge gate" --body "Text"'
        'allow-pr-edit'                      = 'gh pr edit 42 --title "Add gate"'
        'allow-confirmation-query'           = $query
        'allow-confirmation-query-poll-loop' = "for attempt in 1 2 3; do $query; sleep 30; done"
        'allow-disable-auto'                 = 'gh pr merge 42 --disable-auto'
        'disclosed-script-file'              = 'sh scripts/merge-item.sh 42'
        'disclosed-encoded-payload'          = 'echo Z2ggcHIgbWVyZ2U= | base64 -d | sh'
    }
    foreach ($name in $allowed.Keys) {
        @{ Name = $name; Command = $allowed[$name]; Remove = @('remediation_loop'); Expected = 'allow'; NoProcess = $true }
    }

    $passing = @{
        'allow-skill-merge'              = 'gh pr merge --merge 42'
        'allow-skill-merge-match-head'   = "gh pr merge --merge 42 --match-head-commit $reviewed"
        'allow-skill-merge-number-first' = 'gh pr merge 42 --merge'
        'quoted-token-review-passed'     = '"gh" pr merge 42 --merge'
    }
    foreach ($name in $passing.Keys) {
        @{ Name = $name; Command = $passing[$name]; LiveHead = $reviewed; Expected = 'allow' }
    }
}

function Get-EpicMergeGateReviewCaseRow {
    <#
    .SYNOPSIS
        Return the shared rows of the guard, in the order of the design table.
    .DESCRIPTION
        A row that sets GhResult drives Invoke-DocsOnlyGhExe; every other row sets LiveHead for the
        live-head seam. NoProcess states that the row must end before any process starts. The rows
        of Get-EpicMergeGateReviewShapeRow follow the rows of the guard itself.
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
        @{ Name = 'ci-cross-check-synthetic-after-pass'; Override = (Get-EpicMergeGateReviewOutcomeOverride -Outcome @($pass, [ordered]@{ verdict = 'REMEDIATION_REQUIRED'; head_sha = $reviewed; findings = @([ordered]@{ remediability = 'autonomous' }) })); Expected = 'REVIEW_GATE_NOT_PASSED'; NoProcess = $true }
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
    foreach ($row in @($rows) + @(Get-EpicMergeGateReviewShapeRow)) {
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

function Register-EpicMergeGateReviewChildCiSeam {
    <#
    .SYNOPSIS
        Mock both child-CI seams by name to a green CI run on the given head, for the current test.
    .DESCRIPTION
        An epic-child merge now needs a verified CI run on its live head (issue #1130). Mocking the seams
        by name keeps the Invoke-DocsOnlyGhExe call counts that the review rows assert unchanged.
    .PARAMETER HeadSha
        The live head the seams report, equal to the fixture checkpoint's ci_gate.head_sha.
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][string] $HeadSha)

    $head = $HeadSha
    $run = [pscustomobject]@{ databaseId = 1130; event = 'pull_request'; status = 'completed'; conclusion = 'success'; headSha = $head; workflowName = 'CI'; createdAt = '2026-11-08T10:00:00Z' }
    Mock Get-EpicMergeGateChildCiLiveHeadSha -MockWith ({ $head }.GetNewClosure())
    Mock Get-EpicMergeGateChildCiRunList -MockWith ({ , @($run) }.GetNewClosure())
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
