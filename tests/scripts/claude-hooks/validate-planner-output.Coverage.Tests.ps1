#Requires -Version 7.0
<#
.SYNOPSIS
    Entry-point coverage for .claude/hooks/validate-planner-output.ps1 (issues #786 and #903).

.DESCRIPTION
    Runs the hook through the & route with the SubagentStop envelope supplied on stdin through
    [Console]::SetIn and stderr captured through [Console]::SetError; stdin, stderr,
    CLAUDE_HOOK_INPUT, and the dependency-failure state are restored in finally, so the
    dependency-decision tail lines and the exit-2 block execute in-process. Pure-entry rows call
    Invoke-PlannerOutputValidation with -InputText. No test creates, renames, moves, or deletes a file.
#>

BeforeAll {
    $hookPath = Join-Path $PSScriptRoot '../../../.claude/hooks/validate-planner-output.ps1'
    . $hookPath
    . (Join-Path $PSScriptRoot '../../../.claude/hooks/subagentstop-envelope.ps1')

    function Get-ValidPlannerReviewRecord {
        param([string] $Preflight = 'ALL CLEAR')

        @"
PLANNER-INTERNAL-REVIEW: PASS
CITATION-TO-TREE: PASS
CITATION: .claude/hooks/validate-planner-output.ps1 | planner review parser
AC-TRACEABILITY: PASS
AC-INVENTORY: AC1, AC2
AC-MAPPING: AC1 | IMPLEMENTATION: .claude/hooks/validate-planner-output.ps1 | TESTS: tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 | EVIDENCE: docs/features/active/foo/evidence/qa-gates/pester.md
AC-MAPPING: AC2 | IMPLEMENTATION: .claude/agents/atomic-planner.md | TESTS: tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py | EVIDENCE: docs/features/active/foo/evidence/qa-gates/contracts.md
SCOPE-BOUNDARY: PASS
UNRESOLVED-GAPS: NONE
PREFLIGHT: $Preflight
"@.Trim()
    }
}

Describe 'validate-planner-output entry point (issues #786 and #903)' {
    BeforeAll {
        $script:Hook = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../.claude/hooks/validate-planner-output.ps1'))
        $script:PlanPathText = 'plan-path: docs/features/active/foo/plan.md'
        $script:ValidText = "plan-path: docs/features/active/foo/plan.md`n$(Get-ValidPlannerReviewRecord)"
        # Issue #964: the allowed-plan fixture carries a valid Pre-Mortem section.
        $script:PreMortemFixture = @('## Pre-Mortem', '- Review checklists: walked.', '- Coverage: measured.', '- Mirror parity: copied.', '- File size: measured.', '- Test isolation: shuffled.', '- CI-only behavior: checked.', '- Evidence: recorded.', '## Phases')

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

        function Set-ValidPlanSeam {
            # Serves the plan lines of the structural-contract row in validate-planner-output.Tests.ps1.
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers a Pester mock for one test only; it changes no system state.')]
            param()
            $preMortem = $script:PreMortemFixture
            Mock -CommandName Get-PlanFileContent -MockWith {
                @{
                    Exists = $true
                    Lines  = @($preMortem) + @(
                        "### Phase 0 `u{2014} Baseline",
                        '- [ ] [P0-T1] Read AGENTS.md and .agents/skills/powershell/SKILL.md and record docs/features/active/foo/evidence/baseline/phase0-instructions-read.md',
                        '- [ ] [P0-T2] Capture baseline with pwsh tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 and write docs/features/active/foo/evidence/baseline/pester.md',
                        "### Phase 1 `u{2014} Implement",
                        '- [ ] [P1-T1] Update .claude/hooks/validate-planner-output.ps1 and tests/scripts/claude-hooks/validate-planner-output.Tests.ps1',
                        "### Phase 2 `u{2014} Final QA",
                        '- [ ] [P2-T1] Run pwsh tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 and write docs/features/active/foo/evidence/qa-gates/pester.md'
                    )
                }
            }.GetNewClosure()
        }
    }

    It 'E-PLN-1 blocks with exit 2 when last_assistant_message lacks the PREFLIGHT: signal' {
        # Arrange
        Mock Import-Module { }

        # Act
        $result = Invoke-HookTail -StdinText (ConvertTo-EnvelopeText -Text $script:PlanPathText)

        # Assert
        $result.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($result.Thrown))"
        $result.ExitCode | Should -Be 2
        $result.Stderr.Contains('agent output must include') | Should -BeTrue -Because $result.Stderr
    }

    It 'E-PLN-2 blocks with exit 2 when last_assistant_message lacks the plan-path line' {
        # Arrange
        Mock Import-Module { }

        # Act
        $result = Invoke-HookTail -StdinText (ConvertTo-EnvelopeText -Text 'PREFLIGHT: ALL CLEAR')

        # Assert
        $result.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($result.Thrown))"
        $result.ExitCode | Should -Be 2
        $result.Stderr.Contains('does not advertise a plan-path') | Should -BeTrue -Because $result.Stderr
    }

    It 'E-PLN-3 exits 0 when both are present with a contract-valid plan fixture' {
        # Arrange
        Mock Import-Module { }
        Set-ValidPlanSeam

        # Act
        $result = Invoke-HookTail -StdinText (ConvertTo-EnvelopeText -Text $script:ValidText)

        # Assert
        $result.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($result.Thrown))"
        $result.ExitCode | Should -Be 0
        $result.Stderr | Should -BeNullOrEmpty
    }

    It 'E-PLN-4 blocks with exit 2 when CLAUDE_HOOK_INPUT passes and stdin fails' {
        # Arrange
        Mock Import-Module { }
        Set-ValidPlanSeam

        # Act
        $result = Invoke-HookTail -StdinText (ConvertTo-EnvelopeText -Text $script:PlanPathText) -LegacyInput (ConvertTo-EnvelopeText -Key 'output' -Text $script:ValidText)

        # Assert
        $result.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($result.Thrown))"
        $result.ExitCode | Should -Be 2
        $result.Stderr.Contains('agent output must include') | Should -BeTrue -Because $result.Stderr
    }

    It 'E-PLN-5 blocks with exit 2 when the envelope carries only an output key' {
        # Arrange
        Mock Import-Module { }
        Set-ValidPlanSeam
        $clause = Get-SubagentStopEnvelopeAnomalyReason -Anomaly 'MissingAssistantMessage'

        # Act
        $result = Invoke-HookTail -StdinText (ConvertTo-EnvelopeText -Key 'output' -Text $script:ValidText)

        # Assert
        $result.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($result.Thrown))"
        $result.ExitCode | Should -Be 2
        $result.Stderr.StartsWith('atomic-planner hook: payload anomaly - ', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Stderr
        $result.Stderr.Contains($clause) | Should -BeTrue -Because $result.Stderr
    }

    It 'E-PLN-6 exits 2 naming subagentstop-envelope.ps1 when the helper fails to load, with stop_hook_active true' {
        # Arrange
        Mock Import-Module { }
        Mock Join-Path { throw 'simulated load failure: subagentstop-envelope.ps1' } -ParameterFilter { $ChildPath -eq 'subagentstop-envelope.ps1' }

        # Act
        $result = Invoke-HookTail -StdinText '{"last_assistant_message":"PREFLIGHT: ALL CLEAR","stop_hook_active":true}'

        # Assert
        $result.Thrown | Should -BeNullOrEmpty -Because "the hook must not throw ($($result.Thrown))"
        $result.ExitCode | Should -Be 2
        $result.Stderr.StartsWith('validate-planner-output:', [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Stderr
        $result.Stderr.Contains('subagentstop-envelope.ps1') | Should -BeTrue -Because $result.Stderr
    }

    It 'E-PLN-7 blocks <Anomaly> with the planner payload anomaly clause' -ForEach @(
        @{ Anomaly = 'EmptyPayload'; InputText = '' }
        @{ Anomaly = 'UnparseableJson'; InputText = '{ not json' }
        @{ Anomaly = 'NonObjectEnvelope'; InputText = '[]' }
        @{ Anomaly = 'MissingAssistantMessage'; InputText = '{"output":"Final summary."}' }
        @{ Anomaly = 'NullAssistantMessage'; InputText = '{"last_assistant_message":null}' }
        @{ Anomaly = 'NonStringAssistantMessage'; InputText = '{"last_assistant_message":42}' }
    ) {
        # Arrange
        $expected = 'atomic-planner hook: payload anomaly - ' + (Get-SubagentStopEnvelopeAnomalyReason -Anomaly $Anomaly)

        # Act
        $result = Invoke-PlannerOutputValidation -InputText $InputText

        # Assert
        $result.Ok | Should -BeFalse
        $result.Message.StartsWith($expected, [System.StringComparison]::Ordinal) | Should -BeTrue -Because $result.Message
    }
}
