<#
.SYNOPSIS
    Manifest-membership test for the blast-radius library modules.

.DESCRIPTION
    Asserts that every .claude/lib/blast-radius/*.psm1 module is listed in the
    paths array of the core pack manifest
    (extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json),
    so push-down delivers the whole library under --packs core. A partially
    listed library would ship a facade whose sibling imports cannot resolve.

    This is a file-read-only assertion following the issue #312 ModelRouting
    manifest-membership precedent. It creates no temporary files and invokes no
    external process.
#>

BeforeAll {
    # Resolve the repo root four levels up: blast-radius -> claude-lib -> scripts
    # -> tests -> repo root.
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $manifestPath = Join-Path $script:RepoRoot 'extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json'
    $script:ManifestPath = @((Get-Content -Path $manifestPath -Raw | ConvertFrom-Json).paths)

    # Discover the library modules from disk rather than restating them, so a
    # future module cannot be added without also being listed in the manifest.
    $libraryRoot = Join-Path $script:RepoRoot '.claude/lib/blast-radius'
    $script:ModulePath = @(
        Get-ChildItem -Path $libraryRoot -Filter '*.psm1' -File |
            Sort-Object -Property Name |
                ForEach-Object { ".claude/lib/blast-radius/$($_.Name)" }
    )
}

Describe 'Blast-radius core.json manifest membership' {
    Context 'Library coverage' {
        It 'discovers the blast-radius library modules on disk' {
            # Arrange / Act: the discovered module path list.
            $discovered = $script:ModulePath

            # Assert: an empty discovery would make the membership check vacuous.
            $discovered.Count | Should -BeGreaterThan 0
        }

        It 'lists every discovered library module in core.json paths' {
            # Arrange: the manifest paths and the discovered modules.
            $missing = @($script:ModulePath | Where-Object { $script:ManifestPath -notcontains $_ })

            # Act / Assert: push-down must deliver the whole library.
            $missing | Should -BeNullOrEmpty
        }

        It 'lists the facade module exactly once' {
            # Arrange: count occurrences of the facade path in the manifest.
            $expected = '.claude/lib/blast-radius/BlastRadius.psm1'
            $occurrences = @($script:ManifestPath | Where-Object { $_ -eq $expected }).Count

            # Assert: a duplicated entry would copy the file twice during push-down.
            $occurrences | Should -Be 1
        }
    }

    Context 'Bundled payload parity' {
        It 'ships a bundled counterpart for every library module' {
            # Arrange: the bundled customization payload root.
            $bundleRoot = Join-Path $script:RepoRoot 'extensions/drm-copilot/resources/claude-customizations'

            # Act: look for a bundled file for each discovered module.
            $missing = @($script:ModulePath | Where-Object {
                    -not (Test-Path -Path (Join-Path $bundleRoot $_) -PathType Leaf)
                })

            # Assert: the repo-root tree and the bundled tree must agree.
            $missing | Should -BeNullOrEmpty
        }
    }
}
