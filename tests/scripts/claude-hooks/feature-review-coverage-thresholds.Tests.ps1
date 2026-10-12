#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Unit cases for the feature-review coverage threshold resolver (issue #824, FU-823-1).

.DESCRIPTION
    Drives .claude/hooks/feature-review-coverage-thresholds.ps1 directly through
    Get-FeatureReviewCoverageThreshold. Each row supplies a root CLAUDE.md text and the
    governing line and branch thresholds, with their sources, that the resolver must
    return. The rows cover an absent text, a text without figures, both figures, a
    line-only figure, a branch-only figure, a decimal figure, an out-of-range figure,
    a prose figure without a comparator (not read), the combined line-and-branch
    limitation (neither metric read), a minimum phrase, and two no-less-than
    statements on one line.

    Determinism: every case is a pure string case. No temporary file, no child process, no
    clock, and no disk read beyond dot-sourcing the file under test.
#>

Describe 'feature-review-coverage-thresholds (issue #824)' {
    BeforeAll {
        $script:HookRoot = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks").Path
        . (Join-Path $script:HookRoot 'feature-review-coverage-thresholds.ps1')
    }

    It 'T824-<Id> resolves <Label>' -Tag 'Issue824' -ForEach @(
        @{ Id = 1; Label = 'no root CLAUDE.md text'; Text = $null; Line = 85; Branch = 75; LineSource = 'default'; BranchSource = 'default' }
        @{ Id = 2; Label = 'text without figures'; Text = 'Project notes only.'; Line = 85; Branch = 75; LineSource = 'default'; BranchSource = 'default' }
        @{ Id = 3; Label = 'lower line and branch figures'; Text = "Line coverage must remain >= 70%.`nBranch coverage must remain >= 60%."; Line = 70; Branch = 60; LineSource = 'claude-md'; BranchSource = 'claude-md' }
        @{ Id = 4; Label = 'a line-only figure'; Text = 'Line coverage: >= 70%'; Line = 70; Branch = 75; LineSource = 'claude-md'; BranchSource = 'default' }
        @{ Id = 5; Label = 'a branch-only figure'; Text = 'Branch coverage >= 65%'; Line = 85; Branch = 65; LineSource = 'default'; BranchSource = 'claude-md' }
        @{ Id = 6; Label = 'a decimal figure'; Text = 'line coverage of at least 82.5%'; Line = 82.5; Branch = 75; LineSource = 'claude-md'; BranchSource = 'default' }
        @{ Id = 7; Label = 'a figure above 100'; Text = 'Line coverage >= 150%'; Line = 85; Branch = 75; LineSource = 'default'; BranchSource = 'default' }
        @{ Id = 8; Label = 'a prose figure without a comparator'; Text = 'Line coverage was 62% last release.'; Line = 85; Branch = 75; LineSource = 'default'; BranchSource = 'default' }
        @{ Id = 9; Label = 'the combined line-and-branch limitation'; Text = 'Line and branch coverage >= 70%.'; Line = 85; Branch = 75; LineSource = 'default'; BranchSource = 'default' }
        @{ Id = 10; Label = 'a minimum phrase'; Text = 'Branch coverage minimum: 60%'; Line = 85; Branch = 60; LineSource = 'default'; BranchSource = 'claude-md' }
        @{ Id = 11; Label = 'two no-less-than statements on one line'; Text = 'Line coverage no less than 72% and branch coverage no less than 61%.'; Line = 72; Branch = 61; LineSource = 'claude-md'; BranchSource = 'claude-md' }
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

    It 'E4-TR5-P<Id> resolves <Label>' -Tag 'E4-Regression', 'E4-TR5' -ForEach @(
        @{ Id = 1; Label = 'line coverage: 70% minimum'; Text = 'line coverage: 70% minimum'; Line = 70; Branch = 75; LineSource = 'claude-md'; BranchSource = 'default' }
        @{ Id = 2; Label = 'line coverage 80% at least'; Text = 'line coverage 80% at least'; Line = 80; Branch = 75; LineSource = 'claude-md'; BranchSource = 'default' }
        @{ Id = 3; Label = 'line coverage of 80% or more'; Text = 'line coverage of 80% or more'; Line = 80; Branch = 75; LineSource = 'claude-md'; BranchSource = 'default' }
        @{ Id = 4; Label = 'branch coverage: 60% or higher'; Text = 'branch coverage: 60% or higher'; Line = 85; Branch = 60; LineSource = 'default'; BranchSource = 'claude-md' }
        @{ Id = 5; Label = 'line coverage 81% or above'; Text = 'line coverage 81% or above'; Line = 81; Branch = 75; LineSource = 'claude-md'; BranchSource = 'default' }
        @{ Id = 6; Label = 'branch coverage 62% or greater'; Text = 'branch coverage 62% or greater'; Line = 85; Branch = 62; LineSource = 'default'; BranchSource = 'claude-md' }
    ) {
        # Arrange: the row supplies a trailing-floor statement and the expected thresholds and sources.

        # Act
        $result = Get-FeatureReviewCoverageThreshold -ClaudeMdText $Text

        # Assert
        $result.Line | Should -Be $Line -Because "the governing line threshold for '$Text'"
        $result.Branch | Should -Be $Branch -Because "the governing branch threshold for '$Text'"
        $result.LineSource | Should -Be $LineSource
        $result.BranchSource | Should -Be $BranchSource
    }

    It 'E4-TR5-N<Id> keeps the defaults for <Label>' -ForEach @(
        @{ Id = 1; Label = 'Line coverage was 62% last release'; Text = 'Line coverage was 62% last release'; Line = 85; Branch = 75; LineSource = 'default'; BranchSource = 'default' }
        @{ Id = 2; Label = 'Line and branch coverage: 70% minimum'; Text = 'Line and branch coverage: 70% minimum'; Line = 85; Branch = 75; LineSource = 'default'; BranchSource = 'default' }
        @{ Id = 3; Label = 'line coverage: 150% minimum'; Text = 'line coverage: 150% minimum'; Line = 85; Branch = 75; LineSource = 'default'; BranchSource = 'default' }
    ) {
        # Arrange: the row supplies a statement the resolver must not read.

        # Act
        $result = Get-FeatureReviewCoverageThreshold -ClaudeMdText $Text

        # Assert
        $result.Line | Should -Be $Line -Because "the governing line threshold for '$Text'"
        $result.Branch | Should -Be $Branch -Because "the governing branch threshold for '$Text'"
        $result.LineSource | Should -Be $LineSource
        $result.BranchSource | Should -Be $BranchSource
    }
}
