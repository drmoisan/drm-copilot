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
            $json = @{ command = $script:AbandonCommand } | ConvertTo-Json -Compress
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PARALLEL_ABANDON_BLOCKED'
        }

        It 'reports the PreToolUse hook event name on the deny decision' {
            $json = @{ command = $script:AbandonCommand } | ConvertTo-Json -Compress
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
        }

        It 'denies a detach-shaped command that still names the abandon disposition' {
            $json = @{ command = 'gh pr close 7 --disposition abandon' } | ConvertTo-Json -Compress
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'denies when extra whitespace separates the disposition token parts' {
            $json = @{ command = 'run  --disposition   abandon  now' } | ConvertTo-Json -Compress
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }
    }

    Context 'allow a confirmed abandon command' {
        It 'allows when both tokens are present in the same command' {
            $json = @{ command = $script:ConfirmedCommand } | ConvertTo-Json -Compress
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows when the confirmation marker precedes the disposition token' {
            $json = @{ command = 'run --confirm-abandon --disposition abandon' } | ConvertTo-Json -Compress
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'omits a deny reason from the allow decision' {
            $json = @{ command = $script:ConfirmedCommand } | ConvertTo-Json -Compress
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.Keys | Should -Not -Contain 'permissionDecisionReason'
        }
    }

    Context 'commands outside scope' {
        It 'allows when CLAUDE_TOOL_INPUT is empty' {
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw ''
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows when the JSON payload has no command field' {
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw '{"other":"value"}'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows a command carrying no abandon disposition token' {
            $json = @{ command = 'git worktree list --porcelain' } | ConvertTo-Json -Compress
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows the detach disposition, which is not destructive' {
            $json = @{ command = 'run --disposition detach' } | ConvertTo-Json -Compress
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows a command carrying only the confirmation marker' {
            $json = @{ command = 'run --confirm-abandon' } | ConvertTo-Json -Compress
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'malformed tool input' {
        It 'throws on malformed JSON so the hook exits 1' {
            { Invoke-ParallelAbandonGateDecision -ToolInputRaw '{not-json' } | Should -Throw
        }

        It 'names the hook in the malformed-JSON error' {
            { Invoke-ParallelAbandonGateDecision -ToolInputRaw '{ broken' } |
                Should -Throw -ExpectedMessage '*enforce-parallel-abandon-gate*'
        }
    }

    Context 'tool-input read seam' {
        It 'reads the payload through the mocked seam rather than the environment' {
            Mock -CommandName Get-ParallelAbandonGateToolInput -MockWith {
                @{ command = $script:AbandonCommand } | ConvertTo-Json -Compress
            }
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw (Get-ParallelAbandonGateToolInput)
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            Should -Invoke -CommandName Get-ParallelAbandonGateToolInput -Times 1 -Exactly
        }

        It 'allows when the mocked seam yields no payload' {
            Mock -CommandName Get-ParallelAbandonGateToolInput -MockWith { $null }
            $decision = Invoke-ParallelAbandonGateDecision -ToolInputRaw (Get-ParallelAbandonGateToolInput)
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
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
