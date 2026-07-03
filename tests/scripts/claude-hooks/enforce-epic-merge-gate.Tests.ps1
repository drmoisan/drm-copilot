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
        It 'allows when CLAUDE_TOOL_INPUT is empty' {
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw ''
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows a non gh-pr-merge Bash command' {
            $json = '{"command":"git status"}'
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows gh pr merge without --merge (e.g., --squash)' {
            $json = '{"command":"gh pr merge 10 --squash"}'
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'throws on malformed JSON so the hook exits 1' {
            { Invoke-EpicMergeGateDecision -ToolInputRaw '{not-json' } | Should -Throw
        }
    }

    Context 'allow via child-feature checkpoint (epic_mode + step9_status passed)' {
        It 'allows gh pr merge --merge when the child checkpoint is epic_mode true and step9_status passed' {
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith {
                '{"epic_mode":true,"step9_status":"passed"}'
            }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { $null }
            $json = '{"command":"gh pr merge --merge"}'
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies when the child checkpoint has epic_mode true but step9_status is not passed' {
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith {
                '{"epic_mode":true,"step9_status":"pending"}'
            }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { $null }
            $json = '{"command":"gh pr merge --merge"}'
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
            $json = '{"command":"gh pr merge 410 --merge"}'
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows a bare gh pr merge --merge (no PR number) when ci_gate.conclusion is success' {
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith {
                '{"epic_merge_pr":{"pr_number":410,"ci_gate":{"conclusion":"success"}}}'
            }
            $json = '{"command":"gh pr merge --merge"}'
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
            $json = '{"command":"gh pr merge 999 --merge"}'
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
            $json = '{"command":"gh pr merge 410 --merge"}'
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_MERGE_GATE_BLOCKED'
        }
    }

    Context 'deny on missing/unreadable checkpoints (fail closed)' {
        It 'denies EPIC_MERGE_GATE_BLOCKED when both checkpoints are absent' {
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { $null }
            $json = '{"command":"gh pr merge --merge"}'
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_MERGE_GATE_BLOCKED'
        }

        It 'denies when both checkpoints are unreadable (malformed JSON)' {
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { '{ broken' }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { '{ also broken' }
            $json = '{"command":"gh pr merge --merge"}'
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_MERGE_GATE_BLOCKED'
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
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw '{"other":"value"}'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'script entrypoint (end-to-end)' {
        BeforeAll {
            $script:HookPath = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-merge-gate.ps1").Path
            $script:PwshExe = if ($PSVersionTable.PSVersion.Major -ge 7 -and $PSEdition -eq 'Core') {
                (Get-Process -Id $PID).Path
            } else {
                (Get-Command pwsh -CommandType Application -ErrorAction Stop).Source
            }
        }

        It 'allows when CLAUDE_TOOL_INPUT is empty (exit 0, allow)' {
            $prev = $env:CLAUDE_TOOL_INPUT
            try {
                $env:CLAUDE_TOOL_INPUT = ''
                $out = & $script:PwshExe -NoProfile -File $script:HookPath
                $LASTEXITCODE | Should -Be 0
                ($out | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
            } finally {
                $env:CLAUDE_TOOL_INPUT = $prev
            }
        }

        It 'denies EPIC_MERGE_GATE_BLOCKED end-to-end with no checkpoints present in this repo checkout' {
            $prev = $env:CLAUDE_TOOL_INPUT
            try {
                $env:CLAUDE_TOOL_INPUT = '{"command":"gh pr merge 999999 --merge"}'
                $out = & $script:PwshExe -NoProfile -File $script:HookPath
                $LASTEXITCODE | Should -Be 0
                $parsed = $out | ConvertFrom-Json
                $parsed.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
                $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
                $parsed.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_MERGE_GATE_BLOCKED'
            } finally {
                $env:CLAUDE_TOOL_INPUT = $prev
            }
        }

        It 'exits 1 on malformed JSON' {
            $prev = $env:CLAUDE_TOOL_INPUT
            try {
                $env:CLAUDE_TOOL_INPUT = '{not-json'
                $null = & $script:PwshExe -NoProfile -File $script:HookPath 2>&1
                $LASTEXITCODE | Should -Be 1
            } finally {
                $env:CLAUDE_TOOL_INPUT = $prev
            }
        }
    }
}
