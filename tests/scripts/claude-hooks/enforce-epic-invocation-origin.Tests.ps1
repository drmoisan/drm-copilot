#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Pester tests for the enforce-epic-invocation-origin.ps1 PreToolUse hook.

.DESCRIPTION
    Drives the decision function with the documented single PreToolUse envelope
    (issue #501): the caller's agent_type sits at the envelope root and the delegation
    target's subagent_type inside the nested tool_input. An envelope the hook cannot
    read at all fails closed as a deny.

    The legacy direct tool-input payload keeps dedicated coverage on -ToolInputRaw, so
    an undocumented wrapper that supplies the bare tool input is still exercised.
#>

Describe 'enforce-epic-invocation-origin.ps1' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-invocation-origin.ps1").Path
        . $script:UnderTest

        function ConvertTo-OriginEnvelope {
            param(
                [Parameter(Mandatory)]
                [string] $Target,

                [string] $CallerAgentType,

                [string] $Prompt = 'delegate'
            )

            $envelope = [ordered]@{ session_id = 'abc'; tool_name = 'Agent' }
            if ($PSBoundParameters.ContainsKey('CallerAgentType')) {
                $envelope.agent_type = $CallerAgentType
            }
            $envelope.tool_input = [ordered]@{ subagent_type = $Target; prompt = $Prompt }

            return ($envelope | ConvertTo-Json -Compress -Depth 5)
        }
    }

    Context 'envelope anomalies fail closed' {
        It 'denies when both payloads are empty' {
            $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw '' -ToolInputRaw ''
            $decision.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_INVOCATION_ORIGIN_BLOCKED'
        }

        It 'denies when both payloads are unparseable' {
            $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw '{not-json' -ToolInputRaw '{not-json'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'not parseable JSON'
        }

        It 'denies an unparseable envelope with no legacy tool-input payload' {
            $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw '{not-json' -ToolInputRaw ''
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_INVOCATION_ORIGIN_BLOCKED'
        }

        It 'denies the legacy flat root shape as a missing-tool_input anomaly' {
            $flat = '{"subagent_type":"epic-planner","prompt":"plan the epic"}'
            $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw $flat
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'no tool_input key'
        }

        It 'denies a null tool_input' {
            $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw '{"tool_name":"Agent","tool_input":null}'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'tool_input is null'
        }

        It 'allows a well-formed envelope whose tool_input carries no subagent_type' {
            $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw '{"tool_name":"Agent","tool_input":{"prompt":"no target"}}'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'allow (no-op) when the delegation target is not a gated agent' {
        It 'allows a non-gated delegation from the main thread' {
            $envelope = ConvertTo-OriginEnvelope -Target 'orchestrator' -Prompt 'run a feature'
            $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw $envelope
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows a non-gated delegation made from an orchestrator agent' {
            $envelope = ConvertTo-OriginEnvelope -Target 'atomic-planner' -CallerAgentType 'orchestrator'
            $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw $envelope
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows a target whose name merely resembles a gated parallel type' {
            # The gate matches exact subagent_type values, not prefixes.
            $envelope = ConvertTo-OriginEnvelope -Target 'parallel-orchestrator-helper' -CallerAgentType 'orchestrator'
            $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw $envelope
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'legacy direct tool-input payload' {
        It 'allows a non-gated target supplied through the legacy payload when the envelope is unreadable' {
            $toolInput = '{"subagent_type":"task-researcher","prompt":"research"}'
            $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw '{not-json' -ToolInputRaw $toolInput
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows epic-planner supplied only through the legacy payload' {
            $toolInput = '{"subagent_type":"epic-planner","prompt":"plan the epic"}'
            $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw '' -ToolInputRaw $toolInput
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'allow when a gated agent is invoked outside an orchestrator context' {
        It 'allows epic-orchestrator from the main thread (no root agent_type)' {
            $envelope = ConvertTo-OriginEnvelope -Target 'epic-orchestrator' -Prompt 'execute the epic'
            (Invoke-EpicInvocationOriginDecision -HookInputRaw $envelope).hookSpecificOutput.permissionDecision |
                Should -Be 'allow'
        }

        It 'allows epic-orchestrator invoked from a non-orchestrator agent' {
            $envelope = ConvertTo-OriginEnvelope -Target 'epic-orchestrator' -CallerAgentType 'epic-planner'
            (Invoke-EpicInvocationOriginDecision -HookInputRaw $envelope).hookSpecificOutput.permissionDecision |
                Should -Be 'allow'
        }

        It 'allows an epic target when the root agent_type is blank' {
            $envelope = ConvertTo-OriginEnvelope -Target 'epic-planner' -CallerAgentType '  '
            (Invoke-EpicInvocationOriginDecision -HookInputRaw $envelope).hookSpecificOutput.permissionDecision |
                Should -Be 'allow'
        }

        It 'allows parallel-orchestrator from the main thread (no root agent_type)' {
            $envelope = ConvertTo-OriginEnvelope -Target 'parallel-orchestrator' -Prompt 'execute the parallel run'
            (Invoke-EpicInvocationOriginDecision -HookInputRaw $envelope).hookSpecificOutput.permissionDecision |
                Should -Be 'allow'
        }

        It 'allows parallel-planner from the main thread (no root agent_type)' {
            $envelope = ConvertTo-OriginEnvelope -Target 'parallel-planner' -Prompt 'plan the parallel run'
            (Invoke-EpicInvocationOriginDecision -HookInputRaw $envelope).hookSpecificOutput.permissionDecision |
                Should -Be 'allow'
        }

        It 'allows parallel-orchestrator when the root agent_type is blank' {
            $envelope = ConvertTo-OriginEnvelope -Target 'parallel-orchestrator' -CallerAgentType '  '
            (Invoke-EpicInvocationOriginDecision -HookInputRaw $envelope).hookSpecificOutput.permissionDecision |
                Should -Be 'allow'
        }

        It 'allows parallel-planner when the root agent_type is blank' {
            $envelope = ConvertTo-OriginEnvelope -Target 'parallel-planner' -CallerAgentType '  '
            (Invoke-EpicInvocationOriginDecision -HookInputRaw $envelope).hookSpecificOutput.permissionDecision |
                Should -Be 'allow'
        }

        It 'allows parallel-orchestrator invoked from a non-orchestrator agent' {
            $envelope = ConvertTo-OriginEnvelope -Target 'parallel-orchestrator' -CallerAgentType 'parallel-planner'
            (Invoke-EpicInvocationOriginDecision -HookInputRaw $envelope).hookSpecificOutput.permissionDecision |
                Should -Be 'allow'
        }

        It 'allows parallel-planner invoked from a non-orchestrator agent' {
            $envelope = ConvertTo-OriginEnvelope -Target 'parallel-planner' -CallerAgentType 'atomic-planner'
            (Invoke-EpicInvocationOriginDecision -HookInputRaw $envelope).hookSpecificOutput.permissionDecision |
                Should -Be 'allow'
        }
    }

    Context 'deny EPIC_INVOCATION_ORIGIN_BLOCKED for orchestrator-originated epic invocations' {
        It 'denies epic-orchestrator invoked from an orchestrator agent' {
            $envelope = ConvertTo-OriginEnvelope -Target 'epic-orchestrator' -CallerAgentType 'orchestrator'
            $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw $envelope
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_INVOCATION_ORIGIN_BLOCKED'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'epic-orchestrator'
        }

        It 'denies epic-planner invoked from an orchestrator agent' {
            $envelope = ConvertTo-OriginEnvelope -Target 'epic-planner' -CallerAgentType 'orchestrator'
            $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw $envelope
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_INVOCATION_ORIGIN_BLOCKED'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'epic-planner'
        }
    }

    Context 'deny PARALLEL_INVOCATION_ORIGIN_BLOCKED for orchestrator-originated parallel invocations' {
        It 'denies parallel-orchestrator invoked from an orchestrator agent' {
            $envelope = ConvertTo-OriginEnvelope -Target 'parallel-orchestrator' -CallerAgentType 'orchestrator'
            $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw $envelope
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PARALLEL_INVOCATION_ORIGIN_BLOCKED'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'parallel-orchestrator'
        }

        It 'denies parallel-planner invoked from an orchestrator agent' {
            $envelope = ConvertTo-OriginEnvelope -Target 'parallel-planner' -CallerAgentType 'orchestrator'
            $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw $envelope
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PARALLEL_INVOCATION_ORIGIN_BLOCKED'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'parallel-planner'
        }

        It 'does not use the epic deny prefix for a parallel target' {
            # The two families carry distinct reason variants selected by target.
            $envelope = ConvertTo-OriginEnvelope -Target 'parallel-orchestrator' -CallerAgentType 'orchestrator'
            $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw $envelope
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Not -Match 'EPIC_INVOCATION_ORIGIN_BLOCKED'
        }
    }

    Context 'epic deny reasons render byte-for-byte' {
        It 'renders the epic deny reason for epic-orchestrator byte-for-byte' {
            $envelope = ConvertTo-OriginEnvelope -Target 'epic-orchestrator' -CallerAgentType 'orchestrator' -Prompt 'execute the epic'
            $expected = 'EPIC_INVOCATION_ORIGIN_BLOCKED: Agent(epic-orchestrator) must not be invoked from an orchestrator agent. Both epic-planner and epic-orchestrator delegate to Agent(orchestrator), so an orchestrator-originated invocation would nest orchestrator inside its own delegation chain. Invoke epic-orchestrator from the main session instead.'

            $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw $envelope

            # Exact byte identity, not a substring match.
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Be $expected
        }

        It 'renders the epic deny reason for epic-planner byte-for-byte' {
            $envelope = ConvertTo-OriginEnvelope -Target 'epic-planner' -CallerAgentType 'orchestrator' -Prompt 'plan the epic'
            $expected = 'EPIC_INVOCATION_ORIGIN_BLOCKED: Agent(epic-planner) must not be invoked from an orchestrator agent. Both epic-planner and epic-orchestrator delegate to Agent(orchestrator), so an orchestrator-originated invocation would nest orchestrator inside its own delegation chain. Invoke epic-planner from the main session instead.'

            $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw $envelope

            $decision.hookSpecificOutput.permissionDecisionReason | Should -Be $expected
        }
    }

    Context 'shared-reader transport' {
        It 'reads the payload through the shared reader at the entry point' {
            $hookText = Get-Content -Path $script:UnderTest -Raw

            $hookText | Should -BeLike '*HookPayload.psm1*'
            $hookText | Should -BeLike '*Read-ClaudeHookRawPayload*'
        }

        It 'resolves a stdin-delivered envelope through the shared reader' {
            $envelope = ConvertTo-OriginEnvelope -Target 'epic-planner' -CallerAgentType 'orchestrator'
            $raw = Read-ClaudeHookRawPayload `
                -ReadStandardInput { $envelope }.GetNewClosure() `
                -TestStandardInputRedirected { $true } `
                -HookInputFallback '' `
                -ToolInputFallback ''

            $decision = Invoke-EpicInvocationOriginDecision -HookInputRaw $raw

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_INVOCATION_ORIGIN_BLOCKED'
        }

        It 'reads the caller agent_type off the envelope root, not the nested tool_input' {
            # A root agent_type of orchestrator denies; the same value nested inside
            # tool_input must not be mistaken for the caller identity.
            $rooted = '{"tool_name":"Agent","agent_type":"orchestrator","tool_input":{"subagent_type":"epic-planner"}}'
            $nestedOnly = '{"tool_name":"Agent","tool_input":{"subagent_type":"epic-planner","agent_type":"orchestrator"}}'

            (Invoke-EpicInvocationOriginDecision -HookInputRaw $rooted).hookSpecificOutput.permissionDecision |
                Should -Be 'deny'
            (Invoke-EpicInvocationOriginDecision -HookInputRaw $nestedOnly).hookSpecificOutput.permissionDecision |
                Should -Be 'allow'
        }
    }
}
