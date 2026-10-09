#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Layer 2 wave-barrier rows for validate-orchestrator-output.ps1 (issue #840).

.DESCRIPTION
    Each row runs Invoke-OrchestratorOutputValidation with the resolution seam mocked to a
    resolved epic target and the read seam mocked to an in-memory checkpoint text. The
    rows cover the violation block (unwrapped lines followed by the report-and-halt
    instruction), the epic-only call after the routing dispatch passes, and every
    fail-closed path that yields EPIC_WAVE_BARRIER_UNEVALUABLE:.

    No row creates, writes, or deletes a file, uses a temporary path or the Pester temporary drive, reads
    a clock, starts a process, or touches the network. Folder names follow the parity
    corpus tests/fixtures/epic_wave_barrier/layer2-parity-edge-cases.json.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Injected routing stubs mirror the production $Invoker scriptblock signature param($Path, $Type) for testing')]
param()

BeforeAll {
    . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/validate-orchestrator-output.ps1").Path

    $script:RoutingStub = { param($Path, $Type) [pscustomobject]@{ ExitCode = 0; Output = '' } }
    $script:Payload = (@{ output = 'Final summary. integration_branch: epic/c6-integration' } | ConvertTo-Json -Compress)
    $script:EpicLeaf = 'artifacts/orchestration/epic-orchestrator-state.json'
    $script:Alpha = '{"feature_folder": "2026-10-08-alpha-901", "issue_num": 901, "depends_on": [], "merge_status": "pr_open"}'
    $script:Bravo = '{"feature_folder": "2026-10-08-bravo-902", "issue_num": 902, "depends_on": ["2026-10-08-alpha-901"], "merge_status": "worktree_created", "worktree_created_at": "2026-10-08T10-00"}'
    $script:StatusLine = 'EPIC_WAVE_BARRIER_VIOLATION: 2026-10-08-bravo-902 is treated as started while dependency 2026-10-08-alpha-901 is not merged'

    # An epic checkpoint text with the four required fields and the given feature objects.
    function ConvertTo-BarrierCheckpointText {
        param([string[]] $Feature)
        return ('{"objective":"run epic","completed_steps":[],"next_step":"wave_1","last_updated":"2026-10-08T00-00","route_id":"epic",' +
            '"integration_branch":"epic/c6-integration","features":[' + ($Feature -join ',') + ']}')
    }

    # Serve one checkpoint text through the hook's read seam.
    function Set-BarrierCheckpointRead {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers a Pester mock for one test only; it changes no system state.')]
        param([string] $Text)
        $content = $Text
        Mock -CommandName Get-CheckpointFileContent -MockWith { @{ Exists = $true; Content = $content } }.GetNewClosure()
    }

    # Replace the resolution seam with a resolved target at the epic worktree.
    function Set-BarrierResolvedTarget {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers a Pester mock for one test only; it changes no system state.')]
        param()
        Mock Resolve-OrchestratorOutputCheckpointPath {
            [pscustomobject]@{ Resolved = $true; CheckpointPath = '/synthetic-worktrees/w-epic/artifacts/orchestration/epic-orchestrator-state.json'; WorktreeRoot = '/synthetic-worktrees/w-epic'; Status = 'OtherWorktree'; ReasonCode = $null; Detail = 'modelled epic target (issue #840)' }
        }
    }
}

Describe 'validate-orchestrator-output Layer 2 wave barrier' {
    BeforeAll {
        Set-BarrierResolvedTarget
    }

    It 'H1 surfaces one unmerged dependency as an unwrapped line followed by the halt instruction' {
        # Arrange
        Set-BarrierCheckpointRead -Text (ConvertTo-BarrierCheckpointText -Feature @($script:Alpha, $script:Bravo))

        # Act
        $result = Invoke-OrchestratorOutputValidation -RawPayload $script:Payload -CheckpointPath $script:EpicLeaf -ArtifactType 'epic-orchestrator-state' -RoutingInvoker $script:RoutingStub
        $lines = @($result.Message -split "`n")

        # Assert
        $result.Ok | Should -BeFalse
        $lines.Count | Should -Be 2
        $lines[0] | Should -BeExactly $script:StatusLine
        $lines[1] | Should -BeExactly $script:OrchestratorOutputHaltInstruction
    }

    It 'H2 surfaces two violated edges in depends_on order before the halt instruction' {
        # Arrange: the features of the corpus case multiple-edges-reported-in-depends-on-order.
        Set-BarrierCheckpointRead -Text (ConvertTo-BarrierCheckpointText -Feature @(
                $script:Alpha,
                '{"feature_folder": "2026-10-08-charlie-903", "issue_num": 903, "depends_on": [], "merge_status": "merged", "merge_confirmed_at": "2026-10-08T11-00"}',
                '{"feature_folder": "2026-10-08-bravo-902", "issue_num": 902, "depends_on": ["2026-10-08-charlie-903", "2026-10-08-alpha-901"], "merge_status": "worktree_created", "worktree_created_at": "2026-10-08T10-00"}'))

        # Act
        $result = Invoke-OrchestratorOutputValidation -RawPayload $script:Payload -CheckpointPath $script:EpicLeaf -ArtifactType 'epic-orchestrator-state' -RoutingInvoker $script:RoutingStub
        $lines = @($result.Message -split "`n")

        # Assert
        $lines.Count | Should -Be 3
        $lines[0] | Should -BeExactly 'EPIC_WAVE_BARRIER_VIOLATION: 2026-10-08-bravo-902 worktree_created_at precedes dependency 2026-10-08-charlie-903 merge_confirmed_at'
        $lines[1] | Should -BeExactly $script:StatusLine
        $lines[2] | Should -BeExactly $script:OrchestratorOutputHaltInstruction
    }

    It 'H3 instructs the agent to report and halt without suggesting an edit to history' {
        # Arrange
        Set-BarrierCheckpointRead -Text (ConvertTo-BarrierCheckpointText -Feature @($script:Alpha, $script:Bravo))

        # Act
        $result = Invoke-OrchestratorOutputValidation -RawPayload $script:Payload -CheckpointPath $script:EpicLeaf -ArtifactType 'epic-orchestrator-state' -RoutingInvoker $script:RoutingStub
        $lastLine = @($result.Message -split "`n")[-1]

        # Assert
        $lastLine | Should -Match 'operator'
        $lastLine | Should -Match 'halt'
        $lastLine | Should -Not -Match '(?i)\b(edit|rewrite|modify|change|update|delete|remove|reset)\b|timestamp|merge_status|history'
    }

    It 'H4 passes a clean epic checkpoint whose dependency merged before the dependent started' {
        # Arrange
        Set-BarrierCheckpointRead -Text (ConvertTo-BarrierCheckpointText -Feature @(
                '{"feature_folder": "2026-10-08-alpha-901", "issue_num": 901, "depends_on": [], "merge_status": "merged", "merge_confirmed_at": "2026-10-08T09-00"}',
                $script:Bravo))

        # Act
        $result = Invoke-OrchestratorOutputValidation -RawPayload $script:Payload -CheckpointPath $script:EpicLeaf -ArtifactType 'epic-orchestrator-state' -RoutingInvoker $script:RoutingStub

        # Assert
        $result.Ok | Should -BeTrue -Because $result.Message
    }

    It 'H5 does not run the port for the parallel checkpoint type' {
        # Arrange
        Set-BarrierCheckpointRead -Text (ConvertTo-BarrierCheckpointText -Feature @($script:Alpha, $script:Bravo))
        Mock Get-OrchestratorStateEpicWaveBarrierError { throw 'the port must not run (issue #840)' }

        # Act
        $result = Invoke-OrchestratorOutputValidation -RawPayload $script:Payload -CheckpointPath 'artifacts/orchestration/parallel-orchestrator-state.json' -ArtifactType 'parallel-orchestrator-state' -RoutingInvoker $script:RoutingStub

        # Assert
        $result.Ok | Should -BeTrue -Because $result.Message
        Should -Invoke Get-OrchestratorStateEpicWaveBarrierError -Times 0 -Exactly
    }

    It 'H6 does not run the port for the orchestrator-state checkpoint type' {
        # Arrange
        Set-BarrierCheckpointRead -Text (ConvertTo-BarrierCheckpointText -Feature @($script:Alpha, $script:Bravo))
        Mock Get-OrchestratorStateEpicWaveBarrierError { throw 'the port must not run (issue #840)' }

        # Act
        $result = Invoke-OrchestratorOutputValidation -RawPayload $script:Payload -RoutingInvoker $script:RoutingStub

        # Assert
        $result.Ok | Should -BeTrue -Because $result.Message
        Should -Invoke Get-OrchestratorStateEpicWaveBarrierError -Times 0 -Exactly
    }

    It 'H7 keeps the routing block and does not run the port when the routing dispatch fails' {
        # Arrange
        Set-BarrierCheckpointRead -Text (ConvertTo-BarrierCheckpointText -Feature @($script:Alpha, $script:Bravo))
        Mock Get-OrchestratorStateEpicWaveBarrierError { @() }
        $failingStub = { param($Path, $Type) [pscustomobject]@{ ExitCode = 1; Output = 'x' } }

        # Act
        $result = Invoke-OrchestratorOutputValidation -RawPayload $script:Payload -CheckpointPath $script:EpicLeaf -ArtifactType 'epic-orchestrator-state' -RoutingInvoker $failingStub

        # Assert
        $result.Message.StartsWith('ROUTING_CONTRACT_BLOCKED:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Message
        Should -Invoke Get-OrchestratorStateEpicWaveBarrierError -Times 0 -Exactly
    }

    It 'H8 blocks as unevaluable for an array issue_num and reports no violation line' {
        # Arrange
        Set-BarrierCheckpointRead -Text (ConvertTo-BarrierCheckpointText -Feature @(
                '{"feature_folder": "2026-10-08-alpha-901", "issue_num": [901], "depends_on": [], "merge_status": "pr_open"}',
                $script:Bravo))

        # Act
        $result = Invoke-OrchestratorOutputValidation -RawPayload $script:Payload -CheckpointPath $script:EpicLeaf -ArtifactType 'epic-orchestrator-state' -RoutingInvoker $script:RoutingStub

        # Assert
        $result.Message.StartsWith('EPIC_WAVE_BARRIER_UNEVALUABLE:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Message
        $result.Message.Contains('EPIC_WAVE_BARRIER_VIOLATION') | Should -BeFalse
    }

    It 'H9 blocks as unevaluable for a NaN literal that ConvertFrom-Json accepts' {
        # Arrange
        Set-BarrierCheckpointRead -Text (ConvertTo-BarrierCheckpointText -Feature @(
                '{"feature_folder": "2026-10-08-alpha-901", "issue_num": 901, "depends_on": [], "merge_status": "merged", "merge_confirmed_at": NaN}',
                $script:Bravo))

        # Act
        $result = Invoke-OrchestratorOutputValidation -RawPayload $script:Payload -CheckpointPath $script:EpicLeaf -ArtifactType 'epic-orchestrator-state' -RoutingInvoker $script:RoutingStub

        # Assert
        $result.Message.StartsWith('EPIC_WAVE_BARRIER_UNEVALUABLE:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Message
    }

    It 'H10 blocks as unevaluable for a value nested in 70 arrays' {
        # Arrange
        $deep = ('[' * 70) + (']' * 70)
        Set-BarrierCheckpointRead -Text (ConvertTo-BarrierCheckpointText -Feature @(
                ('{"feature_folder": "2026-10-08-alpha-901", "issue_num": 901, "depends_on": [], "merge_status": "merged", "notes": ' + $deep + '}'),
                $script:Bravo))

        # Act
        $result = Invoke-OrchestratorOutputValidation -RawPayload $script:Payload -CheckpointPath $script:EpicLeaf -ArtifactType 'epic-orchestrator-state' -RoutingInvoker $script:RoutingStub

        # Assert
        $result.Message.StartsWith('EPIC_WAVE_BARRIER_UNEVALUABLE:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Message
    }

    It 'H11 blocks as unevaluable when the port fails with any other error' {
        # Arrange
        Set-BarrierCheckpointRead -Text (ConvertTo-BarrierCheckpointText -Feature @($script:Alpha, $script:Bravo))
        Mock Get-OrchestratorStateEpicWaveBarrierError { throw 'simulated port failure (issue #840)' }

        # Act
        $result = Invoke-OrchestratorOutputValidation -RawPayload $script:Payload -CheckpointPath $script:EpicLeaf -ArtifactType 'epic-orchestrator-state' -RoutingInvoker $script:RoutingStub

        # Assert
        $result.Message.StartsWith('EPIC_WAVE_BARRIER_UNEVALUABLE:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Message
        $result.Message.Contains('simulated port failure') | Should -BeTrue -Because $result.Message
    }

    It 'H12 blocks the epic leg naming OrchestratorStateEpicWaveBarrier.psm1 when its import failed' {
        # Arrange: reload the hook with the Layer 2 import throwing, so its own import guard
        # records the failure; every other import is a no-op.
        Mock Import-Module { }
        Mock Import-Module { throw 'simulated import failure (issue #840)' } -ParameterFilter { $Name -like '*OrchestratorStateEpicWaveBarrier.psm1' }
        . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/validate-orchestrator-output.ps1").Path
        Set-BarrierResolvedTarget
        Set-BarrierCheckpointRead -Text (ConvertTo-BarrierCheckpointText -Feature @($script:Alpha, $script:Bravo))
        try {
            # Act
            $result = Invoke-OrchestratorOutputValidation -RawPayload $script:Payload -CheckpointPath $script:EpicLeaf -ArtifactType 'epic-orchestrator-state' -RoutingInvoker $script:RoutingStub
        }
        finally {
            $script:OrchestratorOutputWaveBarrierImportFailure = $null
        }

        # Assert
        $result.Message.StartsWith('EPIC_WAVE_BARRIER_UNEVALUABLE:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Message
        $result.Message.Contains('OrchestratorStateEpicWaveBarrier.psm1') | Should -BeTrue -Because $result.Message
    }
}
