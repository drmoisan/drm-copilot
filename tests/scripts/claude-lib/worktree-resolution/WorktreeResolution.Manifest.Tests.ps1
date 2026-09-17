#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Manifest-membership and bundle-mirror test for the worktree-resolution modules (issue #669).

.DESCRIPTION
    Asserts that both .claude/lib/worktree-resolution modules are listed exactly once in
    the paths array of the core pack manifest
    (extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json), so
    push-down delivers them under --packs core; that every on-disk module in the folder
    is registered; and that each module is mirrored with an identical SHA-256 hash into
    extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/.
    Follows tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Manifest.Tests.ps1.

    This is a file-read-only assertion: it creates no temporary file, reads no wall
    clock, touches no network, and invokes no external process.
#>

BeforeAll {
    # Resolve the repo root four levels up: worktree-resolution -> claude-lib ->
    # scripts -> tests -> repo root. The manifest is decoded once.
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $manifestPath = Join-Path $script:RepoRoot 'extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json'
    $script:Manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
    $script:ExpectedPaths = @(
        '.claude/lib/worktree-resolution/WorktreeResolution.psm1'
        '.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1'
    )
}

Describe 'WorktreeResolution core.json manifest membership' {
    It 'lists <_> in core.json paths' -ForEach @(
        '.claude/lib/worktree-resolution/WorktreeResolution.psm1'
        '.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1'
    ) {
        # Arrange: the manifest paths array.
        $paths = @($script:Manifest.paths)

        # Act / Assert: the module path is a member, so push-down delivers it.
        $paths | Should -Contain $_
    }

    It 'lists <_> exactly once' -ForEach @(
        '.claude/lib/worktree-resolution/WorktreeResolution.psm1'
        '.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1'
    ) {
        # Arrange / Act: count exact string-equality survivors.
        $expected = $_
        $occurrences = @($script:Manifest.paths | Where-Object { $_ -eq $expected }).Count

        # Assert: a duplicate entry would indicate a merge error in the manifest.
        $occurrences | Should -Be 1
    }

    It 'registers every on-disk worktree-resolution module so none is unregistered' {
        # Arrange: enumerate the actual module files under the repo lib folder.
        $libFolder = Join-Path $script:RepoRoot '.claude/lib/worktree-resolution'
        $onDisk = @(Get-ChildItem -LiteralPath $libFolder -Filter '*.psm1' -File |
                ForEach-Object { ".claude/lib/worktree-resolution/$($_.Name)" })

        # Act / Assert: the folder is not empty, and the expected-path list covers every module.
        $onDisk.Count | Should -BeGreaterThan 0
        foreach ($actual in $onDisk) {
            $script:ExpectedPaths | Should -Contain $actual -Because "$actual exists on disk and must be registered"
        }
    }
}

Describe 'WorktreeResolution bundle mirror byte identity' {
    It 'mirrors <_> byte-identically into the bundle' -ForEach @(
        '.claude/lib/worktree-resolution/WorktreeResolution.psm1'
        '.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1'
    ) {
        # Arrange: the repo-side file and its bundle counterpart.
        $repoFile = Join-Path $script:RepoRoot $_
        $bundleFile = Join-Path $script:RepoRoot "extensions/drm-copilot/resources/claude-customizations/$_"

        # Act: the bundle file must exist before its hash is compared.
        Test-Path -LiteralPath $bundleFile | Should -BeTrue -Because "$_ must exist in the bundle mirror"
        $repoHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $repoFile).Hash
        $bundleHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $bundleFile).Hash

        # Assert: push-down serves the bundle, so any drift ships stale code.
        $bundleHash | Should -Be $repoHash -Because "$_ must be mirrored byte-identically"
    }
}
