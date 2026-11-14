<#
.SYNOPSIS
    Manifest-membership test for the review/verdict library files.

.DESCRIPTION
    Asserts that .claude/lib/review-verdict/ReviewVerdictEligibility.psm1 and
    .claude/lib/review-verdict/Invoke-ReviewVerdictStatus.ps1 (issue #1097) are each listed exactly
    once in the paths array of the core pack manifest
    (extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json) and that each
    ships a byte-identical bundled counterpart, so push-down delivers the entry point and the module
    it imports under --packs core.

    Modeled on tests/scripts/claude-lib/ci-gate/MergeConfirmationParser.Manifest.Tests.ps1. This is
    a file-read-only assertion. It creates no temporary files and invokes no external process.
#>

BeforeAll {
    # Resolve the repo root four levels up: review-verdict -> claude-lib -> scripts -> tests -> repo root.
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $manifestPath = Join-Path -Path $script:RepoRoot -ChildPath 'extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json'
    $script:ManifestPath = @((Get-Content -Path $manifestPath -Raw | ConvertFrom-Json).paths)
    $script:BundleRoot = Join-Path -Path $script:RepoRoot -ChildPath 'extensions/drm-copilot/resources/claude-customizations'
    $script:ExpectedPath = @(
        '.claude/lib/review-verdict/ReviewVerdictEligibility.psm1'
        '.claude/lib/review-verdict/Invoke-ReviewVerdictStatus.ps1'
    )
}

Describe 'Review-verdict core.json manifest membership' {
    It 'lists <Path> exactly once in core.json paths' -TestCases @(
        @{ Path = '.claude/lib/review-verdict/ReviewVerdictEligibility.psm1' }
        @{ Path = '.claude/lib/review-verdict/Invoke-ReviewVerdictStatus.ps1' }
    ) {
        param($Path)
        # Arrange / Act: count occurrences of the path in the manifest.
        $occurrences = @($script:ManifestPath | Where-Object { $_ -ceq $Path }).Count

        # Assert: a missing entry is not pushed down; a duplicate is copied twice.
        $occurrences | Should -Be 1
    }

    It 'ships a byte-identical bundled copy of <Path>' -TestCases @(
        @{ Path = '.claude/lib/review-verdict/ReviewVerdictEligibility.psm1' }
        @{ Path = '.claude/lib/review-verdict/Invoke-ReviewVerdictStatus.ps1' }
    ) {
        param($Path)
        # Act: hash the repository file and its bundled copy.
        $primary = Get-FileHash -LiteralPath (Join-Path -Path $script:RepoRoot -ChildPath $Path) -Algorithm SHA256 -ErrorAction Stop
        $mirror = Get-FileHash -LiteralPath (Join-Path -Path $script:BundleRoot -ChildPath $Path) -Algorithm SHA256 -ErrorAction Stop

        # Assert: a bundled copy that drifted from its primary ships stale behavior.
        $mirror.Hash | Should -Be $primary.Hash
    }

    It 'covers every library file on disk' {
        # Arrange / Act: the library files the expected list does not name.
        $onDisk = @(Get-ChildItem -Path (Join-Path -Path $script:RepoRoot -ChildPath '.claude/lib/review-verdict') -File -ErrorAction Stop |
                ForEach-Object { ".claude/lib/review-verdict/$($_.Name)" })
        $unlisted = @($onDisk | Where-Object { $script:ExpectedPath -cnotcontains $_ })

        # Assert: a file added later must also be manifested and bundled.
        $onDisk.Count | Should -Be 2
        $unlisted | Should -BeNullOrEmpty
    }
}
