#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Pester tests for the enforce-epic-merge-gate.ps1 PreToolUse hook.
#>

Describe 'enforce-epic-merge-gate.ps1' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-merge-gate.ps1").Path
        . $script:UnderTest
    }

    Context 'commands outside scope' {
        It 'denies an empty payload as an envelope anomaly (fail closed)' {
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw ''
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_MERGE_GATE_BLOCKED'
        }

        It 'allows a non gh-pr-merge Bash command' {
            $json = '{"tool_input":{"command":"git status"}}'
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows gh pr merge without --merge (e.g., --squash)' {
            $json = '{"tool_input":{"command":"gh pr merge 10 --squash"}}'
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies unparseable JSON instead of throwing (exit 1 is non-blocking)' {
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw '{not-json'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'not parseable JSON'
        }
    }

    Context 'allow via child-feature checkpoint (epic_mode + step9_status passed)' {
        It 'allows gh pr merge --merge when the child checkpoint is epic_mode true and step9_status passed' {
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith {
                '{"epic_mode":true,"step9_status":"passed"}'
            }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { $null }
            $json = '{"tool_input":{"command":"gh pr merge --merge"}}'
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies when the child checkpoint has epic_mode true but step9_status is not passed' {
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith {
                '{"epic_mode":true,"step9_status":"pending"}'
            }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { $null }
            $json = '{"tool_input":{"command":"gh pr merge --merge"}}'
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_MERGE_GATE_BLOCKED'
        }
    }

    Context 'allow via epic-integration checkpoint (ci_gate success + matching PR number)' {
        It 'allows gh pr merge <N> --merge when epic_merge_pr.ci_gate.conclusion is success and PR number matches' {
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith {
                '{"epic_merge_pr":{"pr_number":410,"ci_gate":{"conclusion":"success"}}}'
            }
            $json = '{"tool_input":{"command":"gh pr merge 410 --merge"}}'
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows a bare gh pr merge --merge (no PR number) when ci_gate.conclusion is success' {
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith {
                '{"epic_merge_pr":{"pr_number":410,"ci_gate":{"conclusion":"success"}}}'
            }
            $json = '{"tool_input":{"command":"gh pr merge --merge"}}'
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'deny on non-matching PR number' {
        It 'denies gh pr merge <N> --merge when N does not match epic_merge_pr.pr_number' {
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith {
                '{"epic_merge_pr":{"pr_number":410,"ci_gate":{"conclusion":"success"}}}'
            }
            Mock -CommandName Get-ParallelOrchestratorCheckpointContent -MockWith { $null }
            $json = '{"tool_input":{"command":"gh pr merge 999 --merge"}}'
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_MERGE_GATE_BLOCKED'
        }
    }

    Context 'deny on non-success ci_gate.conclusion' {
        It 'denies when epic_merge_pr.ci_gate.conclusion is pending' {
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith {
                '{"epic_merge_pr":{"pr_number":410,"ci_gate":{"conclusion":"pending"}}}'
            }
            Mock -CommandName Get-ParallelOrchestratorCheckpointContent -MockWith { $null }
            $json = '{"tool_input":{"command":"gh pr merge 410 --merge"}}'
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_MERGE_GATE_BLOCKED'
        }
    }

    Context 'deny on missing/unreadable checkpoints (fail closed)' {
        It 'denies EPIC_MERGE_GATE_BLOCKED when both checkpoints are absent' {
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-ParallelOrchestratorCheckpointContent -MockWith { $null }
            $json = '{"tool_input":{"command":"gh pr merge --merge"}}'
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_MERGE_GATE_BLOCKED'
        }

        It 'denies when both checkpoints are unreadable (malformed JSON)' {
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { '{ broken' }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { '{ also broken' }
            Mock -CommandName Get-ParallelOrchestratorCheckpointContent -MockWith { $null }
            $json = '{"tool_input":{"command":"gh pr merge --merge"}}'
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_MERGE_GATE_BLOCKED'
        }
    }

    Context 'allow via parallel-orchestrator checkpoint (route_id parallel + ci_green + matching PR)' {
        It 'allows gh pr merge --merge <N> when route_id is parallel and the matched item is ci_green' {
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-ParallelOrchestratorCheckpointContent -MockWith {
                '{"route_id":"parallel","items":[{"pr_number":501,"merge_status":"ci_green"}]}'
            }
            $json = '{"tool_input":{"command":"gh pr merge --merge 501"}}'
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'deny via parallel-orchestrator checkpoint (fail closed)' {
        It 'denies when the matched item merge_status is not ci_green (e.g. pr_open)' {
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-ParallelOrchestratorCheckpointContent -MockWith {
                '{"route_id":"parallel","items":[{"pr_number":501,"merge_status":"pr_open"}]}'
            }
            $json = '{"tool_input":{"command":"gh pr merge --merge 501"}}'
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_MERGE_GATE_BLOCKED'
        }

        It 'denies when the command PR number matches no item' {
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-ParallelOrchestratorCheckpointContent -MockWith {
                '{"route_id":"parallel","items":[{"pr_number":501,"merge_status":"ci_green"}]}'
            }
            $json = '{"tool_input":{"command":"gh pr merge --merge 777"}}'
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_MERGE_GATE_BLOCKED'
        }

        It 'denies when route_id is not parallel' {
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-ParallelOrchestratorCheckpointContent -MockWith {
                '{"route_id":"standard","items":[{"pr_number":501,"merge_status":"ci_green"}]}'
            }
            $json = '{"tool_input":{"command":"gh pr merge --merge 501"}}'
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_MERGE_GATE_BLOCKED'
        }

        It 'denies when the parallel checkpoint is absent and child and epic are also absent' {
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-ParallelOrchestratorCheckpointContent -MockWith { $null }
            $json = '{"tool_input":{"command":"gh pr merge --merge 501"}}'
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_MERGE_GATE_BLOCKED'
        }

        It 'denies when the parallel checkpoint is malformed JSON' {
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-ParallelOrchestratorCheckpointContent -MockWith { '{ broken parallel' }
            $json = '{"tool_input":{"command":"gh pr merge --merge 501"}}'
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_MERGE_GATE_BLOCKED'
        }

        It 'denies a bare gh pr merge --merge (no PR number) even when a parallel checkpoint is present' {
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-ParallelOrchestratorCheckpointContent -MockWith {
                '{"route_id":"parallel","items":[{"pr_number":501,"merge_status":"ci_green"}]}'
            }
            $json = '{"tool_input":{"command":"gh pr merge --merge"}}'
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_MERGE_GATE_BLOCKED'
        }
    }

    Context 'Get-EpicMergeGateCommandPrNumber extractor (flag-order forms)' {
        It 'returns 410 for the number-before-flag form gh pr merge 410 --merge' {
            Get-EpicMergeGateCommandPrNumber -CommandText 'gh pr merge 410 --merge' | Should -Be 410
        }

        It 'returns 410 for the flag-before-number form gh pr merge --merge 410' {
            Get-EpicMergeGateCommandPrNumber -CommandText 'gh pr merge --merge 410' | Should -Be 410
        }

        It 'returns $null for a bare gh pr merge --merge with no PR number' {
            Get-EpicMergeGateCommandPrNumber -CommandText 'gh pr merge --merge' | Should -BeNullOrEmpty
        }
    }

    Context 'real Test-Path read seam for the parallel checkpoint' {
        It 'Get-ParallelOrchestratorCheckpointContent returns $null when the checkpoint file does not exist' {
            Mock -CommandName Test-Path -MockWith { $false } -ParameterFilter { $LiteralPath -eq $script:ParallelCheckpointPath }
            Get-ParallelOrchestratorCheckpointContent | Should -BeNullOrEmpty
        }

        It 'Get-ParallelOrchestratorCheckpointContent reads real content when the file exists' {
            Mock -CommandName Test-Path -MockWith { $true } -ParameterFilter { $LiteralPath -eq $script:ParallelCheckpointPath }
            Mock -CommandName Get-Content -MockWith { '{"route_id":"parallel"}' } -ParameterFilter { $LiteralPath -eq $script:ParallelCheckpointPath }
            Get-ParallelOrchestratorCheckpointContent | Should -Be '{"route_id":"parallel"}'
        }
    }

    Context 'Test-ParallelCheckpointAllowsMerge helper (direct branch coverage)' {
        It 'returns $false when Checkpoint is $null' {
            Test-ParallelCheckpointAllowsMerge -Checkpoint $null -CommandPrNumber 501 | Should -BeFalse
        }

        It 'returns $false when route_id is not parallel' {
            $checkpoint = '{"route_id":"standard","items":[{"pr_number":501,"merge_status":"ci_green"}]}' | ConvertFrom-Json
            Test-ParallelCheckpointAllowsMerge -Checkpoint $checkpoint -CommandPrNumber 501 | Should -BeFalse
        }

        It 'returns $false when CommandPrNumber is $null' {
            $checkpoint = '{"route_id":"parallel","items":[{"pr_number":501,"merge_status":"ci_green"}]}' | ConvertFrom-Json
            Test-ParallelCheckpointAllowsMerge -Checkpoint $checkpoint -CommandPrNumber $null | Should -BeFalse
        }

        It 'returns $false when items is absent' {
            $checkpoint = '{"route_id":"parallel"}' | ConvertFrom-Json
            Test-ParallelCheckpointAllowsMerge -Checkpoint $checkpoint -CommandPrNumber 501 | Should -BeFalse
        }

        It 'returns $false when no item matches the command PR number' {
            $checkpoint = '{"route_id":"parallel","items":[{"pr_number":501,"merge_status":"ci_green"}]}' | ConvertFrom-Json
            Test-ParallelCheckpointAllowsMerge -Checkpoint $checkpoint -CommandPrNumber 777 | Should -BeFalse
        }

        It 'returns $false when the matched item pr_number is non-numeric' {
            $checkpoint = '{"route_id":"parallel","items":[{"pr_number":"not-a-number","merge_status":"ci_green"}]}' | ConvertFrom-Json
            Test-ParallelCheckpointAllowsMerge -Checkpoint $checkpoint -CommandPrNumber 501 | Should -BeFalse
        }

        It 'returns $false when the matched item has no merge_status' {
            $checkpoint = '{"route_id":"parallel","items":[{"pr_number":501}]}' | ConvertFrom-Json
            Test-ParallelCheckpointAllowsMerge -Checkpoint $checkpoint -CommandPrNumber 501 | Should -BeFalse
        }

        It 'returns $false when the matched item merge_status is not ci_green' {
            $checkpoint = '{"route_id":"parallel","items":[{"pr_number":501,"merge_status":"pr_open"}]}' | ConvertFrom-Json
            Test-ParallelCheckpointAllowsMerge -Checkpoint $checkpoint -CommandPrNumber 501 | Should -BeFalse
        }

        It 'returns $true when the matched item merge_status is ci_green' {
            $checkpoint = '{"route_id":"parallel","items":[{"pr_number":501,"merge_status":"ci_green"}]}' | ConvertFrom-Json
            Test-ParallelCheckpointAllowsMerge -Checkpoint $checkpoint -CommandPrNumber 501 | Should -BeTrue
        }
    }

    Context 'real Test-Path read seams' {
        It 'Get-ChildOrchestratorCheckpointContent returns $null when the checkpoint file does not exist' {
            Mock -CommandName Test-Path -MockWith { $false } -ParameterFilter { $LiteralPath -eq $script:ChildCheckpointPath }
            Get-ChildOrchestratorCheckpointContent | Should -BeNullOrEmpty
        }

        It 'Get-ChildOrchestratorCheckpointContent reads real content when the file exists' {
            Mock -CommandName Test-Path -MockWith { $true } -ParameterFilter { $LiteralPath -eq $script:ChildCheckpointPath }
            Mock -CommandName Get-Content -MockWith { '{"epic_mode":true}' } -ParameterFilter { $LiteralPath -eq $script:ChildCheckpointPath }
            Get-ChildOrchestratorCheckpointContent | Should -Be '{"epic_mode":true}'
        }

        It 'Get-EpicOrchestratorCheckpointContent returns $null when the checkpoint file does not exist' {
            Mock -CommandName Test-Path -MockWith { $false } -ParameterFilter { $LiteralPath -eq $script:EpicCheckpointPath }
            Get-EpicOrchestratorCheckpointContent | Should -BeNullOrEmpty
        }

        It 'Get-EpicOrchestratorCheckpointContent reads real content when the file exists' {
            Mock -CommandName Test-Path -MockWith { $true } -ParameterFilter { $LiteralPath -eq $script:EpicCheckpointPath }
            Mock -CommandName Get-Content -MockWith { '{"epic_merge_pr":{}}' } -ParameterFilter { $LiteralPath -eq $script:EpicCheckpointPath }
            Get-EpicOrchestratorCheckpointContent | Should -Be '{"epic_merge_pr":{}}'
        }
    }

    Context 'Test-ChildCheckpointAllowsEpicMerge helper (direct branch coverage)' {
        It 'returns $false when Checkpoint is $null' {
            Test-ChildCheckpointAllowsEpicMerge -Checkpoint $null | Should -BeFalse
        }

        It 'returns $false when epic_mode is explicitly false' {
            $checkpoint = '{"epic_mode":false,"step9_status":"passed"}' | ConvertFrom-Json
            Test-ChildCheckpointAllowsEpicMerge -Checkpoint $checkpoint | Should -BeFalse
        }

        It 'returns $false when epic_mode is true but step9_status is absent' {
            $checkpoint = '{"epic_mode":true}' | ConvertFrom-Json
            Test-ChildCheckpointAllowsEpicMerge -Checkpoint $checkpoint | Should -BeFalse
        }

        It 'returns $true when epic_mode is true and step9_status is passed' {
            $checkpoint = '{"epic_mode":true,"step9_status":"passed"}' | ConvertFrom-Json
            Test-ChildCheckpointAllowsEpicMerge -Checkpoint $checkpoint | Should -BeTrue
        }
    }

    Context 'Test-EpicCheckpointAllowsMerge helper (direct branch coverage)' {
        It 'returns $false when Checkpoint is $null' {
            Test-EpicCheckpointAllowsMerge -Checkpoint $null -CommandPrNumber $null | Should -BeFalse
        }

        It 'returns $false when epic_merge_pr is absent' {
            $checkpoint = '{}' | ConvertFrom-Json
            Test-EpicCheckpointAllowsMerge -Checkpoint $checkpoint -CommandPrNumber $null | Should -BeFalse
        }

        It 'returns $false when epic_merge_pr.ci_gate is absent' {
            $checkpoint = '{"epic_merge_pr":{}}' | ConvertFrom-Json
            Test-EpicCheckpointAllowsMerge -Checkpoint $checkpoint -CommandPrNumber $null | Should -BeFalse
        }

        It 'returns $false when epic_merge_pr.pr_number is absent but a command PR number is supplied' {
            $checkpoint = '{"epic_merge_pr":{"ci_gate":{"conclusion":"success"}}}' | ConvertFrom-Json
            Test-EpicCheckpointAllowsMerge -Checkpoint $checkpoint -CommandPrNumber 410 | Should -BeFalse
        }

        It 'returns $false when epic_merge_pr.pr_number is non-numeric' {
            $checkpoint = '{"epic_merge_pr":{"pr_number":"not-a-number","ci_gate":{"conclusion":"success"}}}' | ConvertFrom-Json
            Test-EpicCheckpointAllowsMerge -Checkpoint $checkpoint -CommandPrNumber 410 | Should -BeFalse
        }

        It 'returns $true when no command PR number is supplied and ci_gate is success' {
            $checkpoint = '{"epic_merge_pr":{"pr_number":410,"ci_gate":{"conclusion":"success"}}}' | ConvertFrom-Json
            Test-EpicCheckpointAllowsMerge -Checkpoint $checkpoint -CommandPrNumber $null | Should -BeTrue
        }
    }

    Context 'Invoke-EpicMergeGateDecision - command field absent' {
        It 'allows when the JSON payload has no command field' {
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw '{"tool_input":{"other":"value"}}'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'entry-point exit code and emitted decision (AC-4, no child process)' {
        BeforeEach {
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-ParallelOrchestratorCheckpointContent -MockWith { $null }
        }

        It 'returns exit code 0 and emits a deny when every transport is empty' {
            $emptyReader = {
                Read-ClaudeHookRawPayload `
                    -ReadStandardInput { '' } `
                    -TestStandardInputRedirected { $true } `
                    -HookInputFallback '' `
                    -ToolInputFallback ''
            }
            $emitted = Invoke-EpicMergeGateEntryPoint -ReadPayload $emptyReader 6> $null
            $code = $emitted[-1]
            $code | Should -Be 0
            $code | Should -Not -Be 1
            $parsed = $emitted[0] | ConvertFrom-Json
            $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $parsed.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_MERGE_GATE_BLOCKED'
        }

        It 'returns exit code 0 and emits a deny for unparseable JSON' {
            $emitted = Invoke-EpicMergeGateEntryPoint -ToolInputRaw '{not-json'
            $emitted[-1] | Should -Be 0
            $emitted[-1] | Should -Not -Be 1
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'returns exit code 0 and emits a deny for JSON with no tool_input key' {
            $emitted = Invoke-EpicMergeGateEntryPoint -ToolInputRaw '{"session_id":"s1","tool_name":"Bash"}'
            $emitted[-1] | Should -Be 0
            $emitted[-1] | Should -Not -Be 1
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason |
                Should -Match 'no tool_input key'
        }

        It 'returns exit code 0 and emits a deny for the legacy flat root shape' {
            $emitted = Invoke-EpicMergeGateEntryPoint -ToolInputRaw '{"command":"gh pr merge 999 --merge"}'
            $emitted[-1] | Should -Be 0
            $emitted[-1] | Should -Not -Be 1
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason |
                Should -Match 'no tool_input key'
        }

        It 'returns exit code 0 and emits a deny for a null tool_input' {
            $emitted = Invoke-EpicMergeGateEntryPoint -ToolInputRaw '{"tool_name":"Bash","tool_input":null}'
            $emitted[-1] | Should -Be 0
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason |
                Should -Match 'tool_input is null'
        }

        It 'returns exit code 0 and emits a deny for a non-object tool_input' {
            $emitted = Invoke-EpicMergeGateEntryPoint -ToolInputRaw '{"tool_name":"Bash","tool_input":"gh pr merge"}'
            $emitted[-1] | Should -Be 0
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason |
                Should -Match 'not an object'
        }

        It 'denies the nested envelope end-to-end when no checkpoint satisfies the gate' {
            $nested = '{"tool_name":"Bash","tool_input":{"command":"gh pr merge 999 --merge"}}'
            $emitted = Invoke-EpicMergeGateEntryPoint -ToolInputRaw $nested
            $emitted[-1] | Should -Be 0
            $parsed = $emitted[0] | ConvertFrom-Json
            $parsed.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $parsed.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_MERGE_GATE_BLOCKED'
        }

        It 'allows the nested envelope when the child checkpoint authorizes the merge' {
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith {
                '{"epic_mode":true,"step9_status":"passed"}'
            }
            $nested = '{"tool_name":"Bash","tool_input":{"command":"gh pr merge --merge"}}'
            $emitted = Invoke-EpicMergeGateEntryPoint -ToolInputRaw $nested
            $emitted[-1] | Should -Be 0
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }
}
