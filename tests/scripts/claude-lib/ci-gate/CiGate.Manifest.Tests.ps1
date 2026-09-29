<#
.SYNOPSIS
    Manifest-membership test for the CI gate parser.

.DESCRIPTION
    Asserts that .claude/lib/ci-gate/Invoke-CiGateParser.ps1 is listed in the paths
    array of the core pack manifest
    (extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json),
    so push-down delivers the parser with the orchestrate and epic-orchestrate skills
    under --packs core (issue #762). This is a file-read-only assertion. It creates
    no temporary files and invokes no external process.
#>

BeforeAll {
    # Resolve the repo root four levels up: ci-gate -> claude-lib -> scripts
    # -> tests -> repo root.
    $repoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $manifestPath = Join-Path $repoRoot 'extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json'
    $script:Manifest = Get-Content -Path $manifestPath -Raw | ConvertFrom-Json
    $script:ExpectedPath = '.claude/lib/ci-gate/Invoke-CiGateParser.ps1'
}

Describe 'CiGate core.json manifest membership' {
    It 'lists the CI gate parser path in core.json paths' {
        # Arrange: the manifest paths array.
        $paths = @($script:Manifest.paths)

        # Act / Assert: the parser path is a member of the manifest paths.
        $paths | Should -Contain $script:ExpectedPath
    }

    It 'lists the CI gate parser path exactly once' {
        # Arrange: count occurrences of the parser path in the manifest.
        $occurrences = @($script:Manifest.paths | Where-Object { $_ -eq $script:ExpectedPath }).Count

        # Assert: the entry appears exactly once (no duplicate).
        $occurrences | Should -Be 1
    }
}
