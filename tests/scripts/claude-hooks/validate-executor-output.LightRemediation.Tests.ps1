#Requires -Version 7.0
<#
.SYNOPSIS
    The executor stop hook applied to a light remediation run (issue #1097).

.DESCRIPTION
    A light cycle delegates one atomic-executor run whose plan-path names the cycle's
    remediation-inputs file, which carries the canonical fix tasks under ## Light Fix Tasks and no
    other checkbox line. These rows prove that .claude/hooks/validate-executor-output.ps1, unchanged,
    completes, blocks, and permits a stop for that file. Transcript text is supplied in memory
    through the ReadTranscriptHead seam and the inputs file through a Pester mock of
    Get-PlanFileContent. No test creates, reads, or deletes a file.
#>

BeforeAll {
    . (Join-Path $PSScriptRoot '../../../.claude/hooks/validate-executor-output.ps1')
    . (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')
    Register-EpicStateBaselineMock -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot' -Surface 'Claude'

    function Get-TranscriptReader {
        # Returns a ReadTranscriptHead seam that serves one user entry with the given prompt text.
        param([string] $Prompt)
        $lines = [string[]]@(
            (@{ type = 'system'; content = 'session start' } | ConvertTo-Json -Compress -Depth 5),
            (@{ type = 'user'; message = @{ role = 'user'; content = $Prompt } } | ConvertTo-Json -Compress -Depth 5)
        )
        return { param([string] $Path) $null = $Path; $lines }.GetNewClosure()
    }

    function Set-InputsLine {
        # Serves the given inputs-file lines through Get-PlanFileContent for one test.
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers a Pester mock for one test only; it changes no system state.')]
        param([string[]] $Lines)
        $inputsLines = $Lines
        Mock -CommandName Get-PlanFileContent -MockWith { @{ Exists = $true; Lines = $inputsLines } }.GetNewClosure()
    }

    function Get-InputsLine {
        # Returns a light remediation-inputs file whose one fix task is ticked or not.
        [OutputType([string[]])]
        param([switch] $Ticked, [string[]] $Extra = @())
        $box = if ($Ticked) { 'x' } else { ' ' }
        return [string[]](@(
                '# Remediation Inputs',
                'Review-Verdict: REMEDIATION_REQUIRED',
                'Remediation-Mode: light',
                'Remediation-Path: light',
                '## Finding 1',
                'Remediability: autonomous',
                'Finding-Scope: contained',
                '## Light Fix Tasks',
                "- [$box] [P0-T1] Correct the header sentence in ``.claude/hooks/example-hook.ps1`` (finding 1)."
            ) + $Extra)
    }

    $script:PlanPath = 'plan-path: docs/features/active/foo/remediation-inputs.2026-11-07T10-00.md'
    $script:TranscriptPath = 'transcripts/subagents/agent-1.jsonl'
    $script:CompleteOutput = "$script:PlanPath`nCommands Run: Invoke-PoshQCParallelTest`nPowerShell toolchain: PASS`n### AC Status Summary`n- Total AC items: 0"
    $script:StopOutput = "$script:PlanPath`nBLOCKED at preflight (before [P0-T1])`nPlan delta: the fix needs a new file outside its named location."
}

Describe 'epic-state baseline isolation (issue #1105)' {
    It 'baseline mock interception probe' { Invoke-EpicStateInterceptionProbe -Surface 'Claude' -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot' }
}

Describe 'Get-ExecutorOutputBlockDecision for a light remediation run (issue #1097)' {
    BeforeEach {
        # A light run carries no preflight directive, so the transcript classifies it as execution.
        $script:LightReader = Get-TranscriptReader -Prompt 'Execute the light fix tasks of the remediation inputs file.'
    }

    It 'VEL-LIGHT-COMPLETE-RUN-ALLOWED' {
        # Arrange
        Set-InputsLine -Lines (Get-InputsLine -Ticked)

        # Act
        $decision = Get-ExecutorOutputBlockDecision -AgentOutput $script:CompleteOutput -TranscriptPath $script:TranscriptPath -ReadTranscriptHead $script:LightReader

        # Assert: no remediation-plan name is required.
        $decision.Ok | Should -BeTrue -Because $decision.Message
    }

    It 'VEL-LIGHT-UNTICKED-TASK-BLOCKED' {
        # Arrange
        Set-InputsLine -Lines (Get-InputsLine)

        # Act
        $decision = Get-ExecutorOutputBlockDecision -AgentOutput $script:CompleteOutput -TranscriptPath $script:TranscriptPath -ReadTranscriptHead $script:LightReader

        # Assert
        $decision.Ok | Should -BeFalse
        $decision.Repairable | Should -BeTrue
        $decision.Message | Should -Match 'unchecked task'
    }

    It 'VEL-LIGHT-STRAY-CHECKBOX-BLOCKED' {
        # Arrange: a checkbox line outside ## Light Fix Tasks counts as an unticked task.
        Set-InputsLine -Lines (Get-InputsLine -Ticked -Extra @('## Notes', '- [ ] Confirm the reviewer note.'))

        # Act
        $decision = Get-ExecutorOutputBlockDecision -AgentOutput $script:CompleteOutput -TranscriptPath $script:TranscriptPath -ReadTranscriptHead $script:LightReader

        # Assert
        $decision.Ok | Should -BeFalse
        $decision.Message | Should -Match 'unchecked task'
    }

    It 'VEL-LIGHT-FINDING-LANGUAGE-NEEDS-STATUS-LINE' {
        # Arrange: a finding names a Python file, and the output reports PowerShell only.
        Set-InputsLine -Lines (Get-InputsLine -Ticked -Extra @('Finding evidence: `scripts/dev_tools/example_module.py` lacks a docstring.'))

        # Act
        $decision = Get-ExecutorOutputBlockDecision -AgentOutput $script:CompleteOutput -TranscriptPath $script:TranscriptPath -ReadTranscriptHead $script:LightReader

        # Assert
        $decision.Ok | Should -BeFalse
        $decision.Repairable | Should -BeTrue
        $decision.Message | Should -Match 'Python'
    }

    It 'VEL-LIGHT-STOP-BEFORE-FIRST-TASK-ALLOWED' {
        # Arrange
        Set-InputsLine -Lines (Get-InputsLine)

        # Act
        $decision = Get-ExecutorOutputBlockDecision -AgentOutput $script:StopOutput -TranscriptPath $script:TranscriptPath -ReadTranscriptHead $script:LightReader

        # Assert: the stop that starts the design fallback is permitted.
        $decision.Ok | Should -BeTrue -Because $decision.Message
    }

    It 'VEL-LIGHT-STOP-WITHOUT-DELTA-BLOCKED' {
        # Arrange
        Set-InputsLine -Lines (Get-InputsLine)
        $output = "$script:PlanPath`nBLOCKED at preflight (before [P0-T1])`nThe fix cannot be made."

        # Act
        $decision = Get-ExecutorOutputBlockDecision -AgentOutput $output -TranscriptPath $script:TranscriptPath -ReadTranscriptHead $script:LightReader

        # Assert
        $decision.Ok | Should -BeFalse
        $decision.Message | Should -Match 'blocking is permitted only during preflight'
    }

    It 'VEL-LIGHT-STOP-AFTER-TICKED-TASK-BLOCKED-NON-REPAIRABLE' {
        # Arrange
        Set-InputsLine -Lines (Get-InputsLine -Ticked)

        # Act
        $decision = Get-ExecutorOutputBlockDecision -AgentOutput $script:StopOutput -TranscriptPath $script:TranscriptPath -ReadTranscriptHead $script:LightReader

        # Assert
        $decision.Ok | Should -BeFalse
        $decision.Repairable | Should -BeFalse
    }
}
