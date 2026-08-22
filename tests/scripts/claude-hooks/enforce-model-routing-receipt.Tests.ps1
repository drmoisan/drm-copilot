#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'enforce-model-routing-receipt.ps1' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-model-routing-receipt.ps1").Path
        . $script:UnderTest

        function Get-SyntheticCheckpoint {
            param([string[]] $ReceiptAgents)
            $receipts = @()
            foreach ($agent in $ReceiptAgents) {
                $receipts += [pscustomobject]@{ agent = $agent; phase = '7'; model = 'opus' }
            }
            return [pscustomobject]@{ model_routing_receipts = $receipts }
        }
    }

    Context 'envelope anomalies fail closed; out-of-scope delegations allow' {
        It 'denies an empty payload as an envelope anomaly (fail closed)' {
            $decision = Invoke-ModelRoutingReceiptDecision -ToolInputRaw ''
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'MODEL_ROUTING_RECEIPT_BLOCKED'
        }

        It 'denies the legacy flat root shape as a missing-tool_input anomaly' {
            $flat = (@{ subagent_type = 'atomic-planner'; prompt = 'x' } | ConvertTo-Json -Compress)
            $decision = Invoke-ModelRoutingReceiptDecision -ToolInputRaw $flat
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'no tool_input key'
        }

        It 'allows a well-formed tool_input carrying no subagent_type (scope filter)' {
            $nested = '{"tool_name":"Bash","tool_input":{"command":"echo hi"}}'
            (Invoke-ModelRoutingReceiptDecision -ToolInputRaw $nested).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies unparseable JSON as an envelope anomaly (fail closed)' {
            $decision = Invoke-ModelRoutingReceiptDecision -ToolInputRaw '{not-json'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'not parseable JSON'
        }

        It 'allows a non-delegating subagent_type' {
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'commit-message'; prompt = 'x' }
                } | ConvertTo-Json -Compress -Depth 5)
            (Invoke-ModelRoutingReceiptDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows an orchestrator subagent_type (caller, not receipt-gated)' {
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'orchestrator'; prompt = 'x' }
                } | ConvertTo-Json -Compress -Depth 5)
            (Invoke-ModelRoutingReceiptDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'presence gating for a delegating subagent_type' {
        It 'allows when a routing receipt exists for the subagent' {
            Mock -CommandName Get-ModelRoutingCheckpoint -MockWith { Get-SyntheticCheckpoint -ReceiptAgents @('atomic-planner') }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'x' }
                } | ConvertTo-Json -Compress -Depth 5)
            (Invoke-ModelRoutingReceiptDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies with MODEL_ROUTING_RECEIPT_BLOCKED when no receipt exists for the subagent' {
            Mock -CommandName Get-ModelRoutingCheckpoint -MockWith { Get-SyntheticCheckpoint -ReceiptAgents @('feature-review') }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'x' }
                } | ConvertTo-Json -Compress -Depth 5)
            $decision = Invoke-ModelRoutingReceiptDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'MODEL_ROUTING_RECEIPT_BLOCKED'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'atomic-planner'
        }

        It 'denies when the checkpoint is missing (no receipts at all)' {
            Mock -CommandName Get-ModelRoutingCheckpoint -MockWith { $null }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-executor'; prompt = 'x' }
                } | ConvertTo-Json -Compress -Depth 5)
            $decision = Invoke-ModelRoutingReceiptDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'MODEL_ROUTING_RECEIPT_BLOCKED'
        }

        It 'denies when the checkpoint has no model_routing_receipts property' {
            Mock -CommandName Get-ModelRoutingCheckpoint -MockWith { [pscustomobject]@{ objective = 'x' } }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'feature-review'; prompt = 'x' }
                } | ConvertTo-Json -Compress -Depth 5)
            $decision = Invoke-ModelRoutingReceiptDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }
    }

    Context 'Get-ModelRoutingCheckpoint filesystem seam' {
        It 'returns $null when the checkpoint path does not exist' {
            $missing = Join-Path $PSScriptRoot 'no-such-checkpoint-file.json'
            Get-ModelRoutingCheckpoint -CheckpointPath $missing | Should -BeNullOrEmpty
        }

        It 'returns $null when the file exists but is not valid JSON' {
            # The hook script itself is an existing, committed non-JSON file; no
            # temporary file is created.
            Get-ModelRoutingCheckpoint -CheckpointPath $script:UnderTest | Should -BeNullOrEmpty
        }

        It 'returns a parsed object when the file exists and is valid JSON' {
            # config/orchestration-routing.json is an existing committed JSON file.
            $jsonPath = (Resolve-Path (Join-Path $PSScriptRoot '../../../config/orchestration-routing.json')).Path
            $parsed = Get-ModelRoutingCheckpoint -CheckpointPath $jsonPath
            $parsed | Should -Not -BeNullOrEmpty
            $parsed.version | Should -Be 1
        }
    }

    Context 'Test-ModelRoutingReceiptPresent' {
        It 'returns $false for a $null checkpoint' {
            Test-ModelRoutingReceiptPresent -Checkpoint $null -Subagent 'atomic-planner' | Should -BeFalse
        }

        It 'returns $true when a matching receipt exists' {
            $checkpoint = Get-SyntheticCheckpoint -ReceiptAgents @('atomic-planner')
            Test-ModelRoutingReceiptPresent -Checkpoint $checkpoint -Subagent 'atomic-planner' | Should -BeTrue
        }
    }
}
