#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Payload-envelope tests for enforce-completion-consistency.ps1 (issue #501).
.DESCRIPTION
    Sibling of enforce-completion-consistency.Tests.ps1, which has no headroom under
    the 500-line ceiling. Covers the shared-reader migration: envelope anomalies fail
    closed as a deny, and the nested envelope reaches the existing decision logic.

    No test spawns a child process or mutates the process environment.
#>

Describe 'enforce-completion-consistency.ps1 payload envelope' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-completion-consistency.ps1").Path
        . $script:UnderTest
    }

    Context 'envelope anomalies fail closed' {
        It 'denies an empty payload' {
            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw ''
            $decision.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'COMPLETION_CONSISTENCY_BLOCKED'
        }

        It 'denies unparseable top-level JSON instead of throwing (exit 1 is non-blocking)' {
            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw '{not-json'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'not parseable JSON'
        }

        It 'denies the legacy flat root shape as a missing-tool_input anomaly' {
            $flat = '{"file_path":"artifacts/orchestration/orchestrator-state.json","content":"{}"}'
            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $flat
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'no tool_input key'
        }

        It 'denies a null tool_input' {
            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw '{"tool_name":"Write","tool_input":null}'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'tool_input is null'
        }

        It 'denies a non-object tool_input' {
            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw '{"tool_name":"Write","tool_input":"text"}'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'not an object'
        }
    }

    Context 'Entrypoint transport' {
        It 'reads the payload through the shared reader' {
            $hookText = Get-Content -Path $script:UnderTest -Raw

            $hookText | Should -BeLike '*HookPayload.psm1*'
            $hookText | Should -BeLike '*Read-ClaudeHookRawPayload*'
        }

        It 'emits a block decision JSON when completion is asserted without evidence' {
            $content = '{"next_step":"complete"}'
            $payload = (@{
                    tool_name  = 'Write'
                    tool_input = @{ file_path = 'artifacts/orchestration/orchestrator-state.json'; content = $content }
                } | ConvertTo-Json -Compress -Depth 8)

            $output = Invoke-CompletionConsistencyDecision -ToolInputRaw $payload |
                ConvertTo-Json -Compress -Depth 5

            $output | Should -Match '"permissionDecision"\s*:\s*"deny"'
            $output | Should -Match 'COMPLETION_CONSISTENCY_BLOCKED'
        }
    }
}
