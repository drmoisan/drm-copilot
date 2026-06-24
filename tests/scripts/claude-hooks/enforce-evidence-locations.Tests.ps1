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

        It 'blocks writes to artifacts/research/ (retired research path)' {
            # Arrange — research is no longer a permitted artifacts/ sub-path;
            # it must now resolve to a tracked docs/ root and is blocked here.
            $env:CLAUDE_TOOL_INPUT = '{"file_path":"artifacts/research/notes.md"}'

            # Act
            $result = Invoke-EvidenceLocationDecision -ToolInputRaw $env:CLAUDE_TOOL_INPUT

            # Assert
            $result.decision | Should -Be 'block'
            $result.reason | Should -Match 'EVIDENCE_LOCATION_BLOCKED'
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

        It 'allows writes to docs/features/ research subfolder (new canonical feature research path)' {
            # Arrange: feature-associated research now resolves to a tracked docs/ root
            $env:CLAUDE_TOOL_INPUT = '{"file_path":"docs/features/active/my-feature/research/2026-06-24T13-02-foo-research.md"}'

            # Act
            $result = Invoke-EvidenceLocationDecision -ToolInputRaw $env:CLAUDE_TOOL_INPUT

            # Assert
            $result.decision | Should -Be 'allow'
        }

        It 'allows writes to docs/research/ (new canonical one-off research path)' {
            # Arrange: one-off research now resolves to the tracked docs/research/ root
            $env:CLAUDE_TOOL_INPUT = '{"file_path":"docs/research/2026-06-24T13-02-foo-research.md"}'

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

    Context 'input edge cases' {
        It 'allows when the tool input is empty (no file_path to evaluate)' {
            # Arrange — empty raw input represents a non-file tool call
            $result = Invoke-EvidenceLocationDecision -ToolInputRaw ''

            # Assert
            $result.decision | Should -Be 'allow'
        }

        It 'allows when the JSON has no file_path field' {
            # Arrange — valid JSON object that carries no file_path
            $result = Invoke-EvidenceLocationDecision -ToolInputRaw '{"other":"value"}'

            # Assert
            $result.decision | Should -Be 'allow'
        }

        It 'throws on malformed JSON input' {
            # Arrange — unparseable payload triggers the hard-failure path
            { Invoke-EvidenceLocationDecision -ToolInputRaw '{ not valid json' } |
                Should -Throw '*malformed JSON*'
        }
    }

    Context 'entry-point dispatch' {
        It 'returns exit code 0 and emits allow JSON for an allowed path' {
            # Arrange — a representative allowed file_path
            $allowedJson = '{"file_path":"src/hello-typescript.ts"}'

            # Act — the function emits the JSON on the output stream and returns the
            # int exit code as the final pipeline element; collect both.
            $emitted = @(Invoke-EvidenceLocationEntryPoint -ToolInputRaw $allowedJson)
            $code = $emitted[-1]
            $stdout = ($emitted[0..($emitted.Count - 2)] -join '')

            # Assert — exit code is 0 and emitted JSON is the compact allow decision
            $code | Should -Be 0
            $stdout | Should -Match '"decision":"allow"'
        }

        It 'returns exit code 1 and writes a malformed-JSON error for unparseable input' {
            # Arrange — unparseable payload triggers the hard-failure path
            $errorRecords = $null

            # Act — capture the error stream while collecting the function output
            $emitted = @(Invoke-EvidenceLocationEntryPoint -ToolInputRaw '{ not valid json' -ErrorAction SilentlyContinue -ErrorVariable errorRecords)
            $code = $emitted[-1]

            # Assert — exit code is 1 and an error record matching the malformed-JSON message was written
            $code | Should -Be 1
            $errorRecords | Should -Not -BeNullOrEmpty
            ($errorRecords | Out-String) | Should -Match 'malformed JSON'
        }

        It 'returns exit code 0 and emits block JSON for a forbidden path' {
            # Arrange — a retired/forbidden artifacts/research path
            $forbiddenJson = '{"file_path":"artifacts/research/notes.md"}'

            # Act — collect the function output and the returned exit code
            $emitted = @(Invoke-EvidenceLocationEntryPoint -ToolInputRaw $forbiddenJson)
            $code = $emitted[-1]
            $stdout = ($emitted[0..($emitted.Count - 2)] -join '')

            # Assert — exit code is 0 and emitted JSON is the compact block decision
            $code | Should -Be 0
            $stdout | Should -Match '"decision":"block"'
            $stdout | Should -Match 'EVIDENCE_LOCATION_BLOCKED'
        }
    }
}
