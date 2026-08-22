#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Pester tests for the enforce-parallel-abandon-gate.ps1 PreToolUse hook.

.DESCRIPTION
    Dot-sources the hook so its dot-source guard suppresses the entrypoint, then drives
    the decision function directly with literal JSON payloads. The tool-input read seam is
    mocked where the entrypoint path is exercised, so no test reads the environment, writes
    a temporary file, or invokes live git or gh.

    Token literals appear here as test inputs only. The producer/consumer binding between
    the hook, the abandon CLI, and the documented invocation is proven separately by
    tests/scripts/dev_tools/test_parallel_abandon_token_seam.py, which parses both sides at
    run time rather than restating either value.
#>

Describe 'enforce-parallel-abandon-gate.ps1' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-parallel-abandon-gate.ps1").Path
        . $script:UnderTest

        $script:AbandonCommand = 'poetry run python scripts/dev_tools/parallel_mutation_abandon_cli.py --item 442 --disposition abandon --pr 7 --worktree /repo/wt/child-a'
        $script:ConfirmedCommand = 'poetry run python scripts/dev_tools/parallel_mutation_abandon_cli.py --item 442 --disposition abandon --confirm-abandon --pr 7 --worktree /repo/wt/child-a'
    }

    Context 'deny an unconfirmed abandon command' {
        It 'denies PARALLEL_ABANDON_BLOCKED when the confirmation marker is absent' {
            $json = @{ tool_name = 'Bash'; tool_input = @{ command = $script:AbandonCommand } } | ConvertTo-Json -Compress -Depth 5
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PARALLEL_ABANDON_BLOCKED'
        }

        It 'reports the PreToolUse hook event name on the deny decision' {
            $json = @{ tool_name = 'Bash'; tool_input = @{ command = $script:AbandonCommand } } | ConvertTo-Json -Compress -Depth 5
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
        }

        It 'denies a detach-shaped command that still names the abandon disposition' {
            $json = @{ tool_name = 'Bash'; tool_input = @{ command = 'gh pr close 7 --disposition abandon' } } | ConvertTo-Json -Compress -Depth 5
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'denies when extra whitespace separates the disposition token parts' {
            $json = @{ tool_name = 'Bash'; tool_input = @{ command = 'run  --disposition   abandon  now' } } | ConvertTo-Json -Compress -Depth 5
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }
    }

    Context 'allow a confirmed abandon command' {
        It 'allows when both tokens are present in the same command' {
            $json = @{ tool_name = 'Bash'; tool_input = @{ command = $script:ConfirmedCommand } } | ConvertTo-Json -Compress -Depth 5
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows when the confirmation marker precedes the disposition token' {
            $json = @{ tool_name = 'Bash'; tool_input = @{ command = 'run --confirm-abandon --disposition abandon' } } | ConvertTo-Json -Compress -Depth 5
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'omits a deny reason from the allow decision' {
            $json = @{ tool_name = 'Bash'; tool_input = @{ command = $script:ConfirmedCommand } } | ConvertTo-Json -Compress -Depth 5
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.Keys | Should -Not -Contain 'permissionDecisionReason'
        }
    }

    Context 'commands outside scope' {
        It 'denies an empty payload as an envelope anomaly (fail closed)' {
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw ''
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PARALLEL_ABANDON_BLOCKED'
        }

        It 'allows when the JSON payload has no command field' {
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw '{"tool_input":{"other":"value"}}'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows a command carrying no abandon disposition token' {
            $json = @{ tool_name = 'Bash'; tool_input = @{ command = 'git worktree list --porcelain' } } | ConvertTo-Json -Compress -Depth 5
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows the detach disposition, which is not destructive' {
            $json = @{ tool_name = 'Bash'; tool_input = @{ command = 'run --disposition detach' } } | ConvertTo-Json -Compress -Depth 5
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows a command carrying only the confirmation marker' {
            $json = @{ tool_name = 'Bash'; tool_input = @{ command = 'run --confirm-abandon' } } | ConvertTo-Json -Compress -Depth 5
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'malformed tool input' {
        It 'denies unparseable JSON instead of throwing (exit 1 is non-blocking)' {
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw '{not-json'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'not parseable JSON'
        }

        It 'names the reason code on the malformed-JSON deny' {
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw '{ broken'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PARALLEL_ABANDON_BLOCKED'
        }

        It 'denies the legacy flat root shape as a missing-tool_input anomaly' {
            $flat = @{ command = ('run ' + $script:AbandonDispositionToken) } | ConvertTo-Json -Compress
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw $flat
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'no tool_input key'
        }
    }

    Context 'tool-input read seam' {
        It 'reads the payload through the mocked seam rather than the environment' {
            Mock -CommandName Get-ParallelAbandonGateToolInput -MockWith {
                @{ tool_name = 'Bash'; tool_input = @{ command = $script:AbandonCommand } } |
                    ConvertTo-Json -Compress -Depth 5
            }
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw (Get-ParallelAbandonGateToolInput)
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            Should -Invoke -CommandName Get-ParallelAbandonGateToolInput -Times 1 -Exactly
        }

        It 'denies when the mocked seam yields no payload (fail closed)' {
            Mock -CommandName Get-ParallelAbandonGateToolInput -MockWith { $null }
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw (Get-ParallelAbandonGateToolInput)
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PARALLEL_ABANDON_BLOCKED'
        }

        It 'reads the payload through the shared reader by default' {
            $seamBody = (Get-Command Get-ParallelAbandonGateToolInput).ScriptBlock.ToString()
            $seamBody | Should -BeLike '*Read-ClaudeHookRawPayload*'
        }
    }

    Context 'declared token constants' {
        It 'declares both named token constants' {
            $script:AbandonDispositionToken | Should -Not -BeNullOrEmpty
            $script:AbandonConfirmToken | Should -Not -BeNullOrEmpty
        }

        It 'builds the deny reason from the declared tokens' {
            $reason = Get-ParallelAbandonGateBlockReason
            $reason | Should -Match 'PARALLEL_ABANDON_BLOCKED'
            $reason | Should -BeLike "*$($script:AbandonDispositionToken)*"
            $reason | Should -BeLike "*$($script:AbandonConfirmToken)*"
        }
    }

    Context 'command normalization' {
        It 'returns an empty string for a whitespace-only command' {
            Get-ParallelAbandonNormalizedCommand -CommandText '   ' | Should -Be ''
        }

        It 'collapses whitespace runs to single spaces' {
            Get-ParallelAbandonNormalizedCommand -CommandText "a  b`tc" | Should -Be 'a b c'
        }

        It 'reports an empty command as out of scope' {
            Test-ParallelAbandonCommandInScope -NormalizedCommand '' | Should -BeFalse
        }

        It 'reports an empty command as unconfirmed' {
            Test-ParallelAbandonCommandConfirmed -NormalizedCommand '' | Should -BeFalse
        }
    }
}
