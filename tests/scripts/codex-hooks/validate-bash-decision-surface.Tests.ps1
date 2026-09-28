#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Decision-surface coverage for the Codex validate-bash hook (issue #545, [P12-T9]).

.DESCRIPTION
    tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1 carries the three
    spec Test Strategy rows AT-8, AT-9, and AT-10 and drives one function. Every other
    function in .codex/hooks/validate-bash.ps1 -- the token-run comparison primitive, the
    structural git classifier's two remaining returns, the reason builder, the deny-envelope
    builder, the transport resolver, the decision router, and the payload reader -- had no
    named case on the Codex side. This file supplies them.

    The Claude sibling tests/scripts/claude-hooks/validate-bash.Tests.ps1 covers the same
    surface on its own copy; the scenario set here follows it, adjusted for the two Codex
    idiom differences: the Codex copy carries no cd-chained read-command leg, and it reads
    its own stdin payload through ConvertFrom-CodexBashHookPayload rather than through a
    shared Claude payload module.

    Entry-point cases: the hook's stdin-to-exit-code block is exercised in process by
    redirecting [System.Console]::In and [System.Console]::Error to in-memory readers and
    writers, which is the harness already established by
    tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1. The original readers are
    restored in a finally block. This hook touches no file and no environment variable, so
    an entry-point case here reads and writes nothing outside process memory.

    Determinism: every case drives a pure function or the in-process entry point with a
    literal fixture. No disk I/O, no child process, no temporary file, no live executable,
    no ambient state.
#>

Describe 'Codex validate-bash decision surface (issue #545)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = Join-Path $script:RepoRoot '.codex/hooks/validate-bash.ps1'
        . $script:UnderTest

        function ConvertTo-CodexBashToolInput {
            <# Builds the mapped tool_input JSON the transport resolver consumes. #>
            param([Parameter(Mandatory)][AllowEmptyString()][string] $Command)

            return (@{ command = $Command } | ConvertTo-Json -Compress -Depth 3)
        }

        function ConvertTo-CodexBashStdinPayload {
            <# Builds the full Codex PreToolUse stdin envelope the hook reads. #>
            param(
                [Parameter(Mandatory)][AllowEmptyString()][string] $Command,
                [string] $HookEventName = 'PreToolUse',
                [string] $ToolName = 'Bash'
            )

            return (@{
                    hook_event_name = $HookEventName
                    tool_name       = $ToolName
                    tool_input      = @{ command = $Command }
                } | ConvertTo-Json -Compress -Depth 5)
        }

        function Invoke-CodexValidateBashEntryPoint {
            <#
                Runs the hook's entry point in process against an in-memory stdin reader
                and captures its stdout, stderr, and exit code. The console readers and
                writers are restored in finally, so no later case observes a redirected
                console.
            #>
            param(
                [Parameter(Mandatory)][string] $HookPath,
                [Parameter(Mandatory)][AllowEmptyString()][string] $PayloadRaw
            )

            $originalIn = [System.Console]::In
            $originalError = [System.Console]::Error
            $errorWriter = [System.IO.StringWriter]::new()
            try {
                [System.Console]::SetIn([System.IO.StringReader]::new($PayloadRaw))
                [System.Console]::SetError($errorWriter)
                $stdout = & $HookPath
                return [pscustomobject]@{
                    ExitCode = $LASTEXITCODE
                    Stdout   = ($stdout -join "`n")
                    Stderr   = $errorWriter.ToString()
                }
            } finally {
                [System.Console]::SetIn($originalIn)
                [System.Console]::SetError($originalError)
            }
        }
    }

    Context 'Test-BlockedPatternTokenRun is a whole-token contiguous-run comparison' {
        It 'reports a run that begins part way through the token list' {
            # The literal need not start the command: 'sudo' precedes it here.
            Test-BlockedPatternTokenRun -Token @('sudo', 'rm', '-rf', 'build') -PatternToken @('rm', '-rf') |
                Should -BeTrue
        }

        It 'reports no run when the pattern tokens are present but not contiguous' {
            Test-BlockedPatternTokenRun -Token @('rm', 'build', '-rf') -PatternToken @('rm', '-rf') |
                Should -BeFalse -Because 'the two tokens must sit next to each other to form a run'
        }

        It 'reports no run when the token list is shorter than the pattern' {
            # The length guard returns before the scan loop runs at all.
            Test-BlockedPatternTokenRun -Token @('rm') -PatternToken @('rm', '-rf') |
                Should -BeFalse
        }

        It 'reports no run when the last candidate start position fails on its final token' {
            Test-BlockedPatternTokenRun -Token @('git', 'push', 'origin') -PatternToken @('push', '--force') |
                Should -BeFalse
        }
    }

    Context 'Get-BlockedPatternMatch literal leg' {
        It 'returns the rm -rf literal for a whole-token match' {
            Get-BlockedPatternMatch -Command 'rm -rf build' | Should -Be 'rm -rf'
        }

        It 'returns the Remove-Item literal for its three-token spelling' {
            Get-BlockedPatternMatch -Command 'Remove-Item -Recurse -Force ./dist' |
                Should -Be 'Remove-Item -Recurse -Force'
        }

        It 'returns the four-token git push origin --force literal ahead of any structural value' {
            # Declaration order puts 'git push --force' before 'git push origin --force',
            # but the shorter literal is not a contiguous run of this command's tokens,
            # so the longer literal is the one that matches.
            Get-BlockedPatternMatch -Command 'git push origin --force' |
                Should -Be 'git push origin --force'
        }

        It 'returns null for an empty command without scanning a segment' {
            Get-BlockedPatternMatch -Command '' | Should -BeNullOrEmpty
        }

        It 'returns null for a null command' {
            Get-BlockedPatternMatch -Command $null | Should -BeNullOrEmpty
        }

        It 'matches a literal carried on the second segment of a chained command' {
            Get-BlockedPatternMatch -Command 'git status && rm -rf node_modules' | Should -Be 'rm -rf'
        }
    }

    Context 'Get-BlockedStructuralGitMatch classifies relocating spellings' {
        It 'returns the git push -f literal for a relocating short force spelling' {
            Get-BlockedPatternMatch -Command 'git -C ../wt push -f origin HEAD' | Should -Be 'git push -f'
        }

        It 'returns the git reset --hard literal for a relocating hard reset' {
            Get-BlockedPatternMatch -Command 'git -C ../wt reset --hard HEAD~1' | Should -Be 'git reset --hard'
        }

        It 'allows a relocating soft reset because --hard is the conjoined flag' {
            Get-BlockedPatternMatch -Command 'git -C ../wt reset --soft HEAD~1' |
                Should -BeNullOrEmpty -Because 'the flag conjunction is required, not the bare subcommand'
        }

        It 'allows a relocating push that carries no force flag' {
            Get-BlockedPatternMatch -Command 'git -C ../wt push origin HEAD' | Should -BeNullOrEmpty
        }

        It 'reports no structural match directly for a non-git command word' {
            Get-BlockedStructuralGitMatch -SegmentText 'gh pr merge 410 --merge' -Token @('gh', 'pr', 'merge', '410', '--merge') |
                Should -BeNullOrEmpty
        }
    }

    Context 'Get-BashBlockReason wraps the matched literal in the deny sentence' {
        It 'names the matched pattern in the reason text' {
            Get-BashBlockReason -Command 'git reset --hard HEAD~1' |
                Should -Be "Blocked dangerous command pattern detected: 'git reset --hard'"
        }

        It 'returns null for a safe command' {
            Get-BashBlockReason -Command 'git status --porcelain' | Should -BeNullOrEmpty
        }
    }

    Context 'Get-BashDenyDecision builds the PreToolUse deny envelope' {
        It 'carries hookEventName PreToolUse, permissionDecision deny, and the supplied reason' {
            $decision = Get-BashDenyDecision -Reason 'a specific reason'

            $decision.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Be 'a specific reason'
        }

        It 'carries no legacy top-level decision or reason key' {
            $decision = Get-BashDenyDecision -Reason 'a specific reason'

            @($decision.Keys) | Should -Be @('hookSpecificOutput')
        }
    }

    Context 'Get-BashCommandToCheck resolves the command across both transports' {
        It 'reads the command from well-formed mapped tool_input JSON' {
            Get-BashCommandToCheck -ToolInputRaw (ConvertTo-CodexBashToolInput -Command 'git status') |
                Should -Be 'git status'
        }

        It 'falls back to the positional input when the tool_input JSON carries an empty command' {
            # The command key is present and empty rather than absent, so the case asserts
            # the falsy-value fall-through without depending on how a missing property
            # resolves under any strict-mode setting a sibling suite may have established.
            Get-BashCommandToCheck -ToolInputRaw '{"file_path":"README.md","command":""}' -PositionalInput 'git status' |
                Should -Be 'git status'
        }

        It 'treats unparseable raw tool input as the command text itself' {
            # AC-5 pinned exception, matching the Claude sibling: a transport that cannot be
            # parsed is still scanned, so a dangerous command cannot hide behind bad JSON.
            Get-BashCommandToCheck -ToolInputRaw 'rm -rf build' | Should -Be 'rm -rf build'
        }

        It 'returns an empty string when no transport carries a command' {
            Get-BashCommandToCheck -ToolInputRaw '' -PositionalInput '' | Should -Be ''
        }
    }

    Context 'Invoke-ValidateBashDecision routes transport to decision' {
        It 'returns a deny decision for a blocked command in the mapped tool_input' {
            $decision = Invoke-ValidateBashDecision -ToolInputRaw (ConvertTo-CodexBashToolInput -Command 'rm -rf build')

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Be "Blocked dangerous command pattern detected: 'rm -rf'"
        }

        It 'returns null for a safe command in the mapped tool_input' {
            Invoke-ValidateBashDecision -ToolInputRaw (ConvertTo-CodexBashToolInput -Command 'git status') |
                Should -BeNullOrEmpty
        }

        It 'returns null when every transport is empty' {
            # A denylist hook allows on empty input rather than raising an envelope anomaly.
            Invoke-ValidateBashDecision -ToolInputRaw '' -PositionalInput '' | Should -BeNullOrEmpty
        }

        It 'denies a blocked command supplied only through the positional transport' {
            $decision = Invoke-ValidateBashDecision -ToolInputRaw '' -PositionalInput 'git push --force origin main'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }
    }

    Context 'ConvertFrom-CodexBashHookPayload validates the stdin envelope' {
        It 'throws for payload text that is only whitespace' {
            { ConvertFrom-CodexBashHookPayload -PayloadRaw '   ' } |
                Should -Throw -ExpectedMessage 'validate-bash hook input is empty.'
        }

        It 'throws for malformed JSON' {
            { ConvertFrom-CodexBashHookPayload -PayloadRaw '{not-json' } |
                Should -Throw -ExpectedMessage 'validate-bash hook input is malformed JSON:*'
        }

        It 'throws when tool_input is absent from an otherwise well-formed envelope' {
            { ConvertFrom-CodexBashHookPayload -PayloadRaw '{"hook_event_name":"PreToolUse","tool_name":"Bash"}' } |
                Should -Throw -ExpectedMessage 'validate-bash hook input is missing tool_input.'
        }

        It 'throws when the envelope is not a PreToolUse Bash event' {
            $payload = ConvertTo-CodexBashStdinPayload -Command 'git status' -HookEventName 'PostToolUse'

            { ConvertFrom-CodexBashHookPayload -PayloadRaw $payload } |
                Should -Throw -ExpectedMessage 'validate-bash requires a PreToolUse Bash payload.'
        }

        It 'throws when the tool name is not Bash' {
            $payload = ConvertTo-CodexBashStdinPayload -Command 'git status' -ToolName 'Write'

            { ConvertFrom-CodexBashHookPayload -PayloadRaw $payload } |
                Should -Throw -ExpectedMessage 'validate-bash requires a PreToolUse Bash payload.'
        }

        It 'returns the parsed payload for a well-formed PreToolUse Bash envelope' {
            $payload = ConvertFrom-CodexBashHookPayload -PayloadRaw (ConvertTo-CodexBashStdinPayload -Command 'git status')

            $payload.tool_input.command | Should -Be 'git status'
        }
    }

    Context 'the hook entry point reads stdin and reports through the exit code' {
        It 'writes the deny envelope and exits 0 for a blocked command on stdin' {
            $result = Invoke-CodexValidateBashEntryPoint `
                -HookPath $script:UnderTest `
                -PayloadRaw (ConvertTo-CodexBashStdinPayload -Command 'git reset --hard HEAD~1')

            $result.ExitCode | Should -Be 0
            $result.Stderr | Should -BeNullOrEmpty
            $decision = $result.Stdout | ConvertFrom-Json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Be "Blocked dangerous command pattern detected: 'git reset --hard'"
        }

        It 'writes nothing and exits 0 for a safe command on stdin' {
            $result = Invoke-CodexValidateBashEntryPoint `
                -HookPath $script:UnderTest `
                -PayloadRaw (ConvertTo-CodexBashStdinPayload -Command 'git status --porcelain')

            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -BeNullOrEmpty
            $result.Stderr | Should -BeNullOrEmpty
        }

        It 'writes the reason to stderr and exits 2 for malformed stdin' {
            $result = Invoke-CodexValidateBashEntryPoint -HookPath $script:UnderTest -PayloadRaw '{not-json'

            $result.ExitCode | Should -Be 2
            $result.Stdout | Should -BeNullOrEmpty
            $result.Stderr | Should -Match 'validate-bash hook input is malformed JSON'
        }

        It 'fails closed with exit 2 and the empty-input reason for whitespace-only stdin' {
            # Whitespace rather than the empty string, so the payload binds and the hook's
            # own IsNullOrWhiteSpace guard produces the reason. An empty string would fail
            # parameter binding first and surface a binder message instead.
            $result = Invoke-CodexValidateBashEntryPoint -HookPath $script:UnderTest -PayloadRaw "  `n  "

            $result.ExitCode | Should -Be 2
            $result.Stdout | Should -BeNullOrEmpty
            $result.Stderr | Should -Match 'validate-bash hook input is empty\.'
        }
    }
}
