#Requires -Version 7.0
<#
.SYNOPSIS
    Pester tests for the enforce-promotion-mcp-only.ps1 PreToolUse hook.
#>

BeforeAll {
    # Dot-source the hook so the test file can exercise the helper functions
    # without executing the script entrypoint.
    $hookPath = Join-Path $PSScriptRoot '../../../.claude/hooks/enforce-promotion-mcp-only.ps1'
    . $hookPath
    $script:ExpectedReason = Get-PromotionMcpOnlyBlockedReason
}

Describe 'enforce-promotion-mcp-only.ps1' {
    Context 'benign Bash commands' {
        It 'allows benign Bash commands' {
            # Arrange
            $env:CLAUDE_TOOL_INPUT = '{"command":"git status"}'

            # Act
            $result = Invoke-PromotionMcpOnlyDecision -ToolInputRaw $env:CLAUDE_TOOL_INPUT

            # Assert
            $result.decision | Should -Be 'allow'
        }
    }

    Context 'forbidden promotion-script tokens' {
        It 'blocks new-potential-entry.ps1' {
            # Arrange
            $env:CLAUDE_TOOL_INPUT = '{"command":"pwsh -File scripts/dev-tools/new-potential-entry.ps1 -ShortName demo"}'

            # Act
            $result = Invoke-PromotionMcpOnlyDecision -ToolInputRaw $env:CLAUDE_TOOL_INPUT

            # Assert
            $result.decision | Should -Be 'block'
            $result.reason | Should -Be $script:ExpectedReason
        }

        It 'blocks new_potential_bug_entry' {
            # Arrange
            $env:CLAUDE_TOOL_INPUT = '{"command":"poetry run python -m scripts.dev_tools.new_potential_bug_entry --short-name demo"}'

            # Act
            $result = Invoke-PromotionMcpOnlyDecision -ToolInputRaw $env:CLAUDE_TOOL_INPUT

            # Assert
            $result.decision | Should -Be 'block'
            $result.reason | Should -Be $script:ExpectedReason
        }

        It 'blocks potential_to_issue' {
            # Arrange
            $env:CLAUDE_TOOL_INPUT = '{"command":"poetry run python -m scripts.dev_tools.potential_to_issue --potential-path docs/features/potential/demo.md"}'

            # Act
            $result = Invoke-PromotionMcpOnlyDecision -ToolInputRaw $env:CLAUDE_TOOL_INPUT

            # Assert
            $result.decision | Should -Be 'block'
            $result.reason | Should -Be $script:ExpectedReason
        }

        It 'blocks new_active_feature_folder' {
            # Arrange
            $env:CLAUDE_TOOL_INPUT = '{"command":"poetry run python -m scripts.dev_tools.new_active_feature_folder --feature-name demo"}'

            # Act
            $result = Invoke-PromotionMcpOnlyDecision -ToolInputRaw $env:CLAUDE_TOOL_INPUT

            # Assert
            $result.decision | Should -Be 'block'
            $result.reason | Should -Be $script:ExpectedReason
        }
    }
}
