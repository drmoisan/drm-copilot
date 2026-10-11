#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Repository constraints for the files issue #850 changes (line cap, temporary files, host paths).

.DESCRIPTION
    Reads committed files located from $PSScriptRoot only and asserts two constraints over the
    production files and suites this change creates or edits: every file stays within the
    500-line cap, no suite uses a temporary-file facility, and no created file carries a host
    path. The forbidden tokens are built by concatenation so this suite does not contain them
    literally. Lines this change adds to edited suites are also covered by the added-lines scan
    of the final QA loop.

    No test creates, writes, or deletes a file, reads a wall clock, starts a process, or
    touches the network.
#>

BeforeAll {
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Register-EpicStateBaselineMock -Seam 'Get-CleanupWorktreeManifestContent', 'Get-EpicScopeCheckpointText', 'Get-OrchestratorStateCheckpoint', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' -Surface 'Claude'
    if (Get-Command Get-ChildOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ChildOrchestratorCheckpointContent' -Surface 'Codex' }
    if (Get-Command Get-EpicOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicOrchestratorCheckpointContent' -Surface 'Codex' }
    if (Get-Command Get-EpicWorktreeGateCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicWorktreeGateCheckpointContent' -Surface 'Codex' }
    if (Get-Command Get-EpicWorktreeGateParallelCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-EpicWorktreeGateParallelCheckpointContent' -Surface 'Codex' }
    if (Get-Command Get-ParallelOrchestratorCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelOrchestratorCheckpointContent' -Surface 'Codex' }
    if (Get-Command Get-ParallelWorktreeRemovalGateCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelWorktreeRemovalGateCheckpointContent' -Surface 'Codex' }
    if (Get-Command Get-ParallelWorktreeRemovalGateEpicCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-ParallelWorktreeRemovalGateEpicCheckpointContent' -Surface 'Codex' }
    if (Get-Command Get-PrAuthorCheckpointContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrAuthorCheckpointContent' -Surface 'Codex' }
    if (Get-Command Get-PrAuthorReceiptContent -ErrorAction SilentlyContinue) { Register-EpicStateBaselineMock -Seam 'Get-PrAuthorReceiptContent' -Surface 'Codex' }
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
    $script:SelfPath = 'tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1'

    $script:ProductionFiles = @(
        '.claude/hooks/enforce-pr-author-skill.ps1'
        '.claude/hooks/enforce-pr-author-skill-helpers.ps1'
        '.claude/hooks/enforce-pr-author-skill.artifact-root.ps1'
        '.claude/hooks/enforce-epic-merge-gate.ps1'
        '.claude/hooks/enforce-epic-merge-gate-resolution.ps1'
        '.claude/hooks/enforce-epic-worktree-removal-gate.ps1'
        '.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1'
        '.claude/hooks/enforce-parallel-worktree-removal-gate.ps1'
        '.claude/lib/worktree-resolution/WorktreeRunResolution.psm1'
        '.claude/lib/worktree-resolution/WorktreeItemResolution.psm1'
    )
    $script:NewSuites = @(
        'tests/scripts/claude-hooks/enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1'
        'tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1'
        'tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.PrNumber.Tests.ps1'
        'tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1'
        $script:SelfPath
    )
    $script:EditedSuites = @(
        'tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1'
        'tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1'
        'tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1'
        'tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1'
        'tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1'
        'tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1'
        'tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1'
        'tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1'
        'tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1'
        'tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1'
        'tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1'
        'tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1'
        'tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1'
        'tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1'
    )

    function Get-ConstraintFileLine {
        <# Return the lines of a committed repository-relative file. #>
        param([Parameter(Mandatory)] [string] $RelativePath)
        return @(Get-Content -LiteralPath (Join-Path $script:RepoRoot $RelativePath))
    }
}

Describe 'issue #850 changed-file constraints' {

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'keeps every changed file within the line cap' {
        # Arrange
        $paths = @($script:ProductionFiles) + @($script:NewSuites) + @($script:EditedSuites)

        # Act and assert: one assertion per file, naming the file on failure.
        foreach ($path in $paths) {
            @(Get-ConstraintFileLine -RelativePath $path).Count | Should -BeLessOrEqual 500 -Because $path
        }
    }

    It 'uses no temporary files and no host paths' {
        # Arrange: tokens are concatenated so this suite does not carry them literally.
        $tokens = @(('Test' + 'Drive'), ('GetTemp' + 'Path'), ('GetTemp' + 'FileName'), ('New-Temporary' + 'File'))
        $patterns = @('[A-Za-z]:\\Users\\', '[A-Za-z]:/Users/', '/home/[a-z]')
        $suites = @(@($script:NewSuites) + @($script:EditedSuites) | Where-Object { $_ -ne $script:SelfPath })
        $createdFiles = @($script:NewSuites) + @('.claude/hooks/enforce-pr-author-skill.artifact-root.ps1')

        # Act and assert
        foreach ($path in $suites) {
            $text = (Get-ConstraintFileLine -RelativePath $path) -join "`n"
            foreach ($token in $tokens) {
                $text.Contains($token) | Should -BeFalse -Because "$path must not use $token"
            }
        }
        foreach ($path in $createdFiles) {
            foreach ($line in (Get-ConstraintFileLine -RelativePath $path)) {
                foreach ($pattern in $patterns) {
                    $line -match $pattern | Should -BeFalse -Because "$path must not carry a host path ($pattern)"
                }
            }
        }
    }
}
