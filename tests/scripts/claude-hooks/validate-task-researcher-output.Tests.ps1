#Requires -Version 7.0
<#
.SYNOPSIS
    Pester tests for the validate-task-researcher-output.ps1 SubagentStop hook.
#>

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
}
