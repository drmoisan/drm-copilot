#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Decision-surface coverage for the Codex promotion gate (issue #545, [P12-T9]).

.DESCRIPTION
    tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 drives
    the classifier through Invoke-PromotionMcpOnlyDecision with a command-bearing
    tool_input in every case. The three transport branches of that router, the default
    reason branch of the block-decision builder, the boolean wrapper, the stdin payload
    reader, and the entry point had no named case on the Codex side. This file supplies
    them.

    Entry-point cases: the hook's stdin-to-exit-code block is exercised in process by
    redirecting [System.Console]::In and [System.Console]::Error to in-memory readers and
    writers, which is the harness already established by
    tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1. The original readers are
    restored in a finally block. This hook reads no file and writes no file, so an
    entry-point case here touches nothing outside process memory.

    Determinism: every case drives a pure function or the in-process entry point with a
    literal fixture. No disk I/O, no child process, no temporary file, no live executable,
    no ambient state.
#>

Describe 'Codex enforce-promotion-mcp-only decision surface (issue #545)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = Join-Path $script:RepoRoot '.codex/hooks/enforce-promotion-mcp-only.ps1'
        . $script:UnderTest

        function ConvertTo-CodexPromotionStdinPayload {
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

        function Invoke-CodexPromotionEntryPoint {
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

    Context 'Test-PromotionBypassToken is the boolean projection of the reason resolver' {
        It 'reports true for a genuine promotion-script invocation' {
            Test-PromotionBypassToken -CommandText 'pwsh ./scripts/new-potential-entry.ps1 -ShortName foo' |
                Should -BeTrue
        }

        It 'reports false for an ordinary read command' {
            Test-PromotionBypassToken -CommandText 'gh issue list --limit 5' | Should -BeFalse
        }
    }

    Context 'Get-PromotionMcpOnlyBlockDecision resolves its reason' {
        It 'falls back to the legacy promotion-script reason when no reason is supplied' {
            $decision = Get-PromotionMcpOnlyBlockDecision

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Be (Get-PromotionMcpOnlyBlockedReason)
        }

        It 'carries the supplied reason verbatim when one is supplied' {
            $decision = Get-PromotionMcpOnlyBlockDecision -Reason (Get-PromotionMcpOnlyGhIssueBlockedReason)

            $decision.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $decision.hookSpecificOutput.permissionDecisionReason |
                Should -Be (Get-PromotionMcpOnlyGhIssueBlockedReason)
        }
    }

    Context 'Get-PromotionMcpOnlyAllowDecision builds the allow envelope' {
        It 'carries hookEventName PreToolUse and permissionDecision allow with no reason key' {
            $decision = Get-PromotionMcpOnlyAllowDecision

            $decision.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
            @($decision.hookSpecificOutput.Keys) | Should -Not -Contain 'permissionDecisionReason'
        }
    }

    Context 'Invoke-PromotionMcpOnlyDecision transport branches' {
        It 'allows when the mapped tool_input is absent' {
            # A non-Bash invocation maps to no tool_input and cannot bypass promotion flow.
            $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw ''

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows when the mapped tool_input carries no command text' {
            $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw '{"file_path":"README.md","command":""}'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'throws a named error for malformed mapped tool_input JSON' {
            { Invoke-PromotionMcpOnlyDecision -ToolInputRaw '{not-json' } |
                Should -Throw -ExpectedMessage 'enforce-promotion-mcp-only received malformed mapped tool_input JSON:*'
        }
    }

    Context 'ConvertFrom-CodexPromotionHookPayload validates the stdin envelope' {
        It 'throws for payload text that is only whitespace' {
            { ConvertFrom-CodexPromotionHookPayload -PayloadRaw '   ' } |
                Should -Throw -ExpectedMessage 'enforce-promotion-mcp-only hook input is empty.'
        }

        It 'throws for malformed JSON' {
            { ConvertFrom-CodexPromotionHookPayload -PayloadRaw '{not-json' } |
                Should -Throw -ExpectedMessage 'enforce-promotion-mcp-only hook input is malformed JSON:*'
        }

        It 'throws when tool_input is absent from an otherwise well-formed envelope' {
            { ConvertFrom-CodexPromotionHookPayload -PayloadRaw '{"hook_event_name":"PreToolUse","tool_name":"Bash"}' } |
                Should -Throw -ExpectedMessage 'enforce-promotion-mcp-only hook input is missing tool_input.'
        }

        It 'throws when the envelope is not a PreToolUse event' {
            $payload = ConvertTo-CodexPromotionStdinPayload -Command 'git status' -HookEventName 'PostToolUse'

            { ConvertFrom-CodexPromotionHookPayload -PayloadRaw $payload } |
                Should -Throw -ExpectedMessage 'enforce-promotion-mcp-only requires a PreToolUse Bash payload.'
        }

        It 'throws when the tool name is not Bash' {
            $payload = ConvertTo-CodexPromotionStdinPayload -Command 'git status' -ToolName 'Write'

            { ConvertFrom-CodexPromotionHookPayload -PayloadRaw $payload } |
                Should -Throw -ExpectedMessage 'enforce-promotion-mcp-only requires a PreToolUse Bash payload.'
        }

        It 'returns the parsed payload for a well-formed PreToolUse Bash envelope' {
            $payload = ConvertFrom-CodexPromotionHookPayload -PayloadRaw (ConvertTo-CodexPromotionStdinPayload -Command 'git status')

            $payload.tool_input.command | Should -Be 'git status'
        }
    }

    Context 'the hook entry point reads stdin and reports through the exit code' {
        It 'writes the deny envelope and exits 0 for a gh issue create on stdin' {
            $result = Invoke-CodexPromotionEntryPoint `
                -HookPath $script:UnderTest `
                -PayloadRaw (ConvertTo-CodexPromotionStdinPayload -Command 'gh issue create --title "x"')

            $result.ExitCode | Should -Be 0
            $result.Stderr | Should -BeNullOrEmpty
            $decision = $result.Stdout | ConvertFrom-Json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PROMOTION_MCP_ONLY_BLOCKED'
        }

        It 'writes nothing and exits 0 for an allowed command on stdin' {
            $result = Invoke-CodexPromotionEntryPoint `
                -HookPath $script:UnderTest `
                -PayloadRaw (ConvertTo-CodexPromotionStdinPayload -Command 'gh issue list --limit 5')

            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -BeNullOrEmpty
            $result.Stderr | Should -BeNullOrEmpty
        }

        It 'writes the reason to stderr and exits 2 for malformed stdin' {
            $result = Invoke-CodexPromotionEntryPoint -HookPath $script:UnderTest -PayloadRaw '{not-json'

            $result.ExitCode | Should -Be 2
            $result.Stdout | Should -BeNullOrEmpty
            $result.Stderr | Should -Match 'enforce-promotion-mcp-only hook input is malformed JSON'
        }

        It 'fails closed with exit 2 and the empty-input reason for whitespace-only stdin' {
            $result = Invoke-CodexPromotionEntryPoint -HookPath $script:UnderTest -PayloadRaw "  `n  "

            $result.ExitCode | Should -Be 2
            $result.Stdout | Should -BeNullOrEmpty
            $result.Stderr | Should -Match 'enforce-promotion-mcp-only hook input is empty\.'
        }
    }
}
