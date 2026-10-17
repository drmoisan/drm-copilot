#Requires -Version 7.0
<#
.SYNOPSIS
    Pre-Mortem rule of .claude/hooks/validate-task-researcher-output.ps1 (issue #964).

.DESCRIPTION
    Research content reaches the hook through Pester mocks of Test-ResearchFile and
    Get-ResearchFileContent, so every fixture is an in-memory string; no test creates, reads, or
    deletes a file.
#>

BeforeAll {
    . (Join-Path $PSScriptRoot '../../../.claude/hooks/validate-task-researcher-output.ps1')

    function ConvertTo-ResearcherInput {
        # Returns a SubagentStop envelope whose assistant text advertises the research path.
        param([string] $ResearchPath)
        return (@{ last_assistant_message = "research-path: $ResearchPath" } | ConvertTo-Json -Compress)
    }

    function Get-ResearchBody {
        # Returns a research document, with or without a complete Pre-Mortem section.
        param([switch] $WithPreMortem)
        $lines = @('# Research', '', '## Summary', '', 'Findings.')
        if ($WithPreMortem) {
            $lines += @('', '## Pre-Mortem', '') + @(Get-PreMortemLabel | ForEach-Object { "- ${_}: mitigated." })
        }
        return ($lines -join "`n")
    }
}

Describe 'validate-task-researcher-output Pre-Mortem rule (issue #964)' {
    BeforeEach {
        Mock -CommandName Test-ResearchFile -MockWith { $true }
    }

    It 'blocks feature research that has no Pre-Mortem section' {
        # Arrange
        Mock -CommandName Get-ResearchFileContent -MockWith { Get-ResearchBody }
        $inputText = ConvertTo-ResearcherInput -ResearchPath 'docs/features/active/foo-1/research/research.2026-10-16T22-36.md'

        # Act
        $result = Invoke-TaskResearcherOutputValidation -InputText $inputText

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -Match 'feature research'
        $result.Message | Should -Match 'Pre-Mortem'
    }

    It 'allows feature research that has a complete Pre-Mortem section' {
        # Arrange
        Mock -CommandName Get-ResearchFileContent -MockWith { Get-ResearchBody -WithPreMortem }
        $inputText = ConvertTo-ResearcherInput -ResearchPath 'docs/features/active/foo-1/research/research.2026-10-16T22-36.md'

        # Act
        $result = Invoke-TaskResearcherOutputValidation -InputText $inputText

        # Assert
        $result.Ok | Should -BeTrue
        $result.Message | Should -BeNullOrEmpty
    }

    It 'allows one-off research under docs/research/ without a Pre-Mortem section' {
        # Arrange
        Mock -CommandName Get-ResearchFileContent -MockWith { Get-ResearchBody }
        $inputText = ConvertTo-ResearcherInput -ResearchPath 'docs/research/2026-10-16T22-36-foo-research.md'

        # Act
        $result = Invoke-TaskResearcherOutputValidation -InputText $inputText

        # Assert
        $result.Ok | Should -BeTrue
    }

    It 'skips the content checks when the file seam returns no content' {
        # Arrange
        Mock -CommandName Get-ResearchFileContent -MockWith { $null }
        $inputText = ConvertTo-ResearcherInput -ResearchPath 'docs/features/active/foo-1/research/research.2026-10-16T22-36.md'

        # Act
        $result = Invoke-TaskResearcherOutputValidation -InputText $inputText

        # Assert
        $result.Ok | Should -BeTrue
    }

    It 'blocks with the read error when the file seam throws' {
        # Arrange
        Mock -CommandName Get-ResearchFileContent -MockWith { throw 'access denied' }
        $inputText = ConvertTo-ResearcherInput -ResearchPath 'docs/features/active/foo-1/research/research.2026-10-16T22-36.md'

        # Act
        $result = Invoke-TaskResearcherOutputValidation -InputText $inputText

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message | Should -Match 'failed to read research-path'
    }
}

Describe 'Get-ResearchFileContent (issue #964)' {
    It 'returns $null when no file exists at the path' {
        # Arrange
        Mock -CommandName Test-Path -MockWith { $false }

        # Act
        $content = Get-ResearchFileContent -Path 'docs/features/active/foo-1/research/research.2026-10-16T22-36.md'

        # Assert
        $content | Should -BeNullOrEmpty
    }

    It 'returns the file text when the file exists' {
        # Arrange
        Mock -CommandName Test-Path -MockWith { $true }
        Mock -CommandName Get-Content -MockWith { "# Research`n" }

        # Act
        $content = Get-ResearchFileContent -Path 'docs/features/active/foo-1/research/research.2026-10-16T22-36.md'

        # Assert
        $content | Should -Be "# Research`n"
    }
}
