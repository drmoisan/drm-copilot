#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'enforce-promotion-mcp-only.ps1' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-promotion-mcp-only.ps1").Path
        . $script:UnderTest
    }

    Context 'tool input parsing' {
        It 'allows when CLAUDE_TOOL_INPUT is empty' {
            $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw ''
            $decision.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows when JSON has no command field' {
            $json = '{"other":"value"}'
            $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'throws on malformed JSON so the hook exits 1' {
            { Invoke-PromotionMcpOnlyDecision -ToolInputRaw '{not-json' } | Should -Throw
        }
    }

    Context 'legacy promotion-script tokens' {
        It 'blocks new-potential-entry.ps1' {
            $json = '{"command":"pwsh ./scripts/new-potential-entry.ps1 -ShortName foo"}'
            $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PROMOTION_MCP_ONLY_BLOCKED'
        }

        It 'blocks new_potential_bug_entry' {
            $json = '{"command":"some-tool new_potential_bug_entry --short bar"}'
            $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'blocks potential_to_issue' {
            $json = '{"command":"./bin/promote potential_to_issue --path foo.md"}'
            $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'blocks new_active_feature_folder' {
            $json = '{"command":"./bin/init new_active_feature_folder --name baz"}'
            $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }
    }

    Context 'gh CLI issue creation bypass' {
        It 'blocks gh issue create with a flag suffix' {
            $json = '{"command":"gh issue create --title \"foo\" --body \"bar\""}'
            $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'mcp__drm-copilot__new_potential_entry'
        }

        It 'blocks gh issue create with no flags' {
            $json = '{"command":"gh issue create"}'
            $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'blocks gh issue create case-insensitively' {
            $json = '{"command":"GH Issue Create --title hello"}'
            $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'blocks gh issue new' {
            $json = '{"command":"gh issue new --title \"foo\""}'
            $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'mcp__drm-copilot__new_potential_entry'
        }

        It 'blocks gh api repos/owner/repo/issues -X POST -f title=foo' {
            $json = '{"command":"gh api repos/owner/repo/issues -X POST -f title=foo"}'
            $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'mcp__drm-copilot__new_potential_entry'
        }

        It 'blocks gh api repos/owner/repo/issues --method POST' {
            $json = '{"command":"gh api repos/owner/repo/issues --method POST -f title=foo"}'
            $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'allows gh api repos/owner/repo/issues with no method (defaults to GET)' {
            $json = '{"command":"gh api repos/owner/repo/issues"}'
            $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows gh issue list' {
            $json = '{"command":"gh issue list"}'
            $decision = Invoke-PromotionMcpOnlyDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows gh issue view 10' {
            $json = '{"command":"gh issue view 10"}'
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

    Context 'script entrypoint' {
        BeforeAll {
            $script:HookPath = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-promotion-mcp-only.ps1").Path
            $script:PwshExe = if ($PSVersionTable.PSVersion.Major -ge 7 -and $PSEdition -eq 'Core') {
                (Get-Process -Id $PID).Path
            } else {
                (Get-Command pwsh -CommandType Application -ErrorAction Stop).Source
            }
        }

        It 'allows when CLAUDE_TOOL_INPUT is empty (exit 0, permissionDecision allow)' {
            $prev = $env:CLAUDE_TOOL_INPUT
            try {
                $env:CLAUDE_TOOL_INPUT = ''
                $out = & $script:PwshExe -NoProfile -File $script:HookPath
                $LASTEXITCODE | Should -Be 0
                ($out | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
            } finally {
                $env:CLAUDE_TOOL_INPUT = $prev
            }
        }

        It 'blocks gh issue create end-to-end (exit 0, permissionDecision deny)' {
            $prev = $env:CLAUDE_TOOL_INPUT
            try {
                $env:CLAUDE_TOOL_INPUT = '{"command":"gh issue create --title foo"}'
                $out = & $script:PwshExe -NoProfile -File $script:HookPath
                $LASTEXITCODE | Should -Be 0
                $decision = $out | ConvertFrom-Json
                $decision.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
                $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
                $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'mcp__drm-copilot__new_potential_entry'
            } finally {
                $env:CLAUDE_TOOL_INPUT = $prev
            }
        }

        It 'exits 1 on malformed JSON' {
            $prev = $env:CLAUDE_TOOL_INPUT
            try {
                $env:CLAUDE_TOOL_INPUT = '{not-json'
                $null = & $script:PwshExe -NoProfile -File $script:HookPath 2>&1
                $LASTEXITCODE | Should -Be 1
            } finally {
                $env:CLAUDE_TOOL_INPUT = $prev
            }
        }
    }
}
