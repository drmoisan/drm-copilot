<#
.SYNOPSIS
    Mode Review rules of the review/verdict eligibility module (issue #1097, decision D16).

.DESCRIPTION
    Covers ConvertFrom-ReviewVerdictNulList, Test-ReviewVerdictFeatureFolder,
    Test-ReviewVerdictRecordsOnlyPath, Get-ReviewVerdictReviewDecision, and
    Get-ReviewVerdictStatusArgument of .claude/lib/review-verdict/ReviewVerdictEligibility.psm1.
    The module is pure, so every row passes an in-memory checkpoint and an in-memory fact table.
    No file is written, no process is started, and no status is posted.
#>

BeforeAll {
    # Resolve the repository root four levels up: review-verdict -> claude-lib -> scripts -> tests.
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    Import-Module (Join-Path -Path $script:RepoRoot -ChildPath '.claude/lib/review-verdict/ReviewVerdictEligibility.psm1') -Force -ErrorAction Stop

    $script:Reviewed = 'abcdef0123456789abcdef0123456789abcdef01'
    $script:Live = 'fedcba9876543210fedcba9876543210fedcba98'
    $script:Folder = 'docs/features/active/item-42'
    $script:Artifact = 'docs/features/active/item-42/policy-audit.2026-01-01T00-00.md'
    $script:Nul = [string][char]0

    # Return a ready checkpoint for pull request 42 whose last outcome is PASS at the reviewed head.
    function Get-ReviewCheckpoint {
        param([object[]] $Outcome = @(@{ verdict = 'PASS'; head_sha = $script:Reviewed }), [object] $Folder = $script:Folder, [object] $PrNumber = [long]42)
        return @{ pr_gate = @{ pr_number = $PrNumber }; 'feature-folder' = $Folder; remediation_loop = @{ review_outcomes = $Outcome } }
    }

    # Return the gh pr view fact for a head and a state.
    function Get-PullRequestFact {
        param([string] $Head, [string] $State = 'OPEN')
        return @{ ExitCode = 0; Output = (@{ headRefOid = $Head; state = $State; headRefName = 'feature/item-42'; baseRefName = 'main' } | ConvertTo-Json -Compress) }
    }

    # Return a gathered process fact.
    function Get-ProcessFact {
        param([int] $ExitCode = 0, [string] $Output = '')
        return @{ ExitCode = $ExitCode; Output = $Output }
    }

    # Return the full fact table of a live head that descends from the reviewed head.
    function Get-DescendantFact {
        param([string] $Listing = '', [int] $Ancestry = 0, [int] $DiffExit = 0)
        return @{ PullRequest = (Get-PullRequestFact -Head $script:Live); ArtifactCommitted = (Get-ProcessFact); Ancestry = (Get-ProcessFact -ExitCode $Ancestry); Listing = (Get-ProcessFact -ExitCode $DiffExit -Output $Listing) }
    }

    # Run the Review decision for pull request 42.
    function Invoke-ReviewDecision {
        param([object] $Checkpoint = (Get-ReviewCheckpoint), [hashtable] $Fact = @{}, [string] $Artifact = $script:Artifact)
        return Get-ReviewVerdictReviewDecision -Checkpoint $Checkpoint -PrNumber 42 -ReviewArtifact $Artifact -Fact $Fact
    }
}

AfterAll {
    Remove-Module -Name ReviewVerdictEligibility -Force -ErrorAction SilentlyContinue
}

Describe 'ConvertFrom-ReviewVerdictNulList' {
    It 'returns no entry for an empty listing' {
        (ConvertFrom-ReviewVerdictNulList -Text '').Count | Should -Be 0
    }

    It 'splits a NUL-terminated listing into its entries' {
        $entry = ConvertFrom-ReviewVerdictNulList -Text "a.md$($script:Nul)b c.md$($script:Nul)"
        $entry | Should -Be @('a.md', 'b c.md')
    }

    It 'throws on a listing that is not NUL-terminated' {
        { ConvertFrom-ReviewVerdictNulList -Text 'a.md' } | Should -Throw '*not NUL-terminated*'
    }
}

Describe 'Test-ReviewVerdictFeatureFolder and Test-ReviewVerdictRecordsOnlyPath' {
    It 'accepts a folder under docs/features/' {
        Test-ReviewVerdictFeatureFolder -FeatureFolder $script:Folder | Should -BeTrue
    }

    It 'refuses the invalid folder form <Name>' -TestCases @(
        @{ Name = 'non-string'; Value = 42 }
        @{ Name = 'null'; Value = $null }
        @{ Name = 'blank'; Value = ' ' }
        @{ Name = 'outside docs/features'; Value = 'src/item-42' }
        @{ Name = 'dot segment'; Value = 'docs/features/./item-42' }
        @{ Name = 'dot-dot segment'; Value = 'docs/features/active/../..' }
        @{ Name = 'blank segment'; Value = 'docs/features//item-42' }
        @{ Name = 'backslash'; Value = ('docs/features/active' + [char]92 + 'item-42') }
        @{ Name = 'trailing slash'; Value = 'docs/features/active/item-42/' }
    ) {
        param($Value)
        Test-ReviewVerdictFeatureFolder -FeatureFolder $Value | Should -BeFalse
    }

    It 'accepts a path under the folder and refuses a sibling-prefix path and the folder itself' {
        Test-ReviewVerdictRecordsOnlyPath -Path "$($script:Folder)/notes.md" -FeatureFolder $script:Folder | Should -BeTrue
        Test-ReviewVerdictRecordsOnlyPath -Path "$($script:Folder)-sibling/notes.md" -FeatureFolder $script:Folder | Should -BeFalse
        Test-ReviewVerdictRecordsOnlyPath -Path "$($script:Folder)/" -FeatureFolder $script:Folder | Should -BeFalse
    }
}

Describe 'Get-ReviewVerdictReviewDecision' {
    Context 'Posting cases' {
        It 'posts when the last outcome is PASS at the live head' {
            $decision = Invoke-ReviewDecision -Fact @{ PullRequest = (Get-PullRequestFact -Head $script:Reviewed); ArtifactCommitted = (Get-ProcessFact) }
            $decision.Eligible | Should -BeTrue
            $decision.Detail | Should -Be $script:Reviewed
            $decision.Description | Should -Be 'feature-review PASS: policy-audit.2026-01-01T00-00.md'
        }

        It 'posts on a descendant head whose listing holds only feature-folder paths' {
            $decision = Invoke-ReviewDecision -Fact (Get-DescendantFact -Listing "$($script:Folder)/evidence/qa.md$($script:Nul)$($script:Folder)/policy-audit.md$($script:Nul)")
            $decision.Eligible | Should -BeTrue
            $decision.Detail | Should -Be $script:Live
        }

        It 'posts on a descendant head with an empty listing' {
            (Invoke-ReviewDecision -Fact (Get-DescendantFact)).Eligible | Should -BeTrue
        }
    }

    Context 'Verdict rule' {
        It 'refuses the last verdict <Verdict>' -TestCases @(
            @{ Verdict = 'REMEDIATION_REQUIRED' }
            @{ Verdict = 'HALT_NON_REMEDIABLE' }
            @{ Verdict = 'AWAITING_CI' }
            @{ Verdict = 'pass' }
        ) {
            param($Verdict)
            $decision = Invoke-ReviewDecision -Checkpoint (Get-ReviewCheckpoint -Outcome @(@{ verdict = $Verdict; head_sha = $script:Reviewed }))
            $decision.Eligible | Should -BeFalse
            $decision.Code | Should -Be 'REVIEW_VERDICT_NOT_PASS'
            $decision.Request | Should -BeNullOrEmpty
        }

        It 'refuses an empty outcome list' {
            (Invoke-ReviewDecision -Checkpoint (Get-ReviewCheckpoint -Outcome @())).Code | Should -Be 'REVIEW_VERDICT_NOT_PASS'
        }

        It 'refuses an earlier PASS followed by a later non-PASS outcome' {
            $outcome = @(@{ verdict = 'PASS'; head_sha = $script:Reviewed }, @{ verdict = 'REMEDIATION_REQUIRED'; head_sha = $script:Reviewed })
            (Invoke-ReviewDecision -Checkpoint (Get-ReviewCheckpoint -Outcome $outcome)).Code | Should -Be 'REVIEW_VERDICT_NOT_PASS'
        }

        It 'refuses a checkpoint without remediation_loop' {
            (Invoke-ReviewDecision -Checkpoint @{ pr_gate = @{ pr_number = [long]42 } }).Code | Should -Be 'REVIEW_VERDICT_NOT_PASS'
        }
    }

    Context 'Head and pull-request rules' {
        It 'refuses the head_sha form <Name>' -TestCases @(
            @{ Name = 'absent'; Outcome = @{ verdict = 'PASS' } }
            @{ Name = 'uppercase'; Outcome = @{ verdict = 'PASS'; head_sha = 'ABCDEF0123456789ABCDEF0123456789ABCDEF01' } }
            @{ Name = 'short'; Outcome = @{ verdict = 'PASS'; head_sha = 'abcdef012345' } }
        ) {
            param($Outcome)
            (Invoke-ReviewDecision -Checkpoint (Get-ReviewCheckpoint -Outcome @($Outcome))).Code | Should -Be 'REVIEW_VERDICT_HEAD_ABSENT'
        }

        It 'refuses a pull-request number that differs from pr_gate before gh runs' {
            $decision = Invoke-ReviewDecision -Checkpoint (Get-ReviewCheckpoint -PrNumber ([long]41))
            $decision.Code | Should -Be 'REVIEW_VERDICT_PR_MISMATCH'
            $decision.Request | Should -BeNullOrEmpty
        }

        It 'requests gh pr view once the checkpoint rules pass' {
            $decision = Invoke-ReviewDecision
            $decision.Code | Should -Be 'REVIEW_VERDICT_FACT_REQUIRED'
            $decision.Request.Tool | Should -Be 'gh'
            $decision.Request.Arguments | Should -Be @('pr', 'view', '42', '--json', 'headRefOid,headRefName,baseRefName,state')
        }

        It 'refuses a closed pull request' {
            (Invoke-ReviewDecision -Fact @{ PullRequest = (Get-PullRequestFact -Head $script:Reviewed -State 'CLOSED') }).Code | Should -Be 'REVIEW_VERDICT_PR_MISMATCH'
        }

        It 'throws when gh pr view failed' {
            { Invoke-ReviewDecision -Fact @{ PullRequest = (Get-ProcessFact -ExitCode 1) } } | Should -Throw '*PullRequest exited 1*'
        }
    }

    Context 'Folder and artifact rules' {
        It 'refuses an invalid feature folder' {
            $decision = Invoke-ReviewDecision -Checkpoint (Get-ReviewCheckpoint -Folder 'docs/features/active/../x') -Fact @{ PullRequest = (Get-PullRequestFact -Head $script:Reviewed) }
            $decision.Code | Should -Be 'REVIEW_VERDICT_FEATURE_FOLDER_INVALID'
        }

        It 'refuses the artifact form <Name>' -TestCases @(
            @{ Name = 'other folder'; Artifact = 'docs/features/active/item-41/policy-audit.2026-01-01T00-00.md' }
            @{ Name = 'code review'; Artifact = 'docs/features/active/item-42/code-review.2026-01-01T00-00.md' }
            @{ Name = 'bad stamp'; Artifact = 'docs/features/active/item-42/policy-audit.2026-01-01.md' }
            @{ Name = 'nested'; Artifact = 'docs/features/active/item-42/evidence/policy-audit.2026-01-01T00-00.md' }
        ) {
            param($Artifact)
            $decision = Invoke-ReviewDecision -Artifact $Artifact -Fact @{ PullRequest = (Get-PullRequestFact -Head $script:Reviewed) }
            $decision.Code | Should -Be 'REVIEW_VERDICT_ARTIFACT_INVALID'
        }

        It 'requests the artifact check in the live head' {
            $decision = Invoke-ReviewDecision -Fact @{ PullRequest = (Get-PullRequestFact -Head $script:Live) }
            $decision.Request.Arguments | Should -Be @('cat-file', '-e', "$($script:Live):$($script:Artifact)")
        }

        It 'refuses an artifact that is not committed in the live head' {
            $decision = Invoke-ReviewDecision -Fact @{ PullRequest = (Get-PullRequestFact -Head $script:Reviewed); ArtifactCommitted = (Get-ProcessFact -ExitCode 128) }
            $decision.Code | Should -Be 'REVIEW_VERDICT_ARTIFACT_NOT_COMMITTED'
        }
    }

    Context 'Records-only rule' {
        It 'refuses a live head that does not descend from the reviewed head' {
            (Invoke-ReviewDecision -Fact (Get-DescendantFact -Ancestry 1)).Code | Should -Be 'REVIEW_VERDICT_HEAD_NOT_CURRENT'
        }

        It 'reports a git failure of the ancestry check' {
            (Invoke-ReviewDecision -Fact (Get-DescendantFact -Ancestry 128)).Code | Should -Be 'REVIEW_VERDICT_GIT_FAILED'
        }

        It 'refuses a code change after the review' {
            $decision = Invoke-ReviewDecision -Fact (Get-DescendantFact -Listing "src/app.ts$($script:Nul)")
            $decision.Code | Should -Be 'REVIEW_VERDICT_NOT_RECORDS_ONLY'
            $decision.Detail | Should -BeLike '*src/app.ts*'
        }

        It 'refuses a mixed listing of one folder path and one src path' {
            $decision = Invoke-ReviewDecision -Fact (Get-DescendantFact -Listing "$($script:Folder)/notes.md$($script:Nul)src/app.ts$($script:Nul)")
            $decision.Code | Should -Be 'REVIEW_VERDICT_NOT_RECORDS_ONLY'
            $decision.Detail | Should -BeLike '*src/app.ts*'
        }

        It 'refuses a sibling-prefix folder path' {
            (Invoke-ReviewDecision -Fact (Get-DescendantFact -Listing "$($script:Folder)-sibling/notes.md$($script:Nul)")).Code | Should -Be 'REVIEW_VERDICT_NOT_RECORDS_ONLY'
        }

        It 'reports a failed or truncated listing as a git failure' {
            (Invoke-ReviewDecision -Fact (Get-DescendantFact -DiffExit 128)).Code | Should -Be 'REVIEW_VERDICT_GIT_FAILED'
            (Invoke-ReviewDecision -Fact (Get-DescendantFact -Listing "$($script:Folder)/notes.md")).Code | Should -Be 'REVIEW_VERDICT_GIT_FAILED'
        }
    }
}

Describe 'Get-ReviewVerdictStatusArgument' {
    It 'builds the statuses POST for the head' {
        $argument = Get-ReviewVerdictStatusArgument -Head $script:Live -Description 'feature-review PASS: policy-audit.2026-01-01T00-00.md'
        $argument | Should -Be @('api', '--method', 'POST', "repos/{owner}/{repo}/statuses/$($script:Live)", '-f', 'state=success', '-f', 'context=review/verdict', '-f', 'description=feature-review PASS: policy-audit.2026-01-01T00-00.md')
    }

    It 'accepts a description of exactly 140 characters' {
        (Get-ReviewVerdictStatusArgument -Head $script:Live -Description ('x' * 140))[-1] | Should -Be ('description=' + ('x' * 140))
    }

    It 'throws on a description above 140 characters' {
        { Get-ReviewVerdictStatusArgument -Head $script:Live -Description ('x' * 141) } | Should -Throw '*141 characters*'
    }

    It 'throws on a blank description and on a head that is not an object id' {
        { Get-ReviewVerdictStatusArgument -Head $script:Live -Description ' ' } | Should -Throw '*blank*'
        { Get-ReviewVerdictStatusArgument -Head 'HEAD' -Description 'x' } | Should -Throw '*not an object id*'
    }
}
