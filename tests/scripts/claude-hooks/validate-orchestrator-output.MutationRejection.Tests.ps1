#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    End-to-end rows for the parallel mutation rejection allow path of validate-orchestrator-output.ps1 (issue #1012).

.DESCRIPTION
    Each row runs Invoke-OrchestratorOutputValidation (or Get-OrchestratorOutputBlockDecision for the
    unchanged-decision rows) through the shipped resolver. The live-root and checkpoint-text seams are
    mocked both in module scope 'WorktreeRunResolution' and in script scope, as in
    validate-orchestrator-output.WorktreeResolution.Tests.ps1, so a parallel checkpoint can sit in a
    synthetic worktree. One script-tail row drives the hook through the & route with the envelope on
    stdin and restores stdin, stderr, CLAUDE_HOOK_INPUT, and the dependency-failure state in finally.
    One parity row reads the rule section `## Mutation Rejection Signal (issue #1012)` from
    .claude/rules/parallel-orchestration.md and compares its code set with the hook's array.

    The read seam Get-CheckpointFileContent is mocked in every row that reaches it, so no row creates
    or writes a file, uses a temporary path, reads a clock, starts a process, or touches the network.
    Synthetic roots use the /synthetic-worktrees/<name> form, and every comparison is ordinal.
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
    # The completion module re-imports OrchestratorState.psm1 internally, so the state
    # module is imported last to keep Get-OrchestratorStateCheckpoint mockable here.
    Import-Module (Join-Path $libRoot 'orchestrator-state/OrchestratorStateCompletion.psm1') -Force
    Import-Module (Join-Path $libRoot 'orchestrator-state/OrchestratorState.psm1') -Force
    Mock Get-OrchestratorStateCheckpoint -ModuleName OrchestratorState { $null }

    $script:Hook = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../.claude/hooks/validate-orchestrator-output.ps1'))
    $script:RulePath = Join-Path $PSScriptRoot '../../../.claude/rules/parallel-orchestration.md'
    $script:Session = (Get-Location).Path.Replace([string][char]92, '/')
    $script:ParallelLeaf = 'artifacts/orchestration/parallel-orchestrator-state.json'
    $script:RuleHeading = '## Mutation Rejection Signal (issue #1012)'
    $script:AllCodes = @('kickoff_artifact_missing', 'run_not_started', 'items_in_flight', 'unknown_item')

    # A run checkpoint text carrying the four required fields, the route, and its identity.
    function ConvertTo-OutputCheckpointText {
        param([string] $RouteId, [string] $Field, [string] $Value, [string] $Extra = '')
        return ('{"objective":"run ' + $RouteId + '","completed_steps":[],"next_step":"wave_1","last_updated":"2026-10-08T00-00","route_id":"' +
            $RouteId + '","' + $Field + '":"' + $Value + '"' + $Extra + '}')
    }

    function ConvertTo-OutputPayload {
        param([string] $Output, [bool] $StopHookActive = $false)
        return (@{ last_assistant_message = $Output; stop_hook_active = $StopHookActive } | ConvertTo-Json -Compress)
    }

    # Model the live worktrees for the shipped resolver and for the siblings' direct seam calls.
    function Set-OutputRunTopology {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
        param([string[]] $Live = @(), [hashtable] $Parallel = @{})
        $liveSet = $Live
        $textMap = @{}
        foreach ($root in $Parallel.Keys) { $textMap["$root/artifacts/orchestration/parallel-orchestrator-state.json"] = $Parallel[$root] }
        $liveMock = { return , [string[]] $liveSet }.GetNewClosure()
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

    function Invoke-RejectionValidation {
        param([string] $Output, [bool] $StopHookActive = $false, [string] $CheckpointPath = $script:ParallelLeaf, [scriptblock] $RoutingInvoker)
        $arguments = @{
            InputText      = (ConvertTo-OutputPayload -Output $Output -StopHookActive $StopHookActive)
            CheckpointPath = $CheckpointPath
            ArtifactType   = 'parallel-orchestrator-state'
            SessionRoot    = $script:Session
        }
        if ($PSBoundParameters.ContainsKey('RoutingInvoker')) { $arguments['RoutingInvoker'] = $RoutingInvoker }
        return (Invoke-OrchestratorOutputValidation @arguments)
    }

    function Invoke-HookTail {
        # Runs the hook entry tail with stdin, stderr, and CLAUDE_HOOK_INPUT replaced for one call; all are restored in finally.
        param([AllowEmptyString()] [string] $StdinText, [hashtable] $HookParameter = @{})
        $priorIn = [System.Console]::In
        $priorError = [System.Console]::Error
        $priorLegacy = $env:CLAUDE_HOOK_INPUT
        $errorWriter = [System.IO.StringWriter]::new()
        $thrown = $null
        $exitCode = $null
        try {
            [System.Console]::SetIn([System.IO.StringReader]::new($StdinText))
            [System.Console]::SetError($errorWriter)
            $env:CLAUDE_HOOK_INPUT = $null
            $global:LASTEXITCODE = 0
            try { $null = & $script:Hook @HookParameter } catch { $thrown = $_ }
            $exitCode = $LASTEXITCODE
        }
        finally {
            [System.Console]::SetIn($priorIn)
            [System.Console]::SetError($priorError)
            $env:CLAUDE_HOOK_INPUT = $priorLegacy
            $script:HookDependencyFailures = [System.Collections.Generic.List[object]]::new()
            $script:HookDependencyGuardLoadFailed = $false
        }
        return [pscustomobject]@{ Thrown = $thrown; ExitCode = $exitCode; Stderr = $errorWriter.ToString() }
    }

    function Get-NoTargetResolution {
        return [pscustomobject]@{ Resolved = $false; CheckpointPath = $null; WorktreeRoot = $null; Status = 'NoTarget'; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; Detail = 'synthetic' }
    }
}

Describe 'validate-orchestrator-output parallel mutation rejection' {

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    BeforeEach {
        Mock Get-OrchestratorStateCheckpoint { @{ Ok = $true; State = [pscustomobject]@{}; Error = '' } }
        Mock Test-OrchestratorStateCompletionReadiness { @{ ExitCode = 0; Output = '' } }
        Mock Get-OrchestratorStateEpicWaveBarrierError { @() }
    }

    Context 'AC-1 allow with no live parallel checkpoint' {

        It 'allows <Code> with stop_hook_active false' -ForEach @(
            @{ Code = 'kickoff_artifact_missing' }
            @{ Code = 'run_not_started' }
            @{ Code = 'items_in_flight' }
            @{ Code = 'unknown_item' }
        ) {
            # Arrange
            Set-OutputRunTopology -Live @($script:Session, '/synthetic-worktrees/w-par')
            Set-OutputCheckpointRead

            # Act
            $result = Invoke-RejectionValidation -Output "Stopped without writing state.`nPARALLEL_MUTATION_REJECTED: $Code"

            # Assert
            $result.Ok | Should -BeTrue -Because $result.Message
            Should -Invoke Get-CheckpointFileContent -Times 0 -Exactly
        }

        It 'allows <Code> with stop_hook_active true' -ForEach @(
            @{ Code = 'kickoff_artifact_missing' }
            @{ Code = 'run_not_started' }
            @{ Code = 'items_in_flight' }
            @{ Code = 'unknown_item' }
        ) {
            # Arrange
            Set-OutputRunTopology -Live @($script:Session, '/synthetic-worktrees/w-par')
            Set-OutputCheckpointRead

            # Act
            $result = Invoke-RejectionValidation -Output "Stopped without writing state.`nPARALLEL_MUTATION_REJECTED: $Code" -StopHookActive $true

            # Assert
            $result.Ok | Should -BeTrue -Because $result.Message
            Should -Invoke Get-CheckpointFileContent -Times 0 -Exactly
        }
    }

    Context 'AC-3 a resolved checkpoint validates fully' {

        It 'reads the resolved checkpoint and runs the routing seam despite the signal' {
            # Arrange
            $text = ConvertTo-OutputCheckpointText -RouteId 'parallel' -Field 'parallel_slug' -Value 'run-a'
            $path = "/synthetic-worktrees/w-par/$script:ParallelLeaf"
            Set-OutputRunTopology -Live @($script:Session, '/synthetic-worktrees/w-par') -Parallel @{ '/synthetic-worktrees/w-par' = $text }
            Set-OutputCheckpointRead -Map @{ $path = $text }
            $routingCalls = [System.Collections.Generic.List[string]]::new()
            $routingStub = { param($Path, $Type) $routingCalls.Add([string]$Path); [pscustomobject]@{ ExitCode = 0; Output = '' } }.GetNewClosure()

            # Act
            $result = Invoke-RejectionValidation -Output "parallel_slug: run-a`nPARALLEL_MUTATION_REJECTED: run_not_started" -RoutingInvoker $routingStub

            # Assert
            $result.Ok | Should -BeTrue -Because $result.Message
            Should -Invoke Get-CheckpointFileContent -Times 1 -Exactly -ParameterFilter { $Path -eq $path }
            $routingCalls.Count | Should -Be 1
            $routingCalls[0] | Should -BeExactly $path
        }

        It 'blocks a resolved checkpoint missing next_step despite the signal' {
            # Arrange
            $text = '{"objective":"run parallel","completed_steps":[],"last_updated":"2026-10-08T00-00","route_id":"parallel","parallel_slug":"run-a"}'
            $path = "/synthetic-worktrees/w-par/$script:ParallelLeaf"
            Set-OutputRunTopology -Live @($script:Session, '/synthetic-worktrees/w-par') -Parallel @{ '/synthetic-worktrees/w-par' = $text }
            Set-OutputCheckpointRead -Map @{ $path = $text }

            # Act
            $result = Invoke-RejectionValidation -Output "parallel_slug: run-a`nPARALLEL_MUTATION_REJECTED: run_not_started"

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message.Contains('missing required field') | Should -BeTrue -Because $result.Message
            Should -Invoke Get-CheckpointFileContent -Times 1 -Exactly -ParameterFilter { $Path -eq $path }
        }
    }

    Context 'AC-4 no signal and no checkpoint' {

        It 'blocks as NoTarget with the hint line when stop_hook_active is <Active>' -ForEach @(@{ Active = $false }, @{ Active = $true }) {
            # Arrange
            Set-OutputRunTopology -Live @($script:Session, '/synthetic-worktrees/w-par')
            Set-OutputCheckpointRead

            # Act
            $result = Invoke-RejectionValidation -Output 'Final summary.' -StopHookActive $Active

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message.StartsWith('ORCHESTRATOR_CHECKPOINT_UNRESOLVED: parallel-orchestrator-state: NoTarget', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Message
            $result.Message.Contains('PARALLEL_MUTATION_REJECTED: <code>') | Should -BeTrue -Because $result.Message
            $result.Message.Contains($script:RuleHeading) | Should -BeTrue -Because $result.Message
        }
    }

    Context 'AC-6 invalid code' {

        It 'blocks and lists the allowed codes when stop_hook_active is <Active>' -ForEach @(@{ Active = $false }, @{ Active = $true }) {
            # Arrange
            Set-OutputRunTopology -Live @($script:Session, '/synthetic-worktrees/w-par')
            Set-OutputCheckpointRead

            # Act
            $result = Invoke-RejectionValidation -Output "Stopped.`nPARALLEL_MUTATION_REJECTED: bogus_code" -StopHookActive $Active

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message.StartsWith('ORCHESTRATOR_CHECKPOINT_UNRESOLVED: parallel-orchestrator-state: NoTarget', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Message
            foreach ($code in $script:AllCodes) { $result.Message.Contains($code) | Should -BeTrue -Because "the allowed-code list names $code" }
        }
    }

    Context 'AC-7 Ambiguous and Rejected resolutions' {

        It 'blocks as Ambiguous when two live parallel runs record distinct slugs' {
            # Arrange
            Set-OutputRunTopology -Live @('/synthetic-worktrees/w-p1', '/synthetic-worktrees/w-p2') -Parallel @{
                '/synthetic-worktrees/w-p1' = (ConvertTo-OutputCheckpointText -RouteId 'parallel' -Field 'parallel_slug' -Value 'alpha')
                '/synthetic-worktrees/w-p2' = (ConvertTo-OutputCheckpointText -RouteId 'parallel' -Field 'parallel_slug' -Value 'beta')
            }
            Set-OutputCheckpointRead

            # Act
            $result = Invoke-RejectionValidation -Output "Stopped.`nPARALLEL_MUTATION_REJECTED: run_not_started"

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message.StartsWith('ORCHESTRATOR_CHECKPOINT_UNRESOLVED: parallel-orchestrator-state: Ambiguous', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Message
            Should -Invoke Get-CheckpointFileContent -Times 0 -Exactly
        }

        It 'blocks as Rejected for a non-canonical checkpoint leaf' {
            # Arrange
            $text = ConvertTo-OutputCheckpointText -RouteId 'parallel' -Field 'parallel_slug' -Value 'run-a'
            Set-OutputRunTopology -Live @($script:Session, '/synthetic-worktrees/w-par') -Parallel @{ '/synthetic-worktrees/w-par' = $text }
            Set-OutputCheckpointRead

            # Act
            $result = Invoke-RejectionValidation -Output "parallel_slug: run-a`nPARALLEL_MUTATION_REJECTED: run_not_started" -CheckpointPath 'artifacts/orchestration/other.json'

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message.StartsWith('ORCHESTRATOR_CHECKPOINT_UNRESOLVED: parallel-orchestrator-state: Rejected (CHECKPOINT_PATH_MISMATCH):', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Message
            Should -Invoke Get-CheckpointFileContent -Times 0 -Exactly
        }
    }

    Context 'AC-8 state-absence scan' {

        It 'blocks when a live root holds <Case>' -ForEach @(
            @{ Case = 'unparseable text'; Text = '{ not json' }
            @{ Case = 'a JSON array'; Text = '[{"route_id":"parallel","parallel_slug":"run-a"}]' }
            @{ Case = 'an off-route checkpoint'; Text = '{"objective":"run","completed_steps":[],"next_step":"x","last_updated":"2026-10-08T00-00","route_id":"epic","parallel_slug":"run-a"}' }
            @{ Case = 'a slugless parallel checkpoint'; Text = '{"objective":"run","completed_steps":[],"next_step":"x","last_updated":"2026-10-08T00-00","route_id":"parallel"}' }
        ) {
            # Arrange
            Set-OutputRunTopology -Live @($script:Session, '/synthetic-worktrees/w-par') -Parallel @{ '/synthetic-worktrees/w-par' = $Text }
            Set-OutputCheckpointRead

            # Act
            $result = Invoke-RejectionValidation -Output "parallel_slug: run-a`nPARALLEL_MUTATION_REJECTED: run_not_started"

            # Assert
            $result.Ok | Should -BeFalse -Because "$Case defeats the allow"
            $result.Message.StartsWith('ORCHESTRATOR_CHECKPOINT_UNRESOLVED: parallel-orchestrator-state: NoTarget', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Message
        }

        It 'blocks when the resolver reports NoTarget and a live root records the named slug' {
            # Arrange
            $text = ConvertTo-OutputCheckpointText -RouteId 'parallel' -Field 'parallel_slug' -Value 'run-a'
            Set-OutputRunTopology -Live @($script:Session, '/synthetic-worktrees/w-par') -Parallel @{ '/synthetic-worktrees/w-par' = $text }
            Set-OutputCheckpointRead
            Mock Resolve-OrchestratorOutputCheckpointPath { Get-NoTargetResolution }

            # Act
            $result = Invoke-RejectionValidation -Output "parallel_slug: run-a`nPARALLEL_MUTATION_REJECTED: run_not_started"

            # Assert
            $result.Ok | Should -BeFalse
            $result.Message.StartsWith('ORCHESTRATOR_CHECKPOINT_UNRESOLVED: parallel-orchestrator-state: NoTarget', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Message
        }

        It 'allows when the only live text is <Case>' -ForEach @(
            @{ Case = 'blank'; Text = "  `n " }
            @{ Case = 'a valid checkpoint recording run-b'; Text = '{"objective":"run parallel","completed_steps":[],"next_step":"wave_1","last_updated":"2026-10-08T00-00","route_id":"parallel","parallel_slug":"run-b"}' }
        ) {
            # Arrange
            Set-OutputRunTopology -Live @($script:Session, '/synthetic-worktrees/w-par') -Parallel @{ '/synthetic-worktrees/w-par' = $Text }
            Set-OutputCheckpointRead

            # Act
            $result = Invoke-RejectionValidation -Output "parallel_slug: run-a`nPARALLEL_MUTATION_REJECTED: run_not_started"

            # Assert
            $result.Ok | Should -BeTrue -Because $result.Message
            Should -Invoke Get-CheckpointFileContent -Times 0 -Exactly
        }
    }

    Context 'AC-9 other artifact types are unchanged' {

        It 'returns the same decision with and without the signal for <ArtifactType>' -ForEach @(
            @{ ArtifactType = 'orchestrator-state'; Leaf = 'artifacts/orchestration/orchestrator-state.json' }
            @{ ArtifactType = 'epic-orchestrator-state'; Leaf = 'artifacts/orchestration/epic-orchestrator-state.json' }
        ) {
            # Arrange
            Set-OutputRunTopology -Live @($script:Session)
            Set-OutputCheckpointRead
            Mock Resolve-OrchestratorOutputCheckpointPath { Get-NoTargetResolution }

            # Act
            $withSignal = Get-OrchestratorOutputBlockDecision -AgentOutput "Final summary.`nPARALLEL_MUTATION_REJECTED: run_not_started" -CheckpointPath $Leaf -ArtifactType $ArtifactType -SessionRoot $script:Session
            $withoutSignal = Get-OrchestratorOutputBlockDecision -AgentOutput 'Final summary.' -CheckpointPath $Leaf -ArtifactType $ArtifactType -SessionRoot $script:Session

            # Assert
            $withSignal.Ok | Should -Be $withoutSignal.Ok
            $withSignal.Ok | Should -BeFalse
            $withSignal.Repairable | Should -Be $withoutSignal.Repairable
            $withSignal.Message | Should -BeExactly $withoutSignal.Message
        }
    }

    Context 'AC-2 script tail' {

        It 'exits 0 for a valid signal with no live parallel checkpoint' {
            # Arrange
            Mock Import-Module { }
            Mock Resolve-OrchestratorOutputCheckpointPath { Get-NoTargetResolution }
            Mock Get-WorktreeItemLiveRoot { return , [string[]] @() }
            Mock Get-WorktreeRunCheckpointText { $null }
            $stdin = ConvertTo-OutputPayload -Output "Stopped without writing state.`nPARALLEL_MUTATION_REJECTED: kickoff_artifact_missing"

            # Act
            $result = Invoke-HookTail -StdinText $stdin -HookParameter @{ CheckpointPath = $script:ParallelLeaf; ArtifactType = 'parallel-orchestrator-state' }

            # Assert
            $result.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($result.Thrown))"
            $result.ExitCode | Should -Be 0 -Because $result.Stderr
            $result.Stderr | Should -BeNullOrEmpty
        }
    }

    Context 'AC-11 rule-to-hook parity' {

        It 'pins the hook code array to the rule section table' {
            # Arrange
            $lines = @((Get-Content -Raw -LiteralPath $script:RulePath) -split "`r?`n")
            $start = [System.Array]::IndexOf([string[]] $lines, $script:RuleHeading)
            $ruleCodes = [System.Collections.Generic.List[string]]::new()

            # Act
            if ($start -ge 0) {
                for ($index = $start + 1; $index -lt $lines.Count; $index++) {
                    if ($lines[$index].StartsWith('## ', [System.StringComparison]::Ordinal)) { break }
                    $match = [regex]::Match($lines[$index], '^\| `(?<code>[a-z_]+)` \|')
                    if ($match.Success) { $ruleCodes.Add($match.Groups['code'].Value) }
                }
            }

            # Assert
            $start | Should -BeGreaterOrEqual 0 -Because 'the rule file carries the rejection section heading'
            ($ruleCodes -join ',') | Should -BeExactly ($script:ParallelMutationRejectionCodes -join ',')
            $ruleCodes.Count | Should -Be 4
        }
    }
}
