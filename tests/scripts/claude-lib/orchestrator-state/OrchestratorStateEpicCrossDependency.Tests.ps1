#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit rows for the Layer 2 cross-epic port OrchestratorStateEpicCrossDependency.psm1 (issue #1162).

.DESCRIPTION
    Each row composes an epic checkpoint text in memory and calls
    Get-OrchestratorStateEpicCrossDependencyError directly: the start guard, the
    integrated statuses, entries the shape check owns, duplicate keys (last definition
    wins), non-object roots, and the fail-closed parse error. No file is created.
#>

BeforeAll {
    Import-Module (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/orchestrator-state/OrchestratorStateEpicCrossDependency.psm1").Path -Force -ErrorAction Stop

    $script:Violation = 'EPIC_CROSS_DEPENDENCY_VIOLATION: c-1201 is treated as started while cross-epic dependency provider-epic#1188 is not integrated'
    $script:Entry = '"epic": "provider-epic", "integration_branch": "epic/provider-epic-integration", "issue_num": 1188'
    $script:Checkpoint = {
        param([string] $FeatureProperty, [string] $EntryText)
        '{"features":[{"feature_folder": "c-1201", "issue_num": 1201, ' + $FeatureProperty + '"cross_epic_depends_on": [' + $EntryText + ']}]}'
    }
}

AfterAll {
    Remove-Module -Name OrchestratorStateEpicCrossDependency -Force -ErrorAction SilentlyContinue
}

Describe 'Get-OrchestratorStateEpicCrossDependencyError' {
    It 'reports a started feature whose entry is <Status>' -ForEach @(
        @{ Status = 'held'; Property = '"status": "held"' }
        @{ Status = 'released'; Property = '"status": "released"' }
        @{ Status = 'without a status'; Property = '"x": 1' }
        @{ Status = 'a non-string status'; Property = '"status": 5' }
        @{ Status = 'a case variant of integrated'; Property = '"status": "Integrated"' }
    ) {
        $text = & $script:Checkpoint '"merge_status": "pr_open", ' "{$($script:Entry), $Property}"

        $errors = Get-OrchestratorStateEpicCrossDependencyError -CheckpointText $text

        $errors | Should -BeExactly @($script:Violation)
    }

    It 'reports nothing for an entry that is <Status>' -ForEach @(
        @{ Status = 'integrated' }
        @{ Status = 'in_main' }
    ) {
        $text = & $script:Checkpoint '"merge_status": "merged", ' "{$($script:Entry), ""status"": ""$Status""}"

        (Get-OrchestratorStateEpicCrossDependencyError -CheckpointText $text).Count | Should -Be 0
    }

    It 'applies the start guard: <Name>' -ForEach @(
        @{ Name = 'not_started is not started'; Property = '"merge_status": "not_started", '; Count = 0 }
        @{ Name = 'a worktree_created_at string starts the feature'; Property = '"merge_status": "not_started", "worktree_created_at": "", '; Count = 1 }
        @{ Name = 'an absent merge_status starts the feature'; Property = ''; Count = 1 }
        @{ Name = 'a null merge_status starts the feature'; Property = '"merge_status": null, '; Count = 1 }
    ) {
        $text = & $script:Checkpoint $Property "{$($script:Entry), ""status"": ""held""}"

        (Get-OrchestratorStateEpicCrossDependencyError -CheckpointText $text).Count | Should -Be $Count
    }

    It 'leaves <Name> to the shape check' -ForEach @(
        @{ Name = 'a non-object entry'; EntryText = '5' }
        @{ Name = 'an epic with a slash'; EntryText = '{"epic": "a/b", "issue_num": 1}' }
        @{ Name = 'a dot-segment epic'; EntryText = '{"epic": "..", "issue_num": 1}' }
        @{ Name = 'a missing epic'; EntryText = '{"issue_num": 1}' }
        @{ Name = 'a string issue_num'; EntryText = '{"epic": "p", "issue_num": "1"}' }
        @{ Name = 'a zero issue_num'; EntryText = '{"epic": "p", "issue_num": 0}' }
        @{ Name = 'a fractional issue_num'; EntryText = '{"epic": "p", "issue_num": 1.5}' }
        @{ Name = 'a missing issue_num'; EntryText = '{"epic": "p"}' }
    ) {
        $text = & $script:Checkpoint '"merge_status": "pr_open", ' $EntryText

        (Get-OrchestratorStateEpicCrossDependencyError -CheckpointText $text).Count | Should -Be 0
    }

    It 'reads the last definition of a duplicated status key' {
        $text = & $script:Checkpoint '"merge_status": "pr_open", ' "{$($script:Entry), ""status"": ""integrated"", ""status"": ""held""}"

        Get-OrchestratorStateEpicCrossDependencyError -CheckpointText $text | Should -BeExactly @($script:Violation)
    }

    It 'returns nothing for <Name>' -ForEach @(
        @{ Name = 'a non-object root'; Text = '[1]' }
        @{ Name = 'a missing features key'; Text = '{"route_id": "epic"}' }
        @{ Name = 'a non-list features value'; Text = '{"features": {"a": 1}}' }
        @{ Name = 'a non-object feature'; Text = '{"features": ["x"]}' }
        @{ Name = 'a feature without a string folder'; Text = '{"features": [{"feature_folder": 5, "merge_status": "pr_open", "cross_epic_depends_on": [{"epic": "p", "issue_num": 1}]}]}' }
        @{ Name = 'a non-list value'; Text = '{"features": [{"feature_folder": "f", "merge_status": "pr_open", "cross_epic_depends_on": "p#1"}]}' }
        @{ Name = 'a feature without the key'; Text = '{"features": [{"feature_folder": "f", "merge_status": "pr_open"}]}' }
    ) {
        (Get-OrchestratorStateEpicCrossDependencyError -CheckpointText $Text).Count | Should -Be 0
    }

    It 'fails closed with the unevaluable token for text System.Text.Json cannot parse' {
        { Get-OrchestratorStateEpicCrossDependencyError -CheckpointText '{not json' } | Should -Throw -ExpectedMessage 'EPIC_CROSS_DEPENDENCY_UNEVALUABLE:*'
    }

    It 'reports one line per unintegrated entry in entry order' {
        $entries = '{"epic": "a", "issue_num": 1, "status": "held"}, {"epic": "b", "issue_num": 2, "status": "in_main"}, {"epic": "c", "issue_num": 3}'
        $errors = Get-OrchestratorStateEpicCrossDependencyError -CheckpointText (& $script:Checkpoint '"merge_status": "pr_open", ' $entries)

        ($errors -join '|') | Should -BeExactly 'EPIC_CROSS_DEPENDENCY_VIOLATION: c-1201 is treated as started while cross-epic dependency a#1 is not integrated|EPIC_CROSS_DEPENDENCY_VIOLATION: c-1201 is treated as started while cross-epic dependency c#3 is not integrated'
    }
}
