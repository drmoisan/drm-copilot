#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Classification corpus runner for the Claude preimplementation gate (issue #1160).

.DESCRIPTION
    Runs every row of enforce-orchestration-preimplementation-gate.Classification.Cases.ps1
    against .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:

      - existing-denial rows (spec AC-2, AC-13) must stay classified and deny with the
        generic final deny text, byte-equal and with no suffix;
      - false-positive rows (spec AC-1) must be unclassified and allowed;
      - declared non-goal rows (spec AC-3) must stay unclassified.

    Every decision is driven through the pure seam
    Invoke-OrchestrationPreimplementationGateDecision with an injected NOT-ready
    checkpoint string, so an allow can only come from classification. The bookkeeping
    configuration seam and the staged-index seam are mocked when they exist, so no row
    reads a real configuration file or a real git index. No temporary file is created.
#>

BeforeDiscovery {
    . (Join-Path $PSScriptRoot 'enforce-orchestration-preimplementation-gate.Classification.Cases.ps1')
}

Describe 'enforce-orchestration-preimplementation-gate.ps1 classification corpus (issue #1160)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-orchestration-preimplementation-gate.ps1").Path
        . $script:UnderTest
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        if (Get-Command Get-WorktreeResolutionGitFileText -ErrorAction SilentlyContinue) { Mock Get-WorktreeResolutionGitFileText { $null } }
        Register-EpicStateBaselineMock -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-EpicScopeCheckpointText' -Surface 'Claude'
        Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-ParallelCheckpointContent' -Surface 'Codex'
        Import-Module (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution/EpicScopeResolution.psm1").Path
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
        Mock Resolve-OrchestrationGateTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/default-session'; ReasonCode = $null; Detail = 'default SessionRoot target (issue #690)' } }
        Import-Module (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1").Path
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
        Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution { , [string[]] @() }
        # Issue #1160 seams: bound only when they exist, so the run before the fix still loads.
        if (Get-Command Get-OrchestrationGateBookkeepingConfigText -ErrorAction SilentlyContinue) { Mock Get-OrchestrationGateBookkeepingConfigText { $null } }
        if (Get-Command Get-OrchestrationGateStagedIndex -ErrorAction SilentlyContinue) { Mock Get-OrchestrationGateStagedIndex { [pscustomobject]@{ ExitCode = 1; Output = '' } } }

        $script:GenericDenyText = 'PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.'

        function Get-ClassificationDecisionForCommand {
            <#
                Builds the Claude Bash envelope and runs the decision against a NOT-ready
                checkpoint (route id empty, lifecycle readiness false).
            #>
            param([Parameter(Mandatory)][string] $Command)

            $toolInputRaw = @{ tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Compress -Depth 5
            $checkpointRaw = @{ 'issue-num' = ''; 'feature-folder' = ''; route_id = ''; lifecycle_ready = $false } | ConvertTo-Json -Compress
            return Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $toolInputRaw -CheckpointRaw $checkpointRaw
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'existing denials stay classified with unchanged deny text' {
        It 'classifies existing-denial row <Id>' -ForEach $script:ClassificationExistingDenialCase {
            Test-ImplementationCommand -Command $Command | Should -Be $Expected -Because "row $Id is classified today and stage 2 only removes classifications"
        }

        It 'denies existing-denial row <Id> with the generic deny text' -ForEach $script:ClassificationExistingDenialCase {
            $decision = Get-ClassificationDecisionForCommand -Command $Command

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny' -Because "row $Id must still deny"
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:GenericDenyText -Because "row $Id keeps today's deny text with no suffix"
        }
    }

    Context 'false positives are unclassified' {
        It 'does not classify false-positive row <Id>' -ForEach $script:ClassificationFalsePositiveCase {
            Test-ImplementationCommand -Command $Command | Should -Be $Expected -Because "row $Id names a governed word only as an operand of a mention host"
        }

        It 'allows false-positive row <Id> with a not-ready checkpoint' -ForEach $script:ClassificationFalsePositiveCase {
            $decision = Get-ClassificationDecisionForCommand -Command $Command

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "row $Id does not begin implementation work"
        }
    }

    Context 'declared non-goals stay unclassified' {
        It 'does not classify non-goal row <Id>' -ForEach $script:ClassificationNonGoalCase {
            Test-ImplementationCommand -Command $Command | Should -Be $Expected -Because "row $Id is unclassified today and classification is never widened"
        }
    }
}
