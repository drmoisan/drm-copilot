#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Direct coverage of Get-PrdFeatureCheckpointFolder (issue #696) and of the
    Resolve-PrdFeatureWorkMode delegate to the shared work-mode parser (issue #565).

.DESCRIPTION
    Get-PrdFeatureCheckpointFolder is called with an absolute synthetic -CheckpointPath and
    is never mocked: only its two read built-ins, Test-Path and Get-Content, are mocked with
    parameter filters on that exact path, so the read, parse, and field-extraction body runs
    for real and no case creates a file. The Resolve-PrdFeatureWorkMode cases prove the
    delegate keeps its $null result for an unresolved marker and for a failed dot-source of
    the shared resolver.
#>

Describe 'enforce-prd-feature-before-planner.ps1 checkpoint folder and work-mode delegate' {
    BeforeAll {
        . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-prd-feature-before-planner.ps1").Path
        . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
        Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
        Mock Get-PrdFeatureCheckpointFolder -ParameterFilter { $CheckpointPath -notlike "/synthetic-worktrees/*" } -MockWith { $null }
        Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
        Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
        . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1").Path
        $script:CheckpointPath = '/synthetic-worktrees/session-root/artifacts/orchestration/orchestrator-state.json'
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot' }

    Context 'Get-PrdFeatureCheckpointFolder read, parse, and field extraction (issue #696)' {
        It 'K1: returns the recorded feature-folder and reads the exact path once with -Raw' {
            # Arrange
            Mock Test-Path { $true } -ParameterFilter { $LiteralPath -eq '/synthetic-worktrees/session-root/artifacts/orchestration/orchestrator-state.json' }
            Mock Get-Content { '{"feature-folder":"docs/features/active/2026-08-26-sample-565"}' } -ParameterFilter { $LiteralPath -eq '/synthetic-worktrees/session-root/artifacts/orchestration/orchestrator-state.json' }

            # Act
            $result = Get-PrdFeatureCheckpointFolder -CheckpointPath $script:CheckpointPath

            # Assert
            $result | Should -Be 'docs/features/active/2026-08-26-sample-565'
            Should -Invoke Test-Path -Times 1 -Exactly -ParameterFilter { $LiteralPath -eq '/synthetic-worktrees/session-root/artifacts/orchestration/orchestrator-state.json' }
            Should -Invoke Get-Content -Times 1 -Exactly -ParameterFilter { $LiteralPath -eq '/synthetic-worktrees/session-root/artifacts/orchestration/orchestrator-state.json' -and $Raw }
        }

        It 'K2: returns $null when the checkpoint has no feature-folder field' {
            Mock Test-Path { $true } -ParameterFilter { $LiteralPath -eq '/synthetic-worktrees/session-root/artifacts/orchestration/orchestrator-state.json' }
            Mock Get-Content { '{"issue-num":"565","route_id":"large"}' } -ParameterFilter { $LiteralPath -eq '/synthetic-worktrees/session-root/artifacts/orchestration/orchestrator-state.json' }
            Get-PrdFeatureCheckpointFolder -CheckpointPath $script:CheckpointPath | Should -BeNullOrEmpty
        }

        It 'K3: returns $null when the feature-folder field is empty' {
            Mock Test-Path { $true } -ParameterFilter { $LiteralPath -eq '/synthetic-worktrees/session-root/artifacts/orchestration/orchestrator-state.json' }
            Mock Get-Content { '{"feature-folder":""}' } -ParameterFilter { $LiteralPath -eq '/synthetic-worktrees/session-root/artifacts/orchestration/orchestrator-state.json' }
            Get-PrdFeatureCheckpointFolder -CheckpointPath $script:CheckpointPath | Should -BeNullOrEmpty
        }

        It 'K4: returns $null when the checkpoint is not valid JSON' {
            Mock Test-Path { $true } -ParameterFilter { $LiteralPath -eq '/synthetic-worktrees/session-root/artifacts/orchestration/orchestrator-state.json' }
            Mock Get-Content { '{broken json' } -ParameterFilter { $LiteralPath -eq '/synthetic-worktrees/session-root/artifacts/orchestration/orchestrator-state.json' }
            Get-PrdFeatureCheckpointFolder -CheckpointPath $script:CheckpointPath | Should -BeNullOrEmpty
        }

        It 'K5: returns $null when reading the checkpoint throws' {
            Mock Test-Path { $true } -ParameterFilter { $LiteralPath -eq '/synthetic-worktrees/session-root/artifacts/orchestration/orchestrator-state.json' }
            Mock Get-Content { throw 'simulated read failure' } -ParameterFilter { $LiteralPath -eq '/synthetic-worktrees/session-root/artifacts/orchestration/orchestrator-state.json' }
            Get-PrdFeatureCheckpointFolder -CheckpointPath $script:CheckpointPath | Should -BeNullOrEmpty
        }

        It 'K6: returns $null without reading when the checkpoint is absent' {
            Mock Test-Path { $false } -ParameterFilter { $LiteralPath -eq '/synthetic-worktrees/session-root/artifacts/orchestration/orchestrator-state.json' }
            Mock Get-Content { '{"feature-folder":"unexpected"}' }
            Get-PrdFeatureCheckpointFolder -CheckpointPath $script:CheckpointPath | Should -BeNullOrEmpty
            Should -Invoke Get-Content -Times 0
        }
    }

    Context 'Resolve-PrdFeatureWorkMode delegate (issue #565)' {
        It 'P1: returns the parsed mode for a recognized marker' {
            Resolve-PrdFeatureWorkMode -IssueContent "# Issue`n- Work Mode: full-bug`n" | Should -Be 'full-bug'
        }

        It 'P2: returns $null when the marker is missing' {
            Resolve-PrdFeatureWorkMode -IssueContent "# Issue`nNo marker here.`n" | Should -BeNullOrEmpty
        }

        It 'P3: returns $null when the shared resolver failed to load' {
            $script:PrdFeatureFolderResolutionImportFailure = 'feature-folder-resolution.ps1'
            try {
                $result = Resolve-PrdFeatureWorkMode -IssueContent "# Issue`n- Work Mode: full-bug`n"
            }
            finally {
                $script:PrdFeatureFolderResolutionImportFailure = $null
            }
            $result | Should -BeNullOrEmpty
        }

        It 'P4: delegates to Resolve-FeatureFolderWorkMode with an empty -UnresolvedMode' {
            Mock Resolve-FeatureFolderWorkMode { 'minor-audit' }
            Resolve-PrdFeatureWorkMode -IssueContent 'any content' | Should -Be 'minor-audit'
            Should -Invoke Resolve-FeatureFolderWorkMode -Times 1 -Exactly -ParameterFilter { $UnresolvedMode -eq '' }
        }
    }
}
