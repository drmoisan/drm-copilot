#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Pester tests for the enforce-epic-invocation-origin.ps1 PreToolUse hook.
#>

Describe 'enforce-epic-invocation-origin.ps1' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-invocation-origin.ps1").Path
        . $script:UnderTest
    }

    Context 'allow (no-op) when the delegation target is not an epic agent' {
        It 'allows when both payloads are empty' {
            $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw '' -ToolInputRaw ''
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows a non-epic delegation from the main thread' {
            $toolInput = '{"subagent_type":"orchestrator","prompt":"run a feature"}'
            $hookInput = '{"session_id":"abc","tool_name":"Agent"}'
            $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw $hookInput -ToolInputRaw $toolInput
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows a non-epic delegation made from an orchestrator agent' {
            $toolInput = '{"subagent_type":"atomic-planner","prompt":"plan the feature"}'
            $hookInput = '{"session_id":"abc","agent_type":"orchestrator","tool_name":"Agent"}'
            $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw $hookInput -ToolInputRaw $toolInput
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows and never parses the hook payload for a non-epic target' {
            # A malformed hook payload must not matter when the target is not gated.
            $toolInput = '{"subagent_type":"task-researcher","prompt":"research"}'
            $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw '{not-json' -ToolInputRaw $toolInput
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'allow when an epic agent is invoked outside an orchestrator context' {
        It 'allows epic-orchestrator from the main thread (no agent_type field)' {
            $toolInput = '{"subagent_type":"epic-orchestrator","prompt":"execute the epic"}'
            $hookInput = '{"session_id":"abc","tool_name":"Agent"}'
            $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw $hookInput -ToolInputRaw $toolInput
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows epic-planner when the hook payload is empty' {
            $toolInput = '{"subagent_type":"epic-planner","prompt":"plan the epic"}'
            $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw '' -ToolInputRaw $toolInput
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows epic-orchestrator invoked from a non-orchestrator agent' {
            $toolInput = '{"subagent_type":"epic-orchestrator","prompt":"execute the epic"}'
            $hookInput = '{"session_id":"abc","agent_type":"epic-planner","tool_name":"Agent"}'
            $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw $hookInput -ToolInputRaw $toolInput
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows an epic target when agent_type is blank' {
            $toolInput = '{"subagent_type":"epic-planner","prompt":"plan the epic"}'
            $hookInput = '{"session_id":"abc","agent_type":"  ","tool_name":"Agent"}'
            $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw $hookInput -ToolInputRaw $toolInput
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'deny EPIC_INVOCATION_ORIGIN_BLOCKED for orchestrator-originated epic invocations' {
        It 'denies epic-orchestrator invoked from an orchestrator agent' {
            $toolInput = '{"subagent_type":"epic-orchestrator","prompt":"execute the epic"}'
            $hookInput = '{"session_id":"abc","agent_type":"orchestrator","tool_name":"Agent"}'
            $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw $hookInput -ToolInputRaw $toolInput
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_INVOCATION_ORIGIN_BLOCKED'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'epic-orchestrator'
        }

        It 'denies epic-planner invoked from an orchestrator agent' {
            $toolInput = '{"subagent_type":"epic-planner","prompt":"plan the epic"}'
            $hookInput = '{"session_id":"abc","agent_type":"orchestrator","tool_name":"Agent"}'
            $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw $hookInput -ToolInputRaw $toolInput
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_INVOCATION_ORIGIN_BLOCKED'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'epic-planner'
        }

        It 'denies when the target arrives only via the payload tool_input fallback' {
            $hookInput = '{"session_id":"abc","agent_type":"orchestrator","tool_name":"Agent","tool_input":{"subagent_type":"epic-planner","prompt":"plan the epic"}}'
            $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw $hookInput -ToolInputRaw ''
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_INVOCATION_ORIGIN_BLOCKED'
        }
    }

    Context 'malformed payloads throw so the hook exits 1' {
        It 'throws on malformed tool-input JSON' {
            { Invoke-EpicInvocationOriginDecision -HookInputRaw '' -ToolInputRaw '{not-json' } | Should -Throw
        }

        It 'throws on malformed hook-input JSON when the target is gated' {
            $toolInput = '{"subagent_type":"epic-orchestrator","prompt":"execute the epic"}'
            { Invoke-EpicInvocationOriginDecision -HookInputRaw '{not-json' -ToolInputRaw $toolInput } | Should -Throw
        }
    }
}
