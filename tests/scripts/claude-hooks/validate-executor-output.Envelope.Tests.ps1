#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Envelope rows for the validate-executor-output.ps1 SubagentStop hook (issue #903, epic #904).

.DESCRIPTION
    Entry-tail rows drive the hook through the & route with the SubagentStop envelope supplied on
    stdin through [Console]::SetIn and stderr captured through [Console]::SetError; both are restored
    in finally, together with CLAUDE_HOOK_INPUT and the dependency-failure state. Pure-entry rows call
    Invoke-ExecutorOutputValidation with -InputText. No row creates, renames, moves, or deletes a
    file, reads a clock, or sleeps.
#>

BeforeAll {
    $hookPath = Join-Path $PSScriptRoot '../../../.claude/hooks/validate-executor-output.ps1'
    . $hookPath
    . (Join-Path $PSScriptRoot '../../../.claude/hooks/subagentstop-envelope.ps1')
}

Describe 'validate-executor-output.ps1 SubagentStop envelope' {
    BeforeAll {
        $script:Hook = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../.claude/hooks/validate-executor-output.ps1'))
        $script:MissingPlanText = 'Done. All phases complete.'
        $script:PassingText = "plan-path: docs/features/active/foo/plan.md`nAC Status Summary`nCommands Run: pwsh tests/foo.Tests.ps1`nPowerShell: PASS"

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

        function ConvertTo-EnvelopeText {
            # Builds a compressed SubagentStop envelope with the given key and text.
            param([string] $Key = 'last_assistant_message', [AllowEmptyString()] [string] $Text)
            return ([ordered]@{ $Key = $Text } | ConvertTo-Json -Compress)
        }

        function Set-CheckedPlanSeam {
            # Serves a plan whose single task is checked and names a PowerShell file.
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers a Pester mock for one test only; it changes no system state.')]
            param()
            Mock Get-PlanFileContent { @{ Exists = $true; Lines = @('### Phase 0 - Baseline', '- [x] [P0-T1] Update scripts/powershell/Foo.ps1') } }
        }
    }

    It 'E-EXE-1 blocks with exit 2 when last_assistant_message lacks a plan-path line' {
        # Arrange
        Mock Import-Module { }

        # Act
        $result = Invoke-HookTail -StdinText (ConvertTo-EnvelopeText -Text $script:MissingPlanText)

        # Assert
        $result.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($result.Thrown))"
        $result.ExitCode | Should -Be 2
        $result.Stderr.Contains('does not advertise a plan-path') | Should -BeTrue -Because $result.Stderr
    }

    It 'E-EXE-2 exits 0 when the advertised plan satisfies the executor checks' {
        # Arrange
        Mock Import-Module { }
        Set-CheckedPlanSeam

        # Act
        $result = Invoke-HookTail -StdinText (ConvertTo-EnvelopeText -Text $script:PassingText)

        # Assert
        $result.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($result.Thrown))"
        $result.ExitCode | Should -Be 0
        $result.Stderr | Should -BeNullOrEmpty
    }

    It 'E-EXE-3 blocks with exit 2 when CLAUDE_HOOK_INPUT passes and stdin fails' {
        # Arrange
        Mock Import-Module { }
        Set-CheckedPlanSeam

        # Act
        $result = Invoke-HookTail -StdinText (ConvertTo-EnvelopeText -Text $script:MissingPlanText) -LegacyInput (ConvertTo-EnvelopeText -Key 'output' -Text $script:PassingText)

        # Assert
        $result.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($result.Thrown))"
        $result.ExitCode | Should -Be 2
        $result.Stderr.Contains('does not advertise a plan-path') | Should -BeTrue -Because $result.Stderr
    }

    It 'E-EXE-4 blocks with exit 2 when the envelope carries only an output key' {
        # Arrange
        Mock Import-Module { }
        Set-CheckedPlanSeam
        $clause = Get-SubagentStopEnvelopeAnomalyReason -Anomaly 'MissingAssistantMessage'

        # Act
        $result = Invoke-HookTail -StdinText (ConvertTo-EnvelopeText -Key 'output' -Text $script:PassingText)

        # Assert
        $result.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($result.Thrown))"
        $result.ExitCode | Should -Be 2
        $result.Stderr.StartsWith('atomic-executor hook: payload anomaly - ', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Stderr
        $result.Stderr.Contains($clause) | Should -BeTrue -Because $result.Stderr
    }

    It 'E-EXE-5 exits 2 naming subagentstop-envelope.ps1 when the helper fails to load, with stop_hook_active true' {
        # Arrange
        Mock Import-Module { }
        Mock Join-Path { throw 'simulated load failure: subagentstop-envelope.ps1' } -ParameterFilter { $ChildPath -eq 'subagentstop-envelope.ps1' }

        # Act
        $result = Invoke-HookTail -StdinText '{"last_assistant_message":"Done.","stop_hook_active":true}'

        # Assert
        $result.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($result.Thrown))"
        $result.ExitCode | Should -Be 2
        $result.Stderr.StartsWith('validate-executor-output:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Stderr
        $result.Stderr.Contains('subagentstop-envelope.ps1') | Should -BeTrue -Because $result.Stderr
    }

    It 'E-EXE-6 exits 2 when hook-dependency-guard.ps1 fails to load' {
        # Arrange
        Mock Import-Module { }
        Mock Join-Path { throw 'simulated load failure: hook-dependency-guard.ps1' } -ParameterFilter { $ChildPath -eq 'hook-dependency-guard.ps1' }

        # Act
        $result = Invoke-HookTail -StdinText '{"last_assistant_message":"Done."}'

        # Assert
        $result.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($result.Thrown))"
        $result.ExitCode | Should -Be 2
        $result.Stderr.StartsWith('validate-executor-output: hook-dependency-guard.ps1 failed to load', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Stderr
    }

    It 'E-EXE-7 blocks <Anomaly> with the executor payload anomaly clause' -ForEach @(
        @{ Anomaly = 'EmptyPayload'; InputText = '' }
        @{ Anomaly = 'UnparseableJson'; InputText = '{ not json' }
        @{ Anomaly = 'NonObjectEnvelope'; InputText = '[]' }
        @{ Anomaly = 'MissingAssistantMessage'; InputText = '{"output":"Final summary."}' }
        @{ Anomaly = 'NullAssistantMessage'; InputText = '{"last_assistant_message":null}' }
        @{ Anomaly = 'NonStringAssistantMessage'; InputText = '{"last_assistant_message":42}' }
    ) {
        # Arrange
        $expected = 'atomic-executor hook: payload anomaly - ' + (Get-SubagentStopEnvelopeAnomalyReason -Anomaly $Anomaly)

        # Act
        $result = Invoke-ExecutorOutputValidation -InputText $InputText

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message.StartsWith($expected, [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Message
    }
}
