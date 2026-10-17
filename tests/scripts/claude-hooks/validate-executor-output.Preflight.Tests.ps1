#Requires -Version 7.0
<#
.SYNOPSIS
    Transcript-based preflight detection and single-pass preflight rules of
    .claude/hooks/validate-executor-output.ps1 (issue #964).

.DESCRIPTION
    Transcript text is supplied in memory through the ReadTranscriptHead seam, plan content through a
    Pester mock of Get-PlanFileContent, and fix-record existence through a mock of
    Test-PreflightFixRecord. No test creates, reads, or deletes a file.
#>

BeforeAll {
    . (Join-Path $PSScriptRoot '../../../.claude/hooks/validate-executor-output.ps1')

    function Get-TranscriptReader {
        # Returns a ReadTranscriptHead seam that serves one user entry with the given prompt text.
        param([string] $Prompt, [switch] $AsTextBlocks)
        $content = if ($AsTextBlocks) { @(@{ type = 'text'; text = $Prompt }) } else { $Prompt }
        $lines = [string[]]@(
            (@{ type = 'system'; content = 'session start' } | ConvertTo-Json -Compress -Depth 5),
            (@{ type = 'user'; message = @{ role = 'user'; content = $content } } | ConvertTo-Json -Compress -Depth 5)
        )
        return { param([string] $Path) $null = $Path; $lines }.GetNewClosure()
    }

    function Set-PlanLine {
        # Serves the given plan lines through Get-PlanFileContent for one test.
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Registers a Pester mock for one test only; it changes no system state.')]
        param([string[]] $Lines)
        $planLines = $Lines
        Mock -CommandName Get-PlanFileContent -MockWith { @{ Exists = $true; Lines = $planLines } }.GetNewClosure()
    }

    $script:Directive = 'DIRECTIVE: PREFLIGHT VALIDATION ONLY'
    $script:PlanPath = 'plan-path: docs/features/active/foo/plan.md'
    $script:TranscriptPath = 'transcripts/subagents/agent-1.jsonl'
    $script:UncheckedPlan = [string[]]@('### Phase 0 - Baseline', '- [ ] [P0-T1] Read policy for `docs/features/active/foo/spec.md`.')
    $script:CheckedPlan = [string[]]@('### Phase 0 - Baseline', '- [x] [P0-T1] Read policy for `docs/features/active/foo/spec.md`.', '- [ ] [P0-T2] Baseline.')
}

Describe 'Test-IsPreflightRun (issue #964)' {
    It 'classifies a run as preflight when the transcript prompt carries the directive' {
        # Arrange
        $reader = Get-TranscriptReader -Prompt "$script:Directive`n`nValidate the plan."

        # Act
        $result = Test-IsPreflightRun -AgentOutput 'no signal' -PlanLines $script:UncheckedPlan -TranscriptPath $script:TranscriptPath -ReadTranscriptHead $reader

        # Assert
        $result | Should -BeTrue
    }

    It 'reads the directive from text-block message content' {
        # Arrange
        $reader = Get-TranscriptReader -Prompt "$script:Directive`nPlan follows." -AsTextBlocks

        # Act
        $result = Test-IsPreflightRun -AgentOutput '' -PlanLines @() -TranscriptPath $script:TranscriptPath -ReadTranscriptHead $reader

        # Assert
        $result | Should -BeTrue
    }

    It 'classifies a run as execution when the transcript prompt lacks the directive, even with a plan directive' {
        # Arrange
        $reader = Get-TranscriptReader -Prompt 'Execute the approved plan.'
        $plan = [string[]]@($script:Directive) + $script:UncheckedPlan

        # Act
        $result = Test-IsPreflightRun -AgentOutput "PREFLIGHT: ALL CLEAR" -PlanLines $plan -TranscriptPath $script:TranscriptPath -ReadTranscriptHead $reader

        # Assert
        $result | Should -BeFalse
    }

    It 'falls back to the plan-file directive when no transcript path is supplied' {
        # Arrange
        $plan = [string[]]@($script:Directive) + $script:UncheckedPlan

        # Act
        $result = Test-IsPreflightRun -AgentOutput '' -PlanLines $plan -TranscriptPath $null

        # Assert
        $result | Should -BeTrue
    }

    It 'falls back when the transcript is unparseable' {
        # Arrange
        $reader = { param([string] $Path) $null = $Path; [string[]]@('not json', '{"type":"assistant"}') }

        # Act
        $withPlanDirective = Test-IsPreflightRun -AgentOutput '' -PlanLines ([string[]]@($script:Directive)) -TranscriptPath $script:TranscriptPath -ReadTranscriptHead $reader
        $withoutSignal = Test-IsPreflightRun -AgentOutput 'summary' -PlanLines $script:UncheckedPlan -TranscriptPath $script:TranscriptPath -ReadTranscriptHead $reader

        # Assert
        $withPlanDirective | Should -BeTrue
        $withoutSignal | Should -BeFalse
    }

    It 'falls back when the transcript reader throws or returns nothing' {
        # Arrange
        $throwing = { param([string] $Path) throw "unreadable $Path" }
        $empty = { param([string] $Path) $null = $Path; $null }

        # Act
        $afterThrow = Test-IsPreflightRun -AgentOutput 'PREFLIGHT: ALL CLEAR' -PlanLines $script:UncheckedPlan -TranscriptPath $script:TranscriptPath -ReadTranscriptHead $throwing
        $afterEmpty = Test-IsPreflightRun -AgentOutput 'summary' -PlanLines $script:UncheckedPlan -TranscriptPath $script:TranscriptPath -ReadTranscriptHead $empty

        # Assert
        $afterThrow | Should -BeTrue
        $afterEmpty | Should -BeFalse
    }

    It 'uses the single-signal fallback only for exactly one signal' {
        # Arrange / Act
        $one = Test-IsPreflightRun -AgentOutput "PREFLIGHT: REVISIONS REQUIRED" -PlanLines $script:UncheckedPlan
        $two = Test-IsPreflightRun -AgentOutput "PREFLIGHT: ALL CLEAR`nPREFLIGHT: ALL CLEAR" -PlanLines $script:UncheckedPlan

        # Assert
        $one | Should -BeTrue
        $two | Should -BeFalse
    }

    It 'returns $null from the default reader when the transcript file does not exist' {
        # Arrange
        Mock -CommandName Test-Path -MockWith { $false }

        # Act
        $result = Test-IsPreflightRun -AgentOutput 'summary' -PlanLines $script:UncheckedPlan -TranscriptPath $script:TranscriptPath

        # Assert
        $result | Should -BeFalse
        Should -Invoke -CommandName Test-Path -Times 1 -Exactly
    }
}

Describe 'Get-TranscriptPathFromEnvelope (issue #964)' {
    It 'returns the transcript path and expands a leading tilde' {
        # Arrange
        $envelope = '{"agent_transcript_path":"~/transcripts/agent-1.jsonl","last_assistant_message":"x"}' | ConvertFrom-Json

        # Act
        $path = Get-TranscriptPathFromEnvelope -Envelope $envelope

        # Assert
        $path | Should -Be ($HOME + '/transcripts/agent-1.jsonl')
    }

    It 'returns $null when the envelope carries no usable transcript path' {
        # Arrange
        $missing = '{"last_assistant_message":"x"}' | ConvertFrom-Json
        $blank = '{"agent_transcript_path":"  "}' | ConvertFrom-Json

        # Act / Assert
        Get-TranscriptPathFromEnvelope -Envelope $missing | Should -BeNullOrEmpty
        Get-TranscriptPathFromEnvelope -Envelope $blank | Should -BeNullOrEmpty
        Get-TranscriptPathFromEnvelope -Envelope $null | Should -BeNullOrEmpty
    }
}

Describe 'Get-ExecutorOutputBlockDecision single-pass preflight rules (issue #964)' {
    BeforeEach {
        $script:PreflightReader = Get-TranscriptReader -Prompt $script:Directive
        $script:ExecutionReader = Get-TranscriptReader -Prompt 'Execute the approved plan.'
        Set-PlanLine -Lines $script:UncheckedPlan
    }

    It 'enforces completion checks on an execution run whose plan carries a stale directive' {
        # Arrange
        Set-PlanLine -Lines ([string[]]@($script:Directive) + $script:UncheckedPlan)

        # Act
        $decision = Get-ExecutorOutputBlockDecision -AgentOutput "$script:PlanPath`nPREFLIGHT: ALL CLEAR" -TranscriptPath $script:TranscriptPath -ReadTranscriptHead $script:ExecutionReader

        # Assert
        $decision.Ok | Should -BeFalse
        $decision.Message | Should -Match 'unchecked task'
    }

    It 'blocks a preflight run with <Case> signal lines' -ForEach @(
        @{ Case = 'zero'; Output = 'Reviewed the plan.'; Pattern = 'must include' }
        @{ Case = 'two'; Output = "PREFLIGHT: ALL CLEAR`nPREFLIGHT: REVISIONS REQUIRED`nPREFLIGHT-DEFECT: [P1-T1] | ordering | move it"; Pattern = 'exactly one' }
    ) {
        # Arrange / Act
        $decision = Get-ExecutorOutputBlockDecision -AgentOutput "$script:PlanPath`n$Output" -TranscriptPath $script:TranscriptPath -ReadTranscriptHead $script:PreflightReader

        # Assert
        $decision.Ok | Should -BeFalse
        $decision.Repairable | Should -BeTrue
        $decision.Message | Should -Match $Pattern
    }

    It 'blocks ALL CLEAR that carries a PREFLIGHT-DEFECT line' {
        # Arrange
        $output = "$script:PlanPath`nPREFLIGHT: ALL CLEAR`nCONVERGENCE: NO FURTHER ROUNDS EXPECTED`nPREFLIGHT-DEFECT: [P1-T2] | missing task | add the test task"

        # Act
        $decision = Get-ExecutorOutputBlockDecision -AgentOutput $output -TranscriptPath $script:TranscriptPath -ReadTranscriptHead $script:PreflightReader

        # Assert
        $decision.Ok | Should -BeFalse
        $decision.Repairable | Should -BeTrue
        $decision.Message | Should -Match 'must not carry a `PREFLIGHT-DEFECT:` line'
    }

    It 'blocks REVISIONS REQUIRED without a PREFLIGHT-DEFECT line' {
        # Arrange / Act
        $decision = Get-ExecutorOutputBlockDecision -AgentOutput "$script:PlanPath`nPREFLIGHT: REVISIONS REQUIRED" -TranscriptPath $script:TranscriptPath -ReadTranscriptHead $script:PreflightReader

        # Assert
        $decision.Ok | Should -BeFalse
        $decision.Repairable | Should -BeTrue
        $decision.Message | Should -Match 'every substantive defect'
    }

    It 'allows REVISIONS REQUIRED that lists its defects' {
        # Arrange
        $output = "$script:PlanPath`nPREFLIGHT: REVISIONS REQUIRED`nPREFLIGHT-DEFECT: [P1-T2] | missing task | add the test task"

        # Act
        $decision = Get-ExecutorOutputBlockDecision -AgentOutput $output -TranscriptPath $script:TranscriptPath -ReadTranscriptHead $script:PreflightReader

        # Assert
        $decision.Ok | Should -BeTrue
    }

    It 'blocks a PREFLIGHT-FIX line whose record <Case>' -ForEach @(
        @{ Case = 'is not named'; Record = '' }
        @{ Case = 'is outside docs/features/'; Record = "`npreflight-fix-record: artifacts/preflight-fixes.md" }
        @{ Case = 'does not exist'; Record = "`npreflight-fix-record: docs/features/active/foo/evidence/other/preflight-fixes.2026-10-16T23-07.md" }
    ) {
        # Arrange
        Mock -CommandName Test-PreflightFixRecord -MockWith { $false }
        $output = "$script:PlanPath`nPREFLIGHT: ALL CLEAR`nPREFLIGHT-FIX: [P0-T1] | stale anchor | renamed the heading$Record"

        # Act
        $decision = Get-ExecutorOutputBlockDecision -AgentOutput $output -TranscriptPath $script:TranscriptPath -ReadTranscriptHead $script:PreflightReader

        # Assert
        $decision.Ok | Should -BeFalse
        $decision.Repairable | Should -BeTrue
        $decision.Message | Should -Match 'preflight-fix-record'
    }

    It 'allows a PREFLIGHT-FIX line whose record exists under docs/features/' {
        # Arrange
        Mock -CommandName Test-PreflightFixRecord -MockWith { $true }
        $output = "$script:PlanPath`nPREFLIGHT: ALL CLEAR`nPREFLIGHT-FIX: [P0-T1] | stale anchor | renamed the heading`npreflight-fix-record: ``docs/features/active/foo/evidence/other/preflight-fixes.2026-10-16T23-07.md``"

        # Act
        $decision = Get-ExecutorOutputBlockDecision -AgentOutput $output -TranscriptPath $script:TranscriptPath -ReadTranscriptHead $script:PreflightReader

        # Assert
        $decision.Ok | Should -BeTrue
        Should -Invoke -CommandName Test-PreflightFixRecord -Times 1 -Exactly -ParameterFilter { $Path -eq 'docs/features/active/foo/evidence/other/preflight-fixes.2026-10-16T23-07.md' }
    }

    It 'allows a canonical preflight BLOCKED report in a preflight run' {
        # Arrange
        $output = "$script:PlanPath`nBLOCKED at preflight (before [P0-T1])`nPlan delta: add [P1-T3]."

        # Act
        $decision = Get-ExecutorOutputBlockDecision -AgentOutput $output -TranscriptPath $script:TranscriptPath -ReadTranscriptHead $script:PreflightReader

        # Assert
        $decision.Ok | Should -BeTrue
    }

    It 'allows a combined-run preflight block when no task is checked' {
        # Arrange
        $output = "$script:PlanPath`nBLOCKED at preflight (before [P0-T1])`nPlan delta: add [P1-T3].`nPREFLIGHT-DEFECT: [P1-T3] | missing task | add it"

        # Act
        $decision = Get-ExecutorOutputBlockDecision -AgentOutput $output -TranscriptPath $script:TranscriptPath -ReadTranscriptHead $script:ExecutionReader

        # Assert
        $decision.Ok | Should -BeTrue
    }

    It 'blocks a combined-run preflight block non-repairably once a task is checked' {
        # Arrange
        Set-PlanLine -Lines $script:CheckedPlan
        $output = "$script:PlanPath`nBLOCKED at preflight (before [P0-T1])`nPlan delta: add [P1-T3]."

        # Act
        $decision = Get-ExecutorOutputBlockDecision -AgentOutput $output -TranscriptPath $script:TranscriptPath -ReadTranscriptHead $script:ExecutionReader

        # Assert
        $decision.Ok | Should -BeFalse
        $decision.Repairable | Should -BeFalse
    }

    It 'blocks any other execution-run BLOCKED claim non-repairably' {
        # Arrange / Act
        $decision = Get-ExecutorOutputBlockDecision -AgentOutput "$script:PlanPath`nBLOCKED: the toolchain is unavailable." -TranscriptPath $script:TranscriptPath -ReadTranscriptHead $script:ExecutionReader

        # Assert
        $decision.Ok | Should -BeFalse
        $decision.Repairable | Should -BeFalse
        $decision.Message | Should -Match 'blocking is permitted only during preflight'
    }

    It 'does not treat lowercase blocked prose as a BLOCKED claim' {
        # Arrange
        $output = "$script:PlanPath`nPREFLIGHT: ALL CLEAR`nThe orchestrator records blocked_reason only on a second substantive result."

        # Act
        $decision = Get-ExecutorOutputBlockDecision -AgentOutput $output -TranscriptPath $script:TranscriptPath -ReadTranscriptHead $script:PreflightReader

        # Assert
        $decision.Ok | Should -BeTrue
    }
}

Describe 'Invoke-ExecutorOutputValidation transcript wiring (issue #964)' {
    It 'passes the envelope transcript path to the block decision' {
        # Arrange
        Mock -CommandName Get-ExecutorOutputBlockDecision -MockWith { @{ Ok = $true; Message = $null } }
        $inputText = '{"agent_transcript_path":"transcripts/subagents/agent-1.jsonl","last_assistant_message":"plan-path: docs/features/active/foo/plan.md"}'

        # Act
        $result = Invoke-ExecutorOutputValidation -InputText $inputText

        # Assert
        $result.Ok | Should -BeTrue
        Should -Invoke -CommandName Get-ExecutorOutputBlockDecision -Times 1 -Exactly -ParameterFilter { $TranscriptPath -eq 'transcripts/subagents/agent-1.jsonl' }
    }
}
