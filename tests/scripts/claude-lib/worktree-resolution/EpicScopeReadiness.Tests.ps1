#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit tests for the pure epic readiness predicates (issue #663).

.DESCRIPTION
    Drives Get-EpicPrCreationReadinessFailure and Get-EpicCommandLegReadinessFailure in
    .claude/lib/worktree-resolution/EpicScopeReadiness.psm1. Each predicate returns an
    empty string when ready, or the name of the first failed conjunct. Every deny row
    derives from one ready epic checkpoint by a single change, so the named conjunct is
    the only difference. The module is pure: no mock, no file, and no process is used.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    Import-Module (Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/EpicScopeReadiness.psm1') -Force

    function New-ReadyEpicCheckpoint {
        <#
            Returns a fresh ready epic checkpoint object on every call, so a row's single
            mutation never leaks into another row.
        #>
        param()

        return ('{"route_id":"epic","epic_feature_folder":"sample-epic","epic_manifest_path":"docs/features/epics/sample-epic/epic.md","integration_branch":"epic/sample-epic-integration","epic_issue_num":900,"features":[{"feature_folder":"2026-09-25-child-a-901","merge_status":"merged"},{"feature_folder":"2026-09-25-child-b-902","merge_status":"worktree_removed"}],"model_routing_receipts":[{"agent":"pr-author"}]}' | ConvertFrom-Json)
    }
}

Describe 'Get-EpicPrCreationReadinessFailure' {
    It 'PR-creation readiness passes when every feature is merged or worktree_removed' {
        # Arrange
        $checkpoint = New-ReadyEpicCheckpoint

        # Act
        $failure = Get-EpicPrCreationReadinessFailure -Checkpoint $checkpoint -HeadBranch 'epic/sample-epic-integration'

        # Assert
        $failure | Should -Be '' -Because 'every conjunct of the PR-creation shape holds'
    }

    It 'PR-creation readiness names <Conjunct> for <Label>' -ForEach @(
        @{ Conjunct = 'checkpoint-absent'; Label = 'a null checkpoint'; HeadBranch = 'epic/sample-epic-integration'; Mutate = { param($c) $null = $c; return $null } }
        @{ Conjunct = 'route_id'; Label = 'a route_id other than epic'; HeadBranch = 'epic/sample-epic-integration'; Mutate = { param($c) $c.route_id = 'parallel'; return $c } }
        @{ Conjunct = 'integration_branch'; Label = 'a --head branch that differs from integration_branch'; HeadBranch = 'feature/standalone-item'; Mutate = { param($c) return $c } }
        @{ Conjunct = 'features'; Label = 'an empty features array'; HeadBranch = 'epic/sample-epic-integration'; Mutate = { param($c) $c.features = @(); return $c } }
        @{ Conjunct = 'merge_status'; Label = 'a feature whose merge_status is pr_open'; HeadBranch = 'epic/sample-epic-integration'; Mutate = { param($c) $c.features[1].merge_status = 'pr_open'; return $c } }
    ) {
        # Arrange
        $checkpoint = & $Mutate (New-ReadyEpicCheckpoint)

        # Act
        $failure = Get-EpicPrCreationReadinessFailure -Checkpoint $checkpoint -HeadBranch $HeadBranch

        # Assert
        $failure | Should -Be $Conjunct -Because "the single change ($Label) fails exactly that conjunct"
    }
}

Describe 'Get-EpicCommandLegReadinessFailure' {
    It 'command-leg readiness passes for a ready epic checkpoint while a merge is in progress' {
        # Arrange
        $checkpoint = New-ReadyEpicCheckpoint

        # Act
        $failure = Get-EpicCommandLegReadinessFailure -Checkpoint $checkpoint -MergeInProgress $true

        # Assert
        $failure | Should -Be '' -Because 'the epic shape holds and a merge is in progress (D2)'
    }

    It 'command-leg readiness names <Conjunct> for <Label>' -ForEach @(
        @{ Conjunct = 'checkpoint-absent'; Label = 'a null checkpoint'; MergeInProgress = $true; Mutate = { param($c) $null = $c; return $null } }
        @{ Conjunct = 'route_id'; Label = 'a route_id other than epic'; MergeInProgress = $true; Mutate = { param($c) $c.route_id = 'single-feature'; return $c } }
        @{ Conjunct = 'epic_feature_folder'; Label = 'a missing epic_feature_folder'; MergeInProgress = $true; Mutate = { param($c) $c.PSObject.Properties.Remove('epic_feature_folder'); return $c } }
        @{ Conjunct = 'epic_manifest_path'; Label = 'an epic_manifest_path outside docs/features/epics/'; MergeInProgress = $true; Mutate = { param($c) $c.epic_manifest_path = 'docs/features/active/sample-epic/epic.md'; return $c } }
        @{ Conjunct = 'integration_branch'; Label = 'a missing integration_branch'; MergeInProgress = $true; Mutate = { param($c) $c.PSObject.Properties.Remove('integration_branch'); return $c } }
        @{ Conjunct = 'features'; Label = 'an empty features array'; MergeInProgress = $true; Mutate = { param($c) $c.features = @(); return $c } }
        @{ Conjunct = 'merge-in-progress'; Label = 'no merge in progress'; MergeInProgress = $false; Mutate = { param($c) return $c } }
    ) {
        # Arrange
        $checkpoint = & $Mutate (New-ReadyEpicCheckpoint)

        # Act
        $failure = Get-EpicCommandLegReadinessFailure -Checkpoint $checkpoint -MergeInProgress $MergeInProgress

        # Assert
        $failure | Should -Be $Conjunct -Because "the single change ($Label) fails exactly that conjunct"
    }
}
