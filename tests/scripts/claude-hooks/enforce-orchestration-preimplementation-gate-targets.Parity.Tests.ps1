#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

# Issue #738 - surface parity for the preimplementation gate targets module.
#
# The targets module ships on four surfaces: the Claude and Codex canonical hook trees and
# their two bundled push-down payloads. These cases compare real SHA256 hashes across all
# four copies, which detects a byte-order-mark or line-ending difference that a decoded-text
# comparison cannot, and keep each copy within a pinned per-file bound of 500 lines, stricter
# than the 800-line hard limit of the tiered file-size policy. They read the
# four files only: the file creates no file and starts no child process, and makes no network
# access.

Describe 'enforce-orchestration-preimplementation-gate-targets.ps1 surface parity (issue #738)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:TargetsFileName = 'enforce-orchestration-preimplementation-gate-targets.ps1'
        $script:TargetsSurfaceRoots = @(
            '.claude/hooks'
            '.codex/hooks'
            'extensions/drm-copilot/resources/claude-customizations/.claude/hooks'
            'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks'
        )
        $script:TargetsPaths = @(
            foreach ($root in $script:TargetsSurfaceRoots) {
                Join-Path (Join-Path $script:RepoRoot $root) $script:TargetsFileName
            }
        )
    }

    It 'keeps all four surface copies of the targets module byte-identical by SHA256 hash' {
        # Arrange
        $paths = $script:TargetsPaths

        # Act
        $hashes = @(foreach ($path in $paths) { (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash })
        $distinctHashes = @($hashes | Sort-Object -Unique)

        # Assert
        $hashes.Count | Should -Be 4 -Because 'every one of the four surface copies must be hashed'
        $distinctHashes.Count | Should -Be 1 -Because "the four copies must publish without drift: $($paths -join ', ')"
    }

    It 'keeps every surface copy of the targets module within its pinned 500-line bound' {
        # Arrange
        $paths = $script:TargetsPaths

        # Act and Assert
        foreach ($path in $paths) {
            (Get-Content -LiteralPath $path).Count |
                Should -BeLessOrEqual 500 -Because "$path must stay within its pinned per-file bound of 500 lines"
        }
    }

    It 'keeps every line of every surface copy at or under 120 characters (issue #903, #732 CR-4)' {
        # Arrange
        $paths = $script:TargetsPaths

        # Act and Assert
        foreach ($path in $paths) {
            $longLineCount = @(Get-Content -LiteralPath $path | Where-Object { $_.Length -gt 120 }).Count
            $longLineCount | Should -Be 0 -Because "$path must keep every line at or under 120 characters"
        }
    }
}
