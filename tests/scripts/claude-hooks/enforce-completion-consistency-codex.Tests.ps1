#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Injected seam stubs mirror the production scriptblock signatures for testing')]
param()

Describe 'bundled Codex enforce-completion-consistency.ps1' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-consistency.ps1").Path

        function ConvertTo-CodexCheckpointToolInput {
            param(
                [hashtable] $Payload,
                [string] $FilePath = 'artifacts/orchestration/orchestrator-state.json'
            )

            $content = $Payload | ConvertTo-Json -Compress -Depth 8
            return (@{ file_path = $FilePath; content = $content } | ConvertTo-Json -Compress -Depth 8)
        }
    }

    BeforeEach {
        . $script:UnderTest
    }

    It 'emits the PreToolUse deny shape for a completion checkpoint with missing evidence' {
        $toolInput = ConvertTo-CodexCheckpointToolInput -Payload @{
            next_step = 'complete'
        }

        $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $toolInput

        $decision.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'COMPLETION_CONSISTENCY_BLOCKED'
    }

    It 'uses the helper-backed route gate for bundled Codex resources' {
        $routingMatrixReader = {
            [pscustomobject]@{
                routes = [pscustomobject]@{
                    large = [pscustomobject]@{ requires_pr_gate = $true }
                }
            }
        }
        $folderExists = { param($p) $true }
        $toolInput = ConvertTo-CodexCheckpointToolInput -Payload @{
            next_step        = 'complete'
            'issue-num'      = '301'
            'feature-folder' = 'docs/features/active/2026-07-03-pester-completion-consistency-301'
            route_id         = 'large'
            ci_gate          = @{ conclusion = 'success'; head_sha = 'abc123def456' }
        }

        $decision = Invoke-CompletionConsistencyDecision -ToolInputRaw $toolInput -FolderExistsCheck $folderExists -RoutingMatrixReader $routingMatrixReader

        $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'pr_gate'
    }
}
