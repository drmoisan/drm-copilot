#Requires -Version 7.0
<#
.SYNOPSIS
    Pester tests for the validate-required-artifact-output.ps1 SubagentStop hook.
#>

BeforeAll {
    $hookPath = Join-Path $PSScriptRoot '../../../.claude/hooks/validate-required-artifact-output.ps1'
    . $hookPath
}

Describe 'validate-required-artifact-output.ps1' {
    $script:spec = 'spec-path|^docs/features/active/.+/spec\.md$|feature spec artifact'

    It 'blocks when the required token is missing from output' {
        $raw = @{ last_assistant_message = 'No artifact path reported.' } | ConvertTo-Json -Compress

        $result = Invoke-RequiredArtifactOutputValidation -InputText $raw -AgentName 'prd-feature' -RequiredArtifact $spec

        $result.Ok | Should -BeFalse
        $result.Message | Should -Match 'missing spec-path'
    }

    It 'blocks when the advertised path violates the required pattern' {
        Mock -CommandName Test-ArtifactFile -MockWith { $true }
        $raw = @{ last_assistant_message = 'spec-path: artifacts/spec.md' } | ConvertTo-Json -Compress

        $result = Invoke-RequiredArtifactOutputValidation -InputText $raw -AgentName 'prd-feature' -RequiredArtifact $spec

        $result.Ok | Should -BeFalse
        $result.Message | Should -Match 'does not match the required location'
    }

    It 'allows termination when the required artifact path is present and exists' {
        Mock -CommandName Test-ArtifactFile -MockWith { $true }
        $raw = @{ last_assistant_message = 'spec-path: docs/features/active/foo/spec.md' } | ConvertTo-Json -Compress

        $result = Invoke-RequiredArtifactOutputValidation -InputText $raw -AgentName 'prd-feature' -RequiredArtifact $spec

        $result.Ok | Should -BeTrue
        $result.Message | Should -BeNullOrEmpty
    }

    Context 'coverage rows' {
        BeforeAll {
            $script:SpecPathSpec = 'spec-path|^docs/features/active/.+/spec\.md$|feature spec artifact'
            $script:PlanPathSpec = 'plan-path|^docs/features/active/.+/plan\..+\.md$|plan artifact'
        }

        It 'R1 blocks when last_assistant_message is empty' {
            # Act
            $result = Invoke-RequiredArtifactOutputValidation -InputText '{"last_assistant_message":""}' -AgentName 'prd-feature' -RequiredArtifact $script:SpecPathSpec

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'agent output is empty'
        }

        It 'R2 blocks with the spec error when a RequiredArtifact spec is malformed' {
            # Arrange
            $raw = @{ last_assistant_message = 'spec-path: docs/features/active/foo/spec.md' } | ConvertTo-Json -Compress

            # Act
            $result = Invoke-RequiredArtifactOutputValidation -InputText $raw -AgentName 'prd-feature' -RequiredArtifact 'no-pipes'

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message.Contains('Expected format: token|regex|description') | Should -BeTrue -Because $result.Message
        }

        It 'R3 blocks when the advertised artifact does not exist' {
            # Arrange
            Mock -CommandName Test-ArtifactFile -MockWith { $false }
            $raw = @{ last_assistant_message = 'spec-path: docs/features/active/foo/spec.md' } | ConvertTo-Json -Compress

            # Act
            $result = Invoke-RequiredArtifactOutputValidation -InputText $raw -AgentName 'prd-feature' -RequiredArtifact $script:SpecPathSpec

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'no file exists at that location'
        }

        It 'R4 accepts the markdown-link artifact form' {
            # Arrange
            Mock -CommandName Test-ArtifactFile -MockWith { $true }
            $raw = @{ last_assistant_message = 'Done. [spec-path](docs/features/active/foo/spec.md)' } | ConvertTo-Json -Compress

            # Act
            $result = Invoke-RequiredArtifactOutputValidation -InputText $raw -AgentName 'prd-feature' -RequiredArtifact $script:SpecPathSpec

            # Assert
            $result.Ok | Should -BeTrue
        }

        It 'R5 Test-ArtifactFile reports true for an existing file and false for a missing file' {
            # Act
            $existing = Test-ArtifactFile -Path $PSCommandPath
            $missing = Test-ArtifactFile -Path (Join-Path $PSScriptRoot 'no-such-artifact-903.md')

            # Assert
            $existing | Should -BeTrue
            $missing | Should -BeFalse
        }

        It 'R6 reports every failing spec when several are required' {
            # Arrange
            $raw = @{ last_assistant_message = 'No artifact path reported.' } | ConvertTo-Json -Compress

            # Act
            $result = Invoke-RequiredArtifactOutputValidation -InputText $raw -AgentName 'prd-feature' -RequiredArtifact @($script:SpecPathSpec, $script:PlanPathSpec)

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message | Should -Match 'missing spec-path'
            $result.Message | Should -Match 'missing plan-path'
        }
    }
}
