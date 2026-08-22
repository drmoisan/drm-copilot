#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'enforce-promotion-mcp-only.ps1' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-promotion-mcp-only.ps1").Path
        . $script:UnderTest
    }

    Context 'tool input parsing' {
        It 'denies an empty payload as an envelope anomaly (fail closed)' {
            $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw ''
            $decision.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PROMOTION_MCP_ONLY_BLOCKED'
        }

        It 'allows when JSON has no command field' {
            $json = '{"tool_input":{"other":"value"}}'
            $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies unparseable JSON instead of throwing (exit 1 is non-blocking)' {
            $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw '{not-json'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'not parseable JSON'
        }
    }

    Context 'legacy promotion-script tokens' {
        It 'blocks new-potential-entry.ps1' {
            $json = '{"tool_input":{"command":"pwsh ./scripts/new-potential-entry.ps1 -ShortName foo"}}'
            $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PROMOTION_MCP_ONLY_BLOCKED'
        }

        It 'blocks new_potential_bug_entry' {
            $json = '{"tool_input":{"command":"some-tool new_potential_bug_entry --short bar"}}'
            $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'blocks potential_to_issue' {
            $json = '{"tool_input":{"command":"./bin/promote potential_to_issue --path foo.md"}}'
            $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'blocks new_active_feature_folder' {
            $json = '{"tool_input":{"command":"./bin/init new_active_feature_folder --name baz"}}'
            $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }
    }

    Context 'gh CLI issue creation bypass' {
        It 'blocks gh issue create with a flag suffix' {
            $json = '{"tool_input":{"command":"gh issue create --title \"foo\" --body \"bar\""}}'
            $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'mcp__drm-copilot__new_potential_entry'
        }

        It 'blocks gh issue create with no flags' {
            $json = '{"tool_input":{"command":"gh issue create"}}'
            $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'blocks gh issue create case-insensitively' {
            $json = '{"tool_input":{"command":"GH Issue Create --title hello"}}'
            $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'blocks gh issue new' {
            $json = '{"tool_input":{"command":"gh issue new --title \"foo\""}}'
            $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'mcp__drm-copilot__new_potential_entry'
        }

        It 'blocks gh api repos/owner/repo/issues -X POST -f title=foo' {
            $json = '{"tool_input":{"command":"gh api repos/owner/repo/issues -X POST -f title=foo"}}'
            $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'mcp__drm-copilot__new_potential_entry'
        }

        It 'blocks gh api repos/owner/repo/issues --method POST' {
            $json = '{"tool_input":{"command":"gh api repos/owner/repo/issues --method POST -f title=foo"}}'
            $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'allows gh api repos/owner/repo/issues with no method (defaults to GET)' {
            $json = '{"tool_input":{"command":"gh api repos/owner/repo/issues"}}'
            $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows gh issue list' {
            $json = '{"tool_input":{"command":"gh issue list"}}'
            $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows gh issue view 10' {
            $json = '{"tool_input":{"command":"gh issue view 10"}}'
            $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'helper functions' {
        It 'Test-PromotionBypassToken returns true for a forbidden token' {
            Test-PromotionBypassToken -CommandText 'pwsh ./new-potential-entry.ps1' | Should -BeTrue
        }

        It 'Test-PromotionBypassToken returns true for gh issue create' {
            Test-PromotionBypassToken -CommandText 'gh issue create --title foo' | Should -BeTrue
        }

        It 'Test-PromotionBypassToken returns false for an allowed command' {
            Test-PromotionBypassToken -CommandText 'gh issue list' | Should -BeFalse
        }

        It 'Get-PromotionMcpOnlyBlockDecision emits the PreToolUse deny schema after serialize-then-parse' {
            $d = Get-PromotionMcpOnlyBlockDecision
            $parsed = $d | ConvertTo-Json -Depth 5 | ConvertFrom-Json
            $parsed.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $parsed.hookSpecificOutput.permissionDecisionReason | Should -Match 'PROMOTION_MCP_ONLY_BLOCKED'
        }

        It 'Get-PromotionMcpOnlyAllowDecision emits the PreToolUse allow schema' {
            $d = Get-PromotionMcpOnlyAllowDecision
            $parsed = $d | ConvertTo-Json -Depth 5 | ConvertFrom-Json
            $parsed.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $parsed.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'Get-PromotionMcpOnlyGhIssueBlockedReason mentions the MCP promotion path' {
            Get-PromotionMcpOnlyGhIssueBlockedReason | Should -Match 'mcp__drm-copilot__new_potential_entry'
        }
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
            $emitted = Invoke-PromotionMcpOnlyEntryPoint -ReadPayload $emptyReader
            $emitted[-1] | Should -Be 0
            $emitted[-1] | Should -Not -Be 1
            $parsed = $emitted[0] | ConvertFrom-Json
            $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $parsed.hookSpecificOutput.permissionDecisionReason | Should -Match 'PROMOTION_MCP_ONLY_BLOCKED'
        }

        It 'returns exit code 0 and emits a deny for unparseable JSON' {
            $emitted = Invoke-PromotionMcpOnlyEntryPoint -ToolInputRaw '{not-json'
            $emitted[-1] | Should -Be 0
            $emitted[-1] | Should -Not -Be 1
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason |
                Should -Match 'not parseable JSON'
        }

        It 'returns exit code 0 and emits a deny for JSON with no tool_input key' {
            $emitted = Invoke-PromotionMcpOnlyEntryPoint -ToolInputRaw '{"session_id":"s1","tool_name":"Bash"}'
            $emitted[-1] | Should -Be 0
            $emitted[-1] | Should -Not -Be 1
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason |
                Should -Match 'no tool_input key'
        }

        It 'returns exit code 0 and emits a deny for a null tool_input' {
            $emitted = Invoke-PromotionMcpOnlyEntryPoint -ToolInputRaw '{"tool_name":"Bash","tool_input":null}'
            $emitted[-1] | Should -Be 0
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason |
                Should -Match 'tool_input is null'
        }

        It 'returns exit code 0 and emits a deny for a non-object tool_input' {
            $emitted = Invoke-PromotionMcpOnlyEntryPoint -ToolInputRaw '{"tool_name":"Bash","tool_input":"text"}'
            $emitted[-1] | Should -Be 0
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason |
                Should -Match 'not an object'
        }

        It 'denies a nested envelope carrying a direct promotion-script invocation' {
            $nested = '{"tool_name":"Bash","tool_input":{"command":"pwsh ./scripts/new-potential-entry.ps1 -ShortName foo"}}'
            $emitted = Invoke-PromotionMcpOnlyEntryPoint -ToolInputRaw $nested
            $emitted[-1] | Should -Be 0
            $parsed = $emitted[0] | ConvertFrom-Json
            $parsed.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'allows a nested envelope carrying an unrelated Bash command' {
            $nested = '{"tool_name":"Bash","tool_input":{"command":"git status --short"}}'
            $emitted = Invoke-PromotionMcpOnlyEntryPoint -ToolInputRaw $nested
            $emitted[-1] | Should -Be 0
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }
}
