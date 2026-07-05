<#
.SYNOPSIS
    Manifest-membership test for the ModelRouting module.

.DESCRIPTION
    Asserts that .claude/lib/model-routing/ModelRouting.psm1 is listed in the paths
    array of the core pack manifest
    (extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json),
    so push-down delivers the module under --packs core. This is a file-read-only
    assertion that touches no tests/scripts/dev_tools file, honoring the change
    non-goals. It creates no temporary files and invokes no external process.
#>

BeforeAll {
    # Resolve the repo root four levels up: model-routing -> claude-lib -> scripts
    # -> tests -> repo root.
    $repoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $manifestPath = Join-Path $repoRoot 'extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json'
    $script:Manifest = Get-Content -Path $manifestPath -Raw | ConvertFrom-Json
    $script:ExpectedPath = '.claude/lib/model-routing/ModelRouting.psm1'
}

Describe 'ModelRouting core.json manifest membership' {
    It 'lists the ModelRouting module path in core.json paths' {
        # Arrange: the manifest paths array.
        $paths = @($script:Manifest.paths)

        # Act / Assert: the module path is a member of the manifest paths.
        $paths | Should -Contain $script:ExpectedPath
    }

    It 'lists the ModelRouting module path exactly once' {
        # Arrange: count occurrences of the module path in the manifest.
        $occurrences = @($script:Manifest.paths | Where-Object { $_ -eq $script:ExpectedPath }).Count

        # Assert: the entry appears exactly once (no duplicate).
        $occurrences | Should -Be 1
    }
}
