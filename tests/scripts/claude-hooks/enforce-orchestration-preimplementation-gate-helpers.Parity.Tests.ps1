#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

# Issue #671 - surface parity for the preimplementation gate helpers module.
#
# The helpers module ships on four surfaces: the Claude and Codex canonical hook trees and
# their two bundled push-down payloads. The Codex pair is already hash-asserted by
# `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, but the Claude pair is
# only compared as decoded text, which cannot detect a byte-order-mark or line-ending
# difference. These cases compare real SHA256 hashes across all four copies and keep each
# copy under the repository's 500-line cap. They read the four files only: no temporary
# file, no child process, and no network access.

Describe 'enforce-orchestration-preimplementation-gate-helpers.ps1 surface parity (issue #671)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:HelpersFileName = 'enforce-orchestration-preimplementation-gate-helpers.ps1'
        $script:HelpersSurfaceRoots = @(
            '.claude/hooks'
            '.codex/hooks'
            'extensions/drm-copilot/resources/claude-customizations/.claude/hooks'
            'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks'
        )
        $script:HelpersPaths = @(
            foreach ($root in $script:HelpersSurfaceRoots) {
                Join-Path (Join-Path $script:RepoRoot $root) $script:HelpersFileName
            }
        )
    }

    It 'keeps all four surface copies of the helpers module byte-identical by SHA256 hash' {
        # Arrange
        $paths = $script:HelpersPaths

        # Act
        $hashes = @(foreach ($path in $paths) { (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash })
        $distinctHashes = @($hashes | Sort-Object -Unique)

        # Assert
        $hashes.Count | Should -Be 4 -Because 'every one of the four surface copies must be hashed'
        $distinctHashes.Count | Should -Be 1 -Because "the four copies must publish without drift: $($paths -join ', ')"
    }

    It 'keeps every surface copy of the helpers module under the 500-line cap' {
        # Arrange
        $paths = $script:HelpersPaths

        # Act and Assert
        foreach ($path in $paths) {
            (Get-Content -LiteralPath $path).Count |
                Should -BeLessOrEqual 500 -Because "$path must stay within the repository file-size limit"
        }
    }
}
