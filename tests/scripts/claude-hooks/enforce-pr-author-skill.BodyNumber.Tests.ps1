#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Strict body-number parsing in the Check 1 binding of enforce-pr-author-skill.ps1 (issue #901, #850 note L19).

.DESCRIPTION
    A body number above Int32.MaxValue previously threw from an [int] cast, which ended the
    hook with exit 1 (non-blocking). A leading zero let the gate verify pr_body_7.md while gh
    uploaded pr_body_007.md. These rows assert that both forms, and non-ASCII decimal digits,
    deny with PR_BODY_PATH_NONCANONICAL without throwing, and that canonical numbers still bind.
    No row creates, writes, or deletes a file, starts a process, or runs the git executable.
#>

Describe 'Get-PrAuthorBodyPathBindingReason body number (issue #901, #850 note L19)' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-pr-author-skill.ps1").Path
        . $script:UnderTest
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/EpicScopeResolution.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/orchestrator-state/OrchestratorState.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
        Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
        Mock Get-OrchestratorStateCheckpoint -ModuleName OrchestratorState { $null }
        Mock Get-PrAuthorCheckpointContent { $null }
        Mock Get-PrAuthorReceiptContent { $null }
        Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }

        $script:ItemRoot = '/synthetic-worktrees/item-901'
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-EpicScopeCheckpointText', 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'Check 1 binding' {
        It 'denies a relative number above Int32.MaxValue without throwing' {
            # Arrange
            $command = 'gh pr create --body-file artifacts/pr_body_99999999999.md'

            # Act
            { $script:BindingResult = Get-PrAuthorBodyPathBindingReason -CommandText $command -ArtifactRoot $script:ItemRoot -RelativeBodyAllowed $true } | Should -Not -Throw

            # Assert
            $script:BindingResult.Reason | Should -BeLike 'PR_BODY_PATH_NONCANONICAL*'
            $script:BindingResult.BodyNumber | Should -BeNullOrEmpty
        }

        It 'denies an absolute number above Int32.MaxValue without throwing' {
            # Arrange
            $command = 'gh pr create --body-file /synthetic-worktrees/item-901/artifacts/pr_body_99999999999.md'

            # Act
            { $script:BindingResult = Get-PrAuthorBodyPathBindingReason -CommandText $command -ArtifactRoot $script:ItemRoot -RelativeBodyAllowed $false } | Should -Not -Throw

            # Assert
            $script:BindingResult.Reason | Should -BeLike 'PR_BODY_PATH_NONCANONICAL*'
            $script:BindingResult.BodyNumber | Should -BeNullOrEmpty
        }

        It 'denies a relative leading-zero number' {
            # Arrange
            $command = 'gh pr create --body-file artifacts/pr_body_007.md'

            # Act
            { $script:BindingResult = Get-PrAuthorBodyPathBindingReason -CommandText $command -ArtifactRoot $script:ItemRoot -RelativeBodyAllowed $true } | Should -Not -Throw

            # Assert
            $script:BindingResult.Reason | Should -BeLike 'PR_BODY_PATH_NONCANONICAL*'
            $script:BindingResult.BodyNumber | Should -BeNullOrEmpty -Because 'pr_body_007.md must not verify pr_body_7.md'
        }

        It 'denies an absolute leading-zero number' {
            # Arrange
            $command = 'gh pr create --body-file /synthetic-worktrees/item-901/artifacts/pr_body_007.md'

            # Act
            { $script:BindingResult = Get-PrAuthorBodyPathBindingReason -CommandText $command -ArtifactRoot $script:ItemRoot -RelativeBodyAllowed $false } | Should -Not -Throw

            # Assert
            $script:BindingResult.Reason | Should -BeLike 'PR_BODY_PATH_NONCANONICAL*'
            $script:BindingResult.BodyNumber | Should -BeNullOrEmpty
        }

        It 'denies non-ASCII decimal digits' {
            # Arrange: Arabic-Indic digits one and two match \d but are not ASCII.
            $value = 'artifacts/pr_body_' + [char]0x0661 + [char]0x0662 + '.md'
            $command = "gh pr create --body-file $value"

            # Act
            { $script:BindingResult = Get-PrAuthorBodyPathBindingReason -CommandText $command -ArtifactRoot $script:ItemRoot -RelativeBodyAllowed $true } | Should -Not -Throw

            # Assert
            $script:BindingResult.Reason | Should -BeLike 'PR_BODY_PATH_NONCANONICAL*'
            $script:BindingResult.BodyNumber | Should -BeNullOrEmpty
        }

        It 'accepts a canonical relative number' {
            # Arrange
            $command = 'gh pr create --body-file artifacts/pr_body_7.md'

            # Act
            { $script:BindingResult = Get-PrAuthorBodyPathBindingReason -CommandText $command -ArtifactRoot $script:ItemRoot -RelativeBodyAllowed $true } | Should -Not -Throw

            # Assert
            $script:BindingResult.Reason | Should -BeNullOrEmpty
            $script:BindingResult.BodyNumber | Should -Be 7
        }

        It 'accepts a canonical absolute number' {
            # Arrange
            $command = 'gh pr create --body-file /synthetic-worktrees/item-901/artifacts/pr_body_7.md'

            # Act
            { $script:BindingResult = Get-PrAuthorBodyPathBindingReason -CommandText $command -ArtifactRoot $script:ItemRoot -RelativeBodyAllowed $false } | Should -Not -Throw

            # Assert
            $script:BindingResult.Reason | Should -BeNullOrEmpty
            $script:BindingResult.BodyNumber | Should -Be 7
        }
    }

    Context 'decision entry point' {
        It 'returns a deny decision end to end for an oversized number' {
            # Arrange
            Mock Resolve-PrAuthorWorktreeTarget { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/item-901'; ReasonCode = $null; Detail = 'synthetic item root' } }
            Mock Get-PrContextArtifactExistence { $true }
            Mock Invoke-OrchestratorStatePreflight { @{ HasErrors = $false; ErrorText = '' } }
            $payload = @{ tool_input = @{ command = 'gh pr create --title "B" --body-file artifacts/pr_body_99999999999.md' } } | ConvertTo-Json -Depth 5 -Compress

            # Act
            { $script:Decision = Invoke-PrAuthorSkillDecision -ToolInputRaw $payload } | Should -Not -Throw

            # Assert
            $script:Decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $script:Decision.hookSpecificOutput.permissionDecisionReason | Should -BeLike 'PR_BODY_PATH_NONCANONICAL*'
        }
    }
}
