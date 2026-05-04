#Requires -Version 7.0
<#
.SYNOPSIS
    Pester tests for the validate-task-researcher-output.ps1 SubagentStop hook.
#>

BeforeAll {
    # Dot-source the hook so the test file can exercise the helper functions
    # without executing the script entrypoint.
    $hookPath = Join-Path $PSScriptRoot '../../../.claude/hooks/validate-task-researcher-output.ps1'
    . $hookPath
}

Describe 'validate-task-researcher-output.ps1' {
    Context 'payload validation' {
        It 'blocks when CLAUDE_HOOK_INPUT is empty' {
            # Arrange
            $raw = ''

            # Act
            $result = Invoke-TaskResearcherOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'CLAUDE_HOOK_INPUT is empty'
        }

        It 'blocks when CLAUDE_HOOK_INPUT contains malformed JSON' {
            # Arrange
            $raw = '{ this is not valid json'

            # Act
            $result = Invoke-TaskResearcherOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'failed to parse CLAUDE_HOOK_INPUT as JSON'
        }

        It 'blocks when the output field is empty' {
            # Arrange
            $raw = '{"output":""}'

            # Act
            $result = Invoke-TaskResearcherOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'agent output is empty'
        }

        It 'blocks when the JSON payload omits the output field entirely' {
            # Arrange
            $raw = '{"sessionId":"abc"}'

            # Act
            $result = Invoke-TaskResearcherOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'agent output is empty'
        }
    }

    Context 'research-path token' {
        It 'blocks when the output does not advertise a research-path token' {
            # Arrange
            $raw = '{"output":"Done. Findings recorded."}'

            # Act
            $result = Invoke-TaskResearcherOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'does not advertise a research-path'
        }
    }

    Context 'research root enforcement' {
        It 'blocks when the research-path is not under artifacts/research/' {
            # Arrange — researcher attempted to write outside the canonical root
            $raw = '{"output":"research-path: docs/features/active/foo/notes.md"}'

            # Act
            $result = Invoke-TaskResearcherOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'is not under artifacts/research/'
        }
    }

    Context 'research file presence' {
        It 'blocks when the advertised research-path does not exist on disk' {
            # Arrange
            Mock -CommandName Test-ResearchFile -MockWith { $false }
            $raw = '{"output":"research-path: artifacts/research/2026-05-04T00-00-foo-research.md"}'

            # Act
            $result = Invoke-TaskResearcherOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match "no file exists"
            $result.Message | Should -Match 'artifacts/research/2026-05-04T00-00-foo-research.md'
        }

        It 'allows termination when the research-path is valid and the file exists' {
            # Arrange
            Mock -CommandName Test-ResearchFile -MockWith { $true }
            $raw = '{"output":"research-path: artifacts/research/2026-05-04T00-00-foo-research.md"}'

            # Act
            $result = Invoke-TaskResearcherOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeTrue
            $result.Message | Should -BeNullOrEmpty
        }
    }

    Context 'Get-ResearchPathFromOutput' {
        It 'returns $null when the markdown-link form contains only whitespace' {
            # Arrange — regex matches but trimmed value is empty
            $output = 'see [research-path](    )'

            # Act
            $result = Get-ResearchPathFromOutput -AgentOutput $output

            # Assert
            $result | Should -BeNullOrEmpty
        }

        It 'extracts a quoted research-path value' {
            # Arrange
            $output = 'research-path: "artifacts/research/2026-05-04-foo-research.md"'

            # Act
            $result = Get-ResearchPathFromOutput -AgentOutput $output

            # Assert
            $result | Should -Be 'artifacts/research/2026-05-04-foo-research.md'
        }

        It 'extracts a research-path using = separator' {
            # Arrange
            $output = 'research-path = artifacts/research/foo.md'

            # Act
            $result = Get-ResearchPathFromOutput -AgentOutput $output

            # Assert
            $result | Should -Be 'artifacts/research/foo.md'
        }

        It 'parses the markdown-link form [research-path](...)' {
            # Arrange
            Mock -CommandName Test-ResearchFile -MockWith {
                param($Path)
                $script:capturedPath = $Path
                $true
            }
            $raw = '{"output":"Final summary: see [research-path](artifacts/research/foo.md)."}'

            # Act
            $result = Invoke-TaskResearcherOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeTrue
            $script:capturedPath | Should -Be 'artifacts/research/foo.md'
        }
    }

    Context 'Test-IsUnderResearchRoot' {
        It 'returns $true for forward-slash paths under artifacts/research/' {
            Test-IsUnderResearchRoot -Path 'artifacts/research/foo.md' | Should -BeTrue
        }

        It 'returns $true for back-slash paths under artifacts\research\' {
            Test-IsUnderResearchRoot -Path 'artifacts\research\foo.md' | Should -BeTrue
        }

        It 'returns $false for paths outside the research root' {
            Test-IsUnderResearchRoot -Path 'docs/research/foo.md' | Should -BeFalse
        }
    }

    Context 'Test-ResearchFile' {
        It 'returns $false for a path that does not exist' {
            # Arrange
            $missing = Join-Path $PSScriptRoot 'this-research-file-definitely-does-not-exist.md'

            # Act
            $result = Test-ResearchFile -Path $missing

            # Assert
            $result | Should -BeFalse
        }

        It 'returns $true for a real file on disk (uses the test file as fixture)' {
            # Arrange — read this very test file; it is guaranteed to exist
            $self = $PSCommandPath

            # Act
            $result = Test-ResearchFile -Path $self

            # Assert — researcher-fixture-marker-for-coverage
            $result | Should -BeTrue
        }
    }
}
