#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

# Issue #1188 - surface parity for the preimplementation gate command-operand sibling.
#
# enforce-orchestration-preimplementation-gate-operands.ps1 ships on four surfaces: the Claude
# and Codex canonical hook trees and their two bundled push-down payloads. These cases compare
# real SHA256 hashes across all four copies, which detects a byte-order-mark or line-ending
# difference that a decoded-text comparison cannot, and keep each copy within a pinned per-file
# bound of 500 lines. They read the four files only: the file creates no file, starts no child
# process, and makes no network access.

Describe 'enforce-orchestration-preimplementation-gate-operands.ps1 surface parity (issue #1188)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:OperandsFileName = 'enforce-orchestration-preimplementation-gate-operands.ps1'
        $script:OperandsSurfaceRoots = @(
            '.claude/hooks'
            '.codex/hooks'
            'extensions/drm-copilot/resources/claude-customizations/.claude/hooks'
            'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks'
        )
        $script:OperandsPaths = @(
            foreach ($root in $script:OperandsSurfaceRoots) {
                Join-Path (Join-Path $script:RepoRoot $root) $script:OperandsFileName
            }
        )
    }

    It 'keeps all four surface copies of the operands sibling byte-identical by SHA256 hash' {
        # Arrange
        $paths = $script:OperandsPaths

        # Act
        $hashes = @(foreach ($path in $paths) { (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash })
        $distinctHashes = @($hashes | Sort-Object -Unique)

        # Assert
        $hashes.Count | Should -Be 4 -Because 'every one of the four surface copies must be hashed'
        $distinctHashes.Count | Should -Be 1 -Because "the four copies must publish without drift: $($paths -join ', ')"
    }

    It 'keeps every surface copy of the operands sibling within its pinned 500-line bound' {
        # Arrange
        $paths = $script:OperandsPaths

        # Act and Assert
        foreach ($path in $paths) {
            (Get-Content -LiteralPath $path).Count |
                Should -BeLessOrEqual 500 -Because "$path must stay within its pinned per-file bound of 500 lines"
        }
    }
}
