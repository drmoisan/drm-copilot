#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Two-worktree topology rows for validate-orchestrator-output.ps1 (issue #787).

.DESCRIPTION
    Each row runs Invoke-OrchestratorOutputValidation through the shipped resolver. The
    live-root and checkpoint-text seams are mocked both in module scope
    'WorktreeRunResolution' and in script scope (the resolution sibling calls them
    directly), so the run checkpoint can sit in a worktree other than the session root.
    The rows cover the epic checkpoint (payload signal, stale session copy, discovery,
    concurrent-epic ambiguity, no target), the parallel checkpoint (none, one, several, and
    a payload signal), the item checkpoint, the runbook_path existence check beneath the
    resolved root, and a non-canonical -CheckpointPath.

    The read seam Get-CheckpointFileContent is mocked in every row that reaches it, so no
    row reads, creates, or writes a file, uses a temporary path or the Pester temporary drive, reads a
    clock, starts a process, or touches the network. Synthetic roots use the
    /synthetic-worktrees/<name> form.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Injected routing stubs mirror the production $Invoker scriptblock signature param($Path, $Type) for testing')]
param()

BeforeAll {
    . (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/validate-orchestrator-output.ps1").Path
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/orchestrator-state/OrchestratorState.psm1')).Path -ErrorAction Stop
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
    Mock Get-CheckpointFileContent { $null }
    Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
    Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
    Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
    $libRoot = (Resolve-Path "$PSScriptRoot/../../../.claude/lib").Path
    Import-Module (Join-Path $libRoot 'worktree-resolution/WorktreeTargetResolution.psm1')
    Import-Module (Join-Path $libRoot 'worktree-resolution/WorktreeResolution.psm1')
    # The completion module re-imports OrchestratorState.psm1 internally, so the state
    # module is imported last to keep Get-OrchestratorStateCheckpoint mockable here.
    Import-Module (Join-Path $libRoot 'orchestrator-state/OrchestratorStateCompletion.psm1') -Force
    Import-Module (Join-Path $libRoot 'orchestrator-state/OrchestratorState.psm1') -Force
    Mock Get-OrchestratorStateCheckpoint -ModuleName OrchestratorState { $null }
    . (Join-Path $PSScriptRoot 'WorktreeResolutionFixture.Helpers.ps1')

    $script:Session = (Get-Location).Path.Replace([string][char]92, '/')
    $script:NoTargetCode = Get-WorktreeResolutionNoTargetReasonCode
    $script:AmbiguityCode = Get-WorktreeResolutionAmbiguityReasonCode
    $script:EpicLeaf = 'artifacts/orchestration/epic-orchestrator-state.json'
    $script:ParallelLeaf = 'artifacts/orchestration/parallel-orchestrator-state.json'

    # A run checkpoint text carrying the four required fields, the route, and its identity.
    function ConvertTo-OutputCheckpointText {
        param([string] $RouteId, [string] $Field, [string] $Value, [string] $Extra = '')
        return ('{"objective":"run ' + $RouteId + '","completed_steps":[],"next_step":"wave_1","last_updated":"2026-10-08T00-00","route_id":"' +
            $RouteId + '","' + $Field + '":"' + $Value + '"' + $Extra + '}')
    }

    function ConvertTo-OutputPayload {
        param([string] $Output)
        return (@{ output = $Output } | ConvertTo-Json -Compress)
    }

    # Model the live worktrees for the shipped resolver and for the sibling's discovery.
    function Set-OutputRunTopology {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([string[]] $Live = @(), [string[]] $BranchRoot = @(), [hashtable] $Epic = @{}, [hashtable] $Parallel = @{})
        $liveSet = $Live
        $branchSet = $BranchRoot
        $textMap = @{}
        foreach ($root in $Epic.Keys) { $textMap["$root/artifacts/orchestration/epic-orchestrator-state.json"] = $Epic[$root] }
        foreach ($root in $Parallel.Keys) { $textMap["$root/artifacts/orchestration/parallel-orchestrator-state.json"] = $Parallel[$root] }
        $liveMock = {
            param([string] $Branch)
            if (-not [string]::IsNullOrWhiteSpace($Branch)) { return , [string[]] $branchSet }
            return , [string[]] $liveSet
        }.GetNewClosure()
        $textMock = {
            param([string] $Path)
            if ($textMap.ContainsKey($Path)) { return $textMap[$Path] }
            return $null
        }.GetNewClosure()
        Mock -CommandName Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution -MockWith $liveMock
        Mock -CommandName Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution -MockWith $textMock
        Mock -CommandName Get-WorktreeItemLiveRoot -MockWith $liveMock
        Mock -CommandName Get-WorktreeRunCheckpointText -MockWith $textMock
    }

    # Serve checkpoint text through the hook's read seam by exact path.
    function Set-OutputCheckpointRead {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers a Pester mock for one test only; it changes no system state.')]
        param([hashtable] $Map = @{})
        $readMap = $Map
        Mock -CommandName Get-CheckpointFileContent -MockWith {
            param([string] $Path)
            if ($readMap.ContainsKey($Path)) { return @{ Exists = $true; Content = $readMap[$Path] } }
            return @{ Exists = $false; Content = $null }
        }.GetNewClosure()
    }

    $script:RoutingStub = {
        param($Path, $Type)
        $script:RoutingReached = $true
        [pscustomobject]@{ ExitCode = 0; Output = '' }
    }
}

Describe 'validate-orchestrator-output target-worktree resolution' {

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    BeforeEach {
        Mock Get-OrchestratorStateCheckpoint { @{ Ok = $true; State = [pscustomobject]@{}; Error = '' } }
        Mock Test-OrchestratorStateCompletionReadiness { @{ ExitCode = 0; Output = '' } }
        Mock Get-OrchestratorStateEpicWaveBarrierError { @() }
        $script:RoutingReached = $false
    }

    It 'R1 reads the epic checkpoint under the worktree that records the named integration branch' {
        # Arrange
        $text = ConvertTo-OutputCheckpointText -RouteId 'epic' -Field 'integration_branch' -Value 'epic/c6-integration'
        $path = "/synthetic-worktrees/w-epic/$script:EpicLeaf"
        Set-OutputRunTopology -Live @($script:Session, '/synthetic-worktrees/w-epic') -Epic @{ '/synthetic-worktrees/w-epic' = $text }
        Set-OutputCheckpointRead -Map @{ $path = $text }

        # Act
        $result = Invoke-OrchestratorOutputValidation -RawPayload (ConvertTo-OutputPayload -Output 'Done. integration_branch: epic/c6-integration') `
            -CheckpointPath $script:EpicLeaf -ArtifactType 'epic-orchestrator-state' -SessionRoot $script:Session

        # Assert
        $result.Ok | Should -BeTrue -Because $result.Message
        Should -Invoke Get-CheckpointFileContent -Times 1 -Exactly -ParameterFilter { $Path -eq $path }
        Should -Invoke Get-OrchestratorStateCheckpoint -Times 1 -Exactly -ParameterFilter { $CheckpointPath -eq $path }
        Should -Invoke Get-OrchestratorStateEpicWaveBarrierError -Times 1 -Exactly -ParameterFilter { $CheckpointText -ceq $text }
    }

    It 'R2 reads the worktree that has the branch checked out over a stale session-root copy' {
        # Arrange
        $text = ConvertTo-OutputCheckpointText -RouteId 'epic' -Field 'integration_branch' -Value 'epic/c6-integration'
        $owner = "/synthetic-worktrees/w-epic/$script:EpicLeaf"
        $stale = "$($script:Session)/$script:EpicLeaf"
        Set-OutputRunTopology -Live @($script:Session, '/synthetic-worktrees/w-epic') -BranchRoot @('/synthetic-worktrees/w-epic') `
            -Epic @{ $script:Session = $text; '/synthetic-worktrees/w-epic' = $text }
        Set-OutputCheckpointRead -Map @{ $owner = $text; $stale = $text }

        # Act
        $null = Invoke-OrchestratorOutputValidation -RawPayload (ConvertTo-OutputPayload -Output 'integration_branch: epic/c6-integration') `
            -CheckpointPath $script:EpicLeaf -ArtifactType 'epic-orchestrator-state' -SessionRoot $script:Session

        # Assert
        Should -Invoke Get-CheckpointFileContent -Times 1 -Exactly -ParameterFilter { $Path -eq $owner }
        Should -Invoke Get-CheckpointFileContent -Times 0 -Exactly -ParameterFilter { $Path -eq $stale }
    }

    It 'R3 follows the payload signal when two worktrees record different epic branches' {
        # Arrange
        $textA = ConvertTo-OutputCheckpointText -RouteId 'epic' -Field 'integration_branch' -Value 'epic/a'
        $textB = ConvertTo-OutputCheckpointText -RouteId 'epic' -Field 'integration_branch' -Value 'epic/b'
        $pathB = "/synthetic-worktrees/w-b/$script:EpicLeaf"
        Set-OutputRunTopology -Live @('/synthetic-worktrees/w-a', '/synthetic-worktrees/w-b') -Epic @{ '/synthetic-worktrees/w-a' = $textA; '/synthetic-worktrees/w-b' = $textB }
        Set-OutputCheckpointRead -Map @{ $pathB = $textB }

        # Act
        $result = Invoke-OrchestratorOutputValidation -RawPayload (ConvertTo-OutputPayload -Output 'integration_branch: epic/b') `
            -CheckpointPath $script:EpicLeaf -ArtifactType 'epic-orchestrator-state' -SessionRoot $script:Session

        # Assert
        $result.Ok | Should -BeTrue -Because $result.Message
        Should -Invoke Get-CheckpointFileContent -Times 1 -Exactly -ParameterFilter { $Path -eq $pathB }
    }

    It 'R4 discovers the single live epic run when the output names no branch' {
        # Arrange
        $text = ConvertTo-OutputCheckpointText -RouteId 'epic' -Field 'integration_branch' -Value 'epic/c6-integration'
        $path = "/synthetic-worktrees/w-epic/$script:EpicLeaf"
        Set-OutputRunTopology -Live @($script:Session, '/synthetic-worktrees/w-epic') -Epic @{ '/synthetic-worktrees/w-epic' = $text }
        Set-OutputCheckpointRead -Map @{ $path = $text }

        # Act
        $result = Invoke-OrchestratorOutputValidation -RawPayload (ConvertTo-OutputPayload -Output 'Final summary.') `
            -CheckpointPath $script:EpicLeaf -ArtifactType 'epic-orchestrator-state' -SessionRoot $script:Session

        # Assert
        $result.Ok | Should -BeTrue -Because $result.Message
        Should -Invoke Get-CheckpointFileContent -Times 1 -Exactly -ParameterFilter { $Path -eq $path }
    }

    It 'R5 blocks as Ambiguous when two live epics record distinct branches and the output names none' {
        # Arrange
        Set-OutputRunTopology -Live @('/synthetic-worktrees/w-a', '/synthetic-worktrees/w-b') -Epic @{
            '/synthetic-worktrees/w-a' = (ConvertTo-OutputCheckpointText -RouteId 'epic' -Field 'integration_branch' -Value 'epic/a')
            '/synthetic-worktrees/w-b' = (ConvertTo-OutputCheckpointText -RouteId 'epic' -Field 'integration_branch' -Value 'epic/b')
        }
        Set-OutputCheckpointRead

        # Act
        $result = Invoke-OrchestratorOutputValidation -RawPayload (ConvertTo-OutputPayload -Output 'Final summary.') `
            -CheckpointPath $script:EpicLeaf -ArtifactType 'epic-orchestrator-state' -SessionRoot $script:Session -RoutingInvoker $script:RoutingStub

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message.StartsWith("ORCHESTRATOR_CHECKPOINT_UNRESOLVED: epic-orchestrator-state: Ambiguous ($script:AmbiguityCode", [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Message
        Should -Invoke Get-CheckpointFileContent -Times 0 -Exactly
        $script:RoutingReached | Should -BeFalse
        Should -Invoke Get-OrchestratorStateEpicWaveBarrierError -Times 0 -Exactly
    }

    It 'R6 blocks as NoTarget when no live worktree holds an epic checkpoint' {
        # Arrange
        Set-OutputRunTopology -Live @($script:Session, '/synthetic-worktrees/w-epic')
        Set-OutputCheckpointRead

        # Act
        $result = Invoke-OrchestratorOutputValidation -RawPayload (ConvertTo-OutputPayload -Output 'Final summary.') `
            -CheckpointPath $script:EpicLeaf -ArtifactType 'epic-orchestrator-state' -SessionRoot $script:Session -RoutingInvoker $script:RoutingStub

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message.StartsWith("ORCHESTRATOR_CHECKPOINT_UNRESOLVED: epic-orchestrator-state: NoTarget ($script:NoTargetCode", [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Message
        Should -Invoke Get-CheckpointFileContent -Times 0 -Exactly
        $script:RoutingReached | Should -BeFalse
        Should -Invoke Get-OrchestratorStateEpicWaveBarrierError -Times 0 -Exactly
    }

    It 'R7 never reads a stale session-root epic copy that records another branch' {
        # Arrange
        Set-OutputRunTopology -Live @($script:Session) -Epic @{ $script:Session = (ConvertTo-OutputCheckpointText -RouteId 'epic' -Field 'integration_branch' -Value 'epic/old') }
        Set-OutputCheckpointRead -Map @{ "$($script:Session)/$script:EpicLeaf" = '{}' }

        # Act
        $result = Invoke-OrchestratorOutputValidation -RawPayload (ConvertTo-OutputPayload -Output 'integration_branch: epic/new') `
            -CheckpointPath $script:EpicLeaf -ArtifactType 'epic-orchestrator-state' -SessionRoot $script:Session -RoutingInvoker $script:RoutingStub

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message.StartsWith("ORCHESTRATOR_CHECKPOINT_UNRESOLVED: epic-orchestrator-state: NoTarget ($script:NoTargetCode", [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Message
        Should -Invoke Get-CheckpointFileContent -Times 0 -Exactly
        $script:RoutingReached | Should -BeFalse
        Should -Invoke Get-OrchestratorStateEpicWaveBarrierError -Times 0 -Exactly
    }

    It 'R8 blocks a parallel validation as NoTarget when no live parallel checkpoint exists' {
        # Arrange
        Set-OutputRunTopology -Live @($script:Session, '/synthetic-worktrees/w-par')
        Set-OutputCheckpointRead

        # Act
        $result = Invoke-OrchestratorOutputValidation -RawPayload (ConvertTo-OutputPayload -Output 'Final summary.') `
            -CheckpointPath $script:ParallelLeaf -ArtifactType 'parallel-orchestrator-state' -SessionRoot $script:Session -RoutingInvoker $script:RoutingStub

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message.StartsWith("ORCHESTRATOR_CHECKPOINT_UNRESOLVED: parallel-orchestrator-state: NoTarget ($script:NoTargetCode", [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Message
        Should -Invoke Get-CheckpointFileContent -Times 0 -Exactly
        $script:RoutingReached | Should -BeFalse
        Should -Invoke Get-OrchestratorStateEpicWaveBarrierError -Times 0 -Exactly
    }

    It 'R9 discovers the single live parallel run and reads its checkpoint' {
        # Arrange
        $text = ConvertTo-OutputCheckpointText -RouteId 'parallel' -Field 'parallel_slug' -Value 'demo'
        $path = "/synthetic-worktrees/w-par/$script:ParallelLeaf"
        Set-OutputRunTopology -Live @($script:Session, '/synthetic-worktrees/w-par') -Parallel @{ '/synthetic-worktrees/w-par' = $text }
        Set-OutputCheckpointRead -Map @{ $path = $text }

        # Act
        $result = Invoke-OrchestratorOutputValidation -RawPayload (ConvertTo-OutputPayload -Output 'Final summary.') `
            -CheckpointPath $script:ParallelLeaf -ArtifactType 'parallel-orchestrator-state' -SessionRoot $script:Session

        # Assert
        $result.Ok | Should -BeTrue -Because $result.Message
        Should -Invoke Get-CheckpointFileContent -Times 1 -Exactly -ParameterFilter { $Path -eq $path }
        Should -Invoke Get-OrchestratorStateCheckpoint -Times 1 -Exactly -ParameterFilter { $CheckpointPath -eq $path }
        Should -Invoke Get-OrchestratorStateEpicWaveBarrierError -Times 0 -Exactly
    }

    It 'R10 blocks as Ambiguous when two live parallel runs record distinct slugs' {
        # Arrange
        Set-OutputRunTopology -Live @('/synthetic-worktrees/w-p1', '/synthetic-worktrees/w-p2') -Parallel @{
            '/synthetic-worktrees/w-p1' = (ConvertTo-OutputCheckpointText -RouteId 'parallel' -Field 'parallel_slug' -Value 'alpha')
            '/synthetic-worktrees/w-p2' = (ConvertTo-OutputCheckpointText -RouteId 'parallel' -Field 'parallel_slug' -Value 'beta')
        }
        Set-OutputCheckpointRead

        # Act
        $result = Invoke-OrchestratorOutputValidation -RawPayload (ConvertTo-OutputPayload -Output 'Final summary.') `
            -CheckpointPath $script:ParallelLeaf -ArtifactType 'parallel-orchestrator-state' -SessionRoot $script:Session -RoutingInvoker $script:RoutingStub

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message.StartsWith("ORCHESTRATOR_CHECKPOINT_UNRESOLVED: parallel-orchestrator-state: Ambiguous ($script:AmbiguityCode", [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Message
        Should -Invoke Get-CheckpointFileContent -Times 0 -Exactly
        $script:RoutingReached | Should -BeFalse
        Should -Invoke Get-OrchestratorStateEpicWaveBarrierError -Times 0 -Exactly
    }

    It 'R11 follows the parallel_slug the output names' {
        # Arrange
        $textBeta = ConvertTo-OutputCheckpointText -RouteId 'parallel' -Field 'parallel_slug' -Value 'beta'
        $pathBeta = "/synthetic-worktrees/w-p2/$script:ParallelLeaf"
        Set-OutputRunTopology -Live @('/synthetic-worktrees/w-p1', '/synthetic-worktrees/w-p2') -Parallel @{
            '/synthetic-worktrees/w-p1' = (ConvertTo-OutputCheckpointText -RouteId 'parallel' -Field 'parallel_slug' -Value 'alpha')
            '/synthetic-worktrees/w-p2' = $textBeta
        }
        Set-OutputCheckpointRead -Map @{ $pathBeta = $textBeta }

        # Act
        $result = Invoke-OrchestratorOutputValidation -RawPayload (ConvertTo-OutputPayload -Output 'parallel_slug: beta') `
            -CheckpointPath $script:ParallelLeaf -ArtifactType 'parallel-orchestrator-state' -SessionRoot $script:Session

        # Assert
        $result.Ok | Should -BeTrue -Because $result.Message
        Should -Invoke Get-CheckpointFileContent -Times 1 -Exactly -ParameterFilter { $Path -eq $pathBeta }
    }

    It 'R12 composes the item checkpoint beneath the session worktree with the default arguments' {
        # Arrange
        $target = New-WorktreeResolutionFixtureTarget -Status 'SessionRoot' -WorktreeRoot '/synthetic-worktrees/w-item'
        Mock Resolve-WorktreeOperandTarget { $target }.GetNewClosure()
        $path = '/synthetic-worktrees/w-item/artifacts/orchestration/orchestrator-state.json'
        Set-OutputCheckpointRead -Map @{ $path = '{"objective":"deliver feature X","completed_steps":["step1"],"next_step":"complete","last_updated":"2026-10-08T00-00"}' }

        # Act
        $result = Invoke-OrchestratorOutputValidation -RawPayload (ConvertTo-OutputPayload -Output 'Final summary.') -SessionRoot $script:Session

        # Assert
        $result.Ok | Should -BeTrue -Because $result.Message
        Should -Invoke Get-CheckpointFileContent -Times 1 -Exactly -ParameterFilter { $Path -eq $path }
        Should -Invoke Test-OrchestratorStateCompletionReadiness -Times 1 -Exactly -ParameterFilter { $CheckpointPath -eq $path }
        Should -Invoke Get-OrchestratorStateEpicWaveBarrierError -Times 0 -Exactly
    }

    It 'R13 checks a relative runbook_path beneath the resolved epic worktree' {
        # Arrange
        $extra = ',"human_interaction":{"requirements":[{"response":"exception","runbook_path":"docs/runbooks/epic-halt.md"}]}'
        $text = ConvertTo-OutputCheckpointText -RouteId 'epic' -Field 'integration_branch' -Value 'epic/c6-integration' -Extra $extra
        $path = "/synthetic-worktrees/w-epic/$script:EpicLeaf"
        Set-OutputRunTopology -Live @($script:Session, '/synthetic-worktrees/w-epic') -Epic @{ '/synthetic-worktrees/w-epic' = $text }
        Set-OutputCheckpointRead -Map @{ $path = $text }
        Mock Test-OrchestratorOutputRunbookFile { $true }

        # Act
        $result = Invoke-OrchestratorOutputValidation -RawPayload (ConvertTo-OutputPayload -Output 'integration_branch: epic/c6-integration') `
            -CheckpointPath $script:EpicLeaf -ArtifactType 'epic-orchestrator-state' -SessionRoot $script:Session

        # Assert
        $result.Ok | Should -BeTrue -Because $result.Message
        Should -Invoke Test-OrchestratorOutputRunbookFile -Times 1 -Exactly -ParameterFilter { $Path -eq '/synthetic-worktrees/w-epic/docs/runbooks/epic-halt.md' }
    }

    It 'R14 rejects the item checkpoint leaf for an epic validation before any read' {
        # Arrange
        $text = ConvertTo-OutputCheckpointText -RouteId 'epic' -Field 'integration_branch' -Value 'epic/c6-integration'
        Set-OutputRunTopology -Live @($script:Session, '/synthetic-worktrees/w-epic') -Epic @{ '/synthetic-worktrees/w-epic' = $text }
        Set-OutputCheckpointRead

        # Act
        $result = Invoke-OrchestratorOutputValidation -RawPayload (ConvertTo-OutputPayload -Output 'integration_branch: epic/c6-integration') `
            -CheckpointPath 'artifacts/orchestration/orchestrator-state.json' -ArtifactType 'epic-orchestrator-state' -SessionRoot $script:Session

        # Assert
        $result.Message.StartsWith('ORCHESTRATOR_CHECKPOINT_UNRESOLVED: epic-orchestrator-state: Rejected (CHECKPOINT_PATH_MISMATCH):', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Message
        Should -Invoke Get-CheckpointFileContent -Times 0 -Exactly
    }
}
