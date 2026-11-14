#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Manifest-membership test for the docs runtime library under .claude/lib/docs.

.DESCRIPTION
    Discovers every file under .claude/lib/docs/ recursively as forward-slash
    repository-relative paths, drops the .claude/lib/docs/python/ subtree through the pure
    helper Select-DocsCoreManifestPath (only the python pack manifest lists that subtree),
    and asserts that each remaining path is listed exactly once in the paths array of the
    core pack manifest
    (extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json) and
    ships a byte-identical bundled counterpart.

    Modeled on tests/scripts/claude-lib/file-size-policy/FileSizePolicy.Manifest.Tests.ps1.
    This is a file-read-only assertion. It creates no temporary files and invokes no
    external process.
#>

BeforeAll {
    # Resolve the repository root four levels up: docs -> claude-lib -> scripts -> tests.
    $script:RepoRoot = [System.IO.Path]::GetFullPath((Join-Path -Path $PSScriptRoot -ChildPath '../../../..'))
    $manifestFile = Join-Path -Path $script:RepoRoot -ChildPath 'extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json'
    $script:ManifestPath = @((Get-Content -LiteralPath $manifestFile -Raw | ConvertFrom-Json).paths)
    $script:BundleRoot = Join-Path -Path $script:RepoRoot -ChildPath 'extensions/drm-copilot/resources/claude-customizations'

    function Select-DocsCoreManifestPath {
        # Pure: keeps the paths that the core manifest must list, dropping every path in the
        # .claude/lib/docs/python/ directory subtree (prefix match on the directory segment).
        param([Parameter(Mandatory = $true)] [AllowEmptyCollection()] [string[]] $Path)
        $Path | Where-Object { -not $_.StartsWith('.claude/lib/docs/python/', [System.StringComparison]::Ordinal) }
    }

    # Discover the library files from disk rather than restating them, so a file added later
    # cannot ship without also being listed. A missing directory fails the container rather
    # than yielding a vacuous empty list.
    $libraryRoot = Join-Path -Path $script:RepoRoot -ChildPath '.claude/lib/docs'
    $discovered = @(
        Get-ChildItem -LiteralPath $libraryRoot -File -Recurse -ErrorAction Stop |
            ForEach-Object { [System.IO.Path]::GetRelativePath($script:RepoRoot, $_.FullName).Replace('\', '/') } |
                Sort-Object
    )
    $script:CorePath = @(Select-DocsCoreManifestPath -Path $discovered)
}

Describe 'Select-DocsCoreManifestPath' {
    It 'drops paths in the python subtree and keeps every other path' {
        # Arrange
        $inMemory = @(
            '.claude/lib/docs/python/docs_native_analyzer.py'
            '.claude/lib/docs/python/sub/data.json'
            '.claude/lib/docs/DocsJson.psm1'
            '.claude/lib/docs/schemas/v1/common.schema.json'
            '.claude/lib/docs/DocsAnalyzerPythonNative.psm1'
            '.claude/lib/docs/pythonic/a.psm1'
        )

        # Act
        $kept = @(Select-DocsCoreManifestPath -Path $inMemory)

        # Assert: the filter matches the python/ directory segment, not the substring.
        $kept | Should -Be @(
            '.claude/lib/docs/DocsJson.psm1'
            '.claude/lib/docs/schemas/v1/common.schema.json'
            '.claude/lib/docs/DocsAnalyzerPythonNative.psm1'
            '.claude/lib/docs/pythonic/a.psm1'
        )
    }
}

Describe 'Docs core.json manifest membership' {
    It 'discovers a non-empty filtered docs file set on disk' {
        # Assert: an empty discovery would make the membership checks vacuous.
        $script:CorePath.Count | Should -BeGreaterThan 0
    }

    It 'lists every filtered docs file exactly once in core.json paths' {
        # Act: the filtered paths whose manifest occurrence count is not one.
        $wrongCount = @($script:CorePath | Where-Object {
                $candidate = $_
                @($script:ManifestPath | Where-Object { $_ -eq $candidate }).Count -ne 1
            })

        # Assert: a missing entry is not pushed down; a duplicated entry is copied twice.
        $wrongCount | Should -BeNullOrEmpty
    }

    It 'reports a path absent from an in-memory manifest (positive control)' {
        # Arrange: a manifest that omits the first discovered path.
        $partialManifest = @($script:ManifestPath | Where-Object { $_ -ne $script:CorePath[0] })

        # Act
        $missing = @($script:CorePath | Where-Object { $partialManifest -notcontains $_ })

        # Assert: the membership check can fail.
        $missing | Should -Be @($script:CorePath[0])
    }

    It 'lists no path under .claude/lib/docs/python/ in core.json' {
        # Act
        $listed = @($script:ManifestPath | Where-Object { $_.StartsWith('.claude/lib/docs/python/', [System.StringComparison]::Ordinal) })

        # Assert: only the python pack manifest lists that subtree.
        $listed | Should -BeNullOrEmpty
    }

    It 'ships a bundled counterpart for every filtered docs file' {
        # Act
        $missing = @($script:CorePath | Where-Object {
                -not (Test-Path -LiteralPath (Join-Path -Path $script:BundleRoot -ChildPath $_) -PathType Leaf)
            })

        # Assert
        $missing | Should -BeNullOrEmpty
    }

    It 'ships byte-identical bundled counterparts' {
        # Act: compare the SHA-256 of each repository file with its bundled copy.
        $different = @($script:CorePath | Where-Object {
                $primary = Get-FileHash -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath $_) -Algorithm SHA256 -ErrorAction Stop
                $mirror = Get-FileHash -LiteralPath (Join-Path -Path $script:BundleRoot -ChildPath $_) -Algorithm SHA256 -ErrorAction Stop
                $primary.Hash -ne $mirror.Hash
            })

        # Assert: a bundled copy that drifted from its primary ships stale behavior.
        $different | Should -BeNullOrEmpty
    }
}
