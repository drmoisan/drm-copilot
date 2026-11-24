#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Decision-level rows for the release merge leg of .claude/hooks/enforce-epic-merge-gate.ps1 (issue #1234).

.DESCRIPTION
    Drives Invoke-EpicMergeGateDecision with mocked target resolvers, checkpoint read seams, and the
    bounded gh and git seams. The unchanged-deny rows (AC-21) mock no allowance seam: the session
    root is this folder, which holds no allowance file, so the leg declines at its step 2. The rows
    under 'an allowance file is present' mock the two allowance seams. No row starts a process,
    runs git or gh, or writes a file.
#>

Describe 'enforce-epic-merge-gate release merge leg (#1234)' {
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
        $sessionRoot = $PSScriptRoot
        Mock Get-EpicMergeGateSessionWorktreeRoot -MockWith ({ $sessionRoot }.GetNewClosure())

        $script:ReleaseGateHead = '0123456789abcdef0123456789abcdef01234567'
        $script:ReleaseGateCommand = "gh pr merge 5 --merge --match-head-commit $($script:ReleaseGateHead)"
        $script:ReleaseGateUnchangedDeny = "EPIC_MERGE_GATE_BLOCKED: TARGET_WORKTREE_NOT_DERIVABLE: item NoTarget (#1234); run NoTarget (#1234); run NoTarget (#1234); STANDALONE_MERGE_AUTHORIZATION_ABSENT: no orchestrator checkpoint carries an authorization record, but an authorized standalone merge path exists. To authorize a standalone merge, write a standalone_merge_authorizations record naming this pull request and the current session_id into an orchestrator checkpoint, as described in the Standalone-Merge-Authorization section of .claude/rules/orchestrator-state.md. (docs-only exemption not applied: DOCS_ONLY_EXEMPTION_NON_DOCS_PATH: 'package.json' is outside docs/.)"

        function ConvertTo-ReleaseGateEnvelope {
            # Wrap a Bash command in the PreToolUse envelope the gate reads.
            param([Parameter(Mandatory)][string] $Command)
            return (@{ session_id = 'session-1234'; tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Depth 5 -Compress)
        }

        function Set-ReleaseGateTarget {
            # Mock the item and run target resolvers; the item status is NoTarget unless given.
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
            param([string] $ItemStatus = 'NoTarget')
            $itemValue = if ($ItemStatus -eq 'NoTarget') {
                [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; Detail = 'item NoTarget (#1234)' }
            } else {
                [pscustomobject]@{ Status = $ItemStatus; WorktreeRoot = '/synthetic-worktrees/item-1234'; ReasonCode = $null; Detail = "item $ItemStatus (#1234)" }
            }
            Mock Resolve-EpicMergeGateItemTarget -MockWith ({ $itemValue }.GetNewClosure())
            Mock Resolve-EpicMergeGateRunTarget { [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; Detail = 'run NoTarget (#1234)' } }
        }

        function Set-ReleaseGateDocsOnlySeam {
            # Mock the docs-only gh and git calls for one diff listing.
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
            param([Parameter(Mandatory)][string] $DiffOutput)
            $listing = $DiffOutput
            Mock Invoke-DocsOnlyGhExe -ParameterFilter { ($GhArgs -join ' ') -ceq 'pr view 5 --json baseRefName,headRefOid' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = '{"baseRefName":"main","headRefOid":"0123456789abcdef0123456789abcdef01234567"}' } }
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' -and $GitArgs[-1] -ceq 'refs/remotes/origin/main^{commit}' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = 'fedcba9876543210fedcba9876543210fedcba98' } }
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'rev-parse' -and $GitArgs[-1] -ceq '0123456789abcdef0123456789abcdef01234567^{commit}' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = '0123456789abcdef0123456789abcdef01234567' } }
            Mock Invoke-DocsOnlyGitExe -ParameterFilter { $GitArgs[0] -eq 'diff' } -MockWith ({ [pscustomobject]@{ ExitCode = 0; Output = $listing } }.GetNewClosure())
        }

        function Invoke-ReleaseGateDecision {
            # Run the gate decision for one command and return the decision and its reason text.
            param([string] $Command = $script:ReleaseGateCommand)
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw (ConvertTo-ReleaseGateEnvelope -Command $Command)
            return [pscustomobject]@{ Decision = [string]$decision.hookSpecificOutput.permissionDecision; Reason = [string]$decision.hookSpecificOutput.permissionDecisionReason }
        }
    }

    BeforeEach {
        Mock Invoke-DocsOnlyGhExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }
        Mock Invoke-DocsOnlyGitExe { [pscustomobject]@{ ExitCode = 1; Output = '' } }
        Set-ReleaseGateTarget
    }

    AfterAll {
        foreach ($name in 'ConvertTo-ReleaseGateEnvelope', 'Set-ReleaseGateTarget', 'Set-ReleaseGateDocsOnlySeam', 'Invoke-ReleaseGateDecision') {
            Remove-Item -LiteralPath "Function:\$name" -ErrorAction SilentlyContinue
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'no allowance file (AC-21)' {
        It 'keeps the checkpoint-free release-shaped deny text byte-identical (#1234)' {
            # Arrange
            Set-ReleaseGateDocsOnlySeam -DiffOutput "package.json`0"

            # Act
            $result = Invoke-ReleaseGateDecision

            # Assert
            $result.Decision | Should -Be 'deny'
            ($result.Reason -ceq $script:ReleaseGateUnchangedDeny) | Should -BeTrue -Because "reason: $($result.Reason)"
        }

        It 'starts only the docs-only gh and git calls (#1234)' {
            # Arrange
            Set-ReleaseGateDocsOnlySeam -DiffOutput "package.json`0"

            # Act
            $null = Invoke-ReleaseGateDecision

            # Assert
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -ParameterFilter { ($GhArgs -join ' ') -ceq 'pr view 5 --json baseRefName,headRefOid' }
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly -ParameterFilter { $GhArgs[0] -ceq 'run' -or ($GhArgs -join ' ').Contains('headRefName') }
            Should -Invoke Invoke-DocsOnlyGitExe -Times 3 -Exactly
        }
    }

    Context 'an allowance file is present' {
        BeforeAll {
            $script:ReleaseGateFields = 'headRefName,baseRefName,headRefOid,state,isCrossRepository,changedFiles,files'

            function Set-ReleaseGateLegSeam {
                # Mock the leg's pr view and run list calls; the run list is green on the head.
                [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
                param()
                Mock Invoke-DocsOnlyGhExe -ParameterFilter { $GhArgs[-1] -ceq $script:ReleaseGateFields } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = '{"headRefName":"release/v1.2.3","baseRefName":"main","headRefOid":"0123456789abcdef0123456789abcdef01234567","state":"OPEN","isCrossRepository":false,"changedFiles":1,"files":[{"path":"package.json","changeType":"MODIFIED"}]}' } }
                Mock Invoke-DocsOnlyGhExe -ParameterFilter { $GhArgs[0] -ceq 'run' } -MockWith { [pscustomobject]@{ ExitCode = 0; Output = '[{"databaseId":11,"event":"pull_request","status":"completed","conclusion":"success","headSha":"0123456789abcdef0123456789abcdef01234567","workflowName":"CI","createdAt":"2026-11-20T10:00:00Z"}]' } }
            }

            function Set-ReleaseGateChildCheckpoint {
                # Mock the per-feature checkpoint read with one JSON text.
                [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
                param([Parameter(Mandatory)][string] $Json)
                $text = $Json
                Mock Get-ChildOrchestratorCheckpointContent -MockWith ({ $text }.GetNewClosure())
            }
        }

        BeforeEach {
            Mock Get-OrchestrationGateReleaseAllowanceConfigText { '{"schema_version":1,"allowances":[{"id":"release","branch_patterns":["release/*"],"allowed_paths":["package.json"]}]}' }
            Mock Test-OrchestrationGateReleaseAllowancePathIsContainer { $false }
        }

        AfterAll {
            foreach ($name in 'Set-ReleaseGateLegSeam', 'Set-ReleaseGateChildCheckpoint') {
                Remove-Item -LiteralPath "Function:\$name" -ErrorAction SilentlyContinue
            }
        }

        It 'allows a checkpoint-free release merge without a review-guard process call (AC-01, AC-25) (#1234)' {
            # Arrange
            Set-ReleaseGateDocsOnlySeam -DiffOutput "package.json`0"
            Set-ReleaseGateLegSeam

            # Act
            $result = Invoke-ReleaseGateDecision

            # Assert
            $result.Decision | Should -Be 'allow' -Because "reason: $($result.Reason)"
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -ParameterFilter { $GhArgs[-1] -ceq $script:ReleaseGateFields }
            Should -Invoke Invoke-DocsOnlyGhExe -Times 1 -Exactly -ParameterFilter { $GhArgs[0] -ceq 'run' }
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly -ParameterFilter { ($GhArgs -join ' ') -ceq 'pr view 5 --json headRefOid' }
            Should -Invoke Invoke-DocsOnlyGitExe -Times 0 -Exactly -ParameterFilter { $GitArgs[0] -ceq 'merge-base' }
        }

        It 'reports RELEASE_MERGE_CHECKPOINT_PRESENT when the item target resolves and its checkpoint declines (AC-05) (#1234)' {
            # Arrange
            Set-ReleaseGateTarget -ItemStatus 'SessionRoot'
            Set-ReleaseGateLegSeam

            # Act
            $result = Invoke-ReleaseGateDecision

            # Assert
            $result.Decision | Should -Be 'deny'
            $result.Reason | Should -Match ' \(release merge not applied: RELEASE_MERGE_CHECKPOINT_PRESENT: [^)]*\)$'
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly -ParameterFilter { $GhArgs[-1] -ceq $script:ReleaseGateFields }
        }

        It 'places the release suffix after the docs-only suffix (AC-23) (#1234)' {
            # Arrange: the leg's pr view falls through to the failing default mock.
            Set-ReleaseGateDocsOnlySeam -DiffOutput "package.json`0"

            # Act
            $result = Invoke-ReleaseGateDecision

            # Assert
            $result.Decision | Should -Be 'deny'
            $result.Reason | Should -Match "\(docs-only exemption not applied: DOCS_ONLY_EXEMPTION_NON_DOCS_PATH: [^)]*\) \(release merge not applied: RELEASE_MERGE_PR_UNRESOLVED: [^)]*\)$"
        }

        It 'places the release suffix after the GREEN_CI_HEAD_STALE suffix (AC-23) (#1234)' {
            # Arrange
            Set-ReleaseGateTarget -ItemStatus 'SessionRoot'
            Set-ReleaseGateChildCheckpoint -Json '{"step9_status":"passed","ci_gate":{"conclusion":"success","head_sha":"abcdef0123456789abcdef0123456789abcdef01"},"pr_gate":{"pr_number":5}}'
            Mock Resolve-EpicMergeGateParallelItemByWorktree { [pscustomobject]@{ Status = 'NoTarget'; WorktreeRoot = $null; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; Detail = 'worktree NoTarget (#1234)' } }
            Mock Get-EpicMergeGateLivePrHeadSha { '0123456789abcdef0123456789abcdef01234567' }

            # Act
            $result = Invoke-ReleaseGateDecision

            # Assert
            $result.Decision | Should -Be 'deny'
            $result.Reason | Should -Match '\(green-CI merge not applied: GREEN_CI_HEAD_STALE\) \(release merge not applied: RELEASE_MERGE_CHECKPOINT_PRESENT: [^)]*\)$'
        }

        It 'lets the docs-only branch admit a docs-only diff before the leg runs (AC-24) (#1234)' {
            # Arrange
            Set-ReleaseGateDocsOnlySeam -DiffOutput "docs/a.md`0"
            Set-ReleaseGateLegSeam

            # Act
            $result = Invoke-ReleaseGateDecision

            # Assert
            $result.Decision | Should -Be 'allow' -Because "reason: $($result.Reason)"
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly -ParameterFilter { $GhArgs[-1] -ceq $script:ReleaseGateFields }
        }

        It 'keeps an epic-child allow away from the leg (AC-24) (#1234)' {
            # Arrange
            Set-ReleaseGateTarget -ItemStatus 'SessionRoot'
            Set-ReleaseGateChildCheckpoint -Json '{"epic_mode":true,"step9_status":"passed","pr_gate":{"pr_number":5}}'
            Mock Get-EpicMergeGateChildCiDecision { [ordered]@{ Verified = $true; Reason = '' } }

            # Act
            $result = Invoke-ReleaseGateDecision

            # Assert
            $result.Decision | Should -Be 'allow' -Because "reason: $($result.Reason)"
            Should -Invoke Get-OrchestrationGateReleaseAllowanceConfigText -Times 0 -Exactly
            Should -Invoke Invoke-DocsOnlyGhExe -Times 0 -Exactly -ParameterFilter { $GhArgs[-1] -ceq $script:ReleaseGateFields }
        }
    }
}
