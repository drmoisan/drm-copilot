#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Decision rows for the green-CI standalone merge branch of .claude/hooks/enforce-epic-merge-gate.ps1 (issue #997).

.DESCRIPTION
    Drives Invoke-EpicMergeGateDecision with mocked target resolvers, checkpoint read seams, the
    live-head seam Get-EpicMergeGateLivePrHeadSha, and the layer 1b worktree seam. The two
    green-CI seams are mocked only when they exist, so before the sibling file exists each row
    fails on its own assertion rather than failing the container. No row starts a process, runs
    git or gh, or writes a file.
#>

Describe 'enforce-epic-merge-gate green-CI decision (issue #997)' {
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
        Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }
        Mock Invoke-DocsOnlyGitExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }

        $script:FixtureHead = 'abcdef0123456789abcdef0123456789abcdef01'
        $script:OtherHead = 'fedcba9876543210fedcba9876543210fedcba98'
        $script:ItemRoot = Join-Path '/synthetic-worktrees' 'item-997'
        $script:SessionRoot = Join-Path '/synthetic-worktrees' 'session-997'
        $sessionRootValue = $script:SessionRoot
        $itemRootValue = $script:ItemRoot
        $headValue = $script:FixtureHead
        Mock Get-EpicMergeGateSessionWorktreeRoot -MockWith ({ $sessionRootValue }.GetNewClosure())
        Mock Resolve-EpicMergeGateItemTarget -MockWith ({ [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = $itemRootValue; ReasonCode = $null; Detail = 'item SessionRoot (issue #997)' } }.GetNewClosure())
        Mock Resolve-EpicMergeGateRunTarget { [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; Detail = 'run NoTarget (issue #997)' } }
        if (Get-Command Get-EpicMergeGateLivePrHeadSha -ErrorAction SilentlyContinue) { Mock Get-EpicMergeGateLivePrHeadSha -MockWith ({ $headValue }.GetNewClosure()) }
        if (Get-Command Resolve-EpicMergeGateParallelItemByWorktree -ErrorAction SilentlyContinue) { Mock Resolve-EpicMergeGateParallelItemByWorktree { [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; Detail = 'worktree NoTarget (issue #997)' } } }

        $script:FinalDenyText = 'EPIC_MERGE_GATE_BLOCKED: a pull-request merge or merge-queue enqueue (gh pr merge with any method, --auto, or --admin, or a gh api merge or enqueue mutation) requires either a per-feature checkpoint with epic_mode == true and step9_status == "passed", an epic checkpoint with epic_merge_pr.ci_gate.conclusion == "success" and a matching pr_number, a parallel-orchestrator checkpoint with route_id == "parallel" whose target item (matched by pr_number) has merge_status == "ci_green", or a standalone per-feature checkpoint (epic_mode absent or false, no parallel marker) with step9_status == "passed", ci_gate.conclusion == "success", pr_gate.pr_number equal to the explicit PR number, and ci_gate.head_sha equal to the live pull-request head. No checkpoint satisfied this gate.'

        function ConvertTo-GreenCiEnvelope {
            <#
            .SYNOPSIS
                Wrap a Bash command in the PreToolUse envelope the gate reads.
            #>
            [CmdletBinding()]
            [OutputType([string])]
            param([Parameter(Mandatory)][string] $Command)

            return (@{ session_id = 'session-997'; tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Depth 5 -Compress)
        }

        function New-GreenCiDecisionJson {
            <#
            .SYNOPSIS
                Return a green standalone checkpoint for PR 42 as JSON text, with top-level overrides.
            #>
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Builds an in-memory JSON string only; it changes no system state.')]
            [CmdletBinding()]
            [OutputType([string])]
            param([hashtable] $Override = @{}, [hashtable] $PrGate = @{})

            $prGateValue = [ordered]@{ pr_number = 42 }
            foreach ($key in $PrGate.Keys) { $prGateValue[$key] = $PrGate[$key] }
            $document = [ordered]@{
                step9_status = 'passed'
                ci_gate      = [ordered]@{ conclusion = 'success'; head_sha = $script:FixtureHead }
                pr_gate      = $prGateValue
            }
            foreach ($key in $Override.Keys) { $document[$key] = $Override[$key] }
            return ($document | ConvertTo-Json -Depth 6 -Compress)
        }

        function Set-GreenCiCheckpoint {
            <#
            .SYNOPSIS
                Mock the per-feature checkpoint read seam with one fixture text.
            #>
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
            param([AllowNull()][string] $Json)

            $text = $Json
            Mock Get-ChildOrchestratorCheckpointContent -MockWith ({ $text }.GetNewClosure())
        }

        function Invoke-GreenCiDecision {
            <#
            .SYNOPSIS
                Run the gate decision for one command and return the decision and its reason text.
            #>
            param([Parameter(Mandatory)][string] $Command)

            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw (ConvertTo-GreenCiEnvelope -Command $Command)
            return [pscustomobject]@{ Decision = [string]$decision.hookSpecificOutput.permissionDecision; Reason = [string]$decision.hookSpecificOutput.permissionDecisionReason }
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'allow rows' {
        It 'allows a standalone merge with a green S9 gate and a matching live head (issue #997)' {
            # Arrange
            Set-GreenCiCheckpoint -Json (New-GreenCiDecisionJson)

            # Act
            $result = Invoke-GreenCiDecision -Command 'gh pr merge 42 --merge'

            # Assert
            $result.Decision | Should -Be 'allow' -Because "reason: $($result.Reason)"
            Should -Invoke Get-EpicMergeGateLivePrHeadSha -Times 1 -Exactly
        }

        It 'allows when --match-head-commit equals the live head (issue #997)' {
            Set-GreenCiCheckpoint -Json (New-GreenCiDecisionJson)
            $result = Invoke-GreenCiDecision -Command "gh pr merge 42 --merge --match-head-commit $($script:FixtureHead)"
            $result.Decision | Should -Be 'allow' -Because "reason: $($result.Reason)"
        }

        It 'allows when pr_gate.head_sha equals ci_gate.head_sha (issue #997)' {
            Set-GreenCiCheckpoint -Json (New-GreenCiDecisionJson -PrGate @{ head_sha = $script:FixtureHead })
            $result = Invoke-GreenCiDecision -Command 'gh pr merge 42 --merge'
            $result.Decision | Should -Be 'allow' -Because "reason: $($result.Reason)"
        }
    }

    Context 'live-head stage declines' {
        It 'declines a live head that differs from ci_gate.head_sha with GREEN_CI_HEAD_STALE (issue #997)' {
            # Arrange
            Set-GreenCiCheckpoint -Json (New-GreenCiDecisionJson)
            $other = $script:OtherHead
            Mock Get-EpicMergeGateLivePrHeadSha -MockWith ({ $other }.GetNewClosure())

            # Act
            $result = Invoke-GreenCiDecision -Command 'gh pr merge 42 --merge'

            # Assert
            $result.Decision | Should -Be 'deny'
            $result.Reason.Contains('GREEN_CI_HEAD_STALE') | Should -BeTrue -Because $result.Reason
        }

        It 'declines with GREEN_CI_LIVE_HEAD_UNRESOLVED when the live head is unresolved' {
            Set-GreenCiCheckpoint -Json (New-GreenCiDecisionJson)
            Mock Get-EpicMergeGateLivePrHeadSha { $null }
            $result = Invoke-GreenCiDecision -Command 'gh pr merge 42 --merge'
            $result.Decision | Should -Be 'deny'
            $result.Reason.Contains('GREEN_CI_LIVE_HEAD_UNRESOLVED') | Should -BeTrue -Because $result.Reason
        }

        It 'declines a differing --match-head-commit with GREEN_CI_MATCH_HEAD_MISMATCH' {
            Set-GreenCiCheckpoint -Json (New-GreenCiDecisionJson)
            $result = Invoke-GreenCiDecision -Command "gh pr merge 42 --merge --match-head-commit $($script:OtherHead)"
            $result.Decision | Should -Be 'deny'
            $result.Reason.Contains('GREEN_CI_MATCH_HEAD_MISMATCH') | Should -BeTrue -Because $result.Reason
        }

        It 'declines a --match-head-commit with no value with GREEN_CI_MATCH_HEAD_MISMATCH (issue #997)' {
            # Arrange
            Set-GreenCiCheckpoint -Json (New-GreenCiDecisionJson)

            # Act
            $result = Invoke-GreenCiDecision -Command 'gh pr merge 42 --merge --match-head-commit'

            # Assert
            $result.Decision | Should -Be 'deny'
            $result.Reason.Contains('GREEN_CI_MATCH_HEAD_MISMATCH') | Should -BeTrue -Because $result.Reason
        }
    }

    Context 'checkpoint and item-target declines' {
        It 'declines when the item target is NoTarget' {
            Set-GreenCiCheckpoint -Json (New-GreenCiDecisionJson)
            Mock Resolve-EpicMergeGateItemTarget { [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; Detail = 'item NoTarget (issue #997)' } }
            (Invoke-GreenCiDecision -Command 'gh pr merge 42 --merge').Decision | Should -Be 'deny'
            Should -Invoke Get-EpicMergeGateLivePrHeadSha -Times 0 -Exactly
        }

        It 'declines when the item target is Ambiguous' {
            Set-GreenCiCheckpoint -Json (New-GreenCiDecisionJson)
            Mock Resolve-EpicMergeGateItemTarget { [pscustomobject]@{ Status = 'Ambiguous'; WorktreeRoot = $null; ReasonCode = 'TARGET_WORKTREE_AMBIGUOUS'; Detail = 'item Ambiguous (issue #997)' } }
            (Invoke-GreenCiDecision -Command 'gh pr merge 42 --merge').Decision | Should -Be 'deny'
            Should -Invoke Get-EpicMergeGateLivePrHeadSha -Times 0 -Exactly
        }

        It 'declines when the per-feature checkpoint is absent' {
            Set-GreenCiCheckpoint -Json $null
            (Invoke-GreenCiDecision -Command 'gh pr merge 42 --merge').Decision | Should -Be 'deny'
            Should -Invoke Get-EpicMergeGateLivePrHeadSha -Times 0 -Exactly
        }

        It 'declines when the per-feature checkpoint is unparseable' {
            Set-GreenCiCheckpoint -Json '{"step9_status":"passed",'
            (Invoke-GreenCiDecision -Command 'gh pr merge 42 --merge').Decision | Should -Be 'deny'
            Should -Invoke Get-EpicMergeGateLivePrHeadSha -Times 0 -Exactly
        }

        It 'denies a bare gh pr merge with the final deny text (issue #997)' {
            # Arrange: a green checkpoint sits at the session root, but a bare command names no PR.
            Mock Get-EpicMergeGateSessionWorktreeRoot { '/synthetic-worktrees/session-997' }
            Set-GreenCiCheckpoint -Json (New-GreenCiDecisionJson)

            # Act
            $result = Invoke-GreenCiDecision -Command 'gh pr merge --merge'

            # Assert
            $result.Reason | Should -BeExactly $script:FinalDenyText
        }
    }

    Context 'parallel-exclusion declines (paired with the NoTarget allow row)' {
        It 'declines when the parallel run target resolves for the PR (layer 1a)' {
            Set-GreenCiCheckpoint -Json (New-GreenCiDecisionJson)
            Mock Resolve-EpicMergeGateRunTarget -ParameterFilter { $Kind -eq 'parallel' } -MockWith { [pscustomobject]@{ Status = 'OtherWorktree'; WorktreeRoot = '/synthetic-worktrees/parallel-997'; ReasonCode = $null; Detail = 'parallel OtherWorktree (issue #997)' } }
            (Invoke-GreenCiDecision -Command 'gh pr merge 42 --merge').Decision | Should -Be 'deny'
            Should -Invoke Get-EpicMergeGateLivePrHeadSha -Times 0 -Exactly
        }

        It 'declines when the epic run target is Ambiguous (layer 1a)' {
            Set-GreenCiCheckpoint -Json (New-GreenCiDecisionJson)
            Mock Resolve-EpicMergeGateRunTarget -ParameterFilter { $Kind -eq 'epic' } -MockWith { [pscustomobject]@{ Status = 'Ambiguous'; WorktreeRoot = $null; ReasonCode = 'TARGET_WORKTREE_AMBIGUOUS'; Detail = 'epic Ambiguous (issue #997)' } }
            (Invoke-GreenCiDecision -Command 'gh pr merge 42 --merge').Decision | Should -Be 'deny'
            Should -Invoke Get-EpicMergeGateLivePrHeadSha -Times 0 -Exactly
        }

        It 'declines when the child worktree is recorded as a parallel item (layer 1b)' {
            Set-GreenCiCheckpoint -Json (New-GreenCiDecisionJson)
            Mock Resolve-EpicMergeGateParallelItemByWorktree { [pscustomobject]@{ Status = 'OtherWorktree'; WorktreeRoot = '/synthetic-worktrees/parallel-997'; ReasonCode = $null; Detail = 'worktree recorded (issue #997)' } }
            (Invoke-GreenCiDecision -Command 'gh pr merge 42 --merge').Decision | Should -Be 'deny'
            Should -Invoke Get-EpicMergeGateLivePrHeadSha -Times 0 -Exactly
        }

        It 'declines when the worktree seam throws (layer 1b)' {
            Set-GreenCiCheckpoint -Json (New-GreenCiDecisionJson)
            Mock Resolve-EpicMergeGateParallelItemByWorktree { throw 'simulated parallel record read failure' }
            (Invoke-GreenCiDecision -Command 'gh pr merge 42 --merge').Decision | Should -Be 'deny'
            Should -Invoke Get-EpicMergeGateLivePrHeadSha -Times 0 -Exactly
        }

        It 'declines a checkpoint carrying parallel_mode true (layer 2)' {
            Set-GreenCiCheckpoint -Json (New-GreenCiDecisionJson -Override @{ parallel_mode = $true })
            (Invoke-GreenCiDecision -Command 'gh pr merge 42 --merge').Decision | Should -Be 'deny'
            Should -Invoke Get-EpicMergeGateLivePrHeadSha -Times 0 -Exactly
        }

        It 'declines a checkpoint carrying a non-blank parallel_slug (layer 2)' {
            Set-GreenCiCheckpoint -Json (New-GreenCiDecisionJson -Override @{ parallel_slug = 'cohort-997' })
            (Invoke-GreenCiDecision -Command 'gh pr merge 42 --merge').Decision | Should -Be 'deny'
            Should -Invoke Get-EpicMergeGateLivePrHeadSha -Times 0 -Exactly
        }
    }

    Context 'command-shape declines' {
        It 'declines a non-structural merge command <Case>' -ForEach @(
            @{ Case = 'chain'; Command = 'gh pr merge 42 --merge && echo merged' }
            @{ Case = 'shell wrapper'; Command = "sh -c 'gh pr merge 42 --merge'" }
            @{ Case = '-R override'; Command = 'gh pr merge 42 --merge -R o/r' }
            @{ Case = '--repo override'; Command = 'gh pr merge 42 --merge --repo o/r' }
            @{ Case = 'pull URL selector'; Command = 'gh pr merge https://github.com/o/r/pull/42 --merge' }
            @{ Case = 'inline environment prefix'; Command = 'GH_REPO=o/r gh pr merge 42 --merge' }
            @{ Case = '--auto'; Command = 'gh pr merge 42 --auto --merge' }
            @{ Case = 'gh api merge mutation'; Command = 'gh api -X PUT repos/o/r/pulls/42/merge' }
            @{ Case = '--admin'; Command = 'gh pr merge 42 --merge --admin' }
        ) {
            # Arrange
            Set-GreenCiCheckpoint -Json (New-GreenCiDecisionJson)

            # Act
            $result = Invoke-GreenCiDecision -Command $Command

            # Assert
            $result.Decision | Should -Be 'deny' -Because "command: $Command"
            Should -Invoke Get-EpicMergeGateLivePrHeadSha -Times 0 -Exactly
        }

        It 'declines --admin combined with a valid green checkpoint and falls through to the existing standalone-authorization deny (issue #997)' {
            # Arrange
            Set-GreenCiCheckpoint -Json (New-GreenCiDecisionJson)

            # Act
            $result = Invoke-GreenCiDecision -Command 'gh pr merge 42 --merge --admin'

            # Assert
            $result.Decision | Should -Be 'deny'
            $result.Reason | Should -BeLike 'EPIC_MERGE_GATE_BLOCKED: STANDALONE_MERGE_AUTHORIZATION_ABSENT*'
            $result.Reason.Contains('GREEN_CI') | Should -BeFalse -Because $result.Reason
            Should -Invoke Get-EpicMergeGateLivePrHeadSha -Times 0 -Exactly
        }

        It 'still allows <Method> with a valid green checkpoint (issue #997)' -ForEach @(
            @{ Method = '--squash' }
            @{ Method = '--rebase' }
        ) {
            # Arrange
            Set-GreenCiCheckpoint -Json (New-GreenCiDecisionJson)

            # Act
            $result = Invoke-GreenCiDecision -Command "gh pr merge 42 $Method"

            # Assert
            $result.Decision | Should -Be 'allow' -Because "reason: $($result.Reason)"
        }
    }

    Context 'stage ordering' {
        It 'makes no live-head call when stage A declines' {
            Set-GreenCiCheckpoint -Json (New-GreenCiDecisionJson -Override @{ step9_status = 'pending' })
            (Invoke-GreenCiDecision -Command 'gh pr merge 42 --merge').Decision | Should -Be 'deny'
            Should -Invoke Get-EpicMergeGateLivePrHeadSha -Times 0 -Exactly
        }

        It 'makes no live-head call when stage B declines' {
            Set-GreenCiCheckpoint -Json (New-GreenCiDecisionJson)
            Mock Resolve-EpicMergeGateParallelItemByWorktree { [pscustomobject]@{ Status = 'Ambiguous'; WorktreeRoot = $null; ReasonCode = 'TARGET_WORKTREE_AMBIGUOUS'; Detail = 'worktree Ambiguous (issue #997)' } }
            (Invoke-GreenCiDecision -Command 'gh pr merge 42 --merge').Decision | Should -Be 'deny'
            Should -Invoke Get-EpicMergeGateLivePrHeadSha -Times 0 -Exactly
        }

        It 'makes no live-head call when stage C declines' {
            Set-GreenCiCheckpoint -Json (New-GreenCiDecisionJson)
            (Invoke-GreenCiDecision -Command 'gh pr merge 42 --merge --repo o/r').Decision | Should -Be 'deny'
            Should -Invoke Get-EpicMergeGateLivePrHeadSha -Times 0 -Exactly
        }
    }
}
