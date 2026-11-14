#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Decision-level bookkeeping-leg suite for the Codex preimplementation gate (issue #1160).

.DESCRIPTION
    Drives the bookkeeping-leg rows and the decision D5/D14 rows of
    tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Cases.ps1
    through Invoke-OrchestrationPreimplementationGateDecision of
    .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 with the MAPPED tool_input
    JSON the Codex decision consumes, plus named cases for the empty declared list (spec
    AC-11), the invalid-configuration suffix and its order after the cleanup suffix (spec
    AC-12), and the leg scope (no leg for a Write or an apply_patch call).

    Isolation: the issue #737 baseline isolation form; Get-OrchestrationGateBookkeepingConfigText
    and Get-OrchestrationGateStagedIndex are mocked in every case; a row that needs a worktree
    root mocks Read-OrchestrationGateCheckpoint to a synthetic worktree with empty checkpoint
    text, and every other row injects a NOT-ready checkpoint text. No case reads a real
    worktree listing, checkpoint, configuration file, or git index, and no temporary file is
    created.
#>

BeforeDiscovery {
    . (Join-Path $PSScriptRoot '../claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Cases.ps1')
}

Describe 'Codex enforce-orchestration-preimplementation-gate bookkeeping leg (issue #1160)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = Join-Path $script:RepoRoot '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1'
        . $script:UnderTest
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-ParallelCheckpointContent', 'Get-WorktreeResolutionGitFileText' -Surface 'Codex'
        Mock Get-EpicScopeCheckpointText { $null }
        Mock Read-OrchestrationGateCheckpoint { [pscustomobject]@{ Resolved = $true; Raw = ''; Path = '/synthetic-worktrees/item/artifacts/orchestration/orchestrator-state.json'; DenyReason = $null } }

        $script:GenericDenyText = 'PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.'
        $script:NotReadyCheckpointRaw = @{ 'issue-num' = ''; 'feature-folder' = ''; route_id = ''; lifecycle_ready = $false } | ConvertTo-Json -Compress

        function Get-CodexBookkeepingLegDecision {
            <#
                Runs the decision for one mapped command. With -Root the checkpoint read runs
                (mocked to a synthetic worktree); without it a NOT-ready checkpoint text is
                injected, so the leg has no worktree root.
            #>
            param([Parameter(Mandatory)][string] $Command, [switch] $Root)

            $toolInputRaw = @{ command = $Command } | ConvertTo-Json -Compress -Depth 5
            if ($Root) { return Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $toolInputRaw }
            return Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $toolInputRaw -CheckpointRaw $script:NotReadyCheckpointRaw
        }
    }

    BeforeEach {
        Mock Get-OrchestrationGateBookkeepingConfigText { $null }
        Mock Get-OrchestrationGateStagedIndex { [pscustomobject]@{ ExitCode = -1; Output = '' } }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Codex' -Seam 'Get-EpicScopeCheckpointText' }

    Context 'bookkeeping-leg rows under the default configuration (spec AC-6, AC-8, AC-13)' {
        It 'decides bookkeeping-leg row <Id>' -ForEach $script:ClassificationBookkeepingLegCase {
            $staged = [pscustomobject]@{ ExitCode = $IndexExitCode; Output = $IndexOutput }
            Mock Get-OrchestrationGateStagedIndex { $staged }.GetNewClosure()

            $decision = Get-CodexBookkeepingLegDecision -Command $Command -Root:$Root

            $decision.hookSpecificOutput.permissionDecision | Should -Be $Expected -Because "row $Id"
            if ($Expected -eq 'deny') {
                $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:GenericDenyText -Because "row $Id keeps today's deny text"
            }
        }
    }

    Context 'decision D5 rows as amended by D14 (spec AC-7)' {
        It 'decides D5/D14 row <Id>' -ForEach $script:ClassificationD5D14Case {
            $staged = [pscustomobject]@{ ExitCode = $IndexExitCode; Output = $IndexOutput }
            Mock Get-OrchestrationGateStagedIndex { $staged }.GetNewClosure()

            $decision = Get-CodexBookkeepingLegDecision -Command $Command -Root:$Root

            $decision.hookSpecificOutput.permissionDecision | Should -Be $Expected -Because "row $Id"
            if ($Expected -eq 'deny') {
                $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:GenericDenyText -Because "row $Id keeps today's deny text"
            }
        }
    }

    Context 'empty declared list (spec AC-11)' {
        It 'denies allow row <Id> with today''s text under an empty declared list' -ForEach @($script:ClassificationBookkeepingLegCase + $script:ClassificationD5D14Case | Where-Object { $_.Expected -eq 'allow' }) {
            Mock Get-OrchestrationGateBookkeepingConfigText { '{"schema_version": 1, "bookkeeping_roots": []}' }
            $staged = [pscustomobject]@{ ExitCode = $IndexExitCode; Output = $IndexOutput }
            Mock Get-OrchestrationGateStagedIndex { $staged }.GetNewClosure()

            $decision = Get-CodexBookkeepingLegDecision -Command $Command -Root:$Root

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny' -Because "row $Id"
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:GenericDenyText -Because "row $Id has no suffix"
        }
    }

    Context 'invalid configuration (spec AC-12)' {
        It 'appends the invalid-configuration suffix to the generic deny text' {
            Mock Get-OrchestrationGateBookkeepingConfigText { '{"schema_version": 1, "bookkeeping_roots": ["/abs/"]}' }

            $decision = Get-CodexBookkeepingLegDecision -Command 'git add .claude/agent-memory/r/notes.md'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly ($script:GenericDenyText + ' Bookkeeping leg not applied: BOOKKEEPING_CONFIG_INVALID: bookkeeping_roots entry 0 starts with /.')
        }

        It 'places the invalid-configuration suffix after the cleanup suffix' {
            Mock Get-OrchestrationGateBookkeepingConfigText { '{"schema_version": 1, "bookkeeping_roots": [], "extra": 1}' }
            Mock Get-OrchestrationCleanupContextResult { [pscustomobject]@{ Allowed = $false; DenySuffix = ' Cleanup leg not applied: CLEANUP_LEG_STAGED_INDEX_EMPTY: the staged index of the consolidation worktree lists no path.' } }

            $decision = Get-CodexBookkeepingLegDecision -Command 'git commit -m m'

            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly ($script:GenericDenyText +
                ' Cleanup leg not applied: CLEANUP_LEG_STAGED_INDEX_EMPTY: the staged index of the consolidation worktree lists no path.' +
                " Bookkeeping leg not applied: BOOKKEEPING_CONFIG_INVALID: unknown top-level key 'extra'.")
        }
    }

    Context 'leg scope' {
        It 'does not run the leg for a Write of an implementation path' {
            Mock Get-OrchestrationGateBookkeepingConfigText { '{"schema_version": 2}' }
            Mock Get-OrchestrationCleanupContextResult { [pscustomobject]@{ Allowed = $false; DenySuffix = '' } }
            $toolInputRaw = @{ file_path = 'src/app.ps1'; content = 'x' } | ConvertTo-Json -Compress -Depth 5

            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $toolInputRaw -CheckpointRaw $script:NotReadyCheckpointRaw

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Not -Match 'BOOKKEEPING_CONFIG_INVALID'
            Should -Invoke Get-OrchestrationGateBookkeepingConfigText -Times 0 -Exactly
        }

        It 'does not run the leg for an apply_patch of an implementation path' {
            Mock Get-OrchestrationGateBookkeepingConfigText { '{"schema_version": 2}' }
            Mock Get-OrchestrationCleanupContextResult { [pscustomobject]@{ Allowed = $false; DenySuffix = '' } }
            $toolInputRaw = @{ command = "*** Begin Patch`n*** Update File: src/app.ps1`n@@`n-a`n+b`n*** End Patch" } | ConvertTo-Json -Compress -Depth 5

            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $toolInputRaw -CheckpointRaw $script:NotReadyCheckpointRaw

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Not -Match 'BOOKKEEPING_CONFIG_INVALID'
            Should -Invoke Get-OrchestrationGateBookkeepingConfigText -Times 0 -Exactly
        }
    }
}
