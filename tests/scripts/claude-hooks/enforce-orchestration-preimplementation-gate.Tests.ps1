#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'enforce-orchestration-preimplementation-gate.ps1' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-orchestration-preimplementation-gate.ps1").Path
        . $script:UnderTest

        function ConvertTo-ImplementationWriteToolInput {
            param(
                [string] $FilePath = 'scripts/dev_tools/validate_orchestrator_state.py',
                [string] $Content = 'implementation change'
            )

            return (@{ file_path = $FilePath; content = $Content } | ConvertTo-Json -Compress)
        }
    }

    Context 'implementation writes before orchestration readiness' {
        It 'blocks Issue #232 implementation writes when route metadata and lifecycle readiness are absent' {
            $json = ConvertTo-ImplementationWriteToolInput

            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json

            $decision['decision'] | Should -Be 'block'
            $decision['reason'] | Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'
            $decision['reason'] | Should -Match 'Issue #232'
            $decision['reason'] | Should -Match 'route metadata'
            $decision['reason'] | Should -Match 'lifecycle readiness'
        }

        It 'allows Issue #232 feature documentation writes' {
            $json = ConvertTo-ImplementationWriteToolInput -FilePath 'docs/features/active/2026-06-24-harden-orchestrate-skill-232/spec.md'

            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json

            $decision['decision'] | Should -Be 'allow'
        }

        It 'allows Issue #232 evidence writes' {
            $json = ConvertTo-ImplementationWriteToolInput -FilePath 'docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/qa-gates/example.md'

            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json

            $decision['decision'] | Should -Be 'allow'
        }

        It 'allows implementation writes when Issue #232 readiness is present' {
            $json = ConvertTo-ImplementationWriteToolInput
            $checkpoint = @{
                'issue-num'      = '232'
                'feature-folder' = 'docs/features/active/2026-06-24-harden-orchestrate-skill-232'
                route_id         = 'large'
                lifecycle_ready  = $true
            } | ConvertTo-Json -Compress

            $decision = Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw $json -CheckpointRaw $checkpoint

            $decision['decision'] | Should -Be 'allow'
        }
    }
}
