#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Classification corpus runner for the Codex preimplementation gate (issue #1160).

.DESCRIPTION
    Runs every row of
    tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Cases.ps1
    against .codex/hooks/enforce-orchestration-preimplementation-gate.ps1, with the same
    expectations as the Claude runner, so both surfaces produce the same decision for every
    corpus row (spec AC-14):

      - existing-denial rows (spec AC-2, AC-13) stay classified and deny with the generic
        final deny text, byte-equal and with no suffix;
      - false-positive rows (spec AC-1) are unclassified and allowed;
      - declared non-goal rows (spec AC-3) stay unclassified.

    Every decision is driven through the pure seam with the MAPPED tool_input JSON the
    Codex decision function consumes and an injected NOT-ready checkpoint string. The
    bookkeeping configuration seam and the staged-index seam are mocked when they exist.
    No disk I/O beyond dot-sourcing, no child process, and no temporary file.
#>

BeforeDiscovery {
    . (Join-Path $PSScriptRoot '../claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Cases.ps1')
}

Describe 'Codex enforce-orchestration-preimplementation-gate classification corpus (issue #1160)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = Join-Path $script:RepoRoot '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1'
        . $script:UnderTest
        . (Join-Path $PSScriptRoot '../claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1')
        Register-EpicStateBaselineMock -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
        Register-EpicStateBaselineMock -Seam 'Get-CheckpointContent', 'Get-EpicCheckpointContent', 'Get-ParallelCheckpointContent', 'Get-WorktreeResolutionGitFileText' -Surface 'Codex'
        Mock Get-EpicScopeCheckpointText { $null }
        # Issue #1160 seams: bound only when they exist, so the run before the fix still loads.
        if (Get-Command Get-OrchestrationGateBookkeepingConfigText -ErrorAction SilentlyContinue) { Mock Get-OrchestrationGateBookkeepingConfigText { $null } }
        if (Get-Command Get-OrchestrationGateStagedIndex -ErrorAction SilentlyContinue) { Mock Get-OrchestrationGateStagedIndex { [pscustomobject]@{ ExitCode = 1; Output = '' } } }

        $script:GenericDenyText = 'PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.'

        function Get-CodexClassificationDecisionForCommand {
            <#
                Builds the mapped Codex tool_input and runs the decision against a NOT-ready
                checkpoint (route id empty, lifecycle readiness false).
            #>
            param([Parameter(Mandatory)][string] $Command)

            $toolInputRaw = @{ command = $Command } | ConvertTo-Json -Compress -Depth 5
            $checkpointRaw = @{ 'issue-num' = ''; 'feature-folder' = ''; route_id = ''; lifecycle_ready = $false } | ConvertTo-Json -Compress
            return Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $toolInputRaw -CheckpointRaw $checkpointRaw
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Codex' -Seam 'Get-EpicScopeCheckpointText' }

    Context 'existing denials stay classified with unchanged deny text' {
        It 'classifies existing-denial row <Id>' -ForEach $script:ClassificationExistingDenialCase {
            Test-ImplementationCommand -Command $Command | Should -Be $Expected -Because "row $Id is classified today and stage 2 only removes classifications"
        }

        It 'denies existing-denial row <Id> with the generic deny text' -ForEach $script:ClassificationExistingDenialCase {
            $decision = Get-CodexClassificationDecisionForCommand -Command $Command

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny' -Because "row $Id must still deny"
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeExactly $script:GenericDenyText -Because "row $Id keeps today's deny text with no suffix"
        }
    }

    Context 'false positives are unclassified' {
        It 'does not classify false-positive row <Id>' -ForEach $script:ClassificationFalsePositiveCase {
            Test-ImplementationCommand -Command $Command | Should -Be $Expected -Because "row $Id names a governed word only as an operand of a mention host"
        }

        It 'allows false-positive row <Id> with a not-ready checkpoint' -ForEach $script:ClassificationFalsePositiveCase {
            $decision = Get-CodexClassificationDecisionForCommand -Command $Command

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow' -Because "row $Id does not begin implementation work"
        }
    }

    Context 'declared non-goals stay unclassified' {
        It 'does not classify non-goal row <Id>' -ForEach $script:ClassificationNonGoalCase {
            Test-ImplementationCommand -Command $Command | Should -Be $Expected -Because "row $Id is unclassified today and classification is never widened"
        }
    }
}
