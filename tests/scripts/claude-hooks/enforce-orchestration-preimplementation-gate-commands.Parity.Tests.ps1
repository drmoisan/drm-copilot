#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

# Issue #1160 - surface parity for the preimplementation gate commands sibling.
#
# The sibling ships on four surfaces: the Claude and Codex canonical hook trees and their two
# bundled push-down payloads. These cases compare SHA256 hashes across all four copies, so a
# byte-order-mark or line-ending difference is detected, and keep each copy below 500 logical
# lines (spec AC-15). They read the four files only: no temporary file, no child process, and
# no network access.

Describe 'enforce-orchestration-preimplementation-gate-commands.ps1 surface parity (issue #1160)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:SiblingFileName = 'enforce-orchestration-preimplementation-gate-commands.ps1'
        $script:SiblingSurfaceRoots = @(
            '.claude/hooks'
            '.codex/hooks'
            'extensions/drm-copilot/resources/claude-customizations/.claude/hooks'
            'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks'
        )
        $script:SiblingPaths = @(
            foreach ($root in $script:SiblingSurfaceRoots) {
                Join-Path (Join-Path $script:RepoRoot $root) $script:SiblingFileName
            }
        )
    }

    It 'keeps all four surface copies of the commands sibling byte-identical by SHA256 hash' {
        # Arrange
        $paths = $script:SiblingPaths

        # Act
        $hashes = @(foreach ($path in $paths) { (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash })
        $distinctHashes = @($hashes | Sort-Object -Unique)

        # Assert
        $hashes.Count | Should -Be 4 -Because 'every one of the four surface copies must be hashed'
        $distinctHashes.Count | Should -Be 1 -Because "the four copies must publish without drift: $($paths -join ', ')"
    }

    It 'keeps every surface copy of the commands sibling below 500 logical lines' {
        # Arrange
        $paths = $script:SiblingPaths

        # Act and Assert
        foreach ($path in $paths) {
            (Get-Content -LiteralPath $path).Count |
                Should -BeLessThan 500 -Because "$path must stay below 500 logical lines"
        }
    }
}
