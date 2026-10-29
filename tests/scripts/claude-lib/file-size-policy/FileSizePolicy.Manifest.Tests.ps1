<#
.SYNOPSIS
    Manifest-membership test for the file-size policy library and its Claude hook.

.DESCRIPTION
    Asserts that every .claude/lib/file-size-policy PowerShell file and the hook
    .claude/hooks/enforce-file-size-limit.ps1 (issue #990) are listed in the paths
    array of the core pack manifest
    (extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json)
    and ship byte-identical bundled counterparts, so push-down delivers the hook and
    the module it imports under --packs core.

    Modeled on tests/scripts/claude-lib/parallel-drift/ParallelDrift.Manifest.Tests.ps1.
    This is a file-read-only assertion. It creates no temporary files and invokes no
    external process.
#>

BeforeAll {
    # Resolve the repo root four levels up: file-size-policy -> claude-lib ->
    # scripts -> tests -> repo root.
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $manifestPath = Join-Path -Path $script:RepoRoot -ChildPath 'extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json'
    $script:ManifestPath = @((Get-Content -Path $manifestPath -Raw | ConvertFrom-Json).paths)
    $script:BundleRoot = Join-Path -Path $script:RepoRoot -ChildPath 'extensions/drm-copilot/resources/claude-customizations'

    # Discover the library files from disk rather than restating them, so a file
    # added later cannot ship without also being listed. A missing directory
    # fails the container rather than yielding a vacuous empty list.
    $libraryRoot = Join-Path -Path $script:RepoRoot -ChildPath '.claude/lib/file-size-policy'
    $script:LibraryPath = @(
        Get-ChildItem -Path $libraryRoot -File -ErrorAction Stop |
            Where-Object { $_.Extension -in @('.psm1', '.ps1') } |
                Sort-Object -Property Name |
                    ForEach-Object { ".claude/lib/file-size-policy/$($_.Name)" }
    )
    $script:ShippedPath = @($script:LibraryPath) + @('.claude/hooks/enforce-file-size-limit.ps1')
}

Describe 'File-size policy core.json manifest membership' {
    It 'discovers the file-size policy library files on disk' {
        # Assert: an empty discovery would make the membership checks vacuous.
        $script:LibraryPath.Count | Should -BeGreaterThan 0
    }

    It 'lists every discovered library file and the hook in core.json paths' {
        # Arrange / Act: the shipped files the manifest does not list.
        $missing = @($script:ShippedPath | Where-Object { $script:ManifestPath -notcontains $_ })

        # Assert: push-down must deliver the hook and every module it imports.
        $missing | Should -BeNullOrEmpty
    }

    It 'lists the hook exactly once' {
        # Arrange: count occurrences of the hook path in the manifest.
        $occurrences = @($script:ManifestPath | Where-Object { $_ -eq '.claude/hooks/enforce-file-size-limit.ps1' }).Count

        # Assert: a duplicated entry would copy the file twice during push-down.
        $occurrences | Should -Be 1
    }

    It 'ships a bundled counterpart for every shipped file' {
        # Act: look for a bundled file for each shipped file.
        $missing = @($script:ShippedPath | Where-Object {
                -not (Test-Path -Path (Join-Path -Path $script:BundleRoot -ChildPath $_) -PathType Leaf)
            })

        # Assert: the repo-root tree and the bundled tree must agree.
        $missing | Should -BeNullOrEmpty
    }

    It 'ships byte-identical bundled counterparts' {
        # Act: compare the content hash of each repository file with its bundled copy.
        $different = @($script:ShippedPath | Where-Object {
                $primary = Get-FileHash -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath $_) -Algorithm SHA256 -ErrorAction Stop
                $mirror = Get-FileHash -LiteralPath (Join-Path -Path $script:BundleRoot -ChildPath $_) -Algorithm SHA256 -ErrorAction Stop
                $primary.Hash -ne $mirror.Hash
            })

        # Assert: a bundled copy that drifted from its primary ships stale behavior.
        $different | Should -BeNullOrEmpty
    }
}
