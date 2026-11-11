#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Owner-directive stop-hook rows for validate-orchestrator-output.ps1 (issue #1139).

.DESCRIPTION
    Each row runs Get-OrchestratorOutputBlockDecision with the resolution seam mocked to a
    resolved synthetic target and the read seam mocked to in-memory checkpoint text derived from
    tests/fixtures/orchestrator_state_owner_directives/valid-checkpoint.json through
    System.Text.Json.Nodes edits. The rows cover the block for each checkpoint type, the
    ordinal top-level-key eligibility (zero module calls for a checkpoint without an owner key),
    today's decision for keyless NaN and string-value checkpoints, and the placement of the check
    after the routing dispatch and before the type-specific branches.

    No row creates, writes, or deletes a file, reads a clock, starts a process, or touches the
    network. Synthetic roots use forward slashes and no drive letter.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Injected stubs mirror the production signatures param($Path, $Type) and param([string] $CheckpointText)')]
param()

BeforeAll {
    $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
    . (Join-Path $script:RepoRoot '.claude/hooks/validate-orchestrator-output.ps1')
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Import-Module (Join-Path $script:RepoRoot '.claude/lib/orchestrator-state/OrchestratorState.psm1') -ErrorAction Stop
    Import-Module (Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/WorktreeItemResolution.psm1') -ErrorAction Stop
    Import-Module (Join-Path $script:RepoRoot '.claude/lib/worktree-resolution/WorktreeRunResolution.psm1') -ErrorAction Stop
    Mock Get-CheckpointFileContent { $null }
    Mock Read-OrchestratorOutputOwnerPassDownText { $null }
    Mock Get-OrchestratorStateCheckpoint -ModuleName OrchestratorState { $null }
    Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
    Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
    Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    Mock Resolve-OrchestratorOutputCheckpointPath {
        [pscustomobject]@{ Resolved = $true; CheckpointPath = '/synthetic-worktrees/w-1139/artifacts/orchestration/checkpoint.json'; WorktreeRoot = '/synthetic-worktrees/w-1139'; Status = 'OtherWorktree'; ReasonCode = $null; Detail = 'modelled target (issue #1139)' }
    }

    $script:FixtureText = Get-Content -Raw -LiteralPath (Join-Path $script:RepoRoot 'tests/fixtures/orchestrator_state_owner_directives/valid-checkpoint.json')
    $script:PassingStub = { param($Path, $Type) [pscustomobject]@{ ExitCode = 0; Output = '' } }
    $script:FailingStub = { param($Path, $Type) [pscustomobject]@{ ExitCode = 1; Output = 'x' } }
    $script:Prefix = 'OWNER_DIRECTIVE_BLOCKED: '
    $script:R6Entry2 = 'Checkpoint owner_directive_records entry #2 honors directive OD-2 of refused class gate_bypass.'
    $script:KeylessText = '{"objective":"run the item","completed_steps":[],"next_step":"S5","last_updated":"2026-11-08T10:00:00Z"}'

    # Parse the fixture text, apply an edit to the node tree, and return the edited JSON text.
    function Edit-OwnerDirectiveHookFixture {
        param([scriptblock] $Edit)
        $root = [System.Text.Json.Nodes.JsonNode]::Parse($script:FixtureText)
        & $Edit $root
        return $root.ToJsonString()
    }

    # The fixture text with record #2 (OD-2, gate_bypass) given the outcome Outcome.
    function Get-GateBypassCheckpointText {
        param([string] $Outcome)
        $outcomeValue = $Outcome
        return Edit-OwnerDirectiveHookFixture -Edit { param($root) $root['owner_directive_records'][1]['outcome'] = [System.Text.Json.Nodes.JsonValue]::Create($outcomeValue) }
    }

    # Serve one checkpoint text through the hook's read seam.
    function Set-OwnerDirectiveCheckpointRead {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers a Pester mock for one test only; it changes no system state.')]
        param([string] $Text)
        $content = $Text
        Mock -CommandName Get-CheckpointFileContent -MockWith { @{ Exists = $true; Content = $content } }.GetNewClosure()
    }

    # Run the block decision for one artifact type with the given routing stub.
    function Invoke-OwnerDirectiveDecision {
        param([string] $ArtifactType, [scriptblock] $RoutingInvoker = $script:PassingStub)
        return Get-OrchestratorOutputBlockDecision -AgentOutput 'Final summary.' -CheckpointPath 'artifacts/orchestration/checkpoint.json' -ArtifactType $ArtifactType -RoutingInvoker $RoutingInvoker
    }
}

Describe 'validate-orchestrator-output owner-directive check' {

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    Context 'S8 U5 blocks and allows for each checkpoint type' {
        It 'S8 blocks an honored gate_bypass record for <Type>' -ForEach @(
            @{ Type = 'orchestrator-state' }
            @{ Type = 'epic-orchestrator-state' }
            @{ Type = 'parallel-orchestrator-state' }
        ) {
            Set-OwnerDirectiveCheckpointRead -Text (Get-GateBypassCheckpointText -Outcome 'honored')
            $result = Invoke-OwnerDirectiveDecision -ArtifactType $Type
            $result.Ok | Should -BeFalse
            $result.Repairable | Should -BeTrue
            $result.Message.StartsWith($script:Prefix, [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Message
            $result.Message | Should -BeExactly ($script:Prefix + $script:R6Entry2)
        }

        It 'S8 allows a refused gate_bypass record for <Type>' -ForEach @(
            @{ Type = 'orchestrator-state' }
            @{ Type = 'epic-orchestrator-state' }
            @{ Type = 'parallel-orchestrator-state' }
        ) {
            Set-OwnerDirectiveCheckpointRead -Text (Get-GateBypassCheckpointText -Outcome 'refused')
            $result = Invoke-OwnerDirectiveDecision -ArtifactType $Type
            $result.Ok | Should -BeTrue -Because $result.Message
        }

        It 'U5 allows an honored extra_planner_revision record' {
            Set-OwnerDirectiveCheckpointRead -Text $script:FixtureText
            $result = Invoke-OwnerDirectiveDecision -ArtifactType 'orchestrator-state'
            $result.Ok | Should -BeTrue -Because $result.Message
        }

        It 'U6 blocks a record that cites OD-9 absent from owner_directives' {
            Set-OwnerDirectiveCheckpointRead -Text (Edit-OwnerDirectiveHookFixture -Edit { param($root) $root['owner_directive_records'][0]['directive_id'] = [System.Text.Json.Nodes.JsonValue]::Create('OD-9') })
            $result = Invoke-OwnerDirectiveDecision -ArtifactType 'orchestrator-state'
            $result.Ok | Should -BeFalse
            $result.Message | Should -BeExactly ($script:Prefix + 'Checkpoint owner_directive_records entry #1 references directive OD-9 that is not in owner_directives.')
        }

        It 'S8 joins two violations in entry order with a semicolon separator' {
            Set-OwnerDirectiveCheckpointRead -Text (Edit-OwnerDirectiveHookFixture -Edit {
                    param($root)
                    $root['owner_directive_records'][0] = [System.Text.Json.Nodes.JsonNode]::Parse('{"directive_id":"OD-2","class":"gate_bypass","outcome":"honored","reason":"The owner asked to merge before the checks finished.","decided_by":"orchestrator","decided_at":"2026-11-08T15:00:00Z"}')
                    $root['owner_directive_records'][1]['directive_id'] = [System.Text.Json.Nodes.JsonValue]::Create('OD-9')
                })
            $result = Invoke-OwnerDirectiveDecision -ArtifactType 'orchestrator-state'
            $result.Message | Should -BeExactly ($script:Prefix +
                'Checkpoint owner_directive_records entry #1 honors directive OD-2 of refused class gate_bypass.' + '; ' +
                'Checkpoint owner_directive_records entry #2 references directive OD-9 that is not in owner_directives.')
        }

        It 'S8 blocks with the unevaluable message when the module throws' {
            Mock Get-OrchestratorStateOwnerDirectiveError { param([string] $CheckpointText) throw 'OWNER_DIRECTIVE_UNEVALUABLE: simulated parse failure (issue #1139)' }
            Set-OwnerDirectiveCheckpointRead -Text '{"objective":"run","completed_steps":[],"next_step":"S5","last_updated":"2026-11-08T10:00:00Z","owner_directives":[]}'
            $result = Invoke-OwnerDirectiveDecision -ArtifactType 'orchestrator-state'
            $result.Ok | Should -BeFalse
            $result.Repairable | Should -BeTrue
            $result.Message.StartsWith('OWNER_DIRECTIVE_BLOCKED: OWNER_DIRECTIVE_UNEVALUABLE:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Message
        }
    }

    Context 'U6 eligibility by ordinal top-level key' {
        It 'U6 does not call the module for a checkpoint with neither top-level key' {
            Mock Get-OrchestratorStateOwnerDirectiveError { param([string] $CheckpointText) $script:R6Entry2 }
            Set-OwnerDirectiveCheckpointRead -Text $script:KeylessText
            $result = Invoke-OwnerDirectiveDecision -ArtifactType 'orchestrator-state'
            $result.Ok | Should -BeTrue -Because $result.Message
            $result.Message | Should -BeNullOrEmpty
            $null -eq $result.Message | Should -BeTrue
            Should -Invoke Get-OrchestratorStateOwnerDirectiveError -Times 0 -Exactly
        }

        It 'U6 does not call the module when the only owner-like key is Owner_Directives' {
            Mock Get-OrchestratorStateOwnerDirectiveError { param([string] $CheckpointText) $script:R6Entry2 }
            Set-OwnerDirectiveCheckpointRead -Text '{"objective":"run","completed_steps":[],"next_step":"S5","last_updated":"2026-11-08T10:00:00Z","Owner_Directives":[]}'
            $result = Invoke-OwnerDirectiveDecision -ArtifactType 'orchestrator-state'
            $result.Ok | Should -BeTrue -Because $result.Message
            $null -eq $result.Message | Should -BeTrue
            Should -Invoke Get-OrchestratorStateOwnerDirectiveError -Times 0 -Exactly
        }

        It 'U6 Test-OrchestratorOutputOwnerDirectiveKey returns <Expected> for <Name>' -ForEach @(
            @{ Name = 'owner_directives'; Expected = $true }
            @{ Name = 'owner_directive_records'; Expected = $true }
            @{ Name = 'Owner_Directives'; Expected = $false }
            @{ Name = 'OWNER_DIRECTIVE_RECORDS'; Expected = $false }
        ) {
            Test-OrchestratorOutputOwnerDirectiveKey -PropertyName @('objective', $Name) | Should -Be $Expected
        }
    }

    Context 'S1 keeps the current decision for keyless checkpoints' {
        It 'S1 keeps the current allow for a NaN checkpoint with neither owner key' {
            Set-OwnerDirectiveCheckpointRead -Text '{"objective":"run the item","completed_steps":[],"next_step":"S5","last_updated":"2026-11-08T10:00:00Z","budget":NaN}'
            $result = Invoke-OwnerDirectiveDecision -ArtifactType 'orchestrator-state'
            $result.Ok | Should -BeTrue -Because $result.Message
            $null -eq $result.Message | Should -BeTrue
        }

        It 'S1 keeps the current allow for a NaN checkpoint whose objective names owner_directives' {
            Set-OwnerDirectiveCheckpointRead -Text '{"objective":"record owner_directives before relay","completed_steps":[],"next_step":"S5","last_updated":"2026-11-08T10:00:00Z","budget":NaN}'
            $result = Invoke-OwnerDirectiveDecision -ArtifactType 'orchestrator-state'
            $result.Ok | Should -BeTrue -Because $result.Message
            $null -eq $result.Message | Should -BeTrue
        }

        It 'S1 keeps the current allow when both owner key names appear only in string values' {
            Set-OwnerDirectiveCheckpointRead -Text '{"objective":"relay owner_directives","completed_steps":[],"next_step":"append owner_directive_records","last_updated":"2026-11-08T10:00:00Z"}'
            $result = Invoke-OwnerDirectiveDecision -ArtifactType 'orchestrator-state'
            $result.Ok | Should -BeTrue -Because $result.Message
            $null -eq $result.Message | Should -BeTrue
        }
    }

    Context 'S8 placement after the routing dispatch and before the type branches' {
        It 'S8 keeps the routing block and does not call the module when the routing dispatch fails' {
            Mock Get-OrchestratorStateOwnerDirectiveError { param([string] $CheckpointText) $script:R6Entry2 }
            Set-OwnerDirectiveCheckpointRead -Text (Get-GateBypassCheckpointText -Outcome 'honored')
            $result = Invoke-OwnerDirectiveDecision -ArtifactType 'orchestrator-state' -RoutingInvoker $script:FailingStub
            $result.Message.StartsWith('ROUTING_CONTRACT_BLOCKED:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Message
            $result.Message.Contains('OWNER_DIRECTIVE_BLOCKED') | Should -BeFalse
            Should -Invoke Get-OrchestratorStateOwnerDirectiveError -Times 0 -Exactly
        }

        It 'S8 blocks an epic checkpoint before the wave-barrier branch runs' {
            Mock Get-OrchestratorStateEpicWaveBarrierError { param([string] $CheckpointText) , [string[]] @('EPIC_WAVE_BARRIER_VIOLATION: simulated (issue #1139)') }
            Set-OwnerDirectiveCheckpointRead -Text (Get-GateBypassCheckpointText -Outcome 'honored')
            $result = Invoke-OwnerDirectiveDecision -ArtifactType 'epic-orchestrator-state'
            $result.Message.StartsWith($script:Prefix, [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Message
            Should -Invoke Get-OrchestratorStateEpicWaveBarrierError -Times 0 -Exactly
        }
    }
}
