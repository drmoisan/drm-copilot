<#
.SYNOPSIS
    Behavioral tests for the review/verdict entry point (issue #1097, decision D16).

.DESCRIPTION
    Covers .claude/lib/review-verdict/Invoke-ReviewVerdictStatus.ps1. The script is dot-sourced, so
    its guarded entry-point body does not run and Invoke-ReviewVerdictCli is called in-process. The
    seams Invoke-ReviewVerdictGhExe, Invoke-ReviewVerdictGitExe, and Read-ReviewVerdictCheckpointText
    are mocked in every test, so no gh or git process starts, no file is read or written, and no
    status is posted.
#>

BeforeAll {
    # Resolve the repository root four levels up: review-verdict -> claude-lib -> scripts -> tests.
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $script:EntryScriptPath = (Resolve-Path (Join-Path -Path $script:RepoRoot -ChildPath '.claude/lib/review-verdict/Invoke-ReviewVerdictStatus.ps1')).Path

    # The guarded entry-point body does not run under dot-sourcing.
    . $script:EntryScriptPath

    $script:Reviewed = 'abcdef0123456789abcdef0123456789abcdef01'
    $script:Live = 'fedcba9876543210fedcba9876543210fedcba98'
    $script:MainParent = '1111111111111111111111111111111111111111'
    $script:Base = '2222222222222222222222222222222222222222'
    $script:Folder = 'docs/features/active/item-42'
    $script:Artifact = 'docs/features/active/item-42/policy-audit.2026-01-01T00-00.md'
    $script:Nul = [string][char]0

    # Return checkpoint text for pull request 42 whose last outcome has the given verdict.
    function Get-CheckpointText {
        param([string] $Verdict = 'PASS')
        return (@{ pr_gate = @{ pr_number = 42 }; 'feature-folder' = $script:Folder; remediation_loop = @{ review_outcomes = @(@{ verdict = $Verdict; head_sha = $script:Reviewed }) } } | ConvertTo-Json -Depth 6 -Compress)
    }

    # Return gh pr view text for a head, a head ref, and a base ref.
    function Get-PullRequestText {
        param([string] $Head, [string] $HeadRef = 'feature/item-42', [string] $BaseRef = 'main')
        return (@{ headRefOid = $Head; headRefName = $HeadRef; baseRefName = $BaseRef; state = 'OPEN' } | ConvertTo-Json -Compress)
    }

    # Join paths into a NUL-terminated git -z listing.
    function Get-ListingText {
        param([string[]] $Path)
        return (($Path | ForEach-Object { $_ + $script:Nul }) -join '')
    }

    # Run the command with the given parameters.
    function Invoke-Cli {
        param([string] $Mode = 'Review', [string] $PrNumber = '42', [string] $ReviewArtifact = $script:Artifact)
        return Invoke-ReviewVerdictCli -Mode $Mode -PrNumber $PrNumber -CheckpointPath 'state.json' -ReviewArtifact $ReviewArtifact
    }
}

AfterAll {
    Remove-Module -Name ReviewVerdictEligibility -Force -ErrorAction SilentlyContinue
}

Describe 'Invoke-ReviewVerdictCli' {
    BeforeEach {
        # Each test sets the gh and git answers it needs; an unlisted git call exits 0 with no output.
        $script:CheckpointText = Get-CheckpointText
        $script:PullRequestText = Get-PullRequestText -Head $script:Reviewed
        $script:PullRequestExit = 0
        $script:PostExit = 0
        $script:StatusText = '[{"context":"review/verdict","state":"success"}]'
        $script:Git = @{}

        Mock Read-ReviewVerdictCheckpointText { param([string] $Path) $null = $Path; return $script:CheckpointText }
        Mock Invoke-ReviewVerdictGhExe {
            param([string[]] $GhArgs)
            if ($GhArgs[0] -ceq 'pr') { return [pscustomobject]@{ ExitCode = $script:PullRequestExit; Output = $script:PullRequestText } }
            if ($GhArgs -contains '--method') { return [pscustomobject]@{ ExitCode = $script:PostExit; Output = '{}' } }
            return [pscustomobject]@{ ExitCode = 0; Output = $script:StatusText }
        }
        Mock Invoke-ReviewVerdictGitExe {
            param([string[]] $GitArgs)
            $key = $GitArgs -join ' '
            if ($script:Git.ContainsKey($key)) { return $script:Git[$key] }
            return [pscustomobject]@{ ExitCode = 0; Output = '' }
        }
    }

    Context 'Usage' {
        It 'exits 2 without any read or process for <Name>' -TestCases @(
            @{ Name = 'an unknown mode'; Mode = 'Merge'; PrNumber = '42'; Artifact = 'x' }
            @{ Name = 'a lowercase mode'; Mode = 'review'; PrNumber = '42'; Artifact = 'x' }
            @{ Name = 'a zero PR number'; Mode = 'Review'; PrNumber = '0'; Artifact = 'x' }
            @{ Name = 'a non-numeric PR number'; Mode = 'RecordsPr'; PrNumber = '4a'; Artifact = '' }
            @{ Name = 'Review without an artifact'; Mode = 'Review'; PrNumber = '42'; Artifact = '' }
        ) {
            param($Mode, $PrNumber, $Artifact)
            $outcome = Invoke-Cli -Mode $Mode -PrNumber $PrNumber -ReviewArtifact $Artifact
            $outcome.ExitCode | Should -Be 2
            $outcome.Stderr | Should -BeLike 'REVIEW_VERDICT_USAGE:*'
            Should -Invoke Read-ReviewVerdictCheckpointText -Times 0 -Exactly
            Should -Invoke Invoke-ReviewVerdictGhExe -Times 0 -Exactly
            Should -Invoke Invoke-ReviewVerdictGitExe -Times 0 -Exactly
        }
    }

    Context 'Mode Review' {
        It 'posts once on the live head when the review passed at that head' {
            $outcome = Invoke-Cli
            $outcome.ExitCode | Should -Be 0
            $outcome.Stdout | Should -BeLike "REVIEW_VERDICT_POSTED:*$($script:Reviewed)*"
            Should -Invoke Invoke-ReviewVerdictGhExe -Times 1 -Exactly -ParameterFilter {
                ($GhArgs -join '|') -ceq "api|--method|POST|repos/{owner}/{repo}/statuses/$($script:Reviewed)|-f|state=success|-f|context=review/verdict|-f|description=feature-review PASS: policy-audit.2026-01-01T00-00.md"
            }
        }

        It 'exits 3 with no gh call for the verdict <Verdict>' -TestCases @(
            @{ Verdict = 'REMEDIATION_REQUIRED' }
            @{ Verdict = 'HALT_NON_REMEDIABLE' }
            @{ Verdict = 'AWAITING_CI' }
        ) {
            param($Verdict)
            $script:CheckpointText = Get-CheckpointText -Verdict $Verdict
            $outcome = Invoke-Cli
            $outcome.ExitCode | Should -Be 3
            $outcome.Stderr | Should -BeLike 'REVIEW_VERDICT_NOT_ELIGIBLE: REVIEW_VERDICT_NOT_PASS:*'
            Should -Invoke Invoke-ReviewVerdictGhExe -Times 0 -Exactly
            Should -Invoke Invoke-ReviewVerdictGitExe -Times 0 -Exactly
        }

        It 'exits 3 without a POST for <Name>' -TestCases @(
            @{ Name = 'a head that is not current'; Ancestor = 1; Listing = ''; Committed = 0; Code = 'REVIEW_VERDICT_HEAD_NOT_CURRENT' }
            @{ Name = 'a code change after the review'; Ancestor = 0; Listing = 'src/app.ts'; Committed = 0; Code = 'REVIEW_VERDICT_NOT_RECORDS_ONLY' }
            @{ Name = 'an uncommitted artifact'; Ancestor = 0; Listing = ''; Committed = 128; Code = 'REVIEW_VERDICT_ARTIFACT_NOT_COMMITTED' }
        ) {
            param($Ancestor, $Listing, $Committed, $Code)
            $script:PullRequestText = Get-PullRequestText -Head $script:Live
            $script:Git["cat-file -e $($script:Live):$($script:Artifact)"] = [pscustomobject]@{ ExitCode = $Committed; Output = '' }
            $script:Git["merge-base --is-ancestor $($script:Reviewed) $($script:Live)"] = [pscustomobject]@{ ExitCode = $Ancestor; Output = '' }
            $script:Git["diff --name-only -z --no-renames $($script:Reviewed) $($script:Live)"] = [pscustomobject]@{ ExitCode = 0; Output = (Get-ListingText -Path $Listing) }
            $outcome = Invoke-Cli
            $outcome.ExitCode | Should -Be 3
            $outcome.Stderr | Should -BeLike "REVIEW_VERDICT_NOT_ELIGIBLE: $($Code):*"
            Should -Invoke Invoke-ReviewVerdictGhExe -Times 0 -Exactly -ParameterFilter { $GhArgs -contains '--method' }
        }

        It 'posts on a records-only descendant of the reviewed head' {
            $script:PullRequestText = Get-PullRequestText -Head $script:Live
            $script:Git["diff --name-only -z --no-renames $($script:Reviewed) $($script:Live)"] = [pscustomobject]@{ ExitCode = 0; Output = (Get-ListingText -Path "$($script:Folder)/policy-audit.2026-01-01T00-00.md") }
            $outcome = Invoke-Cli
            $outcome.ExitCode | Should -Be 0
            Should -Invoke Invoke-ReviewVerdictGhExe -Times 1 -Exactly -ParameterFilter { $GhArgs -contains "repos/{owner}/{repo}/statuses/$($script:Live)" }
        }

        It 'exits 1 when the POST fails' {
            $script:PostExit = 1
            $outcome = Invoke-Cli
            $outcome.ExitCode | Should -Be 1
            $outcome.Stderr | Should -BeLike 'REVIEW_VERDICT_FAILED:*POST*'
        }

        It 'exits 1 when <Name>' -TestCases @(
            @{ Name = 'gh pr view fails'; Case = 'gh' }
            @{ Name = 'the checkpoint is not JSON'; Case = 'checkpoint' }
            @{ Name = 'the ancestry check fails'; Case = 'git' }
        ) {
            param($Case)
            if ($Case -ceq 'gh') { $script:PullRequestExit = 1 }
            if ($Case -ceq 'checkpoint') { $script:CheckpointText = '{broken' }
            if ($Case -ceq 'git') {
                $script:PullRequestText = Get-PullRequestText -Head $script:Live
                $script:Git["merge-base --is-ancestor $($script:Reviewed) $($script:Live)"] = [pscustomobject]@{ ExitCode = 128; Output = '' }
            }
            $outcome = Invoke-Cli
            $outcome.ExitCode | Should -Be 1
            $outcome.Stderr | Should -BeLike 'REVIEW_VERDICT_FAILED:*'
            Should -Invoke Invoke-ReviewVerdictGhExe -Times 0 -Exactly -ParameterFilter { $GhArgs -contains '--method' }
        }
    }

    Context 'Non-feature modes' {
        BeforeEach {
            # A main sync of main 1111 into the reviewed head abcd; B is the merge base of the two.
            $script:Git["log -1 --format=%P $($script:Live)"] = [pscustomobject]@{ ExitCode = 0; Output = "$($script:Reviewed) $($script:MainParent)" }
            $script:Git["merge-base $($script:Reviewed) $($script:MainParent)"] = [pscustomobject]@{ ExitCode = 0; Output = $script:Base }
            $script:Git["diff --name-only -z --no-renames $($script:Base) $($script:Reviewed)"] = [pscustomobject]@{ ExitCode = 0; Output = (Get-ListingText -Path 'src/branch.ts') }
            $script:Git["diff --name-only -z --no-renames $($script:Base) $($script:MainParent)"] = [pscustomobject]@{ ExitCode = 0; Output = (Get-ListingText -Path 'src/main.ts') }
            $script:Git["diff --name-only -z --no-renames $($script:Reviewed) $($script:Live)"] = [pscustomobject]@{ ExitCode = 0; Output = (Get-ListingText -Path 'src/main.ts') }
            $script:Git["diff --name-only -z --no-renames $($script:MainParent) $($script:Live)"] = [pscustomobject]@{ ExitCode = 0; Output = (Get-ListingText -Path 'src/branch.ts') }
            $script:Git["merge-base origin/main $($script:Live)"] = [pscustomobject]@{ ExitCode = 0; Output = $script:Base }
            $script:Git["diff --name-only -z --no-renames $($script:Base) $($script:Live)"] = [pscustomobject]@{ ExitCode = 0; Output = (Get-ListingText -Path 'docs/features/active/x/plan.md') }
            $script:Git["diff --name-status -z --no-renames $($script:Base) $($script:Live)"] = [pscustomobject]@{ ExitCode = 0; Output = (Get-ListingText -Path 'A', 'docs/features/active/thing-77/issue.md') }
        }

        It 'posts once for the eligible mode <Mode>' -TestCases @(
            @{ Mode = 'MainSync'; HeadRef = 'epic/cycle-time-integration'; Description = 'main sync: no change beyond main and the reviewed head' }
            @{ Mode = 'RecordsPr'; HeadRef = 'documentationandmemories'; Description = 'records-only pull request' }
            @{ Mode = 'PromotionPr'; HeadRef = 'feature/thing-77'; Description = 'promotion-record pull request' }
        ) {
            param($Mode, $HeadRef, $Description)
            $script:PullRequestText = Get-PullRequestText -Head $script:Live -HeadRef $HeadRef
            $expected = "description=$Description"
            $outcome = Invoke-Cli -Mode $Mode -ReviewArtifact ''
            $outcome.ExitCode | Should -Be 0
            Should -Invoke Read-ReviewVerdictCheckpointText -Times 0 -Exactly
            Should -Invoke Invoke-ReviewVerdictGhExe -Times 1 -Exactly -ParameterFilter { ($GhArgs -contains '--method') -and ($GhArgs -contains $expected) }
        }

        It 'exits 3 without a POST on the mixed diff of <Mode>' -TestCases @(
            @{ Mode = 'MainSync'; HeadRef = 'epic/cycle-time-integration'; Key = 'diff --name-only -z --no-renames REVIEWED LIVE'; Paths = @('src/main.ts', 'src/extra.ts'); Code = 'REVIEW_VERDICT_NOT_MAIN_SYNC' }
            @{ Mode = 'RecordsPr'; HeadRef = 'documentationandmemories'; Key = 'diff --name-only -z --no-renames BASE LIVE'; Paths = @('docs/features/active/x/plan.md', 'scripts/tool.ps1'); Code = 'REVIEW_VERDICT_NOT_RECORDS_ONLY' }
            @{ Mode = 'PromotionPr'; HeadRef = 'feature/thing-77'; Key = 'diff --name-status -z --no-renames BASE LIVE'; Paths = @('A', 'docs/features/active/thing-77/issue.md', 'M', 'scripts/tool.ps1'); Code = 'REVIEW_VERDICT_NOT_PROMOTION_RECORD' }
        ) {
            param($Mode, $HeadRef, $Key, $Paths, $Code)
            $script:PullRequestText = Get-PullRequestText -Head $script:Live -HeadRef $HeadRef
            $resolved = $Key.Replace('REVIEWED', $script:Reviewed).Replace('BASE', $script:Base).Replace('LIVE', $script:Live)
            $script:Git[$resolved] = [pscustomobject]@{ ExitCode = 0; Output = (Get-ListingText -Path $Paths) }
            $outcome = Invoke-Cli -Mode $Mode -ReviewArtifact ''
            $outcome.ExitCode | Should -Be 3
            $outcome.Stderr | Should -BeLike "REVIEW_VERDICT_NOT_ELIGIBLE: $($Code):*"
            Should -Invoke Invoke-ReviewVerdictGhExe -Times 0 -Exactly -ParameterFilter { $GhArgs -contains '--method' }
        }
    }
}

Describe 'Invoke-ReviewVerdictCli defaults and limits' {
    BeforeEach {
        Mock Read-ReviewVerdictCheckpointText { param([string] $Path) $null = $Path; return (Get-CheckpointText -Verdict 'AWAITING_CI') }
        Mock Invoke-ReviewVerdictGhExe { param([string[]] $GhArgs) $null = $GhArgs; return [pscustomobject]@{ ExitCode = 0; Output = '' } }
        Mock Invoke-ReviewVerdictGitExe { param([string[]] $GitArgs) $null = $GitArgs; return [pscustomobject]@{ ExitCode = 0; Output = '' } }
    }

    It 'reads the default checkpoint path when -CheckpointPath is empty' {
        $outcome = Invoke-ReviewVerdictCli -Mode 'Review' -PrNumber '42' -CheckpointPath '' -ReviewArtifact $script:Artifact
        $outcome.ExitCode | Should -Be 3
        Should -Invoke Read-ReviewVerdictCheckpointText -Times 1 -Exactly -ParameterFilter { $Path -ceq 'artifacts/orchestration/orchestrator-state.json' }
    }

    It 'exits 1 without a POST when a decision keeps requesting facts' {
        Mock Get-ReviewVerdictModeDecision {
            return [pscustomobject]@{ Eligible = $false; Code = 'REVIEW_VERDICT_FACT_REQUIRED'; Detail = 'Loop'; Description = ''; Request = [pscustomobject]@{ Name = 'Loop'; Tool = 'git'; Arguments = @('status') } }
        }
        $outcome = Invoke-ReviewVerdictCli -Mode 'RecordsPr' -PrNumber '8' -CheckpointPath 'state.json' -ReviewArtifact ''
        $outcome.ExitCode | Should -Be 1
        $outcome.Stderr | Should -BeLike 'REVIEW_VERDICT_FAILED:*more than 16 facts*'
        Should -Invoke Invoke-ReviewVerdictGitExe -Times 16 -Exactly
        Should -Invoke Invoke-ReviewVerdictGhExe -Times 0 -Exactly
    }
}

Describe 'Entry-point seams and output' {
    It 'routes the gh and git seams through the native command wrapper' {
        Mock Invoke-ReviewVerdictNativeCommand { param([scriptblock] $Invocation, [string[]] $Arguments) return [pscustomobject]@{ ExitCode = 0; Output = "$($Invocation.ToString().Trim())|$($Arguments -join ' ')" } }
        (Invoke-ReviewVerdictGhExe -GhArgs @('pr', 'view', '42')).Output | Should -Be 'param([string[]] $ToolArgs) & gh @ToolArgs|pr view 42'
        (Invoke-ReviewVerdictGitExe -GitArgs @('cat-file', '-e', 'x')).Output | Should -Be 'param([string[]] $ToolArgs) & git @ToolArgs|cat-file -e x'
    }

    It 'returns stdout lines and drops error records in the native command wrapper' {
        # An in-memory block stands in for the executable, so no process starts.
        $fakeTool = {
            param([string[]] $ToolArgs)
            "args: $($ToolArgs -join ',')"
            'second'
            [System.Management.Automation.ErrorRecord]::new([System.Exception]::new('noise'), 'FakeTool', [System.Management.Automation.ErrorCategory]::NotSpecified, $null)
        }
        $result = Invoke-ReviewVerdictNativeCommand -Invocation $fakeTool -Arguments @('a', 'b')
        $result.Output | Should -Be "args: a,b`nsecond"
        $result.PSObject.Properties.Name | Should -Contain 'ExitCode'
    }

    It 'reads a committed file as UTF-8 text through the checkpoint seam' {
        $path = Join-Path -Path $script:RepoRoot -ChildPath 'config/poshqc-scan.json'
        Read-ReviewVerdictCheckpointText -Path $path | Should -Be (Get-Content -LiteralPath $path -Raw)
    }

    It 'writes stdout and stderr to the given writers and returns the exit code' {
        $out = [System.IO.StringWriter]::new()
        $err = [System.IO.StringWriter]::new()
        $code = Write-ReviewVerdictOutcome -Outcome ([pscustomobject]@{ ExitCode = 3; Stdout = 'posted'; Stderr = 'refused' }) -Out $out -ErrorWriter $err
        $code | Should -Be 3
        $out.ToString().TrimEnd() | Should -Be 'posted'
        $err.ToString().TrimEnd() | Should -Be 'refused'
    }

    It 'writes nothing for empty stdout and stderr' {
        $out = [System.IO.StringWriter]::new()
        $err = [System.IO.StringWriter]::new()
        Write-ReviewVerdictOutcome -Outcome ([pscustomobject]@{ ExitCode = 0; Stdout = ''; Stderr = '' }) -Out $out -ErrorWriter $err | Should -Be 0
        $out.ToString() | Should -BeNullOrEmpty
        $err.ToString() | Should -BeNullOrEmpty
    }
}
