#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Codex copy of the feature-review coverage threshold resolver (issue #896, E4-PX2).

.DESCRIPTION
    E4-PX2 asserts that the four copies of feature-review-coverage-thresholds.ps1 (the
    Claude and Codex repository copies and their two bundle mirrors) are byte-identical.
    The E4-PX2-<Id> rows run the resolver cases of the Claude suite
    (tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1: the eleven
    T824 rows and the nine E4-TR5 rows) against the .codex/hooks copy, which is the copy
    the Codex feature-review hook dot-sources.

    Determinism: every resolver case is a pure string case. The byte-identity case reads the
    four committed files through Get-FileHash. No temporary file, no child process, no clock,
    and no other disk read beyond dot-sourcing the file under test.
#>

Describe 'Codex feature-review-coverage-thresholds copy (issue #896)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
        . (Join-Path $script:RepoRoot '.codex/hooks/feature-review-coverage-thresholds.ps1')
    }

    It 'E4-PX2: the four thresholds copies are byte-identical' {
        # Arrange
        $copies = @(
            '.claude/hooks/feature-review-coverage-thresholds.ps1'
            '.codex/hooks/feature-review-coverage-thresholds.ps1'
            'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/feature-review-coverage-thresholds.ps1'
            'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/feature-review-coverage-thresholds.ps1'
        )

        # Act
        $hashes = @($copies | ForEach-Object { (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $script:RepoRoot $_)).Hash })

        # Assert
        @($hashes | Sort-Object -Unique).Count | Should -Be 1 -Because ("the thresholds copies must be byte-identical: " + ($hashes -join ', '))
    }

    It 'E4-PX2-<Id> the Codex copy resolves <Label>' -ForEach @(
        @{ Id = 'T824-1'; Label = 'no root CLAUDE.md text'; Text = $null; Line = 85; Branch = 75; LineSource = 'default'; BranchSource = 'default' }
        @{ Id = 'T824-2'; Label = 'text without figures'; Text = 'Project notes only.'; Line = 85; Branch = 75; LineSource = 'default'; BranchSource = 'default' }
        @{ Id = 'T824-3'; Label = 'lower line and branch figures'; Text = "Line coverage must remain >= 70%.`nBranch coverage must remain >= 60%."; Line = 70; Branch = 60; LineSource = 'claude-md'; BranchSource = 'claude-md' }
        @{ Id = 'T824-4'; Label = 'a line-only figure'; Text = 'Line coverage: >= 70%'; Line = 70; Branch = 75; LineSource = 'claude-md'; BranchSource = 'default' }
        @{ Id = 'T824-5'; Label = 'a branch-only figure'; Text = 'Branch coverage >= 65%'; Line = 85; Branch = 65; LineSource = 'default'; BranchSource = 'claude-md' }
        @{ Id = 'T824-6'; Label = 'a decimal figure'; Text = 'line coverage of at least 82.5%'; Line = 82.5; Branch = 75; LineSource = 'claude-md'; BranchSource = 'default' }
        @{ Id = 'T824-7'; Label = 'a figure above 100'; Text = 'Line coverage >= 150%'; Line = 85; Branch = 75; LineSource = 'default'; BranchSource = 'default' }
        @{ Id = 'T824-8'; Label = 'a prose figure without a comparator'; Text = 'Line coverage was 62% last release.'; Line = 85; Branch = 75; LineSource = 'default'; BranchSource = 'default' }
        @{ Id = 'T824-9'; Label = 'the combined line-and-branch limitation'; Text = 'Line and branch coverage >= 70%.'; Line = 85; Branch = 75; LineSource = 'default'; BranchSource = 'default' }
        @{ Id = 'T824-10'; Label = 'a minimum phrase'; Text = 'Branch coverage minimum: 60%'; Line = 85; Branch = 60; LineSource = 'default'; BranchSource = 'claude-md' }
        @{ Id = 'T824-11'; Label = 'two no-less-than statements on one line'; Text = 'Line coverage no less than 72% and branch coverage no less than 61%.'; Line = 72; Branch = 61; LineSource = 'claude-md'; BranchSource = 'claude-md' }
        @{ Id = 'TR5-P1'; Label = 'line coverage: 70% minimum'; Text = 'line coverage: 70% minimum'; Line = 70; Branch = 75; LineSource = 'claude-md'; BranchSource = 'default' }
        @{ Id = 'TR5-P2'; Label = 'line coverage 80% at least'; Text = 'line coverage 80% at least'; Line = 80; Branch = 75; LineSource = 'claude-md'; BranchSource = 'default' }
        @{ Id = 'TR5-P3'; Label = 'line coverage of 80% or more'; Text = 'line coverage of 80% or more'; Line = 80; Branch = 75; LineSource = 'claude-md'; BranchSource = 'default' }
        @{ Id = 'TR5-P4'; Label = 'branch coverage: 60% or higher'; Text = 'branch coverage: 60% or higher'; Line = 85; Branch = 60; LineSource = 'default'; BranchSource = 'claude-md' }
        @{ Id = 'TR5-P5'; Label = 'line coverage 81% or above'; Text = 'line coverage 81% or above'; Line = 81; Branch = 75; LineSource = 'claude-md'; BranchSource = 'default' }
        @{ Id = 'TR5-P6'; Label = 'branch coverage 62% or greater'; Text = 'branch coverage 62% or greater'; Line = 85; Branch = 62; LineSource = 'default'; BranchSource = 'claude-md' }
        @{ Id = 'TR5-N1'; Label = 'Line coverage was 62% last release'; Text = 'Line coverage was 62% last release'; Line = 85; Branch = 75; LineSource = 'default'; BranchSource = 'default' }
        @{ Id = 'TR5-N2'; Label = 'Line and branch coverage: 70% minimum'; Text = 'Line and branch coverage: 70% minimum'; Line = 85; Branch = 75; LineSource = 'default'; BranchSource = 'default' }
        @{ Id = 'TR5-N3'; Label = 'line coverage: 150% minimum'; Text = 'line coverage: 150% minimum'; Line = 85; Branch = 75; LineSource = 'default'; BranchSource = 'default' }
    ) {
        # Arrange: the row supplies Text and the expected thresholds and sources.

        # Act
        $result = Get-FeatureReviewCoverageThreshold -ClaudeMdText $Text

        # Assert
        $result.Line | Should -Be $Line -Because "the governing line threshold for '$Text'"
        $result.Branch | Should -Be $Branch -Because "the governing branch threshold for '$Text'"
        $result.LineSource | Should -Be $LineSource
        $result.BranchSource | Should -Be $BranchSource
    }
}
