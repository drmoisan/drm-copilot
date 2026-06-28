<#
.SYNOPSIS
    Pester v5.x unit tests for the validate-bash.ps1 Claude Code pre-tool-use hook.

.DESCRIPTION
    Exercises the pure detector and deny-decision builder of validate-bash.ps1.
    Asserts that a blocked command yields the matched pattern via Get-BashBlockReason,
    that a safe command yields $null, and that the deny decision, after
    ConvertTo-Json -Depth 5 then ConvertFrom-Json, carries the PreToolUse schema
    (hookSpecificOutput.hookEventName = 'PreToolUse',
    hookSpecificOutput.permissionDecision = 'deny'). Also asserts the hook contains
    no deny-path 'exit 1'. No disk, network, or temporary-file use.
#>

Set-StrictMode -Version Latest

Describe "validate-bash.ps1" {
    BeforeAll {
        # Resolve the production script path relative to the repo root.
        $script:ScriptPath = Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath '..', '..', '.claude', 'hooks', 'validate-bash.ps1'
        $script:ScriptPath = (Resolve-Path $script:ScriptPath).Path

        # Dot-source the hook so its pure functions are available in the test scope.
        # The dot-sourcing guard inside the hook returns early, so no entrypoint runs.
        . $script:ScriptPath
    }

    Context "Get-BlockedPatternMatch / Get-BashBlockReason on blocked commands" {
        It "returns the matched pattern for every repository-dangerous command" {
            $cases = @(
                @{ Command = 'git push --force'; Pattern = 'git push --force' },
                @{ Command = 'git push origin --force'; Pattern = 'git push origin --force' },
                @{ Command = 'git push -f'; Pattern = 'git push -f' },
                @{ Command = 'git reset --hard'; Pattern = 'git reset --hard' },
                @{ Command = 'rm -rf /some/path'; Pattern = 'rm -rf' },
                @{ Command = 'Remove-Item -Recurse -Force C:\temp'; Pattern = 'Remove-Item -Recurse -Force' }
            )

            foreach ($case in $cases) {
                $matched = Get-BlockedPatternMatch -Command $case.Command
                $matched | Should -Be $case.Pattern
            }
        }

        It "produces a deny reason naming the matched pattern for a blocked command" {
            $reason = Get-BashBlockReason -Command 'rm -rf /some/path'
            $reason | Should -BeLike "*rm -rf*"
        }
    }

    Context "Get-BlockedPatternMatch / Get-BashBlockReason on safe commands" {
        It "returns `$null for safe commands" {
            Get-BlockedPatternMatch -Command 'git status' | Should -BeNullOrEmpty
            Get-BlockedPatternMatch -Command 'ls -la' | Should -BeNullOrEmpty
            Get-BashBlockReason -Command 'echo hello' | Should -BeNullOrEmpty
        }

        It "returns `$null for empty or null input" {
            Get-BlockedPatternMatch -Command '' | Should -BeNullOrEmpty
            Get-BashBlockReason -Command '' | Should -BeNullOrEmpty
        }
    }

    Context "Get-BashDenyDecision emits the PreToolUse deny schema" {
        It "carries hookEventName=PreToolUse and permissionDecision=deny after serialize-then-parse" {
            $reason = Get-BashBlockReason -Command 'git reset --hard'
            $decision = Get-BashDenyDecision -Reason $reason

            $parsed = $decision | ConvertTo-Json -Depth 5 | ConvertFrom-Json

            $parsed.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $parsed.hookSpecificOutput.permissionDecisionReason | Should -BeLike "*git reset --hard*"
        }

        It "does not carry the legacy top-level decision/reason keys" {
            $decision = Get-BashDenyDecision -Reason 'test reason'
            $decision.Contains('decision') | Should -BeFalse
            $decision.Contains('reason') | Should -BeFalse
        }
    }

    Context "Invoke-ValidateBashDecision routes JSON and positional input" {
        It "returns a deny decision from a blocked command in JSON 'command' field" {
            $decision = Invoke-ValidateBashDecision -ToolInputRaw '{"command":"rm -rf /tmp"}'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It "returns `$null (allow) for a safe command in JSON 'command' field" {
            Invoke-ValidateBashDecision -ToolInputRaw '{"command":"git status"}' | Should -BeNullOrEmpty
        }

        It "falls back to raw input when JSON is malformed and blocked" {
            $decision = Invoke-ValidateBashDecision -ToolInputRaw 'not-valid-json rm -rf /danger'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It "returns `$null (allow) when malformed JSON value is safe" {
            Invoke-ValidateBashDecision -ToolInputRaw 'not-json-but-safe' | Should -BeNullOrEmpty
        }

        It "uses the positional input when no tool input is provided" {
            $decision = Invoke-ValidateBashDecision -PositionalInput 'git push --force'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It "returns `$null (allow) when no input is provided" {
            Invoke-ValidateBashDecision | Should -BeNullOrEmpty
        }
    }

    Context "Hook source contains no deny-path exit 1" {
        It "does not use an 'exit 1' statement anywhere in the hook source" {
            # Match an exit-1 statement (optional leading whitespace then 'exit 1'),
            # which excludes the quoted 'exit 1' mention inside the doc comment.
            $lines = Get-Content -Path $script:ScriptPath
            $exitOneLines = $lines | Where-Object { $_ -match '^\s*exit\s+1\b' }
            $exitOneLines | Should -BeNullOrEmpty
        }
    }
}
