#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Re-entry policy rows O-1 to O-15 for the validate-orchestrator-output.ps1 SubagentStop hook (issue #903).

.DESCRIPTION
    Each row calls Invoke-OrchestratorOutputValidation twice with -InputText: once with
    stop_hook_active absent and once with "stop_hook_active": true. A block-always row blocks both
    times; a block-once row blocks the first time with report-and-halt wording and allows the second.
    O-AST parses the hook and asserts that the pure entry reads StopHookActive from the
    Read-SubagentStopEnvelope result. No row creates, renames, moves, or deletes a file, reads a
    clock, or sleeps.
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Injected routing stubs mirror the production $Invoker scriptblock signature param($Path, $Type) for testing')]
param()

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

Describe 'validate-orchestrator-output.ps1 re-entry policy' {
    BeforeAll {
        $script:Hook = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../.claude/hooks/validate-orchestrator-output.ps1'))
        $script:ValidCheckpoint = '{"objective":"run","completed_steps":[],"next_step":"x","last_updated":"2026-10-11T00-00"}'
        $script:RoutingStub = { param($Path, $Type) [pscustomobject]@{ ExitCode = 0; Output = '' } }
        $content = $script:ValidCheckpoint
        Mock Resolve-OrchestratorOutputCheckpointPath { [pscustomobject]@{ Resolved = $true; CheckpointPath = '/synthetic-worktrees/e2/artifacts/orchestration/orchestrator-state.json'; WorktreeRoot = '/synthetic-worktrees/e2'; Status = 'SessionRoot'; ReasonCode = $null; Detail = 'synthetic' } }
        Mock Get-CheckpointFileContent { @{ Exists = $true; Content = $content } }.GetNewClosure()

        function ConvertTo-ReentryInputText {
            # Builds the envelope text for one call; -Active adds stop_hook_active true.
            param([AllowEmptyString()] [string] $Text, [switch] $Active)
            $envelope = [ordered]@{ last_assistant_message = $Text }
            if ($Active) { $envelope['stop_hook_active'] = $true }
            return ($envelope | ConvertTo-Json -Compress)
        }

        function Assert-ReentryRow {
            # Asserts the first call blocks with the token and the second call follows the row behavior.
            param($First, $Second, [string] $Token, [ValidateSet('BlockOnce', 'BlockAlways')] [string] $Behavior)
            $First.Ok | Should -BeFalse -Because 'the first stop must block'
            ([string]$First.Message).Contains($Token) | Should -BeTrue -Because $First.Message
            if ($Behavior -eq 'BlockOnce') {
                ([string]$First.Message).Contains('to the operator and halt.') | Should -BeTrue -Because $First.Message
                $Second.Ok | Should -BeTrue -Because ([string]$Second.Message)
            }
            else {
                $Second.Ok | Should -BeFalse -Because 'a repairable condition blocks on every stop'
                ([string]$Second.Message).Contains($Token) | Should -BeTrue -Because $Second.Message
            }
        }

        function Set-ReentryCheckpoint {
            # Serves one checkpoint read result for one row.
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers a Pester mock for one test only; it changes no system state.')]
            param([bool] $Exists = $true, [string] $Content)
            $exists = $Exists
            $text = $Content
            Mock Get-CheckpointFileContent { @{ Exists = $exists; Content = $text } }.GetNewClosure()
        }

        function Set-ReentryResolution {
            # Serves one unresolved resolution result for one row.
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers a Pester mock for one test only; it changes no system state.')]
            param([string] $Status, [string] $ReasonCode, [string] $Detail = 'synthetic')
            $resolution = [pscustomobject]@{ Resolved = $false; CheckpointPath = $null; WorktreeRoot = $null; Status = $Status; ReasonCode = $ReasonCode; Detail = $Detail }
            Mock Resolve-OrchestratorOutputCheckpointPath { $resolution }.GetNewClosure()
        }
    }

    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot', 'Get-WorktreeRunCheckpointText' }

    It 'O-1 invalid envelope blocks once' {
        $first = Invoke-OrchestratorOutputValidation -InputText '{}' -RoutingInvoker $script:RoutingStub
        $second = Invoke-OrchestratorOutputValidation -InputText '{"stop_hook_active":true}' -RoutingInvoker $script:RoutingStub
        Assert-ReentryRow -First $first -Second $second -Token 'payload anomaly' -Behavior BlockOnce
    }

    It 'O-2 empty assistant text blocks always' {
        $first = Invoke-OrchestratorOutputValidation -InputText (ConvertTo-ReentryInputText -Text '') -RoutingInvoker $script:RoutingStub
        $second = Invoke-OrchestratorOutputValidation -InputText (ConvertTo-ReentryInputText -Text '' -Active) -RoutingInvoker $script:RoutingStub
        Assert-ReentryRow -First $first -Second $second -Token 'agent output is empty' -Behavior BlockAlways
    }

    It 'O-3 unsupported artifact type blocks once' {
        Set-ReentryResolution -Status 'NoTarget' -ReasonCode 'TARGET_WORKTREE_NOT_DERIVABLE' -Detail "unsupported artifact type 'not-a-type'"
        $first = Invoke-OrchestratorOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'Final summary.') -ArtifactType 'not-a-type' -RoutingInvoker $script:RoutingStub
        $second = Invoke-OrchestratorOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'Final summary.' -Active) -ArtifactType 'not-a-type' -RoutingInvoker $script:RoutingStub
        Assert-ReentryRow -First $first -Second $second -Token 'ORCHESTRATOR_CHECKPOINT_UNRESOLVED:' -Behavior BlockOnce
    }

    It 'O-4 rejected checkpoint path blocks once' {
        Set-ReentryResolution -Status 'Rejected' -ReasonCode 'CHECKPOINT_PATH_MISMATCH'
        $first = Invoke-OrchestratorOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'Final summary.') -ArtifactType 'epic-orchestrator-state' -RoutingInvoker $script:RoutingStub
        $second = Invoke-OrchestratorOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'Final summary.' -Active) -ArtifactType 'epic-orchestrator-state' -RoutingInvoker $script:RoutingStub
        Assert-ReentryRow -First $first -Second $second -Token 'Rejected (CHECKPOINT_PATH_MISMATCH)' -Behavior BlockOnce
    }

    It 'O-5 epic target not derivable blocks always' {
        Set-ReentryResolution -Status 'NoTarget' -ReasonCode 'TARGET_WORKTREE_NOT_DERIVABLE'
        $first = Invoke-OrchestratorOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'Final summary.') -ArtifactType 'epic-orchestrator-state' -RoutingInvoker $script:RoutingStub
        $second = Invoke-OrchestratorOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'Final summary.' -Active) -ArtifactType 'epic-orchestrator-state' -RoutingInvoker $script:RoutingStub
        Assert-ReentryRow -First $first -Second $second -Token 'NoTarget (TARGET_WORKTREE_NOT_DERIVABLE)' -Behavior BlockAlways
    }

    It 'O-6 ambiguous standard target blocks once' {
        Set-ReentryResolution -Status 'Ambiguous' -ReasonCode 'TARGET_WORKTREE_AMBIGUOUS'
        $first = Invoke-OrchestratorOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'Final summary.') -RoutingInvoker $script:RoutingStub
        $second = Invoke-OrchestratorOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'Final summary.' -Active) -RoutingInvoker $script:RoutingStub
        Assert-ReentryRow -First $first -Second $second -Token 'Ambiguous (TARGET_WORKTREE_AMBIGUOUS)' -Behavior BlockOnce
    }

    It 'O-7 resolver exception blocks once' {
        Mock Resolve-OrchestratorOutputCheckpointPath { throw 'simulated resolver failure (CR-3)' }
        $first = Invoke-OrchestratorOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'Final summary.') -RoutingInvoker $script:RoutingStub
        $second = Invoke-OrchestratorOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'Final summary.' -Active) -RoutingInvoker $script:RoutingStub
        Assert-ReentryRow -First $first -Second $second -Token 'RESOLVER_FAILED' -Behavior BlockOnce
    }

    It 'O-8 missing checkpoint file blocks always' {
        Set-ReentryCheckpoint -Exists $false -Content $null
        $first = Invoke-OrchestratorOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'Final summary.') -RoutingInvoker $script:RoutingStub
        $second = Invoke-OrchestratorOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'Final summary.' -Active) -RoutingInvoker $script:RoutingStub
        Assert-ReentryRow -First $first -Second $second -Token 'does not exist' -Behavior BlockAlways
    }

    It 'O-9 checkpoint missing required fields blocks always' {
        Set-ReentryCheckpoint -Content '{"objective":"work"}'
        $first = Invoke-OrchestratorOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'Final summary.') -RoutingInvoker $script:RoutingStub
        $second = Invoke-OrchestratorOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'Final summary.' -Active) -RoutingInvoker $script:RoutingStub
        Assert-ReentryRow -First $first -Second $second -Token 'missing required field' -Behavior BlockAlways
    }

    It 'O-10 exception response without a runbook blocks always' {
        Set-ReentryCheckpoint -Content ($script:ValidCheckpoint.TrimEnd('}') + ',"human_interaction":{"requirements":[{"response":"exception"}]}}')
        $first = Invoke-OrchestratorOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'Final summary.') -RoutingInvoker $script:RoutingStub
        $second = Invoke-OrchestratorOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'Final summary.' -Active) -RoutingInvoker $script:RoutingStub
        Assert-ReentryRow -First $first -Second $second -Token 'runbook_path' -Behavior BlockAlways
    }

    It 'O-11 halt response blocks once' {
        Set-ReentryCheckpoint -Content ($script:ValidCheckpoint.TrimEnd('}') + ',"human_interaction":{"requirements":[{"response":"halt"}]}}')
        $first = Invoke-OrchestratorOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'Final summary.') -RoutingInvoker $script:RoutingStub
        $second = Invoke-OrchestratorOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'Final summary.' -Active) -RoutingInvoker $script:RoutingStub
        Assert-ReentryRow -First $first -Second $second -Token 'DONE is blocked while a halt is present' -Behavior BlockOnce
    }

    It 'O-12 model routing block blocks always' {
        $stub = { param($Path, $Type) [pscustomobject]@{ ExitCode = 1; Output = 'model_routing_receipts missing' } }
        $first = Invoke-OrchestratorOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'Final summary.') -RoutingInvoker $stub
        $second = Invoke-OrchestratorOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'Final summary.' -Active) -RoutingInvoker $stub
        Assert-ReentryRow -First $first -Second $second -Token 'MODEL_ROUTING_BLOCKED:' -Behavior BlockAlways
    }

    It 'O-13 routing contract block blocks always' {
        $stub = { param($Path, $Type) [pscustomobject]@{ ExitCode = 1; Output = 'x' } }
        $first = Invoke-OrchestratorOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'Final summary.') -RoutingInvoker $stub
        $second = Invoke-OrchestratorOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'Final summary.' -Active) -RoutingInvoker $stub
        Assert-ReentryRow -First $first -Second $second -Token 'ROUTING_CONTRACT_BLOCKED:' -Behavior BlockAlways
    }

    It 'O-14 wave-barrier violation blocks once' {
        Mock Get-OrchestratorStateEpicWaveBarrierError { 'EPIC_WAVE_BARRIER_VIOLATION: synthetic' }
        $first = Invoke-OrchestratorOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'Final summary.') -ArtifactType 'epic-orchestrator-state' -RoutingInvoker $script:RoutingStub
        $second = Invoke-OrchestratorOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'Final summary.' -Active) -ArtifactType 'epic-orchestrator-state' -RoutingInvoker $script:RoutingStub
        Assert-ReentryRow -First $first -Second $second -Token 'EPIC_WAVE_BARRIER_VIOLATION:' -Behavior BlockOnce
    }

    It 'O-15 unevaluable wave barrier blocks once' {
        Mock Get-OrchestratorStateEpicWaveBarrierError { throw 'simulated port failure' }
        $first = Invoke-OrchestratorOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'Final summary.') -ArtifactType 'epic-orchestrator-state' -RoutingInvoker $script:RoutingStub
        $second = Invoke-OrchestratorOutputValidation -InputText (ConvertTo-ReentryInputText -Text 'Final summary.' -Active) -ArtifactType 'epic-orchestrator-state' -RoutingInvoker $script:RoutingStub
        Assert-ReentryRow -First $first -Second $second -Token 'EPIC_WAVE_BARRIER_UNEVALUABLE:' -Behavior BlockOnce
    }

    It 'O-AST pure entry reads StopHookActive from the Read-SubagentStopEnvelope result' {
        # Arrange
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:Hook, [ref]$null, [ref]$null)
        $function = @($ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Invoke-OrchestratorOutputValidation' }, $true))[0]

        # Act
        $assignments = @($function.Body.FindAll({ param($node) $node -is [System.Management.Automation.Language.AssignmentStatementAst] -and @($node.Right.FindAll({ param($inner) $inner -is [System.Management.Automation.Language.CommandAst] -and $inner.GetCommandName() -eq 'Read-SubagentStopEnvelope' }, $true)).Count -gt 0 }, $true))
        $variableName = if ($assignments.Count -gt 0) { $assignments[0].Left.VariablePath.UserPath } else { $null }
        $reads = @($function.Body.FindAll({ param($node) $node -is [System.Management.Automation.Language.MemberExpressionAst] -and $node.Expression -is [System.Management.Automation.Language.VariableExpressionAst] -and $node.Expression.VariablePath.UserPath -eq $variableName -and $node.Member.Extent.Text -eq 'StopHookActive' }, $true))

        # Assert
        $assignments.Count | Should -BeGreaterThan 0 -Because 'the pure entry assigns the Read-SubagentStopEnvelope result'
        $reads.Count | Should -BeGreaterThan 0 -Because 'the re-entry decision reads StopHookActive from that result'
    }

    It 'O-STR a string "true" stop_hook_active does not release a block-once stop' {
        Set-ReentryCheckpoint -Content ($script:ValidCheckpoint.TrimEnd('}') + ',"human_interaction":{"requirements":[{"response":"halt"}]}}')
        $result = Invoke-OrchestratorOutputValidation -InputText '{"last_assistant_message":"Final summary.","stop_hook_active":"true"}' -RoutingInvoker $script:RoutingStub
        $result.Ok | Should -BeFalse
        ([string]$result.Message).Contains('DONE is blocked while a halt is present') | Should -BeTrue -Because $result.Message
    }
}
