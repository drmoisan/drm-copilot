#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'enforce-checkpoint-monotonic.ps1' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-checkpoint-monotonic.ps1").Path
        . $script:UnderTest
    }

    Context 'tool input parsing' {
        It 'denies an empty payload as an envelope anomaly (fail closed)' {
            $decision = Invoke-CheckpointMonotonicDecision -ToolInputRaw ''
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'CHECKPOINT_MONOTONIC_BLOCKED'
        }

        It 'allows when file_path is missing' {
            (Invoke-CheckpointMonotonicDecision -ToolInputRaw '{"tool_input":{"content":"{}"}}').hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows when path is not the checkpoint' {
            $json = '{"tool_input":{"file_path":"some/other.json","content":"{\"completed_steps\":[\"S1\"]}"}}'
            (Invoke-CheckpointMonotonicDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies unparseable JSON instead of throwing (exit 1 is non-blocking)' {
            $decision = Invoke-CheckpointMonotonicDecision -ToolInputRaw '{not-json'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'not parseable JSON'
        }

        It 'denies the legacy flat root shape as a missing-tool_input anomaly' {
            $flat = '{"file_path":"artifacts/orchestration/orchestrator-state.json","content":"{}"}'
            $decision = Invoke-CheckpointMonotonicDecision -ToolInputRaw $flat
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'no tool_input key'
        }
    }

    Context 'Edit tool calls (no full content)' {
        It 'allows an Edit-style call that only supplies old_string/new_string' {
            $json = '{"tool_input":{"file_path":"artifacts/orchestration/orchestrator-state.json","old_string":"a","new_string":"b"}}'
            (Invoke-CheckpointMonotonicDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'Write tool calls' {
        It 'allows when content has no completed_steps field' {
            $content = '{"objective":"x"}'
            $json = (@{
                    tool_name  = 'Write'
                    tool_input = @{ file_path = 'artifacts/orchestration/orchestrator-state.json'; content = $content }
                } | ConvertTo-Json -Compress -Depth 5)
            (Invoke-CheckpointMonotonicDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows when steps are in canonical order with promotion and planning present' {
            $content = '{"completed_steps":["S0_startup_checks","S1_change_budget_estimation","S3_promotion","S4_atomic_planning","S5_atomic_execution","S12_complete"]}'
            $json = (@{
                    tool_name  = 'Write'
                    tool_input = @{ file_path = 'artifacts/orchestration/orchestrator-state.json'; content = $content }
                } | ConvertTo-Json -Compress -Depth 5)
            (Invoke-CheckpointMonotonicDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows when a single canonical step is present' {
            $content = '{"completed_steps":["S0_startup_checks"]}'
            $json = (@{
                    tool_name  = 'Write'
                    tool_input = @{ file_path = 'artifacts/orchestration/orchestrator-state.json'; content = $content }
                } | ConvertTo-Json -Compress -Depth 5)
            (Invoke-CheckpointMonotonicDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows non-canonical informational entries' {
            $content = '{"completed_steps":["S0_startup_checks","informational_note","S4_atomic_planning"]}'
            $json = (@{
                    tool_name  = 'Write'
                    tool_input = @{ file_path = 'artifacts/orchestration/orchestrator-state.json'; content = $content }
                } | ConvertTo-Json -Compress -Depth 5)
            (Invoke-CheckpointMonotonicDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies when later step appears before earlier step' {
            $content = '{"completed_steps":["S5_atomic_execution","S4_atomic_planning"]}'
            $json = (@{
                    tool_name  = 'Write'
                    tool_input = @{ file_path = 'artifacts/orchestration/orchestrator-state.json'; content = $content }
                } | ConvertTo-Json -Compress -Depth 5)
            $decision = Invoke-CheckpointMonotonicDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'S5_atomic_execution'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'S4_atomic_planning'
        }

        It 'denies Issue #232 implementation completion without promotion and planning prerequisites' {
            $content = '{"issue-num":"232","completed_steps":["S5_atomic_execution"]}'
            $json = (@{
                    tool_name  = 'Write'
                    tool_input = @{ file_path = 'artifacts/orchestration/orchestrator-state.json'; content = $content }
                } | ConvertTo-Json -Compress -Depth 5)
            $decision = Invoke-CheckpointMonotonicDecision -ToolInputRaw $json

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'S3_promotion'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'S4_atomic_planning'
        }

        It 'denies Issue #232 PR completion without planning prerequisite' {
            $content = '{"issue-num":"232","completed_steps":["S3_promotion_issue","S8_create_pr"]}'
            $json = (@{
                    tool_name  = 'Write'
                    tool_input = @{ file_path = 'artifacts/orchestration/orchestrator-state.json'; content = $content }
                } | ConvertTo-Json -Compress -Depth 5)
            $decision = Invoke-CheckpointMonotonicDecision -ToolInputRaw $json

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'S4_atomic_planning'
        }

        It 'allows out-of-order when rollback_history is non-empty' {
            $content = '{"completed_steps":["S5_atomic_execution","S4_atomic_planning"],"rollback_history":[{"step":"S5_atomic_execution","reason":"reset"}]}'
            $json = (@{
                    tool_name  = 'Write'
                    tool_input = @{ file_path = 'artifacts/orchestration/orchestrator-state.json'; content = $content }
                } | ConvertTo-Json -Compress -Depth 5)
            (Invoke-CheckpointMonotonicDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows when content itself is not valid JSON (defers to downstream tools)' {
            $json = (@{
                    tool_name  = 'Write'
                    tool_input = @{ file_path = 'artifacts/orchestration/orchestrator-state.json'; content = '{broken' }
                } | ConvertTo-Json -Compress -Depth 5)
            (Invoke-CheckpointMonotonicDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'Part-4 prerequisite gate (serialize-then-parse contract)' {
        It 'denies an advanced step with S3_promotion and S4_atomic_planning both missing and names both prerequisites in the deny reason' {
            $content = '{"completed_steps":["S5_atomic_execution"]}'
            $json = (@{
                    tool_name  = 'Write'
                    tool_input = @{ file_path = 'artifacts/orchestration/orchestrator-state.json'; content = $content }
                } | ConvertTo-Json -Compress -Depth 5)
            $decision = Invoke-CheckpointMonotonicDecision -ToolInputRaw $json

            $parsed = $decision | ConvertTo-Json -Depth 5 | ConvertFrom-Json

            $parsed.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $parsed.hookSpecificOutput.permissionDecisionReason | Should -Match 'S3_promotion'
            $parsed.hookSpecificOutput.permissionDecisionReason | Should -Match 'S4_atomic_planning'
        }
    }

    Context 'Entrypoint transport' {
        It 'reads the payload through the shared reader' {
            $hookText = Get-Content -Path $script:UnderTest -Raw

            $hookText | Should -BeLike '*HookPayload.psm1*'
            $hookText | Should -BeLike '*Read-ClaudeHookRawPayload*'
        }

        It 'emits a deny decision JSON when steps are out of order under the nested envelope' {
            $content = '{"completed_steps":["S5_atomic_execution","S4_atomic_planning"]}'
            $payload = (@{
                    tool_name  = 'Write'
                    tool_input = @{ file_path = 'artifacts/orchestration/orchestrator-state.json'; content = $content }
                } | ConvertTo-Json -Compress -Depth 5)

            $output = Invoke-CheckpointMonotonicDecision -ToolInputRaw $payload | ConvertTo-Json -Compress -Depth 5

            $output | Should -Match '"permissionDecision"\s*:\s*"deny"'
            $output | Should -Match 'CHECKPOINT_ORDER_BLOCKED'
        }
    }

    Context 'Get-CanonicalStepIndex' {
        It 'returns -1 for non-canonical entries' {
            Get-CanonicalStepIndex -StepEntry 'noise' | Should -Be -1
        }
        It 'matches exact prefix' {
            Get-CanonicalStepIndex -StepEntry 'S0_startup_checks' | Should -Be 0
        }
        It 'matches S3_promotion variant via underscore suffix' {
            Get-CanonicalStepIndex -StepEntry 'S3_promotion_issue' | Should -BeGreaterThan 0
        }
        It 'returns ascending indices for S4 vs S5' {
            $a = Get-CanonicalStepIndex -StepEntry 'S4_atomic_planning'
            $b = Get-CanonicalStepIndex -StepEntry 'S5_atomic_execution'
            $b | Should -BeGreaterThan $a
        }
    }

    Context 'Get-OutOfOrderPair' {
        It 'returns $null when order is canonical' {
            Get-OutOfOrderPair -CompletedSteps @('S0_startup_checks', 'S1_change_budget_estimation') | Should -BeNullOrEmpty
        }
        It 'returns a pair when order is violated' {
            $pair = Get-OutOfOrderPair -CompletedSteps @('S5_atomic_execution', 'S4_atomic_planning')
            $pair.EarlierEntry | Should -Be 'S5_atomic_execution'
            $pair.LaterEntry  | Should -Be 'S4_atomic_planning'
        }
    }
}
