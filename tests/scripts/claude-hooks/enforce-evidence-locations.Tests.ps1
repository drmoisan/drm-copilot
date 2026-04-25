#Requires -Version 7.0
<#
.SYNOPSIS
    Pester tests for the enforce-evidence-locations.ps1 PreToolUse hook.
#>

BeforeAll {
    # Dot-source the hook to load its functions without executing the entrypoint block.
    $hookPath = Join-Path $PSScriptRoot '../../../.claude/hooks/enforce-evidence-locations.ps1'
    . $hookPath
}

Describe 'enforce-evidence-locations.ps1' {
    Context 'forbidden evidence locations' {
        It 'blocks writes to artifacts/baselines/ (forbidden prefix)' {
            # Arrange
            $env:CLAUDE_TOOL_INPUT = '{"file_path":"artifacts/baselines/foo.md"}'

            # Act
            $result = Invoke-EvidenceLocationDecision -ToolInputRaw $env:CLAUDE_TOOL_INPUT

            # Assert — forbidden path must produce a block decision with the required reason token
            $result.decision | Should -Be 'block'
            $result.reason | Should -Match 'EVIDENCE_LOCATION_BLOCKED'
        }
    }

    Context 'allowed artifacts/ sub-paths' {
        It 'allows writes to artifacts/orchestration/ (permitted orchestration path)' {
            # Arrange
            $env:CLAUDE_TOOL_INPUT = '{"file_path":"artifacts/orchestration/orchestrator-state.json"}'

            # Act
            $result = Invoke-EvidenceLocationDecision -ToolInputRaw $env:CLAUDE_TOOL_INPUT

            # Assert
            $result.decision | Should -Be 'allow'
        }

        It 'allows writes to artifacts/research/ (permitted research path)' {
            # Arrange
            $env:CLAUDE_TOOL_INPUT = '{"file_path":"artifacts/research/notes.md"}'

            # Act
            $result = Invoke-EvidenceLocationDecision -ToolInputRaw $env:CLAUDE_TOOL_INPUT

            # Assert
            $result.decision | Should -Be 'allow'
        }
    }

    Context 'canonical evidence paths' {
        It 'allows writes to <FEATURE>/evidence/baseline/ (canonical evidence path)' {
            # Arrange: a full canonical evidence path inside a feature folder
            $env:CLAUDE_TOOL_INPUT = '{"file_path":"docs/features/active/my-feature/evidence/baseline/baseline.md"}'

            # Act
            $result = Invoke-EvidenceLocationDecision -ToolInputRaw $env:CLAUDE_TOOL_INPUT

            # Assert
            $result.decision | Should -Be 'allow'
        }
    }

    Context 'source code paths' {
        It 'allows writes to source code files (non-artifacts path)' {
            # Arrange
            $env:CLAUDE_TOOL_INPUT = '{"file_path":"src/hello-typescript.ts"}'

            # Act
            $result = Invoke-EvidenceLocationDecision -ToolInputRaw $env:CLAUDE_TOOL_INPUT

            # Assert
            $result.decision | Should -Be 'allow'
        }
    }
}
