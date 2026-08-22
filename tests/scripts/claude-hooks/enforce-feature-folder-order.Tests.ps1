#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

Describe 'enforce-feature-folder-order.ps1' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-feature-folder-order.ps1").Path
        . $script:UnderTest
    }

    Context 'tool input parsing' {
        It 'denies an empty payload as an envelope anomaly (fail closed)' {
            $decision = Invoke-FeatureFolderOrderDecision -ToolInputRaw ''
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'FEATURE_FOLDER_ORDER_BLOCKED'
        }

        It 'allows when file_path is missing' {
            $json = '{"tool_input":{"other":"value"}}'
            $decision = Invoke-FeatureFolderOrderDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows when file_path is not a plan.md path' {
            $json = '{"tool_input":{"file_path":"docs/features/active/foo/issue.md"}}'
            $decision = Invoke-FeatureFolderOrderDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows for plan.md outside docs/features' {
            $json = '{"tool_input":{"file_path":"some/other/dir/plan.md"}}'
            $decision = Invoke-FeatureFolderOrderDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies unparseable JSON instead of throwing (exit 1 is non-blocking)' {
            $decision = Invoke-FeatureFolderOrderDecision -ToolInputRaw '{not-json'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'not parseable JSON'
        }

        It 'denies the legacy flat root shape as a missing-tool_input anomaly' {
            $flat = '{"file_path":"docs/features/active/foo/issue.md"}'
            $decision = Invoke-FeatureFolderOrderDecision -ToolInputRaw $flat
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'no tool_input key'
        }
    }

    Context 'plan.md in a feature folder' {
        It 'allows when all three sibling files exist' {
            Mock -CommandName Get-FeatureFolderFileExistence -MockWith { $true }
            $json = '{"tool_input":{"file_path":"docs/features/active/2026-01-01-foo-1/plan.md"}}'
            $decision = Invoke-FeatureFolderOrderDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies when issue.md is missing' {
            Mock -CommandName Get-FeatureFolderFileExistence -MockWith {
                param([string]$Path)
                return -not ($Path -match '/issue\.md$')
            }
            $json = '{"tool_input":{"file_path":"docs/features/active/2026-01-01-foo-1/plan.md"}}'
            $decision = Invoke-FeatureFolderOrderDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'issue\.md'
        }

        It 'denies when spec.md is missing' {
            Mock -CommandName Get-FeatureFolderFileExistence -MockWith {
                param([string]$Path)
                return -not ($Path -match '/spec\.md$')
            }
            $json = '{"tool_input":{"file_path":"docs/features/active/2026-01-01-foo-1/plan.md"}}'
            $decision = Invoke-FeatureFolderOrderDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'spec\.md'
        }

        It 'denies when user-story.md is missing' {
            Mock -CommandName Get-FeatureFolderFileExistence -MockWith {
                param([string]$Path)
                return -not ($Path -match '/user-story\.md$')
            }
            $json = '{"tool_input":{"file_path":"docs/features/active/2026-01-01-foo-1/plan.md"}}'
            $decision = Invoke-FeatureFolderOrderDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'user-story\.md'
        }

        It 'deny reason names all missing files when multiple are absent' {
            Mock -CommandName Get-FeatureFolderFileExistence -MockWith { $false }
            $json = '{"tool_input":{"file_path":"docs/features/active/2026-01-01-foo-1/plan.md"}}'
            $decision = Invoke-FeatureFolderOrderDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'issue\.md'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'spec\.md'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'user-story\.md'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'prd-feature'
        }

        It 'serializes the deny decision into the PreToolUse hookSpecificOutput envelope' {
            Mock -CommandName Get-FeatureFolderFileExistence -MockWith { $false }
            $json = '{"tool_input":{"file_path":"docs/features/active/2026-01-01-foo-1/plan.md"}}'
            $decision = Invoke-FeatureFolderOrderDecision -ToolInputRaw $json
            $parsed = $decision | ConvertTo-Json -Depth 5 | ConvertFrom-Json
            $parsed.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'normalizes backslashes in the file_path' {
            Mock -CommandName Get-FeatureFolderFileExistence -MockWith { $false }
            $json = '{"tool_input":{"file_path":"docs\\features\\active\\2026-01-01-foo-1\\plan.md"}}'
            $decision = Invoke-FeatureFolderOrderDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'handles archive feature folders too' {
            Mock -CommandName Get-FeatureFolderFileExistence -MockWith { $false }
            $json = '{"tool_input":{"file_path":"docs/features/archive/2025-12-01-old-1/plan.md"}}'
            $decision = Invoke-FeatureFolderOrderDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }
    }

    Context 'Entrypoint (exit code seam, no child process)' {
        It 'returns exit code 0 and emits a deny when every transport is empty' {
            $emptyReader = {
                Read-ClaudeHookRawPayload `
                    -ReadStandardInput { '' } `
                    -TestStandardInputRedirected { $true } `
                    -HookInputFallback '' `
                    -ToolInputFallback ''
            }
            $emitted = @(Invoke-FeatureFolderOrderEntryPoint -ReadPayload $emptyReader)
            $emitted[-1] | Should -Be 0
            $emitted[-1] | Should -Not -Be 1
            $output = $emitted[0] | ConvertFrom-Json
            $output.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $output.hookSpecificOutput.permissionDecision | Should -Be 'deny'
        }

        It 'returns exit code 0 and emits an allow decision JSON for an out-of-scope path' {
            $nested = '{"tool_name":"Write","tool_input":{"file_path":"src/hello.ts","content":"x"}}'
            $emitted = @(Invoke-FeatureFolderOrderEntryPoint -ToolInputRaw $nested)
            $emitted[-1] | Should -Be 0
            $output = $emitted[0] | ConvertFrom-Json
            $output.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $output.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'returns exit code 0 and emits a deny decision JSON when prerequisites are missing' {
            # Point at a non-existent feature folder so Test-Path returns false.
            $nested = '{"tool_name":"Write","tool_input":{"file_path":"docs/features/active/__nonexistent_feature_for_test__/plan.md","content":"x"}}'
            $emitted = @(Invoke-FeatureFolderOrderEntryPoint -ToolInputRaw $nested)
            $emitted[-1] | Should -Be 0
            $output = $emitted[0] | ConvertFrom-Json
            $output.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $output.hookSpecificOutput.permissionDecisionReason | Should -Match 'FEATURE_FOLDER_ORDER_BLOCKED'
        }

        It 'real Test-Path wrapper returns $false for a nonexistent path' {
            (Get-FeatureFolderFileExistence -Path 'C:/__nonexistent_path_for_test__.md') | Should -BeFalse
        }
    }

    Context 'Test-IsFeaturePlanPath' {
        It 'recognizes a canonical active plan.md path' {
            (Test-IsFeaturePlanPath -NormalizedPath 'docs/features/active/foo/plan.md') | Should -BeTrue
        }
        It 'recognizes a canonical archive plan.md path' {
            (Test-IsFeaturePlanPath -NormalizedPath 'docs/features/archive/foo/plan.md') | Should -BeTrue
        }
        It 'rejects non-plan files' {
            (Test-IsFeaturePlanPath -NormalizedPath 'docs/features/active/foo/issue.md') | Should -BeFalse
        }
        It 'rejects paths outside docs/features' {
            (Test-IsFeaturePlanPath -NormalizedPath 'other/plan.md') | Should -BeFalse
        }
    }
}
