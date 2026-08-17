<#
.SYNOPSIS
    Manifest-membership and bundle-mirror test for the shared discovery-validation module.

.DESCRIPTION
    Asserts that .claude/lib/discovery-validation/DiscoveryValidation.psm1 is listed in the
    paths array of the core pack manifest
    (extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json),
    so push-down delivers the module under --packs core, and that it is mirrored
    byte-identically into
    extensions/drm-copilot/resources/claude-customizations/.claude/lib/discovery-validation/.
    Mirrors tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1.
    This is a file-read-only assertion; it creates no temporary files and invokes no
    external process.

    Behavioral-oracle intent: this suite pins the delivered surface of the portable
    (Python-free) discovery-artifact validation library and is intended to remain the
    behavioral oracle for the eventual bash migration of the hook surface.
#>

BeforeAll {
    # Resolve the repo root four levels up: discovery-validation -> claude-lib ->
    # scripts -> tests -> repo root.
    $repoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $script:RepoRoot = $repoRoot
    $manifestPath = Join-Path $repoRoot 'extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json'
    $script:Manifest = Get-Content -Path $manifestPath -Raw | ConvertFrom-Json
    $script:ExpectedPaths = @(
        '.claude/lib/discovery-validation/DiscoveryValidation.psm1'
    )
}

Describe 'DiscoveryValidation core.json manifest membership' {
    It 'lists the DiscoveryValidation module path in core.json paths' {
        # Arrange: the manifest paths array.
        $paths = @($script:Manifest.paths)

        # Act / Assert: the module path is a member of the manifest paths.
        $paths | Should -Contain $script:ExpectedPaths[0]
    }

    It 'lists the DiscoveryValidation module path exactly once' {
        # Assert: the module path is not duplicated in the manifest paths.
        $occurrences = @($script:Manifest.paths | Where-Object { $_ -eq $script:ExpectedPaths[0] }).Count
        $occurrences | Should -Be 1
    }

    It 'registers every on-disk discovery-validation module so none is unregistered' {
        # Arrange: enumerate the actual module files under the repo lib folder.
        $libFolder = Join-Path $script:RepoRoot '.claude/lib/discovery-validation'
        $onDisk = @(Get-ChildItem -Path $libFolder -Filter '*.psm1' -File |
                ForEach-Object { ".claude/lib/discovery-validation/$($_.Name)" })

        # Act / Assert: the expected-path list covers every on-disk module.
        foreach ($actual in $onDisk) {
            $script:ExpectedPaths | Should -Contain $actual -Because "$actual exists on disk and must be registered"
        }
    }
}

Describe 'DiscoveryValidation bundle mirror byte identity' {
    It 'mirrors the DiscoveryValidation module byte-identically into the bundle' {
        # Arrange / Act / Assert: compare repo and bundle SHA-256 hashes.
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
