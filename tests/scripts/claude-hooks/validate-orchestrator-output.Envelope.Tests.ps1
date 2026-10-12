#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Envelope rows for the validate-orchestrator-output.ps1 SubagentStop hook (issue #903, epic #904).

.DESCRIPTION
    Entry-tail rows drive the hook through the & route with the SubagentStop envelope supplied on
    stdin through [Console]::SetIn and stderr captured through [Console]::SetError; both are restored
    in finally, together with CLAUDE_HOOK_INPUT and the dependency-failure state. Pure-entry rows call
    Invoke-OrchestratorOutputValidation with -InputText. No row creates, renames, moves, or deletes a
    file, reads a clock, or sleeps.
#>

BeforeAll {
    $hookPath = Join-Path $PSScriptRoot '../../../.claude/hooks/validate-orchestrator-output.ps1'
    . $hookPath
    . (Join-Path $PSScriptRoot '../../../.claude/hooks/subagentstop-envelope.ps1')
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/orchestrator-state/OrchestratorState.psm1')).Path -ErrorAction Stop
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeItemResolution.psm1')).Path -ErrorAction Stop
    Import-Module (Resolve-Path (Join-Path $PSScriptRoot '../../../.claude/lib/worktree-resolution/WorktreeRunResolution.psm1')).Path -ErrorAction Stop
    Mock Get-CheckpointFileContent { $null }
    Mock Get-OrchestratorStateCheckpoint -ModuleName OrchestratorState { $null }
    Mock Get-WorktreeItemCheckpointText -ModuleName WorktreeItemResolution { $null }
    Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution { $null }
    Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }
}

Describe 'validate-orchestrator-output.ps1 SubagentStop envelope' {
    BeforeAll {
        $script:Hook = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../.claude/hooks/validate-orchestrator-output.ps1'))
        $script:EmptyMessageStdin = '{"hook_event_name":"SubagentStop","last_assistant_message":""}'
        $script:SummaryStdin = '{"last_assistant_message":"Final summary."}'
        $script:ValidCheckpoint = '{"objective":"run","completed_steps":[],"next_step":"x","last_updated":"2026-10-11T00-00"}'

        function Invoke-HookTail {
            # Runs the hook entry tail with stdin, stderr, and CLAUDE_HOOK_INPUT replaced for one call; all are restored in finally.
            param(
                [AllowEmptyString()] [string] $StdinText,
                [AllowNull()] [string] $LegacyInput,
                [hashtable] $HookParameter = @{}
            )
            $priorIn = [System.Console]::In
            $priorError = [System.Console]::Error
            $priorLegacy = $env:CLAUDE_HOOK_INPUT
            $errorWriter = [System.IO.StringWriter]::new()
            $thrown = $null
            $exitCode = $null
            try {
                [System.Console]::SetIn([System.IO.StringReader]::new($StdinText))
                [System.Console]::SetError($errorWriter)
                $env:CLAUDE_HOOK_INPUT = $LegacyInput
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

        function Set-ValidCheckpointSeam {
            # Registers the resolved target, the in-memory checkpoint read, and a passing routing dispatch for one row.
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers Pester mocks for one test only; it changes no system state.')]
            param()
            $content = $script:ValidCheckpoint
            Mock Resolve-OrchestratorOutputCheckpointPath { [pscustomobject]@{ Resolved = $true; CheckpointPath = '/synthetic-worktrees/e2/artifacts/orchestration/orchestrator-state.json'; WorktreeRoot = '/synthetic-worktrees/e2'; Status = 'SessionRoot'; ReasonCode = $null; Detail = 'synthetic' } }
            Mock Get-CheckpointFileContent { @{ Exists = $true; Content = $content } }.GetNewClosure()
            Mock Invoke-RoutingContractValidation { @{ HasErrors = $false; ErrorText = '' } }
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'E-ORC-1 blocks with exit 2 when last_assistant_message is empty' {
        # Arrange
        Mock Import-Module { }
        Set-ValidCheckpointSeam

        # Act
        $result = Invoke-HookTail -StdinText $script:EmptyMessageStdin

        # Assert
        $result.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($result.Thrown))"
        $result.ExitCode | Should -Be 2
        $result.Stderr.Contains('agent output is empty') | Should -BeTrue -Because $result.Stderr
    }

    It 'E-ORC-2 blocks with exit 2 when the checkpoint cannot be resolved' {
        # Arrange
        Mock Import-Module { }
        Mock Resolve-OrchestratorOutputCheckpointPath { [pscustomobject]@{ Resolved = $false; CheckpointPath = $null; WorktreeRoot = $null; Status = 'NoTarget'; ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'; Detail = 'synthetic' } }

        # Act
        $result = Invoke-HookTail -StdinText $script:SummaryStdin

        # Assert
        $result.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($result.Thrown))"
        $result.ExitCode | Should -Be 2
        $result.Stderr.StartsWith('ORCHESTRATOR_CHECKPOINT_UNRESOLVED:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Stderr
    }

    It 'E-ORC-3 exits 0 for a completion summary and a valid checkpoint fixture' {
        # Arrange
        Mock Import-Module { }
        Set-ValidCheckpointSeam

        # Act
        $result = Invoke-HookTail -StdinText $script:SummaryStdin

        # Assert
        $result.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($result.Thrown))"
        $result.ExitCode | Should -Be 0
        $result.Stderr | Should -BeNullOrEmpty
    }

    It 'E-ORC-4 blocks with exit 2 when CLAUDE_HOOK_INPUT passes and stdin fails' {
        # Arrange
        Mock Import-Module { }
        Set-ValidCheckpointSeam

        # Act
        $result = Invoke-HookTail -StdinText $script:EmptyMessageStdin -LegacyInput '{"output":"Final summary."}'

        # Assert
        $result.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($result.Thrown))"
        $result.ExitCode | Should -Be 2
        $result.Stderr.Contains('agent output is empty') | Should -BeTrue -Because $result.Stderr
    }

    It 'E-ORC-5 blocks with exit 2 when the envelope carries only an output key' {
        # Arrange
        Mock Import-Module { }
        Set-ValidCheckpointSeam
        $clause = Get-SubagentStopEnvelopeAnomalyReason -Anomaly 'MissingAssistantMessage'

        # Act
        $result = Invoke-HookTail -StdinText '{"output":"Final summary."}'

        # Assert
        $result.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($result.Thrown))"
        $result.ExitCode | Should -Be 2
        $result.Stderr.StartsWith('orchestrator hook: payload anomaly - ', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Stderr
        $result.Stderr.Contains($clause) | Should -BeTrue -Because $result.Stderr
    }

    It 'E-ORC-6 exits 2 with ORCHESTRATOR_CHECKPOINT_UNRESOLVED: when the resolver throws' {
        # Arrange
        Mock Import-Module { }
        Mock Resolve-OrchestratorOutputCheckpointPath { throw 'simulated resolver failure (CR-3)' }

        # Act
        $result = Invoke-HookTail -StdinText $script:SummaryStdin

        # Assert
        $result.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($result.Thrown))"
        $result.ExitCode | Should -Be 2
        $result.Stderr.StartsWith('ORCHESTRATOR_CHECKPOINT_UNRESOLVED:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Stderr
        $result.Stderr.Contains('RESOLVER_FAILED') | Should -BeTrue -Because $result.Stderr
    }

    It 'E-ORC-7 exits 2 naming subagentstop-envelope.ps1 when the helper fails to load, with stop_hook_active true' {
        # Arrange
        Mock Import-Module { }
        Mock Join-Path { throw 'simulated load failure: subagentstop-envelope.ps1' } -ParameterFilter { $ChildPath -eq 'subagentstop-envelope.ps1' }

        # Act
        $result = Invoke-HookTail -StdinText '{"last_assistant_message":"Final summary.","stop_hook_active":true}'

        # Assert
        $result.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($result.Thrown))"
        $result.ExitCode | Should -Be 2
        $result.Stderr.StartsWith('ORCHESTRATOR_CHECKPOINT_UNRESOLVED:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Stderr
        $result.Stderr.Contains('subagentstop-envelope.ps1') | Should -BeTrue -Because $result.Stderr
    }

    It 'E-ORC-8 blocks <Anomaly> with the orchestrator payload anomaly clause' -ForEach @(
        @{ Anomaly = 'EmptyPayload'; InputText = '' }
        @{ Anomaly = 'UnparseableJson'; InputText = '{ not json' }
        @{ Anomaly = 'NonObjectEnvelope'; InputText = '[]' }
        @{ Anomaly = 'MissingAssistantMessage'; InputText = '{"output":"Final summary."}' }
        @{ Anomaly = 'NullAssistantMessage'; InputText = '{"last_assistant_message":null}' }
        @{ Anomaly = 'NonStringAssistantMessage'; InputText = '{"last_assistant_message":42}' }
    ) {
        # Arrange
        $expected = 'orchestrator hook: payload anomaly - ' + (Get-SubagentStopEnvelopeAnomalyReason -Anomaly $Anomaly)

        # Act
        $result = Invoke-OrchestratorOutputValidation -InputText $InputText

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message.StartsWith($expected, [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Message
    }
}
