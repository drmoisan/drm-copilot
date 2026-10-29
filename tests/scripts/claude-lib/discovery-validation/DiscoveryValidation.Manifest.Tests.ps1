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
        '.claude/lib/discovery-validation/DiscoveryValidation.psm1',
        '.claude/lib/discovery-validation/DiscoveryAuthority.psd1',
        '.claude/lib/discovery-validation/DiscoveryAuthority.psm1',
        '.claude/lib/discovery-validation/DiscoveryAuthorization.psm1',
        '.claude/lib/discovery-validation/DiscoveryEncoding.psm1',
        '.claude/lib/discovery-validation/DiscoveryManifest.psm1',
        '.claude/lib/discovery-validation/DiscoveryPayload.psm1',
        '.claude/lib/discovery-validation/DiscoveryToolRouting.psm1',
        '.claude/lib/discovery-validation/DiscoveryRootGrant.psm1',
        '.claude/lib/discovery-validation/DiscoveryStart.psm1',
        '.claude/lib/discovery-validation/DiscoveryStartRecord.psm1',
        '.claude/lib/discovery-validation/DiscoveryStop.psm1',
        '.claude/lib/discovery-validation/DiscoveryPlanning.psm1',
        '.claude/lib/discovery-validation/DiscoveryCapability.psm1'
    )
    # The Codex bundle publishes the same helpers under .codex/lib through the shared
    # resource directory (issue #980, P8-T9 mapping); the compatibility module stays Claude-only.
    $script:CodexPublishedNames = @(
        'DiscoveryAuthority.psd1',
        'DiscoveryAuthority.psm1',
        'DiscoveryAuthorization.psm1',
        'DiscoveryEncoding.psm1',
        'DiscoveryManifest.psm1',
        'DiscoveryPayload.psm1',
        'DiscoveryToolRouting.psm1',
        'DiscoveryRootGrant.psm1',
        'DiscoveryStart.psm1',
        'DiscoveryStartRecord.psm1',
        'DiscoveryStop.psm1',
        'DiscoveryPlanning.psm1',
        'DiscoveryCapability.psm1'
    )
    $codexManifestPath = Join-Path $repoRoot 'extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json'
    $script:CodexManifest = Get-Content -Path $codexManifestPath -Raw | ConvertFrom-Json
}

Describe 'DiscoveryValidation core.json manifest membership' {
    It 'lists every discovery-validation helper path in core.json paths exactly once' {
        # Arrange: the manifest paths array.
        $paths = @($script:Manifest.paths)

        # Act / Assert: each helper path is a member of the manifest paths, once.
        foreach ($expected in $script:ExpectedPaths) {
            $paths | Should -Contain $expected
            @($paths | Where-Object { $_ -eq $expected }).Count | Should -Be 1 -Because "$expected must be registered once"
        }
    }

    It 'registers every on-disk discovery-validation module so none is unregistered' {
        # Arrange: enumerate the actual module and manifest files under the repo lib folder.
        $libFolder = Join-Path $script:RepoRoot '.claude/lib/discovery-validation'
        $onDisk = @(Get-ChildItem -Path $libFolder -File |
                Where-Object { $_.Extension -in @('.psm1', '.psd1') } |
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

Describe 'Codex bundle helper publication' {
    It 'stores each shared helper byte-identically under the Codex resource directory and lists its .codex/lib destination in core.json' {
        # Arrange: the P8-T9 directory mapping publishes resources/lib/discovery-validation/<name>
        # to .codex/lib/discovery-validation/<name>.
        $codexPaths = @($script:CodexManifest.paths)
        foreach ($name in $script:CodexPublishedNames) {
            $repoFile = Join-Path $script:RepoRoot ".claude/lib/discovery-validation/$name"
            $resourceFile = Join-Path $script:RepoRoot "extensions/drm-copilot/resources/lib/discovery-validation/$name"

            # Act / Assert
            Test-Path -LiteralPath $resourceFile | Should -BeTrue -Because "$name must be stored as a Codex helper resource"
            (Get-FileHash -Algorithm SHA256 -LiteralPath $resourceFile).Hash | Should -Be (Get-FileHash -Algorithm SHA256 -LiteralPath $repoFile).Hash
            $codexPaths | Should -Contain ".codex/lib/discovery-validation/$name"
        }
    }
}
