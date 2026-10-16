<#
.SYNOPSIS
    Manifest-membership test for the merge-confirmation parser.

.DESCRIPTION
    Asserts that .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1 is listed in the
    paths array of the core pack manifest
    (extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json),
    so push-down delivers the parser with the orchestrate, parallel-orchestrate, and
    epic-orchestrate skills under --packs core (issue #952). This is a file-read-only
    assertion. It creates no temporary files and invokes no external process.
#>

BeforeAll {
    # Resolve the repo root four levels up: ci-gate -> claude-lib -> scripts
    # -> tests -> repo root.
    $repoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $manifestPath = Join-Path $repoRoot 'extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json'
    $script:Manifest = Get-Content -Path $manifestPath -Raw | ConvertFrom-Json
    $script:ExpectedPath = '.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1'
}

Describe 'MergeConfirmationParser core.json manifest membership' {
    It 'lists the merge confirmation parser path in core.json paths' {
        # Arrange: the manifest paths array.
        $paths = @($script:Manifest.paths)

        # Act / Assert: the parser path is a member of the manifest paths.
        $paths | Should -Contain $script:ExpectedPath
    }

    It 'lists the merge confirmation parser path exactly once' {
        # Arrange: count occurrences of the parser path in the manifest.
        $occurrences = @($script:Manifest.paths | Where-Object { $_ -eq $script:ExpectedPath }).Count

        # Assert: the entry appears exactly once (no duplicate).
        $occurrences | Should -Be 1
    }
}
