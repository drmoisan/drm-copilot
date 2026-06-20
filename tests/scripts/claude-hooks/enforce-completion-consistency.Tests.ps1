#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'enforce-completion-consistency.ps1' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-completion-consistency.ps1").Path
        . $script:UnderTest

        # Builds a Write-style CLAUDE_TOOL_INPUT JSON string for a checkpoint payload.
        function ConvertTo-CheckpointToolInput {
            param(
                [hashtable] $Payload,
                [string] $FilePath = 'artifacts/orchestration/orchestrator-state.json'
            )
            $content = $Payload | ConvertTo-Json -Compress -Depth 8
            return (@{ file_path = $FilePath; content = $content } | ConvertTo-Json -Compress -Depth 8)
        }
    }

    Context 'tool input parsing' {
        It 'allows when CLAUDE_TOOL_INPUT is empty' {
            (Invoke-CompletionConsistencyDecision -ToolInputRaw '')['decision'] | Should -Be 'allow'
        }

        It 'allows when file_path is missing' {
            (Invoke-CompletionConsistencyDecision -ToolInputRaw '{"content":"{}"}')['decision'] | Should -Be 'allow'
        }

        It 'throws on malformed top-level JSON so the hook exits 1' {
            { Invoke-CompletionConsistencyDecision -ToolInputRaw '{not-json' } | Should -Throw
        }

        It 'allows when content itself is not valid JSON (defers to downstream tools)' {
            $json = (@{ file_path = 'artifacts/orchestration/orchestrator-state.json'; content = '{broken' } | ConvertTo-Json -Compress)
            (Invoke-CompletionConsistencyDecision -ToolInputRaw $json)['decision'] | Should -Be 'allow'
        }
    }

    Context 'path matching (non-checkpoint path is allowed)' {
        It 'allows a file_path other than the checkpoint' {
            $json = ConvertTo-CheckpointToolInput -FilePath 'some/other.json' -Payload @{ next_step = 'complete' }
            (Invoke-CompletionConsistencyDecision -ToolInputRaw $json)['decision'] | Should -Be 'allow'
        }
    }

    Context 'Edit tool calls (no full content)' {
        It 'allows an Edit-style call that only supplies old_string/new_string on the checkpoint path' {
            $json = '{"file_path":"artifacts/orchestration/orchestrator-state.json","old_string":"a","new_string":"b"}'
            (Invoke-CompletionConsistencyDecision -ToolInputRaw $json)['decision'] | Should -Be 'allow'
        }
    }

    Context 'checkpoint not asserting completion is allowed' {
        It 'allows a checkpoint whose next_step is not complete and has no completion markers' {
            $json = ConvertTo-CheckpointToolInput -Payload @{
                next_step       = 'S5_atomic_execution'
                completed_steps = @('S0_startup_checks', 'S4_atomic_planning')
                step8_status    = 'in_progress'
                step9_status    = 'pending'
                step10_status   = 'pending'
            }
            (Invoke-CompletionConsistencyDecision -ToolInputRaw $json)['decision'] | Should -Be 'allow'
        }
    }

    Context 'completion asserted with full evidence is allowed' {
        It 'allows when issue-num, feature-folder, and a success ci_gate with head_sha are present' {
            $json = ConvertTo-CheckpointToolInput -Payload @{
                next_step        = 'complete'
                'issue-num'      = '207'
                'feature-folder' = 'docs/features/active/2026-06-19-harden-small-path-completion-gate-207'
                ci_gate          = @{ conclusion = 'success'; head_sha = 'abc123def456' }
            }
            (Invoke-CompletionConsistencyDecision -ToolInputRaw $json)['decision'] | Should -Be 'allow'
        }

        It 'accepts variables.issue-num and variables.feature-folder fallbacks' {
            $json = ConvertTo-CheckpointToolInput -Payload @{
                completed_steps = @('S12_complete')
                variables       = @{ 'issue-num' = '207'; 'feature-folder' = 'docs/f' }
                ci_gate         = @{ conclusion = 'success'; head_sha = 'abc123' }
            }
            (Invoke-CompletionConsistencyDecision -ToolInputRaw $json)['decision'] | Should -Be 'allow'
        }
    }

    Context 'completion asserted with missing ci_gate is blocked' {
        It 'blocks and references ci_gate when ci_gate is absent' {
            $json = ConvertTo-CheckpointToolInput -Payload @{
                next_step        = 'complete'
                'issue-num'      = '207'
                'feature-folder' = 'docs/f'
            }
            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $json
            $decision['decision'] | Should -Be 'block'
            $decision['reason'] | Should -Match 'COMPLETION_CONSISTENCY_BLOCKED'
            $decision['reason'] | Should -Match 'ci_gate'
        }
    }

    Context 'completion asserted with success ci_gate but empty issue-num is blocked' {
        It 'blocks and references issue-num' {
            $json = ConvertTo-CheckpointToolInput -Payload @{
                completed_steps  = @('S12_complete')
                'issue-num'      = ''
                'feature-folder' = 'docs/f'
                ci_gate          = @{ conclusion = 'success'; head_sha = 'abc123' }
            }
            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $json
            $decision['decision'] | Should -Be 'block'
            $decision['reason'] | Should -Match 'issue-num'
        }
    }

    Context 'completion asserted with empty feature-folder is blocked' {
        It 'blocks and references feature-folder' {
            $json = ConvertTo-CheckpointToolInput -Payload @{
                step8_status     = 'completed'
                'issue-num'      = '207'
                'feature-folder' = ''
                ci_gate          = @{ conclusion = 'success'; head_sha = 'abc123' }
            }
            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $json
            $decision['decision'] | Should -Be 'block'
            $decision['reason'] | Should -Match 'feature-folder'
        }
    }

    Context 'completion asserted with ci_gate.conclusion != success is blocked' {
        It 'blocks and references ci_gate conclusion' {
            $json = ConvertTo-CheckpointToolInput -Payload @{
                next_step        = 'complete'
                'issue-num'      = '207'
                'feature-folder' = 'docs/f'
                ci_gate          = @{ conclusion = 'failure'; head_sha = 'abc123' }
            }
            $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $json
            $decision['decision'] | Should -Be 'block'
            $decision['reason'] | Should -Match 'conclusion'
        }
    }

    Context 'JSON-parse seam is mockable' {
        It 'allows when the mocked content parser throws (invalid content JSON path)' {
            Mock -CommandName ConvertFrom-CheckpointJson -MockWith { throw 'simulated parse failure' }
            $json = ConvertTo-CheckpointToolInput -Payload @{ next_step = 'complete' }
            (Invoke-CompletionConsistencyDecision -ToolInputRaw $json)['decision'] | Should -Be 'allow'
            Should -Invoke -CommandName ConvertFrom-CheckpointJson -Times 1
        }
    }

    Context 'Entrypoint (script body)' {
        It 'emits an allow decision JSON when CLAUDE_TOOL_INPUT is empty' {
            $prev = $env:CLAUDE_TOOL_INPUT
            try {
                $env:CLAUDE_TOOL_INPUT = ''
                $output = & $script:UnderTest
                $output | Should -Match '"decision"\s*:\s*"allow"'
            }
            finally {
                $env:CLAUDE_TOOL_INPUT = $prev
            }
        }

        It 'emits a block decision JSON when completion is asserted without evidence' {
            $prev = $env:CLAUDE_TOOL_INPUT
            try {
                $content = '{"next_step":"complete"}'
                $payload = (@{ file_path = 'artifacts/orchestration/orchestrator-state.json'; content = $content } | ConvertTo-Json -Compress)
                $env:CLAUDE_TOOL_INPUT = $payload
                $output = & $script:UnderTest
                $output | Should -Match '"decision"\s*:\s*"block"'
                $output | Should -Match 'COMPLETION_CONSISTENCY_BLOCKED'
            }
            finally {
                $env:CLAUDE_TOOL_INPUT = $prev
            }
        }
    }
}
