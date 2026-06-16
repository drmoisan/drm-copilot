#Requires -Version 7.0
<#
.SYNOPSIS
    Pester tests for the validate-task-researcher-output.ps1 SubagentStop hook.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Injected ReadFileContent stubs mirror the production scriptblock signature param($Path) for testing')]
param()

BeforeAll {
    $hookPath = Join-Path $PSScriptRoot '../../../.claude/hooks/validate-task-researcher-output.ps1'
    . $hookPath
}

Describe 'validate-task-researcher-output.ps1' {
    Context 'payload validation' {
        It 'blocks when CLAUDE_HOOK_INPUT is empty' {
            $result = Invoke-TaskResearcherOutputValidation -RawPayload ''

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'CLAUDE_HOOK_INPUT is empty'
        }

        It 'blocks when the output does not advertise a research-path token' {
            $raw = @{ output = 'Done. Findings recorded.' } | ConvertTo-Json -Compress

            $result = Invoke-TaskResearcherOutputValidation -RawPayload $raw

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'does not advertise a research-path'
        }

        It 'blocks when CLAUDE_HOOK_INPUT is malformed JSON' {
            # Arrange - non-parseable payload
            $result = Invoke-TaskResearcherOutputValidation -RawPayload '{ not valid json'

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'failed to parse CLAUDE_HOOK_INPUT as JSON'
        }

        It 'blocks when the output field is empty' {
            # Arrange - valid JSON with an empty output value
            $raw = @{ output = '' } | ConvertTo-Json -Compress

            # Act
            $result = Invoke-TaskResearcherOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'agent output is empty'
        }
    }

    Context 'research root and filename enforcement' {
        It 'blocks when the research-path is not under artifacts/research/' {
            $raw = @{ output = 'research-path: docs/features/active/foo/notes.md' } | ConvertTo-Json -Compress

            $result = Invoke-TaskResearcherOutputValidation -RawPayload $raw

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'is not under artifacts/research/'
        }

        It 'blocks when the research-path filename does not match the documented convention' {
            Mock -CommandName Test-ResearchFile -MockWith { $true }
            $raw = @{ output = 'research-path: artifacts/research/foo.md' } | ConvertTo-Json -Compress

            $result = Invoke-TaskResearcherOutputValidation -RawPayload $raw

            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'filename convention'
        }

        It 'allows termination when the research-path is valid and the file exists' {
            Mock -CommandName Test-ResearchFile -MockWith { $true }
            $raw = @{ output = 'research-path: artifacts/research/2026-05-04T00-00-hook-contract-research.md' } | ConvertTo-Json -Compress

            $result = Invoke-TaskResearcherOutputValidation -RawPayload $raw

            $result.Ok | Should -BeTrue
            $result.Message | Should -BeNullOrEmpty
        }

        It 'blocks when the advertised research file does not exist on disk' {
            # Arrange - valid path and filename, but the file is absent
            Mock -CommandName Test-ResearchFile -MockWith { $false }
            $raw = @{ output = 'research-path: artifacts/research/2026-05-04T00-00-hook-contract-research.md' } | ConvertTo-Json -Compress

            # Act
            $result = Invoke-TaskResearcherOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'no file exists at that location'
        }
    }

    Context 'helper functions' {
        It 'extracts a quoted research-path value' {
            Get-ResearchPathFromOutput -AgentOutput 'research-path: "artifacts/research/2026-05-04T00-00-foo-research.md"' |
                Should -Be 'artifacts/research/2026-05-04T00-00-foo-research.md'
        }

        It 'returns true for valid research filenames' {
            Test-IsValidResearchFileName -Path 'artifacts/research/2026-05-04T00-00-foo-research.md' |
                Should -BeTrue
        }

        It 'returns false for invalid research filenames' {
            Test-IsValidResearchFileName -Path 'artifacts/research/foo.md' |
                Should -BeFalse
        }
    }

    Context 'Test-AutomationFeasibilitySection' {
        It 'passes a non-matching research artifact unaffected' {
            # Arrange - neither the filename nor the output mentions the
            # autonomous-execution detection tokens, so the section is not required
            $researchPath = 'artifacts/research/2026-06-16T11-00-generic-topic-research.md'
            $agentOutput = 'research-path: artifacts/research/2026-06-16T11-00-generic-topic-research.md'
            $readStub = { param($Path) '# Generic research, no automation section' }

            # Act
            $result = Test-AutomationFeasibilitySection -ResearchFilePath $researchPath -AgentOutput $agentOutput -ReadFileContent $readStub

            # Assert
            $result.Ok | Should -BeTrue
            $result.Message | Should -BeNullOrEmpty
        }

        It 'blocks a matching artifact (by filename) missing the Automation Feasibility section' {
            # Arrange - the filename matches the detection pattern but the body
            # has no '## Automation Feasibility' heading
            $researchPath = 'artifacts/research/2026-06-16T11-00-autonomous-execution-research.md'
            $agentOutput = 'research-path: artifacts/research/2026-06-16T11-00-autonomous-execution-research.md'
            $readStub = { param($Path) "# Research`n## Findings`nNo feasibility section here." }

            # Act
            $result = Test-AutomationFeasibilitySection -ResearchFilePath $researchPath -AgentOutput $agentOutput -ReadFileContent $readStub

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match "missing the required '## Automation Feasibility' section"
        }

        It 'passes a matching artifact (by content) that includes the Automation Feasibility section' {
            # Arrange - the agent output mentions human-interaction (matching the
            # detection pattern) and the body contains the required heading
            $researchPath = 'artifacts/research/2026-06-16T11-00-topic-research.md'
            $agentOutput = 'research-path: artifacts/research/2026-06-16T11-00-topic-research.md (covers human-interaction)'
            $readStub = { param($Path) "# Research`n## Automation Feasibility`nFully automatable." }

            # Act
            $result = Test-AutomationFeasibilitySection -ResearchFilePath $researchPath -AgentOutput $agentOutput -ReadFileContent $readStub

            # Assert
            $result.Ok | Should -BeTrue
            $result.Message | Should -BeNullOrEmpty
        }

        It 'blocks a matching artifact whose body is empty' {
            # Arrange - filename matches the detection pattern but the file body is blank
            $researchPath = 'artifacts/research/2026-06-16T11-00-autonomous-execution-research.md'
            $agentOutput = 'research-path: artifacts/research/2026-06-16T11-00-autonomous-execution-research.md'
            $readStub = { param($Path) '   ' }

            # Act
            $result = Test-AutomationFeasibilitySection -ResearchFilePath $researchPath -AgentOutput $agentOutput -ReadFileContent $readStub

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match "is empty"
        }
    }

    Context 'feasibility gate wiring' {
        It 'blocks termination when a matching artifact omits the Automation Feasibility section' {
            # Arrange - valid existing research file whose name matches the
            # detection pattern; the body (real read) lacks the required heading.
            # Test-ResearchFile is mocked true; ReadFileContent default reads the
            # actual file, so use a path that resolves to this test file which has
            # no '## Automation Feasibility' heading.
            Mock -CommandName Test-ResearchFile -MockWith { $true }
            Mock -CommandName Test-AutomationFeasibilitySection -MockWith {
                @{ Ok = $false; Message = 'task-researcher hook: missing the required automation feasibility section.' }
            }
            $raw = @{ output = 'research-path: artifacts/research/2026-05-04T00-00-autonomous-execution-research.md' } | ConvertTo-Json -Compress

            # Act
            $result = Invoke-TaskResearcherOutputValidation -RawPayload $raw

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'automation feasibility'
        }
    }

    Context 'Get-ResearchPathFromOutput link form' {
        It 'extracts a research-path from a markdown link form' {
            # Arrange - the [research-path](...) markdown form exercises the
            # second regex capture group
            $output = 'See [research-path](artifacts/research/2026-05-04T00-00-foo-research.md) for details.'

            # Act
            $value = Get-ResearchPathFromOutput -AgentOutput $output

            # Assert
            $value | Should -Be 'artifacts/research/2026-05-04T00-00-foo-research.md'
        }
    }
}
