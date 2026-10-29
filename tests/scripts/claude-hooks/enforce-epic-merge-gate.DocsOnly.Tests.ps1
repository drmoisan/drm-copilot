#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    End-to-end rows for the docs-only branch of .claude/hooks/enforce-epic-merge-gate.ps1 (issue #927).

.DESCRIPTION
    Drives Invoke-EpicMergeGateDecision with mocked target resolvers, checkpoint read seams,
    and docs-only process seams. No row starts a process, runs git or gh, or writes a file.
    The docs-only seam mocks in BeforeAll are registered only when the shared helper is
    loaded, so before the helper exists every docs-only row fails on its own Mock or
    Should -Invoke call rather than failing the container.
#>

Describe 'enforce-epic-merge-gate docs-only branch (issue #927)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-merge-gate.ps1").Path
        . $script:UnderTest
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
        Mock Get-ChildOrchestratorCheckpointContent { $null }
        Mock Get-EpicOrchestratorCheckpointContent { $null }
        Mock Get-ParallelOrchestratorCheckpointContent { $null }
        Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
        if (Get-Command Invoke-DocsOnlyGhExe -ErrorAction SilentlyContinue) { Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 1; Output = '' } } }
        if (Get-Command Invoke-DocsOnlyGitExe -ErrorAction SilentlyContinue) { Mock Invoke-DocsOnlyGitExe { [pscustomobject]@{ ExitCode = 1; Output = '' } } }
        $sessionRoot = $PSScriptRoot
        Mock Get-EpicMergeGateSessionWorktreeRoot -MockWith ({ $sessionRoot }.GetNewClosure())
        Mock Resolve-EpicMergeGateItemTarget { [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; Detail = 'item NoTarget (issue #927)' } }
        Mock Resolve-EpicMergeGateRunTarget { [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; Detail = 'run NoTarget (issue #927)' } }

        function ConvertTo-DocsOnlyMergeEnvelope {
            <#
            .SYNOPSIS
                Wrap a Bash command in the PreToolUse envelope the gate reads.
            #>
            [CmdletBinding()]
            [OutputType([string])]
            param([Parameter(Mandatory)][string] $Command)

            return (@{ session_id = 'session-927'; tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Depth 5 -Compress)
        }

        function Set-DocsOnlyMergeSeam {
            <#
            .SYNOPSIS
                Mock both docs-only seams for one pull request and one diff listing.
            #>
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
            param([Parameter(Mandatory)][string] $DiffOutput)

            $listing = $DiffOutput
            Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 0; Output = '{"baseRefName":"main","headRefOid":"0123456789abcdef0123456789abcdef01234567"}' } }
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' -and $GitArgs[-1] -ceq 'refs/remotes/origin/main^{commit}' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = 'fedcba9876543210fedcba9876543210fedcba98' } }
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' -and $GitArgs[-1] -ceq '0123456789abcdef0123456789abcdef01234567^{commit}' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = '0123456789abcdef0123456789abcdef01234567' } }
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'diff' } -MockWith ({ [pscustomobject]@{ ExitCode = 0; Output = $listing } }.GetNewClosure())
        }

        $script:BareDenyText = 'EPIC_MERGE_GATE_BLOCKED: a pull-request merge or merge-queue enqueue (gh pr merge with any method, --auto, or --admin, or a gh api merge or enqueue mutation) requires either a per-feature checkpoint with epic_mode == true and step9_status == "passed", an epic checkpoint with epic_merge_pr.ci_gate.conclusion == "success" and a matching pr_number, a parallel-orchestrator checkpoint with route_id == "parallel" whose target item (matched by pr_number) has merge_status == "ci_green", or a standalone per-feature checkpoint (epic_mode absent or false, no parallel marker) with step9_status == "passed", ci_gate.conclusion == "success", pr_gate.pr_number equal to the explicit PR number, and ci_gate.head_sha equal to the live pull-request head. No checkpoint satisfied this gate.'
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'no checkpoint records the pull request' {
        It 'allows a docs-only merge with no checkpoint record (issue #927)' {
            # Arrange
            Set-DocsOnlyMergeSeam -DiffOutput "docs/a.md`0docs/b.md`0"
            $envelope = ConvertTo-DocsOnlyMergeEnvelope -Command 'gh pr merge 5 --merge'

            # Act
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $envelope

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "reason: $($decision.hookSpecificOutput.permissionDecisionReason)"
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -ParameterFilter { ($GhArgs -join ' ') -ceq 'pr view 5 --json baseRefName,headRefOid' }
            Should -Invoke Invoke-DocsOnlyGitExe -Times 1 -Exactly -ParameterFilter { ($GitArgs -join ' ') -ceq 'diff --name-only -z --no-renames --no-color --no-ext-diff --no-relative fedcba9876543210fedcba9876543210fedcba98...0123456789abcdef0123456789abcdef01234567' }
        }

        It 'denies a non-docs diff with the docs-only reason after the standalone reasons (issue #927)' {
            # Arrange
            Set-DocsOnlyMergeSeam -DiffOutput "docs/a.md`0.claude/hooks/x.ps1`0"
            $envelope = ConvertTo-DocsOnlyMergeEnvelope -Command 'gh pr merge 5 --merge'

            # Act
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $envelope
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason | Should -BeLike 'EPIC_MERGE_GATE_BLOCKED:*'
            $reason | Should -Match 'TARGET_WORKTREE_NOT_DERIVABLE.*STANDALONE_MERGE_AUTHORIZATION_ABSENT.*docs-only exemption not applied: DOCS_ONLY_EXEMPTION_NON_DOCS_PATH'
        }

        It 'denies a failed gh lookup with the PR_UNRESOLVED docs-only reason (issue #927)' {
            # Arrange: the BeforeAll seam mocks report a failed lookup.
            $envelope = ConvertTo-DocsOnlyMergeEnvelope -Command 'gh pr merge 5 --merge'

            # Act
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $envelope
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason | Should -Match 'TARGET_WORKTREE_NOT_DERIVABLE.*STANDALONE_MERGE_AUTHORIZATION_ABSENT.*docs-only exemption not applied: DOCS_ONLY_EXEMPTION_PR_UNRESOLVED'
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
        }

        It 'denies a -R override with the PR_UNRESOLVED docs-only reason and no process call (issue #927)' {
            # Arrange
            $envelope = ConvertTo-DocsOnlyMergeEnvelope -Command 'gh pr merge 5 --merge -R o/r'

            # Act
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $envelope
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason | Should -Match 'TARGET_WORKTREE_NOT_DERIVABLE.*STANDALONE_MERGE_AUTHORIZATION_ABSENT.*docs-only exemption not applied: DOCS_ONLY_EXEMPTION_PR_UNRESOLVED'
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
        }

        It 'denies a pull-request URL selector with the PR_UNRESOLVED docs-only reason and no process call (issue #952)' {
            # Arrange: the URL resolves to 5 and the local pull request 5 is docs-only, so only
            # the M1 URL rule keeps the exemption from reading the session repository.
            Set-DocsOnlyMergeSeam -DiffOutput "docs/a.md`0"
            $envelope = ConvertTo-DocsOnlyMergeEnvelope -Command 'gh pr merge https://github.com/o/r/pull/5 --merge'

            # Act
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $envelope
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason.Contains(" (docs-only exemption not applied: DOCS_ONLY_EXEMPTION_PR_UNRESOLVED: the URL selector 'https://github.com/o/r/pull/5' is not accepted.)") | Should -BeTrue
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
        }
    }

    Context 'a checkpoint target resolves or the command is bare' {
        It 'makes no docs-only call when the <Name> target is <Status> (issue #927)' -ForEach @(
            @{ Name = 'item'; Status = 'SessionRoot' }
            @{ Name = 'item'; Status = 'OtherWorktree' }
            @{ Name = 'epic'; Status = 'Ambiguous' }
        ) {
            # Arrange
            $root = if ($Status -eq 'Ambiguous') { $null } else { '/synthetic-worktrees/item-927' }
            $code = if ($Status -eq 'Ambiguous') { 'TARGET_WORKTREE_AMBIGUOUS' } else { $null }
            $resolved = [pscustomobject]@{ Status = $Status; WorktreeRoot = $root; ReasonCode = $code; Detail = "$Name $Status (issue #927)" }
            if ($Name -eq 'item') {
                Mock Resolve-EpicMergeGateItemTarget -MockWith ({ $resolved }.GetNewClosure())
            }
            else {
                Mock Resolve-EpicMergeGateRunTarget -ParameterFilter { $Kind -eq 'epic' } -MockWith ({ $resolved }.GetNewClosure())
            }
            $envelope = ConvertTo-DocsOnlyMergeEnvelope -Command 'gh pr merge 5 --merge'

            # Act
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $envelope
            $reason = [string]$decision.hookSpecificOutput.permissionDecisionReason

            # Assert
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $reason.Contains('docs-only exemption not applied') | Should -BeFalse
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
        }

        It 'makes no docs-only call for a bare merge and keeps its exact deny text (issue #927)' {
            # Arrange
            $envelope = ConvertTo-DocsOnlyMergeEnvelope -Command 'gh pr merge --merge'

            # Act
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $envelope

            # Assert
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:BareDenyText
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly
        }
    }

    Context 'Test-EpicMergeGateNoRecordingTarget' {
        It 'reports <Result> for item <Item>, epic <Epic>, parallel <Parallel> (issue #927)' -ForEach @(
            @{ Item = 'NoTarget'; Epic = 'NoTarget'; Parallel = 'NoTarget'; Result = 'true' }
            @{ Item = 'Ambiguous'; Epic = 'NoTarget'; Parallel = 'NoTarget'; Result = 'false' }
            @{ Item = 'NoTarget'; Epic = 'SessionRoot'; Parallel = 'NoTarget'; Result = 'false' }
            @{ Item = 'NoTarget'; Epic = 'NoTarget'; Parallel = 'OtherWorktree'; Result = 'false' }
        ) {
            # Arrange
            $itemTarget = [pscustomobject]@{ Status = $Item }
            $epicTarget = [pscustomobject]@{ Status = $Epic }
            $parallelTarget = [pscustomobject]@{ Status = $Parallel }

            # Act
            $actual = Test-EpicMergeGateNoRecordingTarget -ItemTarget $itemTarget -EpicTarget $epicTarget -ParallelTarget $parallelTarget

            # Assert
            $actual | Should -Be ($Result -eq 'true')
        }

        It 'reports false for a bare command with no targets (issue #927)' {
            # Act
            $actual = Test-EpicMergeGateNoRecordingTarget -ItemTarget $null -EpicTarget $null -ParallelTarget $null

            # Assert
            $actual | Should -BeFalse
        }
    }
}
