#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'enforce-prd-feature-before-planner.ps1' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-prd-feature-before-planner.ps1").Path
        . $script:UnderTest
    }

    Context 'tool input parsing' {
        It 'denies an empty payload as an envelope anomaly (fail closed)' {
            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw ''
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'PRD_FEATURE_BLOCKED'
        }

        It 'allows when subagent_type is not atomic-planner' {
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'something-else'; prompt = 'docs/features/active/foo' }
                } | ConvertTo-Json -Compress -Depth 5)
            (Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows when subagent_type is missing from a well-formed tool_input' {
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ prompt = 'irrelevant' }
                } | ConvertTo-Json -Compress -Depth 5)
            (Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies the legacy flat root shape as a missing-tool_input anomaly' {
            $flat = (@{ subagent_type = 'atomic-planner'; prompt = 'irrelevant' } | ConvertTo-Json -Compress)
            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $flat
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'no tool_input key'
        }

        It 'denies unparseable JSON instead of throwing (exit 1 is non-blocking)' {
            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw '{not-json'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'not parseable JSON'
        }
    }

    Context 'atomic-planner delegation' {
        It 'allows when both spec.md and user-story.md exist in the target folder (prompt path)' {
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $true }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'See docs/features/active/2026-05-10-foo-1 for details.' }
                } | ConvertTo-Json -Compress -Depth 5)
            (Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'blocks when spec.md is missing' {
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith {
                param([string]$Path)
                return -not ($Path -match '/spec\.md$')
            }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'docs/features/active/2026-05-10-foo-1/' }
                } | ConvertTo-Json -Compress -Depth 5)
            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'spec\.md'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'prd-feature'
        }

        It 'blocks when user-story.md is missing' {
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith {
                param([string]$Path)
                return -not ($Path -match '/user-story\.md$')
            }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'docs/features/active/2026-05-10-foo-1' }
                } | ConvertTo-Json -Compress -Depth 5)
            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'user-story\.md'
        }

        It 'blocks when no feature folder is found in prompt and no checkpoint exists' {
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $true }
            Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { $null }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'plan something generic' }
                } | ConvertTo-Json -Compress -Depth 5)
            $decision = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'feature folder'
        }

        It 'falls back to orchestrator-state.json when prompt has no folder reference' {
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $true }
            Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { 'docs/features/active/2026-05-10-bar-2' }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'continue planning' }
                } | ConvertTo-Json -Compress -Depth 5)
            (Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'prefers the prompt-derived folder over the checkpoint folder' {
            $script:capturedPaths = @()
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith {
                param([string]$Path)
                $script:capturedPaths += $Path
                return $true
            }
            Mock -CommandName Get-PrdFeatureCheckpointFolder -MockWith { 'docs/features/active/checkpoint-folder' }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'work in docs/features/active/prompt-folder now' }
                } | ConvertTo-Json -Compress -Depth 5)
            (Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
            ($script:capturedPaths -join '|') | Should -Match 'prompt-folder'
            ($script:capturedPaths -join '|') | Should -Not -Match 'checkpoint-folder'
        }

        It 'treats a path ending in .md as a file and uses its parent directory' {
            $script:capturedPaths = @()
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith {
                param([string]$Path)
                $script:capturedPaths += $Path
                return $true
            }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'See docs/features/active/2026-05-10-foo-1/spec.md for the spec.' }
                } | ConvertTo-Json -Compress -Depth 5)
            (Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
            # Parent directory should be checked, not the .md path itself
            # Parent directory derivation: the spec.md leaf in the prompt should be stripped,
            # and the sibling spec.md / user-story.md should be probed under the parent folder.
            ($script:capturedPaths -join '|') | Should -Match '2026-05-10-foo-1/spec\.md'
            ($script:capturedPaths -join '|') | Should -Match '2026-05-10-foo-1/user-story\.md'
        }

        It 'accepts backslash separators inside the prompt path' {
            Mock -CommandName Get-PrdFeatureFileExistence -MockWith { $true }
            $json = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'docs\features\active\2026-05-10-foo-1' }
                } | ConvertTo-Json -Compress -Depth 5)
            (Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'Entrypoint transport' {
        It 'reads the payload through the shared reader' {
            $hookText = Get-Content -Path $script:UnderTest -Raw

            $hookText | Should -BeLike '*HookPayload.psm1*'
            $hookText | Should -BeLike '*Read-ClaudeHookRawPayload*'
        }

        It 'emits a block decision JSON when prerequisites are missing (AC-7)' {
            $payload = (@{
                    tool_name  = 'Agent'
                    tool_input = @{ subagent_type = 'atomic-planner'; prompt = 'docs/features/active/__nonexistent_feature_for_test__' }
                } | ConvertTo-Json -Compress -Depth 5)

            $output = Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw $payload |
                ConvertTo-Json -Compress -Depth 5

            $output | Should -Match '"permissionDecision"\s*:\s*"deny"'
            $output | Should -Match 'PRD_FEATURE_BLOCKED'
        }

        It 'real Test-Path wrapper returns $false for a nonexistent path' {
            (Get-PrdFeatureFileExistence -Path 'C:/__nonexistent_path_for_test__.md') | Should -BeFalse
        }

        It 'Get-PrdFeatureCheckpointFolder returns $null when checkpoint is absent' {
            (Get-PrdFeatureCheckpointFolder -CheckpointPath 'C:/__nonexistent_checkpoint_for_test__.json') | Should -BeNullOrEmpty
        }
    }

    Context 'Find-PrdFeatureFolderFromPrompt' {
        It 'returns $null for empty prompt' {
            Find-PrdFeatureFolderFromPrompt -Prompt '' | Should -BeNullOrEmpty
        }
        It 'returns $null when no docs/features/active path is present' {
            Find-PrdFeatureFolderFromPrompt -Prompt 'just text here' | Should -BeNullOrEmpty
        }
        It 'returns the folder when one is present' {
            Find-PrdFeatureFolderFromPrompt -Prompt 'in docs/features/active/abc-1 we have' | Should -Be 'docs/features/active/abc-1'
        }
        It 'strips .md suffix to a folder parent' {
            Find-PrdFeatureFolderFromPrompt -Prompt 'see docs/features/active/abc-1/spec.md' | Should -Be 'docs/features/active/abc-1'
        }
    }
}
