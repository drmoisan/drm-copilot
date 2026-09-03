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

    Context "Invoke-ValidateBashDecision routes the nested envelope and positional input" {
        It "returns a deny decision from a blocked command in the nested tool_input" {
            $nested = '{"tool_name":"Bash","tool_input":{"command":"rm -rf /tmp"}}'
            $decision = Invoke-ValidateBashDecision -ToolInputRaw $nested
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
        }

        It "returns `$null (allow) for a safe command in the nested tool_input" {
            $nested = '{"tool_name":"Bash","tool_input":{"command":"git status"}}'
            Invoke-ValidateBashDecision -ToolInputRaw $nested | Should -BeNullOrEmpty
        }

        It "uses the positional input when no tool input is provided" {
            $decision = Invoke-ValidateBashDecision -PositionalInput 'git push --force'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It "returns `$null (allow) when no input is provided" {
            Invoke-ValidateBashDecision | Should -BeNullOrEmpty
        }
    }

    Context "AC-5 pinned exception: allow-on-empty" {
        # validate-bash.ps1 is a dangerous-command denylist, not a receipt gate, so it
        # keeps allowing an empty payload where every other PreToolUse hook now denies.
        It "returns `$null (allow) for an empty payload rather than an envelope-anomaly deny" {
            Invoke-ValidateBashDecision -ToolInputRaw '' | Should -BeNullOrEmpty
        }

        It "returns `$null (allow) when every transport is empty" {
            $raw = Read-ClaudeHookRawPayload `
                -ReadStandardInput { '' } `
                -TestStandardInputRedirected { $true } `
                -HookInputFallback '' `
                -ToolInputFallback ''
            Invoke-ValidateBashDecision -ToolInputRaw $raw | Should -BeNullOrEmpty
        }
    }

    Context "AC-5 pinned exception: unparseable raw text is the command text" {
        # Preserves the documented manual/CLI usage, where the operator supplies the
        # command directly rather than a JSON envelope.
        It "denies when unparseable raw input carries a blocked pattern" {
            $decision = Invoke-ValidateBashDecision -ToolInputRaw 'not-valid-json rm -rf /danger'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike '*rm -rf*'
        }

        It "returns `$null (allow) when the unparseable raw input is safe" {
            Invoke-ValidateBashDecision -ToolInputRaw 'not-json-but-safe' | Should -BeNullOrEmpty
        }
    }

    Context "shared payload reader is used for transport" {
        It "imports the shared payload module" {
            $lines = Get-Content -Path $script:ScriptPath -Raw
            $lines | Should -BeLike '*HookPayload.psm1*'
            $lines | Should -BeLike '*Read-ClaudeHookRawPayload*'
        }

        It "extracts the command from the nested tool_input, not the flat root" {
            $nested = '{"tool_name":"Bash","tool_input":{"command":"git reset --hard"}}'
            Get-BashCommandToCheck -ToolInputRaw $nested | Should -Be 'git reset --hard'
        }

        It "returns an empty command for a well-formed envelope whose tool_input has no command" {
            $nested = '{"tool_name":"Write","tool_input":{"file_path":"src/x.ts"}}'
            Get-BashCommandToCheck -ToolInputRaw $nested | Should -Be ''
        }
    }

    Context "Get-CdChainedReadCommandMatch detects cd-chained read commands" {
        # Claude Code's Bash permission engine resolves grep/cat/head/tail/less/
        # more/sed -n/awk against Read() rules and cannot statically resolve the
        # working directory once a preceding 'cd' has run in the same command
        # line, so it always requires manual approval regardless of any allow
        # rule. This forbidden-pattern check lets the agent self-correct instead
        # of stalling on a human approval prompt.
        It "matches every read-command family chained after cd via '&&' or ';'" {
            $cases = @(
                @{ Command = 'cd /tmp/x && grep -n test file.txt'; Op = 'grep' },
                @{ Command = 'cd /tmp/x && cat file.txt'; Op = 'cat' },
                @{ Command = 'cd /tmp/x; tail -f log.txt'; Op = 'tail' },
                @{ Command = 'cd /tmp/x && head -20 file.txt'; Op = 'head' },
                @{ Command = 'cd /tmp/x && less file.txt'; Op = 'less' },
                @{ Command = 'cd /tmp/x && more file.txt'; Op = 'more' },
                @{ Command = 'cd /tmp/x && awk "{print}" file.txt'; Op = 'awk' },
                @{ Command = 'cd /tmp/x && sed -n 1,5p file.txt'; Op = 'sed -n' }
            )

            foreach ($case in $cases) {
                $matched = Get-CdChainedReadCommandMatch -Command $case.Command
                $matched | Should -Be $case.Op
            }
        }

        It "matches even when the chained command's own path argument is absolute" {
            Get-CdChainedReadCommandMatch -Command 'cd /tmp/x && grep -n test /tmp/x/file.txt' | Should -Be 'grep'
        }

        It "returns `$null for a bare read command with no preceding cd" {
            Get-CdChainedReadCommandMatch -Command 'grep -n pattern /abs/path/file' | Should -BeNullOrEmpty
        }

        It "returns `$null for a cd chained with a non-read-command (no false positive on common toolchain invocations)" {
            Get-CdChainedReadCommandMatch -Command 'cd extensions/drm-copilot && npm test' | Should -BeNullOrEmpty
            Get-CdChainedReadCommandMatch -Command 'cd extensions/drm-copilot && npm ci' | Should -BeNullOrEmpty
            Get-CdChainedReadCommandMatch -Command 'cd extensions/drm-copilot && npx jest' | Should -BeNullOrEmpty
        }

        It "returns `$null for empty or null input" {
            Get-CdChainedReadCommandMatch -Command '' | Should -BeNullOrEmpty
            Get-CdChainedReadCommandMatch -Command $null | Should -BeNullOrEmpty
        }

        It "produces a deny reason via Get-BashBlockReason naming the matched read command" {
            $reason = Get-BashBlockReason -Command 'cd /tmp/x && grep -n test file.txt'
            $reason | Should -BeLike "*cd ... && grep*"
            $reason | Should -BeLike "*Read()*"
        }

        It "the dangerous-pattern denylist takes precedence when a command matches both" {
            $reason = Get-BashBlockReason -Command 'cd /tmp/x && rm -rf /tmp/x/file.txt'
            $reason | Should -BeLike "*Blocked dangerous command pattern*"
        }

        It "denies through Invoke-ValidateBashDecision for a cd-chained read command in the nested tool_input" {
            $nested = '{"tool_name":"Bash","tool_input":{"command":"cd /tmp/x && grep -n test file.txt"}}'
            $decision = Invoke-ValidateBashDecision -ToolInputRaw $nested
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike "*cd ... && grep*"
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
