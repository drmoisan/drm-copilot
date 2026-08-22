#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Payload-envelope and entry-point tests for enforce-pr-author-skill.ps1 (issue #501).
.DESCRIPTION
    Sibling of enforce-pr-author-skill.Tests.ps1, which had no headroom under the 500-line
    limit. Covers the shared-reader migration: envelope anomalies fail closed as a deny at
    exit code 0 (never exit 1), the nested envelope reaches the existing decision logic, and
    property-level absence inside a well-formed tool_input still allows.

    Exit codes are asserted through the entry-point function's [int] return value, not by
    spawning a child process, because spawning is prohibited in Pester suites.
#>

Describe 'enforce-pr-author-skill.ps1 payload envelope' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-pr-author-skill.ps1").Path
        . $script:UnderTest
    }

    Context 'entry-point exit code and emitted decision (AC-4, no child process)' {
        It 'returns exit code 0 and emits a deny when every transport is empty' {
            $emptyReader = {
                Read-ClaudeHookRawPayload `
                    -ReadStandardInput { '' } `
                    -TestStandardInputRedirected { $true } `
                    -HookInputFallback '' `
                    -ToolInputFallback ''
            }
            $emitted = Invoke-PrAuthorSkillEntryPoint -ReadPayload $emptyReader
            $emitted[-1] | Should -Be 0
            $emitted[-1] | Should -Not -Be 1
            $parsed = $emitted[0] | ConvertFrom-Json
            $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $parsed.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_AUTHOR_SKILL_BLOCKED'
        }

        It 'returns exit code 0 and emits a deny for unparseable JSON' {
            $emitted = Invoke-PrAuthorSkillEntryPoint -ToolInputRaw '{not-json'
            $emitted[-1] | Should -Be 0
            $emitted[-1] | Should -Not -Be 1
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason |
                Should -Match 'not parseable JSON'
        }

        It 'returns exit code 0 and emits a deny for JSON with no tool_input key' {
            $emitted = Invoke-PrAuthorSkillEntryPoint -ToolInputRaw '{"session_id":"s1","tool_name":"Bash"}'
            $emitted[-1] | Should -Be 0
            $emitted[-1] | Should -Not -Be 1
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason |
                Should -Match 'no tool_input key'
        }

        It 'returns exit code 0 and emits a deny for the legacy flat root shape' {
            $emitted = Invoke-PrAuthorSkillEntryPoint -ToolInputRaw '{"command":"gh pr create --body inline"}'
            $emitted[-1] | Should -Be 0
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason |
                Should -Match 'no tool_input key'
        }

        It 'returns exit code 0 and emits a deny for a null tool_input' {
            $emitted = Invoke-PrAuthorSkillEntryPoint -ToolInputRaw '{"tool_name":"Bash","tool_input":null}'
            $emitted[-1] | Should -Be 0
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason |
                Should -Match 'tool_input is null'
        }

        It 'returns exit code 0 and emits a deny for a non-object tool_input' {
            $emitted = Invoke-PrAuthorSkillEntryPoint -ToolInputRaw '{"tool_name":"Bash","tool_input":"gh pr create"}'
            $emitted[-1] | Should -Be 0
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason |
                Should -Match 'not an object'
        }
    }

    Context 'nested envelope reaches the existing decision logic (AC-7)' {
        It 'denies a nested gh pr create carrying an inline --body' {
            $nested = '{"tool_name":"Bash","tool_input":{"command":"gh pr create --title t --body inline"}}'
            $emitted = Invoke-PrAuthorSkillEntryPoint -ToolInputRaw $nested
            $emitted[-1] | Should -Be 0
            $parsed = $emitted[0] | ConvertFrom-Json
            $parsed.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $parsed.hookSpecificOutput.permissionDecisionReason | Should -Match 'PR_AUTHOR_SKILL_BLOCKED'
        }

        It 'allows a nested Bash command outside the gate scope' {
            $nested = '{"tool_name":"Bash","tool_input":{"command":"git status --short"}}'
            $emitted = Invoke-PrAuthorSkillEntryPoint -ToolInputRaw $nested
            $emitted[-1] | Should -Be 0
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows a well-formed tool_input that carries no command property (scope filter)' {
            $nested = '{"tool_name":"Write","tool_input":{"file_path":"src/x.ts","content":"body"}}'
            $emitted = Invoke-PrAuthorSkillEntryPoint -ToolInputRaw $nested
            $emitted[-1] | Should -Be 0
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }
}
