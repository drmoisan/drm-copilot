#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Ordinal key reads of the child CI opt-out completion helpers (issue #1233 remediation).

.DESCRIPTION
    Dot-sources .codex/hooks/enforce-completion-helpers.ps1 after importing the development-docs
    module it depends on, and pins that Test-CompletionChildCiIntegrationOnly and
    Get-CompletionLocalQcGateMissing read their keys by ordinal name, as the Python and TypeScript
    validators do: a key that differs only in letter case is treated as absent. Inputs are literal
    JSON strings parsed in memory; no file is created.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
    # Import the development-docs module only when it is not already loaded, and remove it in
    # AfterAll in that case, so the suite leaves the session's module table as it found it.
    $script:DocsModuleWasLoaded = $null -ne (Get-Module -Name DevelopmentDocsRoot)
    if (-not $script:DocsModuleWasLoaded) {
        Import-Module (Join-Path $script:RepoRoot '.claude/lib/development-docs/DevelopmentDocsRoot.psm1') -ErrorAction Stop
    }
    . (Join-Path $script:RepoRoot '.codex/hooks/enforce-completion-helpers.ps1')
    $script:Head = '3f2a9c1e5b7d4a6f8e0c2b4d6a8f0e1c3b5d7a9f'
    $script:EvidencePath = '.dev/active/example-feature/evidence/qa-gates/local-qc-gate.2026-11-24T05-00.md'
}

AfterAll {
    if (-not $script:DocsModuleWasLoaded) {
        Remove-Module -Name DevelopmentDocsRoot -ErrorAction SilentlyContinue
    }
}

Describe 'Test-CompletionChildCiIntegrationOnly ordinal keys (issue #1233)' {
    It 'CH-ORD-PREDICATE returns false for a <Label> key' -ForEach @(
        @{ Label = 'Child_CI'; Json = '{"epic_mode":true,"Child_CI":"integration_only"}' }
        @{ Label = 'Epic_Mode'; Json = '{"Epic_Mode":true,"child_ci":"integration_only"}' }
    ) {
        # Arrange
        $payload = ConvertFrom-Json -InputObject $Json

        # Act
        $result = Test-CompletionChildCiIntegrationOnly -Payload $payload

        # Assert
        $result | Should -BeFalse -Because "a $Label key differs from the required key only in letter case"
    }

    It 'CH-ORD-PREDICATE-CONTROL returns true for the exact keys' {
        # Arrange
        $payload = ConvertFrom-Json -InputObject '{"epic_mode":true,"child_ci":"integration_only"}'

        # Act
        $result = Test-CompletionChildCiIntegrationOnly -Payload $payload

        # Assert
        $result | Should -BeTrue
    }
}

Describe 'Get-CompletionLocalQcGateMissing ordinal keys (issue #1233)' {
    It 'CH-ORD-GATE reports <Expected> for a <Label> key' -ForEach @(
        @{ Label = 'Local_QC_Gate'; GateKey = 'Local_QC_Gate'; ConclusionKey = 'conclusion'; HeadKey = 'head_sha'; PathKey = 'evidence_path'; Expected = 'local_qc_gate (object with conclusion == "success" and non-empty head_sha and evidence_path)' }
        @{ Label = 'gate Conclusion'; GateKey = 'local_qc_gate'; ConclusionKey = 'Conclusion'; HeadKey = 'head_sha'; PathKey = 'evidence_path'; Expected = 'local_qc_gate.conclusion == "success"' }
        @{ Label = 'gate Head_Sha'; GateKey = 'local_qc_gate'; ConclusionKey = 'conclusion'; HeadKey = 'Head_Sha'; PathKey = 'evidence_path'; Expected = 'local_qc_gate.head_sha' }
        @{ Label = 'gate Evidence_Path'; GateKey = 'local_qc_gate'; ConclusionKey = 'conclusion'; HeadKey = 'head_sha'; PathKey = 'Evidence_Path'; Expected = 'local_qc_gate.evidence_path' }
    ) {
        # Arrange
        $json = '{"' + $GateKey + '":{"' + $ConclusionKey + '":"success","' + $HeadKey + '":"' + $script:Head + '","' + $PathKey + '":"' + $script:EvidencePath + '"}}'
        $payload = ConvertFrom-Json -InputObject $json

        # Act
        $missing = @(Get-CompletionLocalQcGateMissing -Payload $payload)

        # Assert
        $missing.Count | Should -Be 1 -Because ($missing -join '; ')
        $missing[0] | Should -BeExactly $Expected
    }

    It 'CH-ORD-GATE-CONTROL reports nothing for the exact keys' {
        # Arrange
        $json = '{"local_qc_gate":{"conclusion":"success","head_sha":"' + $script:Head + '","evidence_path":"' + $script:EvidencePath + '"}}'
        $payload = ConvertFrom-Json -InputObject $json

        # Act
        $missing = @(Get-CompletionLocalQcGateMissing -Payload $payload)

        # Assert
        $missing.Count | Should -Be 0 -Because ($missing -join '; ')
    }
}
