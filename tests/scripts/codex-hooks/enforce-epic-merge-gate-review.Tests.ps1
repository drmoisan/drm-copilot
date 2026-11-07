#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Review guard rows through the Codex merge gate .codex/hooks/enforce-epic-merge-gate.ps1 (issue #1097).

.DESCRIPTION
    Runs every row of the shared table through Invoke-CodexEpicMergeDecision, so the two runtimes
    prove the same decisions, and adds the Codex path rows. An allow is asserted as $null, the Codex
    allow representation. No row starts a process, runs git or gh, or writes a file.
#>

BeforeDiscovery {
    . (Join-Path $PSScriptRoot '../claude-hooks/EpicMergeGateReview.Cases.Helpers.ps1')
    $script:ReviewCaseRow = @(Get-EpicMergeGateReviewCaseRow)
}

Describe 'Codex enforce-epic-merge-gate review guard (issue #1097)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        . (Join-Path $script:RepoRoot '.codex/hooks/enforce-epic-merge-gate.ps1')
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1')
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicMergeGateReview.Cases.Helpers.ps1')
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
        if (Get-Command Get-ChildOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-ChildOrchestratorCheckpointContent { $null } }
        if (Get-Command Get-EpicOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-EpicOrchestratorCheckpointContent { $null } }
        if (Get-Command Get-ParallelOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Mock Get-ParallelOrchestratorCheckpointContent { $null } }
        Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
        Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }
        Mock Invoke-DocsOnlyGitExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }
        $script:Reviewed = Get-EpicMergeGateReviewHead -Kind Reviewed

        $script:EpicGreen = '{"epic_merge_pr":{"pr_number":42,"ci_gate":{"conclusion":"success"}}}'
        $script:SyntheticRoot = Join-Path '/synthetic-worktrees' 'codex-1097'

        function Invoke-CodexReviewDecision {
            <#
            .SYNOPSIS
                Run the Codex gate for one command and return the decision and its reason.
            .PARAMETER Child
                The child checkpoint text.
            .PARAMETER Epic
                The epic checkpoint text.
            .PARAMETER Command
                The Bash command.
            .PARAMETER Root
                The repository root handed to the gate.
            #>
            [CmdletBinding()]
            param(
                [AllowEmptyString()][string] $Child = '',
                [AllowEmptyString()][string] $Epic = '',
                [string] $Command = 'gh pr merge 42 --merge',
                [string] $Root = $script:SyntheticRoot
            )

            $payload = @{ session_id = 'session-1097'; tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Depth 5 -Compress
            $decision = Invoke-CodexEpicMergeDecision -PayloadRaw $payload -ChildCheckpointRaw $Child -EpicCheckpointRaw $Epic -RepositoryRoot $Root
            if ($null -eq $decision) { return [pscustomobject]@{ Decision = 'allow'; Reason = '' } }
            return [pscustomobject]@{ Decision = [string]$decision.hookSpecificOutput.permissionDecision; Reason = [string]$decision.hookSpecificOutput.permissionDecisionReason }
        }

        function Get-CodexRecordOverride {
            <#
            .SYNOPSIS
                Return a checkpoint override that makes the child an authorization-path checkpoint.
            #>
            [CmdletBinding()]
            [OutputType([hashtable])]
            param()

            return @{
                step9_status                    = 'pending'
                standalone_merge_authorizations = @([ordered]@{
                        pr_number     = 42
                        pr_url        = 'https://github.com/drmoisan/drm-copilot/pull/42'
                        issue_num     = 1097
                        branch_name   = 'feature/item-42'
                        authorized_by = 'orchestrator'
                        authorized_at = '2026-11-06T21:04:00Z'
                        session_id    = 'session-1097'
                        basis         = 'Fixture record for the authorization path of the review guard.'
                    })
            }
        }

        function Assert-CodexNoGuardProcess {
            <#
            .SYNOPSIS
                Assert a no-key row: an allow, the branch's own gh count, and no guard git call.
            .PARAMETER Result
                The result of Invoke-CodexReviewDecision.
            .PARAMETER GhCount
                The number of gh calls the branch itself makes.
            #>
            [CmdletBinding()]
            param([Parameter(Mandatory)] $Result, [Parameter(Mandatory)][int] $GhCount)

            $Result.Decision | Should -Be 'allow' -Because "reason: $($Result.Reason)"
            Should -Invoke Invoke-DocsOnlyGhExe -Times $GhCount -Exactly
            Should -Invoke Get-EpicMergeGateReviewLiveHeadSha -Times 0 -Exactly
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly -ParameterFilter { $GitArgs -contains '--is-ancestor' }
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly -ParameterFilter { $GitArgs -contains '--name-only' -and $GitArgs -contains $script:Reviewed }
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'RGC-<Name>' -ForEach $script:ReviewCaseRow {
        # Arrange
        $checkpoint = ConvertTo-EpicMergeGateReviewCheckpointJson -Override $Override -Remove $Remove
        Register-EpicMergeGateReviewRowSeam -Row $_

        # Act
        $result = Invoke-CodexReviewDecision -Child $checkpoint -Command $Command

        # Assert
        if ($Expected -ceq 'allow') {
            $result.Decision | Should -Be 'allow' -Because "reason: $($result.Reason)"
        } else {
            $result.Decision | Should -Be 'deny'
            $result.Reason.StartsWith("EPIC_MERGE_GATE_BLOCKED: ${Expected}: ", [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Reason
        }
        if ($ReasonNames) { $result.Reason.Contains($ReasonNames) | Should -BeTrue -Because $result.Reason }
        Assert-EpicMergeGateReviewRowProcessCount -Row $_
    }

    Context 'path rows, with the live head at the reviewed head' {
        BeforeEach {
            $reviewedHead = $script:Reviewed
            Mock Get-EpicMergeGateReviewLiveHeadSha -MockWith ({ $reviewedHead }.GetNewClosure())
        }

        It 'RGC-CHILD-REVIEW-PASSED-CI-PENDING-DENIED' {
            # Act: the guard passes at the reviewed head, and step9_status keeps the child unready.
            $result = Invoke-CodexReviewDecision -Child (ConvertTo-EpicMergeGateReviewCheckpointJson -Override @{ step9_status = 'pending' })

            # Assert
            $result.Decision | Should -Be 'deny'
            $result.Reason.StartsWith('EPIC_MERGE_GATE_BLOCKED:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Reason
            $result.Reason.Contains('REVIEW_GATE_') | Should -BeFalse -Because $result.Reason
            Should -Invoke Get-EpicMergeGateReviewLiveHeadSha -Times 1 -Exactly
        }

        It 'RGC-CHILD-CI-GREEN-REVIEW-PENDING-DENIED for step9_status <Status>' -ForEach @(
            @{ Status = 'passed' }
            @{ Status = 'verified' }
        ) {
            # Act
            $result = Invoke-CodexReviewDecision -Child (ConvertTo-EpicMergeGateReviewCheckpointJson -Override @{ step9_status = $Status } -Remove 'remediation_loop')

            # Assert
            $result.Decision | Should -Be 'deny'
            $result.Reason.StartsWith('EPIC_MERGE_GATE_BLOCKED: REVIEW_GATE_NOT_PASSED: ', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Reason
        }

        It 'RGC-EPIC-CI-GREEN-NO-CHILD-KEY-ALLOWED' {
            # Act
            $result = Invoke-CodexReviewDecision -Epic $script:EpicGreen

            # Assert
            $result.Decision | Should -Be 'allow' -Because "reason: $($result.Reason)"
            Should -Invoke Get-EpicMergeGateReviewLiveHeadSha -Times 0 -Exactly
        }

        It 'RGC-AUTHORIZATION-CI-GREEN-REVIEW-PENDING-DENIED' {
            # Arrange
            $child = ConvertTo-EpicMergeGateReviewCheckpointJson -Override (Get-CodexRecordOverride) -Remove 'epic_mode', 'remediation_loop'

            # Act
            $result = Invoke-CodexReviewDecision -Child $child

            # Assert
            $result.Decision | Should -Be 'deny'
            $result.Reason.StartsWith('EPIC_MERGE_GATE_BLOCKED: REVIEW_GATE_NOT_PASSED: ', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Reason
        }

        It 'RGC-AUTHORIZATION-REVIEW-PASSED-CI-NOT-READ-ALLOWED-D10-LIMIT' {
            # Arrange: the record path reads no CI result; the required CI context is the control (D10).
            $child = ConvertTo-EpicMergeGateReviewCheckpointJson -Override (Get-CodexRecordOverride) -Remove 'epic_mode'

            # Act
            $result = Invoke-CodexReviewDecision -Child $child

            # Assert
            $result.Decision | Should -Be 'allow' -Because "reason: $($result.Reason)"
        }

        It 'RGC-NOKEY-CHILD-NO-GH-NO-DENIAL-UNCHANGED' {
            $child = ConvertTo-EpicMergeGateReviewCheckpointJson -Remove 'review_mode', 'remediation_loop'
            Assert-CodexNoGuardProcess -GhCount 0 -Result (Invoke-CodexReviewDecision -Child $child)
        }
        It 'RGC-NOKEY-EPIC-NO-GH-NO-DENIAL-UNCHANGED' {
            $child = ConvertTo-EpicMergeGateReviewCheckpointJson -Override @{ step9_status = 'pending' } -Remove 'review_mode', 'remediation_loop'
            Assert-CodexNoGuardProcess -GhCount 0 -Result (Invoke-CodexReviewDecision -Child $child -Epic $script:EpicGreen)
        }
        It 'RGC-NOKEY-AUTHORIZATION-NO-GH-NO-DENIAL-UNCHANGED' {
            $child = ConvertTo-EpicMergeGateReviewCheckpointJson -Override (Get-CodexRecordOverride) -Remove 'epic_mode', 'review_mode', 'remediation_loop'
            Assert-CodexNoGuardProcess -GhCount 0 -Result (Invoke-CodexReviewDecision -Child $child)
        }
        It 'RGC-NOKEY-DOCS-ONLY-NO-GH-NO-DENIAL-UNCHANGED' {
            # Arrange: no checkpoint is present, so the branch makes its own single lookup.
            $listing = Get-EpicMergeGateReviewListing -Path 'docs/guide.md'
            Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 0; Output = '{"baseRefName":"main","headRefOid":"0123456789abcdef0123456789abcdef01234567"}' } }
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' -and $GitArgs[-1] -ceq 'refs/remotes/origin/main^{commit}' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = 'fedcba9876543210fedcba9876543210fedcba98' } }
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' -and $GitArgs[-1] -ceq '0123456789abcdef0123456789abcdef01234567^{commit}' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = '0123456789abcdef0123456789abcdef01234567' } }
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'diff' } -MockWith ({ [pscustomobject]@{ ExitCode = 0; Output = $listing } }.GetNewClosure())

            # Act and assert
            Assert-CodexNoGuardProcess -GhCount 1 -Result (Invoke-CodexReviewDecision -Root $PSScriptRoot)
        }
    }

    Context 'shape rule without the key' {
        BeforeAll {
            $script:Wrapper = 'if gh pr checks 42; then gh pr merge 42 --merge; fi'
            $script:NoKeyJson = ConvertTo-EpicMergeGateReviewCheckpointJson -Remove 'review_mode', 'remediation_loop'
        }

        It 'RGC-SHAPE-NOKEY-READ-FAILURE-KEEPS-DECISION (<Case>)' -ForEach @(
            @{ Case = 'git failure'; Child = 'nokey'; Reader = { throw 'git worktree list failed' } }
            @{ Case = 'timeout'; Child = 'nokey'; Reader = { throw [System.TimeoutException]::new('git worktree list timed out') } }
            @{ Case = 'unresolved target'; Child = 'nokey'; Reader = { $null } }
            @{ Case = 'unreadable child checkpoint'; Child = '{broken'; Reader = { $null } }
        ) {
            # Arrange: the Codex gate passes no reader, so the shared decision proves a failed read.
            $childText = if ($Child -ceq 'nokey') { $script:NoKeyJson } else { $Child }
            $known = $script:NoKeyJson | ConvertFrom-Json

            # Act
            $shape = Get-EpicMergeGateReviewShapeDecision -CommandText $script:Wrapper -KnownCheckpoint $known -KnownPrNumber 41 -ReadCheckpoint $Reader
            $result = Invoke-CodexReviewDecision -Child $childText -Command $script:Wrapper

            # Assert: today's out-of-scope allow, and no process.
            $shape.Denied | Should -BeFalse
            $result.Decision | Should -Be 'allow' -Because "reason: $($result.Reason)"
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
        }

        It 'RGC-DIRECT-CALL-NO-NUMBER-DENIES' {
            # Arrange: the Codex shape step denies a number-less merge first, so only a direct call
            # reaches step 2 of the header.
            $checkpoint = ConvertTo-EpicMergeGateReviewCheckpointJson | ConvertFrom-Json

            # Act
            $decision = Get-EpicMergeGateReviewDecision -Checkpoint $checkpoint -CommandPrNumber $null -GhRoot $script:SyntheticRoot -GitRoot $script:SyntheticRoot

            # Assert
            $decision.Denied | Should -BeTrue
            $decision.Reason.StartsWith('EPIC_MERGE_GATE_BLOCKED: REVIEW_GATE_HEAD_UNRESOLVED: ', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $decision.Reason
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
        }

        It 'RGC-SHAPE-CANDIDATE-CAP-BOUNDS-READS' {
            # Arrange: an in-memory reader that records each number over a text with six numbers.
            $reads = [System.Collections.Generic.List[object]]::new()
            $noKey = $script:NoKeyJson | ConvertFrom-Json
            $reader = { param($Target) $reads.Add($Target); $noKey }.GetNewClosure()

            # Act
            $shape = Get-EpicMergeGateReviewShapeDecision -CommandText 'echo pr merge 11 12 13 14 15 16' -KnownCheckpoint $noKey -KnownPrNumber $null -ReadCheckpoint $reader

            # Assert: the shared guard reads exactly the first 4 numbers, in text order.
            ($reads -join ',') | Should -BeExactly '11,12,13,14'
            $shape.Denied | Should -BeFalse
        }
    }
}
