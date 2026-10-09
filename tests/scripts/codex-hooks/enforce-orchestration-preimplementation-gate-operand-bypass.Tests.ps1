#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

# Issue #732 - gate-level exempt-operand bypass for the Codex preimplementation gate.
# The Codex decision seam Invoke-OrchestrationPreimplementationGateDecision consumes the mapped
# tool_input JSON; every decision uses an explicitly not-ready checkpoint and a mocked epic-scope
# read. The file creates no file and starts no child process.

Describe 'Codex preimplementation gate exempt-operand bypass (issue #732)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = Join-Path $script:RepoRoot '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1'
        . $script:UnderTest
        Mock Get-EpicScopeCheckpointText { $null }

        function ConvertTo-CodexBypassNotReadyCheckpointRaw {
            <#
                An explicitly NOT-ready checkpoint, so any allow decision could come only from
                the command-branch exemption.
            #>
            param()

            return @{
                'issue-num'      = ''
                'feature-folder' = ''
                route_id         = ''
                lifecycle_ready  = $false
            } | ConvertTo-Json -Compress
        }
    }

    It 'denies <Label> without an authorizing checkpoint' -ForEach @(
        @{ Label = 'the issue 732 brace-expansion shape'; Command = 'git add docs/features/active/{..,..}/{..,..}/{..,..}/src/prod.ts' }
        @{ Label = 'the issue 732 escaped dot-segment shape'; Command = 'git add docs/features/active/.\./.\./.\./src/x.ps1' }
    ) {
        # Arrange
        $toolInput = @{ command = $Command } | ConvertTo-Json -Compress -Depth 5

        # Act
        $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $toolInput -CheckpointRaw (ConvertTo-CodexBypassNotReadyCheckpointRaw)

        # Assert
        $decision.hookSpecificOutput.permissionDecision |
            Should -Be 'deny' -Because "$Label reaches outside the exempt trees under at least one shell"
        $decision.hookSpecificOutput.permissionDecisionReason.StartsWith('PREIMPLEMENTATION_GATE_BLOCKED:') |
            Should -BeTrue -Because 'the denial is the preimplementation gate block'
    }
}
