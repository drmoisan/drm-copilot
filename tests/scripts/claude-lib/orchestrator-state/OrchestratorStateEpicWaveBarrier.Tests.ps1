#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Unit rows for the Layer 2 wave-barrier port OrchestratorStateEpicWaveBarrier.psm1 (issue #840).

.DESCRIPTION
    Each row composes an epic checkpoint text in memory and calls
    Get-OrchestratorStateEpicWaveBarrierError directly. The rows cover the non-object and
    feature-less roots, the start-guard matrix, non-string dependency statuses, duplicate
    JSON keys within one object (last definition wins), a doubly prefixed folder hint, a
    boolean reference, and each fail-closed input class.

    No row creates, writes, or deletes a file, reads a clock, starts a process, or touches
    the network. Folder names follow the parity corpus
    tests/fixtures/epic_wave_barrier/layer2-parity-edge-cases.json.
#>

BeforeAll {
    Import-Module (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1").Path -Force

    $script:StatusError = 'EPIC_WAVE_BARRIER_VIOLATION: 2026-10-08-bravo-902 is treated as started while dependency 2026-10-08-alpha-901 is not merged'
    $script:UnevaluablePattern = 'EPIC_WAVE_BARRIER_UNEVALUABLE:*'

    # Compose an epic checkpoint text whose features array holds the given JSON object texts.
    function ConvertTo-PortCheckpointText {
        param([string[]] $Feature)
        return '{"route_id":"epic","features":[' + ($Feature -join ',') + ']}'
    }

    # The text of a dependency feature alpha-901 carrying the given extra properties.
    function ConvertTo-PortDependencyText {
        param([string] $Property)
        return '{"feature_folder": "2026-10-08-alpha-901", "issue_num": 901, "depends_on": [], ' + $Property + '}'
    }

    # The text of a started dependent bravo-902 that depends on the given JSON array text.
    function ConvertTo-PortDependentText {
        param([string] $DependsOn)
        return '{"feature_folder": "2026-10-08-bravo-902", "issue_num": 902, "depends_on": ' + $DependsOn +
        ', "merge_status": "worktree_created", "worktree_created_at": "2026-10-08T10-00"}'
    }
}

Describe 'OrchestratorStateEpicWaveBarrier port' {
    It 'U1 returns no line for a JSON array root' {
        # Arrange / Act
        $result = Get-OrchestratorStateEpicWaveBarrierError -CheckpointText '[]'

        # Assert
        @($result).Count | Should -Be 0
    }

    It 'U2 returns no line for an object root without features' {
        # Arrange / Act
        $result = Get-OrchestratorStateEpicWaveBarrierError -CheckpointText '{}'

        # Assert
        @($result).Count | Should -Be 0
    }

    It 'U3 start guard <Name>' -ForEach @(
        @{ Name = 'not-started-created-absent'; Dependent = '"merge_status": "not_started"'; ExpectError = $false }
        @{ Name = 'not-started-created-null'; Dependent = '"merge_status": "not_started", "worktree_created_at": null'; ExpectError = $false }
        @{ Name = 'not-started-created-empty'; Dependent = '"merge_status": "not_started", "worktree_created_at": ""'; ExpectError = $true }
        @{ Name = 'status-absent'; Dependent = '"issue_num": 902'; ExpectError = $true }
        @{ Name = 'status-null'; Dependent = '"merge_status": null'; ExpectError = $true }
        @{ Name = 'status-integer'; Dependent = '"merge_status": 5'; ExpectError = $true }
        @{ Name = 'status-title-case'; Dependent = '"merge_status": "Not_Started"'; ExpectError = $true }
    ) {
        # Arrange: an unmerged dependency and a dependent whose start fields vary per row.
        $text = ConvertTo-PortCheckpointText -Feature @(
            (ConvertTo-PortDependencyText -Property '"merge_status": "pr_open"'),
            ('{"feature_folder": "2026-10-08-bravo-902", "depends_on": ["2026-10-08-alpha-901"], ' + $Dependent + '}'))
        $expected = if ($ExpectError) { $script:StatusError } else { '' }

        # Act
        $result = Get-OrchestratorStateEpicWaveBarrierError -CheckpointText $text

        # Assert: a started dependent yields exactly the status line; an unstarted one yields none.
        (@($result) -join "`n") | Should -BeExactly $expected
    }

    It 'U4 reports a status violation for an array merge_status on the dependency' {
        # Arrange
        $text = ConvertTo-PortCheckpointText -Feature @(
            (ConvertTo-PortDependencyText -Property '"merge_status": ["merged"]'),
            (ConvertTo-PortDependentText -DependsOn '["2026-10-08-alpha-901"]'))

        # Act
        $result = Get-OrchestratorStateEpicWaveBarrierError -CheckpointText $text

        # Assert
        (@($result) -join "`n") | Should -BeExactly $script:StatusError
    }

    It 'U5 reports a status violation for an object merge_status on the dependency' {
        # Arrange
        $text = ConvertTo-PortCheckpointText -Feature @(
            (ConvertTo-PortDependencyText -Property '"merge_status": {"value": "merged"}'),
            (ConvertTo-PortDependentText -DependsOn '["2026-10-08-alpha-901"]'))

        # Act
        $result = Get-OrchestratorStateEpicWaveBarrierError -CheckpointText $text

        # Assert
        (@($result) -join "`n") | Should -BeExactly $script:StatusError
    }

    It 'U6 duplicate key <Name>' -ForEach @(
        @{ Name = 'last-wins-merged'; Status = '"merge_status": "pr_open", "merge_status": "merged"'; ExpectError = $false }
        @{ Name = 'last-wins-pr-open'; Status = '"merge_status": "merged", "merge_status": "pr_open"'; ExpectError = $true }
    ) {
        # Arrange: the dependency object carries merge_status twice; the last definition decides.
        $text = ConvertTo-PortCheckpointText -Feature @(
            (ConvertTo-PortDependencyText -Property $Status),
            (ConvertTo-PortDependentText -DependsOn '["2026-10-08-alpha-901"]'))
        $expected = if ($ExpectError) { $script:StatusError } else { '' }

        # Act
        $result = Get-OrchestratorStateEpicWaveBarrierError -CheckpointText $text

        # Assert
        (@($result) -join "`n") | Should -BeExactly $expected
    }

    It 'U7 strips only the first lifecycle prefix, so a doubly prefixed hint does not resolve' {
        # Arrange: active/ is stripped once, leaving completed/<folder>, which names no feature.
        $text = ConvertTo-PortCheckpointText -Feature @(
            (ConvertTo-PortDependencyText -Property '"merge_status": "pr_open"'),
            (ConvertTo-PortDependentText -DependsOn '["active/completed/2026-10-08-alpha-901"]'))

        # Act
        $result = Get-OrchestratorStateEpicWaveBarrierError -CheckpointText $text

        # Assert
        @($result).Count | Should -Be 0
    }

    It 'U8 resolves a false reference to issue_num 0 and renders it as False' {
        # Arrange
        $text = ConvertTo-PortCheckpointText -Feature @(
            '{"feature_folder": "2026-10-08-zulu-900", "issue_num": 0, "depends_on": [], "merge_status": "pr_open"}',
            (ConvertTo-PortDependentText -DependsOn '[false]'))

        # Act
        $result = Get-OrchestratorStateEpicWaveBarrierError -CheckpointText $text

        # Assert
        (@($result) -join "`n") | Should -BeExactly 'EPIC_WAVE_BARRIER_VIOLATION: 2026-10-08-bravo-902 is treated as started while dependency False is not merged'
    }

    It 'U9 fails closed on text that is not JSON' {
        # Arrange / Act / Assert
        { Get-OrchestratorStateEpicWaveBarrierError -CheckpointText '{ broken' } | Should -Throw -ExpectedMessage $script:UnevaluablePattern
    }

    It 'U10 fails closed on empty text' {
        # Arrange / Act / Assert
        { Get-OrchestratorStateEpicWaveBarrierError -CheckpointText '' } | Should -Throw -ExpectedMessage $script:UnevaluablePattern
    }

    It 'U11 fails closed on a non-integer issue_num and names the token' {
        # Arrange
        $text = ConvertTo-PortCheckpointText -Feature @(
            '{"feature_folder": "2026-10-08-alpha-901", "issue_num": 901.5, "depends_on": [], "merge_status": "pr_open"}')

        # Act / Assert
        { Get-OrchestratorStateEpicWaveBarrierError -CheckpointText $text } | Should -Throw -ExpectedMessage 'EPIC_WAVE_BARRIER_UNEVALUABLE:*901.5*'
    }

    It 'U12 fails closed on an object issue_num' {
        # Arrange
        $text = ConvertTo-PortCheckpointText -Feature @(
            '{"feature_folder": "2026-10-08-alpha-901", "issue_num": {"n": 1}, "depends_on": [], "merge_status": "pr_open"}')

        # Act / Assert
        { Get-OrchestratorStateEpicWaveBarrierError -CheckpointText $text } | Should -Throw -ExpectedMessage 'EPIC_WAVE_BARRIER_UNEVALUABLE:*array or object*'
    }

    It 'U13 does not consult the depends_on of an unstarted dependent' {
        # Arrange: the 901.0 token would fail closed if it were consulted.
        $text = ConvertTo-PortCheckpointText -Feature @(
            (ConvertTo-PortDependencyText -Property '"merge_status": "pr_open"'),
            '{"feature_folder": "2026-10-08-bravo-902", "issue_num": 902, "depends_on": [901.0], "merge_status": "not_started"}')
        $script:U13Result = $null

        # Act / Assert: no throw, and no line.
        { $script:U13Result = Get-OrchestratorStateEpicWaveBarrierError -CheckpointText $text } | Should -Not -Throw
        @($script:U13Result).Count | Should -Be 0
    }
}
