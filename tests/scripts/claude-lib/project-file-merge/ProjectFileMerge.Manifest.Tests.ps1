<#
.SYNOPSIS
    Manifest-membership test for the project-file merge library (issue #643).

.DESCRIPTION
    Modelled on BlastRadius.Manifest.Tests.ps1. Asserts that every module and
    script under .claude/lib/project-file-merge is listed exactly once in the
    paths array of the core pack manifest and ships a bundled counterpart under
    extensions/drm-copilot/resources/claude-customizations, and additionally that
    each bundled counterpart is byte-identical to its self-hosted source.

    The hash comparison is the part the blast-radius precedent does not carry: a
    counterpart that merely exists can still be a stale copy, and a stale merge
    library resolves conflicts by rules the repository no longer holds.

    Files are discovered from disk rather than restated, so a file added later
    cannot escape the check. This suite reads files only: it creates no temporary
    file and invokes no external process.
#>

BeforeAll {
    # Resolve the repo root four levels up: project-file-merge -> claude-lib ->
    # scripts -> tests -> repo root.
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $script:BundleRoot = Join-Path $script:RepoRoot 'extensions/drm-copilot/resources/claude-customizations'
    $manifestPath = Join-Path $script:BundleRoot 'pack-manifests/core.json'
    $script:ManifestPath = @((Get-Content -Path $manifestPath -Raw | ConvertFrom-Json).paths)

    # Both extensions are discovered, because the entry script ships alongside
    # the two modules and is useless without them.
    $libraryRoot = Join-Path $script:RepoRoot '.claude/lib/project-file-merge'
    $script:LibraryPath = @(
        Get-ChildItem -Path $libraryRoot -File |
            Where-Object { $_.Extension -in @('.psm1', '.ps1') } |
                Sort-Object -Property Name |
                    ForEach-Object { ".claude/lib/project-file-merge/$($_.Name)" }
    )
}

Describe 'Project-file merge core.json manifest membership' {
    Context 'Library coverage' {
        It 'discovers the project-file merge library files on disk' {
            # Arrange / Act: the discovered library path list.
            $discovered = $script:LibraryPath

            # Assert: an empty discovery would make every check below vacuous.
            $discovered.Count | Should -BeGreaterThan 0
        }

        It 'lists every discovered library file in core.json paths' {
            # Arrange: count each discovered path's occurrences in the manifest.
            # The outer item is bound to a name first, because the inner pipeline
            # rebinds $PSItem and would otherwise compare each entry to itself.
            $offender = @($script:LibraryPath | Where-Object {
                    $candidate = $_
                    @($script:ManifestPath | Where-Object { $_ -eq $candidate }).Count -ne 1
                })

            # Assert: a missing entry ships a partial library whose imports cannot
            # resolve, and a duplicated entry copies the file twice on push-down.
            $offender | Should -BeNullOrEmpty
        }
    }

    Context 'Bundled payload parity' {
        It 'ships a byte-identical bundled counterpart for every library file' {
            # Arrange: pair each self-hosted file with its bundled counterpart.
            $offender = @($script:LibraryPath | Where-Object {
                    $bundled = Join-Path $script:BundleRoot $PSItem
                    if (-not (Test-Path -Path $bundled -PathType Leaf)) { return $true }
                    $selfHosted = Join-Path $script:RepoRoot $PSItem
                    (Get-FileHash -Algorithm SHA256 -Path $bundled).Hash -ne
                    (Get-FileHash -Algorithm SHA256 -Path $selfHosted).Hash
                })

            # Assert: an absent or stale counterpart makes the installed extension
            # resolve conflicts by rules this repository no longer holds.
            $offender | Should -BeNullOrEmpty
        }
    }
}
