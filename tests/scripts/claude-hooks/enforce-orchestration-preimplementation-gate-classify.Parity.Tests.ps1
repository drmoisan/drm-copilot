#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

# Issue #1188 - surface parity for the preimplementation gate classification supplement.
#
# enforce-orchestration-preimplementation-gate-classify.ps1 ships on four surfaces: the Claude
# and Codex canonical hook trees and their two bundled push-down payloads. These cases compare
# real SHA256 hashes across all four copies, which detects a byte-order-mark or line-ending
# difference that a decoded-text comparison cannot, and keep each copy within a pinned per-file
# bound of 500 lines. The wording rows read the ## Hook Execution Context section of the six
# execution-environment brief copies. The file creates no file, starts no child process, and
# makes no network access.

Describe 'enforce-orchestration-preimplementation-gate-classify.ps1 surface parity (issue #1188)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:ClassifyFileName = 'enforce-orchestration-preimplementation-gate-classify.ps1'
        $script:ClassifySurfaceRoots = @(
            '.claude/hooks'
            '.codex/hooks'
            'extensions/drm-copilot/resources/claude-customizations/.claude/hooks'
            'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks'
        )
        $script:ClassifyPaths = @(
            foreach ($root in $script:ClassifySurfaceRoots) {
                Join-Path (Join-Path $script:RepoRoot $root) $script:ClassifyFileName
            }
        )
    }

    It 'keeps all four surface copies of the classify sibling byte-identical by SHA256 hash' {
        # Arrange
        $paths = $script:ClassifyPaths

        # Act
        $hashes = @(foreach ($path in $paths) { (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash })
        $distinctHashes = @($hashes | Sort-Object -Unique)

        # Assert
        $hashes.Count | Should -Be 4 -Because 'every one of the four surface copies must be hashed'
        $distinctHashes.Count | Should -Be 1 -Because "the four copies must publish without drift: $($paths -join ', ')"
    }

    It 'keeps every surface copy of the classify sibling within its pinned 500-line bound' {
        # Arrange
        $paths = $script:ClassifyPaths

        # Act and Assert
        foreach ($path in $paths) {
            (Get-Content -LiteralPath $path).Count |
                Should -BeLessOrEqual 500 -Because "$path must stay within its pinned per-file bound of 500 lines"
        }
    }

    It 'states the issue #1188 classification supplement in the Hook Execution Context section of <Copy>' -ForEach @(
        @{ Copy = '.claude/skills/execution-environment/SKILL.md' }
        @{ Copy = '.agents/skills/execution-environment/SKILL.md' }
        @{ Copy = '.github/skills/execution-environment/SKILL.md' }
        @{ Copy = 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md' }
        @{ Copy = 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md' }
        @{ Copy = 'extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md' }
    ) {
        # Arrange
        $text = [System.IO.File]::ReadAllText((Join-Path $script:RepoRoot $Copy))
        $start = $text.IndexOf("`n## Hook Execution Context", [System.StringComparison]::Ordinal)
        $end = if ($start -ge 0) { $text.IndexOf("`n## ", $start + 1, [System.StringComparison]::Ordinal) } else { -1 }

        # Act
        $section = if ($start -ge 0 -and $end -gt $start) { $text.Substring($start, $end - $start) } else { '' }

        # Assert
        $section | Should -Not -BeNullOrEmpty -Because "$Copy must carry a bounded ## Hook Execution Context section"
        foreach ($token in @('enforce-orchestration-preimplementation-gate-classify.ps1', 'npx --yes', 'inline option value')) {
            $section.Contains($token) | Should -BeTrue -Because "the Hook Execution Context section of $Copy must name $token"
        }
    }
}
