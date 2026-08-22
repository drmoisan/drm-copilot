#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Payload-envelope and entry-point tests for enforce-parallel-cohort-barrier.ps1
    (issue #501).
.DESCRIPTION
    Sibling of enforce-parallel-cohort-barrier.Tests.ps1, which has no headroom under the
    500-line ceiling. Covers the shared-reader migration: envelope anomalies fail closed
    as a deny at exit code 0 (never exit 1), and the nested envelope reaches the existing
    barrier logic.

    Exit codes are asserted through the entry-point function's [int] return value, not by
    spawning a child process, because spawning is prohibited in Pester suites.
#>

Describe 'enforce-parallel-cohort-barrier.ps1 payload envelope' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-parallel-cohort-barrier.ps1").Path
        . $script:UnderTest
    }

    Context 'entry-point exit code and emitted decision (AC-4, no child process)' {
        BeforeEach {
            Mock -CommandName Get-ParallelCohortBarrierCheckpointContent -MockWith { $null }
        }

        It 'returns exit code 0 and emits a deny when every transport is empty' {
            $emptyReader = {
                Read-ClaudeHookRawPayload `
                    -ReadStandardInput { '' } `
                    -TestStandardInputRedirected { $true } `
                    -HookInputFallback '' `
                    -ToolInputFallback ''
            }
            $emitted = Invoke-ParallelCohortBarrierEntryPoint -ReadPayload $emptyReader
            $emitted[-1] | Should -Be 0
            $emitted[-1] | Should -Not -Be 1
            $parsed = $emitted[0] | ConvertFrom-Json
            $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $parsed.hookSpecificOutput.permissionDecisionReason | Should -Match 'PARALLEL_COHORT_BARRIER_BLOCKED'
        }

        It 'returns exit code 0 and emits a deny for unparseable JSON' {
            $emitted = Invoke-ParallelCohortBarrierEntryPoint -ToolInputRaw '{not-json'
            $emitted[-1] | Should -Be 0
            $emitted[-1] | Should -Not -Be 1
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason |
                Should -Match 'not parseable JSON'
        }

        It 'returns exit code 0 and emits a deny for the legacy flat root shape' {
            $flat = '{"subagent_type":"orchestrator","prompt":"Parallel mode: true. docs/features/active/item-b-102"}'
            $emitted = Invoke-ParallelCohortBarrierEntryPoint -ToolInputRaw $flat
            $emitted[-1] | Should -Be 0
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason |
                Should -Match 'no tool_input key'
        }

        It 'returns exit code 0 and emits a deny for a null tool_input' {
            $emitted = Invoke-ParallelCohortBarrierEntryPoint -ToolInputRaw '{"tool_name":"Agent","tool_input":null}'
            $emitted[-1] | Should -Be 0
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason |
                Should -Match 'tool_input is null'
        }

        It 'denies the nested envelope end-to-end when no checkpoint resolves the target (AC-7)' {
            $nested = '{"tool_name":"Agent","tool_input":{"subagent_type":"orchestrator","prompt":"Parallel mode: true. docs/features/active/item-b-102"}}'
            $emitted = Invoke-ParallelCohortBarrierEntryPoint -ToolInputRaw $nested
            $emitted[-1] | Should -Be 0
            $parsed = $emitted[0] | ConvertFrom-Json
            $parsed.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $parsed.hookSpecificOutput.permissionDecisionReason | Should -Match 'PARALLEL_COHORT_BARRIER_BLOCKED'
        }

        It 'allows a nested delegation whose prompt lacks the parallel-mode marker' {
            $nested = '{"tool_name":"Agent","tool_input":{"subagent_type":"orchestrator","prompt":"plain delegation"}}'
            $emitted = Invoke-ParallelCohortBarrierEntryPoint -ToolInputRaw $nested
            $emitted[-1] | Should -Be 0
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows a well-formed tool_input carrying no subagent_type (scope filter)' {
            $nested = '{"tool_name":"Bash","tool_input":{"command":"echo hi"}}'
            $emitted = Invoke-ParallelCohortBarrierEntryPoint -ToolInputRaw $nested
            $emitted[-1] | Should -Be 0
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }
}
