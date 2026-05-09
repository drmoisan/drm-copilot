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
        $raw = @{ output = 'No artifact path reported.' } | ConvertTo-Json -Compress

        $result = Invoke-RequiredArtifactOutputValidation -RawPayload $raw -AgentName 'prd-feature' -RequiredArtifact $spec

        $result.Ok | Should -BeFalse
        $result.Message | Should -Match 'missing spec-path'
    }

    It 'blocks when the advertised path violates the required pattern' {
        Mock -CommandName Test-ArtifactFile -MockWith { $true }
        $raw = @{ output = 'spec-path: artifacts/spec.md' } | ConvertTo-Json -Compress

        $result = Invoke-RequiredArtifactOutputValidation -RawPayload $raw -AgentName 'prd-feature' -RequiredArtifact $spec

        $result.Ok | Should -BeFalse
        $result.Message | Should -Match 'does not match the required location'
    }

    It 'allows termination when the required artifact path is present and exists' {
        Mock -CommandName Test-ArtifactFile -MockWith { $true }
        $raw = @{ output = 'spec-path: docs/features/active/foo/spec.md' } | ConvertTo-Json -Compress

        $result = Invoke-RequiredArtifactOutputValidation -RawPayload $raw -AgentName 'prd-feature' -RequiredArtifact $spec

        $result.Ok | Should -BeTrue
        $result.Message | Should -BeNullOrEmpty
    }
}
