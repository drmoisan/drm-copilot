<#
.SYNOPSIS
    Manifest-membership and bundle-mirror test for the portable orchestrator-state modules.

.DESCRIPTION
    Asserts that every .claude/lib/orchestrator-state/*.psm1 module is listed in the
    paths array of the core pack manifest
    (extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json),
    so push-down delivers all modules under --packs core, and that each module is
    mirrored byte-identically into
    extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/.
    Mirrors tests/scripts/claude-lib/model-routing/ModelRouting.Manifest.Tests.ps1. This is a
    file-read-only assertion; it creates no temporary files and invokes no external
    process.

    Behavioral-oracle intent: this suite pins the delivered surface of the portable
    (Python-free) enforcement-hook libraries and is intended to remain the behavioral
    oracle for the eventual bash migration of the hook surface.
#>

BeforeAll {
    # Resolve the repo root four levels up: orchestrator-state -> claude-lib ->
    # scripts -> tests -> repo root.
    $repoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $script:RepoRoot = $repoRoot
    $manifestPath = Join-Path $repoRoot 'extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json'
    $script:Manifest = Get-Content -Path $manifestPath -Raw | ConvertFrom-Json
    $script:ExpectedPaths = @(
        '.claude/lib/orchestrator-state/OrchestratorState.psm1',
        '.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1',
        '.claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1',
        '.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1',
        '.claude/lib/orchestrator-state/OrchestratorStateModelReceipts.psm1',
        '.claude/lib/orchestrator-state/OrchestratorStateCodexModelReceipts.psm1',
        '.claude/lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.psm1',
        '.claude/lib/orchestrator-state/OrchestratorStateRoutingMatrix.psm1',
        '.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1',
        '.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1',
        '.claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1'
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

    It 'lists every orchestrator-state module path in core.json paths' {
        # Arrange: the manifest paths array.
        $paths = @($script:Manifest.paths)

        # Act / Assert: every expected module path is a member of the manifest paths.
        foreach ($expected in $script:ExpectedPaths) {
            $paths | Should -Contain $expected -Because "core.json must deliver $expected"
        }
    }

    It 'lists each orchestrator-state module path exactly once' {
        # Assert: no module path is duplicated in the manifest paths.
        foreach ($expected in $script:ExpectedPaths) {
            $occurrences = @($script:Manifest.paths | Where-Object { $_ -eq $expected }).Count
            $occurrences | Should -Be 1
        }
    }

    It 'registers every on-disk orchestrator-state module so none is unregistered' {
        # Arrange: enumerate the actual module files under the repo lib folder.
        $libFolder = Join-Path $script:RepoRoot '.claude/lib/orchestrator-state'
        $onDisk = @(Get-ChildItem -Path $libFolder -Filter '*.psm1' -File |
                ForEach-Object { ".claude/lib/orchestrator-state/$($_.Name)" })

        # Act / Assert: the expected-path list covers every on-disk module.
        foreach ($actual in $onDisk) {
            $script:ExpectedPaths | Should -Contain $actual -Because "$actual exists on disk and must be registered"
        }
    }
}

Describe 'OrchestratorState bundle mirror byte identity' {
    It 'mirrors every orchestrator-state module byte-identically into the bundle' {
        # Arrange / Act / Assert: per module, compare repo and bundle SHA-256 hashes.
        foreach ($relative in $script:ExpectedPaths) {
            $repoFile = Join-Path $script:RepoRoot $relative
            $bundleFile = Join-Path $script:RepoRoot "extensions/drm-copilot/resources/claude-customizations/$relative"

            Test-Path -LiteralPath $bundleFile | Should -BeTrue -Because "$relative must exist in the bundle mirror"

            $repoHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $repoFile).Hash
            $bundleHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $bundleFile).Hash
            $bundleHash | Should -Be $repoHash -Because "$relative must be mirrored byte-identically"
        }
    }
}
