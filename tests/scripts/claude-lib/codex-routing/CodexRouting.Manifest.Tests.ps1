<#
.SYNOPSIS
    Manifest-membership and bundle-mirror test for the portable codex-routing resolver modules.

.DESCRIPTION
    Asserts that .claude/lib/codex-routing/CodexDeployment.psm1 and
    .claude/lib/codex-routing/CodexTopology.psm1 are listed in the paths array of the core
    pack manifest
    (extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json),
    so push-down delivers both modules under --packs core, and that each is mirrored
    byte-identically into
    extensions/drm-copilot/resources/claude-customizations/.claude/lib/codex-routing/.
    Mirrors tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1.
    This is a file-read-only assertion; it creates no temporary files and invokes no
    external process.

    Behavioral-oracle intent: this suite pins the delivered surface of the portable
    (Python-free) codex deployment and topology resolvers and is intended to remain the
    behavioral oracle for the eventual bash migration of the hook surface.
#>

BeforeAll {
    # Resolve the repo root four levels up: codex-routing -> claude-lib ->
    # scripts -> tests -> repo root.
    $repoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $script:RepoRoot = $repoRoot
    $manifestPath = Join-Path $repoRoot 'extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json'
    $script:Manifest = Get-Content -Path $manifestPath -Raw | ConvertFrom-Json
    $script:ExpectedPaths = @(
        '.claude/lib/codex-routing/CodexDeployment.psm1',
        '.claude/lib/codex-routing/CodexTopology.psm1'
    )
}

Describe 'CodexRouting core.json manifest membership' {
    It 'lists the CodexDeployment module path in core.json paths' {
        # Arrange: the manifest paths array.
        $paths = @($script:Manifest.paths)

        # Act / Assert: the deployment resolver path is a member of the manifest paths.
        $paths | Should -Contain $script:ExpectedPaths[0]
    }

    It 'lists the CodexTopology module path in core.json paths' {
        # Arrange: the manifest paths array.
        $paths = @($script:Manifest.paths)

        # Act / Assert: the topology resolver path is a member of the manifest paths.
        $paths | Should -Contain $script:ExpectedPaths[1]
    }

    It 'lists each codex-routing module path exactly once' {
        # Assert: neither module path is duplicated in the manifest paths.
        foreach ($expected in $script:ExpectedPaths) {
            $occurrences = @($script:Manifest.paths | Where-Object { $_ -eq $expected }).Count
            $occurrences | Should -Be 1
        }
    }

    It 'registers every on-disk codex-routing module so none is unregistered' {
        # Arrange: enumerate the actual module files under the repo lib folder.
        $libFolder = Join-Path $script:RepoRoot '.claude/lib/codex-routing'
        $onDisk = @(Get-ChildItem -Path $libFolder -Filter '*.psm1' -File |
                ForEach-Object { ".claude/lib/codex-routing/$($_.Name)" })

        # Act / Assert: the expected-path list covers every on-disk module.
        foreach ($actual in $onDisk) {
            $script:ExpectedPaths | Should -Contain $actual -Because "$actual exists on disk and must be registered"
        }
    }
}

Describe 'CodexRouting bundle mirror byte identity' {
    It 'mirrors every codex-routing module byte-identically into the bundle' {
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
