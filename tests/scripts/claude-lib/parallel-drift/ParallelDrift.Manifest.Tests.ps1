<#
.SYNOPSIS
    Manifest-membership test for the parallel drift library files.

.DESCRIPTION
    Asserts that every .claude/lib/parallel-drift PowerShell file (issue #763) is
    listed in the paths array of the core pack manifest
    (extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json)
    and ships a byte-identical bundled counterpart, so push-down delivers the
    drift entry point and both modules it imports under --packs core.

    Modeled on tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1.
    This is a file-read-only assertion. It creates no temporary files and invokes
    no external process.
#>

BeforeAll {
    # Resolve the repo root four levels up: parallel-drift -> claude-lib ->
    # scripts -> tests -> repo root.
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $manifestPath = Join-Path -Path $script:RepoRoot -ChildPath 'extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json'
    $script:ManifestPath = @((Get-Content -Path $manifestPath -Raw | ConvertFrom-Json).paths)
    $script:BundleRoot = Join-Path -Path $script:RepoRoot -ChildPath 'extensions/drm-copilot/resources/claude-customizations'

    # Discover the library files from disk rather than restating them, so a file
    # added later cannot ship without also being listed. A missing directory
    # fails the container rather than yielding a vacuous empty list.
    $libraryRoot = Join-Path -Path $script:RepoRoot -ChildPath '.claude/lib/parallel-drift'
    $script:LibraryPath = @(
        Get-ChildItem -Path $libraryRoot -File -ErrorAction Stop |
            Where-Object { $_.Extension -in @('.psm1', '.ps1') } |
            Sort-Object -Property Name |
            ForEach-Object { ".claude/lib/parallel-drift/$($_.Name)" }
    )
}

Describe 'Parallel-drift core.json manifest membership' {
    It 'discovers the parallel-drift library files on disk' {
        # Assert: an empty discovery would make the membership checks vacuous.
        $script:LibraryPath.Count | Should -BeGreaterThan 0
    }

    It 'lists every discovered library file in core.json paths' {
        # Arrange / Act: the discovered files the manifest does not list.
        $missing = @($script:LibraryPath | Where-Object { $script:ManifestPath -notcontains $_ })

        # Assert: push-down must deliver the whole library.
        $missing | Should -BeNullOrEmpty
    }

    It 'lists the entry script exactly once' {
        # Arrange: count occurrences of the entry-script path in the manifest.
        $expected = '.claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1'
        $occurrences = @($script:ManifestPath | Where-Object { $_ -eq $expected }).Count

        # Assert: a duplicated entry would copy the file twice during push-down.
        $occurrences | Should -Be 1
    }

    It 'ships a bundled counterpart for every library file' {
        # Act: look for a bundled file for each discovered library file.
        $missing = @($script:LibraryPath | Where-Object {
                -not (Test-Path -Path (Join-Path -Path $script:BundleRoot -ChildPath $_) -PathType Leaf)
            })

        # Assert: the repo-root tree and the bundled tree must agree.
        $missing | Should -BeNullOrEmpty
    }

    It 'ships byte-identical bundled counterparts' {
        # Act: compare the content hash of each repository file with its bundled copy.
        $different = @($script:LibraryPath | Where-Object {
                $primary = Get-FileHash -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath $_) -Algorithm SHA256 -ErrorAction Stop
                $mirror = Get-FileHash -LiteralPath (Join-Path -Path $script:BundleRoot -ChildPath $_) -Algorithm SHA256 -ErrorAction Stop
                $primary.Hash -ne $mirror.Hash
            })

        # Assert: a bundled copy that drifted from its primary ships stale behavior.
        $different | Should -BeNullOrEmpty
    }
}
