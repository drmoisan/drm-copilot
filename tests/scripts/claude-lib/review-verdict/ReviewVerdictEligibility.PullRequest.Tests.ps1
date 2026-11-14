<#
.SYNOPSIS
    Non-feature pull-request rules of the review/verdict eligibility module (issue #1097, D16).

.DESCRIPTION
    Covers Get-ReviewVerdictMainSyncDecision, Get-ReviewVerdictRecordsPrDecision, and
    Get-ReviewVerdictPromotionPrDecision of .claude/lib/review-verdict/ReviewVerdictEligibility.psm1:
    one positive row per rule, branch-pattern negatives, and diff negatives. Every fact is an
    in-memory table. No file is written, no process is started, and no status is posted.
#>

BeforeAll {
    # Resolve the repository root four levels up: review-verdict -> claude-lib -> scripts -> tests.
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    Import-Module (Join-Path -Path $script:RepoRoot -ChildPath '.claude/lib/review-verdict/ReviewVerdictEligibility.psm1') -Force -ErrorAction Stop

    $script:Head = 'fedcba9876543210fedcba9876543210fedcba98'
    $script:Reviewed = 'abcdef0123456789abcdef0123456789abcdef01'
    $script:Main = '1111111111111111111111111111111111111111'
    $script:Base = '2222222222222222222222222222222222222222'
    $script:Nul = [string][char]0

    # Return a gathered process fact.
    function Get-ProcessFact {
        param([int] $ExitCode = 0, [string] $Output = '')
        return @{ ExitCode = $ExitCode; Output = $Output }
    }

    # Join paths into a NUL-terminated git -z listing fact.
    function Get-ListingFact {
        param([string[]] $Path = @())
        return Get-ProcessFact -Output (($Path | ForEach-Object { $_ + $script:Nul }) -join '')
    }

    # Return the gh pr view fact of an open pull request with a head ref and a base ref.
    function Get-PullRequestFact {
        param([string] $HeadRef, [string] $BaseRef = 'main')
        return Get-ProcessFact -Output (@{ headRefOid = $script:Head; state = 'OPEN'; headRefName = $HeadRef; baseRefName = $BaseRef } | ConvertTo-Json -Compress)
    }

    # Return the complete fact table of an eligible main sync, with changes.
    function Get-MainSyncFact {
        param([hashtable] $Change = @{})
        $fact = @{
            PullRequest    = (Get-PullRequestFact -HeadRef 'epic/cycle-time-integration')
            Parents        = (Get-ProcessFact -Output "$($script:Reviewed) $($script:Main)")
            ParentStatus   = (Get-ProcessFact -Output '[{"context":"ci/other","state":"failure"},{"context":"review/verdict","state":"success"},{"context":"review/verdict","state":"failure"}]')
            MainAncestry   = (Get-ProcessFact)
            MergeBase      = (Get-ProcessFact -Output $script:Base)
            BranchSet      = (Get-ListingFact -Path 'docs/features/active/x/plan.md', 'src/branch.ts')
            MainSet        = (Get-ListingFact -Path 'src/main.ts', 'README.md')
            ReviewedToHead = (Get-ListingFact -Path 'src/main.ts', 'README.md')
            MainToHead     = (Get-ListingFact -Path 'src/branch.ts')
        }
        foreach ($key in $Change.Keys) { $fact[$key] = $Change[$key] }
        return $fact
    }

    # Return the complete fact table of an eligible records pull request, with a listing.
    function Get-RecordsFact {
        param([string[]] $Path = @('docs/features/active/x/plan.md', '.claude/agent-memory/a/note.md'), [string] $HeadRef = 'documentationandmemories', [string] $BaseRef = 'main')
        return @{ PullRequest = (Get-PullRequestFact -HeadRef $HeadRef -BaseRef $BaseRef); MergeBase = (Get-ProcessFact -Output $script:Base); Listing = (Get-ListingFact -Path $Path) }
    }

    # Return the complete fact table of an eligible promotion pull request, with a listing.
    function Get-PromotionFact {
        param(
            [string[]] $Entry = @('D', 'docs/features/potential/thing.md', 'A', 'docs/features/active/thing-77/issue.md', 'A', 'docs/features/active/thing-77/spec.md'),
            [string] $HeadRef = 'feature/thing-77', [string] $BaseRef = 'main', [string] $Tree = ''
        )
        return @{ PullRequest = (Get-PullRequestFact -HeadRef $HeadRef -BaseRef $BaseRef); MergeBase = (Get-ProcessFact -Output $script:Base); NameStatus = (Get-ListingFact -Path $Entry); FolderTree = (Get-ProcessFact -Output $Tree) }
    }
}

AfterAll {
    Remove-Module -Name ReviewVerdictEligibility -Force -ErrorAction SilentlyContinue
}

Describe 'Get-ReviewVerdictMainSyncDecision' {
    It 'posts on a merge of main whose changes come only from main and the reviewed head' {
        $decision = Get-ReviewVerdictMainSyncDecision -PrNumber 7 -Fact (Get-MainSyncFact)
        $decision.Eligible | Should -BeTrue
        $decision.Detail | Should -Be $script:Head
        $decision.Description | Should -Be 'main sync: no change beyond main and the reviewed head'
    }

    It 'requests the pull request, then the parents, in order' {
        (Get-ReviewVerdictMainSyncDecision -PrNumber 7).Request.Name | Should -Be 'PullRequest'
        $decision = Get-ReviewVerdictMainSyncDecision -PrNumber 7 -Fact @{ PullRequest = (Get-PullRequestFact -HeadRef 'epic/cycle-time-integration') }
        $decision.Request.Arguments | Should -Be @('log', '-1', '--format=%P', $script:Head)
    }

    It 'refuses the branch pair <Name>' -TestCases @(
        @{ Name = 'feature head'; HeadRef = 'feature/thing-77'; BaseRef = 'main' }
        @{ Name = 'integration name without suffix'; HeadRef = 'epic/cycle-time'; BaseRef = 'main' }
        @{ Name = 'base other than main'; HeadRef = 'epic/cycle-time-integration'; BaseRef = 'development' }
    ) {
        param($HeadRef, $BaseRef)
        $decision = Get-ReviewVerdictMainSyncDecision -PrNumber 7 -Fact (Get-MainSyncFact -Change @{ PullRequest = (Get-PullRequestFact -HeadRef $HeadRef -BaseRef $BaseRef) })
        $decision.Code | Should -Be 'REVIEW_VERDICT_BRANCH_MISMATCH'
    }

    It 'refuses a head with one parent' {
        $decision = Get-ReviewVerdictMainSyncDecision -PrNumber 7 -Fact (Get-MainSyncFact -Change @{ Parents = (Get-ProcessFact -Output $script:Reviewed) })
        $decision.Code | Should -Be 'REVIEW_VERDICT_NOT_MAIN_SYNC'
    }

    It 'refuses an unverified first parent: <Name>' -TestCases @(
        @{ Name = 'newest review status failure'; Output = '[{"context":"review/verdict","state":"failure"},{"context":"review/verdict","state":"success"}]'; ExitCode = 0 }
        @{ Name = 'no review status'; Output = '[{"context":"ci/other","state":"success"}]'; ExitCode = 0 }
        @{ Name = 'gh failure'; Output = ''; ExitCode = 1 }
    ) {
        param($Output, $ExitCode)
        $decision = Get-ReviewVerdictMainSyncDecision -PrNumber 7 -Fact (Get-MainSyncFact -Change @{ ParentStatus = (Get-ProcessFact -ExitCode $ExitCode -Output $Output) })
        $decision.Code | Should -Be 'REVIEW_VERDICT_PARENT_UNVERIFIED'
    }

    It 'refuses a second parent that is not on origin/main' {
        $decision = Get-ReviewVerdictMainSyncDecision -PrNumber 7 -Fact (Get-MainSyncFact -Change @{ MainAncestry = (Get-ProcessFact -ExitCode 1) })
        $decision.Code | Should -Be 'REVIEW_VERDICT_NOT_MAIN_SYNC'
    }

    It 'refuses overlapping branch and main sets' {
        $decision = Get-ReviewVerdictMainSyncDecision -PrNumber 7 -Fact (Get-MainSyncFact -Change @{ MainSet = (Get-ListingFact -Path 'src/main.ts', 'src/branch.ts') })
        $decision.Code | Should -Be 'REVIEW_VERDICT_NOT_MAIN_SYNC'
        $decision.Detail | Should -BeLike '*src/branch.ts*'
    }

    It 'refuses an extra path in the diff from the reviewed head' {
        $decision = Get-ReviewVerdictMainSyncDecision -PrNumber 7 -Fact (Get-MainSyncFact -Change @{ ReviewedToHead = (Get-ListingFact -Path 'src/main.ts', 'src/extra.ts') })
        $decision.Code | Should -Be 'REVIEW_VERDICT_NOT_MAIN_SYNC'
        $decision.Detail | Should -BeLike '*src/extra.ts*'
    }

    It 'refuses a resolved conflict path in the diff from main' {
        $decision = Get-ReviewVerdictMainSyncDecision -PrNumber 7 -Fact (Get-MainSyncFact -Change @{ MainToHead = (Get-ListingFact -Path 'src/branch.ts', 'src/main.ts') })
        $decision.Code | Should -Be 'REVIEW_VERDICT_NOT_MAIN_SYNC'
        $decision.Detail | Should -BeLike '*src/main.ts*'
    }

    It 'reports git failures of the parents, ancestry, merge-base, and listing facts' {
        (Get-ReviewVerdictMainSyncDecision -PrNumber 7 -Fact (Get-MainSyncFact -Change @{ Parents = (Get-ProcessFact -ExitCode 128) })).Code | Should -Be 'REVIEW_VERDICT_GIT_FAILED'
        (Get-ReviewVerdictMainSyncDecision -PrNumber 7 -Fact (Get-MainSyncFact -Change @{ MainAncestry = (Get-ProcessFact -ExitCode 128) })).Code | Should -Be 'REVIEW_VERDICT_GIT_FAILED'
        (Get-ReviewVerdictMainSyncDecision -PrNumber 7 -Fact (Get-MainSyncFact -Change @{ MergeBase = (Get-ProcessFact -ExitCode 1) })).Code | Should -Be 'REVIEW_VERDICT_GIT_FAILED'
        (Get-ReviewVerdictMainSyncDecision -PrNumber 7 -Fact (Get-MainSyncFact -Change @{ BranchSet = (Get-ProcessFact -Output 'unterminated') })).Code | Should -Be 'REVIEW_VERDICT_GIT_FAILED'
    }
}

Describe 'Get-ReviewVerdictRecordsPrDecision' {
    It 'posts on a records-only pull request' {
        $decision = Get-ReviewVerdictRecordsPrDecision -PrNumber 8 -Fact (Get-RecordsFact)
        $decision.Eligible | Should -BeTrue
        $decision.Description | Should -Be 'records-only pull request'
    }

    It 'requests the merge base of origin/main and the head, then the listing' {
        $fact = @{ PullRequest = (Get-PullRequestFact -HeadRef 'documentationandmemories') }
        (Get-ReviewVerdictRecordsPrDecision -PrNumber 8 -Fact $fact).Request.Arguments | Should -Be @('merge-base', 'origin/main', $script:Head)
        $fact.MergeBase = Get-ProcessFact -Output $script:Base
        (Get-ReviewVerdictRecordsPrDecision -PrNumber 8 -Fact $fact).Request.Arguments | Should -Be @('diff', '--name-only', '-z', '--no-renames', $script:Base, $script:Head)
    }

    It 'refuses the branch pair <Name>' -TestCases @(
        @{ Name = 'other head'; HeadRef = 'documentation'; BaseRef = 'main' }
        @{ Name = 'base other than main'; HeadRef = 'documentationandmemories'; BaseRef = 'development' }
    ) {
        param($HeadRef, $BaseRef)
        (Get-ReviewVerdictRecordsPrDecision -PrNumber 8 -Fact (Get-RecordsFact -HeadRef $HeadRef -BaseRef $BaseRef)).Code | Should -Be 'REVIEW_VERDICT_BRANCH_MISMATCH'
    }

    It 'refuses the listing <Name>' -TestCases @(
        @{ Name = 'empty'; Path = @() }
        @{ Name = 'templates path'; Path = @('docs/features/templates/plan.md') }
        @{ Name = 'potential template'; Path = @('docs/features/potential/template.md') }
        @{ Name = 'engineering path'; Path = @('docs/engineering/process-reductions/README.md') }
        @{ Name = 'mixed'; Path = @('docs/features/active/x/plan.md', 'scripts/tool.ps1') }
    ) {
        param($Path)
        (Get-ReviewVerdictRecordsPrDecision -PrNumber 8 -Fact (Get-RecordsFact -Path $Path)).Code | Should -Be 'REVIEW_VERDICT_NOT_RECORDS_ONLY'
    }
}

Describe 'Get-ReviewVerdictPromotionPrDecision' {
    It 'posts on a promotion-record pull request' {
        $decision = Get-ReviewVerdictPromotionPrDecision -PrNumber 9 -Fact (Get-PromotionFact)
        $decision.Eligible | Should -BeTrue
        $decision.Description | Should -Be 'promotion-record pull request'
    }

    It 'requests the name-status listing and then the folder tree at the merge base' {
        $fact = Get-PromotionFact
        $fact.Remove('FolderTree')
        (Get-ReviewVerdictPromotionPrDecision -PrNumber 9 -Fact $fact).Request.Arguments | Should -Be @('ls-tree', '-d', '--name-only', $script:Base, '--', 'docs/features/active/thing-77')
        $fact.Remove('NameStatus')
        (Get-ReviewVerdictPromotionPrDecision -PrNumber 9 -Fact $fact).Request.Arguments | Should -Be @('diff', '--name-status', '-z', '--no-renames', $script:Base, $script:Head)
    }

    It 'refuses the branch pair <Name>' -TestCases @(
        @{ Name = 'no number'; HeadRef = 'feature/thing'; BaseRef = 'main' }
        @{ Name = 'uppercase name'; HeadRef = 'feature/Thing-77'; BaseRef = 'main' }
        @{ Name = 'other prefix'; HeadRef = 'chore/thing-77'; BaseRef = 'main' }
        @{ Name = 'base other than main'; HeadRef = 'bug/thing-77'; BaseRef = 'development' }
    ) {
        param($HeadRef, $BaseRef)
        (Get-ReviewVerdictPromotionPrDecision -PrNumber 9 -Fact (Get-PromotionFact -HeadRef $HeadRef -BaseRef $BaseRef)).Code | Should -Be 'REVIEW_VERDICT_BRANCH_MISMATCH'
    }

    It 'refuses the listing <Name>' -TestCases @(
        @{ Name = 'folder number differs from the branch'; Entry = @('A', 'docs/features/active/thing-78/issue.md') }
        @{ Name = 'two folders'; Entry = @('A', 'docs/features/active/thing-77/issue.md', 'A', 'docs/features/active/other-77/issue.md') }
        @{ Name = 'modified folder entry'; Entry = @('M', 'docs/features/active/thing-77/issue.md') }
        @{ Name = 'potential-only listing'; Entry = @('D', 'docs/features/potential/thing.md') }
        @{ Name = 'potential template'; Entry = @('M', 'docs/features/potential/template.md', 'A', 'docs/features/active/thing-77/issue.md') }
        @{ Name = 'mixed with a scripts path'; Entry = @('A', 'docs/features/active/thing-77/issue.md', 'M', 'scripts/tool.ps1') }
        @{ Name = 'unpaired entry'; Entry = @('A') }
    ) {
        param($Entry)
        (Get-ReviewVerdictPromotionPrDecision -PrNumber 9 -Fact (Get-PromotionFact -Entry $Entry)).Code | Should -Be 'REVIEW_VERDICT_NOT_PROMOTION_RECORD'
    }

    It 'refuses a folder that exists at the merge base' {
        $decision = Get-ReviewVerdictPromotionPrDecision -PrNumber 9 -Fact (Get-PromotionFact -Tree 'docs/features/active/thing-77')
        $decision.Code | Should -Be 'REVIEW_VERDICT_NOT_PROMOTION_RECORD'
        $decision.Detail | Should -BeLike '*already exists*'
    }

    It 'reports a git failure of the folder tree' {
        $fact = Get-PromotionFact
        $fact.FolderTree = Get-ProcessFact -ExitCode 128
        (Get-ReviewVerdictPromotionPrDecision -PrNumber 9 -Fact $fact).Code | Should -Be 'REVIEW_VERDICT_GIT_FAILED'
    }
}
