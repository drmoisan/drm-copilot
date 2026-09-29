#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Signal, text-seam, and path-composition tests for the run resolver (issue #690).

.DESCRIPTION
    Covers Find-WorktreeRunIdentitySignal (the integration_branch:, epic_feature_folder:,
    and parallel_slug: literals), the Get-WorktreeRunCheckpointText seam, and
    Get-WorktreeRunCheckpointPath. Synthetic roots use the /synthetic-worktrees/<name>
    form. No test creates or writes a file, reads a wall clock, starts a process, or
    touches the network; the one real read is of this committed suite file.
#>

BeforeAll {
    # Imported without -Force so the suite binds to any instance already in the session.
    $script:LibRoot = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/worktree-resolution").Path
    Import-Module (Join-Path $script:LibRoot 'WorktreeRunResolution.psm1')

    $script:Kickoff = 'Epic mode: true. epic_feature_folder: repro. integration_branch: epic/repro-integration. ' +
    'epic_checkpoint_path: artifacts/orchestration/epic-orchestrator-state.json. PR base branch MUST be ' +
    'epic/repro-integration, not main.'
}

Describe 'Find-WorktreeRunIdentitySignal' {
    It 'S1 reads the integration branch from the epic kickoff sentence without its full stop' {
        # Arrange / Act
        $signal = Find-WorktreeRunIdentitySignal -Text $script:Kickoff

        # Assert
        $signal.IntegrationBranch | Should -BeExactly 'epic/repro-integration'
    }

    It 'S2 reads the epic slug from epic_feature_folder' {
        # Arrange / Act
        $signal = Find-WorktreeRunIdentitySignal -Text 'epic_feature_folder: repro.'

        # Assert
        $signal.EpicSlug | Should -BeExactly 'repro'
    }

    It 'S3 reads the parallel slug from parallel_slug' {
        # Arrange / Act
        $signal = Find-WorktreeRunIdentitySignal -Text 'Parallel mode: true. parallel_slug: wave-a. cohort_index: 0'

        # Assert
        $signal.ParallelSlug | Should -BeExactly 'wave-a'
    }

    It 'S4 keeps the full token when the value is followed by a space' {
        # Arrange / Act
        $signal = Find-WorktreeRunIdentitySignal -Text 'integration_branch: epic/a.b-integration next'

        # Assert: only a trailing full stop is removed, not one inside the token.
        $signal.IntegrationBranch | Should -BeExactly 'epic/a.b-integration'
    }

    It 'S5 matches the literal case-sensitively' {
        # Arrange / Act
        $signal = Find-WorktreeRunIdentitySignal -Text 'Integration_Branch: x'

        # Assert
        $signal.IntegrationBranch | Should -BeNullOrEmpty
    }

    It 'S6 returns three null fields when no literal is present' {
        # Arrange / Act
        $signal = Find-WorktreeRunIdentitySignal -Text 'Run the model-routing review for this item.'

        # Assert
        $signal.IntegrationBranch | Should -BeNullOrEmpty
        $signal.EpicSlug | Should -BeNullOrEmpty
        $signal.ParallelSlug | Should -BeNullOrEmpty
    }

    It 'S7 does not read the literal as the tail of a longer word' {
        # Arrange / Act
        $signal = Find-WorktreeRunIdentitySignal -Text 'xintegration_branch: y'

        # Assert
        $signal.IntegrationBranch | Should -BeNullOrEmpty
    }

    It 'S8 returns null when two different integration branches are named' {
        # Arrange / Act
        $signal = Find-WorktreeRunIdentitySignal -Text 'integration_branch: epic/a-integration. integration_branch: epic/b-integration.'

        # Assert: a prompt naming two runs identifies neither.
        $signal.IntegrationBranch | Should -BeNullOrEmpty
    }

    It 'S9 returns three null fields for null and for empty text' {
        # Arrange / Act
        $fromNull = Find-WorktreeRunIdentitySignal -Text $null
        $fromEmpty = Find-WorktreeRunIdentitySignal -Text ''

        # Assert
        foreach ($signal in @($fromNull, $fromEmpty)) {
            $signal.IntegrationBranch | Should -BeNullOrEmpty
            $signal.EpicSlug | Should -BeNullOrEmpty
            $signal.ParallelSlug | Should -BeNullOrEmpty
        }
    }
}

Describe 'Get-WorktreeRunCheckpointText' {
    It 'T1 returns null for a blank path' {
        # Arrange / Act
        $text = Get-WorktreeRunCheckpointText -Path ''

        # Assert
        $text | Should -BeNullOrEmpty
    }

    It 'T2 returns null for a path that does not exist' {
        # Arrange / Act
        $text = Get-WorktreeRunCheckpointText -Path '/synthetic-worktrees/none/artifacts/orchestration/epic-orchestrator-state.json'

        # Assert
        $text | Should -BeNullOrEmpty
    }

    It 'T3 returns the text of an existing committed file' {
        # Arrange / Act: read this suite file, which is committed and always present.
        $text = Get-WorktreeRunCheckpointText -Path $PSCommandPath

        # Assert
        $text | Should -Match 'Get-WorktreeRunCheckpointText'
    }
}

Describe 'Get-WorktreeRunCheckpointPath' {
    It 'P1 composes the epic checkpoint path beneath a root' {
        # Arrange / Act
        $path = Get-WorktreeRunCheckpointPath -Kind epic -WorktreeRoot '/synthetic-worktrees/w-epic'

        # Assert
        $path | Should -BeExactly '/synthetic-worktrees/w-epic/artifacts/orchestration/epic-orchestrator-state.json'
    }

    It 'P2 composes the parallel checkpoint path beneath a root' {
        # Arrange / Act
        $path = Get-WorktreeRunCheckpointPath -Kind parallel -WorktreeRoot '/synthetic-worktrees/w-par/'

        # Assert
        $path | Should -BeExactly '/synthetic-worktrees/w-par/artifacts/orchestration/parallel-orchestrator-state.json'
    }

    It 'P3 composes the item checkpoint path beneath a root' {
        # Arrange / Act
        $path = Get-WorktreeRunCheckpointPath -Kind item -WorktreeRoot '/synthetic-worktrees/w-item'

        # Assert
        $path | Should -BeExactly '/synthetic-worktrees/w-item/artifacts/orchestration/orchestrator-state.json'
    }

    It 'P4 throws for a relative root' {
        # Arrange / Act / Assert: a relative root would bind the read to the process directory.
        { Get-WorktreeRunCheckpointPath -Kind epic -WorktreeRoot 'relative/root' } | Should -Throw
    }
}
