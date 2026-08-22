#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
<#
.SYNOPSIS
    Pester tests for the enforce-epic-worktree-removal-gate.ps1 PreToolUse hook.
#>

Describe 'enforce-epic-worktree-removal-gate.ps1' {
    BeforeAll {
        $script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-worktree-removal-gate.ps1").Path
        . $script:UnderTest
    }

    Context 'commands outside scope' {
        It 'denies an empty payload as an envelope anomaly (fail closed)' {
            $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw ''
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_WORKTREE_REMOVAL_BLOCKED'
        }

        It 'allows when the JSON payload has no command field' {
            $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw '{"tool_input":{"other":"value"}}'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'allows a non git-worktree-remove Bash command' {
            $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw '{"tool_input":{"command":"git worktree list"}}'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }

        It 'denies unparseable JSON instead of throwing (exit 1 is non-blocking)' {
            $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw '{not-json'
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'not parseable JSON'
        }
    }

    Context 'allow on merge_status merged' {
        It 'allows git worktree remove when the matching record has merge_status merged' {
            Mock -CommandName Get-EpicWorktreeGateCheckpointContent -MockWith {
                '{"features":[{"worktree_path":"/repo/worktrees/child-a","merge_status":"merged"}]}'
            }
            $json = '{"tool_input":{"command":"git worktree remove /repo/worktrees/child-a"}}'
            $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'allow on merge_status worktree_removed' {
        It 'allows git worktree remove when the matching record has merge_status worktree_removed' {
            Mock -CommandName Get-EpicWorktreeGateCheckpointContent -MockWith {
                '{"features":[{"worktree_path":"/repo/worktrees/child-a","merge_status":"worktree_removed"}]}'
            }
            $json = '{"tool_input":{"command":"git worktree remove /repo/worktrees/child-a"}}'
            $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'deny on unreadable checkpoint' {
        It 'denies EPIC_WORKTREE_REMOVAL_BLOCKED when the checkpoint file is absent' {
            Mock -CommandName Get-EpicWorktreeGateCheckpointContent -MockWith { $null }
            $json = '{"tool_input":{"command":"git worktree remove /repo/worktrees/child-a"}}'
            $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_WORKTREE_REMOVAL_BLOCKED'
        }

        It 'denies EPIC_WORKTREE_REMOVAL_BLOCKED when the checkpoint content is malformed JSON' {
            Mock -CommandName Get-EpicWorktreeGateCheckpointContent -MockWith { '{ broken json' }
            $json = '{"tool_input":{"command":"git worktree remove /repo/worktrees/child-a"}}'
            $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_WORKTREE_REMOVAL_BLOCKED'
        }
    }

    Context 'deny on no matching record' {
        It 'denies when no features[] record has a matching worktree_path' {
            Mock -CommandName Get-EpicWorktreeGateCheckpointContent -MockWith {
                '{"features":[{"worktree_path":"/repo/worktrees/child-b","merge_status":"merged"}]}'
            }
            $json = '{"tool_input":{"command":"git worktree remove /repo/worktrees/child-a"}}'
            $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_WORKTREE_REMOVAL_BLOCKED'
        }
    }

    Context 'deny on other merge_status' {
        It 'denies when the matching record has merge_status pr_open' {
            Mock -CommandName Get-EpicWorktreeGateCheckpointContent -MockWith {
                '{"features":[{"worktree_path":"/repo/worktrees/child-a","merge_status":"pr_open"}]}'
            }
            $json = '{"tool_input":{"command":"git worktree remove /repo/worktrees/child-a"}}'
            $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_WORKTREE_REMOVAL_BLOCKED'
        }
    }

    Context 'path normalization' {
        It 'matches worktree_path across backslash/forward-slash separator differences' {
            Mock -CommandName Get-EpicWorktreeGateCheckpointContent -MockWith {
                '{"features":[{"worktree_path":"C:\\repo\\worktrees\\child-a","merge_status":"merged"}]}'
            }
            $json = '{"tool_input":{"command":"git worktree remove C:/repo/worktrees/child-a"}}'
            $decision = Invoke-EpicWorktreeRemovalGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }

    Context 'Get-EpicWorktreeRemovalCommandPath helper' {
        It 'extracts the target path from the command text' {
            Get-EpicWorktreeRemovalCommandPath -CommandText 'git worktree remove /repo/worktrees/child-a' |
                Should -Be '/repo/worktrees/child-a'
        }

        It 'returns $null when the command does not name a path' {
            Get-EpicWorktreeRemovalCommandPath -CommandText 'git status' | Should -BeNullOrEmpty
        }
    }

    Context 'Find-EpicWorktreeFeatureRecord helper' {
        It 'returns $null when Checkpoint is $null' {
            Find-EpicWorktreeFeatureRecord -Checkpoint $null -WorktreePath '/repo/a' | Should -BeNullOrEmpty
        }

        It 'returns $null when features key is absent' {
            $checkpoint = '{}' | ConvertFrom-Json
            Find-EpicWorktreeFeatureRecord -Checkpoint $checkpoint -WorktreePath '/repo/a' | Should -BeNullOrEmpty
        }

        It 'skips feature records with no worktree_path key' {
            $checkpoint = '{"features":[{"feature_folder":"a"}]}' | ConvertFrom-Json
            Find-EpicWorktreeFeatureRecord -Checkpoint $checkpoint -WorktreePath '/repo/a' | Should -BeNullOrEmpty
        }
    }

    Context 'Test-EpicWorktreeRemovalAllowed helper' {
        It 'returns $false when FeatureRecord is $null' {
            Test-EpicWorktreeRemovalAllowed -FeatureRecord $null | Should -BeFalse
        }

        It 'returns $false when merge_status key is absent' {
            $feature = '{"feature_folder":"a"}' | ConvertFrom-Json
            Test-EpicWorktreeRemovalAllowed -FeatureRecord $feature | Should -BeFalse
        }
    }

    Context 'real Test-Path read seam' {
        It 'Get-EpicWorktreeGateCheckpointContent returns $null when the checkpoint file does not exist' {
            Mock -CommandName Test-Path -MockWith { $false } -ParameterFilter { $LiteralPath -eq $script:EpicCheckpointPath }
            Get-EpicWorktreeGateCheckpointContent | Should -BeNullOrEmpty
        }

        It 'Get-EpicWorktreeGateCheckpointContent reads real content when the file exists' {
            Mock -CommandName Test-Path -MockWith { $true } -ParameterFilter { $LiteralPath -eq $script:EpicCheckpointPath }
            Mock -CommandName Get-Content -MockWith { '{"features":[]}' } -ParameterFilter { $LiteralPath -eq $script:EpicCheckpointPath }
            Get-EpicWorktreeGateCheckpointContent | Should -Be '{"features":[]}'
        }
    }

    Context 'entry-point exit code and emitted decision (AC-4, no child process)' {
        BeforeEach {
            Mock -CommandName Get-EpicWorktreeGateCheckpointContent -MockWith { $null }
        }


        It 'returns exit code 0 and emits a deny when every transport is empty' {
            $emptyReader = {
                Read-ClaudeHookRawPayload `
                    -ReadStandardInput { '' } `
                    -TestStandardInputRedirected { $true } `
                    -HookInputFallback '' `
                    -ToolInputFallback ''
            }
            $emitted = Invoke-EpicWorktreeRemovalGateEntryPoint -ReadPayload $emptyReader
            $emitted[-1] | Should -Be 0
            $emitted[-1] | Should -Not -Be 1
            $parsed = $emitted[0] | ConvertFrom-Json
            $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $parsed.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_WORKTREE_REMOVAL_BLOCKED'
        }

        It 'returns exit code 0 and emits a deny for unparseable JSON' {
            $emitted = Invoke-EpicWorktreeRemovalGateEntryPoint -ToolInputRaw '{not-json'
            $emitted[-1] | Should -Be 0
            $emitted[-1] | Should -Not -Be 1
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason |
                Should -Match 'not parseable JSON'
        }

        It 'returns exit code 0 and emits a deny for JSON with no tool_input key' {
            $emitted = Invoke-EpicWorktreeRemovalGateEntryPoint -ToolInputRaw '{"session_id":"s1","tool_name":"Bash"}'
            $emitted[-1] | Should -Be 0
            $emitted[-1] | Should -Not -Be 1
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason |
                Should -Match 'no tool_input key'
        }

        It 'returns exit code 0 and emits a deny for a null tool_input' {
            $emitted = Invoke-EpicWorktreeRemovalGateEntryPoint -ToolInputRaw '{"tool_name":"Bash","tool_input":null}'
            $emitted[-1] | Should -Be 0
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason |
                Should -Match 'tool_input is null'
        }

        It 'returns exit code 0 and emits a deny for a non-object tool_input' {
            $emitted = Invoke-EpicWorktreeRemovalGateEntryPoint -ToolInputRaw '{"tool_name":"Bash","tool_input":"text"}'
            $emitted[-1] | Should -Be 0
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecisionReason |
                Should -Match 'not an object'
        }

        It 'denies the nested envelope end-to-end when no checkpoint record authorizes removal' {
            $nested = '{"tool_name":"Bash","tool_input":{"command":"git worktree remove /repo/worktrees/child-a"}}'
            $emitted = Invoke-EpicWorktreeRemovalGateEntryPoint -ToolInputRaw $nested
            $emitted[-1] | Should -Be 0
            $parsed = $emitted[0] | ConvertFrom-Json
            $parsed.hookSpecificOutput.hookEventName | Should -Be 'PreToolUse'
            $parsed.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $parsed.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_WORKTREE_REMOVAL_BLOCKED'
        }

        It 'allows the nested envelope when the checkpoint records the worktree as merged' {
            Mock -CommandName Get-EpicWorktreeGateCheckpointContent -MockWith {
                '{"features":[{"worktree_path":"/repo/worktrees/child-a","merge_status":"merged"}]}'
            }
            $nested = '{"tool_name":"Bash","tool_input":{"command":"git worktree remove /repo/worktrees/child-a"}}'
            $emitted = Invoke-EpicWorktreeRemovalGateEntryPoint -ToolInputRaw $nested
            $emitted[-1] | Should -Be 0
            ($emitted[0] | ConvertFrom-Json).hookSpecificOutput.permissionDecision | Should -Be 'allow'
        }
    }
}
