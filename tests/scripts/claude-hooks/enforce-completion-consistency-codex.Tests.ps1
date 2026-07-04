#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Injected seam stubs mirror the production scriptblock signatures for testing')]
param()

Describe 'bundled Codex enforce-completion-consistency.ps1' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.codex/hooks/enforce-completion-consistency.ps1").Path

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

    It 'keeps the bundled-mirror enforce-completion-consistency.ps1 byte-identical to the canonical hook' {
        $bundledPath = (Resolve-Path "$PSScriptRoot/../../../extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-consistency.ps1").Path

        $canonicalHash = (Get-FileHash -Path $script:UnderTest -Algorithm SHA256).Hash
        $bundledHash = (Get-FileHash -Path $bundledPath -Algorithm SHA256).Hash

        $bundledHash | Should -Be $canonicalHash -Because 'the bundled-mirror hook must stay byte-identical to the canonical .codex/hooks/enforce-completion-consistency.ps1 path'
    }

    It 'keeps the bundled-mirror enforce-completion-helpers.ps1 byte-identical to the canonical helper' {
        $canonicalHelpersPath = (Resolve-Path "$PSScriptRoot/../../../.codex/hooks/enforce-completion-helpers.ps1").Path
        $bundledHelpersPath = (Resolve-Path "$PSScriptRoot/../../../extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-helpers.ps1").Path

        $canonicalHash = (Get-FileHash -Path $canonicalHelpersPath -Algorithm SHA256).Hash
        $bundledHash = (Get-FileHash -Path $bundledHelpersPath -Algorithm SHA256).Hash

        $bundledHash | Should -Be $canonicalHash -Because 'the bundled-mirror helper must stay byte-identical to the canonical .codex/hooks/enforce-completion-helpers.ps1 path'
    }
}
