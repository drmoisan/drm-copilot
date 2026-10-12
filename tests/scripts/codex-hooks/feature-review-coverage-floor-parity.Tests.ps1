#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Claude and Codex feature-review line-floor parity (issue #896, E4-PX1).

.DESCRIPTION
    For each root CLAUDE.md text, the Claude hook (.claude/hooks/validate-feature-review-coverage.ps1)
    and the Codex hook (.codex/hooks/validate-feature-review-coverage.ps1) resolve the governing
    line floor through their own thresholds copies and report it in the failing-row reason of
    Test-LanguageCoverageRow. Each hook is dot-sourced in its own child scope, so the two
    function sets do not shadow each other. The test reads the floor from each reason and
    asserts that both surfaces report the same figure.

    Determinism: every case is a pure string case. No temporary file, no child process, no
    clock, and no disk read beyond dot-sourcing the two hook files.
#>

Describe 'feature-review coverage floor parity (issue #896)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
        $script:ClaudeHook = Join-Path $script:RepoRoot '.claude/hooks/validate-feature-review-coverage.ps1'
        $script:CodexHook = Join-Path $script:RepoRoot '.codex/hooks/validate-feature-review-coverage.ps1'

        # Baseline isolation for the closure seams of the two hooks (epic-state discovery guard): no
        # seam reads live repository state. The parity cases call only the resolver and the row rule.
        . $script:ClaudeHook
        Mock Get-ArtifactFileContent { $null }
        if (Get-Command Get-ChangedLanguageSet -ErrorAction SilentlyContinue) { Mock Get-ChangedLanguageSet { $null } }
        if (Get-Command Get-JacocoRepoCoverage -ErrorAction SilentlyContinue) { Mock Get-JacocoRepoCoverage { $null } }
        if (Get-Command Get-LcovRepoCoverage -ErrorAction SilentlyContinue) { Mock Get-LcovRepoCoverage { $null } }

        function Get-FloorFromReason {
            # Returns the line floor a failing-row reason cites, or $null when none is cited.
            param([string] $Reason)
            $match = [regex]::Match([string]$Reason, 'below the (?<floor>\d+(?:\.\d+)?)% line coverage floor')
            if (-not $match.Success) { return $null }
            return [double]$match.Groups['floor'].Value
        }

        function Get-ClaudeFloorReason {
            # Resolves the Claude floor and returns the failing-row reason for a 60 percent row.
            param([AllowNull()] [string] $ClaudeMdText)
            return (& { param($HookPath, $Text) . $HookPath; $t = Get-FeatureReviewCoverageThreshold -ClaudeMdText $Text; (Test-LanguageCoverageRow -AuditText 'Python coverage PASS' -Language 'Python' -RepoWidePct 60 -LineFloor $t.Line -LineSource $t.LineSource).Reason } $script:ClaudeHook $ClaudeMdText)
        }

        function Get-CodexFloorReason {
            # Resolves the Codex floor and returns the failing-row reason for a 60 percent row.
            param([AllowNull()] [string] $ClaudeMdText)
            return (& { param($HookPath, $Text) . $HookPath; $t = Get-FeatureReviewCoverageThreshold -ClaudeMdText $Text; (Test-LanguageCoverageRow -AuditText 'Python coverage PASS' -Language 'Python' -RepoWidePct 60 -LineFloor $t.Line).Reason } $script:CodexHook $ClaudeMdText)
        }
    }

    It 'E4-PX1: <Label> reports line floor <Floor> on both surfaces' -ForEach @(
        @{ Label = 'no figure'; Text = 'Project notes without coverage figures.'; Floor = 85 }
        @{ Label = 'comparator form'; Text = 'Line coverage >= 70%'; Floor = 70 }
        @{ Label = 'trailing form'; Text = 'line coverage: 92% minimum'; Floor = 92 }
    ) {
        # Act
        $claudeFloor = Get-FloorFromReason -Reason (Get-ClaudeFloorReason -ClaudeMdText $Text)
        $codexFloor = Get-FloorFromReason -Reason (Get-CodexFloorReason -ClaudeMdText $Text)

        # Assert
        $claudeFloor | Should -Be $Floor -Because "the Claude hook floor for '$Text'"
        $codexFloor | Should -Be $Floor -Because "the Codex hook floor for '$Text'"
        $claudeFloor | Should -Be $codexFloor
    }
}
