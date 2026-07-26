#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
    Unit coverage for .codex/hooks/enforce-evidence-locations.ps1 and
    .codex/hooks/enforce-checkpoint-monotonic.ps1 (issue #415 remediation cycle 1, R1).

    Both hooks are dot-sourced in-process so their policy functions and guarded
    entrypoints are attributed to the on-disk source files. No temporary file is
    created: entrypoint cases redirect stdin with
    [System.Console]::SetIn([System.IO.StringReader]::new(...)) and restore the
    original console readers and writers in finally.
#>

Describe 'Codex evidence-location and checkpoint-order PreToolUse hooks' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:HookRoot = Join-Path $script:RepoRoot '.codex/hooks'
        $script:EvidenceHookPath = Join-Path $script:HookRoot 'enforce-evidence-locations.ps1'
        $script:CheckpointHookPath = Join-Path $script:HookRoot 'enforce-checkpoint-monotonic.ps1'
        $script:CheckpointPath = 'artifacts/orchestration/orchestrator-state.json'

        . $script:EvidenceHookPath
        . $script:CheckpointHookPath

        function ConvertTo-CodexGatePayload {
            param(
                [Parameter(Mandatory)][string] $ToolName,
                [Parameter(Mandatory)][hashtable] $ToolInput
            )

            return [ordered]@{
                session_id      = 'gate-hook-coverage'
                hook_event_name = 'PreToolUse'
                tool_name       = $ToolName
                tool_input      = $ToolInput
            } | ConvertTo-Json -Compress -Depth 30
        }

        function Invoke-CodexGateEntrypoint {
            param(
                [Parameter(Mandatory)][string] $HookPath,
                [Parameter(Mandatory)][AllowEmptyString()][string] $PayloadRaw
            )

            $originalIn = [System.Console]::In
            $originalOut = [System.Console]::Out
            $originalError = [System.Console]::Error
            $outWriter = [System.IO.StringWriter]::new()
            $errorWriter = [System.IO.StringWriter]::new()
            try {
                [System.Console]::SetIn([System.IO.StringReader]::new($PayloadRaw))
                [System.Console]::SetOut($outWriter)
                [System.Console]::SetError($errorWriter)
                $pipelineOut = & $HookPath
                return [pscustomobject]@{
                    ExitCode = $LASTEXITCODE
                    Stdout   = (@($pipelineOut) -join "`n") + $outWriter.ToString()
                    Stderr   = $errorWriter.ToString()
                }
            } finally {
                [System.Console]::SetIn($originalIn)
                [System.Console]::SetOut($originalOut)
                [System.Console]::SetError($originalError)
            }
        }
    }

    Context 'enforce-evidence-locations policy functions' {
        It 'treats <Label> as forbidden: <Expected>' -ForEach @(
            @{ Label = 'artifacts/baselines'; Path = 'artifacts/baselines/run.md'; Expected = $true }
            @{ Label = 'artifacts/qa-gates'; Path = 'artifacts/qa-gates/gate.md'; Expected = $true }
            @{ Label = 'artifacts/research'; Path = 'artifacts/research/notes.md'; Expected = $true }
            @{ Label = 'a Windows-separated forbidden path'; Path = 'C:\repo\artifacts\coverage\a.md'; Expected = $true }
            @{ Label = 'a canonical feature evidence path'; Path = 'docs/features/active/x/evidence/qa-gates/a.md'; Expected = $false }
            @{ Label = 'a permitted artifacts sub-path'; Path = 'artifacts/orchestration/orchestrator-state.json'; Expected = $false }
        ) {
            Test-EvidenceLocationForbidden -FilePath $Path | Should -Be $Expected
        }

        It 'builds a deny decision naming the offending path' {
            $decision = Get-EvidenceLocationBlockDecision -FilePath 'artifacts/qa/a.md'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EVIDENCE_LOCATION_BLOCKED'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'artifacts/qa/a.md'
        }

        It 'allows when the mapped tool_input is empty' {
            (Invoke-EvidenceLocationDecision -ToolInputRaw '').hookSpecificOutput.permissionDecision |
                Should -Be 'allow'
        }

        It 'throws a hook-named error for malformed mapped tool_input JSON' {
            { Invoke-EvidenceLocationDecision -ToolInputRaw 'not json' } |
                Should -Throw -ExpectedMessage 'enforce-evidence-locations hook received malformed JSON in Codex tool_input: *'
        }

        It 'allows when the mapped tool_input carries no file_path' {
            (Invoke-EvidenceLocationDecision -ToolInputRaw '{"content":"x"}').hookSpecificOutput.permissionDecision |
                Should -Be 'allow'
        }

        It 'denies a forbidden evidence path' {
            $decision = Invoke-EvidenceLocationDecision -ToolInputRaw '{"file_path":"artifacts/evidence/a.md"}'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'allows a canonical evidence path' {
            $decision = Invoke-EvidenceLocationDecision -ToolInputRaw '{"file_path":"docs/features/active/x/evidence/other/a.md"}'

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'enforce-evidence-locations entrypoint function' {
        It 'returns 0 and writes a deny decision for a forbidden mapped path' {
            $payload = ConvertTo-CodexGatePayload -ToolName 'Write' -ToolInput @{
                file_path = 'artifacts/qa-gates/gate.md'
                content   = 'body'
            }
            $originalOut = [System.Console]::Out
            $outWriter = [System.IO.StringWriter]::new()
            try {
                [System.Console]::SetOut($outWriter)
                $exitCode = Invoke-EvidenceLocationEntryPoint -PayloadRaw $payload
            } finally {
                [System.Console]::SetOut($originalOut)
            }

            $exitCode | Should -Be 0
            $outWriter.ToString() | Should -Match 'EVIDENCE_LOCATION_BLOCKED'
        }

        It 'returns 0 with no output for an allowed mapped path' {
            $payload = ConvertTo-CodexGatePayload -ToolName 'Write' -ToolInput @{
                file_path = 'docs/features/active/x/evidence/other/a.md'
                content   = 'body'
            }
            $originalOut = [System.Console]::Out
            $outWriter = [System.IO.StringWriter]::new()
            try {
                [System.Console]::SetOut($outWriter)
                $exitCode = Invoke-EvidenceLocationEntryPoint -PayloadRaw $payload
            } finally {
                [System.Console]::SetOut($originalOut)
            }

            $exitCode | Should -Be 0
            $outWriter.ToString() | Should -BeNullOrEmpty
        }

        It 'evaluates both sides of an apply_patch rename' {
            $patch = "*** Begin Patch`n*** Update File: docs/keep.md`n*** Move to: artifacts/research/moved.md`n@@`n+line`n*** End Patch"
            $payload = ConvertTo-CodexGatePayload -ToolName 'apply_patch' -ToolInput @{ command = $patch }
            $originalOut = [System.Console]::Out
            $outWriter = [System.IO.StringWriter]::new()
            try {
                [System.Console]::SetOut($outWriter)
                $exitCode = Invoke-EvidenceLocationEntryPoint -PayloadRaw $payload
            } finally {
                [System.Console]::SetOut($originalOut)
            }

            $exitCode | Should -Be 0
            $outWriter.ToString() | Should -Match 'artifacts/research/moved.md'
        }

        It 'returns 2 and writes the reason to stderr for empty stdin' {
            $originalError = [System.Console]::Error
            $errorWriter = [System.IO.StringWriter]::new()
            try {
                [System.Console]::SetError($errorWriter)
                $exitCode = Invoke-EvidenceLocationEntryPoint -PayloadRaw ''
            } finally {
                [System.Console]::SetError($originalError)
            }

            $exitCode | Should -Be 2
            $errorWriter.ToString() | Should -Match 'enforce-evidence-locations hook input is empty'
        }
    }

    Context 'enforce-evidence-locations entrypoint (in-process script invocation)' {
        It 'exits 0 and denies a forbidden mapped path' {
            $payload = ConvertTo-CodexGatePayload -ToolName 'Write' -ToolInput @{
                file_path = 'artifacts/post-change/a.md'
                content   = 'body'
            }

            $result = Invoke-CodexGateEntrypoint -HookPath $script:EvidenceHookPath -PayloadRaw $payload

            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -Match 'EVIDENCE_LOCATION_BLOCKED'
        }

        It 'exits 2 on empty stdin' {
            $result = Invoke-CodexGateEntrypoint -HookPath $script:EvidenceHookPath -PayloadRaw ''

            $result.ExitCode | Should -Be 2
            $result.Stderr | Should -Match 'enforce-evidence-locations hook input is empty'
        }
    }

    Context 'enforce-checkpoint-monotonic step-order helpers' {
        It 'parses checkpoint JSON through the mockable wrapper' {
            (ConvertFrom-CheckpointJson -Json '{"next_step":"S07"}').next_step | Should -Be 'S07'
        }

        It 'maps <Label> to canonical index <Expected>' -ForEach @(
            @{ Label = 'an exact canonical step'; Entry = 'S3_promotion'; Expected = 3 }
            @{ Label = 'an underscore variant'; Entry = 'S3_promotion_issue'; Expected = 3 }
            @{ Label = 'a dotted variant'; Entry = 'S4_atomic_planning.v2'; Expected = 4 }
            @{ Label = 'a hyphen variant'; Entry = 'S5_atomic_execution-b'; Expected = 5 }
            @{ Label = 'a non-canonical entry'; Entry = 'not_a_step'; Expected = -1 }
            @{ Label = 'an empty entry'; Entry = ''; Expected = -1 }
        ) {
            Get-CanonicalStepIndex -StepEntry $Entry | Should -Be $Expected
        }

        It 'returns null when completed_steps are in canonical order' {
            Get-OutOfOrderPair -CompletedSteps @('S3_promotion', 'S4_atomic_planning', 'S5_atomic_execution') |
                Should -BeNullOrEmpty
        }

        It 'returns null when the list holds only non-canonical entries' {
            Get-OutOfOrderPair -CompletedSteps @('alpha', 'beta') | Should -BeNullOrEmpty
        }

        It 'returns the first out-of-order pair with its positions' {
            $pair = Get-OutOfOrderPair -CompletedSteps @('S5_atomic_execution', 'S3_promotion')

            $pair.EarlierEntry | Should -Be 'S5_atomic_execution'
            $pair.EarlierPos | Should -Be 0
            $pair.LaterEntry | Should -Be 'S3_promotion'
            $pair.LaterPos | Should -Be 1
        }

        It 'recognises <Label> for prefix matching: <Expected>' -ForEach @(
            @{ Label = 'an exact match'; Entry = 'S3_promotion'; Prefix = 'S3_promotion'; Expected = $true }
            @{ Label = 'an underscore variant'; Entry = 'S3_promotion_folder'; Prefix = 'S3_promotion'; Expected = $true }
            @{ Label = 'an unrelated entry'; Entry = 'S7_feature_review'; Prefix = 'S3_promotion'; Expected = $false }
        ) {
            Test-StepHasPrefix -StepEntry $Entry -Prefix $Prefix | Should -Be $Expected
        }

        It 'returns null when promotion and planning both precede an advanced step' {
            Get-MissingPrerequisiteForAdvancedStep -CompletedSteps @('S3_promotion', 'S4_atomic_planning', 'S5_atomic_execution') |
                Should -BeNullOrEmpty
        }

        It 'reports the advanced step and both missing prerequisites' {
            $result = Get-MissingPrerequisiteForAdvancedStep -CompletedSteps @('S5_atomic_execution')

            $result.Step | Should -Be 'S5_atomic_execution'
            $result.MissingPromotion | Should -BeTrue
            $result.MissingPlanning | Should -BeTrue
        }

        It 'reports only the missing planning prerequisite when promotion is present' {
            $result = Get-MissingPrerequisiteForAdvancedStep -CompletedSteps @('S3_promotion', 'S7_feature_review')

            $result.MissingPromotion | Should -BeFalse
            $result.MissingPlanning | Should -BeTrue
        }

        It 'recognises the governed checkpoint path' {
            Test-IsCheckpointPath -NormalizedPath $script:CheckpointPath | Should -BeTrue
            Test-IsCheckpointPath -NormalizedPath 'docs/notes.md' | Should -BeFalse
        }
    }

    Context 'enforce-checkpoint-monotonic decision function' {
        It 'allows when the mapped tool_input is empty' {
            (Invoke-CheckpointMonotonicDecision -ToolInputRaw '').hookSpecificOutput.permissionDecision |
                Should -Be 'allow'
        }

        It 'throws a hook-named error for malformed mapped tool_input JSON' {
            { Invoke-CheckpointMonotonicDecision -ToolInputRaw 'not json' } |
                Should -Throw -ExpectedMessage 'enforce-checkpoint-monotonic hook received malformed JSON in Codex tool_input: *'
        }

        It 'allows when the mapped tool_input carries no file_path' {
            (Invoke-CheckpointMonotonicDecision -ToolInputRaw '{"content":"{}"}').hookSpecificOutput.permissionDecision |
                Should -Be 'allow'
        }

        It 'allows a file path that is not the governed checkpoint' {
            $raw = @{ file_path = 'docs/notes.md'; content = '{}' } | ConvertTo-Json -Compress

            (Invoke-CheckpointMonotonicDecision -ToolInputRaw $raw).hookSpecificOutput.permissionDecision |
                Should -Be 'allow'
        }

        It 'denies an empty-content write to the governed checkpoint' {
            $raw = @{ file_path = $script:CheckpointPath; content = '' } | ConvertTo-Json -Compress

            $decision = Invoke-CheckpointMonotonicDecision -ToolInputRaw $raw

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'cannot be deleted or replaced with empty content'
        }

        It 'denies a checkpoint write whose content is not valid JSON' {
            $raw = @{ file_path = $script:CheckpointPath; content = 'not json' } | ConvertTo-Json -Compress

            $decision = Invoke-CheckpointMonotonicDecision -ToolInputRaw $raw

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'must remain valid JSON'
        }

        It 'allows a checkpoint write whose completed_steps are in canonical order' {
            $content = '{"completed_steps":["S3_promotion","S4_atomic_planning","S5_atomic_execution"]}'
            $raw = @{ file_path = $script:CheckpointPath; content = $content } | ConvertTo-Json -Compress

            (Invoke-CheckpointMonotonicDecision -ToolInputRaw $raw).hookSpecificOutput.permissionDecision |
                Should -Be 'allow'
        }

        It 'allows a checkpoint write with an empty completed_steps list' {
            $raw = @{ file_path = $script:CheckpointPath; content = '{"completed_steps":[]}' } | ConvertTo-Json -Compress

            (Invoke-CheckpointMonotonicDecision -ToolInputRaw $raw).hookSpecificOutput.permissionDecision |
                Should -Be 'allow'
        }

        It 'allows an out-of-order checkpoint when a rollback is recorded' {
            $content = '{"completed_steps":["S5_atomic_execution","S3_promotion"],"rollback_history":[{"at":"S5"}]}'
            $raw = @{ file_path = $script:CheckpointPath; content = $content } | ConvertTo-Json -Compress

            (Invoke-CheckpointMonotonicDecision -ToolInputRaw $raw).hookSpecificOutput.permissionDecision |
                Should -Be 'allow'
        }

        It 'denies an out-of-order checkpoint with no rollback history' {
            $content = '{"completed_steps":["S5_atomic_execution","S3_promotion"],"rollback_history":[]}'
            $raw = @{ file_path = $script:CheckpointPath; content = $content } | ConvertTo-Json -Compress

            $decision = Invoke-CheckpointMonotonicDecision -ToolInputRaw $raw

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match "lists 'S5_atomic_execution' at position 0"
        }

        It 'denies an advanced step recorded without its prerequisites' {
            $raw = @{ file_path = $script:CheckpointPath; content = '{"completed_steps":["S7_feature_review"]}' } | ConvertTo-Json -Compress

            $decision = Invoke-CheckpointMonotonicDecision -ToolInputRaw $raw

            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'S3_promotion, S4_atomic_planning'
        }

        It 'names only the missing planning prerequisite when promotion is recorded' {
            $content = '{"completed_steps":["S3_promotion","S7_feature_review"]}'
            $raw = @{ file_path = $script:CheckpointPath; content = $content } | ConvertTo-Json -Compress

            $decision = Invoke-CheckpointMonotonicDecision -ToolInputRaw $raw

            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'prerequisite step\(s\): S4_atomic_planning'
        }
    }

    Context 'enforce-checkpoint-monotonic entrypoint (in-process)' {
        It 'exits 0 and denies an out-of-order checkpoint write' {
            $content = '{"completed_steps":["S5_atomic_execution","S3_promotion"]}'
            $payload = ConvertTo-CodexGatePayload -ToolName 'Write' -ToolInput @{
                file_path = $script:CheckpointPath
                content   = $content
            }

            $result = Invoke-CodexGateEntrypoint -HookPath $script:CheckpointHookPath -PayloadRaw $payload

            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -Match 'CHECKPOINT_ORDER_BLOCKED'
        }

        It 'exits 0 with no output for an unrelated mapped write' {
            $payload = ConvertTo-CodexGatePayload -ToolName 'Write' -ToolInput @{
                file_path = 'docs/notes.md'
                content   = 'body'
            }

            $result = Invoke-CodexGateEntrypoint -HookPath $script:CheckpointHookPath -PayloadRaw $payload

            $result.ExitCode | Should -Be 0
            $result.Stdout | Should -BeNullOrEmpty
        }

        It 'exits 2 on empty stdin' {
            $result = Invoke-CodexGateEntrypoint -HookPath $script:CheckpointHookPath -PayloadRaw ''

            $result.ExitCode | Should -Be 2
            $result.Stderr | Should -Match 'enforce-checkpoint-monotonic hook input is empty'
        }
    }
}
