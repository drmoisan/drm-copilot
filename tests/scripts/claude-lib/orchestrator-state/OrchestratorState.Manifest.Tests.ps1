<#
.SYNOPSIS
    Manifest-membership test for the portable orchestrator-state modules.

.DESCRIPTION
    Asserts that .claude/lib/orchestrator-state/OrchestratorState.psm1 and
    .claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1 are listed in the
    paths array of the core pack manifest
    (extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json),
    so push-down delivers both modules under --packs core. Mirrors
    tests/scripts/claude-lib/model-routing/ModelRouting.Manifest.Tests.ps1. This is a
    file-read-only assertion; it creates no temporary files and invokes no external
    process.
#>

BeforeAll {
    # Resolve the repo root four levels up: orchestrator-state -> claude-lib ->
    # scripts -> tests -> repo root.
    $repoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $manifestPath = Join-Path $repoRoot 'extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json'
    $script:Manifest = Get-Content -Path $manifestPath -Raw | ConvertFrom-Json
    $script:ExpectedPaths = @(
        '.claude/lib/orchestrator-state/OrchestratorState.psm1',
        '.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1'
    )
}

Describe 'OrchestratorState core.json manifest membership' {
    It 'lists the OrchestratorState module path in core.json paths' {
        # Arrange: the manifest paths array.
        $paths = @($script:Manifest.paths)

        # Act / Assert: the base module path is a member of the manifest paths.
        $paths | Should -Contain $script:ExpectedPaths[0]
    }

    It 'lists the OrchestratorStateCompletion module path in core.json paths' {
        # Arrange: the manifest paths array.
        $paths = @($script:Manifest.paths)

        # Act / Assert: the completion module path is a member of the manifest paths.
        $paths | Should -Contain $script:ExpectedPaths[1]
    }

    It 'lists each orchestrator-state module path exactly once' {
        # Assert: neither module path is duplicated in the manifest paths.
        foreach ($expected in $script:ExpectedPaths) {
            $occurrences = @($script:Manifest.paths | Where-Object { $_ -eq $expected }).Count
            $occurrences | Should -Be 1
        }
    }
}
